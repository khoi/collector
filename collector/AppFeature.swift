import ComposableArchitecture
import Foundation
import SwiftUI

struct AppFeature: Reducer {
    struct State: Equatable {
        var hasAccessibilityPermission = false
    }

    enum Action: Equatable {
        case applicationDidFinishLaunching
        case applicationDidBecomeActive
        case applicationDidResignActive
        case applicationWillTerminate

        case accessibilityPermissionChanged(Bool)
    }

    @Dependency(\.watcherService) var watcherService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .applicationDidFinishLaunching:
                return .run { send in
                    let hasPermission = try watcherService.hasAccess()
                    await send.callAsFunction(.accessibilityPermissionChanged(hasPermission))
                }
            case let .accessibilityPermissionChanged(newValue):
                state.hasAccessibilityPermission = newValue
                return .none
            case .applicationWillTerminate,
                .applicationDidResignActive,
                .applicationDidBecomeActive:
                return .none
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text("permission: \(viewStore.state.hasAccessibilityPermission.description)")
        }
    }
}
