// KATA-000053 — original value-semantic tree rerooting in Swift 6.
// Copyright (c) 2026 ChicoDotNet. MIT.
import Foundation

struct Tree: Codable, Equatable {
    let label: String
    let children: [Tree]

    init(_ label: String, _ children: [Tree] = []) {
        self.label = label
        self.children = children
    }

    // In-place DFS route avoids repeatedly copying a path at every depth.
    private func indices(to target: String, route: inout [Int]) -> Bool {
        if label == target { return true }
        for (index, child) in children.enumerated() {
            route.append(index)
            if child.indices(to: target, route: &route) { return true }
            route.removeLast()
        }
        return false
    }

    private func descendantPath(to target: String, route: inout [String]) -> Bool {
        route.append(label)
        if label == target { return true }
        for child in children {
            if child.descendantPath(to: target, route: &route) { return true }
        }
        route.removeLast()
        return false
    }

    private func hasUniqueLabels() -> Bool {
        var labels = Set<String>()
        func visit(_ tree: Tree) -> Bool {
            guard labels.insert(tree.label).inserted else { return false }
            return tree.children.allSatisfy(visit)
        }
        return visit(self)
    }

    /// Reorient all edges away from target, preserving the original tree.
    /// Missing targets or duplicate labels return nil.
    func fromPov(_ target: String) -> Tree? {
        var route: [Int] = []
        guard hasUniqueLabels(), indices(to: target, route: &route) else { return nil }
        #if KATA_RED
        return self // Compiles but fails the behavioral reroot contract.
        #else
        var cursor = self
        var contexts: [(label: String, siblings: [Tree])] = []
        for index in route {
            let siblings = cursor.children.enumerated().compactMap { (i, child) -> Tree? in
                i == index ? nil : child
            }
            contexts.append((cursor.label, siblings))
            cursor = cursor.children[index]
        }
        var ancestor: Tree? = nil
        for context in contexts {
            var descendants = context.siblings
            if let prior = ancestor { descendants.append(prior) }
            ancestor = Tree(context.label, descendants)
        }
        var children = cursor.children
        if let prior = ancestor { children.append(prior) }
        #if KATA_MUTANT_DROP_SIBLINGS
        if ancestor != nil { children = [ancestor!] }
        #endif
        return Tree(cursor.label, children)
        #endif
    }

    /// Unique simple path from from to to inclusive, or nil if either is absent.
    func path(from: String, to: String) -> [String]? {
        guard let reoriented = fromPov(from) else { return nil }
        var path: [String] = []
        let result: [String]? = reoriented.descendantPath(to: to, route: &path) ? path : nil
        #if KATA_MUTANT_REVERSE_PATH
        return result.map { Array($0.reversed()) }
        #else
        return result
        #endif
    }
}
