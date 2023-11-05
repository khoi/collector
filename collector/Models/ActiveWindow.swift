import Foundation
import ScriptingBridge

struct ActiveApplication: Equatable {
    let name: String
    let bundleId: String
}

struct ActiveWindow: Equatable {
    let title: String
    let documentURL: String?
}
