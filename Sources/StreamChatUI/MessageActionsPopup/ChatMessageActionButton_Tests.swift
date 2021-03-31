//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatTestTools
@testable import StreamChatUI
import XCTest

class ChatMessageActionButton_Tests: XCTestCase {
    private var content: ChatMessageActionItem<NoExtraData>!
    
    override func setUp() {
        super.setUp()
        
        content = ChatMessageActionItem(
            title: "Action 1",
            icon: UIImage(named: "icn_inline_reply", in: .streamChatUI)!,
            action: {}
        )
    }

    func test_emptyState() {
        let view = ChatMessageActionButton().withoutAutoresizingMaskConstraints
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 50)
        ])
        view.content = content
        view.content = ChatMessageActionItem(title: "", icon: UIImage(), action: {})
        AssertSnapshot(view)
    }
    
    func test_defaultAppearance() {
        let view = ChatMessageActionButton()
        view.content = content
        AssertSnapshot(view)
    }
  
    // TODO: Add tests for individual items
//    func test_defaultAppearance_whenDestructive() {
//        view.content = ChatMessageActionItem(
//            title: "Action 1",
//            icon: UIImage(named: "icn_inline_reply", in: .streamChatUI)!,
//            action: {}
//        )
//    }
    
    func test_appearanceCustomization_usingUIConfig() {
        var config = UIConfig()
        config.colorPalette.text = .blue
        
        let view = ChatMessageActionButton()
        view.content = content
        view.uiConfig = config
        
        AssertSnapshot(view)
    }
    
    func test_appearanceCustomization_usingAppearanceHook() {
        class TestView: ChatMessageActionButton {}
        TestView.defaultAppearance {
            $0.backgroundColor = .cyan
        }

        let view = TestView()

        view.content = content
        AssertSnapshot(view)
    }

    func test_appearanceCustomization_usingSubclassing() {
        class TestView: ChatMessageActionButton {
            override func setUpAppearance() {
                super.setUpAppearance()
                backgroundColor = .cyan
            }
            
            override func updateContent() {
                super.updateContent()
                
                setTitleColor(.red, for: .normal)
            }
        }

        let view = TestView()

        view.content = content
        AssertSnapshot(view)
    }
}
