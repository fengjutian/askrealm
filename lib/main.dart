import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/settings_provider.dart';
import 'services/storage_service.dart';
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
      child: MaterialApp(
        title: '问戏',
        debugShowCheckedModeBanner: false,
        theme: _buildDarkTheme(),
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
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      cardColor: const Color(0xFF1A1A1A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1E88E5),
        secondary: Color(0xFF64FFDA),
        surface: Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.white54),
      ),
    );
  }
}
