import 'package:flutter_test/flutter_test.dart';
import 'package:amia_messaging/core/app_store.dart';
import 'package:amia_messaging/data/local_repository.dart';

class MemoryRepository extends LocalRepository {
  Map<String, dynamic> data = {};
  @override
  Future<Map<String, dynamic>> read() async => data;
  @override
  Future<void> write(Map<String, dynamic> value) async {
    data = value;
  }
}

void main() {
  test('empty messages are ignored; conversations remain isolated', () {
    final store = AppStore();
    store.send('mattie', '  ');
    expect(store.conversations, isEmpty);
    store.send('mattie', '  Hello Amia  ');
    expect(store.messages('mattie').last.text, 'Hello Amia');
    expect(store.messages('wim').length, 3);
  });
  test(
    'profile, preferences, messages and archives survive a restart',
    () async {
      final repository = MemoryRepository();
      final store = AppStore(repository: repository);
      store.name = 'Test User';
      store.colorIndex = 2;
      store.nightMode = true;
      store.archived.add('wim');
      store.channelTitles['design'] = 'Creative team';
      store.unread.add('mattie');
      store.signIn();
      store.send('mattie', 'Persist me');
      store.messages('mattie').last.starred = true;
      store.changed();
      await store.flush();
      final restored = AppStore(repository: repository);
      await restored.load();
      expect(restored.name, 'Test User');
      expect(restored.signedIn, true);
      expect(restored.colorIndex, 2);
      expect(restored.nightMode, true);
      expect(restored.titleFor('design', 'Design UX'), 'Creative team');
      expect(restored.archived, contains('wim'));
      expect(restored.unread, contains('mattie'));
      expect(restored.messages('mattie').last.text, 'Persist me');
      expect(restored.messages('mattie').last.starred, true);
      restored.markRead('mattie');
      expect(restored.unread, isEmpty);
    },
  );
  test('sign out preserves local messages', () {
    final store = AppStore();
    store.send('mattie', 'Keep this');
    store.signIn();
    store.signOut();
    expect(store.signedIn, false);
    expect(store.messages('mattie').last.text, 'Keep this');
  });
}
