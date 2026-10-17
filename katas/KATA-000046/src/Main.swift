// SPDX-License-Identifier: MIT
import Foundation
@main struct Main {
 static func main() throws {
  let data = FileHandle.standardInput.readDataToEndOfFile()
  let cases = try JSONDecoder().decode([SearchCase].self, from: data)
  let output = try cases.map(solve)
  let encoder = JSONEncoder();encoder.outputFormatting = [.sortedKeys]
  FileHandle.standardOutput.write(try encoder.encode(output))
 }
}
