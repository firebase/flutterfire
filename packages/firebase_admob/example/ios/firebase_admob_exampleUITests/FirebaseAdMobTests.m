@import Flutter;
@import firebase_admob;

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface FirebaseAdMobTests : XCTestCase
@property FlutterMethodChannel *mockMethodChannel;
@end

@implementation FirebaseAdMobTests
- (void)setUp {
  [self setUpMockMethodChannel];
}

- (void)setUpMockMethodChannel {
  _mockMethodChannel = OCMClassMock([FlutterMethodChannel class]);
}

- (UIViewController *)createMockRootViewController {
  UIViewController *mockViewController = [[UIViewController alloc] init];
  mockViewController.view.frame = CGRectMake(0, 0, 1000, 1000);

  // Mock call to [FLTMobileAd rootViewController]. The method showAtOffset adds a view to this.
  id mockDelegate = OCMPartialMock(UIApplication.sharedApplication.delegate);
  id mockWindow = OCMClassMock([UIWindow class]);
  OCMStub([mockDelegate window]).andReturn(mockWindow);
  OCMStub([mockWindow rootViewController]).andReturn(mockViewController);

  return mockViewController;
}

- (FLTBannerAd *)createMockFLTBannerAd {
  FLTBannerAd *banner = [FLTBannerAd withId:@(455)
                                     adSize:GADAdSizeFromCGSize(CGSizeMake(300, 50))
                                    channel:_mockMethodChannel];
  id bannerMock = OCMPartialMock(banner);
  OCMStub([bannerMock view]).andReturn([[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]);
  return banner;
}

- (void)testShowAtOffsetAnchorBottom {
  UIViewController *mockViewController = [self createMockRootViewController];
  FLTBannerAd *mockBannerAd = [self createMockFLTBannerAd];

  // Changes FLTBannerAd's private state to LOADED which is required to call showAtOffset.
  [mockBannerAd adViewDidReceiveAd:nil];

  [mockBannerAd showAtOffset:25.0 hCenterOffset:35.0 fromAnchor:0];
  [mockViewController.view layoutIfNeeded];

  XCTAssertEqual(mockViewController.view.subviews.count, 1);

  UIView *adView = mockViewController.view.subviews[0];
  XCTAssertEqual(adView.frame.origin.x, 535);
  XCTAssertEqual(adView.frame.origin.y, 975);
}

- (void)testShowAtOffsetAnchorTop {
  UIViewController *mockViewController = [self createMockRootViewController];
  FLTBannerAd *mockBannerAd = [self createMockFLTBannerAd];

  // Changes FLTBannerAd's private state to LOADED which is required to call showAtOffset.
  [mockBannerAd adViewDidReceiveAd:nil];

  [mockBannerAd showAtOffset:25.0 hCenterOffset:-35.0 fromAnchor:1];
  [mockViewController.view layoutIfNeeded];

  XCTAssertEqual(mockViewController.view.subviews.count, 1);

  UIView *adView = mockViewController.view.subviews[0];
  XCTAssertEqual(adView.frame.origin.x, 465);
  XCTAssertEqual(adView.frame.origin.y, 25);
}
@end
