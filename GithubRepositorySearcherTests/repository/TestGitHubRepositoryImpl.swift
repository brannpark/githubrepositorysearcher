//
//  TestGitHubRepositoryImpl.swift
//  GithubRepositorySearcherTests
//
//  Created by brann on 2022/04/01.
//

import Quick
import Nimble
import CombineExpectations
import Moya
@testable import GithubRepositorySearcher

class TestGitHubRepositoryImpl: QuickSpec {

    private let provider = MoyaProvider<GitHubAPI>(
        plugins: []
//            NetworkLoggerPlugin(
//                configuration: NetworkLoggerPlugin.Configuration(
//                    logOptions: .verbose
//                )
//            )
//        ]
    )

    override func spec() {
        describe("GitHubRepositoryImpl") {
            var repository: GitHubRepositoryImpl!
            beforeEach {
                repository = .init(provider: self.provider)
            }
            context("Moya 키워드로 저장소 검색 시") {
                var recorder: Recorder<GitHubRepoDto, Error>!
                beforeEach {
                    recorder = repository.getRepositories(query: "Moya").record()
                }
                it("Moya 저장소 관련 데이터 목록이 하나 이상 반환되어야 한다") {
                    do {
                        let dto = try self.wait(for: recorder.next(), timeout: 3)
                        expect(dto.items.count).to(beGreaterThan(0))
                    } catch {
                        print(error)
                    }
                }
                it("데이터에 필수 정보들이 포함되어있어야 한다") {
                    let dto = try self.wait(for: recorder.next(), timeout: 3)
                    let repository = dto.items.first!
                    expect(repository.id).to(beGreaterThan(0))
                    expect(repository.name).toNot(beEmpty())
                    expect(repository.owner.login).toNot(beEmpty())
                    expect(repository.owner.avatar_url).toNot(beEmpty())
                    expect(repository.owner.html_url).toNot(beEmpty())
                    expect(repository.html_url).toNot(beEmpty())
                    expect(repository.description).toNot(beEmpty())
                    expect(repository.license?.spdx_id).toNot(beEmpty())
                    expect(repository.stargazers_count).to(beGreaterThanOrEqualTo(0))
                }
            }
        }
    }
}
