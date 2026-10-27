import Foundation
struct Request: Decodable { let a: [Int64]; let b: [Int64]; let insert: Int64; let remove: Int64 }
struct Response: Encodable {
    let a: [Int64]; let b: [Int64]; let union: [Int64]; let intersection: [Int64]
    let difference: [Int64]; let subset: Bool; let disjoint: Bool; let equal: Bool
    let inserted: [Int64]; let removed: [Int64]
}
let decoder = JSONDecoder()
let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys]
while let line = readLine() {
    do {
        guard let input = line.data(using: .utf8) else { throw NSError(domain: "utf8", code: 1) }
        let request = try decoder.decode(Request.self, from: input)
        let a = OrderedSet(request.a), b = OrderedSet(request.b)
        var inserted = a, removed = a
        inserted.insert(request.insert)
        removed.remove(request.remove)
        let response = Response(a: a.values, b: b.values, union: a.union(b).values,
            intersection: a.intersection(b).values, difference: a.difference(b).values,
            subset: a.isSubset(of: b), disjoint: a.isDisjoint(with: b), equal: a == b,
            inserted: inserted.values, removed: removed.values)
        let data = try encoder.encode(response)
        guard let encoded = String(data: data, encoding: .utf8) else { throw NSError(domain: "utf8", code: 2) }
        print(encoded)
    } catch {
        fputs("invalid request: \(error)\n", stderr)
        exit(2)
    }
}
