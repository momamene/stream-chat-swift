//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation

/// An object used to pre-process incoming `Event`.
protocol EventMiddleware {
    /// Process the incoming event and call completion when done. `completion` can be called multiple times if
    /// the functionality requires it.
    ///
    /// - Parameters:
    ///   - event: The incoming `Event`.
    ///   - session: The database session the middleware works with.
    ///   - completion: Called when the event processing is done. If called with `nil`, no middlewares down the
    ///   chain are called.
    func handle(event: Event, session: DatabaseSession, completion: @escaping (Event?) -> Void)
}

extension Array where Element == EventMiddleware {
    /// Evaluates an array of `EventMiddleware`s in the order they're specified in the array. It's not guaranteed that
    /// all middlewares are called. If a middleware calls the completion with `nil`, no middlewares down in the chain are called.
    ///
    /// - Parameters:
    ///   - event: The event to be pre-processed.
    ///   - session: The database session used when evaluating the middlewares.
    ///   - completion: Called when the event pre-processing is finished. Be aware that `completion` can be called
    ///   multiple times for a single event.
    func process(event: Event, session: DatabaseSession, completion: @escaping (Event?) -> Void) {
        guard isEmpty == false else { completion(event); return }
        evaluate(idx: startIndex, event: event, session: session, completion: completion)
    }
    
    private func evaluate(idx: Int, event: Event, session: DatabaseSession, completion: @escaping (Event?) -> Void) {
        let middleware = self[idx]
        middleware.handle(event: event, session: session) { event in
            let nextIdx = idx + 1
            if nextIdx == self.endIndex {
                completion(event)
                
            } else if let event = event {
                self.evaluate(idx: nextIdx, event: event, session: session, completion: completion)
                
            } else {
                completion(nil)
            }
        }
    }
}
