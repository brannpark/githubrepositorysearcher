//
//  MainView.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import SwiftUI
import Combine
import Resolver

struct MainView: RoutableView {

    @InjectedStateObject var viewModel: MainViewModel
    @Environment(\.openURL) var openURL
    @State private var query = ""

    var content: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                headerView(safeAreaInsetTop: proxy.safeAreaInsets.top)
                listView
            }
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                viewModel.isLoading ? AnyView(ProgressView()) : AnyView(EmptyView()),
                alignment: .center
            )
        }
        .onAppear {
            query = "Moya"
            viewModel.submit(searchQuery: query)
        }
    }

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.repositories.enumerated()), id: \.offset) { _, repo in
                    listRow(item: repo)
                    Color.gray.opacity(0.5).frame(height: 1)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func listRow(item: Repository) -> some View {
        Button {
            viewModel.didTap(item: item)
        } label: {
            HStack {
                AsyncImage(
                    url: item.ownerAvatarURL,
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .transition(.opacity.animation(.linear(duration: 0.3)))
                    },
                    placeholder: {
                        Color.gray.opacity(0.3)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                )
                VStack(spacing: 5) {
                    HStack {
                        Text("\(item.owner)/\(item.name)")
                            .foregroundColor(Color.black)
                            .fontWeight(.bold)
                            .underline()
                            .multilineTextAlignment(.leading)
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.yellow)
                            .offset(x: 5, y: 0)
                        Text(String(item.starCount))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(item.description)
                        .foregroundColor(Color.black.opacity(0.7))
                        .font(.system(size: 13))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer(minLength: 10)
                Text(item.license)
                    .foregroundColor(Color.black.opacity(0.7))
                    .font(.system(size: 13))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    private func headerView(safeAreaInsetTop: CGFloat) -> some View {
        VStack(spacing: 0.1) {
            Spacer(minLength: 0).frame(height: safeAreaInsetTop)
            TextField("GitHub 저장소 검색", text: $query)
                .onSubmit {
                    viewModel.submit(searchQuery: query)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
        }
        .background(Color(red: 0.165, green: 0.757, blue: 0.737))
    }
}

extension MainView {

    func handleRouting(_ routing: MainViewModel.Routing) {
        switch routing {
        case .toWebScene(let url):
            openURL(url)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
