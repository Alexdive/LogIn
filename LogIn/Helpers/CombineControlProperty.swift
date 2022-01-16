//
//  CombineControlProperty.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 09.12.2021.
//

import UIKit
import Combine

// source https://github.com/CombineCommunity/CombineCocoa/blob/f35362b30713a0f717106e45cd7e1b71d024c37e/Sources/CombineCocoa/CombineControlProperty.swift

// MARK: - Publisher
extension Combine.Publishers {
    /// A Control Property is a publisher that emits the value at the provided keypath
    /// whenever the specific control events are triggered. It also emits the keypath's
    /// initial value upon subscription.
    struct ControlProperty<Control: UIControl, Value>: Publisher {
        public typealias Output = Value
        public typealias Failure = Never
        
        private let control: Control
        private let controlEvents: Control.Event
        private let keyPath: KeyPath<Control, Value>
        
        /// Initialize a publisher that emits the value at the specified keypath
        /// whenever any of the provided Control Events trigger.
        ///
        /// - parameter control: UI Control.
        /// - parameter events: Control Events.
        /// - parameter keyPath: A Key Path from the UI Control to the requested value.
        public init(control: Control,
                    events: Control.Event,
                    keyPath: KeyPath<Control, Value>) {
            self.control = control
            self.controlEvents = events
            self.keyPath = keyPath
        }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            control: control,
                                            event: controlEvents,
                                            keyPath: keyPath)
            
            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: - Subscription
extension Combine.Publishers.ControlProperty {
    private final class Subscription<S: Subscriber, Control: UIControl, Value>: Combine.Subscription where S.Input == Value {
        private var subscriber: S?
        weak private var control: Control?
        let keyPath: KeyPath<Control, Value>
        private var didEmitInitial = false
        private let event: Control.Event
        
        init(subscriber: S, control: Control, event: Control.Event, keyPath: KeyPath<Control, Value>) {
            self.subscriber = subscriber
            self.control = control
            self.keyPath = keyPath
            self.event = event
            control.addTarget(self, action: #selector(handleEvent), for: event)
        }
        
        func request(_ demand: Subscribers.Demand) {
            // Emit initial value upon first demand request
            if !didEmitInitial,
               demand > .none,
               let control = control,
               let subscriber = subscriber {
                _ = subscriber.receive(control[keyPath: keyPath])
                didEmitInitial = true
            }
            
            // We don't care about the demand at this point.
            // As far as we're concerned - UIControl events are endless until the control is deallocated.
        }
        
        func cancel() {
            control?.removeTarget(self, action: #selector(handleEvent), for: event)
            subscriber = nil
        }
        
        @objc private func handleEvent() {
            guard let control = control else { return }
            _ = subscriber?.receive(control[keyPath: keyPath])
        }
    }
}

extension UIControl.Event {
    static var defaultValueEvents: UIControl.Event {
        return [.allEditingEvents, .valueChanged]
    }
}

extension UIControl {
    class InteractionSubscription<S: Subscriber>: Subscription
    where S.Input == Void {
        
        private let subscriber: S?
        private let control: UIControl
        private let event: UIControl.Event
        
        init(subscriber: S,
             control: UIControl,
             event: UIControl.Event) {
            
            self.subscriber = subscriber
            self.control = control
            self.event = event
            
            self.control.addTarget(self, action: #selector(handleEvent), for: event)
        }
        
        @objc func handleEvent(_ sender: UIControl) {
            _ = self.subscriber?.receive(())
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {}
    }
    
    struct InteractionPublisher: Publisher {
        typealias Output = Void
        typealias Failure = Never
        
        private let control: UIControl
        private let event: UIControl.Event
        
        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Void == S.Input {
            
            let subscription = InteractionSubscription(
                subscriber: subscriber,
                control: control,
                event: event
            )
            subscriber.receive(subscription: subscription)
        }
    }
    
    func publisher(for event: UIControl.Event) -> AnyPublisher<Void, Never> {
        return InteractionPublisher(control: self, event: event).eraseToAnyPublisher()
    }
}
