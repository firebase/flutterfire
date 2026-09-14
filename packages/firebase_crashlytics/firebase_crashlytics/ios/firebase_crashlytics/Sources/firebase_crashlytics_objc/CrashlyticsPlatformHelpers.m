/*
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "CrashlyticsPlatformHelpers.h"
#import "Crashlytics_Platform.h"
#import "ExceptionModel_Platform.h"

@implementation CrashlyticsPlatformHelpers

+ (void)setDevelopmentPlatformName:(NSString *)name version:(NSString *)version {
  FIRCrashlytics *crashlytics = [FIRCrashlytics crashlytics];
  crashlytics.developmentPlatformName = name;
  crashlytics.developmentPlatformVersion = version;
}

+ (void)recordExceptionModel:(FIRExceptionModel *)exception fatal:(BOOL)fatal {
  exception.onDemand = YES;
  exception.isFatal = fatal;
  if (fatal) {
    [[FIRCrashlytics crashlytics] recordOnDemandExceptionModel:exception];
  } else {
    [[FIRCrashlytics crashlytics] recordExceptionModel:exception];
  }
}

@end
