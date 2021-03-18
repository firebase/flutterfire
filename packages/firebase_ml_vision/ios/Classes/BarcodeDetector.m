// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseMlVisionPlugin.h"

@import MLKitBarcodeScanning;

@interface BarcodeDetector ()
@property MLKBarcodeScanner *detector;
@end

@implementation BarcodeDetector
- (instancetype)initWithOptions:(NSDictionary *)options {
  self = [super init];
  if (self) {
    _detector =
        [MLKBarcodeScanner barcodeScannerWithOptions:[BarcodeDetector parseOptions:options]];
  }
  return self;
}

- (void)handleDetection:(MLKVisionImage *)image result:(FlutterResult)result {
  [_detector processImage:image
               completion:^(NSArray<MLKBarcode *> *barcodes, NSError *error) {
                 if (error) {
                   [FLTFirebaseMlVisionPlugin handleError:error result:result];
                   return;
                 } else if (!barcodes) {
                   result(@[]);
                   return;
                 }

                 NSMutableArray *ret = [NSMutableArray array];
                 for (MLKBarcode *barcode in barcodes) {
                   [ret addObject:visionBarcodeToDictionary(barcode)];
                 }
                 result(ret);
               }];
}

NSDictionary *visionBarcodeToDictionary(MLKBarcode *barcode) {
  __block NSMutableArray<NSArray *> *points = [NSMutableArray array];

  for (NSValue *point in barcode.cornerPoints) {
    [points addObject:@[ @(point.CGPointValue.x), @(point.CGPointValue.y) ]];
  }
  return @{
    @"rawValue" : barcode.rawValue,
    @"displayValue" : barcode.displayValue ? barcode.displayValue : [NSNull null],
    @"left" : @(barcode.frame.origin.x),
    @"top" : @(barcode.frame.origin.y),
    @"width" : @(barcode.frame.size.width),
    @"height" : @(barcode.frame.size.height),
    @"format" : @(barcode.format),
    @"valueType" : @(barcode.valueType),
    @"points" : points,
    @"wifi" : barcode.wifi ? visionBarcodeWiFiToDictionary(barcode.wifi) : [NSNull null],
    @"email" : barcode.email ? visionBarcodeEmailToDictionary(barcode.email) : [NSNull null],
    @"phone" : barcode.phone ? visionBarcodePhoneToDictionary(barcode.phone) : [NSNull null],
    @"sms" : barcode.sms ? visionBarcodeSMSToDictionary(barcode.sms) : [NSNull null],
    @"url" : barcode.URL ? visionBarcodeURLToDictionary(barcode.URL) : [NSNull null],
    @"geoPoint" : barcode.geoPoint ? visionBarcodeGeoPointToDictionary(barcode.geoPoint)
                                   : [NSNull null],
    @"contactInfo" : barcode.contactInfo ? barcodeContactInfoToDictionary(barcode.contactInfo)
                                         : [NSNull null],
    @"calendarEvent" : barcode.calendarEvent ? calendarEventToDictionary(barcode.calendarEvent)
                                             : [NSNull null],
    @"driverLicense" : barcode.driverLicense ? driverLicenseToDictionary(barcode.driverLicense)
                                             : [NSNull null],
  };
}

NSDictionary *visionBarcodeWiFiToDictionary(MLKBarcodeWiFi *wifi) {
  return @{
    @"ssid" : wifi.ssid,
    @"password" : wifi.password,
    @"encryptionType" : @(wifi.type),
  };
}

NSDictionary *visionBarcodeEmailToDictionary(MLKBarcodeEmail *email) {
  return @{
    @"address" : email.address,
    @"body" : email.body,
    @"subject" : email.subject,
    @"type" : @(email.type),
  };
}

NSDictionary *visionBarcodePhoneToDictionary(MLKBarcodePhone *phone) {
  return @{
    @"number" : phone.number,
    @"type" : @(phone.type),
  };
}

NSDictionary *visionBarcodeSMSToDictionary(MLKBarcodeSMS *sms) {
  return @{
    @"phoneNumber" : sms.phoneNumber,
    @"message" : sms.message,
  };
}

NSDictionary *visionBarcodeURLToDictionary(MLKBarcodeURLBookmark *url) {
  return @{
    @"title" : url.title ? url.title : [NSNull null],
    @"url" : url.url ? url.url : [NSNull null],
  };
}

NSDictionary *visionBarcodeGeoPointToDictionary(MLKBarcodeGeoPoint *geo) {
  return @{
    @"longitude" : @(geo.longitude),
    @"latitude" : @(geo.latitude),
  };
}

NSDictionary *barcodeContactInfoToDictionary(MLKBarcodeContactInfo *contact) {
  __block NSMutableArray<NSDictionary *> *addresses = [NSMutableArray array];
  [contact.addresses enumerateObjectsUsingBlock:^(MLKBarcodeAddress *_Nonnull address,
                                                  NSUInteger idx, BOOL *_Nonnull stop) {
    __block NSMutableArray<NSString *> *addressLines = [NSMutableArray array];
    [address.addressLines enumerateObjectsUsingBlock:^(NSString *_Nonnull addressLine,
                                                       NSUInteger idx, BOOL *_Nonnull stop) {
      [addressLines addObject:addressLine];
    }];
    [addresses addObject:@{
      @"addressLines" : addressLines,
      @"type" : @(address.type),
    }];
  }];

  __block NSMutableArray<NSDictionary *> *emails = [NSMutableArray array];
  [contact.emails enumerateObjectsUsingBlock:^(MLKBarcodeEmail *_Nonnull email, NSUInteger idx,
                                               BOOL *_Nonnull stop) {
    [emails addObject:@{
      @"address" : email.address ? email.address : [NSNull null],
      @"body" : email.body ? email.body : [NSNull null],
      @"subject" : email.subject ? email.subject : [NSNull null],
      @"type" : @(email.type),
    }];
  }];

  __block NSMutableArray<NSDictionary *> *phones = [NSMutableArray array];
  [contact.phones enumerateObjectsUsingBlock:^(MLKBarcodePhone *_Nonnull phone, NSUInteger idx,
                                               BOOL *_Nonnull stop) {
    [phones addObject:@{
      @"number" : phone.number ? phone.number : [NSNull null],
      @"type" : @(phone.type),
    }];
  }];

  __block NSMutableArray<NSString *> *urls = [NSMutableArray array];
  [contact.urls
      enumerateObjectsUsingBlock:^(NSString *_Nonnull url, NSUInteger idx, BOOL *_Nonnull stop) {
        [urls addObject:url];
      }];
  return @{
    @"addresses" : addresses,
    @"emails" : emails,
    @"phones" : phones,
    @"urls" : urls,
    @"name" : @{
      @"formattedName" : contact.name.formattedName ? contact.name.formattedName : [NSNull null],
      @"first" : contact.name.first ? contact.name.first : [NSNull null],
      @"last" : contact.name.last ? contact.name.last : [NSNull null],
      @"middle" : contact.name.middle ? contact.name.middle : [NSNull null],
      @"prefix" : contact.name.prefix ? contact.name.prefix : [NSNull null],
      @"pronunciation" : contact.name.pronunciation ? contact.name.pronunciation : [NSNull null],
      @"suffix" : contact.name.suffix ? contact.name.suffix : [NSNull null],
    },
    @"jobTitle" : contact.jobTitle ? contact.jobTitle : [NSNull null],
    @"organization" : contact.organization ? contact.jobTitle : [NSNull null],
  };
}

NSDictionary *calendarEventToDictionary(MLKBarcodeCalendarEvent *calendar) {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
  dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
  return @{
    @"eventDescription" : calendar.eventDescription,
    @"location" : calendar.location,
    @"organizer" : calendar.organizer,
    @"status" : calendar.status,
    @"summary" : calendar.summary,
    @"start" : [dateFormatter stringFromDate:calendar.start],
    @"end" : [dateFormatter stringFromDate:calendar.end],
  };
}

NSDictionary *driverLicenseToDictionary(MLKBarcodeDriverLicense *license) {
  return @{
    @"firstName" : license.firstName,
    @"middleName" : license.middleName,
    @"lastName" : license.lastName,
    @"gender" : license.gender,
    @"addressCity" : license.addressCity,
    @"addressStreet" : license.addressStreet,
    @"addressState" : license.addressState,
    @"addressZip" : license.addressZip,
    @"birthDate" : license.birthDate,
    @"documentType" : license.documentType,
    @"licenseNumber" : license.licenseNumber,
    @"expiryDate" : license.expiryDate,
    @"issuingDate" : license.issuingDate,
    @"issuingCountry" : license.issuingCountry,
  };
}

+ (MLKBarcodeScannerOptions *)parseOptions:(NSDictionary *)optionsData {
  NSNumber *barcodeFormat = optionsData[@"barcodeFormats"];
  return
      [[MLKBarcodeScannerOptions alloc] initWithFormats:(MLKBarcodeFormat)barcodeFormat.intValue];
}
@end
