//
//  Repository.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import Foundation

struct Repository {

    let id: Int
    let name: String
    let owner: String
    let ownerAvatarURL: URL?
    let ownerLinkURL: URL
    let linkURL: URL
    let description: String
    let license: String
    let starCount: Int
}
