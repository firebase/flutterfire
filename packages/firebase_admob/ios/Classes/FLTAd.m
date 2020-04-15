#import "FLTAd.h"

@interface ViewHelper : NSObject
+ (void)show:(NSNumber *)anchorOffset horizontalCenterOffset:(NSNumber *)horizontalCenterOffset
  anchorType:(FLTAnchorType *)anchorType
rootViewController:(UIViewController *)rootViewController
        view:(UIView *)view;
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
@end

@implementation FLTBannerAd {
  GADBannerView *bannerView;
  GADRequest *request;
  __weak UIViewController *rootViewController;
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
    self->rootViewController = rootViewController;
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

- (void)show:(NSNumber *)anchorOffset horizontalCenterOffset:(NSNumber *)horizontalCenterOffset anchorType:(FLTAnchorType *)anchorType {
  [ViewHelper show:anchorOffset horizontalCenterOffset:horizontalCenterOffset
        anchorType:anchorType rootViewController:rootViewController
              view:[self view]];
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  [callbackHandler onAdLoaded:self];
}
@end
