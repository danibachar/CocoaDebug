//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit
import Darwin

func exceptionHandler(exception: NSException) {
    if _CrashLogger.shared.crashed {
        return
    }
    _CrashLogger.shared.crashed = true
    _CrashLogger.addCrash(name: exception.name.rawValue, reason: exception.reason)
}

func handleSignal(signal: Int32) {
    if _CrashLogger.shared.crashed {
        return
    }
    _CrashLogger.shared.crashed = true
    switch signal {
    case SIGILL:
        _CrashLogger.addCrash(name: "SIGILL", reason: nil)
    case SIGABRT:
        _CrashLogger.addCrash(name: "SIGABRT", reason: nil)
    case SIGFPE:
        _CrashLogger.addCrash(name: "SIGFPE", reason: nil)
    case SIGBUS:
        _CrashLogger.addCrash(name: "SIGBUS", reason: nil)
    case SIGSEGV:
        _CrashLogger.addCrash(name: "SIGSEGV", reason: nil)
    case SIGSYS:
        _CrashLogger.addCrash(name: "SIGSYS", reason: nil)
    case SIGPIPE:
        _CrashLogger.addCrash(name: "SIGPIPE", reason: nil)
    case SIGTRAP:
        _CrashLogger.addCrash(name: "SIGTRAP", reason: nil)
    default: break
    }
}

class _CrashLogger {

    static let shared = _CrashLogger()
    private init() {}
    
    var crashed = false
    var enable: Bool = false {
        didSet {
            if enable {
                _CrashLogger.register()
            }
            else {
                _CrashLogger.unregister()
            }
        }
    }

    static func register() {
        NSSetUncaughtExceptionHandler(exceptionHandler)
        signal(SIGILL, handleSignal)
        signal(SIGABRT, handleSignal)
        signal(SIGFPE, handleSignal)
        signal(SIGBUS, handleSignal)
        signal(SIGSEGV, handleSignal)
        signal(SIGSYS, handleSignal)
        signal(SIGPIPE, handleSignal)
        signal(SIGTRAP, handleSignal)
    }

    static func unregister() {
        NSSetUncaughtExceptionHandler(nil)
        signal(SIGILL, SIG_DFL)
        signal(SIGABRT, SIG_DFL)
        signal(SIGFPE, SIG_DFL)
        signal(SIGBUS, SIG_DFL)
        signal(SIGSEGV, SIG_DFL)
        signal(SIGSYS, SIG_DFL)
        signal(SIGPIPE, SIG_DFL)
        signal(SIGTRAP, SIG_DFL)
    }

    static func addCrash(name: String, reason: String?) {
        let newCrash = _CrashModel(name: name, reason: reason)
        _CrashStoreManager.shared.addCrash(newCrash)
    }
}