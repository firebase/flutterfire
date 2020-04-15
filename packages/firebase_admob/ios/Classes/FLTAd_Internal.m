#import "FLTAd_Internal.h"

@interface ViewHelper : NSObject
@end

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

@implementation FLTAnchorType {
  NSString *name;
}

- (instancetype)initWithName:(NSString *)name {
  self = [super init];
  if (self) {
    self->name = name;
  }
  return self;
}

+ (FLTAnchorType *)typeWithName:(NSString *)name {
  if ([FLTAnchorType.top->name isEqual:name]) {
    return FLTAnchorType.top;
  } else if ([FLTAnchorType.bottom->name isEqual:name]) {
    return FLTAnchorType.bottom;
  }
  return nil;
}

+ (FLTAnchorType *)top {
  return [[FLTAnchorType alloc] initWithName:@"AnchorType.top"];
}

+ (FLTAnchorType *)bottom {
  return [[FLTAnchorType alloc] initWithName:@"AnchorType.bottom"];
}

- (BOOL)isEqualToAnchorType:(FLTAnchorType *)type {
  return [name isEqual:type->name];
}
@end

@implementation ViewHelper
+ (void)show:(NSNumber *)anchorOffset horizontalCenterOffset:(NSNumber *)horizontalCenterOffset
  anchorType:(FLTAnchorType *)anchorType
rootViewController:(UIViewController *)rootViewController
        view:(UIView *)view {
  UIView *parentView = rootViewController.view;
  [parentView addSubview:view];

  view.translatesAutoresizingMaskIntoConstraints = NO;

  // TODO: code for < 9.0
  UILayoutGuide *layoutGuide = nil;
  if (@available(ios 11.0, *)) {
    layoutGuide = parentView.safeAreaLayoutGuide;
  } else {
    layoutGuide = parentView.layoutMarginsGuide;
  }

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

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                         request:(FLTAdRequest *)request
                          adSize:(FLTAdSize *)adSize
                 callbackHandler:(id<FLTAdListenerCallbackHandler>)callbackHandler {
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

- (nonnull UIView *)view {
  return _bannerView;
}

- (void)show:(NSNumber *)anchorOffset horizontalCenterOffset:(NSNumber *)horizontalCenterOffset anchorType:(FLTAnchorType *)anchorType {
  [self dispose];
  
  [ViewHelper show:anchorOffset horizontalCenterOffset:horizontalCenterOffset
        anchorType:anchorType rootViewController:[ViewHelper rootViewController]
              view:_bannerView];
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  [_callbackHandler onAdLoaded:self];
}
@end
