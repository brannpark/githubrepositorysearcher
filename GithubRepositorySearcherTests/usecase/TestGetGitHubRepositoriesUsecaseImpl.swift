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
        GitHubRepoDto(
            total_count: 1,
            items: [
                GitHubRepoDto.GitHubRepoItemDto(
                    id: 1,
                    name: "TestRepository",
                    owner: GitHubRepoDto.GitHubRepoOwnerDto(
                        login: "Tester",
                        avatar_url: "https://avatars.githubusercontent.com/u/0000000?v=4",
                        html_url: "https://github.com/tester"
                    ),
                    html_url: "https://github.com/tester/test-repository",
                    description: "테스트 프로젝트 저장소",
                    license: GitHubRepoDto.GitHubRepoLicenseDto(
                        spdx_id: "WTFPL"
                    ),
                    stargazers_count: 100
                )
            ]
        )
    }

    override func spec() {
        describe("GetGitHubRepositoriesUsecaseImpl") {
            var repository: GitHubRepositoryMock!
            var usecase: GetGitHubRepositoriesUsecaseImpl!
            beforeEach {
                repository = .init()
                usecase = .init(repository: repository)
            }

            context("실행되면") {
                var recorder: Recorder<[Repository], Error>!
                beforeEach {
                    Given(
                        repository,
                            .getRepositories(
                                query: .any,
                                willReturn: Just(self.mockGitHubRepoDto).setFailureType(to: Error.self).eraseToAnyPublisher()
                            )
                    )
                    recorder = usecase.execute(query: "Moya").record()

                }
                it("GitHubRepository 의 getRepositories 가 호출되어야 한다") {
                    Verify(repository, .getRepositories(query: .any))
                }
                it("Repository 목록을 반환해야 한다") {
                    let result = try recorder.next().get()
                    expect(result).toNot(beEmpty())
                }
                it("데이터들이 정상적으로 변환되어 제공되어야 한다") {
                    let result = try recorder.next().get()
                    let repository = result.first!
                    let expected = self.mockGitHubRepoDto.items.first!
                    expect(repository.id).to(equal(expected.id))
                    expect(repository.name).to(equal(expected.name))
                    expect(repository.owner).to(equal(expected.owner.login))
                    expect(repository.ownerAvatarURL?.absoluteString).to(equal(expected.owner.avatar_url))
                    expect(repository.ownerLinkURL.absoluteString).to(equal(expected.owner.html_url))
                    expect(repository.linkURL.absoluteString).to(equal(expected.html_url))
                    expect(repository.description).to(equal(expected.description))
                    expect(repository.license).to(equal(expected.license?.spdx_id))
                    expect(repository.starCount).to(equal(expected.stargazers_count))
                }
            }
        }
    }
}
