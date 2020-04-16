#import "FLTAd_Internal.h"

@interface ViewHelper : NSObject
@end

@implementation FLTAdSize
- (instancetype _Nonnull)initWithWidth:(NSNumber *_Nonnull)width height:(NSNumber *_Nonnull)height {
  self = [super init];
  if (self) {
    _adSize = GADAdSizeFromCGSize(CGSizeMake(width.doubleValue, height.doubleValue));
  }
  return self;
}
@end

@implementation FLTAdRequest
- (instancetype _Nonnull)init {
  self = [super init];
  if (self) {
    _request = [GADRequest request];
  }
  return self;
}
@end

@implementation FLTAnchorType {
  NSString *name;
}

- (instancetype _Nonnull)initWithName:(NSString *_Nonnull)name {
  self = [super init];
  if (self) {
    self->name = name;
  }
  return self;
}

+ (FLTAnchorType *_Nullable)typeWithName:(NSString *_Nonnull)name {
  if ([FLTAnchorType.top->name isEqual:name]) {
    return FLTAnchorType.top;
  } else if ([FLTAnchorType.bottom->name isEqual:name]) {
    return FLTAnchorType.bottom;
  }
  return nil;
}

+ (FLTAnchorType *_Nonnull)top {
  return [[FLTAnchorType alloc] initWithName:@"AnchorType.top"];
}

+ (FLTAnchorType *_Nonnull)bottom {
  return [[FLTAnchorType alloc] initWithName:@"AnchorType.bottom"];
}

- (BOOL)isEqualToAnchorType:(FLTAnchorType *_Nonnull)type {
  return [name isEqual:type->name];
}
@end

@implementation ViewHelper
+ (void)show:(NSNumber *_Nonnull)anchorOffset
    horizontalCenterOffset:(NSNumber *_Nonnull)horizontalCenterOffset
                anchorType:(FLTAnchorType *_Nonnull)anchorType
        rootViewController:(UIViewController *_Nonnull)rootViewController
                      view:(UIView *_Nonnull)view {
  UIView *parentView = rootViewController.view;
  [parentView addSubview:view];

  view.translatesAutoresizingMaskIntoConstraints = NO;

  if (@available(ios 11.0, *)) {
    [ViewHelper activateConstraintForView:view
                              layoutGuide:parentView.safeAreaLayoutGuide
                             anchorOffset:anchorOffset
                   horizontalCenterOffset:horizontalCenterOffset
                               anchorType:anchorType];
  } else if (@available(ios 9.0, *)) {
    [ViewHelper activateConstraintForView:view
                              layoutGuide:parentView.layoutMarginsGuide
                             anchorOffset:anchorOffset
                   horizontalCenterOffset:horizontalCenterOffset
                               anchorType:anchorType];
  } else {
    // TODO: Make work with offsets
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView
                                                           attribute:NSLayoutAttributeLeading
                                                          multiplier:1
                                                            constant:0]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                           attribute:NSLayoutAttributeTrailing
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1
                                                            constant:0]];
    [parentView
        addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                   attribute:NSLayoutAttributeBottom
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:rootViewController.bottomLayoutGuide
                                                   attribute:NSLayoutAttributeTop
                                                  multiplier:1
                                                    constant:0]];
  }
}

+ (void)activateConstraintForView:(UIView *_Nonnull)view
                      layoutGuide:(UILayoutGuide *_Nonnull)layoutGuide
                     anchorOffset:(NSNumber *_Nonnull)anchorOffset
           horizontalCenterOffset:(NSNumber *_Nonnull)horizontalCenterOffset
                       anchorType:(FLTAnchorType *_Nonnull)anchorType API_AVAILABLE(ios(9.0)) {
  view.translatesAutoresizingMaskIntoConstraints = NO;

  NSLayoutConstraint *verticalConstraint = nil;
  if ([anchorType isEqualToAnchorType:FLTAnchorType.bottom]) {
    verticalConstraint = [view.bottomAnchor constraintEqualToAnchor:layoutGuide.bottomAnchor
                                                           constant:-anchorOffset.doubleValue];
  } else if ([anchorType isEqualToAnchorType:FLTAnchorType.top]) {
    verticalConstraint = [view.topAnchor constraintEqualToAnchor:layoutGuide.topAnchor
                                                        constant:anchorOffset.doubleValue];
  }

  [NSLayoutConstraint activateConstraints:@[
    verticalConstraint,
    [view.centerXAnchor constraintEqualToAnchor:layoutGuide.centerXAnchor
                                       constant:horizontalCenterOffset.doubleValue],
  ]];
}

+ (UIViewController *_Nonnull)rootViewController {
  return [UIApplication sharedApplication].delegate.window.rootViewController;
}
@end

@implementation FLTBannerAd {
  GADBannerView *_bannerView;
  GADRequest *_request;
  __weak id<FLTAdListenerCallbackHandler> _callbackHandler;
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                         request:(FLTAdRequest *_Nonnull)request
                          adSize:(FLTAdSize *_Nonnull)adSize
                 callbackHandler:(id<FLTAdListenerCallbackHandler> _Nonnull)callbackHandler {
  self = [super init];
  if (self) {
    _request = request.request;
    _callbackHandler = callbackHandler;
    _bannerView = [[GADBannerView alloc] initWithAdSize:adSize.adSize];
    _bannerView.adUnitID = adUnitId;
    _bannerView.rootViewController = [ViewHelper rootViewController];
    _bannerView.delegate = self;
  }
  return self;
}

- (void)dispose {
  if (_bannerView.superview) [_bannerView removeFromSuperview];
}

- (void)load {
  [_bannerView loadRequest:_request];
}

- (UIView *)view {
  return _bannerView;
}

- (void)show:(NSNumber *_Nonnull)anchorOffset
    horizontalCenterOffset:(NSNumber *_Nonnull)horizontalCenterOffset
                anchorType:(FLTAnchorType *_Nonnull)anchorType {
  [self dispose];

  [ViewHelper show:anchorOffset
      horizontalCenterOffset:horizontalCenterOffset
                  anchorType:anchorType
          rootViewController:[ViewHelper rootViewController]
                        view:_bannerView];
}

- (void)adViewDidReceiveAd:(GADBannerView *_Nonnull)adView {
  [_callbackHandler onAdLoaded:self];
}
@end

@implementation FLTInterstitialAd {
  GADInterstitial *_interstitial;
  GADRequest *_request;
  __weak id<FLTAdListenerCallbackHandler> _callbackHandler;
}

- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                                  request:(FLTAdRequest *_Nonnull)request
                          callbackHandler:
                              (id<FLTAdListenerCallbackHandler> _Nonnull)callbackHandler {
  self = [super init];
  if (self) {
    _interstitial = [[GADInterstitial alloc] initWithAdUnitID:adUnitId];
    _interstitial.delegate = self;
    _callbackHandler = callbackHandler;
  }
  return self;
}

- (void)load {
  [_interstitial loadRequest:_request];
}

- (void)show {
  [_interstitial presentFromRootViewController:[ViewHelper rootViewController]];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *_Nonnull)ad {
  [_callbackHandler onAdLoaded:self];
}
@end

@implementation FLTNativeAd {
  GADAdLoader *_adLoader;
  GADUnifiedNativeAdView *_nativeAdView;
  NSDictionary<NSString *, id> *_customOptions;
  id<FLTNativeAdFactory> _nativeAdFactory;
  GADRequest *_request;
  __weak id<FLTAdListenerCallbackHandler> _callbackHandler;
}

- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                                  request:(FLTAdRequest *_Nonnull)request
                          nativeAdFactory:(id<FLTNativeAdFactory> _Nonnull)nativeAdFactory
                            customOptions:(NSDictionary<NSString *, id> *_Nonnull)customOptions
                          callbackHandler:
                              (id<FLTAdListenerCallbackHandler> _Nonnull)callbackHandler {
  if (self) {
    _adLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitId
                                   rootViewController:[ViewHelper rootViewController]
                                              adTypes:@[ kGADAdLoaderAdTypeUnifiedNative ]
                                              options:@[]];
    _adLoader.delegate = self;
    _request = request.request;
    _nativeAdFactory = nativeAdFactory;
    _customOptions = customOptions;
    _callbackHandler = callbackHandler;
  }
  return self;
}

- (void)load {
  [_adLoader loadRequest:_request];
}

- (void)dispose {
  if ([_nativeAdView superview]) [_nativeAdView removeFromSuperview];
}

- (void)show:(NSNumber *_Nonnull)anchorOffset
    horizontalCenterOffset:(NSNumber *_Nonnull)horizontalCenterOffset
                anchorType:(FLTAnchorType *_Nonnull)anchorType {
  [self dispose];

  [ViewHelper show:anchorOffset
      horizontalCenterOffset:horizontalCenterOffset
                  anchorType:anchorType
          rootViewController:[ViewHelper rootViewController]
                        view:_nativeAdView];
}

- (UIView *_Nonnull)view {
  return _nativeAdView;
}

- (void)adLoader:(GADAdLoader *_Nonnull)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *_Nonnull)nativeAd {
  _nativeAdView = [_nativeAdFactory createNativeAd:nativeAd customOptions:_customOptions];
  nativeAd.delegate = self;
  [_callbackHandler onAdLoaded:self];
}
@end

@implementation FLTRewardedAd {
  GADRewardedAd *_rewardedAd;
  GADRequest *_request;
  __weak id<FLTAdListenerCallbackHandler> _callbackHandler;
}

- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                                  request:(FLTAdRequest *_Nonnull)request
                          callbackHandler:
                              (id<FLTAdListenerCallbackHandler> _Nonnull)callbackHandler {
  self = [super init];
  if (self) {
    _rewardedAd = [[GADRewardedAd alloc] initWithAdUnitID:adUnitId];
    _request = request.request;
    _callbackHandler = callbackHandler;
  }
  return self;
}

- (void)load {
  [_rewardedAd loadRequest:_request
         completionHandler:^(GADRequestError *_Nullable error) {
           if (!error) [self->_callbackHandler onAdLoaded:self];
         }];
}

- (void)show {
  [_rewardedAd presentFromRootViewController:[ViewHelper rootViewController] delegate:self];
}
@end
