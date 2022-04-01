//
//  InjectedStateObject.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import SwiftUI
import Resolver

@propertyWrapper struct InjectedStateObject<Service>: DynamicProperty where Service: ObservableObject {

    @StateObject private var service: Service

    init(_ initializer: ((Service) -> Void)? = nil) {
        let service = Resolver.main.resolve(Service.self)
        initializer?(service)
        _service = StateObject(wrappedValue: service)
    }

    init(name: Resolver.Name? = nil, container: Resolver? = nil, initializer: ((Service) -> Void)? = nil) {
        let service = container?.resolve(Service.self, name: name) ?? Resolver.main.resolve(Service.self, name: name)
        initializer?(service)
        _service = StateObject(wrappedValue: service)
    }

    var wrappedValue: Service {
        service
    }

    var projectedValue: ObservedObject<Service>.Wrapper {
        return $service
    }
}
