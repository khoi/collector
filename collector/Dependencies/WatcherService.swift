import AXSwift
import Dependencies
import Foundation

struct WatcherService: Sendable {
    var hasAccess: @Sendable () throws -> Bool
}

extension WatcherService: DependencyKey {
    static var liveValue: WatcherService {
        Self.init(hasAccess: {
            checkIsProcessTrusted(prompt: true)
        })
    }

    static var testValue = Self.init(hasAccess: unimplemented("request permission"))
}

extension DependencyValues {
    var watcherService: WatcherService {
        get { self[WatcherService.self] }
        set { self[WatcherService.self] = newValue }
    }
}
