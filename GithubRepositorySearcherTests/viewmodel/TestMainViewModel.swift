//
//  TestMainViewModel.swift
//  GithubRepositorySearcherTests
//
//  Created by brann on 2022/04/02.
//

import Quick
import Nimble
import Combine
import CombineExpectations
import SwiftyMocky
@testable import GithubRepositorySearcher

class TestMainViewModel: QuickSpec {

    private var mockRepositories: [Repository] {
        (1...10).enumerated().map { index, _ in
            Repository(
                id: index,
                name: "repository\(index)",
                owner: "owner\(index)",
                ownerAvatarURL: nil,
                ownerLinkURL: URL(string: "https://github.com/owner\(index)")!,
                linkURL: URL(string: "https://github.com/owner\(index)/repository\(index)")!,
                description: "This is github repository",
                license: "WTFPL",
                starCount: 100
            )
        }
    }

    override func spec() {
        describe("MainViewModel") {
            var viewModel: MainViewModel!
            var getGitHubRepositoriesUsecase: GetGitHubRepositoriesUsecaseMock!
            beforeEach {
                getGitHubRepositoriesUsecase = .init()
                viewModel = .init(getGitHubRepositoriesUsecase: getGitHubRepositoriesUsecase)
            }

            context("빈 검색어가 Submit되면") {
                beforeEach {
                    viewModel.query = "     \n    "
                    viewModel.submitSearch()
                }
                it("GitHub 저장소 검색 Usecase가 실행되지 않아야 한다") {
                    Verify(getGitHubRepositoriesUsecase, 0, .execute(query: .any))
                }
            }

            context("검색어가 Submit되면 (성공시+결과있음)") {
                let searchQuery = "Moya"
                var dataSourceRecorder: Recorder<[Repository], Never>!
                var errorRecorder: Recorder<Error?, Never>!
                var isLoadingRecorder: Recorder<Bool, Never>!
                beforeEach {
                    Given(
                        getGitHubRepositoriesUsecase,
                        .execute(
                            query: .value(searchQuery),
                            willReturn: Just(self.mockRepositories)
                                .setFailureType(to: Error.self)
                                .eraseToAnyPublisher()
                        )
                    )
                    dataSourceRecorder = viewModel.$repositories.dropFirst().record()
                    errorRecorder = viewModel.$error.dropFirst().record()
                    isLoadingRecorder = viewModel.$isLoading.dropFirst().record()
                    viewModel.query = searchQuery
                    viewModel.submitSearch()
                }

                it("GitHub 저장소 검색 Usecase가 실행되어야 한다") {
                    Verify(getGitHubRepositoriesUsecase, .execute(query: .value(searchQuery)))
                }
                it("데이터소스는 빈리스트로 초기화 되었다가 usecase 로 부터 전달받은 값으로 값이 설정되어야 한다") {
                    expect { try dataSourceRecorder.next().get() }.to(beEmpty())
                    expect { try dataSourceRecorder.next().get() }.to(equal(self.mockRepositories))
                }
                it("error는 nil 초기화되어야 한다") {
                    expect { try errorRecorder.next().get() }.to(beNil())
                }
                it("isLoading 은 true 값으로 설정되었다가 false 값으로 다시 설정되어야 한다") {
                    expect { try isLoadingRecorder.next().get() }.to(beTrue())
                    expect { try isLoadingRecorder.next().get() }.to(beFalse())
                }
            }

            context("검색어가 Submit되면 (성공시+결과없음)") {
                let searchQuery = "Moya"
                var errorRecorder: Recorder<Error?, Never>!
                beforeEach {
                    Given(
                        getGitHubRepositoriesUsecase,
                        .execute(
                            query: .value(searchQuery),
                            willReturn: Just([])
                                .setFailureType(to: Error.self)
                                .eraseToAnyPublisher()
                        )
                    )
                    errorRecorder = viewModel.$error.dropFirst().record()
                    viewModel.query = searchQuery
                    viewModel.submitSearch()
                }

                it("error는 nil 초기화되었다가, notFound error 가 설정되어야 한다") {
                    expect { try errorRecorder.next().get() }.to(beNil())
                    expect { try errorRecorder.next().get() as? MainViewModel.Errors }.to(equal(MainViewModel.Errors.notFound))
                }
            }

            context("검색어가 Submit되면 (실패시)") {
                let searchQuery = "Moya"
                var dataSourceRecorder: Recorder<[Repository], Never>!
                var errorRecorder: Recorder<Error?, Never>!
                var isLoadingRecorder: Recorder<Bool, Never>!
                beforeEach {
                    Given(
                        getGitHubRepositoriesUsecase,
                        .execute(
                            query: .value(searchQuery),
                            willReturn: Fail(error: NSError(domain: "error occured", code: -1, userInfo: nil))
                                .eraseToAnyPublisher()
                        )
                    )
                    dataSourceRecorder = viewModel.$repositories.dropFirst().record()
                    errorRecorder = viewModel.$error.dropFirst().record()
                    isLoadingRecorder = viewModel.$isLoading.dropFirst().record()
                    viewModel.query = searchQuery
                    viewModel.submitSearch()
                }

                it("GitHub 저장소 검색 Usecase가 실행되어야 한다") {
                    Verify(getGitHubRepositoriesUsecase, .execute(query: .value(searchQuery)))
                }
                it("데이터소스는 빈리스트로 초기화 되고 다른 값이 설정되지 않아야 한다") {
                    expect { try dataSourceRecorder.next().get() }.to(beEmpty())
                    expect { try dataSourceRecorder.next().get() }.to(throwError())
                }
                it("error는 nil 초기화되었다가 error 가 설정되어야한다") {
                    expect { try errorRecorder.next().get() }.to(beNil())
                    expect { try errorRecorder.next().get() }.toNot(beNil())
                }
                it("isLoading 은 true 값으로 설정되었다가 false 값으로 다시 설정되어야 한다") {
                    expect { try isLoadingRecorder.next().get() }.to(beTrue())
                    expect { try isLoadingRecorder.next().get() }.to(beFalse())
                }
            }
        }
    }
}
