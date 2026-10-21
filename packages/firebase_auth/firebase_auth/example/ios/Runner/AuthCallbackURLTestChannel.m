// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "AuthCallbackURLTestChannel.h"

#import <objc/runtime.h>

@import FirebaseCore;

/// A URL context carrying a chosen URL, as UIKit passes to
/// `scene:openURLContexts:`.
@interface AuthCallbackURLTestContext : UIOpenURLContext
@end

@implementation AuthCallbackURLTestContext {
  NSURL *_testURL;
}

+ (instancetype)contextWithURL:(NSURL *)url {
  // UIKit marks -init unavailable; NSObject's -init would do nothing anyway.
  AuthCallbackURLTestContext *context = [self alloc];
  context->_testURL = url;
  return context;
}

- (NSURL *)URL {
  return _testURL;
}

- (UISceneOpenURLOptions *)options {
  return nil;
}

@end

@implementation AuthCallbackURLTestChannel

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"tests/auth_callback_url"
                                  binaryMessenger:[registrar messenger]];
  [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    NSURL *url = [NSURL URLWithString:call.arguments[@"url"]];
    BOOL withoutDefaultApp = [call.arguments[@"withoutDefaultApp"] boolValue];
    if (url == nil) {
      result([FlutterError errorWithCode:@"invalid-url" message:nil details:nil]);
    } else if ([call.method isEqualToString:@"openThroughAppDelegate"]) {
      __block BOOL handled;
      [self withoutDefaultApp:withoutDefaultApp
                          run:^{
                            handled = [self openThroughAppDelegate:url];
                          }];
      result(@(handled));
    } else if ([call.method isEqualToString:@"openThroughScene"]) {
      __block FlutterError *error;
      [self withoutDefaultApp:withoutDefaultApp
                          run:^{
                            error = [self openThroughScene:url];
                          }];
      result(error);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

static FIRApp *AuthCallbackURLTestNoDefaultApp(id self, SEL _cmd) { return nil; }

/// Runs `block`. With `withoutDefaultApp`, `FirebaseApp.app()` returns nil
/// meanwhile, as in an app that only configures named apps.
///
/// [DEFAULT] stays configured. Deleting and configuring it again would replace
/// its native `Auth`, dropping the emulator settings and listeners the rest of
/// the suite relies on.
+ (void)withoutDefaultApp:(BOOL)withoutDefaultApp run:(void (^)(void))block {
  if (!withoutDefaultApp) {
    block();
    return;
  }
  Method defaultApp = class_getClassMethod([FIRApp class], @selector(defaultApp));
  IMP original = method_setImplementation(defaultApp, (IMP)AuthCallbackURLTestNoDefaultApp);
  block();
  method_setImplementation(defaultApp, original);
}

/// Returns what the app delegate returns to iOS.
+ (BOOL)openThroughAppDelegate:(NSURL *)url {
  UIApplication *application = UIApplication.sharedApplication;
  return [application.delegate application:application openURL:url options:@{}];
}

/// Returns nil once the scene delegate has been called, as
/// `scene:openURLContexts:` returns nothing.
+ (FlutterError *)openThroughScene:(NSURL *)url {
  for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
    if ([scene.delegate respondsToSelector:@selector(scene:openURLContexts:)]) {
      [scene.delegate scene:scene
            openURLContexts:[NSSet setWithObject:[AuthCallbackURLTestContext contextWithURL:url]]];
      return nil;
    }
  }
  return [FlutterError errorWithCode:@"no-scene"
                             message:@"No connected scene opens URLs"
                             details:nil];
}

@end
