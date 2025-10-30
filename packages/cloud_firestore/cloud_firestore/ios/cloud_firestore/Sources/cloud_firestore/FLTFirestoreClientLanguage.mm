// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <string>

namespace firebase {
namespace firestore {
namespace api {

class Firestore {
 public:
  static void SetClientLanguage(std::string language_token);
};

}  // namespace api
}  // namespace firestore
}  // namespace firebase

@interface FLTFirestoreClientLanguage : NSObject
+ (void)setClientLanguage:(NSString *)language;
@end

@implementation FLTFirestoreClientLanguage
+ (void)setClientLanguage:(NSString *)language {
  if (language == nil) {
    return;
  }
  std::string token = std::string([language UTF8String]);
  firebase::firestore::api::Firestore::SetClientLanguage(token);
}
@end
