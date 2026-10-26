// KATA-000053: structurally independent graph/BFS oracle for Swift tree reroot.
// Copyright (c) 2026 ChicoDotNet. MIT. No upstream fixtures imported.
package main

import (
    "bufio"
    "encoding/json"
    "fmt"
    "os"
    "os/exec"
    "reflect"
    "sort"
)

type Tree struct {
    Label string `json:"label"`
    Children []Tree `json:"children"`
}
type Request struct {
    Action string `json:"action"`
    Tree Tree `json:"tree"`
    From string `json:"from"`
    To string `json:"to,omitempty"`
}
type Response struct {
    Tree *Tree `json:"tree"`
    Path []string `json:"path"`
}

type PRNG struct{ value uint64 }
func (r *PRNG) next() uint64 {
    r.value = r.value*2862933555777941757 + 3037000493
    return r.value
}
func generate(size int, seed uint64) Tree {
    r := PRNG{value: seed}
    parents := make([]int, size)
    for i:=1; i<size; i++ { parents[i] = int(r.next() % uint64(i)) }
    var makeNode func(int) Tree
    makeNode = func(id int) Tree {
        node := Tree{Label:fmt.Sprintf("n%d",id), Children: []Tree{}}
        for child:=id+1; child<size; child++ {
            if parents[child]==id { node.Children=append(node.Children,makeNode(child)) }
        }
        return node
    }
    return makeNode(0)
}
func adjacency(tree Tree) map[string][]string {
    edges := map[string][]string{}
    var walk func(Tree)
    walk = func(t Tree) {
        if _,exists:=edges[t.Label];!exists { edges[t.Label]=[]string{} }
        for _,child:=range t.Children {
            edges[t.Label]=append(edges[t.Label],child.Label)
            edges[child.Label]=append(edges[child.Label],t.Label)
            walk(child)
        }
    }
    walk(tree)
    return edges
}
func rootedNeighbors(adj map[string][]string, root string) (map[string][]string,bool) {
    if _,ok:=adj[root];!ok { return nil,false }
    seen:=map[string]bool{root:true}
    directed:=map[string][]string{}
    queue:=[]string{root}
    for len(queue)>0 {
        u:=queue[0];queue=queue[1:]
        for _,v:=range adj[u] {
            if seen[v] {continue}
            seen[v]=true
            directed[u]=append(directed[u],v)
            queue=append(queue,v)
        }
        sort.Strings(directed[u])
    }
    return directed,len(seen)==len(adj)
}
func bfsPath(adj map[string][]string, from,to string) []string {
    if _,ok:=adj[from];!ok {return nil}
    if _,ok:=adj[to];!ok {return nil}
    parent:=map[string]string{from:""}
    queue:=[]string{from}
    for len(queue)>0 {
        u:=queue[0];queue=queue[1:]
        if u==to {break}
        for _,v:=range adj[u] {
            if _,ok:=parent[v];ok {continue}
            parent[v]=u
            queue=append(queue,v)
        }
    }
    if _,ok:=parent[to];!ok {return nil}
    reverse:=[]string{}
    for cur:=to;cur!="";cur=parent[cur] { reverse=append(reverse,cur) }
    result:=make([]string,len(reverse))
    for i:=range reverse { result[i]=reverse[len(reverse)-1-i] }
    return result
}
func verifyReroot(original Tree, actual *Tree, target string) error {
    adj:=adjacency(original)
    expected,exists:=rootedNeighbors(adj,target)
    if !exists {
        if actual!=nil {return fmt.Errorf("missing root %q unexpectedly produced tree",target)}
        return nil
    }
    if actual==nil {return fmt.Errorf("existing root %q returned nil",target)}
    if actual.Label!=target {return fmt.Errorf("root %q, want %q",actual.Label,target)}
    seen:=map[string]bool{}
    var walk func(Tree) error
    walk=func(t Tree) error {
        if seen[t.Label] {return fmt.Errorf("duplicate node %q",t.Label)}
        seen[t.Label]=true
        got:=make([]string,0,len(t.Children))
        for _,child:=range t.Children { got=append(got,child.Label) }
        sort.Strings(got)
        want:=append([]string{},expected[t.Label]...)
        sort.Strings(want)
        if !reflect.DeepEqual(got,want) {return fmt.Errorf("children at %q: got %v want %v",t.Label,got,want)}
        for _,child:=range t.Children {if err:=walk(child);err!=nil{return err}}
        return nil
    }
    if err:=walk(*actual);err!=nil{return err}
    if len(seen)!=len(adj) {return fmt.Errorf("node count %d, expected %d",len(seen),len(adj))}
    return nil
}
func run(binary string) error {
    cmd:=exec.Command(binary)
    stdin,err:=cmd.StdinPipe();if err!=nil{return err}
    stdout,err:=cmd.StdoutPipe();if err!=nil{return err}
    cmd.Stderr=os.Stderr
    if err:=cmd.Start();err!=nil{return err}
    defer func(){_ = stdin.Close();_ = cmd.Process.Kill();_ = cmd.Wait()}()
    reader:=bufio.NewReader(stdout)
    calls:=0
    ask:=func(req Request) (Response,error) {
        var out Response
        data,err:=json.Marshal(req);if err!=nil{return out,err}
        if _,err=stdin.Write(append(data,'\n'));err!=nil{return out,err}
        line,err:=reader.ReadBytes('\n');if err!=nil{return out,err}
        if err=json.Unmarshal(line,&out);err!=nil{return out,err}
        calls++
        return out,nil
    }
    for size:=1;size<=70;size++ {
        original:=generate(size,uint64(size)*0x9e3779b97f4a7c15)
        adj:=adjacency(original)
        if len(adj)!=size {return fmt.Errorf("generator size %d got %d",size,len(adj))}
        for j:=0;j<5;j++ {
            target:=fmt.Sprintf("n%d",(j*37+size/2)%size)
            got,err:=ask(Request{Action:"reroot",Tree:original,From:target});if err!=nil{return err}
            if err=verifyReroot(original,got.Tree,target);err!=nil{return fmt.Errorf("size %d target %s: %w",size,target,err)}
            // Metamorphic: rerooting again at the old root preserves the graph.
            again,err:=ask(Request{Action:"reroot",Tree:*got.Tree,From:"n0"});if err!=nil{return err}
            if err=verifyReroot(original,again.Tree,"n0");err!=nil{return fmt.Errorf("roundtrip %d: %w",size,err)}
            destination:=fmt.Sprintf("n%d",(j*19+size/3)%size)
            path,err:=ask(Request{Action:"path",Tree:original,From:target,To:destination});if err!=nil{return err}
            expected:=bfsPath(adj,target,destination)
            if !reflect.DeepEqual(path.Path,expected) {return fmt.Errorf("size %d path %s -> %s: got %v want %v",size,target,destination,path.Path,expected)}
            reverse,err:=ask(Request{Action:"path",Tree:original,From:destination,To:target});if err!=nil{return err}
            revExpected:=bfsPath(adj,destination,target)
            if !reflect.DeepEqual(reverse.Path,revExpected) {return fmt.Errorf("reverse path mismatch size %d",size)}
        }
        missing,err:=ask(Request{Action:"reroot",Tree:original,From:"absent"});if err!=nil{return err}
        if missing.Tree!=nil {return fmt.Errorf("missing root accepted")}
        missingPath,err:=ask(Request{Action:"path",Tree:original,From:"n0",To:"absent"});if err!=nil{return err}
        if missingPath.Path!=nil {return fmt.Errorf("missing destination accepted")}
    }
    fmt.Printf("Go BFS/adjacency oracle: %d Swift JSONL calls; 70 generated trees, root orientation, path and reversibility PASS\n",calls)
    return nil
}
func main(){
    if len(os.Args)!=2 {fmt.Fprintln(os.Stderr,"usage: go run oracle.go /path/to/swift-cli");os.Exit(2)}
    if err:=run(os.Args[1]);err!=nil {fmt.Fprintln(os.Stderr,"FAIL oracle:",err);os.Exit(1)}
}
