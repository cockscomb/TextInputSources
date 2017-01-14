import XCTest
@testable import TextInputSources

class InputSourceTests: XCTestCase {
    lazy var inputSources = TextInputSources.find(includeAllInstalled: true)

    func testLanguages() {
        for inputSource in inputSources {
            XCTAssert(inputSource.languages.count > 0)
            XCTAssert(inputSource.locales.count > 0)
        }
    }

    static var allTests : [(String, (InputSourceTests) -> () throws -> Void)] {
        return [
            ("testLanguages", testLanguages),
        ]
    }
}
