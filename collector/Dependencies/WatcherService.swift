import AXSwift
import AppKit
import Dependencies
import Foundation

struct WatcherService: Sendable {
    var hasAccess: @Sendable () throws -> Bool
    var frontMostApplication:
        @Sendable () async -> AsyncThrowingStream<NSRunningApplication?, Error>
}

extension WatcherService: DependencyKey {
    static var liveValue: WatcherService {
        Self.init(
            hasAccess: {
                checkIsProcessTrusted(prompt: true)
            },
            frontMostApplication: {
                return AsyncThrowingStream { continuation in
                    Task {
                        for await _ in NSWorkspace.shared.notificationCenter.notifications(
                            named: NSWorkspace.didActivateApplicationNotification, object: nil)
                        {
                            continuation.yield(NSWorkspace.shared.frontmostApplication)
                        }
                        continuation.finish()
                    }
                }
            })
    }

    static var testValue = Self.init(
        hasAccess: unimplemented(),
        frontMostApplication: unimplemented()
    )
}

extension DependencyValues {
    var watcherService: WatcherService {
        get { self[WatcherService.self] }
        set { self[WatcherService.self] = newValue }
    }
}
