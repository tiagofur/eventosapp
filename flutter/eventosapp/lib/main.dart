import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eventosapp/config/theme.dart';
import 'package:eventosapp/config/api_config.dart';
import 'package:eventosapp/core/storage/hive_init.dart';
import 'package:eventosapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:eventosapp/features/auth/presentation/pages/login_page.dart';
import 'package:eventosapp/features/dashboard/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveInit.init();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('es'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('es'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'EventosApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: authState.isAuthenticated
          ? const DashboardPage()
          : const LoginPage(),
    );
  }
}
