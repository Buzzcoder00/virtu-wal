import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../services/signature_service.dart';
import '../models/wallet.dart';
import '../providers/wallet_provider.dart';
import '../providers/auth_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> payload;

  const PaymentScreen({super.key, required this.payload});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isLoading = true;
  Wallet? _scannedWallet;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    final globalUuid = widget.payload['uuid'];
    final walletId = widget.payload['walletId'];

    debugPrint('Fetching wallet: globalUuid=$globalUuid, walletId=$walletId');

    // if the QR belongs to the current user, abort
    final user = ref
        .read(firebaseUserProvider)
        .maybeWhen(data: (u) => u, orElse: () => null);
    if (user != null && user.uid == globalUuid) {
      setState(() {
        _error = 'You cannot scan your own fundraiser QR.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Use the correct asia-southeast1 Firebase Realtime Database endpoint
      final url = Uri.parse(
          'https://virtuwal-8ba9b-default-rtdb.asia-southeast1.firebasedatabase.app/wallets/$globalUuid/$walletId.json');
      debugPrint('Fetching from: $url');

      final response = await http.get(url);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body);
        final wallet = Wallet.fromJson(Map<String, dynamic>.from(data));

        if (!SignatureService.verifySignature(
            widget.payload, wallet.signatureKey)) {
          setState(() {
            _error = "Invalid Signature! This QR may have been forged.";
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _scannedWallet = wallet;
          _isLoading = false;
        });
      } else {
        debugPrint(
            'Wallet not found: status=${response.statusCode}, body=${response.body}');
        setState(() {
          _error = "Wallet not found or deleted.";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching wallet: $e');
      setState(() {
        _error = "Failed to connect to server: $e";
        _isLoading = false;
      });
    }
  }

  /// When a fundraiser QR is scanned by another device we simply add the
  /// fixed default amount (100) to the wallet balance and save it. The old
  /// behaviour of deducting was for consumers; for fundraisers we always top up.
  Future<void> _processPayment() async {
    if (_scannedWallet == null) return;

    setState(() => _isLoading = true);
    const double addAmount = 100.0;

    try {
      final newBalance = _scannedWallet!.balance + addAmount;
      final globalUuid = widget.payload['uuid'];
      final walletId = widget.payload['walletId'];
      final url = Uri.parse(
          'https://virtuwal-8ba9b-default-rtdb.asia-southeast1.firebasedatabase.app/wallets/$globalUuid/$walletId.json');
      await http.patch(url, body: json.encode({'balance': newBalance}));

      // if the scanned wallet belongs to this device, update local state as well
      ref.read(walletsProvider.notifier).addBalance(walletId, addAmount);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Payment Successful'),
            content:
                Text('Added \$${addAmount.toStringAsFixed(2)} to the wallet'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // dialog
                  Navigator.pop(context); // screen
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Process Payment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 18)))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Fundraiser: ${_scannedWallet!.name}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                          'Current balance: \$${_scannedWallet!.balance.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green)),
                      const SizedBox(height: 30),
                      const Text(
                        'A default contribution of \$100 will be added when you '
                        'tap the button below.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _processPayment,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF6A3CE8),
                        ),
                        child: const Text('Contribute \$100',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      )
                    ],
                  ),
                ),
    );
  }
}
