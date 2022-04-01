//
//  GetGitHubRepositoriesUsecase.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import Foundation
import Combine

// sourcery: AutoMockable
protocol GetGitHubRepositoriesUsecase {

    func execute(query: String) -> AnyPublisher<[Repository], Error>
}

struct GetGitHubRepositoriesUsecaseImpl: GetGitHubRepositoriesUsecase {

    private let repository: GitHubRepository

    init(repository: GitHubRepository) {
        self.repository = repository
    }

    func execute(query: String) -> AnyPublisher<[Repository], Error> {
        return repository.getRepositories(query: query)
            .map { dto in
                dto.items.map {
                    Repository(
                        id: $0.id,
                        name: $0.name,
                        owner: $0.owner.login,
                        ownerAvatarURL: URL(string: $0.owner.avatar_url ?? ""),
                        ownerLinkURL: URL(string: $0.owner.html_url)!,
                        linkURL: URL(string: $0.html_url)!,
                        description: $0.description ?? "",
                        license: $0.license?.spdx_id ?? "",
                        starCount: $0.stargazers_count
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
