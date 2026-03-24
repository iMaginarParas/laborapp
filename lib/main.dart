import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/features/auth/providers/auth_providers.dart';
import 'package:flutter_app/features/auth/presentation/login_screen.dart';
import 'package:flutter_app/features/main_tabs/presentation/main_tabs_screen.dart';
import 'package:flutter_app/features/home/presentation/role_selection_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/providers/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await StorageService.init();
  
  final token = StorageService.getToken();
  if (token != null) {
    DioClient.setToken(token);
  }
  
  runApp(
    ProviderScope(
      overrides: [
        if (token != null)
          authStateProvider.overrideWith((ref) => token),
      ],
      child: const LaborgroApp(),
    ),
  );
}

class LaborgroApp extends ConsumerWidget {
  const LaborgroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authStateProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Laborgro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: token == null 
          ? const LoginScreen() 
          : (ref.watch(currentRoleProvider) == null 
              ? const RoleSelectionScreen() 
              : const MainTabsScreen()),
    );
  }
}
