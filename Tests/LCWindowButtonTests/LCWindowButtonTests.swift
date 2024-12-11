import XCTest
@testable import LCWindowButton

final class LCWindowButtonTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        
        // 初始化一个关闭按钮
        let button = LCWindowButton(type: .close)
        
        // 检查按钮类型是否正确
        XCTAssertEqual(button.buttonType, .close, "按钮类型应为关闭")
        
        
    }
}
