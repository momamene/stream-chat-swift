//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

public typealias ChatMessageComposerQuoteBubbleView = _ChatMessageComposerQuoteBubbleView<NoExtraData>

open class _ChatMessageComposerQuoteBubbleView<ExtraData: ExtraDataTypes>: _View, UIConfigProvider {
    /// Default avatar view size. Subclass this view and override this property to change the size.
    open var authorAvatarViewSize: CGSize { .init(width: 24, height: 24) }

    /// Default attachment preview size. Subclass this view and override this property to change the size.
    open var attachmentPreviewSize: CGSize { .init(width: 34, height: 34) }

    /// The quoted message this component shows.
    public var content: _ChatMessage<ExtraData>? {
        didSet {
            updateContentIfNeeded()
        }
    }

    /// The `UIStackView` that acts as a container view.
    public private(set) lazy var container: UIStackView = UIStackView()
        .withoutAutoresizingMaskConstraints

    /// The `UIView` that holds the textView.
    public private(set) lazy var contentView: UIView = UIView()
        .withoutAutoresizingMaskConstraints

    /// The `UITextView` that contains quoted message content.
    public private(set) lazy var textView: UITextView = UITextView()
        .withoutAutoresizingMaskConstraints

    /// The avatar view of the author's quoted message.
    public private(set) lazy var authorAvatarView: ChatAvatarView = uiConfig
        .avatarView.init()
        .withoutAutoresizingMaskConstraints

    /// The attachment preview view if the quoted message has an attachment.
    public private(set) lazy var attachmentPreview: UIImageView = UIImageView()
        .withoutAutoresizingMaskConstraints

    /// The `ChatChannelListItemView` layout constraints.
    public struct Layout {
        public var containerConstraints: [NSLayoutConstraint] = []
        public var authorAvatarViewConstraints: [NSLayoutConstraint] = []
        public var attachmentPreviewWidthConstraint: NSLayoutConstraint?
        public var attachmentPreviewHeightConstraint: NSLayoutConstraint?
        public var attachmentPreviewLeadingConstraint: NSLayoutConstraint?
        public var attachmentPreviewConstraints: [NSLayoutConstraint] = []
        public var textViewConstraints: [NSLayoutConstraint] = []
    }

    /// The `ChatChannelListItemView` layout constraints.
    public private(set) var layout = Layout()
    
    override open func setUp() {
        super.setUp()
        
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.isScrollEnabled = false
        textView.adjustsFontForContentSizeCategory = true
        textView.isUserInteractionEnabled = false
    }
    
    override public func defaultAppearance() {
        textView.textContainer.maximumNumberOfLines = 6
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textContainer.lineFragmentPadding = .zero
        
        textView.backgroundColor = .clear
        textView.font = uiConfig.font.subheadline
        textView.textContainerInset = .zero
        textView.textColor = uiConfig.colorPalette.text

        authorAvatarView.contentMode = .scaleAspectFit
        
        attachmentPreview.layer.cornerRadius = attachmentPreviewSize.width / 4
        attachmentPreview.layer.masksToBounds = true

        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = uiConfig.colorPalette.border.cgColor
        contentView.layer.masksToBounds = true
    }
    
    override open func setUpLayout() {
        preservesSuperviewLayoutMargins = true
        
        addSubview(container)
        
        container.spacing = UIStackView.spacingUseSystem
        container.alignment = .bottom
        
        layout.containerConstraints = [
            container.leadingAnchor.pin(equalTo: leadingAnchor, constant: directionalLayoutMargins.leading),
            container.trailingAnchor.pin(equalTo: trailingAnchor, constant: -directionalLayoutMargins.trailing),
            container.topAnchor.pin(equalTo: topAnchor, constant: directionalLayoutMargins.top),
            container.bottomAnchor.pin(equalTo: bottomAnchor, constant: -directionalLayoutMargins.bottom)
        ]
        
        layout.authorAvatarViewConstraints = [
            authorAvatarView.widthAnchor.pin(equalToConstant: authorAvatarViewSize.width),
            authorAvatarView.heightAnchor.pin(equalToConstant: authorAvatarViewSize.height)
        ]
        
        container.addArrangedSubview(authorAvatarView)
        
        contentView.addSubview(attachmentPreview)
        
        layout.attachmentPreviewConstraints = [
            attachmentPreview.widthAnchor.pin(equalToConstant: attachmentPreviewSize.width),
            attachmentPreview.heightAnchor.pin(equalToConstant: attachmentPreviewSize.height),
            attachmentPreview.leadingAnchor.pin(
                equalTo: contentView.leadingAnchor,
                constant: contentView.directionalLayoutMargins.leading
            ),
            attachmentPreview.topAnchor.pin(equalTo: contentView.topAnchor, constant: contentView.directionalLayoutMargins.top),
            attachmentPreview.bottomAnchor.pin(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -contentView.directionalLayoutMargins.bottom
            )
        ]
        layout.attachmentPreviewWidthConstraint = layout.attachmentPreviewConstraints[0]
        layout.attachmentPreviewHeightConstraint = layout.attachmentPreviewConstraints[1]
        layout.attachmentPreviewLeadingConstraint = layout.attachmentPreviewConstraints[2]
        
        contentView.addSubview(textView)
        
        layout.textViewConstraints = [
            textView.topAnchor.pin(equalTo: contentView.topAnchor, constant: contentView.directionalLayoutMargins.top),
            textView.trailingAnchor.pin(
                equalTo: contentView.trailingAnchor,
                constant: -contentView.directionalLayoutMargins.trailing
            ),
            textView.bottomAnchor.pin(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -contentView.directionalLayoutMargins.bottom
            ),
            textView.leadingAnchor.pin(equalToSystemSpacingAfter: attachmentPreview.trailingAnchor, multiplier: 1)
        ]
                
        contentView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
        
        container.addArrangedSubview(contentView)
        
        NSLayoutConstraint.activate(
            layout.containerConstraints
                + layout.authorAvatarViewConstraints
                + layout.attachmentPreviewConstraints
                + layout.textViewConstraints
        )
    }
    
    override open func updateContent() {
        guard let message = content else { return }
        
        let placeholder = uiConfig.images.userAvatarPlaceholder1
        if let imageURL = message.author.imageURL {
            authorAvatarView.imageView.loadImage(from: imageURL, placeholder: placeholder)
        } else {
            authorAvatarView.imageView.image = placeholder
        }
        
        textView.text = message.text
        updateAttachmentPreview(for: message)
    }
    
    private func updateAttachmentPreview(for message: _ChatMessage<ExtraData>) {
        // TODO: Take last attachment when they'll be ordered.
        guard let attachment = message.attachments.first else {
            attachmentPreview.image = nil
            setAttachmentPreview(hidden: true)
            return
        }
        
        switch attachment.type {
        case .file:
            // TODO: Question for designers.
            // I'm not sure if it will be possible to provide specific icon for all file formats
            // so probably we should stick to some generic like other apps do.
            print("set file icon")
            setAttachmentPreview(hidden: false)
            attachmentPreview.contentMode = .scaleAspectFit
        default:
            let attachment = attachment as? ChatMessageDefaultAttachment
            if let previewURL = attachment?.imagePreviewURL ?? attachment?.imageURL {
                attachmentPreview.loadImage(from: previewURL)
                setAttachmentPreview(hidden: false)
                attachmentPreview.contentMode = .scaleAspectFill
                // TODO: When we will have attachment examples we will set smth
                // different for different types.
                if message.text.isEmpty, attachment?.type == .image {
                    textView.text = "Photo"
                }
            } else {
                attachmentPreview.image = nil
                setAttachmentPreview(hidden: true)
            }
        }
    }

    private func setAttachmentPreview(hidden: Bool) {
        if hidden {
            layout.attachmentPreviewWidthConstraint?.constant = 0
            layout.attachmentPreviewHeightConstraint?.constant = 0
            layout.attachmentPreviewLeadingConstraint?.constant = 0
        } else {
            layout.attachmentPreviewWidthConstraint?.constant = attachmentPreviewSize.width
            layout.attachmentPreviewHeightConstraint?.constant = attachmentPreviewSize.height
            layout.attachmentPreviewLeadingConstraint?.constant = contentView.directionalLayoutMargins.leading
        }
    }
}
