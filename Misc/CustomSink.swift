import Combine

extension Publishers {
    public final class CustomSink<Input, Failure: Error> {
        // MARK: - Properties
        public let combineIdentifier = CombineIdentifier()

        private let initialDemand: Subscribers.Demand

        private let receiveValue: (Input) -> Void
        private let receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?

        private var subscription: Subscription? = nil

        // MARK: - Initializers
        init(initialDemand: Subscribers.Demand = .unlimited,
             receiveValue: @escaping (Input) -> Void,
             receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil)
        {
            self.initialDemand = initialDemand
            self.receiveValue = receiveValue
            self.receiveCompletion = receiveCompletion
        }
    }
}

// MARK: - Subscriber protocol
extension Publishers.CustomSink: Subscriber {
    public func receive(subscription: Subscription) {
        self.subscription = subscription
        if initialDemand > .none {
            subscription.request(initialDemand)
        }
    }

    public func receive(_ input: Input) -> Subscribers.Demand {
        receiveValue(input)
        return .none
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion?(completion)
        subscription = nil
    }
}

// MARK: - Cancellable protocol
extension Publishers.CustomSink: Cancellable {
    public func cancel() {
        subscription?.cancel()
        subscription = nil
    }
}

// MARK: - Convenience
public extension Publisher {
    func customSink(
        initialDemand: Subscribers.Demand = .unlimited,
        receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
        receiveValue: @escaping ((Output) -> Void))
        -> Cancellable
    {
        let sink = Publishers.CustomSink(
            initialDemand: initialDemand,
            receiveValue: receiveValue,
            receiveCompletion: receiveCompletion)
        self.subscribe(sink)
        return sink
    }
}
