import Foundation

@main struct NativeTests {
    static func main() {
        var assertions = 0
        func check(_ ok: Bool, _ message: String) {
            assertions += 1
            if !ok { FileHandle.standardError.write(Data("FAIL native: \(message)\n".utf8)); exit(1) }
        }
        let plans = Wardrobe.plans(for: 250)
        check(plans.count == 5, "250cm has exactly five unordered combinations")
        check(plans.map(\.counts) == [[0,2,1,0], [1,0,2,0], [2,2,0,0], [3,0,1,0], [5,0,0,0]], "lexicographic combinations")
        check(plans.map(\.price) == [214,239,242,267,295], "250cm prices")
        check(Wardrobe.cheapest(in: plans)?.counts == [0,2,1,0], "cheapest uses 75+75+100")
        check(Wardrobe.cheapest(in: plans)?.price == 214, "cheapest price")
        check(Wardrobe.plans(for: 0).map(\.counts) == [[0,0,0,0]], "empty wall has one empty combination")
        check(Wardrobe.cheapest(in: Wardrobe.plans(for: 0))?.price == 0, "empty wall costs zero")
        check(Wardrobe.plans(for: 1).isEmpty, "unfillable wall")
        check(Wardrobe.cheapest(in: Wardrobe.plans(for: 1)) == nil, "no cheapest if no solution")
        check(Wardrobe.plans(for: 120).map(\.counts) == [[0,0,0,1]], "120-only plan")
        check(Wardrobe.plans(for: 50).map(\.counts) == [[1,0,0,0]], "50-only plan")
        check(Wardrobe.plans(for: 75).map(\.counts) == [[0,1,0,0]], "75-only plan")
        check(Wardrobe.plans(for: 100).map(\.counts) == [[0,0,1,0], [2,0,0,0]], "100cm tie in width")
        check(Wardrobe.parseWall("000250") == 250, "leading zeros accepted")
        check(Wardrobe.parseWall("0") == 0, "zero accepted")
        check(Wardrobe.parseWall("1000") == 1000, "upper bound accepted")
        for s in ["", "-1", "+1", "1.0", " 50", "50 ", "50\n", "1_00", "1001", "999999999999999999999999999", "１２", "١٠٠", "NaN"] {
            check(Wardrobe.parseWall(s) == nil, "invalid wall rejected: \(s.debugDescription)")
        }
        for wall in 0...1000 {
            let rows = Wardrobe.plans(for: wall)
            check(rows.allSatisfy { $0.counts.count == 4 && $0.counts.allSatisfy { $0 >= 0 } }, "nonnegative count vectors \(wall)")
            check(rows.allSatisfy { zip($0.counts, Wardrobe.widths).reduce(0) { $0 + $1.0 * $1.1 } == wall }, "exact widths \(wall)")
            check(rows.allSatisfy { zip($0.counts, Wardrobe.prices).reduce(0) { $0 + $1.0 * $1.1 } == $0.price }, "exact prices \(wall)")
            check(Set(rows.map { $0.counts.map(String.init).joined(separator: ",") }).count == rows.count, "no duplicates \(wall)")
            check(rows == rows.sorted { $0.counts.lexicographicallyPrecedes($1.counts) }, "sorted \(wall)")
        }
        print("GREEN native \(assertions) assertions")
    }
}
