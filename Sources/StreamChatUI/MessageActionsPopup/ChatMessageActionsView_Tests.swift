//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatTestTools
@testable import StreamChatUI
import XCTest

class ChatMessageActionsView_Tests: XCTestCase {
    private var content: [ChatMessageActionItem<NoExtraData>]!
    
    override func setUp() {
        super.setUp()
        
        content = [
            ChatMessageActionItem(
                title: "Action 1",
                icon: UIImage(named: "icn_inline_reply", in: .streamChatUI)!,
                action: {}
            ),
            ChatMessageActionItem(
                title: "Action 2",
                icon: UIImage(named: "icn_thread_reply", in: .streamChatUI)!,
                action: {}
            )
        ]
    }
    
    func test_emptyState() {
        let view = ChatMessageActionsView().withoutAutoresizingMaskConstraints
        view.addSizeConstraints()
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 50)
        ])
        view.content = content
        view.content = []
        AssertSnapshot(view)
    }
    
    func test_defaultAppearance() {
        let view = ChatMessageActionsView().withoutAutoresizingMaskConstraints
        view.addSizeConstraints()
        view.content = content
        AssertSnapshot(view)
    }
    
    func test_appearanceCustomization_usingUIConfig() {
        var config = UIConfig()
        config.colorPalette.border = .red
        
        let view = ChatMessageActionsView().withoutAutoresizingMaskConstraints
        view.addSizeConstraints()
        view.content = content
        view.uiConfig = config
        
        AssertSnapshot(view)
    }
    
    func test_appearanceCustomization_usingAppearanceHook() {
        class TestView: ChatMessageActionsView {}
        TestView.defaultAppearance {
            $0.stackView.spacing = 10
            $0.backgroundColor = .cyan
        }
        
        let view = TestView().withoutAutoresizingMaskConstraints
        
        view.addSizeConstraints()
        
        view.content = content
        AssertSnapshot(view)
    }
    
    func test_appearanceCustomization_usingSubclassing() {
        class TestView: ChatMessageActionsView {
            override func setUpAppearance() {
                super.setUpAppearance()
                stackView.spacing = 10
                backgroundColor = .cyan
                layer.cornerRadius = 0
            }
        }
        
        let view = TestView().withoutAutoresizingMaskConstraints
        
        view.addSizeConstraints()
        
        view.content = content
        AssertSnapshot(view)
    }
    
    func test_ItemView_usesCorrectUIConfigTypes_whenCustomTypesDefined() {
        class TestActionButton: ChatMessageActionsView.ActionButton {}
        
        // Create default `ChatMessageActionsView` which has everything default from `UIConfig`
        let view = ChatMessageActionsView()

        // Create new config to set custom types...
        var customConfig = UIConfig()

        customConfig.messageList.messageActionsSubviews.actionButton = TestActionButton.self

        view.uiConfig = customConfig

        XCTAssert(view.stackView.arrangedSubviews.allSatisfy { $0 is TestActionButton })
    }
}

private extension ChatMessageActionsView {
    func addSizeConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 200)
        ])
    }
}
