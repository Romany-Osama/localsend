import 'dart:convert';

import 'package:localsend_app/provider/http_provider.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:localsend_isolates/rust/api/http.dart';
import 'package:localsend_isolates/rust/api/model.dart';

class HomeHubClient {
  final Device device;
  final RsHttpClient _client;

  HomeHubClient({required HttpClientCollection clients, required this.device}) : _client = clients.pinnedTo(device.fingerprint);

  Future<HomeHubEventResult> sendTransferOffer({
    required String offerId,
    required String groupId,
    required String senderDeviceId,
    required String senderAlias,
    required List<Map<String, dynamic>> files,
  }) async {
    final ip = device.ip;
    if (ip?.trim().isNotEmpty != true || device.port <= 0 || device.fingerprint.trim().isEmpty) {
      throw StateError('The selected device has no authenticated LAN address');
    }
    final response = await _client.postJson(
      protocol: device.https ? ProtocolType.https : ProtocolType.http,
      ip: ip!,
      port: device.port,
      path: '/home-hub/v1/transfers/offer',
      body: jsonEncode({
        'offerId': offerId,
        'groupId': groupId,
        'senderDeviceId': senderDeviceId,
        'senderAlias': senderAlias,
        'files': files,
      }),
    );
    return HomeHubEventResult.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<HomeHubEventResult> sendChat({
    required String eventId,
    required String groupId,
    required String senderDeviceId,
    required String senderAlias,
    required String text,
    required String createdAt,
  }) async {
    final ip = device.ip;
    if (ip?.trim().isNotEmpty != true || device.port <= 0 || device.fingerprint.trim().isEmpty) {
      throw StateError('The selected device has no authenticated LAN address');
    }
    final response = await _client.postJson(
      protocol: device.https ? ProtocolType.https : ProtocolType.http,
      ip: ip!,
      port: device.port,
      path: '/home-hub/v1/events',
      body: jsonEncode({
        'eventId': eventId,
        'groupId': groupId,
        'senderDeviceId': senderDeviceId,
        'senderAlias': senderAlias,
        'text': text,
        'createdAt': createdAt,
      }),
    );
    return HomeHubEventResult.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<HomeHubInviteResult> sendInvite({
    required String inviteId,
    required String groupId,
    required String groupName,
    required String senderDeviceId,
    required String senderAlias,
    required String role,
    required String createdAt,
    String? expiresAt,
  }) async {
    final ip = device.ip;
    if (ip?.trim().isNotEmpty != true || device.port <= 0 || device.fingerprint.trim().isEmpty) {
      throw StateError('The selected device has no authenticated LAN address');
    }
    final targetIp = ip!;
    final body = jsonEncode({
      'inviteId': inviteId,
      'groupId': groupId,
      'groupName': groupName,
      'senderDeviceId': senderDeviceId,
      'senderAlias': senderAlias,
      'role': role,
      'createdAt': createdAt,
      ...?(expiresAt == null ? null : {'expiresAt': expiresAt}),
    });
    final response = await _client.postJson(
      protocol: device.https ? ProtocolType.https : ProtocolType.http,
      ip: targetIp,
      port: device.port,
      path: '/home-hub/v1/invite',
      body: body,
    );
    return HomeHubInviteResult.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }
}

class HomeHubEventResult {
  final String eventId;
  final bool accepted;

  const HomeHubEventResult({required this.eventId, required this.accepted});

  factory HomeHubEventResult.fromJson(Map<String, dynamic> json) {
    final eventId = json['eventId'];
    final accepted = json['accepted'];
    if (eventId is! String || eventId.trim().isEmpty || accepted is! bool) {
      throw const FormatException('Invalid Home Hub event response');
    }
    return HomeHubEventResult(eventId: eventId, accepted: accepted);
  }
}

class HomeHubInviteResult {
  final String inviteId;
  final bool accepted;

  const HomeHubInviteResult({required this.inviteId, required this.accepted});

  factory HomeHubInviteResult.fromJson(Map<String, dynamic> json) {
    final inviteId = json['inviteId'];
    final accepted = json['accepted'];
    if (inviteId is! String || inviteId.trim().isEmpty || accepted is! bool) {
      throw const FormatException('Invalid Home Hub invitation response');
    }
    return HomeHubInviteResult(inviteId: inviteId, accepted: accepted);
  }
}
