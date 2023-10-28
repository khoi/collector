import ComposableArchitecture
import XCTest

@testable import collector

@MainActor
final class CounterTests: XCTestCase {
    let clock = TestClock()

    func testCounter() async {
        let store = TestStore(
            initialState: CounterFeature.State()
        ) {
            CounterFeature()
        }

        await store.send(.incrementTapped) {
            $0.count = 1
        }
    }

    func testTimer() async throws {
        let store = TestStore(
            initialState: CounterFeature.State()
        ) {
            CounterFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.toggleTimerTapped) {
            $0.isTimerOn = true
        }

        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.count = 1
        }

        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.count = 2
        }

        await store.send(.toggleTimerTapped) {
            $0.isTimerOn = false
        }
    }

    func testGetFact() async throws {
        let store = TestStore(
            initialState: CounterFeature.State()
        ) {
            CounterFeature()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
            $0.numberFact = NumberFactClient(fetch: { _ in
                "some data"
            })
        }

        await store.send(.getFactTapped) {
            $0.isLoadingFact = true
        }

        await store.receive(.factResponse("some data")) {
            $0.isLoadingFact = false
            $0.fact = "some data"
        }
    }
}
