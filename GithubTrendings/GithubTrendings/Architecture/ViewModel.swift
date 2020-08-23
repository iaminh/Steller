//

import Foundation
import RxSwift

class ViewModel {
    struct ViewLifeCycle {
        let didLoadSubject = PublishSubject<Void>()
        let didAppearSubject = PublishSubject<Void>()
        let didDisappearSubject = PublishSubject<Void>()
        let willAppearSubject = PublishSubject<Void>()
        let willDisappearSubject = PublishSubject<Void>()
    }

    enum LoadingState {
        case loading
        case finished
    }

    let loadingState = BehaviorSubject<LoadingState>(value: .finished)
    let bag = DisposeBag()
    let lifeCycle = ViewLifeCycle()
}

// MARK: Input
class Inputs<Base>: ReactiveCompatible {
    public let vm: Base
    public init(_ vm: Base) {
        self.vm = vm
    }
}

protocol InputCompatible {
    associatedtype InputCompatibleType: ViewModel
    var `in`: Inputs<InputCompatibleType> { get }
}

extension ViewModel: InputCompatible {
    typealias InputCompatibleType = ViewModel
}

extension InputCompatible where Self: ViewModel {
    var `in`: Inputs<Self> { return Inputs(self) }
}

// MARK: Output

class Outputs<Base>: ReactiveCompatible {
    let vm: Base
    init(_ vm: Base) {
        self.vm = vm
    }
}

protocol OutputCompatible {
    associatedtype OutputCompatibleType
    var out: Outputs<OutputCompatibleType> { get }

}
extension OutputCompatible {
    var out: Outputs<Self> { return Outputs(self) }
}

extension ViewModel: OutputCompatible {
    typealias OutputCompatibleType = ViewModel
}
