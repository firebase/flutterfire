#if canImport(FlutterMacOS)
import FlutterMacOS
#else
import Flutter
#endif

import firebase_core
import FirebaseInstallations

let kFLTFirebaseInstallationsChannelName = "plugins.flutter.io/firebase_installations";

public class SwiftFirebaseInstallationsPlugin: FLTFirebasePlugin, FlutterPlugin {
    
    private var eventSink: FlutterEventSink?
    private var messenger:FlutterBinaryMessenger;
    
    var result:FLTFirebaseMethodCallResult?;
    var streamHandler = Dictionary<String, IdChangedStreamHandler?>();
    
    var args = NSDictionary.init();
    
    init(messenger:FlutterBinaryMessenger) {
        self.messenger = messenger;
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger:FlutterBinaryMessenger;
        
        #if os(macOS)
            binaryMessenger = registrar.messenger
        #elseif os(iOS)
            binaryMessenger = registrar.messenger()
        #endif
        
        let channel = FlutterMethodChannel(name: kFLTFirebaseInstallationsChannelName, binaryMessenger: binaryMessenger)
        let instance = SwiftFirebaseInstallationsPlugin(messenger: binaryMessenger)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    @objc private func onIdChanged(notification: NSNotification) {
        print("changed")
    }
    
    /// Gets Installations instance for a Firebase App.
    /// - Returns: a Firebase Installations instance for the passed app from Dart
    internal func getInstallations() -> Installations {
        let appName = FLTFirebasePlugin.firebaseAppName(fromDartName: (args["appName"] as! String))
        let app:FirebaseApp = FLTFirebasePlugin.firebaseAppNamed(appName)!
        return Installations.installations(app: app)
    }
    
    /// Gets Installations Id for an instance.
    /// - Parameter arguments: the arguments passed by the Dart calling method
    /// - Parameter result: the result instance used to send the result to Dart.
    internal func getId() {
        let instance:Installations = getInstallations();
        
        var installationsId:String = ""
        
        instance.installationID { (id:String?, error:Error?) in
            if error != nil {
                self.result!.error(nil, nil, nil, error)
            } else {
                installationsId = id ?? ""
                NSLog("Firebase Installation ID: %@", installationsId)
                
                self.result!.success(id)
            }
            
            
        }
    }
    
    /// Deletes Installations Id for an instance.
    internal func deleteId() {
        let instance:Installations = getInstallations();
        
        instance.delete { (error:Error?) in
            if error != nil {
                self.result!.error(nil, nil, nil, error)
            } else {
                NSLog("Firebase Installation ID deleted successfully.")
                self.result!.success(nil)
            }
        }
        
    }
    
    /// Gets the token Id for an instance.
    internal func getToken() {
        let instance:Installations = getInstallations();
        
        var installationsAuthToken:String = ""
        
        let forceRefresh:Bool = (args["forceRefresh"] as? Bool) ?? false;
        
        instance.authTokenForcingRefresh  (forceRefresh, completion: {(tokenResult:InstallationsAuthTokenResult?, error:Error?) in
            if error != nil {
                self.result!.error(nil, nil, nil, error)
            } else {
                installationsAuthToken = tokenResult?.authToken ?? ""
                
                NSLog("Firebase Installation Auth Token: %@", installationsAuthToken)
                
                self.result!.success(installationsAuthToken)
            }
        });
    }
    
    /// Starts listening to Installation ID events for an instance.
    internal func registerTokenListener() {
        let instance:Installations = getInstallations();
        
        let appName = (args["appName"] as! String)
        let eventChannelName:String = kFLTFirebaseInstallationsChannelName + "/token/" + appName;
        
        let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: messenger)
        
        if (self.streamHandler[eventChannelName] == nil) {
            self.streamHandler[eventChannelName] = IdChangedStreamHandler(instance: instance)
        }
        
        eventChannel.setStreamHandler((self.streamHandler[eventChannelName]!))
        
        result?.success(eventChannelName)
    }
    
    
    internal func mapInstallationsErrorCodes(code:UInt) -> NSString {
        let error = InstallationsErrorCode.init(rawValue: code) ?? InstallationsErrorCode.unknown;
        
        switch error {
        case InstallationsErrorCode.invalidConfiguration:
            return "invalid-configuration";
        case InstallationsErrorCode.keychain:
            return "invalid-keychain";
        case InstallationsErrorCode.serverUnreachable:
            return "server-unreachable";
        case InstallationsErrorCode.unknown:
            return "unknown";
        default:
            return "unknown";
        }
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! NSDictionary
        
        let errorBlock:FLTFirebaseMethodCallErrorBlock = { (code, message, details, error:Error?) in
            var errorDetails:Dictionary = Dictionary<String, Any?>();
            
            errorDetails["code"] = code ?? self.mapInstallationsErrorCodes(code:UInt((error! as NSError).code))
            errorDetails["message"] = message ?? error?.localizedDescription ?? "An unknown error has occurred.";
            errorDetails["additionalData"] = details
            
            
            if(code == "unknown") {
                NSLog("FLTFirebaseInstallations: An error occured while calling method %@", call.method)
            }
            
            result(FLTFirebasePlugin.createFlutterError(fromCode: errorDetails["code"] as! String,
                                                        message: errorDetails["message"] as! String,
                                                        optionalDetails: (errorDetails["additionalData"] as? [AnyHashable : Any]),
                                                        andOptionalNSError: error))
        };
        
        self.result = .create(success: result, andErrorBlock: errorBlock)
        self.args = args
        
        switch (call.method) {
        case "FirebaseInstallations#getId":
            getId()
        case "FirebaseInstallations#delete":
            deleteId()
        case "FirebaseInstallations#getToken":
            getToken()
        case "FirebaseInstallations#registerIdTokenListener":
            registerTokenListener()
        default:
            result(FlutterMethodNotImplemented)
        }
        
    }
}
