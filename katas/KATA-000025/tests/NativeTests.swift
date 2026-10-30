import Foundation

@MainActor @main struct NativeTests {
    static var assertions = 0
    static func fail(_ message: String) -> Never {
        FileHandle.standardError.write(Data(("FAIL " + message + "\n").utf8))
        exit(1)
    }
    static func eq(_ input: String, _ expected: Int64) {
        assertions += 1
        do {
            let got = try StringCalculator.add(input)
            guard got == expected else { fail("expected sum \(expected) got \(got) for \(input.debugDescription)") }
        } catch { fail("expected sum \(expected) but threw \(error) for \(input.debugDescription)") }
    }
    static func error(_ input: String, _ code: String, _ message: String? = nil) {
        assertions += 1
        do { _ = try StringCalculator.add(input); fail("expected error \(code) for \(input.debugDescription)") }
        catch let e as CalculatorError {
            guard e.code == code && (message == nil || e.message == message) else {
                fail("expected error \(code) got \(e.code):\(e.message) for \(input.debugDescription)")
            }
        } catch { fail("unexpected error \(error)") }
    }
    static func main() {
        eq("", 0)
        eq("0", 0)
        eq("1", 1)
        eq("1,2", 3)
        eq("1\n2,3", 6)
        eq("1000,1001,2", 1002)
        eq("0002,0000", 2)
        eq("00000000000000000000000000000001", 1)
        eq("999999999999999999999999999,2", 2)
        eq("//;\n1;2", 3)
        eq("//[***]\n1***2***3", 6)
        eq("//[*][%]\n1*2%3", 6)
        eq("//[**][*]\n1**2*3", 6)
        eq("//[ab][a]\n1ab2a3", 6)
        eq("//[🦊][🐺]\n1🦊2🐺3", 6)
        eq("//[🔬🔬][+]\n1🔬🔬2+3", 6)
        error("-1,2,-3", "negative", "negatives not allowed: -1,-3")
        error("//[*][%]\n-2*3%-4", "negative", "negatives not allowed: -2,-4")
        error("1,", "empty")
        error("1,,2", "empty")
        error("1,\n2", "empty")
        error("1,abc", "number")
        error("//\n1", "header")
        error("//[x]\n", "empty")
        error("//[x][\n1x2", "header")
        error("//[x]z\n1x2", "header")
        error("//[2]\n1", "header")
        error("//;\n1,2", "number")
        error("//;", "header")
        error("-999999999999999999999999", "overflow")
        print("GREEN native \(assertions) assertions")
    }
}
