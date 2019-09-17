
#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface FLTBannerAd : NSObject <FlutterPlatformView>

- (instancetype _Nullable )initWithFrame:(CGRect)frame
                          viewIdentifier:(int64_t)viewId
                               arguments:(id _Nullable)args
                         binaryMessenger:(NSObject<FlutterBinaryMessenger>*_Nullable)messenger;

- (UIView*)view;
@end
