//
//  FLTTransactionStreamHandler.h
//  cloud_firestore
//
//  Created by Sebastian Roth on 24/11/2020.
//

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTTransactionStreamHandler : NSObject <FlutterStreamHandler>

- (instancetype)init:(NSMutableDictionary<NSNumber *, FIRTransaction *> *)transactions;
- (void)receiveTransactionResponse:(NSNumber *)transactionId response:(NSDictionary *)response;

@end

NS_ASSUME_NONNULL_END
