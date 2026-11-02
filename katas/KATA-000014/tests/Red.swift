struct WardrobePlan: Equatable { let counts: [Int]; let price: Int }
enum Wardrobe {
    static let widths = [50, 75, 100, 120]
    static let prices = [59, 62, 90, 111]
    static func plans(for wall: Int) -> [WardrobePlan] { [] }
    static func cheapest(in plans: [WardrobePlan]) -> WardrobePlan? { nil }
    static func parseWall(_ s: String) -> Int? { Int(s) }
}
