import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/local_repository.dart';
import '../data/models.dart';

class AppStore extends ChangeNotifier {
  AppStore({this.repository});
  final LocalRepository? repository;
  bool signedIn = false, notifications = true, nightMode = false;
  bool contactsEnabled = false;
  String name = 'Dennis', email = 'hello@deeper.one', phone = '+123 456 789';
  String avatar = 'dennis', language = 'English', theme = 'Classic';
  String address = 'New York';
  String birthday = '11/02/1990', gender = 'Male';
  int colorIndex = 0;
  double textSize = 13;
  final Map<String, List<ChatMessage>> conversations = {};
  final Set<String> archived = {}, unread = {}, muted = {};
  final List<String> channels = ['Design UX'];
  final Map<String, String> channelTitles = {};
  String titleFor(String id, String fallback) => channelTitles[id] ?? fallback;
  Future<void> _pendingSave = Future.value();
  String? storageError;

  Future<void> load() async {
    final data = await repository?.read() ?? {};
    signedIn = data['signedIn'] as bool? ?? false;
    name = data['name'] as String? ?? name;
    email = data['email'] as String? ?? email;
    phone = data['phone'] as String? ?? phone;
    avatar = data['avatar'] as String? ?? avatar;
    address = data['address'] as String? ?? address;
    birthday = data['birthday'] as String? ?? birthday;
    gender = data['gender'] as String? ?? gender;
    channelTitles.addAll(
      (data['channelTitles'] as Map<String, dynamic>? ?? {})
          .cast<String, String>(),
    );
    language = data['language'] as String? ?? language;
    theme = data['theme'] as String? ?? theme;
    textSize = (data['textSize'] as num?)?.toDouble() ?? textSize;
    colorIndex = data['colorIndex'] as int? ?? 0;
    notifications = data['notifications'] as bool? ?? true;
    nightMode = data['nightMode'] as bool? ?? false;
    contactsEnabled = data['contactsEnabled'] as bool? ?? false;
    for (final entry
        in (data['conversations'] as Map<String, dynamic>? ?? {}).entries) {
      conversations[entry.key] = (entry.value as List)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    for (final entry in {
      'archived': archived,
      'unread': unread,
      'muted': muted,
    }.entries) {
      entry.value.addAll((data[entry.key] as List? ?? []).cast<String>());
    }
    channels.addAll(
      (data['channels'] as List? ?? []).cast<String>().where(
        (c) => !channels.contains(c),
      ),
    );
  }

  List<ChatMessage> messages(String id) =>
      conversations.putIfAbsent(id, initialMessages);
  void send(String id, String text, {String kind = 'text'}) {
    if (text.trim().isEmpty) return;
    messages(id).add(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text.trim(),
        kind: kind,
      ),
    );
    changed();
  }

  void markRead(String id) {
    unread.remove(id);
    changed();
  }

  void signIn() {
    signedIn = true;
    changed();
  }

  void signOut() {
    signedIn = false;
    changed();
  }

  void changed() {
    notifyListeners();
    // Serialize writes so rapid changes cannot overwrite a newer snapshot.
    _pendingSave = _pendingSave.then((_) async {
      try {
        await repository?.write(snapshot());
        storageError = null;
      } catch (_) {
        storageError = 'Changes could not be saved on this device.';
      }
    });
    unawaited(_pendingSave);
  }

  Future<void> flush() => _pendingSave;
  Map<String, dynamic> snapshot() => {
    'signedIn': signedIn,
    'name': name,
    'email': email,
    'phone': phone,
    'avatar': avatar,
    'address': address,
    'birthday': birthday,
    'gender': gender,
    'language': language,
    'theme': theme,
    'textSize': textSize,
    'colorIndex': colorIndex,
    'notifications': notifications,
    'nightMode': nightMode,
    'contactsEnabled': contactsEnabled,
    'channels': channels,
    'channelTitles': channelTitles,
    'archived': archived.toList(),
    'unread': unread.toList(),
    'muted': muted.toList(),
    'conversations': conversations.map(
      (key, value) => MapEntry(key, value.map((m) => m.toJson()).toList()),
    ),
  };
}

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);
  static AppStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
