/*
 * Copyright 2021 Google LLC
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
//
//  Crashlytics_Platform.h
//  Crashlytics
//

#import <Firebase/Firebase.h>

@interface FIRCrashlytics (Platform)

@property(nonatomic, strong, nullable) NSString* developmentPlatformName;
@property(nonatomic, strong, nullable) NSString* developmentPlatformVersion;

- (void)recordOnDemandExceptionModel:(FIRExceptionModel* _Nonnull)exceptionModel;

@end

void FIRCLSUserLoggingRecordInternalKeyValue(NSString* _Nullable key, id _Nullable value);
