library firebase_data_connect;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'src/common/common_library.dart';
import 'src/network/transport_library.dart'
    if (dart.library.io) 'src/network/grpc_library.dart'
    if (dart.library.html) 'src/network/rest_library.dart';

export 'src/common/common_library.dart';

part 'src/core/ref.dart';
part 'src/firebase_data_connect.dart';
part 'src/optional.dart';
part 'src/timestamp.dart';
