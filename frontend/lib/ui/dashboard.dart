import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/wallet_provider.dart';
import '../models/wallet.dart';
import 'widgets/bottom_nav.dart';
import 'manage_wallets.dart';
import 'scan_qr.dart';
import 'profile_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);
    final totalTemp = wallets
        .where((w) => w.status == WalletStatus.active)
        .fold(0.0, (sum, w) => sum + w.balance);
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient at top
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8E3CE8), Color(0xFF3861FB)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TempVal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfileScreen()));
                        },
                        child: const Icon(Icons.settings_outlined,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView(
                      children: [
                        // Main Account Card
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A3CE8), Color(0xFF3861FB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3861FB).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: Colors.white70,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Main Account',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '\$5,420.50',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Available balance',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Temporary Wallets Section Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.security,
                                    color: Color(0xFF9E5C20)),
                                const SizedBox(width: 8),
                                Text(
                                  'Temporary Wallets',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontSize: 18),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ManageWalletsScreen()));
                              },
                              icon: const Icon(Icons.add,
                                  size: 16, color: Color(0xFF6A3CE8)),
                              label: const Text('Manage',
                                  style: TextStyle(
                                      color: Color(0xFF6A3CE8),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Total Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF5),
                            border: Border.all(
                                color: const Color(0xFFFFD54F), width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total in Temporary Wallets',
                                  style: TextStyle(
                                      color: Colors.brown[600],
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(totalTemp),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.brown[800],
                                      fontSize: 28,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Wallets List
                        if (wallets.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                                child: Text("No temporary wallets found.",
                                    style: TextStyle(color: Colors.grey[600]))),
                          )
                        else
                          ...wallets
                              .where((w) => w.status == WalletStatus.active)
                              .take(3)
                              .map((w) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(20),
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        w.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        currencyFormat.format(w.balance),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                color: const Color(0xFF6A3CE8),
                                                fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.grey),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ManageWalletsScreen()));
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Add New Wallet',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E3CE8),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 100), // padding for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const BottomNavBar(currentIndex: 0),
          ),
          Positioned(
            // lift the button higher than before so it doesn’t obscure the
            // "Generate" item in the bottom navigation bar.
            bottom: 70,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ScanQRScreen()));
              },
              backgroundColor: const Color(0xFF3861FB),
              shape: const CircleBorder(),
              child: const Icon(Icons.qr_code_scanner,
                  color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
