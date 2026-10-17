// SPDX-License-Identifier: MIT
import Foundation
@main struct Tests {
    static func expect(_ value: Bool, _ message: String) {
        if !value {
            FileHandle.standardError.write(Data("FAIL behavioral assertion: \(message)\n".utf8))
            exit(1)
        }
    }
    static func main() throws {
        let a = try leaderboard([["Ada", nil, "Bea"]])
        expect(a == [Standing(driver:"Ada",points:25),Standing(driver:"Bea",points:15)], "self-driving must occupy second position")
        let b = try leaderboard([["Ada", "Bea"], ["Bea", "Ada"]])
        expect(b == [Standing(driver:"Ada",points:43),Standing(driver:"Bea",points:43)], "stable alphabetical tiebreaker")
        let c = try leaderboard([[nil, nil, "Cy"], ["Cy", "Ada"]])
        expect(c == [Standing(driver:"Cy",points:40),Standing(driver:"Ada",points:18)], "multiple autonomous cars and cumulative score")
        expect(try leaderboard([]).isEmpty, "empty season")
        expect(try leaderboard([[nil,nil]]).isEmpty, "only autonomous cars")
        do { _ = try leaderboard([["Ada","Ada"]]); expect(false,"duplicate participant rejected") } catch RaceError.invalidRace {}
        do { _ = try leaderboard([[]]); expect(false,"empty race rejected") } catch RaceError.invalidRace {}
        do { _ = try leaderboard([["  "]]); expect(false,"blank driver rejected") } catch RaceError.invalidRace {}
        print("PASS: 8 deterministic Swift scoring and validation cases")
    }
}
