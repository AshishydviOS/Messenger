//
//  LogManager.swift
//  Messenger
//
//  Created by Ashish Yadav on 14/11/20.
//

import Foundation
import CocoaLumberjack

class LogManager{
    
    fileprivate var fileLogger: DDFileLogger!

    static let sharedInstance = LogManager()
    fileprivate init(){}
    
    func initLogger(){
        DDLog.add(DDOSLogger.sharedInstance)    //Deprecate in ios 10.0 : - DDASLLogger.sharedInstance
        if let dDTTYLogger = DDTTYLogger.sharedInstance {
            DDLog.add(dDTTYLogger)
        }
        fileLogger = DDFileLogger()
        fileLogger.maximumFileSize = AppConstants.LOGGER_MAX_SIZE // 10 MB
        fileLogger.rollingFrequency = AppConstants.LOGGER_ROLLING_FREQ // 30 days
        fileLogger.logFileManager.maximumNumberOfLogFiles = AppConstants.LOGGER_MAX_FILES
        DDLog.add(fileLogger)
    }
    
    //MARK: Logging Methods
    
    func logVerbose(_ className:String, methodName:String, logMessage:String){
        DDLogVerbose("verbose,\(className),\(methodName),\(logMessage)")
    }
    
    func logInfo(_ className:String, methodName:String, logMessage:String){
        DDLogInfo("info,\(className),\(methodName),\(logMessage)")
    }
    func logWarning(_ className:String, methodName:String, logMessage:String){
        DDLogWarn("warn,\(className),\(methodName),\(logMessage)")
    }
    
    func logError(_ className:String, methodName:String, logMessage:String){
        DDLogError("error,\(className),\(methodName),\(logMessage)")
    }
}
