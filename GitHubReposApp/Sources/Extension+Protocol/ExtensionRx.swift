import RxCocoa
import RxSwift

// MARK: - UIViewController
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

// MARK: - Eventの分岐メソッドextension
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

// MARK: UIScrollView
extension Reactive where Base: UIScrollView {
    var reachedBottom: ControlEvent<Void> {
        let observable = contentOffset
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let scrollView = base else { return Observable.empty() }
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                
                return y > threshold ? Observable.just(()) : Observable.empty()
            }
        
        return ControlEvent(events: observable)
    }
}
