/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#import "include/cloud_firestore/Private/FLTPipelineParser.h"
#import "include/cloud_firestore/Private/FLTFirebaseFirestoreUtils.h"

#if TARGET_OS_OSX
#import <FirebaseFirestore/FirebaseFirestore.h>
#import "FirebaseFirestoreInternal/FIRPipelineBridge.h"
#else
@import FirebaseFirestore;
#if __has_include("FirebaseFirestoreInternal/FIRPipelineBridge.h")
#import "FirebaseFirestoreInternal/FIRPipelineBridge.h"
#elif __has_include("FIRPipelineBridge.h")
#import "FIRPipelineBridge.h"
#endif
#endif

#if __has_include("FirebaseFirestoreInternal/FIRVectorValue.h")
#import "FirebaseFirestoreInternal/FIRVectorValue.h"
#elif __has_include(<FirebaseFirestoreInternal/FIRVectorValue.h>)
#import <FirebaseFirestoreInternal/FIRVectorValue.h>
#endif

#import <Foundation/Foundation.h>

static NSString *const kPipelineNotAvailable =
    @"Pipeline API is not available. Firestore Pipelines require Firebase iOS SDK with pipeline "
     "support.";

static NSError *pipelineUnavailableError(void) {
  return [NSError errorWithDomain:@"FLTFirebaseFirestore"
                             code:FLTFirebaseFirestoreErrorCodePipelineParse
                         userInfo:@{NSLocalizedDescriptionKey : kPipelineNotAvailable}];
}

#if TARGET_OS_OSX
#if __has_include("FirebaseFirestoreInternal/FIRPipelineBridge.h")
#define FLT_PIPELINE_AVAILABLE 1
#endif
#else
#if __has_include("FirebaseFirestoreInternal/FIRPipelineBridge.h") || \
                  __has_include("FIRPipelineBridge.h")
#define FLT_PIPELINE_AVAILABLE 1
#endif
#endif

#if FLT_PIPELINE_AVAILABLE

// Swift Package Manager builds against Firebase Apple SDK 13, which prefixes
// these classes with __. CocoaPods stays on 12.19.0, where the same classes
// are unprefixed and the sort stage is FIRSorStageBridge. Package.swift sets
// FLT_FIREBASE_SDK_13 so these aliases are skipped. Classes that were already
// __FIR* in 12.19.0 are left alone.
#ifndef FLT_FIREBASE_SDK_13
@compatibility_alias __FIRExprBridge FIRExprBridge;
@compatibility_alias __FIRFieldBridge FIRFieldBridge;
@compatibility_alias __FIRConstantBridge FIRConstantBridge;
@compatibility_alias __FIRFunctionExprBridge FIRFunctionExprBridge;
@compatibility_alias __FIRAggregateFunctionBridge FIRAggregateFunctionBridge;
@compatibility_alias __FIROrderingBridge FIROrderingBridge;
@compatibility_alias __FIRStageBridge FIRStageBridge;
@compatibility_alias __FIRCollectionSourceStageBridge FIRCollectionSourceStageBridge;
@compatibility_alias __FIRDatabaseSourceStageBridge FIRDatabaseSourceStageBridge;
@compatibility_alias __FIRCollectionGroupSourceStageBridge FIRCollectionGroupSourceStageBridge;
@compatibility_alias __FIRDocumentsSourceStageBridge FIRDocumentsSourceStageBridge;
@compatibility_alias __FIRWhereStageBridge FIRWhereStageBridge;
@compatibility_alias __FIRLimitStageBridge FIRLimitStageBridge;
@compatibility_alias __FIROffsetStageBridge FIROffsetStageBridge;
@compatibility_alias __FIRAddFieldsStageBridge FIRAddFieldsStageBridge;
@compatibility_alias __FIRRemoveFieldsStageBridge FIRRemoveFieldsStageBridge;
@compatibility_alias __FIRSelectStageBridge FIRSelectStageBridge;
@compatibility_alias __FIRDistinctStageBridge FIRDistinctStageBridge;
@compatibility_alias __FIRAggregateStageBridge FIRAggregateStageBridge;
@compatibility_alias __FIRFindNearestStageBridge FIRFindNearestStageBridge;
@compatibility_alias __FIRSearchStageBridge FIRSearchStageBridge;
@compatibility_alias __FIRSortStageBridge FIRSorStageBridge;
@compatibility_alias __FIRReplaceWithStageBridge FIRReplaceWithStageBridge;
@compatibility_alias __FIRSampleStageBridge FIRSampleStageBridge;
@compatibility_alias __FIRUnionStageBridge FIRUnionStageBridge;
@compatibility_alias __FIRUnnestStageBridge FIRUnnestStageBridge;
@compatibility_alias __FIRPipelineBridge FIRPipelineBridge;
#endif

// Firebase iOS SDK versions differ: some expose initWithName:Args:Options:, others
// initWithName:Args:.
@interface __FIRFunctionExprBridge (FLTSDKCompat)
- (instancetype)initWithName:(NSString *)name
                        Args:(NSArray<__FIRExprBridge *> *)args
                     Options:(NSDictionary<NSString *, __FIRExprBridge *> *)options;
- (instancetype)initWithName:(NSString *)name Args:(NSArray<__FIRExprBridge *> *)args;
@end

static __FIRFunctionExprBridge *FLTNewFunctionExprBridge(NSString *name,
                                                         NSArray<__FIRExprBridge *> *args) {
  __FIRFunctionExprBridge *obj = [__FIRFunctionExprBridge alloc];
  if ([obj respondsToSelector:@selector(initWithName:Args:Options:)]) {
    return [obj initWithName:name Args:args Options:nil];
  }
  return [obj initWithName:name Args:args];
}

static NSError *parseError(NSString *message) {
  return [NSError errorWithDomain:@"FLTFirebaseFirestore"
                             code:FLTFirebaseFirestoreErrorCodePipelineParse
                         userInfo:@{NSLocalizedDescriptionKey : message}];
}

@interface FLTPipelineExpressionParser : NSObject
@property(nonatomic, strong) FIRFirestore *firestore;
- (instancetype)initWithFirestore:(FIRFirestore *)firestore;
- (__FIRExprBridge *)parseExpression:(NSDictionary<NSString *, id> *)map error:(NSError **)error;
- (__FIRExprBridge *)parseBooleanExpression:(NSDictionary<NSString *, id> *)map
                                      error:(NSError **)error;
- (__FIRExprBridge *)rightExprFromValue:(id)value error:(NSError **)error;
@end

@implementation FLTPipelineExpressionParser

- (instancetype)initWithFirestore:(FIRFirestore *)firestore {
  self = [super init];
  if (self) {
    _firestore = firestore;
  }
  return self;
}

- (__FIRExprBridge *)parseExpression:(NSDictionary<NSString *, id> *)map error:(NSError **)error {
  NSString *name = map[@"name"];
  if (!name) {
    NSDictionary *args = map[@"args"];
    if ([args isKindOfClass:[NSDictionary class]] && args[@"field"]) {
      return [[__FIRFieldBridge alloc] initWithName:args[@"field"]];
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
    return [[__FIRFieldBridge alloc] initWithName:field];
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
        return [[__FIRConstantBridge alloc] init:docRef];
      }
    }
    return [[__FIRConstantBridge alloc] init:value];
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
    return [[__FIRConstantBridge alloc] init:[NSNull null]];
  }

  if ([name isEqualToString:@"document_id_from_ref"]) {
    NSString *path = args[@"doc_ref"];
    if (![path isKindOfClass:[NSString class]] || path.length == 0) {
      if (error) *error = parseError(@"document_id_from_ref requires doc_ref path");
      return nil;
    }
    if (!self.firestore) {
      if (error) *error = parseError(@"document_id_from_ref requires firestore");
      return nil;
    }
    FIRDocumentReference *docRef = [self.firestore documentWithPath:path];
    __FIRExprBridge *refExpr = [[__FIRConstantBridge alloc] init:docRef];
    return FLTNewFunctionExprBridge(@"document_id", @[ refExpr ]);
  }

  // Swift asBoolean() is a type coercion, not a pipeline function named "as_boolean".
  // Dart still sends as_boolean + expression; unwrap to the inner __FIRExprBridge.
  if ([name isEqualToString:@"as_boolean"]) {
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"as_boolean requires expression");
      return nil;
    }
    return [self parseExpression:(NSDictionary *)exprMap error:error];
  }

  if ([name isEqualToString:@"document_matches"]) {
    NSString *query = args[@"query"];
    if (![query isKindOfClass:[NSString class]]) {
      if (error) *error = parseError(@"document_matches requires query");
      return nil;
    }
    __FIRExprBridge *queryExpr = [[__FIRConstantBridge alloc] init:query];
    return FLTNewFunctionExprBridge(@"document_matches", @[ queryExpr ]);
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
    __FIRExprBridge *left = [self parseExpression:leftMap error:error];
    __FIRExprBridge *right = [self parseExpression:rightMap error:error];
    if (!left || !right) return nil;
    return FLTNewFunctionExprBridge(sdkName, @[ left, right ]);
  }

  // -------------------------------------------------------------------------
  // Unary expressions (single expression): exists, is_error, is_absent, not
  // (as_boolean is handled above — unwrap only, not a pipeline function.)
  // -------------------------------------------------------------------------
  NSArray *unaryNames = @[ @"exists", @"is_error", @"is_absent", @"not" ];
  if ([unaryNames containsObject:name]) {
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError([NSString stringWithFormat:@"%@ requires expression", name]);
      return nil;
    }
    __FIRExprBridge *expr = [name isEqualToString:@"not"]
                                ? [self parseBooleanExpression:exprMap error:error]
                                : [self parseExpression:exprMap error:error];
    if (!expr) return nil;
    return FLTNewFunctionExprBridge(name, @[ expr ]);
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
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    if (!expr) return nil;
    NSString *unarySdkName = name;
    if ([name isEqualToString:@"to_lower_case"]) unarySdkName = @"to_lower";
    if ([name isEqualToString:@"to_upper_case"]) unarySdkName = @"to_upper";
    return FLTNewFunctionExprBridge(unarySdkName, @[ expr ]);
  }

  // -------------------------------------------------------------------------
  // N-ary logical (expressions array): and, or, xor, nor
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"and"] || [name isEqualToString:@"or"] ||
      [name isEqualToString:@"xor"] || [name isEqualToString:@"nor"]) {
    NSArray *exprMaps = args[@"expressions"];
    if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires at least one expression", name]);
      return nil;
    }
    NSMutableArray<__FIRExprBridge *> *all = [NSMutableArray array];
    for (id em in exprMaps) {
      if (![em isKindOfClass:[NSDictionary class]]) continue;
      __FIRExprBridge *e = [self parseBooleanExpression:em error:error];
      if (!e) return nil;
      [all addObject:e];
    }
    if (all.count == 0) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires at least one expression", name]);
      return nil;
    }
    return FLTNewFunctionExprBridge(name, all);
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
    __FIRExprBridge *valueExpr = [self parseExpression:valueMap error:error];
    if (!valueExpr) return nil;
    NSMutableArray<__FIRExprBridge *> *valueExprs = [NSMutableArray array];
    for (id vm in valuesMaps) {
      if (![vm isKindOfClass:[NSDictionary class]]) continue;
      __FIRExprBridge *ve = [self parseExpression:vm error:error];
      if (!ve) return nil;
      [valueExprs addObject:ve];
    }
    if (valueExprs.count == 0) {
      if (error)
        *error = parseError([NSString stringWithFormat:@"%@ requires at least one value", name]);
      return nil;
    }
    __FIRExprBridge *valuesArrayExpr = FLTNewFunctionExprBridge(@"array", valueExprs);
    return FLTNewFunctionExprBridge(name, @[ valueExpr, valuesArrayExpr ]);
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
    __FIRExprBridge *arrayExpr = [self parseExpression:arrayMap error:error];
    __FIRExprBridge *elementExpr = [self parseExpression:elementMap error:error];
    if (!arrayExpr || !elementExpr) return nil;
    return FLTNewFunctionExprBridge(name, @[ arrayExpr, elementExpr ]);
  }

  // -------------------------------------------------------------------------
  // array + values[]: array_contains_all, array_contains_any
  // SDK expects: array_contains_any(field, array(val1, val2, ...)) — two args.
  // Reuse the "array" expression parser to build the values array.
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array_contains_all"] ||
      [name isEqualToString:@"array_contains_any"]) {
    id arrayMap = args[@"array"];
    if (![arrayMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError([NSString stringWithFormat:@"%@ requires array", name]);
      return nil;
    }
    __FIRExprBridge *arrayExpr = [self parseExpression:arrayMap error:error];
    if (!arrayExpr) return nil;

    NSArray *valuesMaps = args[@"values"];
    if (![valuesMaps isKindOfClass:[NSArray class]]) valuesMaps = args[@"elements"];
    BOOL hasValues = [valuesMaps isKindOfClass:[NSArray class]] && valuesMaps.count > 0;

    if (hasValues) {
      NSDictionary *arrayExprMap = @{@"name" : @"array", @"args" : @{@"elements" : valuesMaps}};
      __FIRExprBridge *valuesArrayExpr = [self parseExpression:arrayExprMap error:error];
      if (!valuesArrayExpr) return nil;
      return FLTNewFunctionExprBridge(name, @[ arrayExpr, valuesArrayExpr ]);
    }

    if ([name isEqualToString:@"array_contains_all"]) {
      id arrayExpressionMap = args[@"array_expression"];
      if ([arrayExpressionMap isKindOfClass:[NSDictionary class]]) {
        __FIRExprBridge *requiredArrayExpr = [self parseExpression:arrayExpressionMap error:error];
        if (!requiredArrayExpr) return nil;
        return FLTNewFunctionExprBridge(name, @[ arrayExpr, requiredArrayExpr ]);
      }
    }

    if (error)
      *error = parseError([NSString
          stringWithFormat:
              @"%@ requires array and values/elements, or array_contains_all with array_expression",
              name]);
    return nil;
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
    NSMutableArray<__FIRExprBridge *> *all = [NSMutableArray array];
    for (id em in exprMaps) {
      if (![em isKindOfClass:[NSDictionary class]]) continue;
      __FIRExprBridge *e = [self parseExpression:em error:error];
      if (!e) return nil;
      [all addObject:e];
    }
    if (all.count == 0) {
      if (error) *error = parseError(@"concat requires at least one expression");
      return nil;
    }
    return FLTNewFunctionExprBridge(@"concat", all);
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
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    __FIRExprBridge *start = [self parseExpression:startMap error:error];
    __FIRExprBridge *end = [self parseExpression:endMap error:error];
    if (!expr || !start || !end) return nil;
    return FLTNewFunctionExprBridge(@"substring", @[ expr, start, end ]);
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
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    __FIRExprBridge *find = [self parseExpression:findMap error:error];
    __FIRExprBridge *replacement = [self parseExpression:replacementMap error:error];
    if (!expr || !find || !replacement) return nil;
    return FLTNewFunctionExprBridge(@"string_replace", @[ expr, find, replacement ]);
  }

  // -------------------------------------------------------------------------
  // expression + find + replacement: string_replace_one / string_replace_all
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"string_replace_one"] ||
      [name isEqualToString:@"string_replace_all"]) {
    id exprMap = args[@"expression"];
    id findMap = args[@"find"];
    id replacementMap = args[@"replacement"];
    if (![exprMap isKindOfClass:[NSDictionary class]] ||
        ![findMap isKindOfClass:[NSDictionary class]] ||
        ![replacementMap isKindOfClass:[NSDictionary class]]) {
      if (error)
        *error = parseError(
            [NSString stringWithFormat:@"%@ requires expression, find, and replacement", name]);
      return nil;
    }
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    __FIRExprBridge *find = [self parseExpression:findMap error:error];
    __FIRExprBridge *replacement = [self parseExpression:replacementMap error:error];
    if (!expr || !find || !replacement) return nil;
    return FLTNewFunctionExprBridge(name, @[ expr, find, replacement ]);
  }

  // -------------------------------------------------------------------------
  // expression + search/repetitions: string_index_of / string_repeat
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"string_index_of"] || [name isEqualToString:@"string_repeat"]) {
    id exprMap = args[@"expression"];
    NSString *argumentName = [name isEqualToString:@"string_index_of"] ? @"search" : @"repetitions";
    id argumentMap = args[argumentName];
    if (![exprMap isKindOfClass:[NSDictionary class]] ||
        ![argumentMap isKindOfClass:[NSDictionary class]]) {
      if (error)
        *error = parseError(
            [NSString stringWithFormat:@"%@ requires expression and %@", name, argumentName]);
      return nil;
    }
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    __FIRExprBridge *argument = [self parseExpression:argumentMap error:error];
    if (!expr || !argument) return nil;
    return FLTNewFunctionExprBridge(name, @[ expr, argument ]);
  }

  // -------------------------------------------------------------------------
  // expression + optional value: ltrim / rtrim
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"ltrim"] || [name isEqualToString:@"rtrim"]) {
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError([NSString stringWithFormat:@"%@ requires expression", name]);
      return nil;
    }
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    if (!expr) return nil;

    id valueMap = args[@"value"];
    if (![valueMap isKindOfClass:[NSDictionary class]]) {
      return FLTNewFunctionExprBridge(name, @[ expr ]);
    }
    __FIRExprBridge *value = [self parseExpression:valueMap error:error];
    if (!value) return nil;
    return FLTNewFunctionExprBridge(name, @[ expr, value ]);
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
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    __FIRExprBridge *delimiter = [self parseExpression:delimiterMap error:error];
    if (!expr || !delimiter) return nil;
    return FLTNewFunctionExprBridge(name, @[ expr, delimiter ]);
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
    __FIRExprBridge *first = [self parseExpression:firstMap error:error];
    __FIRExprBridge *second = [self parseExpression:secondMap error:error];
    if (!first || !second) return nil;
    return FLTNewFunctionExprBridge(@"array_concat", @[ first, second ]);
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
    NSMutableArray<__FIRExprBridge *> *all = [NSMutableArray array];
    for (id am in arraysMaps) {
      if (![am isKindOfClass:[NSDictionary class]]) continue;
      __FIRExprBridge *e = [self parseExpression:am error:error];
      if (!e) return nil;
      [all addObject:e];
    }
    if (all.count == 0) {
      if (error) *error = parseError(@"array_concat_multiple requires at least one array");
      return nil;
    }
    return FLTNewFunctionExprBridge(@"array_concat", all);
  }

  // -------------------------------------------------------------------------
  // expression + offset (+ optional length): array_slice
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array_slice"]) {
    id exprMap = args[@"expression"];
    id offsetMap = args[@"offset"];
    id lengthMap = args[@"length"];
    if (![exprMap isKindOfClass:[NSDictionary class]] ||
        ![offsetMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"array_slice requires expression and offset");
      return nil;
    }
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    __FIRExprBridge *offset = [self parseExpression:offsetMap error:error];
    if (!expr || !offset) return nil;
    NSMutableArray<__FIRExprBridge *> *sliceArgs =
        [NSMutableArray arrayWithObjects:expr, offset, nil];
    if ([lengthMap isKindOfClass:[NSDictionary class]]) {
      __FIRExprBridge *length = [self parseExpression:lengthMap error:error];
      if (!length) return nil;
      [sliceArgs addObject:length];
    }
    return FLTNewFunctionExprBridge(@"array_slice", sliceArgs);
  }

  // -------------------------------------------------------------------------
  // expression + alias + filter: array_filter
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array_filter"]) {
    id exprMap = args[@"expression"];
    NSString *alias = args[@"alias"];
    id filterMap = args[@"filter"];
    if (![exprMap isKindOfClass:[NSDictionary class]] || ![alias isKindOfClass:[NSString class]] ||
        ![filterMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"array_filter requires expression, alias, and filter");
      return nil;
    }
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    __FIRExprBridge *filter = [self parseBooleanExpression:filterMap error:error];
    if (!expr || !filter) return nil;
    return FLTNewFunctionExprBridge(@"array_filter",
                                    @[ expr, [[__FIRConstantBridge alloc] init:alias], filter ]);
  }

  // -------------------------------------------------------------------------
  // expression + aliases + transform: array_transform / array_transform_with_index
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array_transform"] ||
      [name isEqualToString:@"array_transform_with_index"]) {
    id exprMap = args[@"expression"];
    NSString *elementAlias = args[@"element_alias"];
    NSString *indexAlias = args[@"index_alias"];
    id transformMap = args[@"transform"];
    BOOL withIndex = [name isEqualToString:@"array_transform_with_index"];
    if (![exprMap isKindOfClass:[NSDictionary class]] ||
        ![elementAlias isKindOfClass:[NSString class]] ||
        (withIndex && ![indexAlias isKindOfClass:[NSString class]]) ||
        ![transformMap isKindOfClass:[NSDictionary class]]) {
      if (error) {
        NSString *message =
            withIndex
                ? @"array_transform_with_index requires expression, element_alias, index_alias, "
                  @"and transform"
                : @"array_transform requires expression, element_alias, and transform";
        *error = parseError(message);
      }
      return nil;
    }
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    __FIRExprBridge *transform = [self parseExpression:transformMap error:error];
    if (!expr || !transform) return nil;
    NSMutableArray<__FIRExprBridge *> *transformArgs = [NSMutableArray
        arrayWithObjects:expr, [[__FIRConstantBridge alloc] init:elementAlias], nil];
    if (withIndex) {
      [transformArgs addObject:[[__FIRConstantBridge alloc] init:indexAlias]];
    }
    [transformArgs addObject:transform];
    return FLTNewFunctionExprBridge(name, transformArgs);
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
    NSMutableArray<__FIRExprBridge *> *elementExprs = [NSMutableArray array];
    for (id em in elementsMaps) {
      if (![em isKindOfClass:[NSDictionary class]]) continue;
      __FIRExprBridge *e = [self parseExpression:em error:error];
      if (!e) return nil;
      [elementExprs addObject:e];
    }
    if (elementExprs.count == 0) {
      if (error) *error = parseError(@"array requires at least one element");
      return nil;
    }
    return FLTNewFunctionExprBridge(@"array", elementExprs);
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
    NSMutableArray<__FIRExprBridge *> *mapArgs = [NSMutableArray array];
    for (NSString *key in dataMap) {
      id valueMap = dataMap[key];
      if (![valueMap isKindOfClass:[NSDictionary class]]) continue;
      __FIRExprBridge *keyExpr = [[__FIRConstantBridge alloc] init:key];
      __FIRExprBridge *valueExpr = [self parseExpression:valueMap error:error];
      if (!valueExpr) return nil;
      [mapArgs addObject:keyExpr];
      [mapArgs addObject:valueExpr];
    }
    if (mapArgs.count == 0) {
      if (error) *error = parseError(@"map requires at least one key-value pair");
      return nil;
    }
    return FLTNewFunctionExprBridge(@"map", mapArgs);
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
    __FIRExprBridge *mapExpr = [self parseExpression:mapMap error:error];
    __FIRExprBridge *keyExpr = [self parseExpression:keyMap error:error];
    if (!mapExpr || !keyExpr) return nil;
    return FLTNewFunctionExprBridge(@"map_get", @[ mapExpr, keyExpr ]);
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
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    __FIRExprBridge *elseExpr = [self parseExpression:elseMap error:error];
    if (!expr || !elseExpr) return nil;
    return FLTNewFunctionExprBridge(@"if_absent", @[ expr, elseExpr ]);
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
    __FIRExprBridge *expr = [self parseExpression:exprMap error:error];
    __FIRExprBridge *catchExpr = [self parseExpression:catchMap error:error];
    if (!expr || !catchExpr) return nil;
    return FLTNewFunctionExprBridge(@"if_error", @[ expr, catchExpr ]);
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
    __FIRExprBridge *condition = [self parseBooleanExpression:conditionMap error:error];
    __FIRExprBridge *thenExpr = [self parseExpression:thenMap error:error];
    __FIRExprBridge *elseExpr = [self parseExpression:elseMap error:error];
    if (!condition || !thenExpr || !elseExpr) return nil;
    return FLTNewFunctionExprBridge(@"conditional", @[ condition, thenExpr, elseExpr ]);
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
    __FIRExprBridge *timestampExpr = [self parseExpression:timestampMap error:error];
    __FIRExprBridge *amountExpr = [self parseExpression:amountMap error:error];
    if (!timestampExpr || !amountExpr) return nil;
    __FIRExprBridge *unitExpr = [[__FIRConstantBridge alloc] init:unitVal];
    return FLTNewFunctionExprBridge(name, @[ timestampExpr, unitExpr, amountExpr ]);
  }

  // -------------------------------------------------------------------------
  // No args: current_timestamp (SDK: current_timestamp with empty Args)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"current_timestamp"]) {
    return FLTNewFunctionExprBridge(@"current_timestamp", @[]);
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
    __FIRExprBridge *timestampExpr = [self parseExpression:timestampMap error:error];
    if (!timestampExpr) return nil;
    __FIRExprBridge *unitExpr = [[__FIRConstantBridge alloc] init:unitVal];
    return FLTNewFunctionExprBridge(@"timestamp_trunc", @[ timestampExpr, unitExpr ]);
  }

  // -------------------------------------------------------------------------
  // map_keys, map_values (unary on map expression)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"map_keys"] || [name isEqualToString:@"map_values"]) {
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError([NSString stringWithFormat:@"%@ requires expression", name]);
      return nil;
    }
    __FIRExprBridge *expr = [self parseExpression:(NSDictionary *)exprMap error:error];
    if (!expr) return nil;
    return FLTNewFunctionExprBridge(name, @[ expr ]);
  }

  // -------------------------------------------------------------------------
  // parent: doc_ref path or expression
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"parent"]) {
    NSString *docPath = args[@"doc_ref"];
    if ([docPath isKindOfClass:[NSString class]] && docPath.length > 0) {
      FIRDocumentReference *ref = [self.firestore documentWithPath:docPath];
      __FIRExprBridge *refExpr = [[__FIRConstantBridge alloc] init:ref];
      return FLTNewFunctionExprBridge(@"parent", @[ refExpr ]);
    }
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"parent requires expression or doc_ref");
      return nil;
    }
    __FIRExprBridge *expr = [self parseExpression:(NSDictionary *)exprMap error:error];
    if (!expr) return nil;
    return FLTNewFunctionExprBridge(@"parent", @[ expr ]);
  }

  // -------------------------------------------------------------------------
  // timestamp_diff: end, start, unit (unit = string or expression map)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"timestamp_diff"]) {
    id endMap = args[@"end"];
    id startMap = args[@"start"];
    id unitObj = args[@"unit"];
    if (![endMap isKindOfClass:[NSDictionary class]] ||
        ![startMap isKindOfClass:[NSDictionary class]] || !unitObj) {
      if (error) *error = parseError(@"timestamp_diff requires end, start, and unit");
      return nil;
    }
    __FIRExprBridge *endExpr = [self parseExpression:(NSDictionary *)endMap error:error];
    __FIRExprBridge *startExpr = [self parseExpression:(NSDictionary *)startMap error:error];
    if (!endExpr || !startExpr) return nil;
    __FIRExprBridge *unitExpr = nil;
    if ([unitObj isKindOfClass:[NSString class]]) {
      unitExpr = [[__FIRConstantBridge alloc] init:unitObj];
    } else if ([unitObj isKindOfClass:[NSDictionary class]]) {
      unitExpr = [self parseExpression:(NSDictionary *)unitObj error:error];
    } else {
      if (error) *error = parseError(@"timestamp_diff unit must be string or expression");
      return nil;
    }
    if (!unitExpr) return nil;
    return FLTNewFunctionExprBridge(@"timestamp_diff", @[ endExpr, startExpr, unitExpr ]);
  }

  // -------------------------------------------------------------------------
  // timestamp_extract: timestamp, part; optional timezone (string or expression)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"timestamp_extract"]) {
    id timestampMap = args[@"timestamp"];
    id partMap = args[@"part"];
    if (![timestampMap isKindOfClass:[NSDictionary class]] ||
        ![partMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"timestamp_extract requires timestamp and part");
      return nil;
    }
    __FIRExprBridge *tsExpr = [self parseExpression:(NSDictionary *)timestampMap error:error];
    __FIRExprBridge *partExpr = [self parseExpression:(NSDictionary *)partMap error:error];
    if (!tsExpr || !partExpr) return nil;
    id tzRaw = args[@"timezone"];
    if (tzRaw == nil) {
      return FLTNewFunctionExprBridge(@"timestamp_extract", @[ tsExpr, partExpr ]);
    }
    __FIRExprBridge *tzExpr = nil;
    if ([tzRaw isKindOfClass:[NSString class]]) {
      tzExpr = [[__FIRConstantBridge alloc] init:tzRaw];
    } else if ([tzRaw isKindOfClass:[NSDictionary class]]) {
      tzExpr = [self parseExpression:(NSDictionary *)tzRaw error:error];
    } else {
      if (error) *error = parseError(@"timestamp_extract timezone must be string or expression");
      return nil;
    }
    if (!tzExpr) return nil;
    return FLTNewFunctionExprBridge(@"timestamp_extract", @[ tsExpr, partExpr, tzExpr ]);
  }

  // -------------------------------------------------------------------------
  // if_null: expression + replacement
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"if_null"]) {
    id exprMap = args[@"expression"];
    id replMap = args[@"replacement"];
    if (![exprMap isKindOfClass:[NSDictionary class]] ||
        ![replMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"if_null requires expression and replacement");
      return nil;
    }
    __FIRExprBridge *ifExpr = [self parseExpression:(NSDictionary *)exprMap error:error];
    __FIRExprBridge *replExpr = [self parseExpression:(NSDictionary *)replMap error:error];
    if (!ifExpr || !replExpr) return nil;
    return FLTNewFunctionExprBridge(@"if_null", @[ ifExpr, replExpr ]);
  }

  // -------------------------------------------------------------------------
  // coalesce: expressions[] (>= 2)
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"coalesce"]) {
    NSArray *exprMaps = args[@"expressions"];
    if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count < 2) {
      if (error) *error = parseError(@"coalesce requires at least two expressions");
      return nil;
    }
    NSMutableArray<__FIRExprBridge *> *exprs = [NSMutableArray array];
    for (id em in exprMaps) {
      if (![em isKindOfClass:[NSDictionary class]]) continue;
      __FIRExprBridge *e = [self parseExpression:(NSDictionary *)em error:error];
      if (!e) return nil;
      [exprs addObject:e];
    }
    if (exprs.count < 2) {
      if (error) *error = parseError(@"coalesce requires at least two expressions");
      return nil;
    }
    return FLTNewFunctionExprBridge(@"coalesce", exprs);
  }

  // -------------------------------------------------------------------------
  // switch_on: alternating condition (bool), result (expr), optional default
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"switch_on"]) {
    NSArray *exprMaps = args[@"expressions"];
    if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count < 2) {
      if (error) *error = parseError(@"switch_on requires at least two expressions");
      return nil;
    }
    NSUInteger n = exprMaps.count;
    __FIRExprBridge *first = [self parseBooleanExpression:exprMaps[0] error:error];
    __FIRExprBridge *second = [self parseExpression:exprMaps[1] error:error];
    if (!first || !second) return nil;
    if (n == 2) {
      return FLTNewFunctionExprBridge(@"switch_on", @[ first, second ]);
    }
    NSMutableArray<__FIRExprBridge *> *rest = [NSMutableArray array];
    for (NSUInteger i = 2; i < n; i++) {
      __FIRExprBridge *e = nil;
      if ((n % 2 == 1) && (i == n - 1)) {
        e = [self parseExpression:exprMaps[i] error:error];
      } else if (i % 2 == 0) {
        e = [self parseBooleanExpression:exprMaps[i] error:error];
      } else {
        e = [self parseExpression:exprMaps[i] error:error];
      }
      if (!e) return nil;
      [rest addObject:e];
    }
    NSMutableArray<__FIRExprBridge *> *all = [NSMutableArray arrayWithObjects:first, second, nil];
    [all addObjectsFromArray:rest];
    return FLTNewFunctionExprBridge(@"switch_on", all);
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

- (__FIRExprBridge *)rightExprFromValue:(id)value error:(NSError **)error {
  if ([value isKindOfClass:[NSDictionary class]]) {
    return [self parseExpression:(NSDictionary *)value error:error];
  }
  return [[__FIRConstantBridge alloc] init:value];
}

- (__FIRExprBridge *)parseFilterExpressionWithArgs:(NSDictionary *)args error:(NSError **)error {
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
    NSMutableArray<__FIRExprBridge *> *all = [NSMutableArray array];
    for (id em in exprMaps) {
      if (![em isKindOfClass:[NSDictionary class]]) continue;
      __FIRExprBridge *e = [self parseBooleanExpression:(NSDictionary *)em error:error];
      if (!e) return nil;
      [all addObject:e];
    }
    if (all.count == 0) return nil;
    return FLTNewFunctionExprBridge(operator, all);
  }

  // Field-based: field + isEqualTo, isGreaterThan, etc.
  NSString *fieldName = args[@"field"];
  if (![fieldName isKindOfClass:[NSString class]]) {
    if (error) *error = parseError(@"filter requires operator+expressions or field");
    return nil;
  }
  __FIRExprBridge *fieldExpr = [[__FIRFieldBridge alloc] initWithName:fieldName];

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
      __FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return FLTNewFunctionExprBridge(@"equal", @[ fieldExpr, right ]);
    }
    if ([key isEqualToString:@"isNotEqualTo"]) {
      __FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return FLTNewFunctionExprBridge(@"not_equal", @[ fieldExpr, right ]);
    }
    if ([key isEqualToString:@"isGreaterThan"]) {
      __FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return FLTNewFunctionExprBridge(@"greater_than", @[ fieldExpr, right ]);
    }
    if ([key isEqualToString:@"isGreaterThanOrEqualTo"]) {
      __FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return FLTNewFunctionExprBridge(@"greater_than_or_equal", @[ fieldExpr, right ]);
    }
    if ([key isEqualToString:@"isLessThan"]) {
      __FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return FLTNewFunctionExprBridge(@"less_than", @[ fieldExpr, right ]);
    }
    if ([key isEqualToString:@"isLessThanOrEqualTo"]) {
      __FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return FLTNewFunctionExprBridge(@"less_than_or_equal", @[ fieldExpr, right ]);
    }
    if ([key isEqualToString:@"arrayContains"]) {
      __FIRExprBridge *right = [self rightExprFromValue:value error:error];
      if (!right) return nil;
      return FLTNewFunctionExprBridge(@"array_contains", @[ fieldExpr, right ]);
    }
    if ([key isEqualToString:@"arrayContainsAny"] || [key isEqualToString:@"whereIn"]) {
      NSArray *valuesList = [value isKindOfClass:[NSArray class]] ? value : @[];
      NSMutableArray<__FIRExprBridge *> *valueExprs = [NSMutableArray array];
      for (id v in valuesList) {
        __FIRExprBridge *ve = [self rightExprFromValue:v error:error];
        if (!ve) return nil;
        [valueExprs addObject:ve];
      }
      if (valueExprs.count == 0) {
        if (error) *error = parseError(@"arrayContainsAny/whereIn requires non-empty list");
        return nil;
      }
      // SDK expects (value, array) not (value, v1, v2, ...); wrap in "array" expr.
      __FIRExprBridge *valuesArrayExpr = FLTNewFunctionExprBridge(@"array", valueExprs);
      return FLTNewFunctionExprBridge(@"equal_any", @[ fieldExpr, valuesArrayExpr ]);
    }
    if ([key isEqualToString:@"whereNotIn"]) {
      NSArray *valuesList = [value isKindOfClass:[NSArray class]] ? value : @[];
      NSMutableArray<__FIRExprBridge *> *valueExprs = [NSMutableArray array];
      for (id v in valuesList) {
        __FIRExprBridge *ve = [self rightExprFromValue:v error:error];
        if (!ve) return nil;
        [valueExprs addObject:ve];
      }
      if (valueExprs.count == 0) {
        if (error) *error = parseError(@"whereNotIn requires non-empty list");
        return nil;
      }
      // SDK expects (value, array) not (value, v1, v2, ...); wrap in "array" expr.
      __FIRExprBridge *valuesArrayExpr = FLTNewFunctionExprBridge(@"array", valueExprs);
      return FLTNewFunctionExprBridge(@"not_equal_any", @[ fieldExpr, valuesArrayExpr ]);
    }
    if ([key isEqualToString:@"isNull"]) {
      __FIRExprBridge *right = [[__FIRConstantBridge alloc] init:[NSNull null]];
      return FLTNewFunctionExprBridge(@"equal", @[ fieldExpr, right ]);
    }
    if ([key isEqualToString:@"isNotNull"]) {
      __FIRExprBridge *right = [[__FIRConstantBridge alloc] init:[NSNull null]];
      return FLTNewFunctionExprBridge(@"not_equal", @[ fieldExpr, right ]);
    }
  }

  if (error)
    *error =
        parseError(@"filter requires at least one comparison (isEqualTo, isGreaterThan, etc.)");
  return nil;
}

- (__FIRExprBridge *)parseBooleanExpression:(NSDictionary<NSString *, id> *)map
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
  if (error) *error = parseError(@"expression must have alias or be a field reference");
  return nil;
}

+ (NSDictionary<NSString *, __FIRExprBridge *> *)
    parseSearchFieldsWithExpressionMaps:(NSArray<NSDictionary<NSString *, id> *> *)exprMaps
                             exprParser:(FLTPipelineExpressionParser *)exprParser
                                  error:(NSError **)error {
  NSMutableDictionary<NSString *, __FIRExprBridge *> *fields = [NSMutableDictionary dictionary];
  NSError *parseErr = nil;

  for (id em in exprMaps) {
    if (![em isKindOfClass:[NSDictionary class]]) continue;

    __FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
    if (!expr) {
      if (error) *error = parseErr;
      return nil;
    }

    NSString *key = [self keyForExpressionMap:em error:error];
    if (![key isKindOfClass:[NSString class]] || key.length == 0) return nil;
    fields[key] = expr;
  }

  return fields;
}

+ (__FIRStageBridge *)parseSearchStageWithArgs:(NSDictionary *)args
                                    exprParser:(FLTPipelineExpressionParser *)exprParser
                                         error:(NSError **)error {
  NSString *queryType = args[@"query_type"];
  id query = args[@"query"];
  NSMutableDictionary<NSString *, __FIRExprBridge *> *options = [NSMutableDictionary dictionary];
  NSError *parseErr = nil;

  if ([queryType isEqualToString:@"string"]) {
    if (![query isKindOfClass:[NSString class]]) {
      if (error) *error = parseError(@"search query_type 'string' requires string query");
      return nil;
    }
    __FIRExprBridge *queryExpr = [[__FIRConstantBridge alloc] init:query];
    options[@"query"] = FLTNewFunctionExprBridge(@"document_matches", @[ queryExpr ]);
  } else if ([queryType isEqualToString:@"expression"]) {
    if (![query isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"search query_type 'expression' requires expression query");
      return nil;
    }
    __FIRExprBridge *queryExpr = [exprParser parseBooleanExpression:query error:&parseErr];
    if (!queryExpr) {
      if (error) *error = parseErr;
      return nil;
    }
    options[@"query"] = queryExpr;
  } else {
    if (error) *error = parseError(@"search requires query_type to be 'string' or 'expression'");
    return nil;
  }

  NSNumber *limit = [args[@"limit"] isKindOfClass:[NSNumber class]] ? args[@"limit"] : nil;
  if (limit) options[@"limit"] = [[__FIRConstantBridge alloc] init:limit];

  NSNumber *offset = [args[@"offset"] isKindOfClass:[NSNumber class]] ? args[@"offset"] : nil;
  if (offset) options[@"offset"] = [[__FIRConstantBridge alloc] init:offset];

  NSNumber *retrievalDepth =
      [args[@"retrieval_depth"] isKindOfClass:[NSNumber class]] ? args[@"retrieval_depth"] : nil;
  if (retrievalDepth) {
    options[@"retrieval_depth"] = [[__FIRConstantBridge alloc] init:retrievalDepth];
  }

  NSString *languageCode =
      [args[@"language_code"] isKindOfClass:[NSString class]] ? args[@"language_code"] : nil;
  if (languageCode) {
    options[@"language_code"] = [[__FIRConstantBridge alloc] init:languageCode];
  }

  NSMutableArray<__FIROrderingBridge *> *sort = [NSMutableArray array];
  NSArray *orderingMaps = args[@"sort"];
  if ([orderingMaps isKindOfClass:[NSArray class]]) {
    for (id om in orderingMaps) {
      if (![om isKindOfClass:[NSDictionary class]]) continue;
      id exprMap = ((NSDictionary *)om)[@"expression"];
      NSString *dir = ((NSDictionary *)om)[@"order_direction"];
      if (![exprMap isKindOfClass:[NSDictionary class]]) continue;
      __FIRExprBridge *expr = [exprParser parseExpression:exprMap error:&parseErr];
      if (!expr) {
        if (error) *error = parseErr;
        return nil;
      }
      NSString *direction = [dir isEqualToString:@"asc"] ? @"ascending" : @"descending";
      [sort addObject:[[__FIROrderingBridge alloc] initWithExpr:expr Direction:direction]];
    }
  }

  NSDictionary<NSString *, __FIRExprBridge *> *addFields = @{};
  NSArray *addFieldMaps = args[@"add_fields"];
  if ([addFieldMaps isKindOfClass:[NSArray class]] && addFieldMaps.count > 0) {
    addFields = [self parseSearchFieldsWithExpressionMaps:addFieldMaps
                                               exprParser:exprParser
                                                    error:error];
    if (!addFields) return nil;
  }

  return [[__FIRSearchStageBridge alloc] initWithOptions:options
                                               addFields:addFields
                                                  select:@{}
                                                    sort:sort];
}

+ (NSArray<__FIRStageBridge *> *)
    parseStagesWithFirestore:(FIRFirestore *)firestore
                      stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                       error:(NSError **)error {
  FLTPipelineExpressionParser *exprParser =
      [[FLTPipelineExpressionParser alloc] initWithFirestore:firestore];
  NSMutableArray<__FIRStageBridge *> *stageBridges = [NSMutableArray array];
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

    __FIRStageBridge *stage = nil;

    if (i == 0) {
      if ([stageName isEqualToString:@"collection"]) {
        NSString *path = args[@"path"];
        if (!path) {
          if (error) *error = parseError(@"collection requires 'path'");
          return nil;
        }
        FIRCollectionReference *ref = [firestore collectionWithPath:path];
        stage = [[__FIRCollectionSourceStageBridge alloc] initWithRef:ref
                                                            firestore:firestore
                                                           forceIndex:nil];
      } else if ([stageName isEqualToString:@"collection_group"]) {
        NSString *path = args[@"path"];
        if (!path) {
          if (error) *error = parseError(@"collection_group requires 'path'");
          return nil;
        }
        stage = [[__FIRCollectionGroupSourceStageBridge alloc] initWithCollectionId:path
                                                                         forceIndex:nil];
      } else if ([stageName isEqualToString:@"database"]) {
        stage = [[__FIRDatabaseSourceStageBridge alloc] init];
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
        stage = [[__FIRDocumentsSourceStageBridge alloc] initWithDocuments:refs
                                                                 firestore:firestore];
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
        __FIRExprBridge *expr = [exprParser parseBooleanExpression:exprMap error:&parseErr];
        if (!expr) {
          if (error) *error = parseErr;
          return nil;
        }
        stage = [[__FIRWhereStageBridge alloc] initWithExpr:expr];
      } else if ([stageName isEqualToString:@"search"]) {
        stage = [self parseSearchStageWithArgs:args exprParser:exprParser error:error];
        if (!stage) return nil;
      } else if ([stageName isEqualToString:@"limit"]) {
        NSNumber *limit = args[@"limit"];
        if (![limit isKindOfClass:[NSNumber class]]) {
          if (error) *error = parseError(@"limit requires numeric limit");
          return nil;
        }
        stage = [[__FIRLimitStageBridge alloc] initWithLimit:limit.intValue];
      } else if ([stageName isEqualToString:@"offset"]) {
        NSNumber *offset = args[@"offset"];
        if (![offset isKindOfClass:[NSNumber class]]) {
          if (error) *error = parseError(@"offset requires numeric offset");
          return nil;
        }
        stage = [[__FIROffsetStageBridge alloc] initWithOffset:offset.intValue];
      } else if ([stageName isEqualToString:@"sort"]) {
        NSArray *orderingMaps = args[@"orderings"];
        if (![orderingMaps isKindOfClass:[NSArray class]] || orderingMaps.count == 0) {
          if (error) *error = parseError(@"sort requires at least one ordering");
          return nil;
        }
        NSMutableArray<__FIROrderingBridge *> *orderings = [NSMutableArray array];
        for (id om in orderingMaps) {
          if (![om isKindOfClass:[NSDictionary class]]) continue;
          id exprMap = ((NSDictionary *)om)[@"expression"];
          NSString *dir = ((NSDictionary *)om)[@"order_direction"];
          if (![exprMap isKindOfClass:[NSDictionary class]]) continue;
          __FIRExprBridge *expr = [exprParser parseExpression:exprMap error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
          }
          NSString *direction = [dir isEqualToString:@"asc"] ? @"ascending" : @"descending";
          __FIROrderingBridge *ordering = [[__FIROrderingBridge alloc] initWithExpr:expr
                                                                          Direction:direction];
          [orderings addObject:ordering];
        }
        if (orderings.count == 0) {
          if (error) *error = parseError(@"sort requires at least one ordering");
          return nil;
        }
        stage = [[__FIRSortStageBridge alloc] initWithOrderings:orderings];
      } else if ([stageName isEqualToString:@"select"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          if (error) *error = parseError(@"select requires at least one expression");
          return nil;
        }
        NSMutableDictionary<NSString *, __FIRExprBridge *> *fields =
            [NSMutableDictionary dictionary];
        for (id em in exprMaps) {
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          __FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
          }
          NSString *key = [self keyForExpressionMap:em error:error];
          if (!key) return nil;
          fields[key] = expr;
        }
        stage = [[__FIRSelectStageBridge alloc] initWithSelections:fields];
      } else if ([stageName isEqualToString:@"add_fields"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          if (error) *error = parseError(@"add_fields requires at least one expression");
          return nil;
        }
        NSMutableDictionary<NSString *, __FIRExprBridge *> *fields =
            [NSMutableDictionary dictionary];
        for (id em in exprMaps) {
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          __FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
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
        stage = [[__FIRAddFieldsStageBridge alloc] initWithFields:fields];
      } else if ([stageName isEqualToString:@"remove_fields"]) {
        NSArray *paths = args[@"field_paths"];
        if (![paths isKindOfClass:[NSArray class]] || paths.count == 0) {
          if (error) *error = parseError(@"remove_fields requires field_paths");
          return nil;
        }
        stage = [[__FIRRemoveFieldsStageBridge alloc] initWithFields:paths];
      } else if ([stageName isEqualToString:@"distinct"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          if (error) *error = parseError(@"distinct requires at least one expression");
          return nil;
        }
        NSMutableDictionary<NSString *, __FIRExprBridge *> *fields =
            [NSMutableDictionary dictionary];
        for (id em in exprMaps) {
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          __FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
          }
          NSString *key = [self keyForExpressionMap:em error:error];
          if (!key) return nil;
          fields[key] = expr;
        }
        stage = [[__FIRDistinctStageBridge alloc] initWithGroups:fields];
      } else if ([stageName isEqualToString:@"replace_with"]) {
        id exprMap = args[@"expression"];
        if (![exprMap isKindOfClass:[NSDictionary class]]) {
          if (error) *error = parseError(@"replace_with requires expression");
          return nil;
        }
        __FIRExprBridge *expr = [exprParser parseExpression:exprMap error:&parseErr];
        if (!expr) {
          if (error) *error = parseErr;
          return nil;
        }
        stage = [[__FIRReplaceWithStageBridge alloc] initWithExpr:expr];
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
        stage = [[__FIRUnionStageBridge alloc] initWithOther:otherPipeline];
      } else if ([stageName isEqualToString:@"sample"]) {
        NSString *type = args[@"type"];
        id val = args[@"value"];
        if ([type isEqualToString:@"percentage"]) {
          double v = [val isKindOfClass:[NSNumber class]] ? [(NSNumber *)val doubleValue] : 0;
          stage = [[__FIRSampleStageBridge alloc] initWithPercentage:v];
        } else {
          int v = [val isKindOfClass:[NSNumber class]] ? [(NSNumber *)val intValue] : 0;
          stage = [[__FIRSampleStageBridge alloc] initWithCount:v];
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
        __FIRExprBridge *fieldExpr = nil;
        __FIRExprBridge *aliasExpr = nil;
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
        aliasExpr = [[__FIRFieldBridge alloc] initWithName:aliasStr];
        NSString *indexFieldStr =
            [args[@"index_field"] isKindOfClass:[NSString class]] ? args[@"index_field"] : nil;
        __FIRExprBridge *indexFieldExpr =
            (indexFieldStr.length > 0) ? [[__FIRFieldBridge alloc] initWithName:indexFieldStr]
                                       : nil;
        stage = [[__FIRUnnestStageBridge alloc] initWithField:fieldExpr
                                                        alias:aliasExpr
                                                   indexField:indexFieldExpr];
      } else if ([stageName isEqualToString:@"find_nearest"]) {
        NSString *vectorFieldName = args[@"vector_field"];
        NSArray *vectorValueArray = args[@"vector_value"];
        NSString *distanceMeasure = args[@"distance_measure"];
        NSNumber *limit = [args[@"limit"] isKindOfClass:[NSNumber class]] ? args[@"limit"] : nil;
        NSString *distanceField = [args[@"distance_field"] isKindOfClass:[NSString class]]
                                      ? args[@"distance_field"]
                                      : nil;
        if (![vectorFieldName isKindOfClass:[NSString class]] || vectorFieldName.length == 0) {
          if (error) *error = parseError(@"find_nearest requires 'vector_field'");
          return nil;
        }
        if (![vectorValueArray isKindOfClass:[NSArray class]] || vectorValueArray.count == 0) {
          if (error) *error = parseError(@"find_nearest requires non-empty 'vector_value'");
          return nil;
        }
        if (![distanceMeasure isKindOfClass:[NSString class]] || distanceMeasure.length == 0) {
          if (error) *error = parseError(@"find_nearest requires 'distance_measure'");
          return nil;
        }
        __FIRFieldBridge *embeddingField = [[__FIRFieldBridge alloc] initWithName:vectorFieldName];
        NSMutableArray<NSNumber *> *numbers =
            [NSMutableArray arrayWithCapacity:vectorValueArray.count];
        for (id v in vectorValueArray) {
          if ([v isKindOfClass:[NSNumber class]]) {
            [numbers addObject:(NSNumber *)v];
          }
        }
        if (numbers.count != (NSUInteger)vectorValueArray.count) {
          if (error) *error = parseError(@"find_nearest vector_value must be an array of numbers");
          return nil;
        }
        FIRVectorValue *queryVector = [[FIRVectorValue alloc] initWithArray:numbers];
        stage = [[__FIRFindNearestStageBridge alloc] initWithField:embeddingField
                                                       vectorValue:queryVector
                                                   distanceMeasure:distanceMeasure
                                                             limit:limit
                                                     distanceField:distanceField];
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

+ (__FIRAggregateFunctionBridge *)aggregateFunctionFromMap:(NSDictionary *)funcMap
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
  NSMutableArray<__FIRExprBridge *> *argsArray = [NSMutableArray array];
  if ([argsDict isKindOfClass:[NSDictionary class]]) {
    id exprMap = argsDict[@"expression"];
    if ([exprMap isKindOfClass:[NSDictionary class]]) {
      __FIRExprBridge *expr = [exprParser parseExpression:exprMap error:error];
      if (!expr) return nil;
      [argsArray addObject:expr];
    }
  }
  return [[__FIRAggregateFunctionBridge alloc] initWithName:iosName Args:argsArray];
}

+ (__FIRStageBridge *)parseAggregateStageWithArgs:(NSDictionary *)args
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

+ (__FIRStageBridge *)parseAggregateStageWithOptionsArgs:(NSDictionary *)args
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

+ (__FIRStageBridge *)parseAggregateStageWithAccumulatorMaps:(NSArray *)accumulatorMaps
                                                   groupMaps:(nullable NSArray *)groupMaps
                                                  exprParser:
                                                      (FLTPipelineExpressionParser *)exprParser
                                                       error:(NSError **)error {
  NSError *parseErr = nil;
  NSMutableDictionary<NSString *, __FIRAggregateFunctionBridge *> *accumulators =
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
    __FIRAggregateFunctionBridge *func = [self aggregateFunctionFromMap:funcMap
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

  NSMutableDictionary<NSString *, __FIRExprBridge *> *groups = [NSMutableDictionary dictionary];
  if ([groupMaps isKindOfClass:[NSArray class]] && groupMaps.count > 0) {
    for (NSUInteger g = 0; g < groupMaps.count; g++) {
      id gm = groupMaps[g];
      if (![gm isKindOfClass:[NSDictionary class]]) continue;
      __FIRExprBridge *expr = [exprParser parseExpression:gm error:&parseErr];
      if (!expr) continue;
      NSError *groupKeyError = nil;
      NSString *groupKey = [self keyForExpressionMap:gm error:&groupKeyError];
      if (![groupKey isKindOfClass:[NSString class]] || groupKey.length == 0) {
        if (error)
          *error =
              groupKeyError
                  ?: parseError(
                         @"aggregate group expression must be a field reference or have an alias");
        return nil;
      }
      groups[groupKey] = expr;
    }
  }

  return [[__FIRAggregateStageBridge alloc] initWithAccumulators:accumulators groups:groups];
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
  NSArray<__FIRStageBridge *> *stageBridges = [self parseStagesWithFirestore:firestore
                                                                      stages:stages
                                                                       error:&parseErr];
  if (!stageBridges) {
    completion(nil, parseErr);
    return;
  }

  __FIRPipelineBridge *pipeline = [[__FIRPipelineBridge alloc] initWithStages:stageBridges
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
  NSArray<__FIRStageBridge *> *stageBridges = [self parseStagesWithFirestore:firestore
                                                                      stages:stages
                                                                       error:error];
  if (!stageBridges) return nil;
  return [[__FIRPipelineBridge alloc] initWithStages:stageBridges db:firestore];
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
