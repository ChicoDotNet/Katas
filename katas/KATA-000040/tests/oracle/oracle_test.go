package oracle

import (
 "bytes"
 "context"
 "encoding/json"
 "fmt"
 "math"
 "math/rand"
 "os"
 "os/exec"
 "reflect"
 "sort"
 "testing"
 "time"
)

type Request struct { A []int64 `json:"a"`; B []int64 `json:"b"`; Insert int64 `json:"insert"`; Remove int64 `json:"remove"` }
type Response struct { A []int64 `json:"a"`; B []int64 `json:"b"`; Union []int64 `json:"union"`; Intersection []int64 `json:"intersection"`; Difference []int64 `json:"difference"`; Subset bool `json:"subset"`; Disjoint bool `json:"disjoint"`; Equal bool `json:"equal"`; Inserted []int64 `json:"inserted"`; Removed []int64 `json:"removed"` }

// Reference 1: hash-set algebra, independent of Swift's sorted-array merge.
func model(q Request) Response {
 a, b := map[int64]bool{}, map[int64]bool{}
 for _,v := range q.A { a[v] = true }
 for _,v := range q.B { b[v] = true }
 canonical := func(m map[int64]bool) []int64 { out:=make([]int64,0,len(m)); for v:=range m {out=append(out,v)};sort.Slice(out,func(i,j int)bool{return out[i]<out[j]});return out }
 union, intersection, difference := map[int64]bool{},map[int64]bool{},map[int64]bool{}
 for v:=range a {union[v]=true;if b[v]{intersection[v]=true}else{difference[v]=true}}
 for v:=range b {union[v]=true}
 inserted, removed := map[int64]bool{},map[int64]bool{}
 for v:=range a {inserted[v]=true;removed[v]=true}
 inserted[q.Insert]=true;delete(removed,q.Remove)
 subset:=true;for v:=range a{if !b[v]{subset=false}}
 equal:=len(a)==len(b)&&subset
 return Response{canonical(a),canonical(b),canonical(union),canonical(intersection),canonical(difference),subset,len(intersection)==0,equal,canonical(inserted),canonical(removed)}
}

// Reference 2: a bounded-domain algebraic bitmask, not a second map or sorted merge.
// The 41 bits represent integer values -20..20. This catches mistakes in the map oracle itself.
func mask(values []int64) uint64 { var m uint64; for _,v:=range values {m |= uint64(1)<<uint(v+20)};return m }
func unmask(m uint64) []int64 {r:=[]int64{};for i:=0;i<41;i++{if m&(uint64(1)<<uint(i))!=0{r=append(r,int64(i-20))}};return r}
func bitset(q Request) Response {
 a,b:=mask(q.A),mask(q.B)
 ai:=a|(uint64(1)<<uint(q.Insert+20));ar:=a & ^(uint64(1)<<uint(q.Remove+20))
 return Response{unmask(a),unmask(b),unmask(a|b),unmask(a&b),unmask(a & ^b),a & ^b==0,a&b==0,a==b,unmask(ai),unmask(ar)}
}

func TestIndependentModels(t *testing.T){
 rng:=rand.New(rand.NewSource(9001))
 for i:=0;i<3000;i++{q:=randomRequest(rng,true);a,b:=model(q),bitset(q);if !reflect.DeepEqual(a,b){t.Fatalf("independent Go model discrepancy at %d: map=%+v bitset=%+v",i,a,b)}}
}
func randomRequest(rng *rand.Rand, bounded bool) Request {
 q := Request{A: []int64{}, B: []int64{}}
 choose:=func()int64{if bounded{return int64(rng.Intn(41)-20)};switch rng.Intn(30){case 0:return math.MinInt64;case 1:return math.MaxInt64;default:return rng.Int63n(200000)-100000}}
 for i:=rng.Intn(32);i>0;i--{q.A=append(q.A,choose())}
 for i:=rng.Intn(32);i>0;i--{q.B=append(q.B,choose())}
 q.Insert=choose();q.Remove=choose()
 return q
}

func TestRealSwiftProcessDifferential(t *testing.T){
 binary:=os.Getenv("SWIFT_SET_BINARY");if binary==""{t.Fatal("SWIFT_SET_BINARY must point to compiled genuine Swift implementation")}
 rng:=rand.New(rand.NewSource(20261027))
 queries:=[]Request{
  {[]int64{},[]int64{},0,0},
  {[]int64{math.MinInt64,math.MaxInt64,0,0},[]int64{math.MinInt64,1},math.MaxInt64,math.MinInt64},
  {[]int64{2,2,2},[]int64{2,2},-1,2},
  {[]int64{-1,-2,-3},[]int64{1,2,3},0,-2},
 }
 for i:=0;i<700;i++{queries=append(queries,randomRequest(rng,i<350))}
 // Actual second execution per swapped input; commutativity is checked against Swift, not just the model.
 total:=len(queries)
 for i:=0;i<total;i++{q:=queries[i];queries=append(queries,Request{q.B,q.A,q.Insert,q.Remove})}
 var input bytes.Buffer
 for _,q:=range queries {raw,e:=json.Marshal(q);if e!=nil{t.Fatal(e)};input.Write(raw);input.WriteByte('\n')}
 ctx,cancel:=context.WithTimeout(context.Background(),90*time.Second);defer cancel()
 cmd:=exec.CommandContext(ctx,binary);cmd.Stdin=&input;var output,stderr bytes.Buffer;cmd.Stdout=&output;cmd.Stderr=&stderr
 if err:=cmd.Run();err!=nil{t.Fatalf("real Swift process failed: %v stderr=%s",err,stderr.String())}
 lines:=bytes.Split(bytes.TrimSpace(output.Bytes()),[]byte{'\n'});if len(lines)!=len(queries){t.Fatalf("premature EOF or extra output: got %d lines expected %d, stderr=%s",len(lines),len(queries),stderr.String())}
 results:=make([]Response,0,len(lines))
 for i,line:=range lines {var got Response;if err:=json.Unmarshal(line,&got);err!=nil{t.Fatalf("response %d invalid JSON: %v",i,err)}
  want:=model(queries[i]);if !reflect.DeepEqual(got,want){t.Fatalf("case %d: Swift=%+v independent map=%+v input=%+v",i,got,want,queries[i])}
  if i<total && i>=4 && i-4<350 {bits:=bitset(queries[i]);if !reflect.DeepEqual(got,bits){t.Fatalf("case %d: Swift differs from independent bitset: %+v %+v",i,got,bits)}}
  results=append(results,got)
 }
 for i:=0;i<total;i++{orig,swapped:=results[i],results[i+total];if !reflect.DeepEqual(orig.Union,swapped.Union)||!reflect.DeepEqual(orig.Intersection,swapped.Intersection){t.Fatalf("real-process commutativity failed %d",i)}}
 fmt.Printf("ORACLE PASS: %d genuine Swift JSONL requests, %d real swapped pairs, 3000 map-vs-bitset crosschecks\n",len(queries),total)
}
func TestInvalidRequestRejected(t *testing.T){
 binary:=os.Getenv("SWIFT_SET_BINARY");if binary==""{t.Fatal("SWIFT_SET_BINARY required")}
 cmd:=exec.Command(binary);cmd.Stdin=bytes.NewBufferString("{\"a\": [1], \"b\": [], \"insert\": 1}\n");out,err:=cmd.CombinedOutput();if err==nil{t.Fatalf("invalid request unexpectedly accepted: %s",out)}
}
