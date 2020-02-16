import AppKit


struct Donnees : Codable {
    var name: String
    var icon: String
    var children: [Children]
}

struct Children : Codable {

    var name: String
    var nameView: String
    var icon: String
}

extension Encodable {
    func encoded() throws -> Data {
        return try PropertyListEncoder().encode(self)
    }
}

extension Data {
    func decoded<T: Decodable>() throws -> T {
        return try PropertyListDecoder().decode(T.self, from: self)
    }
}

