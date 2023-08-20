//
//  FeedCellViewModel.swift
//  FeediOS
//
//  Created by hamedpouramiri on 8/19/23.
//

import Foundation

struct FeedCellViewModel<Image> {
    let isLoading: Bool
    let canRety: Bool
    let location: String?
    let description: String?
    let image: Image?
    
    var hasLocation: Bool {
        location != nil
    }
}
