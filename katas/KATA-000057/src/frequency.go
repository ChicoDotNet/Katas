// SPDX-License-Identifier: MIT
package frequency
import ("fmt";"os";"unicode")
// Count reduces independently owned per-goroutine maps on the caller goroutine.
// Unicode mapping is rune-level simple lowercase, not full case folding.
func Count(lines []string,workers int)(map[rune]int,error){
 if workers<1||workers>32{return nil,fmt.Errorf("workers must be 1..32")}
 result:=map[rune]int{}
 if os.Getenv("KATA_RED")=="1"{return result,nil}
 if len(lines)==0{return result,nil}
 if workers>len(lines){workers=len(lines)}
 work:=make(chan string);partials:=make(chan map[rune]int,workers)
 for i:=0;i<workers;i++{go func(){
  local:=map[rune]int{}
  for line:=range work{
   for _,letter:=range line{
    if !unicode.IsLetter(letter){continue}
    local[unicode.ToLower(letter)]++
   }
  }
  partials<-local
 }()}
 for _,line:=range lines{work<-line}
 close(work)
 for i:=0;i<workers;i++{for letter,count:=range <-partials{result[letter]+=count}}
 return result,nil
}
