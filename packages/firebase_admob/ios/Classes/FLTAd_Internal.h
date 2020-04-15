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
+ (FLTAnchorType *_Nonnull)typeWithName:(NSString *_Nonnull)name;
+ (FLTAnchorType *_Nonnull)top;
+ (FLTAnchorType *_Nonnull)bottom;
@end

@protocol FLTPlatformViewAd <FLTAd>
@required
- (void)show:(NSNumber *_Nonnull)anchorOffset horizontalCenterOffset:(NSNumber *_Nonnull)horizontalCenterOffset
anchorType:(FLTAnchorType *_Nonnull)anchorType;
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
