//
//  Routable.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import Foundation
import SwiftUI

protocol RoutableViewModel {

    associatedtype Routing
    var router: PassthroughRelay<Routing> { get }
}

protocol RoutableView: View {

    associatedtype Content: View
    associatedtype ViewModel: RoutableViewModel

    var viewModel: ViewModel { get }
    @ViewBuilder var content: Content { get }

    func handleRouting(_ routing: ViewModel.Routing)
}

extension RoutableView {

    var body: some View {
        content.onReceive(viewModel.router) { routing in
            handleRouting(routing)
        }
    }
}
