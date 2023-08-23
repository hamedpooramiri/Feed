//
//  HTTPURLResponse+Helpers.swift
//  Feed
//
//  Created by hamedpouramiri on 8/23/23.
//

import Foundation

public extension HTTPURLResponse {
    var isOK: Bool {
        statusCode == 200
    }
}
