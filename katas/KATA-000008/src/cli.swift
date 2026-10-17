// SPDX-License-Identifier: MIT
import Foundation
@main struct CLI {
    static func main() throws {
        let data = FileHandle.standardInput.readDataToEndOfFile()
        let scenarios = try JSONDecoder().decode([Scenario].self, from: data)
        let output: [[Standing]] = try scenarios.map { try leaderboard($0.races) }
        FileHandle.standardOutput.write(try JSONEncoder().encode(output))
    }
}
