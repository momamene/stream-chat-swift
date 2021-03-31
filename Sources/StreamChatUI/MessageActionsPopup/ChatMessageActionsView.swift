//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

public typealias ChatMessageActionsView = _ChatMessageActionsView<NoExtraData>

/// View that contains `_ChatMessageActionItem`s
/// It is shown in `_ChatMessagePopupVC` to show the defined action items
open class _ChatMessageActionsView<ExtraData: ExtraDataTypes>: _View, UIConfigProvider {
    /// The data this view component shows.
    public var content: [ChatMessageActionItem] = [] {
        didSet { updateContentIfNeeded() }
    }

    /// Stack view with action items
    public private(set) lazy var stackView: UIStackView = UIStackView()
        .withoutAutoresizingMaskConstraints

    override public func defaultAppearance() {
        super.defaultAppearance()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 1
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = uiConfig.colorPalette.border
    }

    override open func setUpLayout() {
        embed(stackView)
    }

    override open func updateContent() {
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
            stackView.removeArrangedSubview($0)
        }

        content.forEach {
            let actionView = uiConfig.messageList.messageActionsSubviews.actionButton.init()
            actionView.content = $0
            stackView.addArrangedSubview(actionView)
        }
    }
}
