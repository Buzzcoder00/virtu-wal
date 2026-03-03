import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/wallet_provider.dart';
import '../models/wallet.dart';
import 'widgets/bottom_nav.dart';
import 'wallet_detail.dart';

class GenerateQRScreen extends ConsumerStatefulWidget {
  const GenerateQRScreen({super.key});

  @override
  ConsumerState<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends ConsumerState<GenerateQRScreen> {
  double _durationMinutes = 5;
  Wallet? _selectedWallet;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallets = ref.read(walletsProvider);
      if (wallets.isNotEmpty) {
        setState(() {
          _selectedWallet = wallets.first;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    if (_selectedWallet == null && wallets.isNotEmpty) {
      _selectedWallet = wallets.first;
    }
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Generate QR Code',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Selected Wallet or Dropdown
                GestureDetector(
                  onTap: () {
                    // Could show bottom sheet to select wallet
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDFF),
                      border: Border.all(
                          color: const Color(0xFF8E3CE8), width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedWallet?.name ?? 'Select Wallet',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedWallet != null
                                  ? currencyFormat
                                      .format(_selectedWallet!.balance)
                                  : '-',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const Icon(Icons.check_circle,
                            color: Color(0xFF8E3CE8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Tabs
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F5FF),
                          border: Border.all(color: const Color(0xFF8E3CE8)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.timer_outlined,
                                color: Color(0xFF8E3CE8), size: 32),
                            SizedBox(height: 8),
                            Text('Time Limit',
                                style: TextStyle(
                                    color: Color(0xFF8E3CE8),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.attach_money,
                                color: Colors.grey, size: 32),
                            SizedBox(height: 8),
                            Text('Amount Limit',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Slider Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Duration (minutes)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: _durationMinutes,
                        min: 1,
                        max: 60,
                        activeColor: const Color(0xFF6A3CE8),
                        inactiveColor: Colors.grey[200],
                        onChanged: (val) {
                          setState(() {
                            _durationMinutes = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${_durationMinutes.toInt()} minutes',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Color(0xFF6A3CE8)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'QR expires automatically when time runs out.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _selectedWallet == null
                      ? null
                      : () {
                          final updatedWallet = _selectedWallet!.copyWith(
                              expiryDate:
                                  DateTime.now().millisecondsSinceEpoch +
                                      (_durationMinutes.toInt() * 60 * 1000));
                          ref.read(walletsProvider.notifier).addWallet(
                              updatedWallet); // Re-save with new limit
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => WalletDetailScreen(
                                      wallet: updatedWallet)));
                        },
                  icon: const Icon(Icons.qr_code, color: Colors.white),
                  label: const Text('Generate QR Code',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E3CE8),
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const BottomNavBar(currentIndex: 1),
          ),
        ],
      ),
    );
  }
}
