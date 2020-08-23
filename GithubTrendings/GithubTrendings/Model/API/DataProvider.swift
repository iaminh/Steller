//
//  File.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import Foundation
import RxSwift

struct Repo: Codable {
    struct User: Codable {
        let avatarUrl: String
    }

    let id: Int
    let name: String
    let owner: User
    let description: String
    let forks: Int
    let stargazersCount: String
    let language: String
    let created: Date
}

//curl -G https://api.github.com/search/repositories --data-urlencode "q=created:>`date -v-1m '+%Y-%m-%d'`" --data-urlencode "sort=stars" --data-urlencode "order=desc" -H "Accept: application/json"
// curl -G https://api.github.com/search/repositories --data-urlencode "q=created:>`date -v-1w '+%Y-%m-%d'`" --data-urlencode "sort=stars" --data-urlencode "order=desc" -H "Accept: application/json"

struct GithubAPI {
    enum Interval {
        case month
        case week
        case day

        func toDate() -> Date {
            switch self {
            case .month:
                return Calendar.current.date(byAdding: DateComponents(month: -1), to: Date())!
            case .day:
                return Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!
            case .week:
                return Calendar.current.date(byAdding: DateComponents(weekOfYear: -1), to: Date())!
            }
        }
    }

    private func createRequest(for interval: Interval) -> URLRequest {
        let baseURL = URL(string: "https://api.github.com/search/repositories")!
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!

        components.queryItems = [
          .init(name: "order", value: "desc"),
          .init(name: "sort", value: "stars"),
          .init(name: "created", value: interval.toDate().toDayString()),
        ]

        return URLRequest(url: components.url!)
    }

    func loadRepos(for interval: Interval) -> Observable<[Repo]> {

        let request = createRequest(for: interval)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return URLSession.shared
            .rx
            .data(request: request)
            .map { try decoder.decode([Repo].self, from: $0) }
    }
}
