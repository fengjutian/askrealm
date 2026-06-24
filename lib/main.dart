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
            onGenerateRoute: (routeSettings) {
              final Widget page;
              switch (routeSettings.name) {
                case '/':
                  page = const HomePage();
                  break;
                case '/select':
                  page = const CharacterSelectPage();
                  break;
                case '/chat/single':
                  page = const SingleChatPage();
                  break;
                case '/chat/group':
                  page = const GroupChatPage();
                  break;
                case '/settings':
                  page = const SettingsPage();
                  break;
                default:
                  page = const HomePage();
              }

              // 帷幕升起效果：淡入 + 微上移
              return _CurtainPageRoute(
                settings: routeSettings,
                page: page,
              );
            },
          );
        },
      ),
    );
  }
}

/// 自定义页面路由 — 帷幕升起过渡动画
class _CurtainPageRoute extends PageRouteBuilder {
  final Widget page;

  _CurtainPageRoute({required RouteSettings settings, required this.page})
      : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // 进入：淡入 + 轻微上移，模拟帷幕升起
            const beginOffset = Offset(0.0, 0.025);
            const endOffset = Offset.zero;

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final offsetTween = Tween<Offset>(begin: beginOffset, end: endOffset)
                .animate(curvedAnimation);
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .animate(curvedAnimation);

            return FadeTransition(
              opacity: fadeTween,
              child: SlideTransition(
                position: offsetTween,
                child: child,
              ),
            );
          },
        );
}
