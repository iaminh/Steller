//
//  GithubDetailVM.swift
//  GithubTrendings
//
//  Created by Chu Anh Minh on 8/23/20.
//  Copyright © 2020 MinhChu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class StoryDetailVM: ViewModel {
    fileprivate let story: Story
    init(story: Story) {
        self.story = story
        super.init()
    }
}

extension Outputs where Base == StoryDetailVM {
    var title: String { return  vm.story.user.displayName }
    var description: String { return "Some text from: \(vm.story.user.displayName)" }
    var imageURL: String { return vm.story.coverSrc }
}
