import XCTest
@testable import TextInputSources

class TextInputSourcesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(TextInputSources().text, "Hello, World!")
    }


    static var allTests : [(String, (TextInputSourcesTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
