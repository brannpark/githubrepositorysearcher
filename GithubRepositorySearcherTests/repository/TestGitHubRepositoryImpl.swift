//
//  TestGitHubRepositoryImpl.swift
//  GithubRepositorySearcherTests
//
//  Created by brann on 2022/04/01.
//

import Quick
import Nimble
import CombineExpectations
@testable import GithubRepositorySearcher

class TestGitHubRepositoryImpl: QuickSpec {

    override func spec() {
        describe("GitHubRepositoryImpl") {
            var repository: GitHubRepositoryMock!
            beforeEach {
                repository = .init()
            }
            context("Moya 키워드로 저장소 검색 시") {
                var recorder: Recorder<GitHubRepoDto, Error>!
                var dto: GitHubRepoDto!
                beforeEach {
                    recorder = repository.getRepositories(query: "Moya").record()
                    dto = try self.wait(for: recorder.next(), timeout: 10)
                }
                it("Moya 저장소 관련 데이터 목록이 하나 이상 반환되어야 한다") {
                    expect(dto.items.count).to(beGreaterThan(0))
                }
                it("데이터에 필수 정보들이 포함되어있어야 한다") {
                    let repository = dto.items.first!
                    expect(repository.id).toNot(beEmpty())
                    expect(repository.name).toNot(beEmpty())
                    expect(repository.owner.login).toNot(beEmpty())
                    expect(repository.owner.avatar_url).toNot(beEmpty())
                    expect(repository.owner.html_url).toNot(beEmpty())
                    expect(repository.html_url).toNot(beEmpty())
                    expect(repository.description).toNot(beEmpty())
                    expect(repository.license.spdx_id).toNot(beEmpty())
                }
            }
        }
    }
}
