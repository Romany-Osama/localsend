import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/provider/network/stream/stream_browse_client.dart';
import 'package:localsend_app/provider/network/server/server_provider.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:localsend_isolates/rust/api/server.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;
import 'package:refena_flutter/refena_flutter.dart';
import 'package:uuid/uuid.dart';

class StreamTab extends StatelessWidget {
  const StreamTab({super.key});

  @override
  Widget build(BuildContext context) {
    final nearby = context.watch(nearbyDevicesProvider);
    final devices = nearby.devices.values.where((device) => device.ip?.isNotEmpty ?? false).toList();
    final server = context.ref.notifier(serverProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stream & Browse')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('شارك مجلدًا من هذا الجهاز', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('سيظل الملف على جهازك. الجهاز الآخر يستطيع تصفحه، لكن كل ملف يحتاج موافقة منفصلة قبل قراءته.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final path = await FilePicker.platform.getDirectoryPath(dialogTitle: 'اختيار مجلد للمشاركة');
                      if (path == null || !context.mounted) return;
                      await server.setStreamRoots([
                        ...server.streamRoots,
                        StreamRootParams(id: Uuid().v4(), name: p.basename(path), path: path),
                      ]);
                    },
                    icon: const Icon(Icons.folder_shared),
                    label: const Text('اختيار مجلد'),
                  ),
                  if (server.streamRoots.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    for (final root in server.streamRoots)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.folder),
                        title: Text(root.name),
                        subtitle: Text(root.path),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          StreamApprovalPanel(server: server),
          const SizedBox(height: 18),
          Text('الأجهزة القريبة', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (devices.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('لم يتم العثور على أجهزة HTTP قريبة. افتح LocalSend على الجهاز الآخر وابدأ البحث من تبويب الإرسال.'),
              ),
            )
          else
            for (final device in devices)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.devices),
                  title: Text(device.alias),
                  subtitle: Text('${device.ip}:${device.port}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => StreamBrowserPage(device: device)),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class StreamApprovalPanel extends StatelessWidget {
  final ServerService server;

  const StreamApprovalPanel({required this.server, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object?>(
      stream: server.streamEvents,
      builder: (context, _) {
        final sessions = server.pendingStreamSessions.values.toList();
        final files = server.pendingStreamFiles.values.toList();
        if (sessions.isEmpty && files.isEmpty) return const SizedBox.shrink();
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('طلبات الوصول', style: Theme.of(context).textTheme.titleMedium),
                for (final request in sessions)
                  ListTile(
                    leading: const Icon(Icons.lock_open),
                    title: Text('جهاز يريد فتح جلسة تصفح'),
                    subtitle: Text(request.ip),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(onPressed: () => server.declineStreamSession(request.sessionId), icon: const Icon(Icons.close)),
                        IconButton(onPressed: () => server.acceptStreamSession(request.sessionId), icon: const Icon(Icons.check)),
                      ],
                    ),
                  ),
                for (final request in files)
                  ListTile(
                    leading: const Icon(Icons.video_file),
                    title: Text(request.entry.name),
                    subtitle: Text('طلب قراءة من ${request.ip}'),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(onPressed: () => server.declineStreamFile(request.requestId), icon: const Icon(Icons.close)),
                        IconButton(onPressed: () => server.acceptStreamFile(request.requestId), icon: const Icon(Icons.check)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StreamBrowserPage extends StatefulWidget {
  final Device device;

  const StreamBrowserPage({required this.device, super.key});

  @override
  State<StreamBrowserPage> createState() => _StreamBrowserPageState();
}

class _StreamBrowserPageState extends State<StreamBrowserPage> {
  late final StreamBrowseClient _client;
  List<StreamRemoteRoot> _roots = const [];
  List<StreamRemoteEntry> _entries = const [];
  StreamRemoteRoot? _root;
  String _path = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _client = StreamBrowseClient(widget.device);
    unawaited(_open());
  }

  Future<void> _open() async {
    try {
      await _client.openSession();
      final roots = await _client.roots();
      if (!mounted) return;
      setState(() {
        _roots = roots;
        _root = roots.isEmpty ? null : roots.first;
      });
      if (roots.isNotEmpty) await _loadEntries(roots.first, '');
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadEntries(StreamRemoteRoot root, String path) async {
    setState(() {
      _loading = true;
      _error = null;
      _root = root;
      _path = path;
    });
    try {
      final entries = await _client.entries(rootId: root.id, path: path);
      if (mounted) setState(() => _entries = entries);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEntry(StreamRemoteEntry entry) async {
    if (entry.isDirectory) {
      await _loadEntries(_root!, entry.path);
      return;
    }
    if (!entry.streamable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هذا الملف غير قابل للتشغيل داخل المشغل')));
      }
      return;
    }
    setState(() => _loading = true);
    try {
      final grant = await _client.requestFile(rootId: entry.rootId, path: entry.path, purpose: 'play');
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => StreamPlayerPage(grant: grant)));
    } catch (error) {
      if (mounted) setState(() => _error = 'لم تتم الموافقة أو فشل الطلب: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    unawaited(_client.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.alias),
        actions: [
          if (_roots.length > 1)
            PopupMenuButton<StreamRemoteRoot>(
              initialValue: _root,
              onSelected: (root) => _loadEntries(root, ''),
              itemBuilder: (_) => [
                for (final root in _roots) PopupMenuItem(value: root, child: Text(root.name)),
              ],
            ),
        ],
      ),
      body: _loading && _entries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_path.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.arrow_upward),
                    title: Text(_path),
                    onTap: () {
                      final parent = p.dirname(_path);
                      _loadEntries(_root!, parent == '.' ? '' : parent);
                    },
                  ),
                if (_error != null)
                  Padding(padding: const EdgeInsets.all(16), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                Expanded(
                  child: ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (_, index) {
                      final entry = _entries[index];
                      return ListTile(
                        leading: Icon(entry.isDirectory ? Icons.folder : Icons.insert_drive_file),
                        title: Text(entry.name),
                        subtitle: Text(entry.isDirectory ? 'مجلد' : '${entry.size} bytes'),
                        trailing: entry.isDirectory || entry.streamable ? const Icon(Icons.chevron_right) : null,
                        onTap: () => _openEntry(entry),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class StreamPlayerPage extends StatefulWidget {
  final StreamGrant grant;

  const StreamPlayerPage({required this.grant, super.key});

  @override
  State<StreamPlayerPage> createState() => _StreamPlayerPageState();
}

class _StreamPlayerPageState extends State<StreamPlayerPage> {
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    unawaited(_player.open(Media(widget.grant.uri.toString())));
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.grant.file.name)),
      body: Center(
        child: Video(
          controller: _controller,
          controls: AdaptiveVideoControls,
        ),
      ),
    );
  }
}
