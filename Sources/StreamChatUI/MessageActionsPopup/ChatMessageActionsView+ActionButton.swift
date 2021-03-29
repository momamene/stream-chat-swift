//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import UIKit

extension _ChatMessageActionsView {
    /// Button for action displayed in `_ChatMessageActionsView`
    open class ActionButton: _Button, UIConfigProvider {
        /// The data this view component shows.
        public var content: ChatMessageActionItem<ExtraData>? {
            didSet { updateContentIfNeeded() }
        }

        override public func defaultAppearance() {
            backgroundColor = uiConfig.colorPalette.background
            titleLabel?.font = uiConfig.font.body
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            contentHorizontalAlignment = .left
        }

        override open func setUp() {
            super.setUp()
            
            addTarget(self, action: #selector(touchUpInsideHandler(_:)), for: .touchUpInside)
        }

        override open func tintColorDidChange() {
            super.tintColorDidChange()
            
            updateContentIfNeeded()
        }
        
        override open func updateContent() {
            let imageTintСolor: UIColor
            let titleTextColor: UIColor

            if content?.isDestructive == true {
                imageTintСolor = uiConfig.colorPalette.alert
                titleTextColor = imageTintСolor
            } else {
                imageTintСolor = content?.isPrimary == true ? tintColor : uiConfig.colorPalette.inactiveTint
                titleTextColor = uiConfig.colorPalette.text
            }

            setImage(content?.icon.tinted(with: imageTintСolor), for: .normal)
            setTitle(content?.title, for: .normal)
            setTitleColor(titleTextColor, for: .normal)
        }
        
        /// Triggered when `ActionButton` is tapped
        @objc open func touchUpInsideHandler(_ sender: Any) {
            content?.action()
        }
    }
}
