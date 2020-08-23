import Foundation

let log: LogService = {
    let logService = LogService.sharedService
    logService.logLevel = Configuration.debug ? .debug : .production
    return logService
}()

typealias ExternalLogAction = (_ text: String) -> Void

class LogService {
    static let sharedService = LogService()

    enum GeneralLogLevel {
        case debug
        case production
        case productionWithCrashlogs
    }

    // We use this because of nice readable syntax :
    //  log.message("Test remote")(.RemoteLogging)
    //  log.message("Text local")

    enum ExternalLogActions {
        case remoteLogging
        case none
    }

    var crashLogAction: ExternalLogAction?
    var messageLogAction: ExternalLogAction?
    var errorLogAction: ExternalLogAction?

    var logLevel: GeneralLogLevel = .debug

    typealias Message = (String) -> String

    @discardableResult
    func message(_ text: String) -> ((ExternalLogActions) -> Void)! {
        let message = detailedMessage()

        if logLevel == .debug { print(message(text)) }
        if logLevel == .productionWithCrashlogs { crashLogAction?(message(text)) }

        return { externalLogAction -> Void in
            if externalLogAction == .remoteLogging { self.messageLogAction?(message(text)) }
        }
    }

    private func detailedMessage() -> Message {
        return { text -> String in
            let messageText = "\n" + "Logger [\(Date().toDayTimeString())]: " + text
            return messageText
        }
    }

    func simplePrint(_ separator: String, terminator: String, item: Any) {
        if logLevel == .debug { print(item, separator: separator, terminator: terminator) }
    }
}
