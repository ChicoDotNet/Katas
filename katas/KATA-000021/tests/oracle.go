// SPDX-License-Identifier: MIT
// Independent greedy integer encoder, not a translation of Prolog's place DCG.
package main

import (
    "bufio"
    "bytes"
    "flag"
    "fmt"
    "os"
    "os/exec"
    "strconv"
    "strings"
)

type token struct { value int; text string }
var tokens = []token{
    {1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
    {100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
    {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"},
}
func greedy(n int) string {
    var b strings.Builder
    for _, t := range tokens {
        for n >= t.value { b.WriteString(t.text); n -= t.value }
    }
    return b.String()
}
func independentValue(s string) int {
    symbol := map[byte]int{'I':1,'V':5,'X':10,'L':50,'C':100,'D':500,'M':1000}
    total := 0
    for i:=0; i<len(s); i++ {
        value := symbol[s[i]]
        if i+1<len(s) && value<symbol[s[i+1]] { total-=value } else { total+=value }
    }
    return total
}
func main() {
    cli := flag.String("cli", "src/cli.pl", "Prolog CLI path")
    flag.Parse()
    var input []string
    for n:=1;n<=3999;n++ { input=append(input,strconv.Itoa(n)) }
    invalid:=[]string{"", "0", "4000", "-1", "01", " 1", "1 ", "1.0", "X", "Ⅳ", "99999", "+3"}
    input=append(input,invalid...)
    command:=exec.Command("swipl","-q","-s",*cli)
    command.Stdin=strings.NewReader(strings.Join(input,"\n")+"\n")
    var stderr bytes.Buffer
    command.Stderr=&stderr
    output,err:=command.Output()
    if err!=nil {fmt.Fprintf(os.Stderr,"CLI FAILED: %v: %s\n",err,stderr.String());os.Exit(2)}
    scanner:=bufio.NewScanner(bytes.NewReader(output))
    var actual []string
    for scanner.Scan() {actual=append(actual,scanner.Text())}
    if err:=scanner.Err();err!=nil {panic(err)}
    if len(actual)!=len(input) {fmt.Fprintf(os.Stderr,"DIFF line count: got %d want %d; stderr=%s\n",len(actual),len(input),stderr.String());os.Exit(1)}
    metamorphic:=0
    for n:=1;n<=3999;n++ {
        want:=greedy(n)
        if actual[n-1]!=want {fmt.Fprintf(os.Stderr,"DIFF %d: got %q want %q\n",n,actual[n-1],want);os.Exit(1)}
        if independentValue(actual[n-1])!=n {fmt.Fprintf(os.Stderr,"DIFF value %d: %q\n",n,actual[n-1]);os.Exit(1)}
        if n<=2999 && actual[n+999]!="M"+actual[n-1] {fmt.Fprintf(os.Stderr,"DIFF metamorphic +1000 at %d\n",n);os.Exit(1)}
        if n<=2999 {metamorphic++}
    }
    for i,s:=range invalid {if actual[3999+i]!="ERR" {fmt.Fprintf(os.Stderr,"DIFF invalid %q: %q\n",s,actual[3999+i]);os.Exit(1)}}
    fmt.Printf("PASS 3999 greedy comparisons, 3999 independent numeric decodes, %d metamorphic shifts, %d invalid lines\n",metamorphic,len(invalid))
}
