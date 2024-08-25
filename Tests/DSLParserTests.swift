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

  func testParseTypeNode() {
    let dsl = "type Int32"
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .typeNode(typeNode) = ast[0] {
      XCTAssertEqual(typeNode.name, "Int32")
    } else {
      XCTFail("Expected typeNode, got \(ast[0])")
    }
  }

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
      XCTAssertEqual(structNode.fields[0].type, "Int32")
      XCTAssertEqual(structNode.fields[0].optional, false)
      XCTAssertEqual(structNode.fields[1].name, "name")
      XCTAssertEqual(structNode.fields[1].type, "String")
      XCTAssertEqual(structNode.fields[1].optional, false)
    } else {
      XCTFail("Expected structNode, got \(ast[0])")
    }
  }

  func testParseStructWithInheritance() {
    let dsl = """
      struct Engineer extends Person {
          specialty: String
          isWorking: Bool
      }
      """
    let ast = parser.parse(dsl)

    XCTAssertEqual(ast.count, 1)
    if case let .structNode(structNode) = ast[0] {
      XCTAssertEqual(structNode.name, "Engineer")
      XCTAssertEqual(structNode.extends, "Person")
      XCTAssertEqual(structNode.fields.count, 2)
      XCTAssertEqual(structNode.fields[0].name, "specialty")
      XCTAssertEqual(structNode.fields[0].type, "String")
      XCTAssertEqual(structNode.fields[0].optional, false)
      XCTAssertEqual(structNode.fields[1].name, "isWorking")
      XCTAssertEqual(structNode.fields[1].type, "Bool")
      XCTAssertEqual(structNode.fields[1].optional, false)
    } else {
      XCTFail("Expected structNode, got \(ast[0])")
    }
  }

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
      XCTAssertEqual(interfaceNode.methods[0].parameters[0].type, "Int32")
      XCTAssertEqual(interfaceNode.methods[0].returnType, "Void")
      XCTAssertEqual(interfaceNode.methods[1].name, "report")
      XCTAssertEqual(interfaceNode.methods[1].parameters.count, 0)
      XCTAssertEqual(interfaceNode.methods[1].returnType, "String")
    } else {
      XCTFail("Expected interfaceNode, got \(ast[0])")
    }
  }

  func testParseFunctionSignatureNode() {
    let dsl = "function hire(person: Person, position: String): Boolean"
    let ast = parser.parse(dsl)

    print("AST: ", ast)

    XCTAssertEqual(ast.count, 1)
    if case let .functionSignatureNode(functionNode) = ast[0] {
      XCTAssertEqual(functionNode.name, "hire")
      XCTAssertEqual(functionNode.parameters.count, 2)
      XCTAssertEqual(functionNode.parameters[0].name, "person")
      XCTAssertEqual(functionNode.parameters[0].type, "Person")
      XCTAssertEqual(functionNode.parameters[1].name, "position")
      XCTAssertEqual(functionNode.parameters[1].type, "String")
      XCTAssertEqual(functionNode.returnType, "Bool")
    } else {
      XCTFail("Expected functionSignatureNode, got \(ast[0])")
    }
  }

  // Additional tests for edge cases and malformed inputs can be added here.
}
