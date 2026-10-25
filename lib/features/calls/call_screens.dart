import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/app_store.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../messaging/messaging_screens.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Calls'),
      actions: [
        IconButton(
          tooltip: 'New call',
          onPressed: () => go(context, '/voice-call'),
          icon: const Icon(CupertinoIcons.phone_badge_plus),
        ),
        const SizedBox(width: 16),
      ],
    ),
    bottomNavigationBar: const BottomTabs(0),
    body: ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const Text('Recent calls', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 20),
        for (var i = 0; i < 6; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Avatar(people[i].image),
            title: Text(
              people[i].name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              i % 3 == 0 ? '↙ Missed call · Yesterday' : '↗ Outgoing · Today',
              style: TextStyle(
                fontSize: 11,
                color: i % 3 == 0 ? AmiaColors.pink : AmiaColors.muted,
              ),
            ),
            trailing: Icon(
              i.isEven ? CupertinoIcons.phone : CupertinoIcons.videocam,
              size: 21,
            ),
            onTap: () =>
                go(context, i.isEven ? '/voice-call' : '/incoming-call'),
          ),
      ],
    ),
  );
}

class CallScreen extends StatefulWidget {
  const CallScreen({super.key, this.video = false, this.incoming = false});
  final bool video, incoming;
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Timer? _timer;
  bool _connected = false, _muted = false, _speaker = false, _camera = true;
  int _seconds = 0;
  @override
  void initState() {
    super.initState();
    if (!widget.incoming && !widget.video) _start();
  }

  void _start() {
    _connected = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _duration =>
      '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';
  void _end() {
    Navigator.pop(context);
    toast(context, _connected ? 'Call ended · $_duration' : 'Call declined');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AmiaColors.ink,
    body: Stack(
      children: [
        if (widget.video)
          Positioned.fill(
            child: Image.asset(asset('erika'), fit: BoxFit.cover),
          ),
        if (widget.video)
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: .12)),
          ),
        if (!widget.video)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 280,
            child: CustomPaint(painter: _CallSlantPainter()),
          ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const BackButton(color: Colors.white),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Switch camera',
                      onPressed: () => setState(() => _camera = !_camera),
                      icon: Icon(
                        _camera
                            ? CupertinoIcons.videocam
                            : CupertinoIcons.videocam_fill,
                        color: AmiaColors.pink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (!widget.video) ...[
                const Avatar('rahul', size: 160),
                const SizedBox(height: 20),
                const Text(
                  'Rahul Malviya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _connected ? 'Connected' : 'Coming call…',
                              style: const TextStyle(
                                color: AmiaColors.pink,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Erika Mateo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.incoming)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            asset('story_1'),
                            width: 86,
                            height: 125,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                _connected ? _duration : 'Waiting…',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              const Text(
                'Call preview',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if ((widget.incoming || widget.video) && !_connected) ...[
                    _CallControl(
                      icon: CupertinoIcons.phone,
                      label: 'Accept call',
                      color: const Color(0xFF16CAA0),
                      onPressed: () => setState(_start),
                    ),
                    const SizedBox(width: 95),
                    _CallControl(
                      icon: CupertinoIcons.phone_down,
                      label: 'Decline call',
                      onPressed: _end,
                    ),
                  ] else ...[
                    _CallControl(
                      icon: _muted
                          ? CupertinoIcons.mic_slash
                          : CupertinoIcons.mic,
                      label: _muted ? 'Unmute microphone' : 'Mute microphone',
                      small: true,
                      color: _muted ? AmiaColors.pink : Colors.transparent,
                      onPressed: () => setState(() => _muted = !_muted),
                    ),
                    const SizedBox(width: 32),
                    _CallControl(
                      icon: CupertinoIcons.phone_down,
                      label: 'End call',
                      onPressed: _end,
                    ),
                    const SizedBox(width: 32),
                    _CallControl(
                      icon: _speaker
                          ? CupertinoIcons.speaker_2_fill
                          : CupertinoIcons.speaker_2,
                      label: 'Speaker',
                      small: true,
                      color: _speaker ? AmiaColors.pink : Colors.transparent,
                      onPressed: () => setState(() => _speaker = !_speaker),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 75),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color = AmiaColors.pink,
    this.small = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool small;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: small ? 40 : 72,
    height: small ? 40 : 72,
    child: IconButton(
      tooltip: label,
      style: IconButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: small ? 25 : 34),
    ),
  );
}

class _CallSlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AmiaColors.yellow);
    canvas.drawPath(
      Path()
        ..lineTo(size.width, 0)
        ..lineTo(size.width, 50)
        ..lineTo(0, 0)
        ..close(),
      Paint()..color = AmiaColors.ink,
    );
    canvas.drawPath(
      Path()
        ..lineTo(size.width * .75, 38)
        ..lineTo(0, 80)
        ..close(),
      Paint()..color = AmiaColors.pink,
    );
  }

  @override
  bool shouldRepaint(_CallSlantPainter old) => false;
}

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({
    super.key,
    this.preview = false,
    this.args = const ChatArgs(),
  });
  final bool preview;
  final ChatArgs args;
  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  int _filter = 0;
  bool _flash = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AmiaColors.ink,
    body: Stack(
      children: [
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              [
                Colors.transparent,
                Colors.amber.withValues(alpha: .12),
                Colors.pink.withValues(alpha: .14),
                Colors.blue.withValues(alpha: .18),
              ][_filter],
              BlendMode.srcATop,
            ),
            child: Image.asset(
              asset(widget.preview ? 'camera_preview' : 'camera'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .6),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 12),
                  const BackButton(color: Colors.white),
                  const Spacer(),
                  Text(
                    widget.preview ? 'Photo preview' : 'Sample camera',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  IconButton(
                    tooltip: 'Flash',
                    onPressed: () => setState(() => _flash = !_flash),
                    icon: Icon(
                      _flash
                          ? CupertinoIcons.bolt_fill
                          : CupertinoIcons.bolt_slash,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              const Spacer(),
              if (!widget.preview)
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => setState(() => _filter = i),
                      child: Container(
                        width: 78,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _filter == i
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            asset(i.isEven ? 'camera' : 'camera_preview'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Photo library',
                      onPressed: () => go(context, '/media'),
                      icon: const Icon(
                        CupertinoIcons.photo,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: IconButton(
                        tooltip: widget.preview ? 'Send photo' : 'Take photo',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        icon: Icon(
                          widget.preview
                              ? CupertinoIcons.paperplane
                              : CupertinoIcons.camera,
                          size: 32,
                        ),
                        onPressed: () {
                          if (!widget.preview) {
                            go(
                              context,
                              '/photo-preview',
                              arguments: widget.args,
                            );
                            return;
                          }
                          AppScope.of(context).send(
                            widget.args.id,
                            'camera_preview',
                            kind: 'image',
                          );
                          Navigator.popUntil(
                            context,
                            (route) =>
                                route.settings.name == '/chat' || route.isFirst,
                          );
                          toast(context, 'Photo added to conversation');
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: 'Switch filter',
                      onPressed: () =>
                          setState(() => _filter = (_filter + 1) % 4),
                      icon: const Icon(
                        CupertinoIcons.camera_rotate,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 55),
            ],
          ),
        ),
      ],
    ),
  );
}
