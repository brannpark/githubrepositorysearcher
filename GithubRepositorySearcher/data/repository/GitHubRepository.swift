//
//  GitHubRepository.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import Combine
import Moya

// sourcery: AutoMockable
protocol GitHubRepository {

    func getRepositories(query: String) -> AnyPublisher<GitHubRepoDto, Error>
}

struct GitHubRepositoryImpl: GitHubRepository {

    private let provider: MoyaProvider<GitHubAPI>

    init(provider: MoyaProvider<GitHubAPI>) {
        self.provider = provider
    }

    func getRepositories(query: String) -> AnyPublisher<GitHubRepoDto, Error> {
        return provider.requestPublisher(.getRepositories(query: query))
            .map(GitHubRepoDto.self)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
