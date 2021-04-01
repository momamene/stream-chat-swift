//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation

/// The type is designed to pre-process some incoming `Event` via middlewares before being published
class EventNotificationCenter: NotificationCenter {
    private(set) var middlewares: [EventMiddleware] = []
    
    let database: DatabaseContainer
    
    init(middlewares: [EventMiddleware] = [], database: DatabaseContainer) {
        self.database = database
        super.init()
        middlewares.forEach(add)
    }

    func add(middleware: EventMiddleware) {
        middlewares.append(middleware)
    }
    
    func process(_ event: Event) {
        database.write { session in
            self.middlewares.process(event: event, session: session) { [weak self] in
                guard let self = self, let eventToPublish = $0 else { return }
                self.post(Notification(newEventReceived: eventToPublish, sender: self))
            }
        }
    }
}
