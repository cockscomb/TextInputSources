import XCTest
@testable import TextInputSources

class TextInputSourcesTests: XCTestCase {
    func testCurrent() {
        XCTAssertNotNil(TextInputSources.current)
        XCTAssertNotNil(TextInputSources.currentLayout)
        XCTAssertNotNil(TextInputSources.currentASCIICapable)
        XCTAssertNotNil(TextInputSources.currentASCIICapableLayout)
    }

    func testFind() {
        let current = TextInputSources.current
        let finded = TextInputSources.find(filtering: current.filteringProperties)
        XCTAssertEqual(finded.count, 1)
        XCTAssertEqual(finded.first, current)
    }

    static var allTests : [(String, (TextInputSourcesTests) -> () throws -> Void)] {
        return [
            ("testCurrent", testCurrent),
            ("testFind", testFind),
        ]
    }
}
