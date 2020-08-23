//
//  Configuration.swift
//  TVShow
//
//  Created by Chu Anh Minh on 5/27/19.
//  Copyright © 2019 MinhChu. All rights reserved.
//

import Foundation

struct Configuration {
    static var debug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    static var build: String {
        if let buildString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return buildString
        }
        return ""
    }

    static var version: String {
        if let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return versionString
        }
        return ""
    }
    
    static var appName: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return name
        }
        return ""
    }
    
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
