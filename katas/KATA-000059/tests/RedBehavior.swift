import Foundation
@main struct RedBehavior {
    static func main() async {
        let factory = RobotFactory(seed: 4)
        let a = await factory.create()
        let b = await factory.create()
        let first = await factory.name(for: a)
        let second = await factory.name(for: b)
        if first == second {
            FileHandle.standardError.write(Data("FAIL behavioral assertion: duplicate robot names\n".utf8))
            exit(1)
        }
        print("UNEXPECTED RED PASS")
    }
}
