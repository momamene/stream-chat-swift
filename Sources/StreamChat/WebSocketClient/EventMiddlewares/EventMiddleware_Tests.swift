//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import CoreData
@testable import StreamChat
import XCTest

class EventMiddleware_Tests: XCTestCase {
    /// A test middleware that can be initiated with a closure/
    struct ClosureBasedMiddleware: EventMiddleware {
        let closure: (_ event: Event, _ session: DatabaseSession, _ completion: @escaping (Event?) -> Void) -> Void
        
        func handle(event: Event, session: DatabaseSession, completion: @escaping (Event?) -> Void) {
            closure(event, session, completion)
        }
    }
    
    /// A test event holding an `Int` value.
    struct IntBasedEvent: Event, Equatable {
        let value: Int
    }
    
    func test_middlewareEvaluation() throws {
        var database: DatabaseContainer! = DatabaseContainerMock()
        let usedSession = database.viewContext
        
        let chain: [EventMiddleware] = [
            // Adds `1` to the event synchronously
            ClosureBasedMiddleware { event, session, completion in
                XCTAssertEqual(session as! NSManagedObjectContext, usedSession)
                let event = event as! IntBasedEvent
                completion(IntBasedEvent(value: event.value + 1))
            },
            
            // Adds `1` to the event synchronously and resets it to `0` asynchronously
            ClosureBasedMiddleware { event, session, completion in
                XCTAssertEqual(session as! NSManagedObjectContext, usedSession)
                let event = event as! IntBasedEvent
                DispatchQueue.main.async {
                    completion(IntBasedEvent(value: 0))
                }
                completion(IntBasedEvent(value: event.value + 1))
            }
        ]
        
        // Evaluate the middlewares and record the events
        var result: [IntBasedEvent?] = []
        chain.process(event: IntBasedEvent(value: 0), session: usedSession) {
            result.append($0 as? IntBasedEvent)
        }
        
        // Check we have two callbacks with correct results
        AssertAsync.willBeEqual(result, [IntBasedEvent(value: 2), IntBasedEvent(value: 0)])
        
        AssertAsync.canBeReleased(&database)
    }
}
