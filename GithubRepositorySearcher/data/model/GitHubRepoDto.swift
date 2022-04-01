//
//  GitHubRepoDto.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//
// swiftlint:disable identifier_name
import Foundation

struct GitHubRepoDto: Decodable {

    let total_count: Int
    let items: [GitHubRepoItemDto]

}

extension GitHubRepoDto {

    struct GitHubRepoItemDto: Decodable {

        let id: Int
        let name: String
        let owner: GitHubRepoOwnerDto
        let html_url: String
        let description: String?
        let license: GitHubRepoLicenseDto?
        let stargazers_count: Int
    }

    struct GitHubRepoOwnerDto: Decodable {

        let login: String
        let avatar_url: String?
        let html_url: String
    }

    struct GitHubRepoLicenseDto: Decodable {

        let spdx_id: String
    }
}
