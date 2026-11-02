import Foundation

// The four element widths and prices are from the public-domain kata statement.
// This is an original dynamic-programming implementation, not a starter port.
struct WardrobePlan: Equatable {
    let counts: [Int]
    let price: Int
}

enum Wardrobe {
    static let widths = [50, 75, 100, 120]
    static let prices = [59, 62, 90, 111]
    static let maximumWall = 1000

    // Memoization caches the set of solutions for each (module index, remaining width).
    // It is deliberately unlike the independent Go count-vector brute-force oracle.
    static func plans(for wall: Int) -> [WardrobePlan] {
        precondition((0...maximumWall).contains(wall))
        struct State: Hashable { let index: Int; let remaining: Int }
        var memo: [State: [[Int]]] = [:]
        func suffixes(_ index: Int, _ remaining: Int) -> [[Int]] {
            if index == widths.count { return remaining == 0 ? [[]] : [] }
            let key = State(index: index, remaining: remaining)
            if let cached = memo[key] { return cached }
            let width = widths[index]
            var result: [[Int]] = []
            for count in 0...(remaining / width) {
                for tail in suffixes(index + 1, remaining - count * width) {
                    result.append([count] + tail)
                }
            }
            memo[key] = result
            return result
        }
        return suffixes(0, wall).map { counts in
            WardrobePlan(counts: counts,
                         price: zip(counts, prices).reduce(0) { $0 + $1.0 * $1.1 })
        }.sorted { $0.counts.lexicographicallyPrecedes($1.counts) }
    }

    static func cheapest(in plans: [WardrobePlan]) -> WardrobePlan? {
        plans.min { a, b in
            a.price == b.price
                ? a.counts.lexicographicallyPrecedes(b.counts)
                : a.price < b.price
        }
    }

    static func parseWall(_ argument: String) -> Int? {
        guard !argument.isEmpty, argument.utf8.allSatisfy({ (48...57).contains($0) }),
              let value = Int(argument), (0...maximumWall).contains(value) else { return nil }
        return value
    }
}
