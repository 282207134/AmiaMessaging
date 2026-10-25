import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/app_store.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../auth/auth_screens.dart';
import '../messaging/messaging_screens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      bottomNavigationBar: const BottomTabs(3),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 316,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: SlantPainter()),
                ),
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            BackButton(
                              color: Colors.white,
                              onPressed: () => home(context),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'My QR code',
                              onPressed: () => go(context, '/qr'),
                              icon: const Icon(
                                CupertinoIcons.number,
                                color: Colors.white,
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Profile options',
                              icon: const Icon(
                                CupertinoIcons.ellipsis,
                                color: Colors.white,
                              ),
                              onSelected: (value) async {
                                if (value == '/logout') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (dialog) => AlertDialog(
                                      title: const Text('Log out?'),
                                      content: const Text(
                                        'Your messages and preferences will stay on this device.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialog, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialog, true),
                                          child: const Text('Log out'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && context.mounted) {
                                    store.signOut();
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                          '/welcome',
                                          (_) => false,
                                        );
                                  }
                                } else {
                                  go(context, value);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: '/edit-profile',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: '/reset',
                                  child: Text('Change your password'),
                                ),
                                const PopupMenuItem(
                                  value: '/logout',
                                  child: Text(
                                    'Log out',
                                    style: TextStyle(color: AmiaColors.pink),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: GestureDetector(
                          onTap: () => go(context, '/edit-profile'),
                          child: Row(
                            children: [
                              Avatar(store.avatar, size: 80),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      store.email,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      store.phone,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Setting', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                SettingRow(
                  'Notification',
                  icon: CupertinoIcons.bell,
                  onTap: () => go(context, '/notification-settings'),
                ),
                SettingRow(
                  'Privacy and Security',
                  icon: CupertinoIcons.circle_grid_3x3,
                  onTap: () => go(context, '/privacy'),
                ),
                SettingRow(
                  'Theme',
                  icon: CupertinoIcons.doc,
                  onTap: () => go(context, '/theme'),
                ),
                SettingRow(
                  'Language',
                  icon: CupertinoIcons.globe,
                  onTap: () => go(context, '/language'),
                ),
                const SizedBox(height: 30),
                const Text('Message', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 14),
                SettingRow(
                  'Direct share',
                  icon: CupertinoIcons.share,
                  onTap: () => go(context, '/invite'),
                ),
                SettingRow(
                  'Image gifts',
                  icon: CupertinoIcons.photo,
                  onTap: () => go(context, '/media'),
                ),
                SettingRow(
                  'Contact',
                  icon: CupertinoIcons.person_2,
                  onTap: () => go(context, '/contacts'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatSettingsScreen extends StatelessWidget {
  const ChatSettingsScreen({super.key, this.args = const ChatArgs()});
  final ChatArgs args;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Setting'),
      actions: [
        IconButton(
          tooltip: 'Edit channel name',
          icon: const Icon(CupertinoIcons.pencil, size: 19),
          onPressed: () async {
            final name = await editTextDialog(
              context,
              'Channel name',
              AppScope.of(context).titleFor(args.id, args.title),
            );
            if (name == null || name.trim().isEmpty || !context.mounted) return;
            final store = AppScope.of(context);
            store.channelTitles[args.id] = name.trim();
            store.changed();
            Navigator.of(context).pushReplacementNamed(
              '/chat-settings',
              arguments: ChatArgs(
                id: args.id,
                title: name.trim(),
                image: args.image,
              ),
            );
          },
        ),
        const SizedBox(width: 18),
      ],
    ),
    bottomNavigationBar: const BottomTabs(1),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 30),
      children: [
        Center(
          child: GestureDetector(
            onTap: () => showPhotoPicker(context),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AmiaColors.pink),
              ),
              child: const Icon(CupertinoIcons.chat_bubble_text, size: 46),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          AppScope.of(context).titleFor(args.id, args.title),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AmiaColors.pink,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final action in [
              (CupertinoIcons.person_add, '/invite'),
              (CupertinoIcons.phone, '/voice-call'),
              (CupertinoIcons.videocam, '/video-call'),
              (CupertinoIcons.bell, '/notification-settings'),
            ])
              CircleAvatar(
                backgroundColor: action.$2 == '/voice-call'
                    ? AmiaColors.ink
                    : const Color(0xFFF8F8F8),
                child: IconButton(
                  tooltip: action.$2.substring(1),
                  icon: Icon(
                    action.$1,
                    size: 20,
                    color: action.$2 == '/voice-call'
                        ? Colors.white
                        : AmiaColors.pink,
                  ),
                  onPressed: () => go(context, action.$2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 45),
        SettingRow(
          'Theme chat',
          height: 50,
          onTap: () => go(context, '/theme'),
        ),
        SettingRow(
          'Receive notifications',
          height: 50,
          onTap: () => go(context, '/notification-settings'),
        ),
        SettingRow(
          'Media share',
          height: 50,
          onTap: () => go(context, '/media'),
        ),
        SettingRow(
          'See group members',
          height: 50,
          onTap: () => go(context, '/members'),
        ),
        SettingRow(
          'Starred messages',
          height: 50,
          onTap: () => go(context, '/starred'),
        ),
      ],
    ),
  );
}

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Chat setting')),
      bottomNavigationBar: const BottomTabs(3),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 30),
        children: [
          const Text('Theme color', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            height: 190 + (store.textSize - 13) * 7,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: store.theme == 'Day'
                  ? const Color(0xFFE4F4F3)
                  : AmiaColors.ink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AmiaColors.accents[store.colorIndex],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Probabo, inquit, modo ista sis\nIt’s morning in Tokyo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: store.textSize - 2,
                      height: 1.8,
                    ),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AmiaColors.blue,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      'It’s morning in Tokyo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: store.textSize - 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (final theme in ['Classic', 'Day', 'Tinted Blue'])
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      store.theme = theme;
                      store.changed();
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 59,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: theme == 'Tinted Blue'
                                ? const Color(0xFF16283B)
                                : const Color(0xFFF2F4F6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: store.theme == theme
                                  ? AmiaColors.pink
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AmiaColors.accents[store.colorIndex],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 30,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AmiaColors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(theme, style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < AmiaColors.accents.length; i++)
                Semantics(
                  label: 'Theme color ${i + 1}',
                  selected: store.colorIndex == i,
                  child: GestureDetector(
                    onTap: () {
                      store.colorIndex = i;
                      store.changed();
                    },
                    child: Container(
                      width: 37,
                      height: 37,
                      decoration: BoxDecoration(
                        color: AmiaColors.accents[i],
                        shape: BoxShape.circle,
                      ),
                      child: store.colorIndex == i
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          SettingRow(
            'Chat Background',
            height: 50,
            subtitle: store.theme,
            onTap: () {
              store.theme = store.theme == 'Day' ? 'Classic' : 'Day';
              store.changed();
            },
          ),
          SettingRow(
            'Auto-Night Mode',
            height: 50,
            trailing: Switch.adaptive(
              value: store.nightMode,
              activeTrackColor: AmiaColors.pink,
              onChanged: (v) {
                store.nightMode = v;
                store.changed();
              },
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'Text size · ${store.textSize.toInt()}',
            style: const TextStyle(fontSize: 12),
          ),
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 11)),
              Expanded(
                child: Slider(
                  min: 11,
                  max: 18,
                  divisions: 7,
                  value: store.textSize,
                  onChanged: (v) {
                    store.textSize = v;
                    store.changed();
                  },
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 18),
          const Text('App icon', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AmiaColors.pink,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(asset('amia_logo')),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _query = '';
  static const _languages = [
    ('English', 'English'),
    ('Arabic', 'العربية'),
    ('Catalan', 'Català'),
    ('Dutch', 'Nederlands'),
    ('French', 'Français'),
    ('German', 'Deutsch'),
    ('Indonesian', 'Bahasa Indonesia'),
    ('Italian', 'Italiano'),
    ('Chinese', '简体中文'),
  ];
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Languages')),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const Text(
            'Search for your language',
            style: TextStyle(fontSize: 12),
          ),
          TextField(
            decoration: const InputDecoration(
              hintText: 'ex: English',
              suffixIcon: Icon(CupertinoIcons.search, size: 18),
            ),
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
          ),
          const SizedBox(height: 32),
          const Text('Languages', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          for (final language in _languages.where(
            (l) => '${l.$1} ${l.$2}'.toLowerCase().contains(_query),
          ))
            SettingRow(
              language.$1,
              subtitle: language.$2,
              trailing: store.language == language.$1
                  ? const Icon(CupertinoIcons.checkmark, size: 18)
                  : const SizedBox(),
              onTap: () {
                store.language = language.$1;
                store.changed();
                toast(context, '${language.$1} selected');
              },
            ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notification'),
      actions: [
        IconButton(
          tooltip: 'Notification settings',
          onPressed: () => go(context, '/notification-settings'),
          icon: const Icon(CupertinoIcons.gear, size: 20),
        ),
        const SizedBox(width: 16),
      ],
    ),
    bottomNavigationBar: const BottomTabs(2),
    body: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      children: [
        Center(
          child: Image.asset(
            asset('notification_art'),
            height: 165,
            width: 165,
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < 6; i++) ...[
          if (i == 0 || i == 3)
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                i == 0 ? 'Today' : 'Yesterday',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          InkWell(
            onTap: () => go(
              context,
              i == 5 ? '/incoming-call' : '/chat',
              arguments: const ChatArgs(),
            ),
            child: SizedBox(
              height: 65,
              child: Row(
                children: [
                  Avatar(people[i].image, size: 40),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          [
                            '1 minute',
                            '12 minutes',
                            '2 hours',
                            '12h 34',
                            '15h 12',
                            '52 minutes ago',
                          ][i],
                          style: const TextStyle(
                            fontSize: 10,
                            color: AmiaColors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            'Alii autem, quibus ego assentior',
                            'Primum igitur, quid sit',
                            'Et quidem exercitus quid ex eo',
                            'Et quidem rerum hic tenetur a',
                            'Quid ex eo est cur verear, ne',
                            'You missed 1 call from Join',
                          ][i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
        ],
        const SizedBox(height: 24),
      ],
    ),
  );
}

class PreferenceScreen extends StatelessWidget {
  const PreferenceScreen({super.key, this.privacy = false});
  final bool privacy;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(privacy ? 'Privacy and Security' : 'Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          Center(
            child: Image.asset(
              asset(privacy ? 'contacts_art' : 'notification_art'),
              width: 150,
              height: 150,
            ),
          ),
          const SizedBox(height: 30),
          if (privacy) ...[
            SettingRow(
              'Change password',
              icon: CupertinoIcons.lock,
              onTap: () => go(context, '/reset'),
            ),
            SettingRow(
              'Archived chats',
              icon: CupertinoIcons.archivebox,
              onTap: () => go(context, '/archived'),
            ),
            SettingRow(
              'My QR code',
              icon: CupertinoIcons.qrcode,
              onTap: () => go(context, '/qr'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Messages and profile preferences are saved on this device. You can manage conversations from Channels.',
              style: TextStyle(
                color: AmiaColors.muted,
                fontSize: 12,
                height: 1.8,
              ),
            ),
          ] else ...[
            SettingRow(
              'Receive notifications',
              subtitle: 'In-app notification preference',
              trailing: Switch.adaptive(
                value: store.notifications,
                activeTrackColor: AmiaColors.pink,
                onChanged: (v) {
                  store.notifications = v;
                  store.changed();
                },
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Your preference is saved locally. Push notifications require a connected messaging service.',
              style: TextStyle(
                color: AmiaColors.muted,
                fontSize: 12,
                height: 1.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Shared media')),
    body: GridView.count(
      padding: const EdgeInsets.all(28),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children:
          ['camera', 'camera_preview', 'erika', 'story_1', 'story_2', 'dennis']
              .map(
                (image) => GestureDetector(
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (dialog) => Dialog(
                      child: Stack(
                        children: [
                          Image.asset(asset(image), fit: BoxFit.contain),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton.filled(
                              tooltip: 'Close photo',
                              onPressed: () => Navigator.pop(dialog),
                              icon: const Icon(CupertinoIcons.xmark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(asset(image), fit: BoxFit.cover),
                  ),
                ),
              )
              .toList(),
    ),
  );
}
