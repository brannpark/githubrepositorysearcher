//
//  GetGitHubRepositoriesUsecase.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import Combine

// sourcery: AutoMockable
protocol GetGitHubRepositoriesUsecase {

    func execute(query: String) -> AnyPublisher<Repository, Error>
}

struct GetGitHubRepositoriesUsecaseImpl: GetGitHubRepositoriesUsecase {

    func execute(query: String) -> AnyPublisher<Repository, Error> {
        // not implemented
        fatalError()
    }
}
