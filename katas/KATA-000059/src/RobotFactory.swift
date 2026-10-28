import Foundation

// This actor owns all reservations. A reset releases the current reservation,
// but the robot's next assignment may not repeat its immediately prior name.
enum RobotNameError: Error, Equatable {
    case unknownRobot
    case exhausted
}

actor RobotFactory {
    // Application-wide registry; isolated instances are useful only for tests/tenants.
    static let shared = RobotFactory()
    private let letters: Int
    private let digits: Int
    private let capacity: Int
    private var nextID = 0
    private var existing: Set<Int> = []
    private var assignments: [Int: Int] = [:]
    private var previous: [Int: Int] = [:]
    private var occupied: Set<Int> = []
    private var deterministicState: UInt64?

    init(letters: Int = 26, digits: Int = 1000, seed: UInt64? = nil) {
        precondition((1...26).contains(letters) && (1...1000).contains(digits))
        self.letters = letters
        self.digits = digits
        self.capacity = letters * letters * digits
        self.deterministicState = seed
    }

    func create() -> Int {
        let id = nextID
        nextID += 1
        existing.insert(id)
        return id
    }

    func name(for id: Int) throws -> String {
        guard existing.contains(id) else { throw RobotNameError.unknownRobot }
        if let code = assignments[id] { return encode(code) }
        #if MUTANT_RESET_REUSES
        if let old = previous[id] {
            assignments[id] = old
            occupied.insert(old)
            return encode(old)
        }
        #endif
        let forbidden = previous[id]
        let unavailable = occupied.count + (forbidden.map { occupied.contains($0) ? 0 : 1 } ?? 0)
        guard unavailable < capacity else { throw RobotNameError.exhausted }

        // Production uses Swift's system RNG. The seeded path is exclusively
        // for deterministic test replay, not cryptographic or production use.
        var chosen: Int?
        for _ in 0..<min(64, capacity * 2) {
            let candidate = randomBelow(capacity)
            if available(candidate, forbidden: forbidden) {
                chosen = candidate
                break
            }
        }
        if chosen == nil {
            // Reservoir sampling across all available names: guaranteed to
            // terminate at high occupancy without a predictable scan choice.
            var seen = 0
            for candidate in 0..<capacity where available(candidate, forbidden: forbidden) {
                seen += 1
                if randomBelow(seen) == 0 { chosen = candidate }
            }
        }
        guard let code = chosen else { throw RobotNameError.exhausted }
        assignments[id] = code
        occupied.insert(code)
        previous.removeValue(forKey: id)
        return encode(code)
    }

    func reset(_ id: Int) throws {
        guard existing.contains(id) else { throw RobotNameError.unknownRobot }
        if let old = assignments.removeValue(forKey: id) {
            occupied.remove(old)
            previous[id] = old
        }
    }

    func retire(_ id: Int) throws {
        guard existing.remove(id) != nil else { throw RobotNameError.unknownRobot }
        if let old = assignments.removeValue(forKey: id) { occupied.remove(old) }
        previous.removeValue(forKey: id)
    }

    private func available(_ candidate: Int, forbidden: Int?) -> Bool {
        #if MUTANT_IGNORE_OCCUPIED
        return candidate != forbidden
        #else
        return !occupied.contains(candidate) && candidate != forbidden
        #endif
    }

    private func encode(_ code: Int) -> String {
        let pair = code / digits
        let number = code % digits
        let a = UnicodeScalar(65 + pair / letters)!
        let b = UnicodeScalar(65 + pair % letters)!
        return String(a) + String(b) + String(format: "%03d", number)
    }

    private func randomBelow(_ bound: Int) -> Int {
        if var state = deterministicState {
            state = state &+ 0x9E3779B97F4A7C15
            deterministicState = state
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return Int((z ^ (z >> 31)) % UInt64(bound))
        }
        return Int.random(in: 0..<bound)
    }
}
