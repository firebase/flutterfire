#import <Flutter/Flutter.h>
#import "Firebase/Firebase.h"
#import "GoogleMobileAds/GoogleMobileAds.h"

@protocol FLTAdListenerCallbackHandler;

@protocol FLTAd <NSObject>
@required
- (void)load;
- (void)dispose;
@end

@protocol FLTAdListenerCallbackHandler <NSObject>
- (void)onAdLoaded:(id<FLTAd>)ad;
@end

@interface FLTAdSize : NSObject
@property (readonly) GADAdSize adSize;
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height;
@end

@interface FLTAdRequest : NSObject;
@property (readonly) GADRequest *request;
@end

@interface FLTBannerAd : NSObject<FLTAd, GADBannerViewDelegate, FlutterPlatformView>
- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                         request:(FLTAdRequest *)request
                          adSize:(FLTAdSize *)adSize
              rootViewController:(UIViewController *)rootViewController
                 callbackHandler:(id<FLTAdListenerCallbackHandler>)callbackHandler;
@end
