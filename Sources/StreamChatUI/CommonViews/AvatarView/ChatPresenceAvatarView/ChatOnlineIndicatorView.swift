//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

/// A view used to indicate the presence of a user.
public typealias ChatOnlineIndicatorView = _ChatOnlineIndicatorView<NoExtraData>

/// A view used to indicate the presence of a user.
open class _ChatOnlineIndicatorView<ExtraData: ExtraDataTypes>: _View, UIConfigProvider {
    
    open private(set) lazy var circleView: UIView = UIView()
        .withoutAutoresizingMaskConstraints
    
    override public func defaultAppearance() {
        super.defaultAppearance()

        backgroundColor = .clear
        circleView.backgroundColor = uiConfig.colorPalette.alternativeActiveTint
    }

    override open func setUpLayout() {
        super.setUpLayout()
        heightAnchor.pin(equalTo: widthAnchor).isActive = true
        
        let borderWidth: CGFloat = 2
        embed(circleView, insets: .init(top: borderWidth, leading: borderWidth, bottom: borderWidth, trailing: borderWidth))
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2
        layer.masksToBounds = true
        
        circleView.layer.cornerRadius = circleView.bounds.width / 2
        circleView.layer.masksToBounds = true
    }
    
    /// Path used to mask space in super view. 
    open var maskingPath: CGPath? {
        UIBezierPath(ovalIn: frame).cgPath
    }
}
