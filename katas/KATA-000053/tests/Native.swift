// Native behavioral, structural and metamorphic checks (not the Go oracle).
import Foundation

@MainActor
@main
struct NativeTests {
    static var checks = 0
    static func expect(_ condition: @autoclosure () -> Bool, _ why: String) {
        checks += 1
        guard condition() else {
            FileHandle.standardError.write(Data("FAIL behavioral assertion: \(why)\n".utf8))
            exit(1)
        }
    }
    static func edges(_ tree: Tree) -> Set<String> {
        var result = Set<String>()
        func visit(_ node: Tree) {
            for child in node.children {
                let pair = [node.label, child.label].sorted()
                result.insert(pair[0] + "|" + pair[1])
                visit(child)
            }
        }
        visit(tree)
        return result
    }
    static func labels(_ tree: Tree) -> [String] {
        [tree.label] + tree.children.flatMap { labels($0) }
    }
    static func inserted(_ tree: Tree, parent: String, child: String) -> Tree {
        if tree.label == parent { return Tree(tree.label, tree.children + [Tree(child)]) }
        return Tree(tree.label, tree.children.map { inserted($0, parent: parent, child: child) })
    }
    static func main() {
        let root = Tree("grand", [
            Tree("parent", [Tree("x", [Tree("kid0"), Tree("kid1")]), Tree("sibling")]),
            Tree("uncle", [Tree("cousin")])
        ])
        let snapshot = root
        let transformed = root.fromPov("x")
        expect(transformed?.label == "x", "requested node becomes root")
        expect(transformed.map(edges) == edges(root), "edge set preserved across reroot")
        expect(transformed?.children.contains(where: { $0.label == "kid0" }) == true, "original children survive")
        expect(root == snapshot, "original tree remains unchanged")
        expect(root.path(from: "x", to: "cousin") == ["x", "parent", "grand", "uncle", "cousin"], "cousin path")
        expect(root.path(from: "cousin", to: "x") == ["cousin", "uncle", "grand", "parent", "x"], "reverse path")
        expect(root.fromPov("missing") == nil, "missing reroot")
        expect(root.path(from: "missing", to: "x") == nil, "missing source")
        expect(root.path(from: "x", to: "missing") == nil, "missing destination")
        expect(Tree("only").fromPov("only") == Tree("only"), "singleton")
        expect(Tree("dup", [Tree("dup")]).fromPov("dup") == nil, "ambiguous duplicate labels rejected")
        var seed: UInt64 = 0x6c8e9cf570932bd5
        func next() -> UInt64 { seed = seed &* 6364136223846793005 &+ 1442695040888963407; return seed }
        for size in 2...54 {
            var tree = Tree("n0")
            for i in 1..<size {
                let parent = "n\(Int(next() % UInt64(i)))"
                tree = inserted(tree, parent: parent, child: "n\(i)")
            }
            let before = edges(tree)
            let all = labels(tree)
            for i in 0..<size {
                let newRoot = "n\(i)"
                guard let reoriented = tree.fromPov(newRoot) else {
                    expect(false, "all generated nodes exist")
                    return
                }
                expect(reoriented.label == newRoot, "generated root label")
                expect(edges(reoriented) == before, "generated undirected edges unchanged")
                expect(Set(labels(reoriented)) == Set(all), "generated labels unchanged")
                let back = reoriented.fromPov("n0")
                expect(back?.label == "n0" && back.map(edges) == before, "reroot reversibility")
                let other = "n\(Int(next() % UInt64(size)))"
                if let path = tree.path(from: newRoot, to: other) {
                    expect(path.first == newRoot && path.last == other, "path endpoints")
                    expect(Set(path).count == path.count, "path is simple")
                    for j in 1..<path.count {
                        let pair = [path[j-1], path[j]].sorted()
                        expect(before.contains(pair[0] + "|" + pair[1]), "path uses existing edge")
                    }
                } else { expect(false, "path between existing nodes") }
            }
        }
        print("Swift native GREEN: \(checks) behavioral/structural/metamorphic assertions")
    }
}
