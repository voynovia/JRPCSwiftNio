import XCTest
@testable import JRPCSwiftNio

final class JRPCSwiftNioTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(JRPCSwiftNio().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
