// Copyright 2026 Google LLC
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

/// The kind of streaming request.
enum RequestKind {
  subscribe,
  execute,
  resume,
  cancel,
}

/// Request to execute or subscribe to a Data Connect query or mutation.
class ExecuteRequest {
  ExecuteRequest(this.operationName, this.variables);

  final String operationName;
  final Map<String, dynamic>? variables;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['operationName'] = operationName;
    if (variables != null) {
      data['variables'] = variables;
    }
    return data;
  }
}

/// Request to resume a query.
class ResumeRequest {
  ResumeRequest();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }
}

/// StreamRequest defines the request of Data Connect's bi-directional streaming API.
class StreamRequest {
  StreamRequest({
    this.name,
    this.headers,
    this.requestId,
    this.requestKind,
    this.subscribe,
    this.execute,
    this.resume,
    this.cancel,
    this.dataEtag,
  });

  /// The resource name of the connector.
  final String? name;

  /// Optional headers.
  final Map<String, String>? headers;

  /// The request id used to identify a request within the stream.
  final String? requestId;

  /// Kind of the request.
  final RequestKind? requestKind;

  /// Subscribe to a Data Connect query.
  final ExecuteRequest? subscribe;

  /// Execute a Data Connect query or mutation.
  final ExecuteRequest? execute;

  /// Resume a query.
  final ResumeRequest? resume;

  /// Signal that the client is no longer interested.
  final bool? cancel;

  /// Etag for caching.
  final String? dataEtag;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name;
    }
    if (headers != null) {
      data['headers'] = headers;
    }
    if (requestId != null) {
      data['requestId'] = requestId;
    }
    if (dataEtag != null) {
      data['dataEtag'] = dataEtag;
    }

    if (subscribe != null) {
      data['subscribe'] = subscribe!.toJson();
    } else if (execute != null) {
      data['execute'] = execute!.toJson();
    } else if (resume != null) {
      data['resume'] = resume!.toJson();
    } else if (cancel == true) {
      data['cancel'] = <String, dynamic>{};
    }

    return data;
  }
}

/// StreamResponse defines the response of Data Connect's bi-directional streaming API.
class StreamResponse {
  StreamResponse({
    this.requestId,
    this.data,
    this.dataEtag,
    this.errors,
    this.cancelled,
    this.extensions,
  });

  factory StreamResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('result')) {
      json = json['result'] as Map<String, dynamic>;
    } else if (json.containsKey('error')) {
      final errObj = json['error'] as Map<String, dynamic>;
      json = {
        'errors': [
          {'message': errObj['message']}
        ]
      };
    }

    List<dynamic>? errorsList = json['errors'] as List<dynamic>?;

    return StreamResponse(
      requestId: json['requestId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      dataEtag: json['dataEtag'] as String?,
      errors: errorsList,
      cancelled: json['cancelled'] as bool?,
      extensions: json['extensions'] as Map<String, dynamic>?,
    );
  }

  final String? requestId;
  final Map<String, dynamic>? data;
  final String? dataEtag;
  final List<dynamic>? errors;
  final bool? cancelled;
  final Map<String, dynamic>? extensions;
}
