#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

@interface FLTBannerAdFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end
