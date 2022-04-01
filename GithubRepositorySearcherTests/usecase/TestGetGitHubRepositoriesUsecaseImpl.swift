//
//  TestGetGitHubRepositoriesUsecaseImpl.swift
//  GithubRepositorySearcherTests
//
//  Created by brann on 2022/04/01.
//

import Quick
import Nimble
import CombineExpectations
import Combine
import SwiftyMocky
@testable import GithubRepositorySearcher

class TestGetGitHubRepositoriesUsecaseImpl: QuickSpec {

    private var mockGitHubRepoDto: GitHubRepoDto {
        GitHubRepoDto()
    }

    override func spec() {
        describe("GetGitHubRepositoriesUsecaseImpl") {
            var repository: GitHubRepositoryMock!
            var usecase: GetGitHubRepositoriesUsecaseImpl!
            beforeEach {
                repository = .init()
                usecase = .init()
            }

            context("실행되면") {
                var recorder: Recorder<[Repository], Error>!
                var result: [Repository]!
                beforeEach {
                    Given(
                        repository,
                            .getRepositories(
                                query: .any,
                                willReturn: Just(self.mockGitHubRepoDto).setFailureType(to: Error.self).eraseToAnyPublisher()
                            )
                    )
                    recorder = usecase.execute(query: "Moya").record()
                    result = try recorder.next().get()
                }
                it("GitHubRepository 의 getRepositories 가 호출되어야 한다") {
                    Verify(repository, .getRepositories(query: .any))
                }
                it("Repository 목록을 반환해야 한다") {
                    expect(result).toNot(beEmpty())
                }
                it("데이터들이 정상적으로 변환되어 제공되어야 한다") {
                    let repository = result.first!
                    expect(repository.id).toNot(beEmpty())
                    expect(repository.name).toNot(beEmpty())
                    expect(repository.owner).toNot(beEmpty())
                    expect(repository.ownerAvatarURL.absoluteString).toNot(beEmpty())
                    expect(repository.ownerLinkURL.absoluteString).toNot(beEmpty())
                    expect(repository.linkURL.absoluteString).toNot(beEmpty())
                    expect(repository.description).toNot(beEmpty())
                    expect(repository.license).toNot(beEmpty())
                }
            }
        }
    }
}
