//
//  DescribeImage.swift
//  Assignment3Ios
//
//  Created by HEWA DEWAGE DIHAN UDARA SANDARUWAN on 6/11/2562 BE.
//  Copyright © 2562 HEWA DEWAGE DIHAN UDARA SANDARUWAN. All rights reserved.
//

import Foundation

struct DescribeImage: Codable {
    let description: Description?
    let requestId: String?
}

struct Description: Codable {
    let tags: [String]?
    let captions: [Caption]?
}

struct Caption: Codable {
    let text: String?
    let confidence: Float?
}
