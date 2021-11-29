import Flutter
import UIKit
import firebase_core

import FirebaseInstallations

public class SwiftFirebaseInstallationsPlugin: FLTFirebasePlugin, FlutterPlugin {
    
    var channel:String?;
    
    init(channelName:String) {
        channel = channelName;
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channelName = "plugins.flutter.io/firebase_installations";
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftFirebaseInstallationsPlugin(channelName: channelName)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    /// Get Installations instance for a Firebase App.
    /// - Parameter arguments: the arguments passed by the Dart calling method
    /// - Returns: a Firebase Installations instance for the passed app from Dart
    internal func getInstallations(arguments: NSDictionary) -> Installations {
        let appName = FLTFirebasePlugin.firebaseAppName(fromDartName: (arguments["appName"] as! String))
        let app:FirebaseApp = FLTFirebasePlugin.firebaseAppNamed(appName)!
        return Installations.installations(app: app)
    }
    
    /// Get Installations Id for an instance.
    internal func getId(arguments: NSDictionary, result: FLTFirebaseMethodCallResult) {
        let instance:Installations = getInstallations(arguments: arguments);
        
        var installationsId:String = ""
        
        instance.installationID { (id:String?, error:Error?) in
            if error != nil {
                result.error(nil, nil, nil, error)
            }
            
            installationsId = id ?? ""
            NSLog("Firebase Installation ID: %@", installationsId)
            
            result.success(id)
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! NSDictionary
        
        let errorBlock:FLTFirebaseMethodCallErrorBlock = { (code, message, details, error) in
            if(code == nil) {
                
            }
            if(code == "unknown") {
                NSLog("FLTFirebaseInstallations: An error occured while calling method %@", call.method)
            }
            
            result(FLTFirebasePlugin.createFlutterError(fromCode: code!,
                                                        message: message!,
                                                        optionalDetails: details,
                                                        andOptionalNSError: error))
        };
        
        let methodCallResult:FLTFirebaseMethodCallResult = .create(success: result, andErrorBlock: errorBlock)
        
        switch (call.method) {
        case "FirebaseInstallations#getId":
            getId(arguments: args, result: methodCallResult)
        default:
            result(FlutterMethodNotImplemented)
        }
        
    }
}
