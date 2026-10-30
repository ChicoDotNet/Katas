import Foundation

enum CalculatorError: Error, Equatable {
    case malformedHeader
    case emptyNumber
    case malformedNumber(String)
    case numberOverflow
    case negatives([Int64])

    var code: String {
        switch self {
        case .malformedHeader: return "header"
        case .emptyNumber: return "empty"
        case .malformedNumber: return "number"
        case .numberOverflow: return "overflow"
        case .negatives: return "negative"
        }
    }

    var message: String {
        switch self {
        case .malformedHeader: return "invalid delimiter header"
        case .emptyNumber: return "number expected"
        case .malformedNumber(let s): return "invalid number: \(s)"
        case .numberOverflow: return "integer overflow"
        case .negatives(let values):
            return "negatives not allowed: " + values.map(String.init).joined(separator: ",")
        }
    }
}

struct StringCalculator {
    static func add(_ input: String) throws -> Int64 {
        if input.isEmpty { return 0 }
        let (delimiters, body) = try splitHeader(input)
        let ordered = delimiters.map(Array.init).sorted { $0.count > $1.count }
        let chars = Array(body)
        var tokens: [String] = []
        var current: [Character] = []
        var index = 0
        while index < chars.count {
            if let delimiter = ordered.first(where: { candidate in
                index + candidate.count <= chars.count &&
                Array(chars[index..<(index + candidate.count)]) == candidate
            }) {
                guard !current.isEmpty else { throw CalculatorError.emptyNumber }
                tokens.append(String(current))
                current.removeAll(keepingCapacity: true)
                index += delimiter.count
            } else {
                current.append(chars[index])
                index += 1
            }
        }
        guard !current.isEmpty else { throw CalculatorError.emptyNumber }
        tokens.append(String(current))

        var negatives: [Int64] = []
        var total: Int64 = 0
        for token in tokens {
            let negative = token.first == "-"
            let digits = negative ? String(token.dropFirst()) : token
            guard !digits.isEmpty && digits.allSatisfy({ $0 >= "0" && $0 <= "9" }) else {
                throw CalculatorError.malformedNumber(token)
            }
            if negative {
                guard let value = Int64(token) else { throw CalculatorError.numberOverflow }
                if value < 0 { negatives.append(value) }
            } else {
                // Ignore arbitrarily long positive integers above 1000 without
                // attempting to represent them in a machine integer.
                let significant = String(digits.drop(while: { $0 == "0" }))
                if significant.count > 4 ||
                    (significant.count == 4 && significant > "1000") { continue }
                guard let value = Int64(significant.isEmpty ? "0" : significant) else { throw CalculatorError.numberOverflow }
                if value > 1000 { continue }
                let (sum, overflow) = total.addingReportingOverflow(value)
                if overflow { throw CalculatorError.numberOverflow }
                total = sum
            }
        }
        if !negatives.isEmpty { throw CalculatorError.negatives(negatives) }
        return total
    }

    private static func splitHeader(_ input: String) throws -> ([String], String) {
        guard input.hasPrefix("//") else { return ([",", "\n"], input) }
        guard let newline = input.firstIndex(of: "\n") else { throw CalculatorError.malformedHeader }
        let header = String(input[input.index(input.startIndex, offsetBy: 2)..<newline])
        let body = String(input[input.index(after: newline)...])
        guard !header.isEmpty else { throw CalculatorError.malformedHeader }
        var delimiters: [String] = []
        if header.first == "[" {
            let h = Array(header)
            var i = 0
            while i < h.count {
                guard h[i] == "[" else { throw CalculatorError.malformedHeader }
                i += 1
                let start = i
                while i < h.count && h[i] != "]" { i += 1 }
                guard i < h.count && i > start else { throw CalculatorError.malformedHeader }
                delimiters.append(String(h[start..<i]))
                i += 1
            }
        } else {
            guard header.count == 1 else { throw CalculatorError.malformedHeader }
            delimiters = [header]
        }
        guard !delimiters.isEmpty && delimiters.allSatisfy({ delim in
            !delim.contains("\n") && !delim.contains("\r") &&
            !delim.contains("[") && !delim.contains("]") &&
            !delim.contains("-") && !delim.contains(where: { $0 >= "0" && $0 <= "9" })
        }) else { throw CalculatorError.malformedHeader }
        return (delimiters, body)
    }
}
