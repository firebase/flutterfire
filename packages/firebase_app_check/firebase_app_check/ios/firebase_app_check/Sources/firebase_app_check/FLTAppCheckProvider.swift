// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import FirebaseAppCheck
import FirebaseCore

class FLTAppCheckProvider: NSObject, AppCheckProvider {
    var app: FirebaseApp?
    var delegateProvider: AppCheckProvider?
    
    init(app: FirebaseApp) {
        super.init()
        self.app = app
    }
    
    func configure(app: FirebaseApp, providerName: String) {
        switch providerName {
        case "debug":
            let provider: AppCheckDebugProvider? = AppCheckDebugProvider(app: app)
            if let debugToken = provider?.localDebugToken() {
                print("Firebase App Check Debug Token: \(debugToken)")
            }
            self.delegateProvider = provider
            
        case "deviceCheck":
            self.delegateProvider = DeviceCheckProvider(app: app)
            
        case "appAttest":
            if #available(iOS 14.0, macCatalyst 14.0, tvOS 15.0, watchOS 9.0, *) {
                self.delegateProvider = AppAttestProvider(app: app)
            } else {
                // This is not a valid environment, setup debug provider.
                self.delegateProvider = AppCheckDebugProvider(app: app)
            }
            
        case "appAttestWithDeviceCheckFallback":
            if #available(iOS 14.0, *) {
                self.delegateProvider = AppAttestProvider(app: app)
            } else {
                self.delegateProvider = DeviceCheckProvider(app: app)
            }
            
        default:
            break
        }
    }
    
    func getToken(completion: @escaping (AppCheckToken?, Error?) -> Void) {
        // Proxying to delegateProvider
        delegateProvider?.getToken(completion: completion)
    }
} 