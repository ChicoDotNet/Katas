package main

import (
    "fmt"
    "math/rand"
    "os"
    "os/exec"
    "path/filepath"
    "regexp"
    "strconv"
    "strings"
)

type TestCase struct {
    Pattern string
    Flags string
    Files []string
    Lines map[string][]string
}
func asciiLower(s string) string {
    return strings.Map(func(r rune) rune {if r >= 'A' && r <= 'Z' {return r + ('a'-'A')}; return r}, s)
}
// Oracle A: fixed substring/index and exact equality; no Perl regex engine.
func containsIndex(line, pattern string, flags string) bool {
    if strings.Contains(flags, "i") {line=asciiLower(line); pattern=asciiLower(pattern)}
    match := strings.Contains(line,pattern)
    if strings.Contains(flags,"x") {match = line == pattern}
    if strings.Contains(flags,"v") {match = !match}
    return match
}
// Oracle B: quote and compile a literal regex, with full-line anchors when -x.
// Its matching engine is distinct from both Perl's index() and Oracle A.
func containsRegex(line, pattern string, flags string) bool {
    if strings.Contains(flags,"i") {line=asciiLower(line); pattern=asciiLower(pattern)}
    re := regexp.QuoteMeta(pattern)
    if strings.Contains(flags,"x") {re = "^" + regexp.QuoteMeta(pattern) + "$"}
    matched := regexp.MustCompile(re).MatchString(line)
    if strings.Contains(flags,"v") {matched = !matched}
    return matched
}
func render(c TestCase, matcher func(string,string,string)bool) string {
    var out strings.Builder
    for _, file := range c.Files {
        lines := c.Lines[file]
        for i, line := range lines {
            if !matcher(line,c.Pattern,c.Flags) {continue}
            if strings.Contains(c.Flags,"l") {out.WriteString(file); out.WriteByte('\n'); break}
            if len(c.Files)>1 {out.WriteString(file);out.WriteByte(':')}
            if strings.Contains(c.Flags,"n") {out.WriteString(strconv.Itoa(i+1));out.WriteByte(':')}
            out.WriteString(line);out.WriteByte('\n')
        }
    }
    return out.String()
}
func run(impl string,c TestCase) (string,error) {
    args:=[]string{impl}
    for _,flag:=range c.Flags {args=append(args,"-"+string(flag))}
    args=append(args,"--",c.Pattern)
    args=append(args,c.Files...)
    cmd:=exec.Command("perl",args...)
    out,err:=cmd.CombinedOutput()
    return string(out),err
}
func main() {
    impl:="src/grep.pl"
    if len(os.Args)>1 {impl=os.Args[1]}
    if !filepath.IsAbs(impl) {p,_:=filepath.Abs(impl);impl=p}
    root,err:=os.MkdirTemp("","ninja-grep-oracle-")
    if err!=nil {panic(err)}
    defer os.RemoveAll(root)
    rng:=rand.New(rand.NewSource(20261022))
    alphabet:=[]string{"alpha","BETA","a.b","a?b","needle","NEEDLE","","space bar","caf\u00e9","x:y","[a-z]","zebra","ALPHA","-x","-needle"}
    patterns:=[]string{"alpha","ALPHA","needle","e","a.b","a?b","[a-z]","","caf\u00e9","x:y","zebra","BETA","missing","-x","-needle"}
    limit:=900
    if s:=os.Getenv("KATA_ORACLE_CASES");s!="" {
        n,e:=strconv.Atoi(s);if e!=nil||n<1||n>900 {panic("invalid oracle case limit")}
        limit=n
    }
    cases:=0
    independentChecks:=0
    metamorphicPairs:=0
    for i:=0;i<limit;i++ {
        n:=1+rng.Intn(3)
        paths:=make([]string,0,n)
        lines:=make(map[string][]string)
        for j:=0;j<n;j++ {
            path:=filepath.Join(root,fmt.Sprintf("case%d_file%d.txt",i,j))
            count:=rng.Intn(11)
            ls:=make([]string,0,count)
            for k:=0;k<count;k++ {ls=append(ls,alphabet[rng.Intn(len(alphabet))])}
            lines[path]=ls
            if err:=os.WriteFile(path,[]byte(strings.Join(ls,"\n")+func()string{if len(ls)>0{return "\n"};return ""}()),0600);err!=nil {panic(err)}
            paths=append(paths,path)
        }
        flagset:=""
        for _,f:=range "nilvx" {if rng.Intn(2)==0 {flagset+=string(f)}}
        c:=TestCase{patterns[rng.Intn(len(patterns))],flagset,paths,lines}
        a:=render(c,containsIndex)
        b:=render(c,containsRegex)
        if a!=b {panic(fmt.Sprintf("oracles disagree case %d: %q != %q",i,a,b))}
        got,err:=run(impl,c)
        if err!=nil || got!=a {panic(fmt.Sprintf("case %d: error=%v\nwant %q\ngot  %q\nflags %q pattern %q",i,err,a,got,c.Flags,c.Pattern))}
        cases++
        independentChecks+=2
        // Metamorphic complement: for a single file, numbered matches and
        // numbered inverted matches partition every original line exactly once.
        if i<200 {
            single:=TestCase{c.Pattern,"n",[]string{paths[0]},lines}
            if strings.Contains(c.Flags,"i") {single.Flags+="i"}
            if strings.Contains(c.Flags,"x") {single.Flags+="x"}
            positive,err:=run(impl,single);if err!=nil {panic(err)}
            single.Flags+="v"
            negative,err:=run(impl,single);if err!=nil {panic(err)}
            seen:=map[int]int{}
            for _,output:=range []string{positive,negative} {
                for _,line:=range strings.Split(strings.TrimSuffix(output,"\n"),"\n") {
                    if line=="" {continue}
                    fields:=strings.SplitN(line,":",2)
                    k,e:=strconv.Atoi(fields[0]);if e!=nil {panic(e)}
                    seen[k]++
                }
            }
            if len(seen)!=len(lines[paths[0]]) {panic("metamorphic complement lost a line")}
            for k:=1;k<=len(lines[paths[0]]);k++ {if seen[k]!=1 {panic("metamorphic complement duplicate/missing")}}
            metamorphicPairs++
        }
    }
    // Guard the oracle against a trivial always-empty implementation.
    c:=TestCase{"needle","",[]string{filepath.Join(root,"witness.txt")},map[string][]string{}}
    c.Lines[c.Files[0]]=[]string{"needle","other"}
    if err:=os.WriteFile(c.Files[0],[]byte("needle\nother\n"),0600);err!=nil {panic(err)}
    if got,err:=run(impl,c);err!=nil||got!="needle\n" {panic("witness failed")}
    fmt.Printf("PASS Perl CLI versus two independent Go matchers: %d randomized cases, %d oracle checks, %d complement pairs, 1 witness\n",cases,independentChecks,metamorphicPairs)
}
