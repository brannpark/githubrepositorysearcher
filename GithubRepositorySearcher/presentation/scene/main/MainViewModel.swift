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
    @Published var query: String = ""
    @Published var repositories = [Repository]()
    @Published var isLoading = false
    @Published var error: Error?
    let router = PassthroughRelay<Routing>()

    init(getGitHubRepositoriesUsecase: GetGitHubRepositoriesUsecase) {
        self.getGitHubRepositoriesUsecase = getGitHubRepositoriesUsecase
    }

    func onAppear() {
        query = "Moya"
        submitSearch()
    }

    func submitSearch() {
        let searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchQuery.isEmpty else {
            return
        }
        getGitHubRepositoriesUsecase.execute(query: searchQuery)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.repositories = []
                self?.error = nil
                self?.isLoading = true
            }, receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            }, receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else {
                    return
                }
                print(error)
                self?.error = error
            } receiveValue: { [weak self] repositories in
                self?.repositories = repositories
                if repositories.isEmpty {
                    self?.error = Errors.notFound
                }
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

    enum Errors: Error {

        case notFound
    }
}
