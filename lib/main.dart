import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/settings_provider.dart';
import 'services/storage_service.dart';
import 'theme.dart';
import 'pages/home_page.dart';
import 'pages/character_select_page.dart';
import 'pages/single_chat_page.dart';
import 'pages/group_chat_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const AskRealmApp());
}

class AskRealmApp extends StatelessWidget {
  const AskRealmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: '问戏',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: settings.themeMode,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  );
                case '/select':
                  return MaterialPageRoute(
                    builder: (_) => const CharacterSelectPage(),
                  );
                case '/chat/single':
                  return MaterialPageRoute(
                    builder: (_) => const SingleChatPage(),
                  );
                case '/chat/group':
                  return MaterialPageRoute(
                    builder: (_) => const GroupChatPage(),
                  );
                case '/settings':
                  return MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
