#import <Flutter/Flutter.h>
#import "Firebase/Firebase.h"
#import "GoogleMobileAds/GoogleMobileAds.h"
#import "FLTFirebaseAdMobPlugin.h"

@protocol FLTNativeAdFactory;

@protocol FLTAd <NSObject>
@required
- (void)load;
@end

@interface FLTAnchorType : NSObject
+ (FLTAnchorType *_Nonnull)typeWithName:(NSString *_Nonnull)name;
+ (FLTAnchorType *_Nonnull)top;
+ (FLTAnchorType *_Nonnull)bottom;
@end

@protocol FLTPlatformViewAd <FLTAd>
@required
- (void)show:(NSNumber *_Nonnull)anchorOffset horizontalCenterOffset:(NSNumber *_Nonnull)horizontalCenterOffset
anchorType:(FLTAnchorType *_Nonnull)anchorType;
- (void)dispose;
@end

@protocol FLTFullscreenAd <FLTAd>
@required
- (void)show;
@end

@protocol FLTAdListenerCallbackHandler <NSObject>
- (void)onAdLoaded:(id<FLTAd>_Nonnull)ad;
@end

@interface FLTAdSize : NSObject
@property(readonly) GADAdSize adSize;
- (instancetype _Nonnull)initWithWidth:(NSNumber *_Nonnull)width height:(NSNumber *_Nonnull)height;
@end

@interface FLTAdRequest : NSObject
@property(readonly) GADRequest *_Nonnull request;
@end

@interface FLTBannerAd : NSObject<FLTPlatformViewAd, GADBannerViewDelegate, FlutterPlatformView>
- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                         request:(FLTAdRequest *_Nonnull)request
                          adSize:(FLTAdSize *_Nonnull)adSize
                 callbackHandler:(id<FLTAdListenerCallbackHandler>_Nonnull)callbackHandler;
@end

@interface FLTInterstitialAd : NSObject<FLTFullscreenAd, GADInterstitialDelegate>
- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                         request:(FLTAdRequest *_Nonnull)request
                 callbackHandler:(id<FLTAdListenerCallbackHandler>_Nonnull)callbackHandler;
@end

@interface FLTNativeAd : NSObject<FLTPlatformViewAd, GADUnifiedNativeAdDelegate, GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate, GADNativeAdDelegate, FlutterPlatformView>
- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                         request:(FLTAdRequest *_Nonnull)request
                          nativeAdFactory:(id<FLTNativeAdFactory> _Nonnull)nativeAdFactory
                      customOptions:(NSDictionary<NSString *, id> *_Nonnull)customOptions
                 callbackHandler:(id<FLTAdListenerCallbackHandler>_Nonnull)callbackHandler;
@end
