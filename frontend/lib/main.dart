import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/locale_service.dart';
import 'screens/landing/home_page.dart';
import 'screens/analytics/analytics_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleService().init();
  runApp(const SmartPackApp());
}

class SmartPackApp extends StatelessWidget {
  const SmartPackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        return MaterialApp(
          title: 'SmartPack AI - Precision Sustainable Packaging',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: LocaleService().currentLocale,
          home: const HomePage(),
          routes: {
            '/analytics': (context) => const AnalyticsDashboardScreen(),
          },
        );
      },
    );
  }
}
