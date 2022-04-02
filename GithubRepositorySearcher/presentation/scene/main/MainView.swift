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

    var content: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                headerView(safeAreaInsetTop: proxy.safeAreaInsets.top)
                if let error = viewModel.error {
                    errorView(for: error)
                } else {
                    listView
                }
            }
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                viewModel.isLoading ? AnyView(ProgressView()) : AnyView(EmptyView()),
                alignment: .center
            )
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var listView: some View {
        List {
            ForEach(Array(viewModel.repositories.enumerated()), id: \.offset) { _, repo in
                listRow(for: repo)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .background(Color.white)
            .overlay(Color.gray.opacity(0.4).frame(maxWidth: .infinity, maxHeight: 1), alignment: .bottom)
        }
        .listStyle(PlainListStyle())
        .environment(\.defaultMinListRowHeight, 0)
        .environment(\.defaultMinListHeaderHeight, 0)
    }

    private func errorView(for error: Error) -> some View {
        ZStack {
            switch error {
            case MainViewModel.Errors.notFound:
                Text("저장소를 찾을 수 없습니다.")
            default:
                Text("일시적인 오류입니다.\n다시 시도해주세요.")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func ownerImage(for item: Repository) -> some View {
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
        ).onTapGesture {
            viewModel.didTapOwner(item: item)
        }
    }

    private func listRow(for item: Repository) -> some View {
        Button {
            viewModel.didTapRow(item: item)
        } label: {
            HStack {
                ownerImage(for: item)
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
        .buttonStyle(ButtonPressedStyle())
    }

    private func headerView(safeAreaInsetTop: CGFloat) -> some View {
        VStack(spacing: 0.1) {
            Spacer(minLength: 0).frame(height: safeAreaInsetTop)
            TextField("GitHub 저장소 검색", text: $viewModel.query)
                .onSubmit {
                    viewModel.submitSearch()
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
