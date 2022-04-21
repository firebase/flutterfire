// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_dynamic_links;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
export 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart'
    show
        AndroidParameters,
        DynamicLinkParameters,
        FirebaseDynamicLinksPlatform,
        GoogleAnalyticsParameters,
        IOSParameters,
        ITunesConnectAnalyticsParameters,
        NavigationInfoParameters,
        PendingDynamicLinkData,
        PendingDynamicLinkDataAndroid,
        PendingDynamicLinkDataIOS,
        MatchType,
        ShortDynamicLink,
        ShortDynamicLinkType,
        SocialMetaTagParameters;
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/foundation.dart';

part 'src/firebase_dynamic_links.dart';
