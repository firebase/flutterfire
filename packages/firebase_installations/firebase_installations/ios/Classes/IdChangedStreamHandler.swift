import Foundation
import FirebaseInstallations

class IdChangedStreamHandler: NSObject, FlutterStreamHandler {
    
    var eventSink: FlutterEventSink?
    var installationIDObserver: NSObjectProtocol?;
    var instance:Installations;
    var authToken:String = "";
    
    init(instance: Installations) {
        self.instance = instance;
    }
    
    @objc func handleInstallationIDChange() {
        var events = Dictionary<String, String>();
        
        var installationsAuthToken:String = ""
        
        // Fetch new auth token
        self.instance.authTokenForcingRefresh  (true, completion: {(tokenResult:InstallationsAuthTokenResult?, error:Error?) in
            if error != nil {
                self.eventSink!(FlutterError())
            }
            installationsAuthToken = tokenResult?.authToken ?? ""
            if(installationsAuthToken != self.authToken) {
                self.authToken = installationsAuthToken;
                events["token"] = self.authToken;
                self.eventSink!(events)
            }
            
        });
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        
        // [START handle_installation_id_change]
        installationIDObserver = NotificationCenter.default.addObserver(
            forName: .InstallationIDDidChange,
            object: nil,
            queue: nil
        ) { (notification) in
            self.handleInstallationIDChange()
        }
        // [END handle_installation_id_change]
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
}
