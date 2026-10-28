// Deliberately compilable behavioral RED: both robots receive the same name.
actor RobotFactory {
    init(letters: Int = 26, digits: Int = 1000, seed: UInt64? = nil) {}
    func create() -> Int { 1 }
    func name(for id: Int) -> String { "AA000" }
}
