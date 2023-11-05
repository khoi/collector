import AXSwift
import AppKit
import Dependencies
import Foundation

struct WatcherService: Sendable {
    var hasAccess: @Sendable () throws -> Bool
    var frontMostApplication: @Sendable () async -> AsyncThrowingStream<ActiveApplication, Error>
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
                            guard let application = NSWorkspace.shared.frontmostApplication
                            else {
                                return
                            }

                            guard let applicationName = application.localizedName,
                                let bundleId = application.bundleIdentifier
                            else {
                                assertionFailure("check why application doesn't have data")
                                return
                            }

                            continuation.yield(
                                ActiveApplication(
                                    name: applicationName,
                                    bundleId: bundleId
                                ))
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
