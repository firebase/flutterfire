// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required;

import 'firebase_analytics_platform_interface.dart';

/// The method channel implementation of [FirebaseAnalyticsPlatform].
class MethodChannelFirebaseAnalytics extends FirebaseAnalyticsPlatform {
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/firebase_analytics');

  @override
  Future<void> logEvent({
    @required String name,
    Map<String, dynamic> parameters,
  }) {
    return _channel.invokeMethod<void>('logEvent', <String, dynamic>{
      'name': name,
      'parameters': parameters,
    });
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    return _channel.invokeMethod<void>(
      'setAnalyticsCollectionEnabled',
      enabled,
    );
  }

  @override
  Future<void> setUserId(String id) {
    return _channel.invokeMethod<void>('setUserId', id);
  }

  @override
  Future<void> setCurrentScreen({
    @required String screenName,
    String screenClassOverride,
  }) {
    return _channel.invokeMethod<void>('setCurrentScreen', <String, String>{
      'screenName': screenName,
      'screenClassOverride': screenClassOverride,
    });
  }

  @override
  Future<void> setUserProperty({
    @required String name,
    @required String value,
  }) {
    return _channel.invokeMethod<void>('setUserProperty', <String, String>{
      'name': name,
      'value': value,
    });
  }

  @override
  Future<void> resetAnalyticsData() {
    return _channel.invokeMethod<void>('resetAnalyticsData');
  }

  @override
  Future<void> setSessionTimeoutDuration(int milliseconds) {
    return _channel.invokeMethod<void>(
        'setSessionTimeoutDuration', milliseconds);
  }

  @override
  Future<void> logAddToCart({
    @required String itemId,
    @required String itemName,
    @required String itemCategory,
    @required int quantity,
    double price,
    double value,
    String currency,
    String origin,
    String itemLocationId,
    String destination,
    String startDate,
    String endDate,
  }) {
    return _channel.invokeMethod<void>('logAddToCart', <String, dynamic>{
    "itemId" : itemId,
    "itemName" : itemName,
    "itemCategory" : itemCategory,
    "quantity" : quantity,
    "price" : price,
    "value" : value,
    "currency" : currency,
    "origin" : origin,
    "itemLocationId" : itemLocationId,
    "destination" : destination,
    "startDate" : startDate,
    "endDate" : endDate,
    });
  }

  @override
  Future<void> logEcommercePurchase({
    String currency,
    double value,
    String transactionId,
    double tax,
    double shipping,
    String coupon,
    String location,
    int numberOfNights,
    int numberOfRooms,
    int numberOfPassengers,
    String origin,
    String destination,
    String startDate,
    String endDate,
    String travelClass,
  }) {
    return _channel.invokeMethod<void>('logEcommercePurchase', <String, dynamic>{
    "currency" : currency,
    "value" : value,
    "transactionId" : transactionId,
    "tax" : tax,
    "shipping" : shipping,
    "coupon" : coupon,
    "location" : location,
    "numberOfNights" : numberOfNights,
    "numberOfRooms" : numberOfRooms,
    "numberOfPassengers" : numberOfPassengers,
    "origin" : origin,
    "destination" : destination,
    "startDate" : startDate,
    "endDate" : endDate,
    "travelClass" : travelClass,
    });
  }

}
