//
//  FeedItemCell.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/16/23.
//

import UIKit

public final class FeedItemCell: UITableViewCell {
    
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let locationContainer = UIView()
    public let imageContainer = UIView()
    public private(set) lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTaped), for: .touchUpInside)
        return button
    }()
    public let feedImageView = UIImageView()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTaped() {
        onRetry?()
    }
    
}
