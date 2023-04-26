// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//
//  GoogleSignInMacOS.swift
//  Runner
//
//  Created by Andrei Lesnitsky on 10.09.21.
//

import Foundation

import Cocoa
import FlutterMacOS
import WebKit

public class WebviewController: NSViewController, WKNavigationDelegate {
  var width: CGFloat?
  var height: CGFloat?
  var redirectUri: String?
  var result: FlutterResult?
  var onComplete: ((String?) -> Void)?

  override public func loadView() {
    let webView = WKWebView(frame: NSMakeRect(0, 0, width ?? 980, height ?? 720))

    webView.navigationDelegate = self
    webView.allowsBackForwardNavigationGestures = true

    view = webView
  }

  func loadUrl(_ url: String) {
    clearCookies()

    let url = URL(string: url)!
    let request = URLRequest(url: url)
    (view as! WKWebView).load(request)
  }

  func clearCookies() {
    HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

    WKWebsiteDataStore.default()
      .fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
        records.forEach { record in
          WKWebsiteDataStore.default()
            .removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
        }
      }
  }

  public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard let url = navigationAction.request.url else {
      decisionHandler(.allow)
      return
    }

    let uriString = url.absoluteString

    print("Opening \(uriString)")

    if uriString.starts(with: redirectUri!) {
      decisionHandler(.cancel)
      onComplete!(uriString)
      dismiss(self)
    } else {
      decisionHandler(.allow)
    }
  }

  override public func viewDidDisappear() {
    onComplete!(nil)
  }
}

public class GoogleSignInMacOSPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_sign_in_desktop",
      binaryMessenger: registrar.messenger
    )
    let instance = GoogleSignInMacOSPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "signIn":
      let args = call.arguments as! NSDictionary
      signIn(
        clientId: args["clientId"] as! String,
        redirectUri: args["redirectUri"] as! String,
        result: result
      )
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func signIn(clientId: String, redirectUri: String, result: @escaping FlutterResult) {
    let appWindow = NSApplication.shared.windows.first!
    let webviewController = WebviewController()

    webviewController.redirectUri = redirectUri
    webviewController.onComplete = { callbackUrl in
      result(callbackUrl)
    }

    webviewController
      .loadUrl(
        "https://accounts.google.com/o/oauth2/auth?client_id=\(clientId)&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fplus.login&immediate=false&response_type=token&redirect_uri=\(redirectUri)"
      )

    appWindow.contentViewController?.presentAsModalWindow(webviewController)
  }
}
