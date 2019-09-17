/*
 ISC License
 
 Copyright (c) 2019 Kevin McGill <kevin@mcgilldevtech.com>
 
 Permission to use, copy, modify, and/or distribute this software for any
 purpose with or without fee is hereby granted, provided that the above
 copyright notice and this permission notice appear in all copies.
 
 THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

import Foundation
import GoogleMobileAds

class AdmobBanner : NSObject, FlutterPlatformView {

    private let channel: FlutterMethodChannel
    private let messeneger: FlutterBinaryMessenger
    private let frame: CGRect
    private let viewId: Int64
    private let args: [String: Any]
    private var adView: GADBannerView?

    init(frame: CGRect, viewId: Int64, args: [String: Any], messeneger: FlutterBinaryMessenger) {
        self.args = args
        self.messeneger = messeneger
        self.frame = frame
        self.viewId = viewId
        channel = FlutterMethodChannel(name: "admob_flutter/banner_\(viewId)", binaryMessenger: messeneger)
    }
    
    func view() -> UIView {
        return getBannerAdView() ?? UIView()
    }

    fileprivate func dispose() {
        adView?.removeFromSuperview()
        adView = nil
        channel.setMethodCallHandler(nil)
    }
    
    fileprivate func getBannerAdView() -> GADBannerView? {
        if adView == nil {
            adView = GADBannerView()
            adView!.rootViewController = UIApplication.shared.keyWindow?.rootViewController
            adView!.frame = self.frame.width == 0 ? CGRect(x: 0, y: 0, width: 1, height: 1) : self.frame
            adView!.adUnitID = self.args["adUnitId"] as? String ?? "ca-app-pub-3940256099942544/2934735716"
            channel.setMethodCallHandler { [weak self] (flutterMethodCall: FlutterMethodCall, flutterResult: FlutterResult) in
                switch flutterMethodCall.method {
                case "setListener":
                    self?.adView?.delegate = self
                    break
                case "dispose":
                    self?.dispose()
                    break
                default:
                    flutterResult(FlutterMethodNotImplemented)
                }
            }
            requestAd()
        }
        
        return adView
    }
    
    fileprivate func requestAd() {
        if let ad = getBannerAdView() {
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            ad.load(request)
        }
    }
    
    fileprivate func getSize() -> GADAdSize {
        let size = args["adSize"] as? [String: Any]
        let width = size!["width"] as? Int ?? 0
        let height = size!["height"] as? Int ?? 0
        let name = size!["name"] as! String
        
        switch name {
        case "BANNER":
            return kGADAdSizeBanner
        case "LARGE_BANNER":
            return kGADAdSizeLargeBanner
        case "MEDIUM_RECTANGLE":
            return kGADAdSizeMediumRectangle
        case "FULL_BANNER":
            return kGADAdSizeFullBanner
        case "LEADERBOARD":
            return kGADAdSizeLeaderboard
        case "SMART_BANNER":
            // TODO: Do we need Landscape too?
            return kGADAdSizeSmartBannerPortrait
        default:
            return GADAdSize.init(size: CGSize(width: width, height: height), flags: 0)
        }
    }

}

extension AdmobBanner : GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        channel.invokeMethod("loaded", arguments: nil)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        channel.invokeMethod("failedToLoad", arguments: [
            "errorCode": error.code,
            "error": error.localizedDescription
        ])
    }
    
    /// Tells the delegate that a full screen view will be presented in response to the user clicking on
    /// an ad. The delegate may want to pause animations and time sensitive interactions.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        channel.invokeMethod("clicked", arguments: nil)
        channel.invokeMethod("opened", arguments: nil)
    }
    
    // TODO: not sure this exists on iOS.
    // channel.invokeMethod("impression", null)
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        channel.invokeMethod("leftApplication", arguments: nil)
    }
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        channel.invokeMethod("closed", arguments: nil)
    }
}
