//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

/// A view that is used as a wrapper for status data in navigationItem's titleView
open class _ChatMessageListTitleView<ExtraData: ExtraDataTypes>: _View, UIConfigProvider {
    /// Content of the view that contains title (first line) and subtitle (second nil)
    open var content: (title: String?, subtitle: String?) = (nil, nil) {
        didSet {
            updateContent()
        }
    }
    
    /// Label that represents the first line of the final titleView
    open private(set) var titleLabel: UILabel = UILabel()
    
    /// Label that represents the second line of the final titleView
    open private(set) var subtitleLabel: UILabel = UILabel()
    
    /// A view that joins the `titleLabel` and `subtitleLabel` in vertical stack
    open private(set) var stackView: UIStackView = UIStackView()
    
    override public func defaultAppearance() {
        super.defaultAppearance()
        
        titleLabel.textAlignment = .center
        titleLabel.font = uiConfig.font.headlineBold
        
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = uiConfig.font.caption1
        subtitleLabel.textColor = uiConfig.colorPalette.subtitleText
        
        stackView.axis = .vertical
    }
    
    override open func setUpLayout() {
        super.setUpLayout()
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.pin(to: self)
    }
    
    override open func updateContent() {
        super.updateContent()
        
        titleLabel.text = content.title
        subtitleLabel.text = content.subtitle
    }
}
