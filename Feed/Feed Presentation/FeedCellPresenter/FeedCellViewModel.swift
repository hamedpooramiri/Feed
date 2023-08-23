//
//  FeedCellViewModel.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/19/23.
//

import Foundation

public struct FeedCellViewModel<Image> {
    public let isLoading: Bool
    public let canRety: Bool
    public let location: String?
    public let description: String?
    public let image: Image?
    
    public var hasLocation: Bool {
        location != nil
    }
}
