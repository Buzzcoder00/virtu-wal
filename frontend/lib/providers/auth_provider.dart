import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

/// Exposes the current [User] or null if not signed in.
final firebaseUserProvider = StreamProvider<User?>((ref) {
  final service = AuthService();
  return service.authStateChanges();
});

/// Wrapper around [AuthService] to perform actions.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
