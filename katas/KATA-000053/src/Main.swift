// JSONL interface for independently generated Go oracle scenarios.
import Foundation

struct Request: Codable {
    let action: String
    let tree: Tree
    let from: String
    let to: String?
}
struct Response: Codable {
    let tree: Tree?
    let path: [String]?
}
@main
struct POVCommand {
    static func main() {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        while let line = readLine() {
            guard let data = line.data(using: .utf8),
                  let request = try? decoder.decode(Request.self, from: data) else {
                FileHandle.standardError.write(Data("Invalid request JSON\n".utf8))
                exit(2)
            }
            let response: Response
            switch request.action {
            case "reroot":
                response = Response(tree: request.tree.fromPov(request.from), path: nil)
            case "path":
                guard let destination = request.to else { exit(2) }
                response = Response(tree: nil, path: request.tree.path(from: request.from, to: destination))
            default: exit(2)
            }
            guard let encoded = try? encoder.encode(response),
                  let output = String(data: encoded, encoding: .utf8) else { exit(2) }
            FileHandle.standardOutput.write(Data((output + "\n").utf8))
        }
    }
}
