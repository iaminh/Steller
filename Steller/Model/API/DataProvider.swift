//
//  File.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import Foundation
import RxSwift

struct Story: Codable {
    struct User: Codable {
        let displayName: String
        let avatarImageUrl: String
    }

    let id: String
    let coverSrc: String
    let user: User
}

struct StoriesResponseDTO: Codable {
    let data: [Story]
}

struct DataProvider {
    func loadStories() -> Observable<[Story]> {
        let request = URLRequest(url: URL(string: "https://api.steller.co/v1/users/76794126980351029/stories")!)
        return URLSession.shared
            .rx
            .data(request: request)
            .map { try CustomDecoder().decode(StoriesResponseDTO.self, from: $0) }
            .map { $0.data }
            .debug()
    }
}
