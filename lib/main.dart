import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/features/auth/presentation/login_screen.dart';
import 'package:flutter_app/features/main_tabs/presentation/main_tabs_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: LaborgroApp(),
    ),
  );
}

class LaborgroApp extends ConsumerWidget {
  const LaborgroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Laborgro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: token == null ? const LoginScreen() : const MainTabsScreen(),
    );
  }
}
