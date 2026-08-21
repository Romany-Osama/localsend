import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:localsend_isolates/model/device.dart';

class StreamBrowseClient {
  final Device device;
  final http.Client _client;
  String? sessionId;

  StreamBrowseClient(this.device) : _client = http.Client();

  Uri _uri(String path, [Map<String, String>? query]) {
    final scheme = device.https ? 'https' : 'http';
    return Uri(
      scheme: scheme,
      host: device.ip ?? (throw StateError('The selected device has no HTTP address')),
      port: device.port,
      path: path,
      queryParameters: query,
    );
  }

  Future<dynamic> _request(String method, Uri uri, {Object? body}) async {
    final request = http.Request(method, uri);
    request.headers['content-type'] = 'application/json';
    if (body != null) {
      request.body = jsonEncode(body);
    }
    final response = await _client.send(request);
    final text = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Stream request failed (${response.statusCode}): $text');
    }
    return text.isEmpty ? null : jsonDecode(text);
  }

  Future<void> openSession() async {
    final response = await _request(
      'POST',
      _uri('/api/localsend/stream/v1/session'),
      body: {'userAgent': 'LocalSend Stream & Browse'},
    ) as Map<String, dynamic>;
    sessionId = response['sessionId'] as String;
  }

  Future<List<StreamRemoteRoot>> roots() async {
    final id = sessionId ?? (throw StateError('Stream session is not open'));
    final response = await _request(
      'GET',
      _uri('/api/localsend/stream/v1/roots', {'sessionId': id}),
    ) as List<dynamic>;
    return response.map((item) => StreamRemoteRoot.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }

  Future<List<StreamRemoteEntry>> entries({required String rootId, String path = ''}) async {
    final id = sessionId ?? (throw StateError('Stream session is not open'));
    final response = await _request(
      'GET',
      _uri('/api/localsend/stream/v1/entries', {
        'sessionId': id,
        'rootId': rootId,
        if (path.isNotEmpty) 'path': path,
      }),
    ) as List<dynamic>;
    return response.map((item) => StreamRemoteEntry.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }

  Future<StreamGrant> requestFile({required String rootId, required String path, String purpose = 'open'}) async {
    final id = sessionId ?? (throw StateError('Stream session is not open'));
    final response = await _request(
      'POST',
      _uri('/api/localsend/stream/v1/file-request'),
      body: {'sessionId': id, 'rootId': rootId, 'path': path, 'purpose': purpose},
    ) as Map<String, dynamic>;
    return StreamGrant.fromJson(this, response);
  }

  Uri streamUri(String grantId) {
    final id = sessionId ?? (throw StateError('Stream session is not open'));
    return _uri('/api/localsend/stream/v1/stream', {'sessionId': id, 'grantId': grantId});
  }

  Future<void> revoke() async {
    final id = sessionId;
    if (id == null) return;
    try {
      await _request('POST', _uri('/api/localsend/stream/v1/session/revoke', {'sessionId': id}));
    } finally {
      sessionId = null;
    }
  }

  Future<void> dispose() async {
    await revoke();
    _client.close();
  }
}

class StreamRemoteRoot {
  final String id;
  final String name;

  const StreamRemoteRoot({required this.id, required this.name});

  factory StreamRemoteRoot.fromJson(Map<String, dynamic> json) {
    return StreamRemoteRoot(id: json['id'] as String, name: json['name'] as String);
  }
}

class StreamRemoteEntry {
  final String rootId;
  final String path;
  final String name;
  final String kind;
  final int size;
  final String? mimeType;
  final bool streamable;

  const StreamRemoteEntry({
    required this.rootId,
    required this.path,
    required this.name,
    required this.kind,
    required this.size,
    required this.mimeType,
    required this.streamable,
  });

  bool get isDirectory => kind == 'directory';

  factory StreamRemoteEntry.fromJson(Map<String, dynamic> json) {
    return StreamRemoteEntry(
      rootId: json['rootId'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
      kind: json['kind'] as String,
      size: (json['size'] as num).toInt(),
      mimeType: json['mimeType'] as String?,
      streamable: json['streamable'] as bool? ?? false,
    );
  }
}

class StreamGrant {
  final StreamBrowseClient client;
  final String requestId;
  final String grantId;
  final StreamRemoteEntry file;
  final int expiresInSeconds;

  const StreamGrant({
    required this.client,
    required this.requestId,
    required this.grantId,
    required this.file,
    required this.expiresInSeconds,
  });

  Uri get uri => client.streamUri(grantId);

  factory StreamGrant.fromJson(StreamBrowseClient client, Map<String, dynamic> json) {
    return StreamGrant(
      client: client,
      requestId: json['requestId'] as String,
      grantId: json['grantId'] as String,
      file: StreamRemoteEntry.fromJson(json['file'] as Map<String, dynamic>),
      expiresInSeconds: (json['expiresInSeconds'] as num).toInt(),
    );
  }
}
