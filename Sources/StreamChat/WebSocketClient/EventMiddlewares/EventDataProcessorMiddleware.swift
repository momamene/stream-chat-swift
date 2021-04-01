//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation

/// A middleware which saves the incoming data from the Event to the database.
struct EventDataProcessorMiddleware<ExtraData: ExtraDataTypes>: EventMiddleware {
    func handle(event: Event, session: DatabaseSession, completion: @escaping (Event?) -> Void) {
        guard let eventWithPayload = (event as? EventWithPayload) else {
            completion(event)
            return
        }
        
        guard let payload = eventWithPayload.payload as? EventPayload<ExtraData> else {
            log.assertionFailure("""
            Type mismatch between `EventPayload.ExtraData` and `EventDataProcessorMiddleware.ExtraData`."
                EventPayload type: \(type(of: eventWithPayload.payload))
                EventDataProcessorMiddleware type: \(type(of: self))
            """)
            completion(nil)
            return
        }
        
        do {
            try session.saveEvent(payload: payload)
            log.debug("Event data saved to db: \(payload)")
            
        } catch {
            log.error("Failed saving incoming `Event` data to DB. Error: \(error)")
            completion(nil)
            return
        }

        completion(event)
    }
}
