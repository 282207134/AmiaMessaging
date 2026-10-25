import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/app_store.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../auth/auth_screens.dart';
import '../messaging/messaging_screens.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key, this.members = false});
  final bool members;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(members ? 'Group members' : 'New Contacts')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
      children: [
        if (!members) ...[
          SettingRow(
            'Add people nearby',
            icon: CupertinoIcons.location,
            onTap: () => go(context, '/nearby'),
          ),
          SettingRow(
            'Invite friends',
            icon: CupertinoIcons.person_add,
            onTap: () => go(context, '/invite'),
          ),
          SettingRow(
            'Upload contact',
            icon: CupertinoIcons.square_arrow_up,
            onTap: () => go(context, '/contacts-permission'),
          ),
          SettingRow(
            'Connect instagram',
            icon: CupertinoIcons.camera,
            onTap: () => showDialog<void>(
              context: context,
              builder: (dialog) => AlertDialog(
                title: const Text('Connect Instagram'),
                content: const Text(
                  'Social account connections will be available when a messaging service is connected.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialog),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text('Contacts', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 14),
        ],
        for (var i = 0; i < (members ? people.length : 3); i++)
          _ContactTile(
            people[i],
            city: [
              'Bratislava',
              'Brussels',
              'Harare',
              'Tokyo',
              'Berlin',
              'Shanghai',
              'Paris',
            ][i],
          ),
        if (!members) ...[
          const SizedBox(height: 30),
          const Text('Suggested people', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 14),
          for (final person in people.skip(3)) _ContactTile(person),
        ],
      ],
    ),
  );
}

class _ContactTile extends StatelessWidget {
  const _ContactTile(this.person, {this.city = 'Available on Amia'});
  final Person person;
  final String city;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Avatar(person.image, size: 42),
    title: Text(
      person.name,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      city,
      style: const TextStyle(fontSize: 11, color: AmiaColors.muted),
    ),
    trailing: const Icon(CupertinoIcons.chat_bubble, size: 18),
    onTap: () => go(
      context,
      '/chat',
      arguments: ChatArgs(
        id: person.id,
        title: person.name,
        image: person.image,
      ),
    ),
  );
}

class ContactsPermissionScreen extends StatelessWidget {
  const ContactsPermissionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Contacts')),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
        child: Column(
          children: [
            const Expanded(
              child: ArtEmpty(
                title: 'Find your phone contacts on messenger',
                message: 'Find friends and start a conversation. Enable the sample contact list to explore connections on Amia.',
                image: 'contacts_art',
              ),
            ),
            PinkButton(
              AppScope.of(context).contactsEnabled
                  ? 'View contacts'
                  : 'Turn on',
              onPressed: () {
                final store = AppScope.of(context);
                store.contactsEnabled = true;
                store.changed();
                Navigator.of(context).pushReplacementNamed('/contacts');
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});
  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _email = TextEditingController();
  final _form = GlobalKey<FormState>();
  final Set<String> _invited = {};
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Invite people')),
    body: ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Form(
          key: _form,
          child: FormFieldLine(
            'Enter your friend’s email',
            hint: 'ex: hello@deeper.one',
            controller: _email,
            keyboard: TextInputType.emailAddress,
            validator: emailValidator,
            suffix: IconButton(
              tooltip: 'Create invitation',
              icon: const Icon(CupertinoIcons.paperplane, size: 20),
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                setState(() => _invited.add(_email.text.trim()));
                toast(context, 'Invitation prepared for ${_email.text.trim()}');
                _email.clear();
              },
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text('Channel', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 14),
        for (var i = 0; i < 4; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Avatar(people[i].image, size: 30),
            title: Text(
              [
                'Group design system',
                'Design Voicechat',
                'Rahul Malviya',
                'Kendasha Wood',
              ][i],
              style: const TextStyle(fontSize: 13),
            ),
            onTap: () => go(context, '/chat', arguments: const ChatArgs()),
          ),
        if (_invited.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Prepared invitations',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          for (final email in _invited)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(email, style: const TextStyle(fontSize: 12)),
              trailing: const Icon(CupertinoIcons.checkmark, size: 16),
            ),
        ],
      ],
    ),
  );
}

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('People nearby')),
    body: ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const Text(
          'Discover people in the Amia community',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 24),
        for (final person in people.take(4)) _ContactTile(person),
        const SizedBox(height: 30),
        const Text(
          'Sample community · Your location is not accessed',
          style: TextStyle(color: AmiaColors.muted, fontSize: 11),
        ),
      ],
    ),
  );
}
