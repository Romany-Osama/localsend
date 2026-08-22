import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String _requiredString(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Home Hub $field must not be empty');
  }
  return value.trim();
}

DateTime _requiredDateTime(Object? value, String field) {
  final raw = _requiredString(value, field);
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    throw FormatException('Home Hub $field is not a valid date');
  }
  return parsed.toLocal();
}

DateTime? _optionalDateTime(Object? value, String field) {
  if (value == null) return null;
  return _requiredDateTime(value, field);
}

enum HomeHubRole {
  owner,
  sender,
  viewer,
  guest,
}

enum HomeHubInviteStatus {
  pending,
  accepted,
  declined,
  revoked,
}

class HomeHubMember {
  final String deviceId;
  final String alias;
  final HomeHubRole role;
  final DateTime joinedAt;
  final DateTime? expiresAt;

  const HomeHubMember({
    required this.deviceId,
    required this.alias,
    required this.role,
    required this.joinedAt,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && !expiresAt!.isAfter(DateTime.now());

  HomeHubMember copyWith({
    String? alias,
    HomeHubRole? role,
    DateTime? joinedAt,
    DateTime? expiresAt,
    bool clearExpiry = false,
  }) {
    return HomeHubMember(
      deviceId: deviceId,
      alias: alias ?? this.alias,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      expiresAt: clearExpiry ? null : (expiresAt ?? this.expiresAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'alias': alias,
        'role': role.name,
        'joinedAt': joinedAt.toUtc().toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toUtc().toIso8601String(),
      };

  factory HomeHubMember.fromJson(Map<String, dynamic> json) {
    return HomeHubMember(
      deviceId: _requiredString(json['deviceId'], 'member deviceId'),
      alias: (json['alias'] as String?)?.trim().isNotEmpty == true ? (json['alias'] as String).trim() : 'Unknown device',
      role: HomeHubRole.values.firstWhere(
        (value) => value.name == json['role'],
        orElse: () => HomeHubRole.viewer,
      ),
      joinedAt: _requiredDateTime(json['joinedAt'], 'member joinedAt'),
      expiresAt: _optionalDateTime(json['expiresAt'], 'member expiresAt'),
    );
  }
}

class HomeHubGroup {
  final String id;
  final String name;
  final String ownerDeviceId;
  final DateTime createdAt;
  final List<HomeHubMember> members;

  const HomeHubGroup({
    required this.id,
    required this.name,
    required this.ownerDeviceId,
    required this.createdAt,
    required this.members,
  });

  HomeHubMember? member(String deviceId) {
    for (final member in members) {
      if (member.deviceId == deviceId) return member;
    }
    return null;
  }

  HomeHubGroup copyWith({
    String? name,
    String? ownerDeviceId,
    DateTime? createdAt,
    List<HomeHubMember>? members,
  }) {
    return HomeHubGroup(
      id: id,
      name: name ?? this.name,
      ownerDeviceId: ownerDeviceId ?? this.ownerDeviceId,
      createdAt: createdAt ?? this.createdAt,
      members: List.unmodifiable(members ?? this.members),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ownerDeviceId': ownerDeviceId,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'members': members.map((member) => member.toJson()).toList(),
      };

  factory HomeHubGroup.fromJson(Map<String, dynamic> json) {
    final members = (json['members'] as List<dynamic>? ?? const [])
        .map((member) => HomeHubMember.fromJson(Map<String, dynamic>.from(member as Map)))
        .toList(growable: false);
    return HomeHubGroup(
      id: _requiredString(json['id'], 'group id'),
      name: _requiredString(json['name'], 'group name'),
      ownerDeviceId: _requiredString(json['ownerDeviceId'], 'owner deviceId'),
      createdAt: _requiredDateTime(json['createdAt'], 'group createdAt'),
      members: List.unmodifiable(members),
    );
  }
}

class HomeHubInvite {
  final String id;
  final String groupId;
  final String groupName;
  final String inviterDeviceId;
  final String inviterAlias;
  final HomeHubRole role;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final HomeHubInviteStatus status;

  const HomeHubInvite({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.inviterDeviceId,
    required this.inviterAlias,
    required this.role,
    required this.createdAt,
    required this.status,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && !expiresAt!.isAfter(DateTime.now());

  HomeHubInvite copyWith({
    HomeHubInviteStatus? status,
  }) {
    return HomeHubInvite(
      id: id,
      groupId: groupId,
      groupName: groupName,
      inviterDeviceId: inviterDeviceId,
      inviterAlias: inviterAlias,
      role: role,
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'groupName': groupName,
        'inviterDeviceId': inviterDeviceId,
        'inviterAlias': inviterAlias,
        'role': role.name,
        'createdAt': createdAt.toUtc().toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toUtc().toIso8601String(),
        'status': status.name,
      };

  factory HomeHubInvite.fromJson(Map<String, dynamic> json) {
    return HomeHubInvite(
      id: _requiredString(json['id'], 'invite id'),
      groupId: _requiredString(json['groupId'], 'invite groupId'),
      groupName: _requiredString(json['groupName'], 'invite group name'),
      inviterDeviceId: _requiredString(json['inviterDeviceId'], 'inviter deviceId'),
      inviterAlias: _requiredString(json['inviterAlias'], 'inviter alias'),
      role: HomeHubRole.values.firstWhere(
        (value) => value.name == json['role'],
        orElse: () => HomeHubRole.viewer,
      ),
      createdAt: _requiredDateTime(json['createdAt'], 'invite createdAt'),
      expiresAt: _optionalDateTime(json['expiresAt'], 'invite expiresAt'),
      status: HomeHubInviteStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => HomeHubInviteStatus.pending,
      ),
    );
  }

  factory HomeHubInvite.create({
    required String groupId,
    required String groupName,
    required String inviterDeviceId,
    required String inviterAlias,
    HomeHubRole role = HomeHubRole.viewer,
    DateTime? expiresAt,
  }) {
    return HomeHubInvite(
      id: _uuid.v4(),
      groupId: _requiredString(groupId, 'groupId'),
      groupName: _requiredString(groupName, 'group name'),
      inviterDeviceId: _requiredString(inviterDeviceId, 'inviter deviceId'),
      inviterAlias: _requiredString(inviterAlias, 'inviter alias'),
      role: role,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      status: HomeHubInviteStatus.pending,
    );
  }
}


enum HomeHubDeliveryStatus {
  pending,
  accepted,
  rejected,
  offline,
  transferring,
  completed,
  failed,
}

class HomeHubChatMessage {
  final String id;
  final String groupId;
  final String senderDeviceId;
  final String senderAlias;
  final String text;
  final DateTime createdAt;
  final bool outgoing;

  const HomeHubChatMessage({
    required this.id,
    required this.groupId,
    required this.senderDeviceId,
    required this.senderAlias,
    required this.text,
    required this.createdAt,
    required this.outgoing,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'senderDeviceId': senderDeviceId,
        'senderAlias': senderAlias,
        'text': text,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'outgoing': outgoing,
      };

  factory HomeHubChatMessage.fromJson(Map<String, dynamic> json) {
    return HomeHubChatMessage(
      id: _requiredString(json['id'], 'message id'),
      groupId: _requiredString(json['groupId'], 'message groupId'),
      senderDeviceId: _requiredString(json['senderDeviceId'], 'message senderDeviceId'),
      senderAlias: _requiredString(json['senderAlias'], 'message senderAlias'),
      text: _requiredString(json['text'], 'message text'),
      createdAt: _requiredDateTime(json['createdAt'], 'message createdAt'),
      outgoing: json['outgoing'] == true,
    );
  }
}

class HomeHubOutboxItem {
  final HomeHubChatMessage message;
  final String recipientDeviceId;
  final String recipientAlias;
  final HomeHubDeliveryStatus status;
  final int attempts;
  final DateTime updatedAt;

  const HomeHubOutboxItem({
    required this.message,
    required this.recipientDeviceId,
    required this.recipientAlias,
    required this.status,
    required this.attempts,
    required this.updatedAt,
  });

  HomeHubOutboxItem copyWith({HomeHubDeliveryStatus? status, int? attempts, DateTime? updatedAt}) {
    return HomeHubOutboxItem(
      message: message,
      recipientDeviceId: recipientDeviceId,
      recipientAlias: recipientAlias,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message.toJson(),
        'recipientDeviceId': recipientDeviceId,
        'recipientAlias': recipientAlias,
        'status': status.name,
        'attempts': attempts,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory HomeHubOutboxItem.fromJson(Map<String, dynamic> json) {
    return HomeHubOutboxItem(
      message: HomeHubChatMessage.fromJson(Map<String, dynamic>.from(json['message'] as Map)),
      recipientDeviceId: _requiredString(json['recipientDeviceId'], 'outbox recipientDeviceId'),
      recipientAlias: _requiredString(json['recipientAlias'], 'outbox recipientAlias'),
      status: HomeHubDeliveryStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => HomeHubDeliveryStatus.pending,
      ),
      attempts: json['attempts'] is int ? json['attempts'] as int : 0,
      updatedAt: _requiredDateTime(json['updatedAt'], 'outbox updatedAt'),
    );
  }
}
