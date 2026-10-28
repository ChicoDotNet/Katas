import Foundation

func ensure(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else {
        FileHandle.standardError.write(Data("FAIL behavioral assertion: \(message)\n".utf8))
        exit(1)
    }
}

@main struct NativeTests {
    static func main() async throws {
        var assertions = 0
        let factory = RobotFactory(seed: 19)
        var ids: [Int] = []
        var names = Set<String>()
        for _ in 0..<1200 {
            let id = await factory.create()
            ids.append(id)
            let name = try await factory.name(for: id)
            ensure(name.range(of: "^[A-Z]{2}[0-9]{3}$", options: .regularExpression) != nil, "name shape")
            ensure(names.insert(name).inserted, "active robots must have distinct names")
            let repeated = try await factory.name(for: id)
            ensure(repeated == name, "name idempotence")
            assertions += 3
        }
        for id in ids.prefix(200) {
            let before = try await factory.name(for: id)
            try await factory.reset(id)
            let after = try await factory.name(for: id)
            ensure(before != after, "reset must change robot's name")
            assertions += 1
        }
        var live = Set<String>()
        for id in ids {
            let n = try await factory.name(for: id)
            ensure(live.insert(n).inserted, "all live names unique after reset")
            assertions += 1
        }
        // Exercise the actual production system RNG path (seed=nil).
        let production = RobotFactory()
        var productionNames = Set<String>()
        for _ in 0..<250 {
            let id = await production.create()
            let n = try await production.name(for: id)
            ensure(productionNames.insert(n).inserted, "production RNG names unique")
            assertions += 1
        }
        let small = RobotFactory(letters: 2, digits: 2, seed: 8)
        var smallIDs: [Int] = []
        var smallNames = Set<String>()
        for _ in 0..<8 {
            let id = await small.create()
            smallIDs.append(id)
            let n = try await small.name(for: id)
            ensure(smallNames.insert(n).inserted, "bounded capacity uniqueness")
            assertions += 1
        }
        let overflow = await small.create()
        do {
            _ = try await small.name(for: overflow)
            ensure(false, "capacity exhaustion must throw")
        } catch RobotNameError.exhausted { assertions += 1 }
        try await small.retire(smallIDs[0])
        let recovered = try await small.name(for: overflow)
        let repeatedRecovery = try await small.name(for: overflow)
        ensure(recovered == repeatedRecovery, "recovered slot is stable")
        ensure(smallNames.contains(recovered), "freed slot must be reused")
        assertions += 2
        do {
            _ = try await small.name(for: -1)
            ensure(false, "unknown robot must throw")
        } catch RobotNameError.unknownRobot { assertions += 1 }

        // A real concurrent actor stress test, not a sequential oracle simulation.
        let concurrent = RobotFactory(seed: 0xD00D)
        let batch = try await withThrowingTaskGroup(of: String.self, returning: [String].self) { group in
            for _ in 0..<600 {
                group.addTask {
                    let id = await concurrent.create()
                    return try await concurrent.name(for: id)
                }
            }
            var collected: [String] = []
            for try await n in group { collected.append(n) }
            return collected
        }
        ensure(Set(batch).count == batch.count, "concurrent uniqueness")
        assertions += 1
        print("GREEN Swift native PASS: \(assertions) assertions, 1200 seeded + 250 system-RNG robots, 200 resets, 600 concurrent, 8-slot exhaustion")
    }
}
