import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localsend_app/model/cross_file.dart';
import 'package:localsend_app/model/home_hub.dart';
import 'package:localsend_app/provider/device_info_provider.dart';
import 'package:localsend_app/provider/home_hub_provider.dart';
import 'package:localsend_app/provider/http_provider.dart';
import 'package:localsend_app/provider/network/home_hub/home_hub_client.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/provider/network/server/server_provider.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_isolates/isolate.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:uuid/uuid.dart';

class HomeHubTab extends StatelessWidget {
  const HomeHubTab({super.key});

  Future<void> _createGroup(BuildContext context) async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إنشاء جروب منزلي'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'اسم الجروب',
              hintText: 'العائلة',
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(nameController.text),
              child: const Text('إنشاء'),
            ),
          ],
        );
      },
    );
    nameController.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;

    final self = context.ref.read(deviceFullInfoProvider);
    await context.ref.redux(homeHubProvider).dispatchAsync(
          CreateHomeHubGroupAction(
            name: name,
            ownerDeviceId: self.fingerprint,
            ownerAlias: self.alias,
          ),
        );
    if (context.mounted) context.ref.notifier(serverProvider).syncHomeHubGroups();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch(homeHubProvider);
    final self = context.ref.read(deviceFullInfoProvider);
    final server = context.ref.notifier(serverProvider);
    final pendingInvites = state.invites.where((invite) {
      return invite.status == HomeHubInviteStatus.pending && !invite.isExpired;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Hub'),
        actions: [
          IconButton(
            tooltip: 'إنشاء جروب',
            onPressed: () => _createGroup(context),
            icon: const Icon(Icons.group_add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مركز البيت المحلي', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'جروبات وشات ونقل مباشر داخل شبكة Wi‑Fi فقط. لا يوجد حساب سحابي ولا جهاز مركزي مطلوب أن يعمل طوال الوقت.',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هذا الجهاز: ${self.alias}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _createGroup(context),
                    icon: const Icon(Icons.add),
                    label: const Text('إنشاء جروب جديد'),
                  ),
                ],
              ),
            ),
          ),
          if (server.pendingHomeHubInvites.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('طلبات الانضمام الواردة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _HomeHubInviteApprovalPanel(server: server),
          ],
          if (server.pendingHomeHubTransferOffers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('عروض ملفات تحتاج موافقتك', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _HomeHubTransferApprovalPanel(server: server),
          ],
          if (pendingInvites.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('دعواتي المعلّقة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final invite in pendingInvites) _InviteCard(invite: invite, self: self),
          ],
          const SizedBox(height: 16),
          Text('جروباتي', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (state.groups.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('لم تنشئ أو تقبل أي جروب بعد.'),
              ),
            )
          else
            for (final group in state.groups)
              _GroupCard(
                group: group,
                selfDeviceId: self.fingerprint,
              ),
        ],
      ),
    );
  }
}

class _HomeHubTransferApprovalPanel extends StatelessWidget {
  final ServerService server;

  const _HomeHubTransferApprovalPanel({required this.server});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HttpServerHomeHubTransferOfferEvent>(
      stream: server.homeHubTransferEvents,
      builder: (context, _) {
        final requests = server.pendingHomeHubTransferOffers.values.toList(growable: false);
        if (requests.isEmpty) return const SizedBox.shrink();
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            children: [
              for (final request in requests)
                ListTile(
                  leading: const Icon(Icons.file_copy_outlined),
                  title: Text('${request.senderAlias} يريد إرسال ملفات'),
                  subtitle: Text(
                    '${request.ip} · ${request.files.length} ملف${request.files.length == 1 ? '' : 'ات'}\n${request.files.map((file) => file.name).join('، ')}',
                  ),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'رفض العرض',
                        onPressed: () => server.respondHomeHubTransferOffer(offerId: request.offerId, accept: false),
                        icon: const Icon(Icons.close),
                      ),
                      IconButton(
                        tooltip: 'قبول العرض',
                        onPressed: () => server.respondHomeHubTransferOffer(offerId: request.offerId, accept: true),
                        icon: const Icon(Icons.check),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeHubInviteApprovalPanel extends StatelessWidget {
  final ServerService server;

  const _HomeHubInviteApprovalPanel({required this.server});

  Future<void> _accept(BuildContext context, HttpServerHomeHubInviteRequestEvent event) async {
    final role = HomeHubRole.values.firstWhere((value) => value.name == event.role, orElse: () => HomeHubRole.viewer);
    final createdAt = DateTime.tryParse(event.createdAt)?.toLocal() ?? DateTime.now();
    final expiresAt = event.expiresAt == null ? null : DateTime.tryParse(event.expiresAt!)?.toLocal();
    final invite = HomeHubInvite(
      id: event.inviteId,
      groupId: event.groupId,
      groupName: event.groupName,
      inviterDeviceId: event.senderDeviceId,
      inviterAlias: event.senderAlias,
      role: role,
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: HomeHubInviteStatus.pending,
    );
    await context.ref.redux(homeHubProvider).dispatchAsync(UpsertHomeHubInviteAction(invite));
    if (!context.mounted) return;
    final self = context.ref.read(deviceFullInfoProvider);
    await context.ref.redux(homeHubProvider).dispatchAsync(
          AcceptHomeHubInviteAction(inviteId: event.inviteId, selfDeviceId: self.fingerprint, selfAlias: self.alias),
        );
    if (!context.mounted) return;
    server.acceptHomeHubInvite(event.inviteId);
    server.syncHomeHubGroups();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HttpServerHomeHubInviteRequestEvent>(
      stream: server.homeHubEvents,
      builder: (context, _) {
        final requests = server.pendingHomeHubInvites.values.toList(growable: false);
        if (requests.isEmpty) return const SizedBox.shrink();
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            children: [
              for (final request in requests)
                ListTile(
                  leading: const Icon(Icons.group_add),
                  title: Text('${request.senderAlias} يريد إضافتك إلى ${request.groupName}'),
                  subtitle: Text('${request.ip} · الدور المقترح: ${request.role}'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(tooltip: 'رفض', onPressed: () => server.declineHomeHubInvite(request.inviteId), icon: const Icon(Icons.close)),
                      IconButton(tooltip: 'قبول', onPressed: () => _accept(context, request), icon: const Icon(Icons.check)),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InviteCard extends StatelessWidget {
  final HomeHubInvite invite;
  final Device self;

  const _InviteCard({required this.invite, required this.self});

  @override
  Widget build(BuildContext context) {
    final service = context.ref.redux(homeHubProvider);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.mail_outline),
        title: Text(invite.groupName),
        subtitle: Text('دعوة من ${invite.inviterAlias}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'رفض',
              onPressed: () => service.dispatchAsync(DeclineHomeHubInviteAction(invite.id)),
              icon: const Icon(Icons.close),
            ),
            IconButton(
              tooltip: 'قبول',
              onPressed: () => service.dispatchAsync(
                AcceptHomeHubInviteAction(
                  inviteId: invite.id,
                  selfDeviceId: self.fingerprint,
                  selfAlias: self.alias,
                ),
              ),
              icon: const Icon(Icons.check),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final HomeHubGroup group;
  final String selfDeviceId;

  const _GroupCard({required this.group, required this.selfDeviceId});

  @override
  Widget build(BuildContext context) {
    final member = group.member(selfDeviceId);
    final expiredMembers = group.members.where((item) => item.isExpired).length;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.groups)),
        title: Text(group.name),
        subtitle: Text(
          '${group.members.length} أعضاء · ${member?.role.name ?? 'غير معروف'}${expiredMembers == 0 ? '' : ' · $expiredMembers منتهية'}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HomeHubGroupPage(
              group: group,
              selfDeviceId: selfDeviceId,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeHubChatPage extends StatefulWidget {
  final HomeHubGroup group;
  final String selfDeviceId;

  const HomeHubChatPage({required this.group, required this.selfDeviceId, super.key});

  @override
  State<HomeHubChatPage> createState() => _HomeHubChatPageState();
}

class _HomeHubChatPageState extends State<HomeHubChatPage> {
  final _textController = TextEditingController();
  StreamSubscription<HttpServerHomeHubChatMessageEvent>? _subscription;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final ref = context.ref;
    final server = ref.notifier(serverProvider);
    _subscription = server.homeHubChatEvents.listen((event) {
      if (event.groupId != widget.group.id) return;
      unawaited(ref.redux(homeHubProvider).dispatchAsync(
            AddHomeHubChatMessageAction(
              HomeHubChatMessage(
                id: event.eventId,
                groupId: event.groupId,
                senderDeviceId: event.senderDeviceId,
                senderAlias: event.senderAlias,
                text: event.text,
                createdAt: DateTime.tryParse(event.createdAt)?.toLocal() ?? DateTime.now(),
                outgoing: false,
              ),
            ),
          ));
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel() ?? Future<void>.value());
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;
    final ref = context.ref;
    final self = ref.read(deviceFullInfoProvider);
    final message = HomeHubChatMessage(
      id: const Uuid().v4(),
      groupId: widget.group.id,
      senderDeviceId: self.fingerprint,
      senderAlias: self.alias,
      text: text,
      createdAt: DateTime.now(),
      outgoing: true,
    );
    final nearby = ref.read(nearbyDevicesProvider);
    final deliveries = <HomeHubOutboxItem>[];
    for (final member in widget.group.members) {
      if (member.deviceId == widget.selfDeviceId || member.isExpired) continue;
      deliveries.add(
        HomeHubOutboxItem(
          message: message,
          recipientDeviceId: member.deviceId,
          recipientAlias: member.alias,
          status: nearby.devices.values.any((device) => device.fingerprint == member.deviceId)
              ? HomeHubDeliveryStatus.pending
              : HomeHubDeliveryStatus.offline,
          attempts: 0,
          updatedAt: DateTime.now(),
        ),
      );
    }
    await ref.redux(homeHubProvider).dispatchAsync(
          EnqueueHomeHubChatMessageAction(message: message, deliveries: deliveries),
        );
    if (!mounted) return;
    _textController.clear();
    setState(() => _sending = true);
    for (final delivery in deliveries) {
      final device = nearby.devices.values.cast<Device?>().firstWhere(
            (candidate) => candidate?.fingerprint == delivery.recipientDeviceId,
            orElse: () => null,
          );
      if (device == null) continue;
      try {
        await HomeHubClient(clients: ref.read(httpProvider), device: device).sendChat(
          eventId: message.id,
          groupId: message.groupId,
          senderDeviceId: message.senderDeviceId,
          senderAlias: message.senderAlias,
          text: message.text,
          createdAt: message.createdAt.toUtc().toIso8601String(),
        );
        await ref.redux(homeHubProvider).dispatchAsync(
              UpdateHomeHubOutboxItemAction(
                messageId: message.id,
                recipientDeviceId: delivery.recipientDeviceId,
                status: HomeHubDeliveryStatus.completed,
              ),
            );
      } catch (_) {
        await ref.redux(homeHubProvider).dispatchAsync(
              UpdateHomeHubOutboxItemAction(
                messageId: message.id,
                recipientDeviceId: delivery.recipientDeviceId,
                status: HomeHubDeliveryStatus.failed,
              ),
            );
      }
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch(homeHubProvider);
    final messages = state.messages.where((message) => message.groupId == widget.group.id).toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: Text('شات ${widget.group.name}')),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('ابدأ أول رسالة داخل الشبكة المحلية'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Align(
                        alignment: message.outgoing ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(message.outgoing ? 'أنت' : message.senderAlias, style: Theme.of(context).textTheme.labelSmall),
                                const SizedBox(height: 4),
                                Text(message.text),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(hintText: 'اكتب رسالة محلية…', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHubGroupPage extends StatelessWidget {
  final HomeHubGroup group;
  final String selfDeviceId;

  const HomeHubGroupPage({required this.group, required this.selfDeviceId, super.key});

  Future<void> _inviteDevice(BuildContext context) async {
    final nearby = context.ref.read(nearbyDevicesProvider);
    final candidates = nearby.devices.values
        .where((device) => device.fingerprint != selfDeviceId && device.ip?.trim().isNotEmpty == true)
        .toList(growable: false);
    if (candidates.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد أجهزة HTTP قريبة متاحة للدعوة')));
      }
      return;
    }
    final device = await showDialog<Device>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('اختيار جهاز للدعوة'),
        children: [
          for (final candidate in candidates)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(candidate),
              child: Text(candidate.alias),
            ),
        ],
      ),
    );
    if (device == null || !context.mounted) return;

    final self = context.ref.read(deviceFullInfoProvider);
    final invite = HomeHubInvite.create(
      groupId: group.id,
      groupName: group.name,
      inviterDeviceId: self.fingerprint,
      inviterAlias: self.alias,
      role: HomeHubRole.viewer,
    );
    try {
      final result = await HomeHubClient(
        clients: context.ref.read(httpProvider),
        device: device,
      ).sendInvite(
        inviteId: invite.id,
        groupId: invite.groupId,
        groupName: invite.groupName,
        senderDeviceId: invite.inviterDeviceId,
        senderAlias: invite.inviterAlias,
        role: invite.role.name,
        createdAt: invite.createdAt.toUtc().toIso8601String(),
        expiresAt: invite.expiresAt?.toUtc().toIso8601String(),
      );
      if (!context.mounted) return;
      if (!result.accepted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الجهاز رفض الدعوة')));
        return;
      }
      final current = context.ref.read(homeHubProvider).groups.firstWhere((item) => item.id == group.id, orElse: () => group);
      final members = [...current.members]
        ..removeWhere((member) => member.deviceId == device.fingerprint)
        ..add(HomeHubMember(deviceId: device.fingerprint, alias: device.alias, role: invite.role, joinedAt: DateTime.now()));
      await context.ref.redux(homeHubProvider).dispatchAsync(UpsertHomeHubGroupAction(current.copyWith(members: members)));
      if (context.mounted) context.ref.notifier(serverProvider).syncHomeHubGroups();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت إضافة ${device.alias} للجروب')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشلت الدعوة: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.ref.redux(homeHubProvider);
    final selectedFiles = context.ref.watch(selectedSendingFilesProvider);
    final isOwner = group.ownerDeviceId == selfDeviceId;
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          if (isOwner)
            IconButton(
              tooltip: 'دعوة جهاز قريب',
              onPressed: () => _inviteDevice(context),
              icon: const Icon(Icons.person_add_alt_1),
            ),
          if (selectedFiles.isNotEmpty)
            IconButton(
              tooltip: 'إرسال الملفات للجروب',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HomeHubBroadcastPage(
                    group: group,
                    selfDeviceId: selfDeviceId,
                    files: selectedFiles,
                  ),
                ),
              ),
              icon: const Icon(Icons.send_to_mobile),
            ),
          IconButton(
            tooltip: 'الشات المحلي',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HomeHubChatPage(group: group, selfDeviceId: selfDeviceId)),
            ),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          if (isOwner)
            IconButton(
              tooltip: 'حذف الجروب',
              onPressed: () async {
                await service.dispatchAsync(DeleteHomeHubGroupAction(group.id));
                if (context.mounted) context.ref.notifier(serverProvider).syncHomeHubGroups();
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('الموافقة مطلوبة لكل جهاز'),
              subtitle: const Text('العضوية لا تمنح تلقائيًا صلاحية استقبال ملف أو قراءة بث.'),
            ),
          ),
          const SizedBox(height: 12),
          Text('الأعضاء', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final member in group.members)
            Card(
              child: ListTile(
                leading: Icon(member.deviceId == selfDeviceId ? Icons.person : Icons.devices),
                title: Text(member.alias),
                subtitle: Text('${member.role.name}${member.isExpired ? ' · انتهت الصلاحية' : ''}'),
                trailing: isOwner && member.deviceId != selfDeviceId
                    ? IconButton(
                        tooltip: 'إزالة العضو',
                        onPressed: () => service.dispatchAsync(
                          RemoveHomeHubMemberAction(groupId: group.id, deviceId: member.deviceId),
                        ),
                        icon: const Icon(Icons.person_remove_outlined),
                      )
                    : null,
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'إضافة الأجهزة والدردشة والإرسال الجماعي ستستخدم نفس قائمة الأجهزة القريبة، وستظل كل الدعوات والطلبات مباشرة داخل LAN.',
          ),
        ],
      ),
    );
  }
}


class HomeHubBroadcastPage extends StatefulWidget {
  final HomeHubGroup group;
  final String selfDeviceId;
  final List<CrossFile> files;

  const HomeHubBroadcastPage({
    required this.group,
    required this.selfDeviceId,
    required this.files,
    super.key,
  });

  @override
  State<HomeHubBroadcastPage> createState() => _HomeHubBroadcastPageState();
}

class _HomeHubBroadcastPageState extends State<HomeHubBroadcastPage> {
  final _offerId = const Uuid().v4();
  final Map<String, HomeHubDeliveryStatus> _statuses = {};
  bool _sending = false;

  Future<void> _sendOffer() async {
    if (_sending) return;
    final ref = context.ref;
    final self = ref.read(deviceFullInfoProvider);
    final nearby = ref.read(nearbyDevicesProvider);
    final files = [
      for (var index = 0; index < widget.files.length; index++)
        {
          'fileId': '$_offerId-$index',
          'name': widget.files[index].name,
          'size': widget.files[index].size,
        },
    ];
    final recipients = <({HomeHubMember member, Device? device})>[];
    for (final member in widget.group.members) {
      if (member.deviceId == widget.selfDeviceId || member.isExpired) continue;
      final device = nearby.devices.values.cast<Device?>().firstWhere(
            (candidate) => candidate?.fingerprint == member.deviceId,
            orElse: () => null,
          );
      recipients.add((member: member, device: device));
    }
    if (recipients.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد عضو قريب متاح الآن')));
      return;
    }
    setState(() {
      _sending = true;
      for (final recipient in recipients) {
        _statuses[recipient.member.deviceId] = recipient.device == null ? HomeHubDeliveryStatus.offline : HomeHubDeliveryStatus.pending;
      }
    });
    for (final recipient in recipients) {
      final device = recipient.device;
      if (device == null) continue;
      try {
        final result = await HomeHubClient(clients: ref.read(httpProvider), device: device).sendTransferOffer(
          offerId: _offerId,
          groupId: widget.group.id,
          senderDeviceId: self.fingerprint,
          senderAlias: self.alias,
          files: files,
        );
        if (!mounted) return;
        setState(() {
          _statuses[recipient.member.deviceId] = result.accepted ? HomeHubDeliveryStatus.accepted : HomeHubDeliveryStatus.rejected;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _statuses[recipient.member.deviceId] = HomeHubDeliveryStatus.failed);
      }
    }
    if (mounted) setState(() => _sending = false);
  }

  String _statusText(HomeHubDeliveryStatus? status) {
    switch (status) {
      case HomeHubDeliveryStatus.pending:
        return 'في انتظار موافقة الجهاز';
      case HomeHubDeliveryStatus.accepted:
        return 'وافق على العرض';
      case HomeHubDeliveryStatus.rejected:
        return 'رفض العرض';
      case HomeHubDeliveryStatus.offline:
        return 'غير متصل؛ سيحتاج إعادة المحاولة';
      case HomeHubDeliveryStatus.failed:
        return 'فشل الاتصال';
      default:
        return 'لم يُرسل بعد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إرسال إلى ${widget.group.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('${widget.files.length} ملف'),
              subtitle: const Text('سيظهر طلب موافقة مستقل لكل عضو. لا يستطيع أي مدير إجبار جهاز على الاستلام.'),
            ),
          ),
          const SizedBox(height: 12),
          for (final file in widget.files)
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(file.name),
              subtitle: Text('${file.size} bytes'),
            ),
          const Divider(),
          for (final member in widget.group.members.where((member) => member.deviceId != widget.selfDeviceId))
            ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: Text(member.alias),
              subtitle: Text(_statusText(_statuses[member.deviceId])),
              trailing: _statuses[member.deviceId] == HomeHubDeliveryStatus.accepted
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sending ? null : _sendOffer,
            icon: _sending ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
            label: Text(_sending ? 'في انتظار قرارات الأجهزة…' : 'إرسال عرض مستقل لكل جهاز'),
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه الخطوة ترسل metadata والعرض عبر LAN/mTLS فقط. بعد قبول العرض، سيُعاد استخدام مسار نقل LocalSend الأصلي لجسم الملفات في المرحلة التالية؛ لا يتم رفع الملفات إلى Internet.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
