import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:amia_messaging/app.dart';
import 'package:amia_messaging/core/app_store.dart';
import 'package:amia_messaging/data/models.dart';
import 'package:amia_messaging/features/auth/auth_screens.dart';
import 'package:amia_messaging/features/messaging/messaging_screens.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android: complete UI gallery and core user journeys', (
    tester,
  ) async {
    final store = AppStore();
    await tester.pumpWidget(AmiaApp(store: store));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    Future<void> capture(String name) async {
      messengerKey.currentState?.removeCurrentSnackBar();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: name);
      await binding.takeScreenshot(name);
    }

    Future<void> route(String path, String screenshot) async {
      FocusManager.instance.primaryFocus?.unfocus();
      messengerKey.currentState?.removeCurrentSnackBar();
      navigatorKey.currentState!.pushNamedAndRemoveUntil('/home', (_) => false);
      await tester.pumpAndSettle();
      if (path != '/home') navigatorKey.currentState!.pushNamed(path);
      await tester.pumpAndSettle();
      await capture(screenshot);
    }

    await capture('03_welcome');
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await capture('04_login');
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'hello@deeper.one',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'amia1234');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(store.signedIn, true);
    await capture('02_channels');
    await tester.tap(find.byTooltip('Options for Mattie Blooman'));
    await tester.pumpAndSettle();
    await capture('01_channel_options');
    await tester.tap(find.text('Mark as Unread'));
    await tester.pumpAndSettle();
    expect(store.unread, contains('mattie'));

    await route('/qr', '05_qr_account');
    await route('/accounts', '06_choose_account');
    await route('/signup', '07_signup');
    await route('/address', '08_address');
    await route('/complete-profile', '10_complete_profile');
    showPhotoPicker(navigatorKey.currentContext!);
    await tester.pumpAndSettle();
    await capture('09_photo_picker');
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    await route('/passcode', '11_passcode');
    await tester.enterText(find.byType(TextField), '0000');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter 1234'), findsOneWidget);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '1234',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your profile'), findsOneWidget);
    await route('/profile', '13_profile');
    await tester.tap(find.byTooltip('Profile options'));
    await tester.pumpAndSettle();
    await capture('12_profile_menu');
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    await route('/language', '14_language');
    await tester.tap(find.text('French'));
    await tester.pumpAndSettle();
    expect(store.language, 'French');
    await route('/contacts', '15_contacts');
    await route('/contacts-permission', '16_contacts_permission');
    await route('/invite', '17_invite');
    await route('/chat-settings', '18_chat_settings');
    await route('/theme', '19_theme');
    await tester.tap(find.text('Tinted Blue'));
    await tester.pumpAndSettle();
    expect(store.theme, 'Tinted Blue');
    await capture('32_dark_theme');
    store.theme = 'Classic';
    store.changed();
    await route('/notifications', '20_notifications');
    await route('/starred', '21_starred_empty');
    await route('/photo-preview', '22_photo_preview');
    await route('/camera', '23_camera');
    await route('/incoming-call', '25_incoming_call');
    await tester.tap(find.byTooltip('Accept call'));
    await tester.pumpAndSettle();
    await capture('24_connected_video_call');
    await route('/channels-expanded', '26_channels_expanded');
    await route('/new-channel', '27_new_channel');
    await tester.enterText(find.byType(TextField), 'Amia team');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Create channel'));
    await tester.pumpAndSettle();
    expect(store.channels, contains('Amia team'));
    await route('/chat', '28_chat');
    await tester.enterText(find.byType(TextField), 'Hello from Amia!');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(store.messages('design').last.text, 'Hello from Amia!');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Hello from Amia!'));
    await tester.pumpAndSettle();
    await capture('30_message_options');
    await tester.tap(find.text('Star message'));
    await tester.pumpAndSettle();
    expect(store.messages('design').last.starred, true);
    await route('/starred', '31_starred_messages');
    await route('/voice-call', '29_voice_call');
    await tester.tap(find.byTooltip('Mute microphone'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Unmute microphone'), findsOneWidget);
    await route('/calls', '33_calls');
    await route('/edit-profile', '34_edit_profile');
    await route('/privacy', '35_privacy');
    await route('/notification-settings', '36_notification_settings');
    await route('/members', '37_members');
    await route('/media', '38_shared_media');
    await route('/nearby', '39_nearby');
    await route('/forgot', '40_forgot_password');
    await route('/reset', '41_reset_password');
    store.archived.add(people.first.id);
    store.changed();
    await route('/archived', '42_archived');
    await route('/home', '43_home_final');
    showConversationOptions(navigatorKey.currentContext!, people.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unarchive'));
    await tester.pumpAndSettle();
    expect(store.archived, isEmpty);
    expect(find.text('Mattie Blooman'), findsOneWidget);
  });
}
