import 'package:flutter/material.dart';

import 'core/app_store.dart';
import 'core/theme.dart';
import 'features/auth/auth_screens.dart';
import 'features/calls/call_screens.dart';
import 'features/messaging/messaging_screens.dart';
import 'features/people/people_screens.dart';
import 'features/settings/settings_screens.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();

class AmiaApp extends StatelessWidget {
  const AmiaApp({super.key, required this.store, this.initialRoute});
  final AppStore store;
  final String? initialRoute;
  @override
  Widget build(BuildContext context) => AppScope(
    store: store,
    child: ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        title: 'Amia',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: messengerKey,
        theme: amiaTheme(false),
        darkTheme: amiaTheme(true),
        themeMode: store.nightMode || store.theme == 'Tinted Blue'
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: initialRoute ?? (store.signedIn ? '/home' : '/welcome'),
        builder: (context, child) => ColoredBox(
          color: const Color(0xFFE9EAEE),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child!,
            ),
          ),
        ),
        onGenerateInitialRoutes: (name) => [_route(RouteSettings(name: name))],
        onGenerateRoute: _route,
      ),
    ),
  );
}

Route<void> _route(RouteSettings settings) {
  final args = settings.arguments is ChatArgs
      ? settings.arguments as ChatArgs
      : const ChatArgs();
  final screen = switch (settings.name) {
    '/welcome' => const WelcomeScreen(),
    '/login' => const LoginScreen(),
    '/signup' => const LoginScreen(signUp: true),
    '/accounts' => const AccountScreen(),
    '/qr' => const QrScreen(),
    '/passcode' => const PasscodeScreen(),
    '/passcode-reset' => const PasscodeScreen(reset: true),
    '/complete-profile' => const CompleteProfileScreen(),
    '/edit-profile' => const CompleteProfileScreen(edit: true),
    '/address' => const AddressScreen(),
    '/forgot' => const PasswordScreen(forgot: true),
    '/reset' => const PasswordScreen(),
    '/home' => const ChannelsScreen(),
    '/channels-expanded' => const ChannelsScreen(expanded: true),
    '/archived' => const ChannelsScreen(archived: true),
    '/chat' => ChatScreen(args: args),
    '/new-channel' => const NewChannelScreen(),
    '/starred' => const StarredScreen(),
    '/chat-settings' => ChatSettingsScreen(args: args),
    '/profile' => const ProfileScreen(),
    '/theme' => const ThemeScreen(),
    '/language' => const LanguageScreen(),
    '/notifications' => const NotificationsScreen(),
    '/notification-settings' => const PreferenceScreen(),
    '/privacy' => const PreferenceScreen(privacy: true),
    '/contacts' => const ContactsScreen(),
    '/members' => const ContactsScreen(members: true),
    '/contacts-permission' => const ContactsPermissionScreen(),
    '/nearby' => const NearbyScreen(),
    '/invite' => const InviteScreen(),
    '/media' => const MediaScreen(),
    '/calls' => const CallsScreen(),
    '/voice-call' => const CallScreen(),
    '/video-call' => const CallScreen(video: true),
    '/incoming-call' => const CallScreen(video: true, incoming: true),
    '/camera' => PhotoScreen(args: args),
    '/photo-preview' => PhotoScreen(preview: true, args: args),
    _ => const WelcomeScreen(),
  };
  return MaterialPageRoute<void>(settings: settings, builder: (_) => screen);
}
