// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';

const _facebookBlue = Color(0xff1878F2);
const _facebookWhite = Color(0xffffffff);

const _backgroundColor = ThemedColor(_facebookBlue, _facebookBlue);
const _color = ThemedColor(_facebookWhite, _facebookWhite);

const _iconSvg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="1428px" height="1428px" viewBox="0 0 1428 1428" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <title>f_logo_RGB-White_1024</title>
    <g id="f_logo_RGB-White_1024" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <path d="M1031.76618,715.821184 C1031.76618,540.23251 889.423667,397.89 713.834994,397.89 C538.24632,397.89 395.90381,540.23251 395.90381,715.821184 C395.90381,874.509827 512.166649,1006.03895 664.158246,1029.89 L664.158246,807.723166 L583.433532,807.723166 L583.433532,715.821184 L664.158246,715.821184 L664.158246,645.77697 C664.158246,566.095467 711.623137,522.081869 784.245574,522.081869 C819.029853,522.081869 855.413724,528.291462 855.413724,528.291462 L855.413724,606.532339 L815.323347,606.532339 C775.82847,606.532339 763.511741,631.039742 763.511741,656.182385 L763.511741,715.821184 L851.687968,715.821184 L837.592191,807.723166 L763.511741,807.723166 L763.511741,1029.89 C915.503339,1006.03895 1031.76618,874.509827 1031.76618,715.821184" id="Fill-1" fill="#FFFFFE"></path>
    </g>
</svg>
''';

const _iconSrc = ThemedIconSrc(_iconSvg, _iconSvg);

class FacebookProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  const FacebookProviderButtonStyle();

  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;

  @override
  String get assetsPackage => 'firebase_ui_oauth_facebook';
}
