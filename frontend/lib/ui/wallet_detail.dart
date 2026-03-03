import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

import '../models/wallet.dart';
import '../services/signature_service.dart';
import '../providers/auth_provider.dart';

class WalletDetailScreen extends ConsumerWidget {
  final Wallet wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // use authenticated user's uid as global identifier
    final user = ref
        .watch(firebaseUserProvider)
        .maybeWhen(data: (u) => u, orElse: () => null);
    final deviceUuid = user?.uid ?? '';
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final payload = SignatureService.generateQrPayload(
      deviceUuid,
      wallet.id,
      wallet.amountLimit,
      wallet.expiryDate,
      wallet.signatureKey,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF6A3CE8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(wallet.name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Scan this code to pay',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              const SizedBox(height: 24),
              QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF3861FB),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF6A3CE8),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                currencyFormat.format(wallet.balance),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: Color(0xFF8E3CE8)),
              ),
              const Text('Raised so far', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                'Goal: ${currencyFormat.format(wallet.amountLimit)}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Expires at: ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(wallet.expiryDate))}',
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
