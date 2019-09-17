
#import "FLTBannerAd.h"

@implementation FLTBannerAd {
    FlutterMethodChannel* _channel;
    NSObject<FlutterBinaryMessenger>* _messenger;
    CGRect _frame;
    int64_t _viewId;
    id _args;
    GADBannerView* _adView;
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    if ([super init]) {
        _frame = frame;
        _messenger = messenger;
        _args = args;
        _viewId = viewId;
        _channel = [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_admob/banner" binaryMessenger:messenger];
    }
    return self;
}

- (UIView*)view {
    return [self getBannerAdView];
}

- (void)dispose{
    [_adView removeFromSuperview];
    _adView = nil;
    [_channel setMethodCallHandler:nil];
}

- (GADBannerView*) getBannerAdView {
    if(_adView ==nil){
        _adView = [GADBannerView init];
        _adView.rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
        _adView.frame = _frame.size.width == 0? CGRectMake(0, 0, 1, 1) :_frame;
        _adView.adUnitID = (NSString*) _args[@"adUnitId"];
        [self requestAd];
    }
    return _adView;
}

- (void) requestAd {
    GADBannerView *ad = [self getBannerAdView];
    if(ad){
        GADRequest *request = [GADRequest init];
        request.testDevices = [NSArray arrayWithObjects:kGADSimulatorID, nil];
        [ad loadRequest:request];
    }
}
- (GADAdSize) getSize{
    id size = _args[@"adSize"];
    int width =(int) size[@"width"];
    int height =(int) size[@"height"];
    NSString *name = (NSString*) size[@"name"];
    if([name isEqualToString:@"BANNER"])
        return kGADAdSizeBanner;
    else if([name isEqualToString:@"BANNER"])
        return kGADAdSizeLargeBanner;
    else if([name isEqualToString:@"BANNER"])
        
        return kGADAdSizeMediumRectangle;
    else if([name isEqualToString:@"FULL_BANNER"])
        
        return kGADAdSizeFullBanner;
    else if([name isEqualToString:@"LEADERBOARD"])
        
        return kGADAdSizeLeaderboard;
    else if([name isEqualToString:@"SMART_BANNER"])
        
        return kGADAdSizeSmartBannerPortrait;
    else
        return GADAdSizeFromCGSize(CGSizeMake(0, 0));
    
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([call.method  isEqual: @"setListener"])
        _adView.delegate = self;
    else if([call.method  isEqual: @"dispose"])
        [self dispose];
    else
        result(FlutterMethodNotImplemented);
}


@end
