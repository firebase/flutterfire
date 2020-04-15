#import <Flutter/Flutter.h>
#import "Firebase/Firebase.h"
#import "GoogleMobileAds/GoogleMobileAds.h"

@protocol FLTAdListenerCallbackHandler;

@protocol FLTAd <NSObject>
@required
- (void)load;
- (void)dispose;
@end

@interface FLTAnchorType : NSObject
+ (FLTAnchorType *)typeWithName:(NSString *)name;
+ (FLTAnchorType *)top;
+ (FLTAnchorType *)bottom;
@end

@protocol FLTPlatformViewAd <FLTAd>
@required
- (void)show:(NSNumber *)anchorOffset horizontalCenterOffset:(NSNumber *)horizontalCenterOffset
anchorType:(FLTAnchorType *)anchorType;
@end

@protocol FLTAdListenerCallbackHandler <NSObject>
- (void)onAdLoaded:(id<FLTAd>)ad;
@end

@interface FLTAdSize : NSObject
@property(readonly) GADAdSize adSize;
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height;
@end

@interface FLTAdRequest : NSObject
@property(readonly) GADRequest *request;
@end

@interface FLTBannerAd : NSObject<FLTPlatformViewAd, GADBannerViewDelegate, FlutterPlatformView>
- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                         request:(FLTAdRequest *)request
                          adSize:(FLTAdSize *)adSize
              rootViewController:(UIViewController *)rootViewController
                 callbackHandler:(id<FLTAdListenerCallbackHandler>)callbackHandler;
@end
