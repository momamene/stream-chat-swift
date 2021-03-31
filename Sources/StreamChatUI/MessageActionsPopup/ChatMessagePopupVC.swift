//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

public typealias ChatMessagePopupVC = _ChatMessagePopupVC<NoExtraData>

open class _ChatMessagePopupVC<ExtraData: ExtraDataTypes>: _ViewController, UIConfigProvider {
    public private(set) lazy var scrollView = UIScrollView()
        .withoutAutoresizingMaskConstraints
    public private(set) lazy var scrollContentView = UIView()
        .withoutAutoresizingMaskConstraints
    public private(set) lazy var contentView = UIView()
        .withoutAutoresizingMaskConstraints
    public private(set) lazy var blurView: UIView = {
        let blur: UIBlurEffect
        if #available(iOS 13.0, *) {
            blur = UIBlurEffect(style: .systemUltraThinMaterial)
        } else {
            blur = UIBlurEffect(style: .regular)
        }
        return UIVisualEffectView(effect: blur)
            .withoutAutoresizingMaskConstraints
    }()

    public private(set) lazy var messageContentView = messageContentViewClass.init()
        .withoutAutoresizingMaskConstraints

    public var messageContentViewClass: _ChatMessageContentView<ExtraData>.Type!
    public var message: _ChatMessageGroupPart<ExtraData>!
    public var messageViewFrame: CGRect!
    public var actionsController: _ChatMessageActionsVC<ExtraData>!
    /// `_ChatMessageReactionsVC` instance for showing reactions.
    public var reactionsController: _ChatMessageReactionsVC<ExtraData>?
    
    /// Spacing between reactions, message, and actions
    public var spacing: CGFloat = 8
    
    /// Layout properties of this view
    public private(set) var layout = Layout()
    
    /// Properties tied to `_ChatMessagePopupVC` layout
    public struct Layout {
        /// Constraints of `reactionsController.view`
        public fileprivate(set) var reactionsViewConstraints: [NSLayoutConstraint] = []
        /// Constraints of `actionsController.view`
        public fileprivate(set) var actionsViewConstraints: [NSLayoutConstraint] = []
        /// Constraints of `messageContentView`
        public fileprivate(set) var messageContentViewConstraints: [NSLayoutConstraint] = []
    }

    // MARK: - Life Cycle

    override open func setUp() {
        super.setUp()
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnOverlay)))
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.isScrollEnabled = false
    }

    override public func defaultAppearance() {
        view.backgroundColor = .clear
        blurView.alpha = 0

        reactionsController?.view.alpha = 0
        reactionsController?.view.transform = .init(scaleX: 0.5, y: 0.5)
        
        actionsController.view.alpha = 0
        actionsController.view.transform = .init(scaleX: 0.5, y: 0.5)
    }

    override open func setUpLayout() {
        if let reactionsController = reactionsController {
            reactionsController.view.translatesAutoresizingMaskIntoConstraints = false
            addChildViewController(reactionsController, targetView: contentView)
        }

        actionsController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(actionsController, targetView: contentView)

        contentView.addSubview(messageContentView)
        messageContentView.setupMessageBubbleView()
        scrollContentView.addSubview(contentView)
        scrollView.embed(scrollContentView)
        view.embed(blurView)
        view.embed(scrollView)
        
        if let reactionsController = reactionsController {
            layout.reactionsViewConstraints = [
                reactionsController.view.topAnchor.pin(equalTo: contentView.topAnchor),
                reactionsController.view.leadingAnchor.pin(greaterThanOrEqualTo: contentView.leadingAnchor),
                reactionsController.view.trailingAnchor.pin(lessThanOrEqualTo: contentView.trailingAnchor),
                reactionsController.view.bottomAnchor.pin(equalTo: messageContentView.topAnchor, constant: -spacing)
            ]
            
            if message.isSentByCurrentUser {
                layout.reactionsViewConstraints += [
                    reactionsController.view.centerXAnchor.pin(equalTo: messageContentView.leadingAnchor)
                        .with(priority: .defaultHigh),
                    reactionsController.reactionsBubble.tailTrailingAnchor.pin(equalTo: messageContentView.leadingAnchor)
                ]
            } else {
                layout.reactionsViewConstraints += [
                    reactionsController.view.centerXAnchor.pin(equalTo: messageContentView.trailingAnchor)
                        .with(priority: .defaultHigh),
                    reactionsController.reactionsBubble.tailLeadingAnchor.pin(equalTo: messageContentView.trailingAnchor)
                ]
            }
            
            reactionsController.view.layoutIfNeeded()
        }
        
        layout.actionsViewConstraints = [
            actionsController.view.topAnchor.pin(equalTo: messageContentView.bottomAnchor, constant: spacing),
            actionsController.view.widthAnchor.pin(equalTo: contentView.widthAnchor, multiplier: 0.7),
            actionsController.view.bottomAnchor.pin(lessThanOrEqualTo: scrollContentView.bottomAnchor)
        ]
        
        if message.isSentByCurrentUser {
            layout.actionsViewConstraints.append(
                actionsController.view.trailingAnchor.pin(equalTo: messageContentView.trailingAnchor)
            )
        } else {
            layout.actionsViewConstraints.append(
                actionsController.view.leadingAnchor.pin(equalTo: messageContentView.messageBubbleView!.leadingAnchor)
            )
        }
        
        layout.messageContentViewConstraints = [
            messageContentView.topAnchor.pin(equalTo: contentView.topAnchor).almostRequired,
            messageContentView.widthAnchor.pin(equalToConstant: messageViewFrame.width),
            messageContentView.heightAnchor.pin(equalToConstant: messageViewFrame.height)
        ]
        if message.isSentByCurrentUser {
            layout.messageContentViewConstraints.append(
                messageContentView.trailingAnchor.pin(
                    equalTo: contentView.leadingAnchor,
                    constant: messageViewFrame.maxX
                )
            )
        } else {
            layout.messageContentViewConstraints.append(
                messageContentView.leadingAnchor.pin(
                    equalTo: contentView.leadingAnchor,
                    constant: messageViewFrame.minX
                )
            )
        }

        let scrollContentViewConstraint = [
            scrollContentView.widthAnchor.pin(equalTo: view.widthAnchor)
        ]
        
        var contentViewConstraints = [
            contentView.leadingAnchor.pin(equalTo: scrollContentView.leadingAnchor),
            contentView.trailingAnchor.pin(equalTo: scrollContentView.trailingAnchor)
        ]

        if messageViewFrame.minY <= 0 {
            contentViewConstraints += [
                contentView.topAnchor.pin(equalTo: scrollContentView.topAnchor),
                contentView.bottomAnchor.pin(
                    equalTo: scrollContentView.bottomAnchor,
                    constant: -(view.bounds.height - messageViewFrame.maxY - actionsController.view.frame.height - spacing)
                )
            ]
        } else {
            contentViewConstraints += [
                contentView.topAnchor.pin(
                    equalTo: scrollContentView.topAnchor,
                    constant: messageViewFrame.minY - (reactionsController?.view.frame.height ?? 0) - spacing
                ),
                contentView.bottomAnchor.pin(equalTo: scrollContentView.bottomAnchor)
            ]
        }

        NSLayoutConstraint.activate(
            layout.messageContentViewConstraints
                + layout.reactionsViewConstraints
                + layout.actionsViewConstraints
                + scrollContentViewConstraint
                + contentViewConstraints
        )
    }

    override open func updateContent() {
        messageContentView.message = message
        messageContentView.reactionsBubble?.isHidden = true
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Initially, the `applyInitialContentOffset` invocation was in `viewDidLayoutSubviews`
        // since the content offset can be applied when all the views are laid out
        // and `scrollView` content size is calculated.
        //
        // The problem is that `viewDidLayoutSubviews` is also called when reaction is
        // added/removed OR the gif is loaded while the initial `contentOffset` should be applied just once.
        //
        // Dispatching the invocation from `viewWillAppear`:
        //  1. makes sure we do it once;
        //  2. postpones it to the next run-loop iteration which guarantees it happens after `viewDidLayoutSubviews`
        DispatchQueue.main.async {
            self.applyInitialContentOffset()
            
            Animate {
                self.scrollToMakeMessageVisible()
                self.blurView.alpha = 1

                self.actionsController.view.alpha = 1
                self.actionsController.view.transform = .identity
            }
            
            Animate(delay: 0.1) {
                self.reactionsController?.view.alpha = 1
                self.reactionsController?.view.transform = .identity
            }
        }
    }
    
    open func applyInitialContentOffset() {
        let contentOffset = CGPoint(
            x: 0,
            y: max(0, -messageViewFrame.minY + spacing + (reactionsController?.view.frame.height ?? 0))
        )
        scrollView.setContentOffset(contentOffset, animated: false)
    }

    open func scrollToMakeMessageVisible() {
        let contentRect = scrollContentView.convert(contentView.frame, to: scrollView)
        scrollView.scrollRectToVisible(contentRect, animated: false)
    }

    @objc open func didTapOnOverlay() {
        dismiss(animated: true)
    }
}
