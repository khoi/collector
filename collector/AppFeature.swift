import AXSwift
import AppKit
import ComposableArchitecture
import Foundation
import SwiftUI

struct AppFeature: Reducer {
    struct State: Equatable {
        var hasAccessibilityPermission = false
    }

    enum Action: Equatable {
        case applicationDidFinishLaunching
        case applicationWillTerminate
        case accessibilityPermissionChanged(Bool)
        case frontMostApplicationChanged(ActiveApplication)
    }

    private enum CancelID: Hashable {
        case frontMostApplication
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

                guard state.hasAccessibilityPermission else {
                    return .cancel(id: CancelID.frontMostApplication)

                }

                return .run { send in
                    let notifications = await self.watcherService.frontMostApplication()

                    for try await app in notifications {
                        await send(.frontMostApplicationChanged(app))
                    }
                }
                .cancellable(id: CancelID.frontMostApplication)

            case let .frontMostApplicationChanged(app):
                print(app)
                return .none
            case .applicationWillTerminate:
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
