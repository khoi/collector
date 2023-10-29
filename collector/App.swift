import ComposableArchitecture
import Foundation
import SwiftUI

@main
struct CollectorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(
                store: appDelegate.store
            )
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let store: StoreOf<AppFeature> = Store(
        initialState: AppFeature.State(),
        reducer: {
            AppFeature()._printChanges()
        },
        withDependencies: nil
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        store.send(.applicationDidFinishLaunching)
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.send(.applicationWillTerminate)
    }
}
