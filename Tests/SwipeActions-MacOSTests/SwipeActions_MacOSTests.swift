import XCTest
@testable import SwipeActions_MacOS
import SwiftUI
struct MyView: View {
    var body: some View {
        SwipeView {
            Text("123")
        } leadingActions: { _ in
            SwipeAction("222") {
                
            }
        }

    }
}
final class SwipeActions_MacOSTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let view = MyView()
           XCTAssertEqual(view.body, Text("!"))
    }
}
