// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of 'common_library.dart';

/// ConnectorConfig options required for connecting to a Data Connect instance.
class ConnectorConfig {
  /// Constructor
  ConnectorConfig(this.location, this.connector, this.serviceId);

  /// location
  String location;

  /// connector
  String connector;

  /// serviceId
  String serviceId;

  /// String representation of connectorConfig
  String toJson() {
    return jsonEncode({
      'location': location,
      'connector': connector,
      'serviceId': serviceId,
    });
  }
}

/// DataConnectOptions includes the Project ID along with the existing ConnectorConfig.
class DataConnectOptions extends ConnectorConfig {
  /// Constructor
  DataConnectOptions(
    this.projectId,
    String location,
    String connector,
    String serviceId,
  ) : super(location, connector, serviceId);

  /// projectId for Firebase App
  String projectId;
}
