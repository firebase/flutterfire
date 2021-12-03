// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.i

mport Foundation
import FirebaseInstallations

class IdChangedStreamHandler: NSObject, FlutterStreamHandler {
    
    
    var eventSink: FlutterEventSink?;
    var installationIDObserver: NSObjectProtocol?;
    var instance:Installations;
    var installationsId:String = "";
    
    init(instance: Installations) {
        self.instance = instance;
    }
    
        @objc func handleInstallationIDChange() {
            var events = Dictionary<String, String>();
    
            // Fetch new installation Id
            instance.installationID { (newId:String?, error:Error?) in
                if error != nil {
                    self.eventSink!(FlutterError())
                } else {
                    if(newId != self.installationsId) {
                        self.installationsId = newId!;
                        events["token"] = self.installationsId;
                        self.eventSink!(events)
                    }
                }
            }
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
