import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_store.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class ChatArgs {
  const ChatArgs({
    this.id = 'design',
    this.title = 'Design UX',
    this.image = 'dennis',
  });
  final String id, title, image;
}

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({
    super.key,
    this.expanded = false,
    this.archived = false,
  });
  final bool expanded, archived;
  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  bool _searching = false;
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final conversations = [
      for (final channel in store.channels.skip(1))
        Person(
          'channel:$channel',
          store.titleFor('channel:$channel', channel),
          'dennis',
          'Channel created · Say hello',
          'now',
        ),
      for (final person in people)
        Person(
          person.id,
          store.titleFor(person.id, person.name),
          person.image,
          person.preview,
          person.time,
        ),
    ];
    final filtered = conversations
        .where(
          (p) =>
              p.name.toLowerCase().contains(_search.toLowerCase()) &&
              store.archived.contains(p.id) == widget.archived,
        )
        .toList();
    return Scaffold(
      bottomNavigationBar: const BottomTabs(1),
      body: Column(
        children: [
          if (!widget.archived)
            SizedBox(
              height: _searching ? 96 : (widget.expanded ? 307 : 208),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _searching
                        ? const ColoredBox(color: AmiaColors.ink)
                        : CustomPaint(
                            painter: _ChannelHeaderPainter(
                              widget.expanded
                                  ? AmiaColors.blue
                                  : AmiaColors.ink,
                            ),
                          ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: 'Notifications',
                                onPressed: () => go(context, '/notifications'),
                                icon: const Icon(
                                  CupertinoIcons.bell,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              if (!widget.expanded)
                                const Expanded(
                                  child: Text(
                                    'Channels',
                                    style: TextStyle(
                                      color: AmiaColors.blue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              else
                                const Spacer(),
                              IconButton(
                                tooltip: 'Search conversations',
                                onPressed: () =>
                                    setState(() => _searching = !_searching),
                                icon: const Icon(
                                  CupertinoIcons.search,
                                  color: Colors.white,
                                  size: 21,
                                ),
                              ),
                              IconButton(
                                tooltip: 'New channel',
                                onPressed: () => go(context, '/new-channel'),
                                icon: const Icon(
                                  CupertinoIcons.plus,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.expanded && !_searching)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(28, 10, 0, 16),
                              child: Text(
                                'Channels',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 9),
                        if (!_searching)
                          SizedBox(
                            height: widget.expanded ? 138 : 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                              ),
                              itemCount: 4,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, i) => GestureDetector(
                                onTap: () => go(
                                  context,
                                  i == 2 ? '/video-call' : '/chat',
                                  arguments: const ChatArgs(),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        asset(
                                          [
                                            'story_1',
                                            'story_2',
                                            'dennis',
                                            'story_4',
                                          ][i],
                                        ),
                                        width: 80,
                                        height: widget.expanded ? 138 : 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (i < 2)
                                      const Positioned(
                                        right: 10,
                                        top: 10,
                                        child: CircleAvatar(
                                          radius: 5.5,
                                          backgroundColor: Color(0xFF0ED69B),
                                        ),
                                      ),
                                    if (i == 2)
                                      Positioned(
                                        top: 8,
                                        right: 5,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AmiaColors.pink,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Text(
                                            'LIVE ○',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (widget.expanded)
                                      Positioned(
                                        bottom: 10,
                                        left: 7,
                                        right: 7,
                                        child: Text(
                                          [
                                            'Miglena\nTadic',
                                            'Johnny\nLane',
                                            'Greg\nWilliamson',
                                            'Tyrone\nHawkins',
                                          ][i],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            height: 1.3,
                                            shadows: [Shadow(blurRadius: 6)],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            SafeArea(
              bottom: false,
              child: AppBar(title: const Text('Archived chats')),
            ),
          if (_searching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search conversations',
                  prefixIcon: Icon(CupertinoIcons.search),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 16, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Recent contact', style: TextStyle(fontSize: 12)),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Channel options',
                  icon: const Icon(CupertinoIcons.ellipsis, size: 18),
                  onSelected: (v) => go(context, v),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: '/channels-expanded',
                      child: Text('Expanded view'),
                    ),
                    const PopupMenuItem(
                      value: '/archived',
                      child: Text('Archived chats'),
                    ),
                    const PopupMenuItem(
                      value: '/contacts',
                      child: Text('New contacts'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No conversations found',
                      style: TextStyle(color: AmiaColors.muted),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final person in filtered)
                        _ChannelRow(person: person),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChannelHeaderPainter extends CustomPainter {
  const _ChannelHeaderPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height - 125)
        ..lineTo(0, size.height - 55)
        ..close(),
      Paint()..color = color,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - 83)
        ..lineTo(65, size.height - 64)
        ..lineTo(0, size.height - 50)
        ..close(),
      Paint()..color = AmiaColors.pink,
    );
  }

  @override
  bool shouldRepaint(_ChannelHeaderPainter old) => color != old.color;
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({required this.person});
  final Person person;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final messages = store.conversations[person.id];
    final latest = messages?.lastOrNull;
    final preview =
        latest != null && !['intro', 'reply', 'payment'].contains(latest.id)
        ? (latest.kind == 'image' ? 'Photo' : latest.text)
        : person.preview;
    return InkWell(
      onTap: () {
        store.markRead(person.id);
        go(
          context,
          '/chat',
          arguments: ChatArgs(
            id: person.id,
            title: person.name,
            image: person.image,
          ),
        );
      },
      onLongPress: () => showConversationOptions(context, person),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 22, 0),
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              Avatar(person.image),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            person.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: store.unread.contains(person.id)
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 24,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: 'Options for ${person.name}',
                            onPressed: () =>
                                showConversationOptions(context, person),
                            icon: const Icon(CupertinoIcons.ellipsis, size: 17),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AmiaColors.muted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          store.unread.contains(person.id) ? '●' : person.time,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AmiaColors.blue,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Divider(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showConversationOptions(
  BuildContext context,
  Person person,
) async {
  final store = AppScope.of(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Avatar(person.image, size: 36),
            title: Text(
              person.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          for (final entry in [
            ('Mark as Unread', CupertinoIcons.chat_bubble),
            (
              store.archived.contains(person.id) ? 'Unarchive' : 'Archive',
              CupertinoIcons.archivebox,
            ),
            (
              store.muted.contains(person.id) ? 'Unmute' : 'Mute',
              CupertinoIcons.bell_slash,
            ),
          ])
            ListTile(
              leading: Icon(entry.$2),
              title: Text(entry.$1),
              onTap: () {
                if (entry.$1 == 'Mark as Unread') {
                  store.unread.add(person.id);
                } else if (entry.$1.contains('rchive')) {
                  if (!store.archived.remove(person.id)) {
                    store.archived.add(person.id);
                  }
                } else {
                  if (!store.muted.remove(person.id)) {
                    store.muted.add(person.id);
                  }
                }
                store.changed();
                Navigator.pop(sheet);
                toast(context, '${entry.$1} · ${person.name}');
              },
            ),
        ],
      ),
    ),
  );
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.args = const ChatArgs()});
  final ChatArgs args;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    AppScope.of(context).send(widget.args.id, _input.text);
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final messages = store.messages(widget.args.id);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => go(context, '/chat-settings', arguments: widget.args),
          child: Text(store.titleFor(widget.args.id, widget.args.title)),
        ),
        actions: [
          IconButton(
            tooltip: 'Voice call',
            onPressed: () => go(context, '/voice-call'),
            icon: const Icon(CupertinoIcons.phone, size: 20),
          ),
          IconButton(
            tooltip: 'Video call',
            onPressed: () => go(context, '/video-call'),
            icon: const Icon(CupertinoIcons.videocam, size: 22),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                controller: _scroll,
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'TODAY',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: AmiaColors.muted,
                        ),
                      ),
                    ),
                  ),
                  for (final message in messages)
                    GestureDetector(
                      onLongPress: () =>
                          showMessageOptions(context, message, widget.args.id),
                      child: _MessageBubble(message: message),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Attachments',
                    onPressed: () => _attachments(context),
                    icon: const Icon(CupertinoIcons.ellipsis, size: 22),
                  ),
                  IconButton(
                    tooltip: 'Photo',
                    onPressed: () =>
                        go(context, '/camera', arguments: widget.args),
                    icon: const Icon(CupertinoIcons.photo, size: 21),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: .035),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: AmiaColors.pink,
                            width: .6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send message',
                    onPressed: _send,
                    icon: const Icon(CupertinoIcons.paperplane, size: 23),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _attachments(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(CupertinoIcons.camera),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(sheet);
              go(context, '/camera', arguments: widget.args);
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.photo),
            title: const Text('Photo library'),
            onTap: () {
              Navigator.pop(sheet);
              go(context, '/photo-preview', arguments: widget.args);
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.star),
            title: const Text('Starred messages'),
            onTap: () {
              Navigator.pop(sheet);
              go(context, '/starred');
            },
          ),
        ],
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final color = message.mine
        ? AmiaColors.blue
        : AmiaColors.accents[store.colorIndex];
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: message.mine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 275),
            child: Container(
              padding: EdgeInsets.all(message.kind == 'image' ? 4 : 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(message.mine ? 12 : 3),
                  bottomRight: Radius.circular(message.mine ? 3 : 12),
                ),
              ),
              child: switch (message.kind) {
                'payment' => SizedBox(
                  width: 140,
                  child: Column(
                    children: [
                      Text(
                        '\$${message.text}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Completed',
                              style: TextStyle(
                                color: AmiaColors.ink,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '10:20 min · Sample',
                              style: TextStyle(
                                color: AmiaColors.muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                'image' => ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    asset(message.text),
                    height: 210,
                    width: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                _ => Text(
                  message.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: store.textSize,
                    height: 1.55,
                  ),
                ),
              },
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!message.mine) ...[
                const Avatar('yi', size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                message.id == 'intro' ? '3:34 AM' : '10:20 AM',
                style: const TextStyle(fontSize: 9, color: AmiaColors.muted),
              ),
              const SizedBox(width: 6),
              Icon(
                message.starred
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.checkmark_circle,
                size: 11,
                color: AmiaColors.pink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showMessageOptions(
  BuildContext context,
  ChatMessage message,
  String chatId,
) async {
  final store = AppScope.of(context);
  final action = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final label in [
            'Forward',
            'Copy',
            if (message.mine && message.kind == 'text') 'Edit',
            message.starred ? 'Unstar' : 'Star message',
            'Remove message',
          ])
            ListTile(
              title: Text(
                label,
                style: TextStyle(
                  color: label == 'Remove message' ? AmiaColors.pink : null,
                ),
              ),
              onTap: () => Navigator.pop(sheet, label),
            ),
        ],
      ),
    ),
  );
  if (!context.mounted || action == null) return;
  switch (action) {
    case 'Copy':
      await Clipboard.setData(ClipboardData(text: message.text));
      if (context.mounted) toast(context, 'Message copied');
    case 'Star message':
    case 'Unstar':
      message.starred = !message.starred;
      store.changed();
    case 'Remove message':
      store.messages(chatId).remove(message);
      store.changed();
    case 'Edit':
      final text = await editTextDialog(context, 'Edit message', message.text);
      if (text != null && text.trim().isNotEmpty) {
        message.text = text.trim();
        store.changed();
      }
    case 'Forward':
      final target = await showModalBottomSheet<Person>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Forward to',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              for (final person in people)
                ListTile(
                  leading: Avatar(person.image, size: 36),
                  title: Text(person.name),
                  onTap: () => Navigator.pop(sheet, person),
                ),
            ],
          ),
        ),
      );
      if (target != null) {
        store.send(target.id, message.text, kind: message.kind);
        if (context.mounted) toast(context, 'Forwarded to ${target.name}');
      }
  }
}

Future<String?> editTextDialog(
  BuildContext context,
  String title,
  String initial,
) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true, maxLines: 4),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialog, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  // The dialog finishes its exit animation before releasing the controller.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  controller.dispose();
  return result;
}

class NewChannelScreen extends StatefulWidget {
  const NewChannelScreen({super.key});
  @override
  State<NewChannelScreen> createState() => _NewChannelScreenState();
}

class _NewChannelScreenState extends State<NewChannelScreen> {
  final _name = TextEditingController();
  final Set<int> _selected = {0, 1, 3};
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _create() {
    if (_name.text.trim().isEmpty || _selected.isEmpty) {
      toast(context, 'Name the channel and choose at least one member');
      return;
    }
    final store = AppScope.of(context);
    final name = _name.text.trim();
    if (store.channels.contains(name)) {
      toast(context, 'A channel with this name already exists');
      return;
    }
    store.channels.add(name);
    store.conversations['channel:$name'] = [];
    store.changed();
    Navigator.of(context).pushReplacementNamed(
      '/chat',
      arguments: ChatArgs(id: 'channel:$name', title: name),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('New channel'),
      actions: [
        IconButton(
          tooltip: 'Create channel',
          onPressed: _create,
          icon: const Icon(CupertinoIcons.checkmark),
        ),
        const SizedBox(width: 16),
      ],
    ),
    body: ScrollableColumn(
      padding: const EdgeInsets.all(28),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Name your new channel',
            hintText: 'ex: Deeper team',
          ),
        ),
        const SizedBox(height: 40),
        const Text('Choose Members', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 20),
        for (var i = 0; i < 5; i++)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AmiaColors.pink,
            secondary: Avatar(people[i].image, size: 30),
            title: Text(
              [
                'Jason Bailey',
                'Merrile Burgett',
                'Mok Kwang-Hyun',
                'Bairam Frootan',
                'Elise Beverley',
              ][i],
              style: const TextStyle(fontSize: 13),
            ),
            value: _selected.contains(i),
            onChanged: (_) => setState(() {
              if (!_selected.remove(i)) _selected.add(i);
            }),
          ),
        const Spacer(),
        PinkButton('Create channel', onPressed: _create),
        const SizedBox(height: 30),
      ],
    ),
  );
}

class StarredScreen extends StatelessWidget {
  const StarredScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final starred = store.conversations.values
        .expand((v) => v)
        .where((m) => m.starred)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Starred messages')),
      bottomNavigationBar: const BottomTabs(1),
      body: starred.isEmpty
          ? const Center(
              child: ArtEmpty(
                title: 'No Conversation',
                message: 'Tap and hold on any message to star it, so you can easily find it later.',
                image: 'starred_art',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(28),
              children: starred.map((m) => _MessageBubble(message: m)).toList(),
            ),
    );
  }
}
