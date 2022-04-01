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

    func getRepositories(query: String) -> AnyPublisher<GitHubRepoDto, Error> {
        // not implemented
        fatalError()
    }
}
