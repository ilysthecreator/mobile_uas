import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/splash_page.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to theme changes from AuthProvider via Riverpod
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'E-Ticketing Helpdesk',
      debugShowCheckedModeBanner: false,
      
      // Theme settings
      themeMode: authState.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // Initial home screen
      home: const SplashPage(),
    );
  }
}
