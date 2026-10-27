// Native Swift behavioral and algebraic checks, original inputs.
var checks = 0
func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    checks += 1
    if !condition() { fatalError("NATIVE FAIL #\(checks): \(message)") }
}
let empty = OrderedSet()
let x = OrderedSet([4, -2, 4, 0, Int64.min, Int64.max, -2])
let y = OrderedSet([0, 2, 4, Int64.max])
check(empty.isEmpty, "empty")
check(x.values == [Int64.min, -2, 0, 4, Int64.max], "canonical sorted unique")
check(x.count == 5, "count")
check(x.contains(Int64.min) && x.contains(Int64.max), "extreme membership")
check(!x.contains(2), "missing membership")
check(x.union(y).values == [Int64.min, -2, 0, 2, 4, Int64.max], "union")
check(x.intersection(y).values == [0, 4, Int64.max], "intersection")
check(x.difference(y).values == [Int64.min, -2], "difference")
check(OrderedSet([0,4]).isSubset(of: x), "subset")
check(!y.isSubset(of: x), "not subset")
check(!x.isDisjoint(with: y), "not disjoint")
check(OrderedSet([1]).isDisjoint(with: x), "disjoint")
check(x == OrderedSet([Int64.max, 4, 0, -2, Int64.min]), "equality ignores input order")
var changed = x
changed.insert(2)
check(changed.contains(2) && !x.contains(2), "copy on write insert isolation")
changed.insert(2)
check(changed.count == x.count + 1, "idempotent insert")
changed.remove(Int64.min)
check(!changed.contains(Int64.min) && x.contains(Int64.min), "copy on write removal isolation")
changed.remove(Int64.min)
check(changed.count == x.count, "idempotent remove")
var state: UInt64 = 0x9e3779b97f4a7c15
func next() -> UInt64 { state = state &* 6364136223846793005 &+ 1442695040888963407; return state }
for caseNo in 0..<2400 {
    var a: [Int64] = [], b: [Int64] = []
    for _ in 0..<(Int(next() % 27)) { a.append(Int64(next() % 73) - 36) }
    for _ in 0..<(Int(next() % 27)) { b.append(Int64(next() % 73) - 36) }
    let s = OrderedSet(a), t = OrderedSet(b)
    let u = s.union(t), intersection = s.intersection(t), difference = s.difference(t)
    check(u == t.union(s), "union commutative \(caseNo)")
    check(intersection == t.intersection(s), "intersection commutative \(caseNo)")
    check(s.union(s) == s, "union idempotent \(caseNo)")
    check(s.intersection(s) == s, "intersection idempotent \(caseNo)")
    check(s.difference(s).isEmpty, "difference self \(caseNo)")
    check(s.isSubset(of: u), "subset of union \(caseNo)")
    check(intersection.isSubset(of: s), "intersection subset \(caseNo)")
    check(difference.isDisjoint(with: t), "difference disjoint \(caseNo)")
    check(difference.union(intersection) == s, "partition identity \(caseNo)")
    check(s.isDisjoint(with: t) == intersection.isEmpty, "disjoint equivalence \(caseNo)")
    check(s.values == s.values.sorted(), "sorted invariant \(caseNo)")
    check(s.values.count == s.count, "count invariant \(caseNo)")
}
print("NATIVE GREEN PASS \(checks) assertions")
