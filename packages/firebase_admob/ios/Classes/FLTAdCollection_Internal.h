#import <Foundation/Foundation.h>
#import "FLTAd_Internal.h"

@protocol FLTAd;

/// Collection of FLTMobileAd subclass instances.
@interface FLTAdCollection : NSObject
/// Adds `ad` to the collection for `referenceId`.
- (void)addAd:(__kindof id<FLTAd> _Nonnull)ad forReferenceId:(NSNumber *_Nonnull)referenceId;

/// Removes the ad with the specified referenceId from the collection.
- (void)removeAdWithReferenceId:(NSNumber *_Nonnull)referenceId;

/// Returns the ad for `referenceId` or nil if no ad was stored for `identifier`.
- (__kindof id<FLTAd> _Nullable)adForReferenceId:(NSNumber *_Nonnull)referenceId;

/// Returns the referenceId for `ad` or nil if the ad was not stored.
- (NSString *_Nullable)referenceIdForAd:(id<FLTAd> _Nonnull)ad;
@end
