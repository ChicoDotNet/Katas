import Foundation
// Deliberately wrong but compilable RED implementation.
struct StringCalculator { static func add(_ input: String) throws -> Int64 { return 0 } }
enum CalculatorError: Error { case placeholder; var code: String { "placeholder" }; var message: String { "placeholder" } }
