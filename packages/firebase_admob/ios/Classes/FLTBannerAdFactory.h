#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface FLTBannerAdFactory : NSObject<FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end
