/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#import "include/cloud_firestore/Private/FLTPipelineParser.h"

#if TARGET_OS_OSX
#import <FirebaseFirestore/FirebaseFirestore.h>
#import "FirebaseFirestoreInternal/FIRPipelineBridge.h"
#else
@import FirebaseFirestore;
#if __has_include("FIRPipelineBridge.h")
#import "FIRPipelineBridge.h"
#endif
#endif

#import <Foundation/Foundation.h>

static NSString *const kPipelineNotAvailable =
    @"Pipeline API is not available. Firestore Pipelines require Firebase iOS SDK with pipeline "
     "support.";

static NSError *pipelineUnavailableError(void) {
  return [NSError errorWithDomain:@"FLTFirebaseFirestore"
                             code:-1
                         userInfo:@{NSLocalizedDescriptionKey : kPipelineNotAvailable}];
}

#if TARGET_OS_OSX
#if __has_include("FirebaseFirestoreInternal/FIRPipelineBridge.h")
#define FLT_PIPELINE_AVAILABLE 1
#endif
#else
#if __has_include("FIRPipelineBridge.h")
#define FLT_PIPELINE_AVAILABLE 1
#endif
#endif

#if FLT_PIPELINE_AVAILABLE

static NSError *parseError(NSString *message) {
  return [NSError errorWithDomain:@"FLTFirebaseFirestore"
                             code:-1
                         userInfo:@{NSLocalizedDescriptionKey : message}];
}

@interface FLTPipelineExpressionParser : NSObject
@property(nonatomic, strong) FIRFirestore *firestore;
- (instancetype)initWithFirestore:(FIRFirestore *)firestore;
- (FIRExprBridge *)parseExpression:(NSDictionary<NSString *, id> *)map error:(NSError **)error;
- (FIRExprBridge *)parseBooleanExpression:(NSDictionary<NSString *, id> *)map
                                    error:(NSError **)error;
- (FIRExprBridge *)rightExprFromValue:(id)value error:(NSError **)error;
@end

@implementation FLTPipelineExpressionParser

- (instancetype)initWithFirestore:(FIRFirestore *)firestore {
  self = [super init];
  if (self) {
    _firestore = firestore;
  }
  return self;
}

- (FIRExprBridge *)parseExpression:(NSDictionary<NSString *, id> *)map error:(NSError **)error {
  NSString *name = map[@"name"];
  if (!name) {
    NSDictionary *args = map[@"args"];
    if ([args isKindOfClass:[NSDictionary class]] && args[@"field"]) {
      return [[FIRFieldBridge alloc] initWithName:args[@"field"]];
    }
    if (error) *error = parseError(@"Expression must have a 'name' field");
    return nil;
  }

  NSDictionary *args = map[@"args"];
  if (![args isKindOfClass:[NSDictionary class]]) args = @{};

  if ([name isEqualToString:@"field"]) {
    NSString *field = args[@"field"];
    if (!field) {
      if (error) *error = parseError(@"Field expression requires 'field' argument");
      return nil;
    }
    return [[FIRFieldBridge alloc] initWithName:field];
  }

  if ([name isEqualToString:@"constant"]) {
    id value = args[@"value"];
    if (value == nil) {
      if (error) *error = parseError(@"Constant requires 'value' argument");
      return nil;
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
      NSString *path = ((NSDictionary *)value)[@"path"];
      if ([path isKindOfClass:[NSString class]] && self.firestore) {
        FIRDocumentReference *docRef = [self.firestore documentWithPath:path];
        return [[FIRConstantBridge alloc] init:docRef];
      }
    }
    return [[FIRConstantBridge alloc] init:value];
  }

  if ([name isEqualToString:@"alias"]) {
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"Alias requires 'expression'");
      return nil;
    }
    // No explicit AliasedExpression type in ObjC; aliases are dict keys when building stages.
    // Parse and return the inner expression; the caller uses args[@"alias"] as the dict key.
    return [self parseExpression:exprMap error:error];
  }

  if ([name isEqualToString:@"null"]) {
    return [[FIRConstantBridge alloc] init:[NSNull null]];
  }

  // Map Dart names to iOS SDK names where they differ
  NSString *sdkName = name;
  if ([name isEqualToString:@"bit_xor"]) sdkName = @"xor";
  if ([name isEqualToString:@"modulo"]) sdkName = @"mod";

  // -------------------------------------------------------------------------
  // Binary expressions (left + right): comparisons, arithmetic, bitwise
  // -------------------------------------------------------------------------
  static NSArray *binaryNames = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    binaryNames = @[
      @"equal", @"not_equal", @"greater_than", @"greater_than_or_equal", @"less_than",
      @"less_than_or_equal", @"add", @"subtract", @"multiply", @"divide", @"mod", @"bit_and",
      @"bit_or", @"bit_left_shift", @"bit_right_shift"
    ];
  });
  if ([binaryNames containsObject:sdkName] || [name isEqualToString:@"bit_xor"]) {
    id leftMap = args[@"left"];
    id rightMap = args[@"right"];
    if (![leftMap isKindOfClass:[NSDictionary class]] ||
        ![rightMap isKindOfClass:[NSDictionary class]]) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires left and right expressions", name]);
      return nil;
    }
    FIRExprBridge *left = [self parseExpression:leftMap error:error];
    FIRExprBridge *right = [self parseExpression:rightMap error:error];
    if (!left || !right) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:sdkName Args:@[ left, right ]];
  }

  // -------------------------------------------------------------------------
  // Unary expressions (single expression): exists, is_error, is_absent, not
  // -------------------------------------------------------------------------
  NSArray *unaryNames = @[ @"exists", @"is_error", @"is_absent", @"not" ];
  if ([unaryNames containsObject:name]) {
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError([NSString stringWithFormat:@"%@ requires expression", name]);
      return nil;
    }
    FIRExprBridge *expr = [name isEqualToString:@"not"]
                              ? [self parseBooleanExpression:exprMap error:error]
                              : [self parseExpression:exprMap error:error];
    if (!expr) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:@[ expr ]];
  }

  // -------------------------------------------------------------------------
  // Unary with optional SDK name mapping: length, to_lower, to_upper, trim,
  // abs, array_length, array_reverse, bit_not, document_id, collection_id
  // -------------------------------------------------------------------------
  NSArray *unaryWithSdkName = @[
    @"length", @"to_lower_case", @"to_upper_case", @"trim", @"abs", @"array_length",
    @"array_reverse", @"bit_not", @"document_id", @"collection_id"
  ];
  if ([unaryWithSdkName containsObject:name]) {
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError([NSString stringWithFormat:@"%@ requires expression", name]);
      return nil;
    }
    FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    if (!expr) return nil;
    NSString *unarySdkName = name;
    if ([name isEqualToString:@"to_lower_case"]) unarySdkName = @"to_lower";
    if ([name isEqualToString:@"to_upper_case"]) unarySdkName = @"to_upper";
    return [[FIRFunctionExprBridge alloc] initWithName:unarySdkName Args:@[ expr ]];
  }

  // -------------------------------------------------------------------------
  // N-ary logical (expressions array): and, or, xor
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"and"] || [name isEqualToString:@"or"] ||
      [name isEqualToString:@"xor"]) {
    NSArray *exprMaps = args[@"expressions"];
    if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires at least one expression", name]);
      return nil;
    }
    NSMutableArray<FIRExprBridge *> *all = [NSMutableArray array];
    for (id em in exprMaps) {
      if (![em isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *e = [self parseBooleanExpression:em error:error];
      if (!e) return nil;
      [all addObject:e];
    }
    if (all.count == 0) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires at least one expression", name]);
      return nil;
    }
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:all];
  }

  // -------------------------------------------------------------------------
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"equal_any"] || [name isEqualToString:@"not_equal_any"]) {
    id valueMap = args[@"value"];
    NSArray *valuesMaps = args[@"values"];
    if (![valueMap isKindOfClass:[NSDictionary class]] ||
        ![valuesMaps isKindOfClass:[NSArray class]] || valuesMaps.count == 0) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires value and non-empty values", name]);
      return nil;
    }
    FIRExprBridge *valueExpr = [self parseExpression:valueMap error:error];
    if (!valueExpr) return nil;
    NSMutableArray<FIRExprBridge *> *valueExprs = [NSMutableArray array];
    for (id vm in valuesMaps) {
      if (![vm isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *ve = [self parseExpression:vm error:error];
      if (!ve) return nil;
      [valueExprs addObject:ve];
    }
    if (valueExprs.count == 0) {
      if (error)
        *error = parseError([NSString stringWithFormat:@"%@ requires at least one value", name]);
      return nil;
    }
    FIRExprBridge *valuesArrayExpr = [[FIRFunctionExprBridge alloc] initWithName:@"array"
                                                                            Args:valueExprs];
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:@[ valueExpr, valuesArrayExpr ]];
  }

  // -------------------------------------------------------------------------
  // array + element: array_contains
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array_contains"]) {
    id arrayMap = args[@"array"];
    id elementMap = args[@"element"];
    if (![arrayMap isKindOfClass:[NSDictionary class]] ||
        ![elementMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"array_contains requires array and element");
      return nil;
    }
    FIRExprBridge *arrayExpr = [self parseExpression:arrayMap error:error];
    FIRExprBridge *elementExpr = [self parseExpression:elementMap error:error];
    if (!arrayExpr || !elementExpr) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:@[ arrayExpr, elementExpr ]];
  }

  // -------------------------------------------------------------------------
  // array + values[]: array_contains_all, array_contains_any
  // SDK expects: array_contains_any(field, array(val1, val2, ...)) — two args.
  // Reuse the "array" expression parser to build the values array.
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array_contains_all"] ||
      [name isEqualToString:@"array_contains_any"]) {
    id arrayMap = args[@"array"];
    NSArray *valuesMaps = args[@"values"];
    if (![valuesMaps isKindOfClass:[NSArray class]]) valuesMaps = args[@"elements"];
    if (![arrayMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError([NSString stringWithFormat:@"%@ requires array", name]);
      return nil;
    }
    if (![valuesMaps isKindOfClass:[NSArray class]] || valuesMaps.count == 0) {
      if (error)
        *error = parseError(
            [NSString stringWithFormat:@"%@ requires array and at least one value", name]);
      return nil;
    }
    FIRExprBridge *arrayExpr = [self parseExpression:arrayMap error:error];
    if (!arrayExpr) return nil;
    NSDictionary *arrayExprMap = @{@"name" : @"array", @"args" : @{@"elements" : valuesMaps}};
    FIRExprBridge *valuesArrayExpr = [self parseExpression:arrayExprMap error:error];
    if (!valuesArrayExpr) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:@[ arrayExpr, valuesArrayExpr ]];
  }

  // -------------------------------------------------------------------------
  // expressions[]: concat (SDK: concat)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"concat"]) {
    NSArray *exprMaps = args[@"expressions"];
    if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
      if (error) *error = parseError(@"concat requires non-empty expressions");
      return nil;
    }
    NSMutableArray<FIRExprBridge *> *all = [NSMutableArray array];
    for (id em in exprMaps) {
      if (![em isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *e = [self parseExpression:em error:error];
      if (!e) return nil;
      [all addObject:e];
    }
    if (all.count == 0) {
      if (error) *error = parseError(@"concat requires at least one expression");
      return nil;
    }
    return [[FIRFunctionExprBridge alloc] initWithName:@"concat" Args:all];
  }

  // -------------------------------------------------------------------------
  // expression + start + end: substring (SDK: substring)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"substring"]) {
    id exprMap = args[@"expression"];
    id startMap = args[@"start"];
    id endMap = args[@"end"];
    if (![exprMap isKindOfClass:[NSDictionary class]] ||
        ![startMap isKindOfClass:[NSDictionary class]] ||
        ![endMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"substring requires expression, start, and end");
      return nil;
    }
    FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    FIRExprBridge *start = [self parseExpression:startMap error:error];
    FIRExprBridge *end = [self parseExpression:endMap error:error];
    if (!expr || !start || !end) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:@"substring" Args:@[ expr, start, end ]];
  }

  // -------------------------------------------------------------------------
  // expression + find + replacement: replace (SDK: string_replace)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"replace"]) {
    id exprMap = args[@"expression"];
    id findMap = args[@"find"];
    id replacementMap = args[@"replacement"];
    if (![exprMap isKindOfClass:[NSDictionary class]] ||
        ![findMap isKindOfClass:[NSDictionary class]] ||
        ![replacementMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"replace requires expression, find, and replacement");
      return nil;
    }
    FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    FIRExprBridge *find = [self parseExpression:findMap error:error];
    FIRExprBridge *replacement = [self parseExpression:replacementMap error:error];
    if (!expr || !find || !replacement) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:@"string_replace"
                                                  Args:@[ expr, find, replacement ]];
  }

  // -------------------------------------------------------------------------
  // expression + delimiter: split, join (SDK: split, join)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"split"] || [name isEqualToString:@"join"]) {
    id exprMap = args[@"expression"];
    id delimiterMap = args[@"delimiter"];
    if (![exprMap isKindOfClass:[NSDictionary class]] ||
        ![delimiterMap isKindOfClass:[NSDictionary class]]) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires expression and delimiter", name]);
      return nil;
    }
    FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    FIRExprBridge *delimiter = [self parseExpression:delimiterMap error:error];
    if (!expr || !delimiter) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:@[ expr, delimiter ]];
  }

  // -------------------------------------------------------------------------
  // first + second: array_concat (SDK: array_concat)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array_concat"]) {
    id firstMap = args[@"first"];
    id secondMap = args[@"second"];
    if (![firstMap isKindOfClass:[NSDictionary class]] ||
        ![secondMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"array_concat requires first and second");
      return nil;
    }
    FIRExprBridge *first = [self parseExpression:firstMap error:error];
    FIRExprBridge *second = [self parseExpression:secondMap error:error];
    if (!first || !second) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:@"array_concat" Args:@[ first, second ]];
  }

  // -------------------------------------------------------------------------
  // arrays[]: array_concat_multiple (SDK: array_concat)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array_concat_multiple"]) {
    NSArray *arraysMaps = args[@"arrays"];
    if (![arraysMaps isKindOfClass:[NSArray class]] || arraysMaps.count == 0) {
      if (error) *error = parseError(@"array_concat_multiple requires non-empty arrays");
      return nil;
    }
    NSMutableArray<FIRExprBridge *> *all = [NSMutableArray array];
    for (id am in arraysMaps) {
      if (![am isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *e = [self parseExpression:am error:error];
      if (!e) return nil;
      [all addObject:e];
    }
    if (all.count == 0) {
      if (error) *error = parseError(@"array_concat_multiple requires at least one array");
      return nil;
    }
    return [[FIRFunctionExprBridge alloc] initWithName:@"array_concat" Args:all];
  }

  // -------------------------------------------------------------------------
  // elements[]: array (construct) — Expression.array([...]) from Dart
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array"]) {
    NSArray *elementsMaps = args[@"elements"];
    if (![elementsMaps isKindOfClass:[NSArray class]] || elementsMaps.count == 0) {
      if (error) *error = parseError(@"array requires non-empty elements");
      return nil;
    }
    NSMutableArray<FIRExprBridge *> *elementExprs = [NSMutableArray array];
    for (id em in elementsMaps) {
      if (![em isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *e = [self parseExpression:em error:error];
      if (!e) return nil;
      [elementExprs addObject:e];
    }
    if (elementExprs.count == 0) {
      if (error) *error = parseError(@"array requires at least one element");
      return nil;
    }
    return [[FIRFunctionExprBridge alloc] initWithName:@"array" Args:elementExprs];
  }

  // -------------------------------------------------------------------------
  // data: map (construct) — Expression.map({ "k": expr, ... }) from Dart
  // SDK expects Args as alternating key (constant), value (expression).
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"map"]) {
    NSDictionary *dataMap = args[@"data"];
    if (![dataMap isKindOfClass:[NSDictionary class]] || dataMap.count == 0) {
      if (error) *error = parseError(@"map requires non-empty data");
      return nil;
    }
    NSMutableArray<FIRExprBridge *> *mapArgs = [NSMutableArray array];
    for (NSString *key in dataMap) {
      id valueMap = dataMap[key];
      if (![valueMap isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *keyExpr = [[FIRConstantBridge alloc] init:key];
      FIRExprBridge *valueExpr = [self parseExpression:valueMap error:error];
      if (!valueExpr) return nil;
      [mapArgs addObject:keyExpr];
      [mapArgs addObject:valueExpr];
    }
    if (mapArgs.count == 0) {
      if (error) *error = parseError(@"map requires at least one key-value pair");
      return nil;
    }
    return [[FIRFunctionExprBridge alloc] initWithName:@"map" Args:mapArgs];
  }

  // -------------------------------------------------------------------------
  // map + key: map_get (SDK: map_get)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"map_get"]) {
    id mapMap = args[@"map"];
    id keyMap = args[@"key"];
    if (![mapMap isKindOfClass:[NSDictionary class]] ||
        ![keyMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"map_get requires map and key");
      return nil;
    }
    FIRExprBridge *mapExpr = [self parseExpression:mapMap error:error];
    FIRExprBridge *keyExpr = [self parseExpression:keyMap error:error];
    if (!mapExpr || !keyExpr) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:@"map_get" Args:@[ mapExpr, keyExpr ]];
  }

  // -------------------------------------------------------------------------
  // expression + else: if_absent (SDK: if_absent)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"if_absent"]) {
    id exprMap = args[@"expression"];
    id elseMap = args[@"else"];
    if (![exprMap isKindOfClass:[NSDictionary class]] ||
        ![elseMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"if_absent requires expression and else");
      return nil;
    }
    FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    FIRExprBridge *elseExpr = [self parseExpression:elseMap error:error];
    if (!expr || !elseExpr) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:@"if_absent" Args:@[ expr, elseExpr ]];
  }

  // -------------------------------------------------------------------------
  // expression + catch: if_error (SDK: if_error)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"if_error"]) {
    id exprMap = args[@"expression"];
    id catchMap = args[@"catch"];
    if (![exprMap isKindOfClass:[NSDictionary class]] ||
        ![catchMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"if_error requires expression and catch");
      return nil;
    }
    FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    FIRExprBridge *catchExpr = [self parseExpression:catchMap error:error];
    if (!expr || !catchExpr) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:@"if_error" Args:@[ expr, catchExpr ]];
  }

  // -------------------------------------------------------------------------
  // condition + then + else: conditional (SDK: conditional)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"conditional"]) {
    id conditionMap = args[@"condition"];
    id thenMap = args[@"then"];
    id elseMap = args[@"else"];
    if (![conditionMap isKindOfClass:[NSDictionary class]] ||
        ![thenMap isKindOfClass:[NSDictionary class]] ||
        ![elseMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"conditional requires condition, then, and else");
      return nil;
    }
    FIRExprBridge *condition = [self parseBooleanExpression:conditionMap error:error];
    FIRExprBridge *thenExpr = [self parseExpression:thenMap error:error];
    FIRExprBridge *elseExpr = [self parseExpression:elseMap error:error];
    if (!condition || !thenExpr || !elseExpr) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:@"conditional"
                                                  Args:@[ condition, thenExpr, elseExpr ]];
  }

  // -------------------------------------------------------------------------
  // timestamp + amount + unit: timestamp_add, timestamp_subtract (SDK: Args ts, amount, unit)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"timestamp_add"] || [name isEqualToString:@"timestamp_subtract"]) {
    id timestampMap = args[@"timestamp"];
    id unitVal = args[@"unit"];
    id amountMap = args[@"amount"];
    if (![timestampMap isKindOfClass:[NSDictionary class]] || !unitVal ||
        ![amountMap isKindOfClass:[NSDictionary class]]) {
      if (error)
        *error = parseError(
            [NSString stringWithFormat:@"%@ requires timestamp, unit, and amount", name]);
      return nil;
    }
    FIRExprBridge *timestampExpr = [self parseExpression:timestampMap error:error];
    FIRExprBridge *amountExpr = [self parseExpression:amountMap error:error];
    if (!timestampExpr || !amountExpr) return nil;
    FIRExprBridge *unitExpr = [[FIRConstantBridge alloc] init:unitVal];
    return [[FIRFunctionExprBridge alloc] initWithName:name
                                                  Args:@[ timestampExpr, unitExpr, amountExpr ]];
  }

  // -------------------------------------------------------------------------
  // No args: current_timestamp (SDK: current_timestamp with empty Args)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"current_timestamp"]) {
    return [[FIRFunctionExprBridge alloc] initWithName:@"current_timestamp" Args:@[]];
  }

  // -------------------------------------------------------------------------
  // timestamp + unit: timestamp_truncate (SDK: timestamp_trunc)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"timestamp_truncate"]) {
    id timestampMap = args[@"timestamp"];
    id unitVal = args[@"unit"];
    if (![timestampMap isKindOfClass:[NSDictionary class]] || !unitVal) {
      if (error) *error = parseError(@"timestamp_truncate requires timestamp and unit");
      return nil;
    }
    FIRExprBridge *timestampExpr = [self parseExpression:timestampMap error:error];
    if (!timestampExpr) return nil;
    FIRExprBridge *unitExpr = [[FIRConstantBridge alloc] init:unitVal];
    return [[FIRFunctionExprBridge alloc] initWithName:@"timestamp_trunc"
                                                  Args:@[ timestampExpr, unitExpr ]];
  }

  // -------------------------------------------------------------------------
  // PipelineFilter (name "filter"): operator-based (and/or) or field-based
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"filter"]) {
    return [self parseFilterExpressionWithArgs:args error:error];
  }

  if (error) *error = parseError([NSString stringWithFormat:@"Unsupported expression: %@", name]);
  return nil;
}

- (FIRExprBridge *)rightExprFromValue:(id)value error:(NSError **)error {
  if ([value isKindOfClass:[NSDictionary class]]) {
    return [self parseExpression:(NSDictionary *)value error:error];
  }
  return [[FIRConstantBridge alloc] init:value];
}

- (FIRExprBridge *)parseFilterExpressionWithArgs:(NSDictionary *)args error:(NSError **)error {
  // Operator-based: and/or with expressions array (from PipelineFilter.and / .or)
  NSString *operator= args[@"operator"];
  NSArray *exprMaps = args[@"expressions"];
  if ([operator isKindOfClass:[NSString class]] && [exprMaps isKindOfClass:[NSArray class]]) {
    if (exprMaps.count == 0) {
      if (error) *error = parseError(@"filter with operator requires at least one expression");
      return nil;
    }
    if (exprMaps.count == 1) {
      id em = exprMaps[0];
      if (![em isKindOfClass:[NSDictionary class]]) {
        if (error) *error = parseError(@"filter expressions must be maps");
        return nil;
      }
      return [self parseBooleanExpression:(NSDictionary *)em error:error];
    }
    NSMutableArray<FIRExprBridge *> *all = [NSMutableArray array];
    for (id em in exprMaps) {
      if (![em isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *e = [self parseBooleanExpression:(NSDictionary *)em error:error];
      if (!e) return nil;
      [all addObject:e];
    }
    if (all.count == 0) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:operator Args:all];
  }

  // Field-based: field + isEqualTo, isGreaterThan, etc.
  NSString *fieldName = args[@"field"];
  if (![fieldName isKindOfClass:[NSString class]]) {
    if (error) *error = parseError(@"filter requires operator+expressions or field");
    return nil;
  }
  FIRExprBridge *fieldExpr = [[FIRFieldBridge alloc] initWithName:fieldName];

  static NSArray *filterComparisonKeys = nil;
  static dispatch_once_t filterOnce;
  dispatch_once(&filterOnce, ^{
    filterComparisonKeys = @[
      @"isEqualTo", @"isNotEqualTo", @"isGreaterThan", @"isGreaterThanOrEqualTo", @"isLessThan",
      @"isLessThanOrEqualTo", @"arrayContains", @"arrayContainsAny", @"whereIn", @"whereNotIn",
      @"isNull", @"isNotNull"
    ];
  });
  for (NSString *key in filterComparisonKeys) {
    id value = args[key];
    if (value == nil) continue;

    if ([key isEqualToString:@"isEqualTo"]) {
      FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return [[FIRFunctionExprBridge alloc] initWithName:@"equal" Args:@[ fieldExpr, right ]];
    }
    if ([key isEqualToString:@"isNotEqualTo"]) {
      FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return [[FIRFunctionExprBridge alloc] initWithName:@"not_equal" Args:@[ fieldExpr, right ]];
    }
    if ([key isEqualToString:@"isGreaterThan"]) {
      FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return [[FIRFunctionExprBridge alloc] initWithName:@"greater_than"
                                                    Args:@[ fieldExpr, right ]];
    }
    if ([key isEqualToString:@"isGreaterThanOrEqualTo"]) {
      FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return [[FIRFunctionExprBridge alloc] initWithName:@"greater_than_or_equal"
                                                    Args:@[ fieldExpr, right ]];
    }
    if ([key isEqualToString:@"isLessThan"]) {
      FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return [[FIRFunctionExprBridge alloc] initWithName:@"less_than" Args:@[ fieldExpr, right ]];
    }
    if ([key isEqualToString:@"isLessThanOrEqualTo"]) {
      FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return [[FIRFunctionExprBridge alloc] initWithName:@"less_than_or_equal"
                                                    Args:@[ fieldExpr, right ]];
    }
    if ([key isEqualToString:@"arrayContains"]) {
      FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return [[FIRFunctionExprBridge alloc] initWithName:@"array_contains"
                                                    Args:@[ fieldExpr, right ]];
    }
    if ([key isEqualToString:@"arrayContainsAny"] || [key isEqualToString:@"whereIn"]) {
      NSArray *valuesList = [value isKindOfClass:[NSArray class]] ? value : @[];
      NSMutableArray<FIRExprBridge *> *valueExprs = [NSMutableArray array];
      for (id v in valuesList) {
        FIRExprBridge *ve = [self rightExprFromValue:v error:error];
        if (!ve) return nil;
        [valueExprs addObject:ve];
      }
      if (valueExprs.count == 0) {
        if (error) *error = parseError(@"arrayContainsAny/whereIn requires non-empty list");
        return nil;
      }
      // SDK expects (value, array) not (value, v1, v2, ...); wrap in "array" expr.
      FIRExprBridge *valuesArrayExpr = [[FIRFunctionExprBridge alloc] initWithName:@"array"
                                                                              Args:valueExprs];
      return [[FIRFunctionExprBridge alloc] initWithName:@"equal_any"
                                                    Args:@[ fieldExpr, valuesArrayExpr ]];
    }
    if ([key isEqualToString:@"whereNotIn"]) {
      NSArray *valuesList = [value isKindOfClass:[NSArray class]] ? value : @[];
      NSMutableArray<FIRExprBridge *> *valueExprs = [NSMutableArray array];
      for (id v in valuesList) {
        FIRExprBridge *ve = [self rightExprFromValue:v error:error];
        if (!ve) return nil;
        [valueExprs addObject:ve];
      }
      if (valueExprs.count == 0) {
        if (error) *error = parseError(@"whereNotIn requires non-empty list");
        return nil;
      }
      // SDK expects (value, array) not (value, v1, v2, ...); wrap in "array" expr.
      FIRExprBridge *valuesArrayExpr = [[FIRFunctionExprBridge alloc] initWithName:@"array"
                                                                              Args:valueExprs];
      return [[FIRFunctionExprBridge alloc] initWithName:@"not_equal_any"
                                                    Args:@[ fieldExpr, valuesArrayExpr ]];
    }
    if ([key isEqualToString:@"isNull"]) {
      FIRExprBridge *right = [[FIRConstantBridge alloc] init:[NSNull null]];
      return [[FIRFunctionExprBridge alloc] initWithName:@"equal" Args:@[ fieldExpr, right ]];
    }
    if ([key isEqualToString:@"isNotNull"]) {
      FIRExprBridge *right = [[FIRConstantBridge alloc] init:[NSNull null]];
      return [[FIRFunctionExprBridge alloc] initWithName:@"not_equal" Args:@[ fieldExpr, right ]];
    }
  }

  if (error)
    *error =
        parseError(@"filter requires at least one comparison (isEqualTo, isGreaterThan, etc.)");
  return nil;
}

- (FIRExprBridge *)parseBooleanExpression:(NSDictionary<NSString *, id> *)map
                                    error:(NSError **)error {
  return [self parseExpression:map error:error];
}

@end

@implementation FLTPipelineParser

/// Returns the key (alias or field name) for an expression map in select/distinct stages.
/// Uses args.alias if present; otherwise for "field" expressions uses args.field. Returns nil if
/// no key can be determined (caller should error).
+ (NSString *)keyForExpressionMap:(NSDictionary *)em error:(NSError **)error {
  NSString *alias = [em valueForKeyPath:@"args.alias"];
  if ([alias isKindOfClass:[NSString class]] && alias.length > 0) {
    return alias;
  }
  if ([em[@"name"] isEqualToString:@"field"]) {
    NSString *field = [em valueForKeyPath:@"args.field"];
    if ([field isKindOfClass:[NSString class]]) return field;
    if (error) *error = parseError(@"field expression must have args.field");
    return nil;
  }
  if (error)
    *error = parseError(@"select/distinct expression must have alias or be a field reference");
  return nil;
}

+ (NSArray<FIRStageBridge *> *)
    parseStagesWithFirestore:(FIRFirestore *)firestore
                      stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                       error:(NSError **)error {
  FLTPipelineExpressionParser *exprParser =
      [[FLTPipelineExpressionParser alloc] initWithFirestore:firestore];
  NSMutableArray<FIRStageBridge *> *stageBridges = [NSMutableArray array];
  NSError *parseErr = nil;

  for (NSUInteger i = 0; i < stages.count; i++) {
    NSDictionary *stageMap = stages[i];
    if (![stageMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"Stage must be a map");
      return nil;
    }
    NSString *stageName = stageMap[@"stage"];
    if (![stageName isKindOfClass:[NSString class]]) {
      if (error) *error = parseError(@"Stage must have a 'stage' field");
      return nil;
    }
    id argsObj = stageMap[@"args"];
    NSDictionary *args = [argsObj isKindOfClass:[NSDictionary class]] ? argsObj : @{};
    NSArray *argsArray = [argsObj isKindOfClass:[NSArray class]] ? argsObj : nil;

    FIRStageBridge *stage = nil;

    if (i == 0) {
      if ([stageName isEqualToString:@"collection"]) {
        NSString *path = args[@"path"];
        if (!path) {
          if (error) *error = parseError(@"collection requires 'path'");
          return nil;
        }
        FIRCollectionReference *ref = [firestore collectionWithPath:path];
        stage = [[FIRCollectionSourceStageBridge alloc] initWithRef:ref firestore:firestore];
      } else if ([stageName isEqualToString:@"collection_group"]) {
        NSString *path = args[@"path"];
        if (!path) {
          if (error) *error = parseError(@"collection_group requires 'path'");
          return nil;
        }
        stage = [[FIRCollectionGroupSourceStageBridge alloc] initWithCollectionId:path];
      } else if ([stageName isEqualToString:@"database"]) {
        stage = [[FIRDatabaseSourceStageBridge alloc] init];
      } else if ([stageName isEqualToString:@"documents"]) {
        NSArray *docMaps = argsArray;
        if (!docMaps || docMaps.count == 0) {
          if (error) *error = parseError(@"documents requires array of document refs");
          return nil;
        }
        NSMutableArray<FIRDocumentReference *> *refs = [NSMutableArray array];
        for (id docMap in docMaps) {
          if (![docMap isKindOfClass:[NSDictionary class]]) continue;
          NSString *path = ((NSDictionary *)docMap)[@"path"];
          if (path) [refs addObject:[firestore documentWithPath:path]];
        }
        stage = [[FIRDocumentsSourceStageBridge alloc] initWithDocuments:refs firestore:firestore];
      } else {
        if (error)
          *error = parseError(
              [NSString stringWithFormat:@"First stage must be collection, collection_group, "
                                         @"documents, or database. Got: %@",
                                         stageName]);
        return nil;
      }
    } else {
      if ([stageName isEqualToString:@"where"]) {
        id exprMap = args[@"expression"];
        if (![exprMap isKindOfClass:[NSDictionary class]]) {
          if (error) *error = parseError(@"where requires expression");
          return nil;
        }
        FIRExprBridge *expr = [exprParser parseBooleanExpression:exprMap error:&parseErr];
        if (!expr) {
          if (error) *error = parseErr;
          return nil;
        }
        stage = [[FIRWhereStageBridge alloc] initWithExpr:expr];
      } else if ([stageName isEqualToString:@"limit"]) {
        NSNumber *limit = args[@"limit"];
        if (![limit isKindOfClass:[NSNumber class]]) {
          if (error) *error = parseError(@"limit requires numeric limit");
          return nil;
        }
        stage = [[FIRLimitStageBridge alloc] initWithLimit:limit.intValue];
      } else if ([stageName isEqualToString:@"offset"]) {
        NSNumber *offset = args[@"offset"];
        if (![offset isKindOfClass:[NSNumber class]]) {
          if (error) *error = parseError(@"offset requires numeric offset");
          return nil;
        }
        stage = [[FIROffsetStageBridge alloc] initWithOffset:offset.intValue];
      } else if ([stageName isEqualToString:@"sort"]) {
        NSArray *orderingMaps = args[@"orderings"];
        if (![orderingMaps isKindOfClass:[NSArray class]] || orderingMaps.count == 0) {
          if (error) *error = parseError(@"sort requires at least one ordering");
          return nil;
        }
        NSMutableArray<FIROrderingBridge *> *orderings = [NSMutableArray array];
        for (id om in orderingMaps) {
          if (![om isKindOfClass:[NSDictionary class]]) continue;
          id exprMap = ((NSDictionary *)om)[@"expression"];
          NSString *dir = ((NSDictionary *)om)[@"order_direction"];
          if (![exprMap isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:exprMap error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
          }
          NSString *direction = [dir isEqualToString:@"asc"] ? @"ascending" : @"descending";
          FIROrderingBridge *ordering = [[FIROrderingBridge alloc] initWithExpr:expr
                                                                      Direction:direction];
          [orderings addObject:ordering];
        }
        if (orderings.count == 0) {
          if (error) *error = parseError(@"sort requires at least one ordering");
          return nil;
        }
        stage = [[FIRSorStageBridge alloc] initWithOrderings:orderings];
      } else if ([stageName isEqualToString:@"select"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          if (error) *error = parseError(@"select requires at least one expression");
          return nil;
        }
        NSMutableDictionary<NSString *, FIRExprBridge *> *fields = [NSMutableDictionary dictionary];
        for (id em in exprMaps) {
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
          }
          NSString *key = [self keyForExpressionMap:em error:error];
          if (!key) return nil;
          fields[key] = expr;
        }
        stage = [[FIRSelectStageBridge alloc] initWithSelections:fields];
      } else if ([stageName isEqualToString:@"add_fields"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          if (error) *error = parseError(@"add_fields requires at least one expression");
          return nil;
        }
        NSMutableDictionary<NSString *, FIRExprBridge *> *fields = [NSMutableDictionary dictionary];
        for (id em in exprMaps) {
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
          }
          NSString *alias = [em valueForKeyPath:@"args.alias"];
          if (!alias) {
            if (error) *error = parseError(@"add_fields expressions must have alias");
            return nil;
          }
          fields[alias] = expr;
        }
        stage = [[FIRAddFieldsStageBridge alloc] initWithFields:fields];
      } else if ([stageName isEqualToString:@"remove_fields"]) {
        NSArray *paths = args[@"field_paths"];
        if (![paths isKindOfClass:[NSArray class]] || paths.count == 0) {
          if (error) *error = parseError(@"remove_fields requires field_paths");
          return nil;
        }
        stage = [[FIRRemoveFieldsStageBridge alloc] initWithFields:paths];
      } else if ([stageName isEqualToString:@"distinct"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          if (error) *error = parseError(@"distinct requires at least one expression");
          return nil;
        }
        NSMutableDictionary<NSString *, FIRExprBridge *> *fields = [NSMutableDictionary dictionary];
        for (id em in exprMaps) {
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
          }
          NSString *key = [self keyForExpressionMap:em error:error];
          if (!key) return nil;
          fields[key] = expr;
        }
        stage = [[FIRDistinctStageBridge alloc] initWithGroups:fields];
      } else if ([stageName isEqualToString:@"replace_with"]) {
        id exprMap = args[@"expression"];
        if (![exprMap isKindOfClass:[NSDictionary class]]) {
          if (error) *error = parseError(@"replace_with requires expression");
          return nil;
        }
        FIRExprBridge *expr = [exprParser parseExpression:exprMap error:&parseErr];
        if (!expr) {
          if (error) *error = parseErr;
          return nil;
        }
        stage = [[FIRReplaceWithStageBridge alloc] initWithExpr:expr];
      } else if ([stageName isEqualToString:@"union"]) {
        NSArray *nestedStages = args[@"pipeline"];
        if (![nestedStages isKindOfClass:[NSArray class]] || nestedStages.count == 0) {
          if (error) *error = parseError(@"union requires non-empty pipeline");
          return nil;
        }
        id otherPipeline = [self buildPipelineWithFirestore:firestore
                                                     stages:nestedStages
                                                      error:&parseErr];
        if (!otherPipeline) {
          if (error) *error = parseErr;
          return nil;
        }
        stage = [[FIRUnionStageBridge alloc] initWithOther:otherPipeline];
      } else if ([stageName isEqualToString:@"sample"]) {
        NSString *type = args[@"type"];
        id val = args[@"value"];
        if ([type isEqualToString:@"percentage"]) {
          double v = [val isKindOfClass:[NSNumber class]] ? [(NSNumber *)val doubleValue] : 0;
          stage = [[FIRSampleStageBridge alloc] initWithPercentage:v];
        } else {
          int v = [val isKindOfClass:[NSNumber class]] ? [(NSNumber *)val intValue] : 0;
          stage = [[FIRSampleStageBridge alloc] initWithCount:v];
        }
      } else if ([stageName isEqualToString:@"aggregate"]) {
        stage = [self parseAggregateStageWithArgs:args exprParser:exprParser error:error];
      } else if ([stageName isEqualToString:@"aggregate_with_options"]) {
        stage = [self parseAggregateStageWithOptionsArgs:args exprParser:exprParser error:error];
      } else if ([stageName isEqualToString:@"unnest"]) {
        id exprMap = args[@"expression"];
        if (![exprMap isKindOfClass:[NSDictionary class]]) {
          if (error) *error = parseError(@"unnest requires expression");
          return nil;
        }
        FIRExprBridge *fieldExpr = nil;
        FIRExprBridge *aliasExpr = nil;
        NSDictionary *exprDict = (NSDictionary *)exprMap;
        NSString *aliasStr = nil;
        if ([exprDict[@"name"] isEqualToString:@"alias"]) {
          NSDictionary *aliasArgs = exprDict[@"args"];
          if ([aliasArgs isKindOfClass:[NSDictionary class]] && aliasArgs[@"expression"]) {
            fieldExpr = [exprParser parseExpression:aliasArgs[@"expression"] error:&parseErr];
            if (!fieldExpr) {
              if (error) *error = parseErr;
              return nil;
            }
            aliasStr =
                [aliasArgs[@"alias"] isKindOfClass:[NSString class]] ? aliasArgs[@"alias"] : nil;
          }
        }
        if (!fieldExpr) {
          fieldExpr = [exprParser parseExpression:exprMap error:&parseErr];
          if (!fieldExpr) {
            if (error) *error = parseErr;
            return nil;
          }
          if (!aliasStr && [exprDict[@"name"] isEqualToString:@"field"]) {
            NSDictionary *fieldArgs = exprDict[@"args"];
            aliasStr =
                [fieldArgs[@"field"] isKindOfClass:[NSString class]] ? fieldArgs[@"field"] : @"_";
          }
        }
        if (!aliasStr) aliasStr = @"_";
        aliasExpr = [[FIRFieldBridge alloc] initWithName:aliasStr];
        NSString *indexFieldStr =
            [args[@"index_field"] isKindOfClass:[NSString class]] ? args[@"index_field"] : nil;
        FIRExprBridge *indexFieldExpr =
            (indexFieldStr.length > 0) ? [[FIRFieldBridge alloc] initWithName:indexFieldStr] : nil;
        stage = [[FIRUnnestStageBridge alloc] initWithField:fieldExpr
                                                      alias:aliasExpr
                                                 indexField:indexFieldExpr];
      } else {
        if (error)
          *error = parseError([NSString stringWithFormat:@"Unknown pipeline stage: %@", stageName]);
        return nil;
      }
    }

    if (stage) [stageBridges addObject:stage];
  }

  if (stageBridges.count == 0) {
    if (error && !*error) *error = parseError(@"No valid stages");
    return nil;
  }

  return stageBridges;
}

+ (FIRAggregateFunctionBridge *)aggregateFunctionFromMap:(NSDictionary *)funcMap
                                              exprParser:(FLTPipelineExpressionParser *)exprParser
                                                   error:(NSError **)error {
  NSString *name = funcMap[@"name"];
  if (![name isKindOfClass:[NSString class]]) {
    if (error) *error = parseError(@"Aggregate function must have a 'name'");
    return nil;
  }
  // Map Dart aggregate function names to iOS SDK names (count_all -> count with no args; minimum ->
  // min; maximum -> max)
  NSString *iosName = name;
  if ([name isEqualToString:@"count_all"]) {
    iosName = @"count";
  } else if ([name isEqualToString:@"minimum"]) {
    iosName = @"min";
  } else if ([name isEqualToString:@"maximum"]) {
    iosName = @"max";
  }
  NSDictionary *argsDict = funcMap[@"args"];
  NSMutableArray<FIRExprBridge *> *argsArray = [NSMutableArray array];
  if ([argsDict isKindOfClass:[NSDictionary class]]) {
    id exprMap = argsDict[@"expression"];
    if ([exprMap isKindOfClass:[NSDictionary class]]) {
      FIRExprBridge *expr = [exprParser parseExpression:exprMap error:error];
      if (!expr) return nil;
      [argsArray addObject:expr];
    }
  }
  return [[FIRAggregateFunctionBridge alloc] initWithName:iosName Args:argsArray];
}

+ (FIRStageBridge *)parseAggregateStageWithArgs:(NSDictionary *)args
                                     exprParser:(FLTPipelineExpressionParser *)exprParser
                                          error:(NSError **)error {
  NSArray *accumulatorMaps = args[@"aggregate_functions"];
  if (![accumulatorMaps isKindOfClass:[NSArray class]] || accumulatorMaps.count == 0) {
    if (error) *error = parseError(@"aggregate requires aggregate_functions");
    return nil;
  }
  return [self parseAggregateStageWithAccumulatorMaps:accumulatorMaps
                                            groupMaps:nil
                                           exprParser:exprParser
                                                error:error];
}

+ (FIRStageBridge *)parseAggregateStageWithOptionsArgs:(NSDictionary *)args
                                            exprParser:(FLTPipelineExpressionParser *)exprParser
                                                 error:(NSError **)error {
  NSDictionary *stageMap = args[@"aggregate_stage"];
  if (![stageMap isKindOfClass:[NSDictionary class]]) {
    if (error) *error = parseError(@"aggregate_with_options requires aggregate_stage");
    return nil;
  }
  NSArray *accumulatorMaps = stageMap[@"accumulators"];
  if (![accumulatorMaps isKindOfClass:[NSArray class]] || accumulatorMaps.count == 0) {
    accumulatorMaps = stageMap[@"aggregate_functions"];
  }
  if (![accumulatorMaps isKindOfClass:[NSArray class]] || accumulatorMaps.count == 0) {
    if (error) *error = parseError(@"aggregate_stage requires accumulators or aggregate_functions");
    return nil;
  }
  NSArray *groupMaps = stageMap[@"groups"];
  return [self parseAggregateStageWithAccumulatorMaps:accumulatorMaps
                                            groupMaps:groupMaps
                                           exprParser:exprParser
                                                error:error];
}

+ (FIRStageBridge *)parseAggregateStageWithAccumulatorMaps:(NSArray *)accumulatorMaps
                                                 groupMaps:(nullable NSArray *)groupMaps
                                                exprParser:(FLTPipelineExpressionParser *)exprParser
                                                     error:(NSError **)error {
  NSError *parseErr = nil;
  NSMutableDictionary<NSString *, FIRAggregateFunctionBridge *> *accumulators =
      [NSMutableDictionary dictionary];
  for (id accMap in accumulatorMaps) {
    if (![accMap isKindOfClass:[NSDictionary class]]) continue;
    NSString *alias = nil;
    NSDictionary *funcMap = nil;
    if ([accMap[@"name"] isEqualToString:@"alias"]) {
      NSDictionary *accArgs = accMap[@"args"];
      if (![accArgs isKindOfClass:[NSDictionary class]]) continue;
      alias = accArgs[@"alias"];
      funcMap = accArgs[@"aggregate_function"];
    }
    if (![alias isKindOfClass:[NSString class]] || ![funcMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"Each accumulator must have alias and aggregate_function");
      return nil;
    }
    FIRAggregateFunctionBridge *func = [self aggregateFunctionFromMap:funcMap
                                                           exprParser:exprParser
                                                                error:&parseErr];
    if (!func) {
      if (error) *error = parseErr;
      return nil;
    }
    accumulators[alias] = func;
  }
  if (accumulators.count == 0) {
    if (error) *error = parseError(@"aggregate requires at least one valid accumulator");
    return nil;
  }

  NSMutableDictionary<NSString *, FIRExprBridge *> *groups = [NSMutableDictionary dictionary];
  if ([groupMaps isKindOfClass:[NSArray class]] && groupMaps.count > 0) {
    for (NSUInteger g = 0; g < groupMaps.count; g++) {
      id gm = groupMaps[g];
      if (![gm isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *expr = [exprParser parseExpression:gm error:&parseErr];
      if (!expr) continue;
      groups[[NSString stringWithFormat:@"_%lu", (unsigned long)g]] = expr;
    }
  }

  return [[FIRAggregateStageBridge alloc] initWithAccumulators:accumulators groups:groups];
}

+ (void)executePipelineWithFirestore:(FIRFirestore *)firestore
                              stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                             options:(nullable NSDictionary<NSString *, id> *)options
                          completion:(void (^)(id _Nullable snapshot,
                                               NSError *_Nullable error))completion {
  if (!stages || stages.count == 0) {
    completion(nil, parseError(@"Pipeline requires at least one stage"));
    return;
  }

  NSError *parseErr = nil;
  NSArray<FIRStageBridge *> *stageBridges = [self parseStagesWithFirestore:firestore
                                                                    stages:stages
                                                                     error:&parseErr];
  if (!stageBridges) {
    completion(nil, parseErr);
    return;
  }

  FIRPipelineBridge *pipeline = [[FIRPipelineBridge alloc] initWithStages:stageBridges
                                                                       db:firestore];
  [pipeline executeWithCompletion:^(id snapshot, NSError *execError) {
    if (execError) {
      completion(nil, execError);
      return;
    }
    completion(snapshot, nil);
  }];
}

+ (id)buildPipelineWithFirestore:(FIRFirestore *)firestore
                          stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                           error:(NSError **)error {
  NSArray<FIRStageBridge *> *stageBridges = [self parseStagesWithFirestore:firestore
                                                                    stages:stages
                                                                     error:error];
  if (!stageBridges) return nil;
  return [[FIRPipelineBridge alloc] initWithStages:stageBridges db:firestore];
}

@end

#else

@implementation FLTPipelineParser

+ (void)executePipelineWithFirestore:(FIRFirestore *)firestore
                              stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                             options:(nullable NSDictionary<NSString *, id> *)options
                          completion:(void (^)(id _Nullable snapshot,
                                               NSError *_Nullable error))completion {
  completion(nil, pipelineUnavailableError());
}

@end

#endif
