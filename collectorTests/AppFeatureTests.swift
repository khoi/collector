import ComposableArchitecture
import XCTest

@testable import collector

@MainActor
final class AppFeatureTests: XCTestCase {
    func testSomething() async {
        let store = TestStore(
            initialState: AppFeature.State()
        ) {
            AppFeature()
        }
    }

}
