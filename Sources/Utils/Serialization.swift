import Foundation

class Serializer {

  // Static method to serialize an Encodable object to a JSON string
  static func serialize<T: Encodable>(_ object: T) -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted  // For more readable JSON output

    do {
      let jsonData = try encoder.encode(object)
      return String(data: jsonData, encoding: .utf8)
    } catch {
      print("Failed to serialize object: \(error)")
      return nil
    }
  }

  // Static method to deserialize a JSON string to a Decodable object
  static func deserialize<T: Decodable>(_ jsonString: String, to type: T.Type) -> T? {
    let decoder = JSONDecoder()

    guard let jsonData = jsonString.data(using: .utf8) else {
      print("Failed to convert string to Data")
      return nil
    }

    do {
      let object = try decoder.decode(T.self, from: jsonData)
      return object
    } catch {
      print("Failed to deserialize JSON string: \(error)")
      return nil
    }
  }
}
