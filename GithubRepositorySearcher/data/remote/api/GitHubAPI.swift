//
//  GitHubAPI.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import Moya

enum GitHubAPI: TargetType {

    case getRepositories(query: String)

    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }

    var path: String {
        switch self {
        case .getRepositories:
            return "/search/repositories"
        }
    }

    var method: Method {
        switch self {
        case .getRepositories:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getRepositories(let query):
            return .requestParameters(parameters: ["q": query], encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getRepositories:
            return ["Accept": "application/vnd.github.v3+json"]
        }
    }
}
