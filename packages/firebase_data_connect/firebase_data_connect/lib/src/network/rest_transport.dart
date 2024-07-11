part of firebase_data_connect_rest;

class RestTransport implements DataConnectTransport {
  RestTransport(this.transportOptions, this.options) {
    String protocol = 'http';
    if (transportOptions.isSecure == null ||
        transportOptions.isSecure == true) {
      protocol += 's';
    }
    String host = transportOptions.host;
    int port = transportOptions.port ?? 443;
    String project = options.projectId;
    String location = options.location;
    String service = options.serviceId;
    String connector = options.connector;
    _url =
        '$protocol://$host:$port/v1alpha/projects/$project/locations/$location/services/$service/connectors/$connector';
  }
  late String _url;
  TransportOptions transportOptions;
  DataConnectOptions options;
  Future<Data> invokeOperation<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      OperationType opType,
      String? token) async {
    String project = options.projectId;
    String location = options.location;
    String service = options.serviceId;
    String connector = options.connector;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['X-Firebase-Auth-Token'] = token;
    }
    Map<String, dynamic> body = {
      'name':
          'projects/$project/locations/$location/services/$service/connectors/$connector',
      'operationName': queryName,
    };
    if (vars != null && serializer != null) {
      body['variables'] = json.decode(serializer(vars));
    }
    String endpoint =
        opType == OperationType.query ? 'executeQuery' : 'executeMutation';
    http.Response r = await http.post(Uri.parse('$_url:$endpoint'),
        body: json.encode(body), headers: headers);
    return deserializer(jsonEncode(jsonDecode(r.body)['data']));
  }

  @override
  Future<Data> invokeQuery<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token) async {
    return invokeOperation(
        queryName, deserializer, serializer, vars, OperationType.query, token);
  }

  @override
  Future<Data> invokeMutation<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token) async {
    return invokeOperation(queryName, deserializer, serializer, vars,
        OperationType.mutation, token);
  }
}

DataConnectTransport getTransport(
        TransportOptions transportOptions, DataConnectOptions options) =>
    RestTransport(transportOptions, options);
