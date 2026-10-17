// SPDX-License-Identifier: MIT
import Foundation
struct SearchCase: Codable { let grid: [String]; let words: [String] }
struct Match: Codable, Equatable { let word: String; let start: [Int]?; let end: [Int]? }
enum SearchError: Error { case invalidGrid; case invalidWord }
func solve(_ input: SearchCase) throws -> [Match] {
    let grid = input.grid.map(Array.init)
    guard let width = grid.first?.count, width > 0, !grid.isEmpty,
          grid.count <= 30, width <= 30,
          input.grid.allSatisfy({ $0.count == width && !$0.utf8.isEmpty && $0.utf8.allSatisfy { 65...90 ~= $0 } })
    else { throw SearchError.invalidGrid }
    guard input.words.allSatisfy({ !$0.isEmpty && $0.utf8.allSatisfy { 65...90 ~= $0 } }) else {
        throw SearchError.invalidWord
    }
    let delta = [(-1,0),(-1,1),(0,1),(1,1),(1,0),(1,-1),(0,-1),(-1,-1)]
    let height = grid.count
    return input.words.map { word in
#if KATA_RED
        return Match(word: word, start: nil, end: nil)
#else
        let symbols = Array(word)
        for r in 0..<height {
            for c in 0..<width where grid[r][c] == symbols[0] {
                for (dr,dc) in delta {
                    let lastR = r + dr * (symbols.count - 1)
                    let lastC = c + dc * (symbols.count - 1)
                    if lastR < 0 || lastR >= height || lastC < 0 || lastC >= width { continue }
                    if symbols.indices.allSatisfy({ grid[r + dr * $0][c + dc * $0] == symbols[$0] }) {
                        return Match(word: word, start: [r,c], end: [lastR,lastC])
                    }
                }
            }
        }
        return Match(word: word, start: nil, end: nil)
#endif
    }
}
