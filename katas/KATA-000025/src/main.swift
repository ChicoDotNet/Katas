import Foundation

while let line = readLine() {
    guard let data = Data(base64Encoded: line), let input = String(data: data, encoding: .utf8) else {
        print("ERR|encoding")
        continue
    }
    do {
        print("OK|\(try StringCalculator.add(input))")
    } catch let e as CalculatorError {
        let message = Data(e.message.utf8).base64EncodedString()
        print("ERR|\(e.code)|\(message)")
    } catch {
        print("ERR|unexpected")
    }
}
