//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import CoreData

/// A middleware which updates `currentlyTypingMembers` for a specific channel based on received `TypingEvent`.
struct ChannelMemberTypingStateUpdaterMiddleware<ExtraData: ExtraDataTypes>: EventMiddleware {
    func handle(event: Event, session: DatabaseSession, completion: @escaping (Event?) -> Void) {
        guard let typingEvent = event as? TypingEvent else {
            completion(event)
            return
        }
        
        do {
            guard
                let channelDTO = session.channel(cid: typingEvent.cid),
                let memberDTO = session.member(userId: typingEvent.userId, cid: typingEvent.cid)
            else { return }
            
            if typingEvent.isTyping {
                channelDTO.currentlyTypingMembers.insert(memberDTO)
            } else {
                channelDTO.currentlyTypingMembers.remove(memberDTO)
            }
        } catch {
            log.error("Failed saving incoming `TypingEvent` data to DB. Error: \(error)")
        }
        
        completion(event)
    }
}
