library firebase_data_connect;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:grpc/grpc.dart';
import 'package:json_annotation/json_annotation.dart';

import 'src/generated/connector_service.pbgrpc.dart';
import 'src/generated/google/protobuf/struct.pb.dart';

part 'src/firebase_data_connect.dart';
part 'src/grpc_transport.dart';
part 'src/transport.dart';
