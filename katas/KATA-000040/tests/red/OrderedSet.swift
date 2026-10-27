// Intentionally compilable but behaviorally incorrect RED stub.
struct OrderedSet: Equatable {
    private var elements: [Int64] = []
    init(_ values: [Int64] = []) {}
    var values: [Int64] { elements }
    var count: Int { 0 }
    var isEmpty: Bool { true }
    func contains(_ value: Int64) -> Bool { false }
    mutating func insert(_ value: Int64) {}
    mutating func remove(_ value: Int64) {}
    func union(_ other: OrderedSet) -> OrderedSet { OrderedSet() }
    func intersection(_ other: OrderedSet) -> OrderedSet { OrderedSet() }
    func difference(_ other: OrderedSet) -> OrderedSet { OrderedSet() }
    func isSubset(of other: OrderedSet) -> Bool { true }
    func isDisjoint(with other: OrderedSet) -> Bool { true }
    static func == (lhs: OrderedSet, rhs: OrderedSet) -> Bool { true }
}
