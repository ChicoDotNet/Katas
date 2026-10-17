// SPDX-License-Identifier: MIT
import Foundation

struct Standing: Codable, Equatable {
    let driver: String
    let points: Int
}
struct Scenario: Codable {
    let races: [[String?]]
}
enum RaceError: Error {
    case invalidRace
}
// Self-driving nil entry occupies its position but cannot accrue driver points.
// This is an ORIGINAL, locally defined scoring policy, not a copy of upstream code.
func leaderboard(_ races: [[String?]]) throws -> [Standing] {
#if KATA_RED
    return [] // Wrong but compilable behavioral RED.
#else
    let points = [25,18,15,12,10,8,6,4,2,1]
    var totals: [String:Int] = [:]
    for positions in races {
        guard !positions.isEmpty && positions.count <= points.count else { throw RaceError.invalidRace }
        var seen = Set<String>()
        for (index, participant) in positions.enumerated() {
            guard let name = participant else { continue }
            guard !name.isEmpty && !name.contains(where: { $0.isWhitespace }) && seen.insert(name).inserted else {
                throw RaceError.invalidRace
            }
            totals[name, default: 0] += points[index]
        }
    }
    return totals.map { Standing(driver: $0.key, points: $0.value) }
        .sorted { left, right in left.points == right.points ? left.driver < right.driver : left.points > right.points }
#endif
}
