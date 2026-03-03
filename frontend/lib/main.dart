import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'ui/dashboard.dart';
import 'ui/login_screen.dart';
import 'ui/signup_screen.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Prefer default initialization (works when google-services.json is present).
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Default Firebase.initializeApp() failed: $e');
    // Fallback: initialize with explicit options using the provided config.
    // This helps when a google-services.json is not present (quick start).
    const firebaseOptions = FirebaseOptions(
      apiKey: 'AIzaSyANahVtrHkNaCTZ8FMKKKorEPezTrNMC18',
      authDomain: 'virtuwal-8ba9b.firebaseapp.com',
      databaseURL:
          'https://virtuwal-8ba9b-default-rtdb.asia-southeast1.firebasedatabase.app',
      projectId: 'virtuwal-8ba9b',
      storageBucket: 'virtuwal-8ba9b.firebasestorage.app',
      messagingSenderId: '238385591985',
      appId: '1:238385591985:web:66473faa803becc92a5490',
    );

    try {
      // On web use the same options; on mobile this may work as a fallback.
      await Firebase.initializeApp(options: firebaseOptions);
      debugPrint('Firebase initialized with explicit options');
    } catch (e2) {
      debugPrint('Firebase fallback initialization failed: $e2');
    }
  }
  runApp(const ProviderScope(child: VirtuWalApp()));
}

class VirtuWalApp extends ConsumerWidget {
  const VirtuWalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'VirtuWal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A3CE8),
          primary: const Color(0xFF6A3CE8),
          secondary: const Color(0xFF3861FB),
        ),
        useMaterial3: true,
        textTheme:
            GoogleFonts.interTextTheme(Theme.of(context).textTheme).copyWith(
          titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFC),
      ),
      home: const _RootNavigator(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
      },
    );
  }
}

/// Wrapper widget that handles auth-based navigation without rebuilding the
/// entire home widget on auth state changes. This preserves the navigation stack.
class _RootNavigator extends ConsumerWidget {
  const _RootNavigator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseUserProvider);

    return authState.when(
      data: (user) {
        debugPrint('authState data: $user');
        if (user == null) {
          return const LoginScreen();
        }
        return const DashboardScreen();
      },
      loading: () {
        debugPrint('authState loading');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (e, _) {
        debugPrint('authState error: $e');
        return Scaffold(body: Center(child: Text('Error: $e')));
      },
    );
  }
}
