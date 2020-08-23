//
//  Controller.swift
//  HomeCredit

import UIKit
import RxSwift
import RxCocoa

class Controller<VM: ViewModel>: BaseViewController {
    public let vm: VM

    init(viewModel: VM) {
        self.vm = viewModel
        super.init(nibName: NSStringFromClass(type(of: self))
            .components(separatedBy: ".").last, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindToVM()
    }

    override func viewWillAppear(_ animated: Bool) {
        vm.lifeCycle.willAppearSubject.onNext(())
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        vm.lifeCycle.didAppearSubject.onNext(())
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        vm.lifeCycle.willDisappearSubject.onNext(())
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        vm.lifeCycle.didDisappearSubject.onNext(())
        super.viewDidDisappear(animated)
    }

    func bindToVM() {
        vm.loadingState
            .map { $0 == .loading }
            .bind(to: showLoading)
            .disposed(by: bag)
    }
}
