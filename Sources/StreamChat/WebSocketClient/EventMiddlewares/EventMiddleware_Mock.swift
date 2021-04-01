//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

/// A test middleware that can be initiated with a closure
final class EventMiddlewareMock: EventMiddleware {
    var closure: (Event, DatabaseSession, @escaping (Event?) -> Void) -> Void
    
    init(closure: @escaping (Event, DatabaseSession, @escaping (Event?) -> Void) -> Void = { $2($0) }) {
        self.closure = closure
    }
    
    func handle(event: Event, session: DatabaseSession, completion: @escaping (Event?) -> Void) {
        closure(event, session, completion)
    }
}
