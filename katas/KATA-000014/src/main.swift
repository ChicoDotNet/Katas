import Foundation

let args = Array(CommandLine.arguments.dropFirst())
guard args.count == 1, let wall = Wardrobe.parseWall(args[0]) else {
    FileHandle.standardError.write(Data("ERR:wall (expected one ASCII integer from 0 to 1000)\n".utf8))
    exit(2)
}
let plans = Wardrobe.plans(for: wall)
print("COUNT \(plans.count)")
for plan in plans {
    print("PLAN \(plan.counts.map(String.init).joined(separator: ",")) PRICE \(plan.price)")
}
if let cheapest = Wardrobe.cheapest(in: plans) {
    print("CHEAPEST \(cheapest.counts.map(String.init).joined(separator: ",")) PRICE \(cheapest.price)")
} else {
    print("CHEAPEST NONE")
}
