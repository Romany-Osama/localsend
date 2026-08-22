import 'package:localsend_app/model/home_hub.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:uuid/uuid.dart';

final homeHubProvider = ReduxProvider<HomeHubService, HomeHubState>((ref) {
  return HomeHubService(ref.read(persistenceProvider));
});

class HomeHubState {
  final List<HomeHubGroup> groups;
  final List<HomeHubInvite> invites;
  final List<HomeHubChatMessage> messages;
  final List<HomeHubOutboxItem> outbox;

  const HomeHubState({
    required this.groups,
    required this.invites,
    required this.messages,
    required this.outbox,
  });

  HomeHubState copyWith({
    List<HomeHubGroup>? groups,
    List<HomeHubInvite>? invites,
    List<HomeHubChatMessage>? messages,
    List<HomeHubOutboxItem>? outbox,
  }) {
    return HomeHubState(
      groups: List.unmodifiable(groups ?? this.groups),
      invites: List.unmodifiable(invites ?? this.invites),
      messages: List.unmodifiable(messages ?? this.messages),
      outbox: List.unmodifiable(outbox ?? this.outbox),
    );
  }
}

class HomeHubService extends ReduxNotifier<HomeHubState> {
  final PersistenceService _persistence;

  HomeHubService(this._persistence);

  @override
  HomeHubState init() {
    final groups = _persistence
        .getHomeHubGroups()
        .map(
          (group) => group.copyWith(
            members: group.members.where((member) {
              return member.deviceId.trim().isNotEmpty &&
                  (member.deviceId == group.ownerDeviceId || !member.isExpired);
            }).toList(),
          ),
        )
        .where((group) => group.id.trim().isNotEmpty && group.ownerDeviceId.trim().isNotEmpty)
        .toList();
    final invites = _persistence
        .getHomeHubInvites()
        .where((invite) => invite.id.trim().isNotEmpty && (!invite.isExpired || invite.status != HomeHubInviteStatus.pending))
        .toList();
    final messages = _persistence.getHomeHubMessages();
    final outbox = _persistence
        .getHomeHubOutbox()
        .where((item) => item.message.id.trim().isNotEmpty && item.recipientDeviceId.trim().isNotEmpty)
        .toList();
    return HomeHubState(groups: groups, invites: invites, messages: messages, outbox: outbox);
  }

  Future<HomeHubState> persist(HomeHubState next) async {
    await _persistence.setHomeHubGroups(next.groups);
    await _persistence.setHomeHubInvites(next.invites);
    await _persistence.setHomeHubMessages(next.messages);
    await _persistence.setHomeHubOutbox(next.outbox);
    return next;
  }
}

class CreateHomeHubGroupAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final String name;
  final String ownerDeviceId;
  final String ownerAlias;

  CreateHomeHubGroupAction({
    required this.name,
    required this.ownerDeviceId,
    required this.ownerAlias,
  });

  @override
  Future<HomeHubState> reduce() async {
    final cleanName = name.trim();
    final cleanOwnerId = ownerDeviceId.trim();
    final cleanAlias = ownerAlias.trim();
    if (cleanName.isEmpty || cleanOwnerId.isEmpty || cleanAlias.isEmpty) return state;

    final now = DateTime.now();
    final group = HomeHubGroup(
      id: const Uuid().v4(),
      name: cleanName,
      ownerDeviceId: cleanOwnerId,
      createdAt: now,
      members: [
        HomeHubMember(
          deviceId: cleanOwnerId,
          alias: cleanAlias,
          role: HomeHubRole.owner,
          joinedAt: now,
        ),
      ],
    );
    return notifier.persist(state.copyWith(groups: [...state.groups, group]));
  }
}

class RenameHomeHubGroupAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final String groupId;
  final String name;

  RenameHomeHubGroupAction({required this.groupId, required this.name});

  @override
  Future<HomeHubState> reduce() async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return state;
    final index = state.groups.indexWhere((group) => group.id == groupId);
    if (index == -1) return state;
    final groups = [...state.groups];
    groups[index] = groups[index].copyWith(name: cleanName);
    return notifier.persist(state.copyWith(groups: groups));
  }
}

class DeleteHomeHubGroupAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final String groupId;

  DeleteHomeHubGroupAction(this.groupId);

  @override
  Future<HomeHubState> reduce() async {
    final groups = state.groups.where((group) => group.id != groupId).toList();
    if (groups.length == state.groups.length) return state;
    return notifier.persist(state.copyWith(groups: groups));
  }
}

class UpsertHomeHubInviteAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final HomeHubInvite invite;

  UpsertHomeHubInviteAction(this.invite);

  @override
  Future<HomeHubState> reduce() async {
    if (invite.isExpired || invite.status != HomeHubInviteStatus.pending) return state;
    final invites = [...state.invites];
    final index = invites.indexWhere((item) => item.id == invite.id);
    if (index == -1) {
      invites.add(invite);
    } else {
      invites[index] = invite;
    }
    return notifier.persist(state.copyWith(invites: invites));
  }
}

class DeclineHomeHubInviteAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final String inviteId;

  DeclineHomeHubInviteAction(this.inviteId);

  @override
  Future<HomeHubState> reduce() async {
    return _setInviteStatus(HomeHubInviteStatus.declined);
  }

  Future<HomeHubState> _setInviteStatus(HomeHubInviteStatus status) async {
    final index = state.invites.indexWhere((invite) => invite.id == inviteId);
    if (index == -1) return state;
    final invites = [...state.invites];
    invites[index] = invites[index].copyWith(status: status);
    return notifier.persist(state.copyWith(invites: invites));
  }
}

class AcceptHomeHubInviteAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final String inviteId;
  final String selfDeviceId;
  final String selfAlias;

  AcceptHomeHubInviteAction({
    required this.inviteId,
    required this.selfDeviceId,
    required this.selfAlias,
  });

  @override
  Future<HomeHubState> reduce() async {
    final inviteIndex = state.invites.indexWhere((invite) => invite.id == inviteId);
    if (inviteIndex == -1) return state;
    final invite = state.invites[inviteIndex];
    final cleanSelfId = selfDeviceId.trim();
    final cleanSelfAlias = selfAlias.trim();
    if (invite.status != HomeHubInviteStatus.pending ||
        invite.isExpired ||
        cleanSelfId.isEmpty ||
        cleanSelfAlias.isEmpty ||
        invite.inviterDeviceId == cleanSelfId) {
      return state;
    }

    final memberTime = DateTime.now();
    final existingIndex = state.groups.indexWhere((group) => group.id == invite.groupId);
    final groups = [...state.groups];
    final self = HomeHubMember(
      deviceId: cleanSelfId,
      alias: cleanSelfAlias,
      role: invite.role,
      joinedAt: memberTime,
      expiresAt: invite.expiresAt,
    );
    if (existingIndex == -1) {
      groups.add(
        HomeHubGroup(
          id: invite.groupId,
          name: invite.groupName,
          ownerDeviceId: invite.inviterDeviceId,
          createdAt: invite.createdAt,
          members: [
            HomeHubMember(
              deviceId: invite.inviterDeviceId,
              alias: invite.inviterAlias,
              role: HomeHubRole.owner,
              joinedAt: invite.createdAt,
            ),
            self,
          ],
        ),
      );
    } else {
      final members = [...groups[existingIndex].members]
        ..removeWhere((member) => member.deviceId == cleanSelfId)
        ..add(self);
      groups[existingIndex] = groups[existingIndex].copyWith(members: members);
    }

    final invites = [...state.invites];
    invites[inviteIndex] = invite.copyWith(status: HomeHubInviteStatus.accepted);
    return notifier.persist(state.copyWith(groups: groups, invites: invites));
  }
}

class UpsertHomeHubGroupAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final HomeHubGroup group;

  UpsertHomeHubGroupAction(this.group);

  @override
  Future<HomeHubState> reduce() async {
    if (group.id.trim().isEmpty ||
        group.ownerDeviceId.trim().isEmpty ||
        group.members.isEmpty ||
        group.members.any((member) => member.deviceId.trim().isEmpty)) {
      return state;
    }
    final groups = [...state.groups];
    final index = groups.indexWhere((item) => item.id == group.id);
    if (index == -1) {
      groups.add(group);
    } else {
      groups[index] = group;
    }
    return notifier.persist(state.copyWith(groups: groups));
  }
}

class RemoveHomeHubMemberAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final String groupId;
  final String deviceId;

  RemoveHomeHubMemberAction({required this.groupId, required this.deviceId});

  @override
  Future<HomeHubState> reduce() async {
    if (groupId.trim().isEmpty || deviceId.trim().isEmpty) return state;
    final index = state.groups.indexWhere((group) => group.id == groupId);
    if (index == -1) return state;
    final group = state.groups[index];
    if (group.ownerDeviceId == deviceId) return state;
    final groups = [...state.groups];
    groups[index] = group.copyWith(
      members: group.members.where((member) => member.deviceId != deviceId).toList(),
    );
    return notifier.persist(state.copyWith(groups: groups));
  }
}

class UpdateHomeHubMemberRoleAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final String groupId;
  final String deviceId;
  final HomeHubRole role;

  UpdateHomeHubMemberRoleAction({
    required this.groupId,
    required this.deviceId,
    required this.role,
  });

  @override
  Future<HomeHubState> reduce() async {
    if (groupId.trim().isEmpty || deviceId.trim().isEmpty) return state;
    final index = state.groups.indexWhere((group) => group.id == groupId);
    if (index == -1) return state;
    final group = state.groups[index];
    if (group.ownerDeviceId == deviceId || role == HomeHubRole.owner) return state;
    final members = group.members.map((member) {
      return member.deviceId == deviceId ? member.copyWith(role: role) : member;
    }).toList();
    final groups = [...state.groups];
    groups[index] = group.copyWith(members: members);
    return notifier.persist(state.copyWith(groups: groups));
  }
}


class AddHomeHubChatMessageAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final HomeHubChatMessage message;

  AddHomeHubChatMessageAction(this.message);

  @override
  Future<HomeHubState> reduce() async {
    if (message.id.trim().isEmpty || message.groupId.trim().isEmpty || message.text.trim().isEmpty) return state;
    if (state.messages.any((item) => item.id == message.id)) return state;
    final messages = [...state.messages, message]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return notifier.persist(state.copyWith(messages: messages));
  }
}

class EnqueueHomeHubChatMessageAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final HomeHubChatMessage message;
  final List<HomeHubOutboxItem> deliveries;

  EnqueueHomeHubChatMessageAction({required this.message, required this.deliveries});

  @override
  Future<HomeHubState> reduce() async {
    if (message.id.trim().isEmpty || message.groupId.trim().isEmpty || message.text.trim().isEmpty) return state;
    final messages = state.messages.any((item) => item.id == message.id) ? [...state.messages] : [...state.messages, message];
    final outbox = [...state.outbox];
    for (final delivery in deliveries) {
      if (delivery.recipientDeviceId.trim().isEmpty || outbox.any((item) => item.message.id == message.id && item.recipientDeviceId == delivery.recipientDeviceId)) continue;
      outbox.add(delivery);
    }
    return notifier.persist(state.copyWith(messages: messages, outbox: outbox));
  }
}

class UpdateHomeHubOutboxItemAction extends AsyncReduxAction<HomeHubService, HomeHubState> {
  final String messageId;
  final String recipientDeviceId;
  final HomeHubDeliveryStatus status;

  UpdateHomeHubOutboxItemAction({required this.messageId, required this.recipientDeviceId, required this.status});

  @override
  Future<HomeHubState> reduce() async {
    final outbox = state.outbox.map((item) {
      if (item.message.id != messageId || item.recipientDeviceId != recipientDeviceId) return item;
      return item.copyWith(status: status, attempts: item.attempts + 1, updatedAt: DateTime.now());
    }).toList();
    return notifier.persist(state.copyWith(outbox: outbox));
  }
}
