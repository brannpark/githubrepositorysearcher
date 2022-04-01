//
//  DIContainer.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import Foundation
import Resolver
import Moya

extension Resolver: ResolverRegistering {

    public static func registerAllServices() {
        register(name: .timeoutInterval) { TimeInterval(6) }
        register {
            return MoyaProvider<GitHubAPI>(
                requestClosure: { endpoint, done in
                    do {
                        var request = try endpoint.urlRequest()
                        request.timeoutInterval = resolve(name: .timeoutInterval)
                        done(.success(request))
                    } catch {
                        done(.failure(MoyaError.underlying(error, nil)))
                    }
                },
                plugins: [
                    NetworkLoggerPlugin(
                        configuration: NetworkLoggerPlugin.Configuration(
                            logOptions: .verbose
                        )
                    )
                ]
            )
        }.scope(.application)

        register { GitHubRepositoryImpl(provider: resolve()) as GitHubRepository }
        register { GetGitHubRepositoriesUsecaseImpl(repository: resolve()) as GetGitHubRepositoriesUsecase }
        register { MainViewModel(getGitHubRepositoriesUsecase: resolve()) }
    }
}

extension Resolver.Name {

    static let timeoutInterval = Self("timeoutInterval")
}
