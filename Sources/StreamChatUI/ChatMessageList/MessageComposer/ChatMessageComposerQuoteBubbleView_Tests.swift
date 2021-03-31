//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
import StreamChatTestTools
@testable import StreamChatUI
import XCTest

class ChatMessageComposerQuoteBubbleView_Tests: XCTestCase {
    var view: ChatMessageComposerQuoteBubbleView!

    override func setUp() {
        super.setUp()
        view = ChatMessageComposerQuoteBubbleView().withoutAutoresizingMaskConstraints
        view.addSizeConstraints()
        view.backgroundColor = .gray
    }

    override func tearDown() {
        super.tearDown()
        view = nil
    }

    func test_emptyAppearance() {
        view.content = makeMessage(text: "")

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_defaultAppearance() {
        view.content = makeMessage(text: "Hello Vader!")

        AssertSnapshot(view)
    }

    func test_withImageAttachmentAppearance() {
        let attachment = ChatMessageDefaultAttachment(imageUrl: TestImages.yoda.url, title: "")
        view.content = makeMessage(text: "Hello Vader!", attachments: [attachment])

        AssertSnapshot(view)
    }

    func test_withLongTextAppearance() {
        let attachment = ChatMessageDefaultAttachment(imageUrl: TestImages.yoda.url, title: "")
        view.content = makeMessage(text: "Hello Darth Vader! Where is my light saber?", attachments: [attachment])

        AssertSnapshot(view)
    }

    func test_appearanceCustomization_usingUIConfig() {
        class TestView: ChatAvatarView {
            override func setUpAppearance() {
                super.setUpAppearance()

                imageView.layer.shadowColor = UIColor.black.cgColor
                imageView.layer.shadowOpacity = 0.7
                imageView.layer.shadowOffset = .zero
                imageView.layer.shadowRadius = 5
                imageView.clipsToBounds = false
            }
        }

        var config = UIConfig()
        config.avatarView = TestView.self

        view.content = makeMessage(text: "Hello Vader!")
        view.uiConfig = config

        AssertSnapshot(view, variants: [.defaultLight])
    }

    func test_appearanceCustomization_usingAppearanceHook() {
        class TestView: ChatMessageComposerQuoteBubbleView {}
        TestView.defaultAppearance {
            $0.contentView.layer.borderColor = UIColor.yellow.cgColor
            $0.contentView.backgroundColor = .lightGray
        }

        let view = TestView().withoutAutoresizingMaskConstraints
        view.content = makeMessage(text: "Hello Vader!")
        view.addSizeConstraints()

        AssertSnapshot(view, variants: [.defaultLight])
    }

    func test_appearanceCustomization_usingSubclassing() {
        class TestView: ChatMessageComposerQuoteBubbleView {
            override var attachmentPreviewSize: CGSize { .init(width: 50, height: 50) }
            override var authorAvatarViewSize: CGSize { .init(width: 28, height: 29) }

            override func setUpAppearance() {
                super.setUpAppearance()

                contentView.layer.borderColor = UIColor.yellow.cgColor
                contentView.backgroundColor = .lightGray
            }

            override func setUpLayout() {
                super.setUpLayout()

                container.alignment = .center
            }
        }

        let view = TestView().withoutAutoresizingMaskConstraints
        let attachment = ChatMessageDefaultAttachment(imageUrl: TestImages.yoda.url, title: "")
        view.content = makeMessage(text: "Hello Vader!", attachments: [attachment])
        view.addSizeConstraints()

        AssertSnapshot(view, variants: [.defaultLight])
    }
}

private extension ChatMessageComposerQuoteBubbleView {
    func addSizeConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 360)
        ])
    }
}

// MARK: - Factory Helper

extension ChatMessageComposerQuoteBubbleView_Tests {
    func makeMessage(text: String, attachments: [ChatMessageAttachment] = []) -> ChatMessage {
        .mock(
            id: .unique,
            text: text,
            author: .mock(id: .unique),
            attachments: attachments
        )
    }
}

// MARK: - Mock ChatMessageDefaultAttachment

private extension ChatMessageDefaultAttachment {
    init(imageUrl: URL?, title: String) {
        self.init(id: .unique, type: .image, localURL: nil, localState: nil, title: title)
        imageURL = imageUrl
    }
}
