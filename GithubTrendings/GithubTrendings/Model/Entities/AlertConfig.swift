//
//  AlertConfig.swift
//
//  Created by Chu Anh Minh on 3/5/19.
//

import Foundation

struct AlertConfig {
    enum Style {
        case systemAlert
        case actionSheet
    }

    struct Action {
        enum Style {
            case `default`
            case cancel
            case yellow
        }
        let title: String
        let handler: (() -> Void)?
        let style: Style

        init(style: Style = .default, title: String, handler: (() -> Void)? = nil) {
            self.title = title
            self.handler = handler
            self.style = style
        }
    }

    let title: String?
    let message: String?
    let style: Style
    let actions: [Action]

    init(style: Style = .systemAlert,
         title: String,
         message: String? = nil,
         actions: [Action] = [Action(title: "OK".localized)]) {
        self.title = title
        self.message = message
        self.actions = actions
        self.style = style
    }
}
