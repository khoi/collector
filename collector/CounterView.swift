import ComposableArchitecture
import SwiftUI

struct NumberFactClient {
    var fetch: @Sendable (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
    static let liveValue = NumberFactClient { number in
        let (data, _) = try await URLSession.shared.data(
            from:
                URL(string: "http://www.numbersapi.com/\(number)")!
        )
        return String(decoding: data, as: UTF8.self)
    }
}

extension DependencyValues {
    var numberFact: NumberFactClient {
        get {
            self[NumberFactClient.self]
        }
        set {
            self[NumberFactClient.self] = newValue
        }
    }
}

struct CounterFeature: Reducer {
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isTimerOn = false
        var isLoadingFact = false
    }

    enum Action: Equatable {
        case timerTicked
        case incrementTapped
        case decrementTapped
        case getFactTapped
        case toggleTimerTapped
        case factResponse(String)
    }

    private enum CancelID: Hashable {
        case timer
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.numberFact) var numberFact

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .incrementTapped:
                state.count += 1
                return .none
            case .decrementTapped:
                state.count -= 1
                return .none
            case .getFactTapped:
                state.fact = nil
                state.isLoadingFact = true
                return .run { [count = state.count] send in
                    await send(.factResponse(try self.numberFact.fetch(count)))
                }
            case .toggleTimerTapped:
                state.isTimerOn.toggle()

                if state.isTimerOn {
                    return .run { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            await send(.timerTicked)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
            case .timerTicked:
                state.count += 1
                return .none
            case .factResponse(let fact):
                state.isLoadingFact = false
                state.fact = fact
                return .none
            }
        }
    }
}

struct CounterView: View {
    let store: StoreOf<CounterFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    Text("\(viewStore.count)")
                    Button("-") {
                        viewStore.send(.decrementTapped)
                    }
                    Button("+") {
                        viewStore.send(.incrementTapped)
                    }
                }

                Section {
                    Button {
                        viewStore.send(.getFactTapped)
                    } label: {
                        HStack {
                            Text("Get fact")
                            if viewStore.isLoadingFact {
                                ProgressView()
                            }
                        }
                    }
                    if let fact = viewStore.fact {
                        Text(fact)
                    }

                }

                Section {
                    Button(viewStore.isTimerOn ? "Stop Timer" : "Start Timer") {
                        viewStore.send(.toggleTimerTapped)
                    }
                }
            }
        }

    }
}

#Preview {
    CounterView(
        store: Store(initialState: CounterFeature.State()) {
            CounterFeature()._printChanges()
        }
    )
    .frame(width: 400, height: 400)
}
