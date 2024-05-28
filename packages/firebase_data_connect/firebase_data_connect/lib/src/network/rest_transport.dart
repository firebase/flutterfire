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
  @override
  Future<OperationResult<Data, Variables>> invokeMutation<
          Data extends DataConnectClass, Variables extends DataConnectClass>(
      String queryName, Serializer serialize, Variables? vars) async {
    String project = options.projectId;
    String location = options.location;
    String service = options.serviceId;
    String connector = options.connector;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    Map<String, dynamic> body = {
      'name':
          'projects/$project/locations/$location/services/$service/connectors/$connector',
      'operationName': queryName,
    };
    if (vars != null && vars.toJson() != '') {
      body['variables'] = json.decode(vars.toJson());
    }
    print(json.encode(body));
    http.Response r = await http.post(Uri.parse('$_url:executeMutation'),
        body: json.encode(body), headers: headers);
    return OperationResult(
        serialize(jsonEncode(jsonDecode(r.body)['data'])), vars);
  }

  @override
  Future<OperationResult<Data, Variables>> invokeQuery<
          Data extends DataConnectClass, Variables extends DataConnectClass>(
      String queryName, Serializer serialize, Variables? vars) async {
    String project = options.projectId;
    String location = options.location;
    String service = options.serviceId;
    String connector = options.connector;
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    Map<String, dynamic> body = {
      'name':
          'projects/$project/locations/$location/services/$service/connectors/$connector',
      'operationName': queryName,
    };
    if (vars != null && vars.toJson() != '') {
      body['variables'] = vars;
    }
    http.Response r = await http.post(Uri.parse('$_url:executeQuery'),
        body: json.encode(body), headers: headers);
    return OperationResult(
        serialize(jsonEncode(jsonDecode(r.body)['data'])), vars);
  }
}

DataConnectTransport getTransport(
        TransportOptions transportOptions, DataConnectOptions options) =>
    RestTransport(transportOptions, options);
