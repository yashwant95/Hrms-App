import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../config/theme.dart';
import '../../core/constants.dart';
import '../../core/utils/api_client.dart';
import '../auth/providers/auth_provider.dart';

final chatApiProvider = Provider((ref) => ApiClient());

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _active;
  io.Socket? _socket;
  bool _loading = true;
  bool _sending = false;
  String? _error;
  String _displayName(Map<String, dynamic> conversation) =>
      (conversation['name'] as String?) ??
      (conversation['displayName'] as String?) ??
      (conversation['kind'] == 'CHANNEL' ? 'Team channel' : 'Direct message');

  @override
  void initState() {
    super.initState();
    _load();
    _connect();
  }

  @override
  void dispose() {
    _socket?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final token = await _storage.read(key: 'token');
    if (!mounted || token == null) return;
    final base = AppConstants.apiBaseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    final socket = io.io(
      base,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );
    socket.on('chat:message', (dynamic data) {
      if (!mounted ||
          data is! Map ||
          data['conversationId']?.toString() != _active?['_id']?.toString())
        return;
      final message = Map<String, dynamic>.from(data);
      setState(() {
        final index = _messages.indexWhere(
          (item) => item['id']?.toString() == message['id']?.toString(),
        );
        if (index >= 0)
          _messages[index] = {..._messages[index], ...message};
        else
          _messages.add(message);
      });
    });
    socket.connect();
    _socket = socket;
  }

  Future<void> _load() async {
    try {
      final response = await ref
          .read(chatApiProvider)
          .client
          .get('/chat/conversations');
      final rows = (response.data as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      if (!mounted) return;
      setState(() {
        _conversations = rows;
        _loading = false;
        _error = null;
      });
      if (rows.isNotEmpty && _active == null) await _select(rows.first);
    } catch (error) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = error.toString();
        });
    }
  }

  Future<void> _select(Map<String, dynamic> conversation) async {
    setState(() {
      _active = conversation;
      _messages = [];
    });
    _socket?.emit('conversation:join', conversation['_id'].toString());
    try {
      final response = await ref
          .read(chatApiProvider)
          .client
          .get('/chat/conversations/${conversation['_id']}/messages');
      final data = Map<String, dynamic>.from(response.data as Map);
      if (mounted)
        setState(
          () => _messages = (data['messages'] as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(),
        );
      await ref
          .read(chatApiProvider)
          .client
          .post('/chat/conversations/${conversation['_id']}/read');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _send({List<String> attachmentKeys = const []}) async {
    final body = _controller.text.trim();
    final conversation = _active;
    if ((body.isEmpty && attachmentKeys.isEmpty) ||
        conversation == null ||
        _sending)
      return;
    setState(() => _sending = true);
    try {
      final response = await ref
          .read(chatApiProvider)
          .client
          .post(
            '/chat/conversations/${conversation['_id']}/messages',
            data: {'body': body, 'attachmentKeys': attachmentKeys},
          );
      final message = Map<String, dynamic>.from(response.data as Map);
      if (mounted) {
        setState(() {
          if (!_messages.any(
            (item) => item['id']?.toString() == message['id']?.toString(),
          ))
            _messages.add(message);
        });
        _controller.clear();
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleReaction(Map<String, dynamic> message) async {
    final emoji = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: ['👍', '❤️', '😂', '🎉', '🙏'].map((value) => IconButton(
            tooltip: value,
            icon: Text(value, style: const TextStyle(fontSize: 27)),
            onPressed: () => Navigator.pop(context, value),
          )).toList(),
        ),
      ),
    );
    if (emoji == null) return;
    try {
      final response = await ref.read(chatApiProvider).client.put(
        '/chat/messages/${message['id']}/reactions',
        data: {'emoji': emoji},
      );
      if (!mounted) return;
      setState(() {
        final index = _messages.indexWhere((item) => item['id'] == message['id']);
        if (index >= 0) _messages[index] = {..._messages[index], 'reactions': response.data['reactions']};
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _openThread(Map<String, dynamic> parent) async {
    final controller = TextEditingController();
    var replies = <Map<String, dynamic>>[];
    var loading = true;
    var sending = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, refresh) {
          Future<void> loadReplies() async {
            try {
              final response = await ref.read(chatApiProvider).client.get(
                '/chat/conversations/${parent['conversationId']}/messages',
                queryParameters: {'threadParentId': parent['id']},
              );
              replies = (response.data['messages'] as List)
                  .map((item) => Map<String, dynamic>.from(item as Map)).toList();
            } catch (_) {
              // The sheet remains usable for composing a reply if loading fails.
            } finally {
              loading = false;
              refresh(() {});
            }
          }

          Future<void> sendReply() async {
            final body = controller.text.trim();
            if (body.isEmpty || sending) return;
            sending = true;
            refresh(() {});
            try {
              final response = await ref.read(chatApiProvider).client.post(
                '/chat/conversations/${parent['conversationId']}/messages',
                data: {'body': body, 'threadParentId': parent['id']},
              );
              replies.add(Map<String, dynamic>.from(response.data as Map));
              controller.clear();
            } catch (error) {
              if (mounted) setState(() => _error = error.toString());
            } finally {
              sending = false;
              refresh(() {});
            }
          }

          if (loading) Future.microtask(loadReplies);
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.viewInsetsOf(context).bottom + 12),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .68,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Replies', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text((parent['body'] ?? 'Attachment').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
                    const Divider(height: 20),
                    Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : replies.isEmpty
                      ? const Center(child: Text('No replies yet. Start the thread.'))
                      : ListView.builder(itemCount: replies.length, itemBuilder: (context, index) {
                          final reply = replies[index];
                          final sender = reply['sender'] is Map ? Map<String, dynamic>.from(reply['sender'] as Map) : <String, dynamic>{};
                          return ListTile(dense: true, leading: const CircleAvatar(child: Icon(Icons.person_outline)), title: Text((sender['displayName'] ?? sender['email'] ?? 'Coworker').toString()), subtitle: Text((reply['body'] ?? '').toString()));
                        })),
                    Row(children: [
                      Expanded(child: TextField(controller: controller, minLines: 1, maxLines: 3, textInputAction: TextInputAction.send, onSubmitted: (_) => sendReply(), decoration: const InputDecoration(hintText: 'Reply in thread', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      IconButton.filled(onPressed: sending ? null : sendReply, icon: sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send)),
                    ]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    controller.dispose();
  }

  Future<void> _attachFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf', 'doc', 'docx'],
    );
    final file = picked?.files.single;
    if (file?.path == null) return;
    setState(() => _sending = true);
    try {
      final response = await ref
          .read(chatApiProvider)
          .client
          .post(
            '/chat/files',
            data: FormData.fromMap({
              'file': await MultipartFile.fromFile(
                file!.path!,
                filename: file.name,
              ),
            }),
          );
      final data = Map<String, dynamic>.from(response.data as Map);
      if (mounted) setState(() => _sending = false);
      await _send(attachmentKeys: [data['fileKey'].toString()]);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _downloadAttachment(Map<String, dynamic> file) async {
    try {
      final response = await ref.read(chatApiProvider).client.get<List<int>>(
        '/chat/files/${Uri.encodeComponent(file['fileKey'].toString())}',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) throw Exception('File is empty or unavailable');
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save attachment',
        fileName: (file['fileName'] ?? 'office-attachment').toString(),
        bytes: Uint8List.fromList(bytes),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(savedPath == null ? 'Save cancelled' : 'Attachment saved'),
      ));
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _startDirectMessage() async {
    try {
      final response = await ref
          .read(chatApiProvider)
          .client
          .get('/chat/people');
      final people = (response.data as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      if (!mounted) return;
      final person = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .72,
            child: Column(
              children: [
                const ListTile(
                  title: Text(
                    'Start a direct message',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Choose a coworker in your organization'),
                ),
                const Divider(height: 1),
                Expanded(
                  child: people.isEmpty
                      ? const Center(
                          child: Text('No other active coworkers found'),
                        )
                      : ListView.builder(
                          itemCount: people.length,
                          itemBuilder: (context, index) {
                            final person = people[index];
                            final title =
                                (person['displayName'] ??
                                        person['email'] ??
                                        'Coworker')
                                    .toString();
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  title.characters.first.toUpperCase(),
                                ),
                              ),
                              title: Text(title),
                              subtitle: Text('${person['role'] ?? 'Employee'}'),
                              onTap: () => Navigator.pop(context, person),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
      if (person == null) return;
      final conversationResponse = await ref
          .read(chatApiProvider)
          .client
          .post(
            '/chat/conversations/direct',
            data: {
              'memberIds': [person['id']],
            },
          );
      final conversation = Map<String, dynamic>.from(
        conversationResponse.data as Map,
      );
      await _load();
      await _select(
        _conversations.firstWhere(
          (item) => item['_id'].toString() == conversation['_id'].toString(),
          orElse: () => conversation,
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _browseChannels() async {
    try {
      final response = await ref
          .read(chatApiProvider)
          .client
          .get('/chat/channels/public');
      final channels = (response.data as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      if (!mounted) return;
      final channel = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (context) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .65,
            child: Column(
              children: [
                const ListTile(
                  title: Text(
                    'Browse channels',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Join a channel for your team or office'),
                ),
                const Divider(height: 1),
                Expanded(
                  child: channels.isEmpty
                      ? const Center(child: Text('No public channels yet'))
                      : ListView.builder(
                          itemCount: channels.length,
                          itemBuilder: (context, index) {
                            final item = channels[index];
                            return ListTile(
                              leading: const Icon(Icons.tag),
                              title: Text(
                                (item['name'] ?? 'Channel').toString(),
                              ),
                              subtitle: Text(
                                '${item['memberCount'] ?? 0} members',
                              ),
                              trailing: item['joined'] == true
                                  ? const Icon(Icons.check_circle_outline)
                                  : const Text('Join'),
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
      if (channel == null) return;
      if (channel['joined'] != true)
        await ref
            .read(chatApiProvider)
            .client
            .post('/chat/channels/${channel['_id']}/join');
      await _load();
      await _select(
        _conversations.firstWhere(
          (item) => item['_id'].toString() == channel['_id'].toString(),
          orElse: () => channel,
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _createChannel() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create a channel'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Channel name',
            prefixText: '#',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.length < 2) return;
    try {
      final response = await ref
          .read(chatApiProvider)
          .client
          .post('/chat/channels', data: {'name': name});
      final channel = Map<String, dynamic>.from(response.data as Map);
      await _load();
      await _select(
        _conversations.firstWhere(
          (item) => item['_id'].toString() == channel['_id'].toString(),
          orElse: () => channel,
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (!auth.modules.contains('chat'))
      return Scaffold(
        appBar: AppBar(title: const Text('Team chat')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Text(
              'Chat is not included in your organization plan. Ask your administrator to enable it.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    return Scaffold(
      appBar: AppBar(
        title: Text(_active == null ? 'Team chat' : _displayName(_active!)),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More chat actions',
            onSelected: (value) {
              if (value == 'direct') _startDirectMessage();
              if (value == 'browse') _browseChannels();
              if (value == 'channel') _createChannel();
            },
            itemBuilder: (context) => [
              if (auth.permissions.contains('CHAT_SEND'))
                const PopupMenuItem(
                  value: 'direct',
                  child: Text('नई निजी बातचीत'),
                ),
              const PopupMenuItem(value: 'browse', child: Text('चैनल देखें')),
              if (auth.permissions.contains('CHAT_CHANNEL_CREATE'))
                const PopupMenuItem(
                  value: 'channel',
                  child: Text('चैनल बनाएँ'),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Refresh conversations',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
          ? _EmptyChat(onRefresh: _load)
          : Column(
              children: [
                if (_error != null)
                  MaterialBanner(
                    content: Text(
                      _error!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => setState(() => _error = null),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 94,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: _conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = _conversations[index];
                      final selected = item['_id'] == _active?['_id'];
                      return SizedBox(
                        width: 112,
                        child: OutlinedButton(
                          onPressed: () => _select(item),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selected
                                ? AppTheme.primary.withValues(alpha: .08)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item['kind'] == 'CHANNEL'
                                    ? Icons.tag
                                    : Icons.person_outline,
                                size: 20,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _displayName(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Text(
                            _active?['kind'] == 'CHANNEL'
                                ? 'Say hello in this channel.'
                                : 'Start the conversation.',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final sender = Map<String, dynamic>.from(
                              message['sender'] is Map
                                  ? message['sender'] as Map
                                  : {},
                            );
                            final name =
                                (sender['displayName'] ??
                                        sender['email'] ??
                                        'Coworker')
                                    .toString();
                            final deleted = message['deleted'] == true;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppTheme.primary
                                        .withValues(alpha: .1),
                                    child: Text(
                                      name.characters.first.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                name,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _time(message['createdAt']),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          deleted
                                              ? 'Message deleted'
                                              : (message['body'] ?? '')
                                                    .toString(),
                                          style: const TextStyle(height: 1.4),
                                        ),
                                        if (!deleted &&
                                            (message['attachments'] as List? ??
                                                    const [])
                                                .isNotEmpty)
                                          ...((message['attachments'] as List)
                                              .map(
                                                (file) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 6,
                                                      ),
                                                  child: ActionChip(
                                                    avatar: const Icon(
                                                      Icons.attach_file,
                                                      size: 16,
                                                    ),
                                                    label: Text(
                                                      (file['fileName'] ??
                                                              'Attached file')
                                                          .toString(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    onPressed: () => _downloadAttachment(Map<String, dynamic>.from(file as Map)),
                                                  ),
                                                ),
                                              )),
                                      ],
                                    ),
                                  ),
                                        if (!deleted &&
                                            (message['reactions'] as List? ?? const []).isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Wrap(
                                              spacing: 6,
                                              children: (message['reactions'] as List).map((reaction) {
                                                final item = Map<String, dynamic>.from(reaction as Map);
                                                final members = item['userIds'] as List? ?? const [];
                                                return Chip(
                                                  visualDensity: VisualDensity.compact,
                                                  label: Text('${item['emoji']} ${members.length}'),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        if (!deleted)
                                          Wrap(
                                            spacing: 2,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () => _openThread(message),
                                                icon: const Icon(Icons.reply_rounded, size: 18),
                                                label: const Text('Reply'),
                                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                              ),
                                              TextButton.icon(
                                                onPressed: auth.permissions.contains('CHAT_SEND') ? () => _toggleReaction(message) : null,
                                                icon: const Icon(Icons.add_reaction_outlined, size: 18),
                                                label: const Text('React'),
                                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                              ),
                                            ],
                                          ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                if (auth.permissions.contains('CHAT_SEND'))
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Attach a file',
                            onPressed: _sending ? null : _attachFile,
                            icon: const Icon(Icons.attach_file_rounded),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                              decoration: InputDecoration(
                                hintText: 'Write a message',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 52,
                            width: 52,
                            child: FilledButton(
                              onPressed: _sending ? null : _send,
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _sending
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: const Text('You have read-only access to chat.'),
                  ),
              ],
            ),
    );
  }

  String _time(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    return date == null
        ? ''
        : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _EmptyChat extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyChat({required this.onRefresh});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.forum_outlined, size: 54, color: AppTheme.primary),
          const SizedBox(height: 16),
          const Text(
            'Your team conversations will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask a coworker to add you to a channel, or start a direct message from the web workspace.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    ),
  );
}
