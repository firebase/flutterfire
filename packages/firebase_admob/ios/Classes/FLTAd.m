#import "FLTAd.h"

@implementation FLTAdSize
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height {
  self = [super init];
  if (self) {
    _adSize = GADAdSizeFromCGSize(CGSizeMake(width.doubleValue, height.doubleValue));
  }
  return self;
}
@end

@implementation FLTAdRequest
- (instancetype)init {
  self = [super init];
  if (self) {
    _request = [GADRequest request];
  }
  return self;
}
@end

@implementation FLTBannerAd {
  GADBannerView *bannerView;
  GADRequest *request;
  __weak id<FLTAdListenerCallbackHandler> callbackHandler;
}

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                         request:(FLTAdRequest *)request
                          adSize:(FLTAdSize *)adSize
              rootViewController:(UIViewController *)rootViewController
                 callbackHandler:(id<FLTAdListenerCallbackHandler>)callbackHandler {
  self = [super init];
  if (self) {
    self->request = request.request;
    self->callbackHandler = callbackHandler;
    bannerView = [[GADBannerView alloc] initWithAdSize:adSize.adSize];
    bannerView.adUnitID = adUnitId;
    bannerView.rootViewController = rootViewController;
    bannerView.delegate = self;
  }
  return self;
}

- (void)dispose {
  // TODO: Pass to add view
}

- (void)load {
  [bannerView loadRequest:request];
}

- (nonnull UIView *)view {
  return bannerView;
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  [callbackHandler onAdLoaded:self];
}
@end
