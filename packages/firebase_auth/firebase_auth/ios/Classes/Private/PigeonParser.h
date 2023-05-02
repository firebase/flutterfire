#import <Foundation/Foundation.h>
#import "messages.g.h"
#import <Firebase/Firebase.h>

@interface PigeonParser : NSObject

+ (PigeonUserCredential *_Nullable)getPigeonUserCredentialFromAuthResult:(nonnull FIRAuthDataResult *)authResult;
+ (PigeonUserDetails *_Nullable)getPigeonDetails:(nonnull FIRUser *)user;
+ (PigeonUserInfo *_Nullable)getPigeonUserInfo:(nonnull FIRUser *)user;
+ (PigeonActionCodeInfo *_Nullable)parseActionCode:(nonnull FIRActionCodeInfo*) info;
+ (FIRActionCodeSettings *_Nullable)parseActionCodeSettings:(nullable PigeonActionCodeSettings*) settings;

@end
