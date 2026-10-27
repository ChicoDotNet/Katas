// Original implementation for KATA-000040, MIT. No upstream starter or fixtures copied.
// Sorted array representation is deliberately different from the Go map/bitset oracles.
struct OrderedSet: Equatable {
    private var elements: [Int64]

    init(_ values: [Int64] = []) {
        let sorted = values.sorted()
        var unique: [Int64] = []
        unique.reserveCapacity(sorted.count)
        for value in sorted where unique.last != value {
            unique.append(value)
        }
        elements = unique
    }

    private init(sortedUnique: [Int64]) { elements = sortedUnique }
    var values: [Int64] { elements }
    var count: Int { elements.count }
    var isEmpty: Bool { elements.isEmpty }

    private func lowerBound(_ value: Int64) -> Int {
        var lo = 0
        var hi = elements.count
        while lo < hi {
            let mid = lo + (hi - lo) / 2
            if elements[mid] < value { lo = mid + 1 } else { hi = mid }
        }
        return lo
    }

    func contains(_ value: Int64) -> Bool {
        let i = lowerBound(value)
        return i < elements.count && elements[i] == value
    }

    mutating func insert(_ value: Int64) {
        let i = lowerBound(value)
        if i == elements.count || elements[i] != value { elements.insert(value, at: i) }
    }

    mutating func remove(_ value: Int64) {
        let i = lowerBound(value)
        if i < elements.count && elements[i] == value { elements.remove(at: i) }
    }

    func union(_ other: OrderedSet) -> OrderedSet {
        var result: [Int64] = []
        result.reserveCapacity(count + other.count)
        var i = 0, j = 0
        while i < count && j < other.count {
            let a = elements[i], b = other.elements[j]
            if a < b { result.append(a); i += 1 }
            else if b < a { result.append(b); j += 1 }
            else { result.append(a); i += 1; j += 1 }
        }
        if i < count { result.append(contentsOf: elements[i...]) }
        if j < other.count { result.append(contentsOf: other.elements[j...]) }
        return OrderedSet(sortedUnique: result)
    }

    func intersection(_ other: OrderedSet) -> OrderedSet {
        var result: [Int64] = []
        var i = 0, j = 0
        while i < count && j < other.count {
            let a = elements[i], b = other.elements[j]
            if a < b { i += 1 }
            else if b < a { j += 1 }
            else { result.append(a); i += 1; j += 1 }
        }
        return OrderedSet(sortedUnique: result)
    }

    func difference(_ other: OrderedSet) -> OrderedSet {
        var result: [Int64] = []
        var i = 0, j = 0
        while i < count {
            if j == other.count { result.append(contentsOf: elements[i...]); break }
            let a = elements[i], b = other.elements[j]
            if a < b { result.append(a); i += 1 }
            else if b < a { j += 1 }
            else { i += 1; j += 1 }
        }
        return OrderedSet(sortedUnique: result)
    }

    func isSubset(of other: OrderedSet) -> Bool {
        var i = 0, j = 0
        while i < count && j < other.count {
            if elements[i] == other.elements[j] { i += 1; j += 1 }
            else if elements[i] > other.elements[j] { j += 1 }
            else { return false }
        }
        return i == count
    }

    func isDisjoint(with other: OrderedSet) -> Bool { intersection(other).isEmpty }
    static func == (lhs: OrderedSet, rhs: OrderedSet) -> Bool { lhs.elements == rhs.elements }
}
