import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  String _getErrorMessage(dynamic e) {
    final msg = e.toString();
    // Extract readable message from Firebase exceptions
    if (msg.contains('user-not-found'))
      return 'No account found with this email';
    if (msg.contains('wrong-password')) return 'Incorrect password';
    if (msg.contains('invalid-email')) return 'Invalid email address';
    if (msg.contains('user-disabled')) return 'This account has been disabled';
    if (msg.contains('too-many-requests'))
      return 'Too many login attempts. Please try again later';
    // Return just the message part (after ]: )
    if (msg.contains(']:')) return msg.split(']:').last.trim();
    return msg;
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      await auth.signIn(_emailController.text.trim(), _passwordController.text);
    } catch (e) {
      setState(() {
        _error = _getErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
