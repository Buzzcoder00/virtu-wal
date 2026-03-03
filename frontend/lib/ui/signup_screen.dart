import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  String _getErrorMessage(dynamic e) {
    final msg = e.toString();
    // Extract readable message from Firebase exceptions
    if (msg.contains('email-already-in-use'))
      return 'This email is already registered';
    if (msg.contains('weak-password'))
      return 'Password is too weak (at least 6 characters)';
    if (msg.contains('invalid-email')) return 'Invalid email address';
    if (msg.contains('too-many-requests'))
      return 'Too many requests. Please try again later';
    // Return just the message part (after ]: )
    if (msg.contains(']:')) return msg.split(']:').last.trim();
    return msg;
  }

  void _signup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      await auth.signUp(_emailController.text.trim(), _passwordController.text);
      // after signup, navigate back to login
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please log in.')),
        );
      }
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
      appBar: AppBar(title: const Text('Sign up')),
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
              onPressed: _isLoading ? null : _signup,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
