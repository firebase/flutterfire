#import "FLTFirebaseAdMobReaderWriter_Internal.h"

typedef NS_ENUM(NSInteger, FirebaseAdMobField) {
  FirebaseAdMobFieldAdRequest = 128,
  FirebaseAdMobFieldAdSize = 129,
};

@implementation FLTFirebaseAdMobReaderWriter
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTFirebaseAdMobReader alloc] initWithData:data];
}
@end

@implementation FLTFirebaseAdMobReader
- (id)readValueOfType:(UInt8)type {
  FirebaseAdMobField field = (FirebaseAdMobField)type;
  switch (field) {
    case FirebaseAdMobFieldAdRequest:
      return [[FLTAdRequest alloc] init];
    case FirebaseAdMobFieldAdSize:
      return [[FLTAdSize alloc] initWithWidth:[self readValueOfType:[self readByte]]
                                       height:[self readValueOfType:[self readByte]]];
  }
  return [super readValueOfType:type];
}
@end
