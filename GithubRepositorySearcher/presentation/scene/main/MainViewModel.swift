//
//  MainViewModel.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import Foundation
import Combine

class MainViewModel: ObservableObject, RoutableViewModel {

    private let getGitHubRepositoriesUsecase: GetGitHubRepositoriesUsecase
    private var disposeBag = Set<AnyCancellable>()
    @Published var repositories = [Repository]()
    @Published var isLoading = false
    let router = PassthroughRelay<Routing>()

    init(getGitHubRepositoriesUsecase: GetGitHubRepositoriesUsecase) {
        self.getGitHubRepositoriesUsecase = getGitHubRepositoriesUsecase
    }

    func submit(searchQuery: String) {
        repositories = []
        getGitHubRepositoriesUsecase.execute(query: searchQuery)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.isLoading = true
            }, receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            }, receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                print(error)
            } receiveValue: { repositories in
                self.repositories = repositories
            }
            .store(in: &disposeBag)
    }

    func didTapRow(item: Repository) {
        router.send(.toWebScene(url: item.linkURL))
    }

    func didTapOwner(item: Repository) {
        router.send(.toWebScene(url: item.ownerLinkURL))
    }
}

extension MainViewModel {

    enum Routing {

        case toWebScene(url: URL)
    }
}
