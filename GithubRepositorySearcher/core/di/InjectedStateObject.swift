//
//  InjectedStateObject.swift
//  GithubRepositorySearcher
//
//  Created by brann on 2022/04/01.
//

import Resolver
import SwiftUI
import Combine

@propertyWrapper
public struct InjectedStateObject<ObjectType>: DynamicProperty where ObjectType: ObservableObject {

    var initializer: ((ObjectType) -> Void)?
    @State private var box = RestorableBox()

    private final class RestorableBox {

        var object: ObjectType?
    }

    private final class MessageForwarder: ObservableObject {

        let objectWillChange = ObservableObjectPublisher()
        var subscription: AnyCancellable?
        var object: ObjectType? {
            didSet {
                // Subscribe to the object only if needed.
                if let object = object, object !== oldValue {
                    subscription = object.objectWillChange.sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
                }
            }
        }
    }

    @ObservedObject private var messageForwarder = MessageForwarder()

    public var wrappedValue: ObjectType {
        if let object = messageForwarder.object {
            return object
        } else {
            fatalError(
          """
          BUG: This should never happen as `update` is guaranteed to mutate \
          before you're allowed to access `wrappedValue` property.
          """
            )
        }
    }

    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        if let object = messageForwarder.object {
            let wrapper = ObservedObject(wrappedValue: object)
            return wrapper.projectedValue
        } else {
            fatalError(
        """
        BUG: This should never happen as `update` is guaranteed to mutate \
        before you're allowed to access `projectedValue` property.
        """
            )
        }
    }

    public init() {}

    public init(_ initializer: @escaping (ObjectType) -> Void) {
        self.initializer = initializer
    }

    public func update() {
        // This mutation should only happen once for the lifetime of the view.
        if box.object == nil {
            let obj = Resolver.main.resolve(ObjectType.self)
            initializer?(obj)
            box.object = obj
        }
        // Re-inject the object into the message forwarder.
        if let object = box.object {
            messageForwarder.object = object
        }
    }
}
