import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amia_messaging/app.dart';
import 'package:amia_messaging/core/app_store.dart';

void main() {
  testWidgets('verification recovers from an invalid code', (tester) async {
    await tester.pumpWidget(
      AmiaApp(store: AppStore(), initialRoute: '/passcode'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0000');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter 1234'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your profile'), findsOneWidget);
  });
  testWidgets('login validates inputs and reaches Channels', (tester) async {
    final store = AppStore();
    await tester.pumpWidget(AmiaApp(store: store, initialRoute: '/login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'test@amia.app');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(store.signedIn, true);
    expect(find.text('Recent contact'), findsOneWidget);
  });
  testWidgets('sending a message updates the visible conversation', (
    tester,
  ) async {
    final store = AppStore();
    await tester.pumpWidget(AmiaApp(store: store, initialRoute: '/chat'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A real local message');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(store.messages('design').last.text, 'A real local message');
    expect(find.text('A real local message'), findsOneWidget);
    await tester.longPress(find.text('A real local message'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Star message'));
    await tester.pumpAndSettle();
    expect(store.messages('design').last.starred, true);
  });
  testWidgets('search shows an empty result then restores contacts', (
    tester,
  ) async {
    await tester.pumpWidget(AmiaApp(store: AppStore(), initialRoute: '/home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Search conversations'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'not-a-contact');
    await tester.pumpAndSettle();
    expect(find.text('No conversations found'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Mattie');
    await tester.pumpAndSettle();
    expect(find.text('Mattie Blooman'), findsOneWidget);
    expect(find.text('Wim Willems'), findsNothing);
  });
  testWidgets('small phone pages and keyboard forms remain scrollable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    for (final route in [
      '/welcome',
      '/signup',
      '/passcode',
      '/complete-profile',
      '/new-channel',
      '/theme',
      '/profile',
      '/reset',
    ]) {
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await tester.pumpWidget(AmiaApp(store: AppStore(), initialRoute: route));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
      if (['/signup', '/passcode', '/new-channel', '/reset'].contains(route)) {
        tester.view.viewInsets = const FakeViewPadding(bottom: 240);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$route with keyboard');
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
      }
    }
  });
}
