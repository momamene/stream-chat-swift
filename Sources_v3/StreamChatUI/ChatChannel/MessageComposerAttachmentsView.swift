//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import UIKit

open class MessageComposerAttachmentsView<ExtraData: UIExtraDataTypes>: UIView,
    UICollectionViewDelegate,
    UICollectionViewDataSource {
    // MARK: - Properties

    public weak var composer: UIView?
    public let uiConfig: UIConfig<ExtraData>
    
    var attachments: [UIImage] = []
    
    // MARK: - Subviews
    
    public private(set) lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = .init(width: 50, height: 70)
        flowLayout.sectionInset = .init(top: 20, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .horizontal
        
        return flowLayout
    }()
    
    public private(set) lazy var collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: flowLayout)

    // MARK: - Init
    
    public required init(
        uiConfig: UIConfig<ExtraData> = .default
    ) {
        self.uiConfig = uiConfig
        
        super.init(frame: .zero)
        
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        uiConfig = .default
        
        super.init(coder: coder)
        
        commonInit()
    }
    
    public func commonInit() {
        embed(collectionView)
        
        setupAppearance()
        setupCollectionView()
    }
    
    // MARK: - Public
    
    open func setupAppearance() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    open func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    // MARK: - Actions
    
    public func insertNewItem(with image: UIImage) {
        attachments.append(image)
        collectionView.reloadData()
        if !attachments.isEmpty {
            isHidden = false
        }
    }

    public func remove(at index: Int) {
        attachments.remove(at: index)
        collectionView.reloadData()
        if attachments.isEmpty {
            isHidden = true
            composer?.invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - UICollectionView
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        attachments.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let imageView = MessageComposerAttachmentsCellView(
            image: attachments[indexPath.row],
            deleteClosure: { [weak self] in
                self?.remove(at: indexPath.row)
                collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            }
        )
        cell.embed(imageView)
        return cell
    }
}
