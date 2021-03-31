//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

/// Protocol for action item
/// Action items are then showed in `_ChatMessageActionsView`
/// Setup individual item by creating new instance that conforms to this protocol
public protocol ChatMessageActionItem {
    var title: String { get }
    var icon: UIImage { get }
    var isPrimary: Bool { get }
    var isDestructive: Bool { get }
    var action: (ChatMessageActionItem) -> Void { get }
}

extension ChatMessageActionItem {
    public var isPrimary: Bool { false }
    public var isDestructive: Bool { false }
}

public struct InlineReplyActionItem: ChatMessageActionItem {
    public var title: String { L10n.Message.Actions.inlineReply }
    public let icon: UIImage
    public let action: (ChatMessageActionItem) -> Void
    
    public init<ExtraData: ExtraDataTypes>(
        action: @escaping (ChatMessageActionItem) -> Void,
        uiConfig: _UIConfig<ExtraData> = .default
    ) {
        self.action = action
        icon = uiConfig.images.messageActionInlineReply
    }
}

public struct ThreadReplyActionItem: ChatMessageActionItem {
    public var title: String { L10n.Message.Actions.threadReply }
    public let icon: UIImage
    public let action: (ChatMessageActionItem) -> Void
    
    public init<ExtraData: ExtraDataTypes>(
        action: @escaping (ChatMessageActionItem) -> Void,
        uiConfig: _UIConfig<ExtraData> = .default
    ) {
        self.action = action
        icon = uiConfig.images.messageActionThreadReply
    }
}

public struct EditActionItem: ChatMessageActionItem {
    public var title: String { L10n.Message.Actions.edit }
    public let icon: UIImage
    public let action: (ChatMessageActionItem) -> Void
    
    public init<ExtraData: ExtraDataTypes>(
        action: @escaping (ChatMessageActionItem) -> Void,
        uiConfig: _UIConfig<ExtraData> = .default
    ) {
        self.action = action
        icon = uiConfig.images.messageActionEdit
    }
}

public struct CopyActionItem: ChatMessageActionItem {
    public var title: String { L10n.Message.Actions.copy }
    public let icon: UIImage
    public let action: (ChatMessageActionItem) -> Void
    
    public init<ExtraData: ExtraDataTypes>(
        action: @escaping (ChatMessageActionItem) -> Void,
        uiConfig: _UIConfig<ExtraData> = .default
    ) {
        self.action = action
        icon = uiConfig.images.messageActionCopy
    }
}

public struct UnblockUserActionItem: ChatMessageActionItem {
    public var title: String { L10n.Message.Actions.userUnblock }
    public let icon: UIImage
    public let action: (ChatMessageActionItem) -> Void
    
    public init<ExtraData: ExtraDataTypes>(
        action: @escaping (ChatMessageActionItem) -> Void,
        uiConfig: _UIConfig<ExtraData> = .default
    ) {
        self.action = action
        icon = uiConfig.images.messageActionBlockUser
    }
}

public struct BlockUserActionItem: ChatMessageActionItem {
    public var title: String { L10n.Message.Actions.userBlock }
    public let icon: UIImage
    public let action: (ChatMessageActionItem) -> Void
    
    public init<ExtraData: ExtraDataTypes>(
        action: @escaping (ChatMessageActionItem) -> Void,
        uiConfig: _UIConfig<ExtraData> = .default
    ) {
        self.action = action
        icon = uiConfig.images.messageActionBlockUser
    }
}

public struct MuteUserActionItem: ChatMessageActionItem {
    public var title: String { L10n.Message.Actions.userMute }
    public let icon: UIImage
    public let action: (ChatMessageActionItem) -> Void
    
    public init<ExtraData: ExtraDataTypes>(
        action: @escaping (ChatMessageActionItem) -> Void,
        uiConfig: _UIConfig<ExtraData> = .default
    ) {
        self.action = action
        icon = uiConfig.images.messageActionMuteUser
    }
}

public struct UnmuteUserActionItem: ChatMessageActionItem {
    public var title: String { L10n.Message.Actions.userUnmute }
    public let icon: UIImage
    public let action: (ChatMessageActionItem) -> Void
    
    public init<ExtraData: ExtraDataTypes>(
        action: @escaping (ChatMessageActionItem) -> Void,
        uiConfig: _UIConfig<ExtraData> = .default
    ) {
        self.action = action
        icon = uiConfig.images.messageActionMuteUser
    }
}

public struct DeleteActionItem: ChatMessageActionItem {
    public var title: String { L10n.Message.Actions.delete }
    public var isDestructive: Bool { true }
    public let icon: UIImage
    public let action: (ChatMessageActionItem) -> Void
    
    public init<ExtraData: ExtraDataTypes>(
        action: @escaping (ChatMessageActionItem) -> Void,
        uiConfig: _UIConfig<ExtraData> = .default
    ) {
        self.action = action
        icon = uiConfig.images.messageActionDelete
    }
}

public struct ResendActionItem: ChatMessageActionItem {
    public var title: String { L10n.Message.Actions.resend }
    public var isPrimary: Bool { true }
    public let icon: UIImage
    public let action: (ChatMessageActionItem) -> Void
    
    public init<ExtraData: ExtraDataTypes>(
        action: @escaping (ChatMessageActionItem) -> Void,
        uiConfig: _UIConfig<ExtraData> = .default
    ) {
        self.action = action
        icon = uiConfig.images.messageActionResend
    }
}
