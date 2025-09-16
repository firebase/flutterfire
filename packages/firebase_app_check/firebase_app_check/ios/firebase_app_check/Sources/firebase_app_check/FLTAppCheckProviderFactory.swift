// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import FirebaseAppCheck
import FirebaseCore

class FLTAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    var providers: [String: FLTAppCheckProvider]?
    
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        // The SDK may try to call this before we have been configured,
        // so we will configure ourselves and set the provider up as a default to start
        // pre-configure
        if providers == nil {
            providers = [:]
        }
        
        if providers?[app.name] == nil {
            providers?[app.name] = FLTAppCheckProvider(app: app)
            if let provider = providers?[app.name] {
                // We set "deviceCheck" as this is currently what is default. Backward compatible.
                provider.configure(app: app, providerName: "deviceCheck")
            }
        }
        
        return providers?[app.name]
    }
    
    func configure(app: FirebaseApp, providerName: String) {
        if providers == nil {
            providers = [:]
        }
        
        if providers?[app.name] == nil {
            providers?[app.name] = FLTAppCheckProvider(app: app)
        }
        
        if let provider = providers?[app.name] {
            provider.configure(app: app, providerName: providerName)
        }
    }
} 