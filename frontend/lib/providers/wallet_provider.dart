import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_service.dart';
import '../models/wallet.dart';
import 'auth_provider.dart';

final firebaseServiceProvider = Provider<FirebaseService?>((ref) {
  final user = ref.watch(firebaseUserProvider).maybeWhen(
        data: (u) => u,
        orElse: () => null,
      );
  if (user == null) return null;
  return FirebaseService(user.uid);
});

final walletsProvider =
    StateNotifierProvider<WalletsNotifier, List<Wallet>>((ref) {
  final fsService = ref.watch(firebaseServiceProvider);
  return WalletsNotifier(fsService);
});

class WalletsNotifier extends StateNotifier<List<Wallet>> {
  final FirebaseService? firebaseService;

  WalletsNotifier(this.firebaseService) : super([]) {
    // whenever the service becomes available (user logs in) fetch wallets
    if (firebaseService != null) {
      debugPrint('[WalletsNotifier] Service available, fetching wallets...');
      _fetchWallets();
    } else {
      debugPrint('[WalletsNotifier] No service (user not logged in)');
    }
  }

  Future<void> _fetchWallets() async {
    try {
      debugPrint('[WalletsNotifier._fetchWallets] Starting fetch...');
      final wallets = await firebaseService!.fetchWallets();
      debugPrint(
          '[WalletsNotifier._fetchWallets] Fetched ${wallets.length} wallets');
      state = wallets;
    } catch (e) {
      debugPrint('[WalletsNotifier._fetchWallets] Error: $e');
    }
  }

  Future<void> addWallet(Wallet wallet) async {
    state = [wallet, ...state];
    await firebaseService?.saveWallet(wallet);
  }

  Future<void> removeWallet(String walletId) async {
    state = state.where((w) => w.id != walletId).toList();
    await firebaseService?.deleteWallet(walletId);
  }

  /// Adds `amount` to the wallet's balance (used when someone pays into the
  /// fundraiser).
  Future<void> addBalance(String walletId, double amount) async {
    final walletIndex = state.indexWhere((w) => w.id == walletId);
    if (walletIndex != -1) {
      final wallet = state[walletIndex];
      if (wallet.status != WalletStatus.active)
        throw Exception('Wallet is ${wallet.status.name}');

      final updatedWallet = wallet.copyWith(balance: wallet.balance + amount);
      final updatedList = [...state];
      updatedList[walletIndex] = updatedWallet;
      state = updatedList;

      await firebaseService?.updateWalletBalance(
          walletId, updatedWallet.balance);
    }
  }
}
