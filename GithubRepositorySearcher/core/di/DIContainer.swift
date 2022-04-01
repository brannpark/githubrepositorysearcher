//
//  DIContainer.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {

    public static func registerAllServices() {
        register { GitHubRepositoryImpl() as GitHubRepository }
        register { GetGitHubRepositoriesUsecaseImpl() as GetGitHubRepositoriesUsecase }
    }
}
