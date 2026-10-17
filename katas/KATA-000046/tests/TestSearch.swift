// SPDX-License-Identifier: MIT
import Foundation
@main struct TestSearch {
 static func check(_ actual: Match,_ start: [Int]?,_ end: [Int]?,_ name: String) {
  guard actual.start == start && actual.end == end else {
   FileHandle.standardError.write(Data("FAIL behavioral assertion: \(name) actual=\(actual)\n".utf8));exit(1)
  }
 }
 static func main() throws {
  let grid=SearchCase(grid:["ABCDE","FGHIJ","KLMNO","PQRST","UVWXY"],
    words:["ABC","CBA","AFKPU","EJOTY","AGMSY","EIMQU","ZZ","A","YSMGA"])
  let found=try solve(grid)
  check(found[0],[0,0],[0,2],"horizontal")
  check(found[1],[0,2],[0,0],"backward")
  check(found[2],[0,0],[4,0],"downward")
  check(found[3],[0,4],[4,4],"right edge")
  check(found[4],[0,0],[4,4],"diagonal down right")
  check(found[5],[0,4],[4,0],"diagonal down left")
  check(found[6],nil,nil,"not found")
  check(found[7],[0,0],[0,0],"single letter")
  check(found[8],[4,4],[0,0],"reverse diagonal")
  let ties=try solve(SearchCase(grid:["ABA","BAB","ABA"],words:["AB","BA"]))
  check(ties[0],[0,0],[0,1],"first row column")
  check(ties[1],[0,1],[0,2],"direction priority")
  do{_ = try solve(SearchCase(grid:["ABC","AB"],words:["AB"]));throw SearchError.invalidWord}catch SearchError.invalidGrid{}
  do{_ = try solve(SearchCase(grid:["AAA"],words:[""]));throw SearchError.invalidGrid}catch SearchError.invalidWord{}
  print("PASS: 11 directional assertions and 2 input validation cases")
 }
}
