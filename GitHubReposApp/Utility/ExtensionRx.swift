import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
    var viewWillAppear: Driver<Void> {
        return sentMessage(#selector(base.viewWillAppear(_:)))
            .map { _ in () }
            .asDriver(onErrorDriveWith: .empty())
    }
    
    var viewDidAppear: Driver<Void> {
        return sentMessage(#selector(base.viewDidAppear(_:)))
            .map { _ in () }
            .asDriver(onErrorDriveWith: .empty())
        
    }
    
    var viewWillDisappear: Driver<Void> {
        return sentMessage(#selector(base.viewWillDisappear(_:)))
            .map { _ in () }
            .asDriver(onErrorDriveWith: .empty())
    }
    
    var viewDidDisappear: Driver<Void> {
        return sentMessage(#selector(base.viewDidDisappear(_:)))
            .map { _ in () }
            .asDriver(onErrorDriveWith: .empty())
    }
}

//Eventの分岐メソッドextension
extension ObservableType where Element: EventConvertible {
    public func elements() -> Observable<Element.Element> {
        return filter { $0.event.element != nil }
            .map { $0.event.element! }
    }
    
    public func errors() -> Observable<Swift.Error> {
        return filter { $0.event.error != nil }
            .map { $0.event.error! }
    }
}
