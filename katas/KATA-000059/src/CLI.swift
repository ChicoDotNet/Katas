import Foundation

@main struct RobotCLI {
    static func main() async {
        while let line = readLine() {
            do {
                guard let input = try JSONSerialization.jsonObject(with: Data(line.utf8)) as? [String: Any],
                      let operations = input["ops"] as? [[String: Any]] else {
                    print("{\"error\":\"invalid_input\"}")
                    continue
                }
                let letters = input["letters"] as? Int ?? 26
                let digits = input["digits"] as? Int ?? 1000
                guard (1...26).contains(letters), (1...1000).contains(digits) else {
                    print("{\"error\":\"invalid_configuration\"}")
                    continue
                }
                let seed = (input["seed"] as? NSNumber)?.uint64Value
                let factory = RobotFactory(letters: letters, digits: digits, seed: seed)
                var labels: [String: Int] = [:]
                var results: [[String: Any]] = []
                for operation in operations {
                    let action = operation["op"] as? String ?? ""
                    let label = operation["id"] as? String ?? ""
                    guard !label.isEmpty else {
                        results.append(["error": "invalid_id"])
                        continue
                    }
                    if action == "new" {
                        if labels[label] != nil {
                            results.append(["error": "duplicate_id"])
                        } else {
                            labels[label] = await factory.create()
                            results.append(["ok": true])
                        }
                        continue
                    }
                    guard let id = labels[label] else {
                        results.append(["error": "unknown_robot"])
                        continue
                    }
                    do {
                        switch action {
                        case "name":
                            let n = try await factory.name(for: id)
                            results.append(["name": n])
                        case "reset":
                            try await factory.reset(id)
                            results.append(["ok": true])
                        case "retire":
                            try await factory.retire(id)
                            labels.removeValue(forKey: label)
                            results.append(["ok": true])
                        default:
                            results.append(["error": "invalid_operation"])
                        }
                    } catch RobotNameError.exhausted {
                        results.append(["error": "exhausted"])
                    } catch {
                        results.append(["error": "unknown_robot"])
                    }
                }
                let output = try JSONSerialization.data(withJSONObject: ["results": results], options: [.sortedKeys])
                print(String(decoding: output, as: UTF8.self))
            } catch {
                print("{\"error\":\"invalid_input\"}")
            }
        }
    }
}
