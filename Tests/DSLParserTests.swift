import XCTest

@testable import typemeld

final class DSLParserTests: XCTestCase {

  var parser: DSLParser!

  override func setUp() {
    super.setUp()
    parser = DSLParser()
  }

  override func tearDown() {
    parser = nil
    super.tearDown()
  }

  // Test for Struct Node
  func testParseStructNode() {
    let dsl = """
      struct Person {
          id: Int32
          name: String
      }
      """
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .structNode(structNode) = ast[0] {
      XCTAssertEqual(structNode.name, "Person")
      XCTAssertEqual(structNode.fields.count, 2)
      XCTAssertEqual(structNode.fields[0].name, "id")
      XCTAssertEqual(structNode.fields[0].type.name, "Int32")
      XCTAssertEqual(structNode.fields[0].optional, false)
      XCTAssertEqual(structNode.fields[1].name, "name")
      XCTAssertEqual(structNode.fields[1].type.name, "String")
      XCTAssertEqual(structNode.fields[1].optional, false)
    } else {
      XCTFail("Expected structNode, got \(ast[0])")
    }
  }

  // Test for Struct with Inheritance
  func testParseStructWithInheritance() {
    let dsl = """
      struct Engineer extends Person {
          specialty: String
          isWorking: Boolean
      }
      """
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .structNode(structNode) = ast[0] {
      XCTAssertEqual(structNode.name, "Engineer")
      XCTAssertEqual(structNode.extends, "Person")
      XCTAssertEqual(structNode.fields.count, 2)
      XCTAssertEqual(structNode.fields[0].name, "specialty")
      XCTAssertEqual(structNode.fields[0].type.name, "String")
      XCTAssertEqual(structNode.fields[0].optional, false)
      XCTAssertEqual(structNode.fields[1].name, "isWorking")
      XCTAssertEqual(structNode.fields[1].type.name, "Boolean")
      XCTAssertEqual(structNode.fields[1].optional, false)
    } else {
      XCTFail("Expected structNode, got \(ast[0])")
    }
  }

  // Test for Interface Node
  func testParseInterfaceNode() {
    let dsl = """
      interface Worker {
          work(hours: Int32): Void
          report(): String
      }
      """
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .interfaceNode(interfaceNode) = ast[0] {
      XCTAssertEqual(interfaceNode.name, "Worker")
      XCTAssertEqual(interfaceNode.methods.count, 2)
      XCTAssertEqual(interfaceNode.methods[0].name, "work")
      XCTAssertEqual(interfaceNode.methods[0].parameters.count, 1)
      XCTAssertEqual(interfaceNode.methods[0].parameters[0].name, "hours")
      XCTAssertEqual(interfaceNode.methods[0].parameters[0].type.name, "Int32")
      XCTAssertEqual(interfaceNode.methods[0].returnType.name, "Void")
      XCTAssertEqual(interfaceNode.methods[1].name, "report")
      XCTAssertEqual(interfaceNode.methods[1].parameters.count, 0)
      XCTAssertEqual(interfaceNode.methods[1].returnType.name, "String")
    } else {
      XCTFail("Expected interfaceNode, got \(ast[0])")
    }
  }

  // Test for Function Signature Node
  func testParseFunctionSignatureNode() {
    let dsl = "function hire(person: Person, position: String): Boolean"
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .functionSignatureNode(functionNode) = ast[0] {
      XCTAssertEqual(functionNode.name, "hire")
      XCTAssertEqual(functionNode.parameters.count, 2)
      XCTAssertEqual(functionNode.parameters[0].name, "person")
      XCTAssertEqual(functionNode.parameters[0].type.name, "Person")
      XCTAssertEqual(functionNode.parameters[1].name, "position")
      XCTAssertEqual(functionNode.parameters[1].type.name, "String")
      XCTAssertEqual(functionNode.returnType.name, "Boolean")
    } else {
      XCTFail("Expected functionSignatureNode, got \(ast[0])")
    }
  }

  // Test for Array Type Parsing
  func testParseArrayType() {
    let dsl = """
      struct Team {
          members: String[]
          projectIds: Int32[]
      }
      """
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .structNode(structNode) = ast[0] {
      XCTAssertEqual(structNode.name, "Team")
      XCTAssertEqual(structNode.fields.count, 2)

      // Check for array type fields
      XCTAssertEqual(structNode.fields[0].name, "members")
      XCTAssertEqual(structNode.fields[0].type.name, "Array")
      XCTAssertEqual(structNode.fields[0].type.genericType?.name, "String")  // Array type with String as generic type

      XCTAssertEqual(structNode.fields[1].name, "projectIds")
      XCTAssertEqual(structNode.fields[1].type.name, "Array")
      XCTAssertEqual(structNode.fields[1].type.genericType?.name, "Int32")  // Array type with Int32 as generic type
    } else {
      XCTFail("Expected structNode, got \(ast[0])")
    }
  }

  // Test for Generic Types
  func testParseGenericTypes() {
    let dsl = "function fetchData<T>(url: String): ApiResponse<T>"
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .functionSignatureNode(functionNode) = ast[0] {
      XCTAssertEqual(functionNode.name, "fetchData")
      XCTAssertEqual(functionNode.parameters.count, 1)
      XCTAssertEqual(functionNode.parameters[0].name, "url")
      XCTAssertEqual(functionNode.parameters[0].type.name, "String")
      XCTAssertEqual(functionNode.returnType.name, "ApiResponse")
      XCTAssertNotNil(functionNode.returnType.genericType)
      XCTAssertEqual(functionNode.returnType.genericType?.name, "T")
    } else {
      XCTFail("Expected functionSignatureNode, got \(ast[0])")
    }
  }

  // Test for Record Type Parsing
  // Test for Record Type Parsing
  func testParseRecordType() {
    let dsl = """
      struct LogEntry {
          message: String
          timestamp: { seconds: Int32, nanos: Int32 }
      }
      """
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .structNode(structNode) = ast[0] {
      XCTAssertEqual(structNode.name, "LogEntry")
      XCTAssertEqual(structNode.fields.count, 2)

      XCTAssertEqual(structNode.fields[0].name, "message")
      XCTAssertEqual(structNode.fields[0].type.name, "String")
      XCTAssertEqual(structNode.fields[0].optional, false)

      XCTAssertEqual(structNode.fields[1].name, "timestamp")
      XCTAssertEqual(structNode.fields[1].type.name, "Record")

      XCTAssertEqual(structNode.fields[1].type.fields?.count, 2)  // Ensure two fields are parsed

      if let timestampFields = structNode.fields[1].type.fields {
        XCTAssertEqual(timestampFields[0].name, "seconds")
        XCTAssertEqual(timestampFields[0].type.name, "Int32")
        XCTAssertEqual(timestampFields[1].name, "nanos")
        XCTAssertEqual(timestampFields[1].type.name, "Int32")
      } else {
        XCTFail("Expected fields for timestamp, got nil")
      }

    } else {
      XCTFail("Expected structNode, got \(ast[0])")
    }
  }

  // Test for Type Definition
  func testParseTypeDefinition() {
    let dsl = "type KeyValue = { key: String, value: Int32 }"
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .typeNode(typeNode) = ast[0] {
      XCTAssertEqual(typeNode.name, "KeyValue")
      XCTAssertEqual(typeNode.fields?.count, 2)
      XCTAssertEqual(typeNode.fields?[0].name, "key")
      XCTAssertEqual(typeNode.fields?[0].type.name, "String")
      XCTAssertEqual(typeNode.fields?[1].name, "value")
      XCTAssertEqual(typeNode.fields?[1].type.name, "Int32")
    } else {
      XCTFail("Expected typeNode, got \(ast[0])")
    }
  }

  // Test for Optional Fields in Struct
  func testParseStructWithOptionalFields() {
    let dsl = """
      struct User {
          id: Int32
          name: String?
          age: Int32?
      }
      """
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .structNode(structNode) = ast[0] {
      XCTAssertEqual(structNode.name, "User")
      XCTAssertEqual(structNode.fields.count, 3)
      XCTAssertEqual(structNode.fields[0].name, "id")
      XCTAssertEqual(structNode.fields[0].type.name, "Int32")
      XCTAssertEqual(structNode.fields[0].optional, false)
      XCTAssertEqual(structNode.fields[1].name, "name")
      XCTAssertEqual(structNode.fields[1].type.name, "String")
      XCTAssertEqual(structNode.fields[1].optional, true)
      XCTAssertEqual(structNode.fields[2].name, "age")
      XCTAssertEqual(structNode.fields[2].type.name, "Int32")
      XCTAssertEqual(structNode.fields[2].optional, true)
    } else {
      XCTFail("Expected structNode, got \(ast[0])")
    }
  }

  // Additional tests for edge cases and malformed inputs
  func testParseInvalidSyntax() {
    let dsl = "strct InvalidStruct { name: String }"  // Invalid 'struct' keyword
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 0)
  }

  func testParseEmptyInput() {
    let dsl = ""
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 0)
  }
}
