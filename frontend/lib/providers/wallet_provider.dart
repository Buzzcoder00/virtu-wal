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
  final notifier = WalletsNotifier(fsService, ref);
  // When service changes (login/logout), trigger refetch or clear
  ref.listen(firebaseServiceProvider, (prev, next) {
    if (next != null && prev != next) {
      debugPrint('[walletsProvider] Service changed, refetching...');
      notifier._fetchWallets();
    } else if (next == null) {
      debugPrint('[walletsProvider] User logged out, clearing wallets');
      notifier.clearWallets();
    }
  });
  return notifier;
});

class WalletsNotifier extends StateNotifier<List<Wallet>> {
  final FirebaseService? firebaseService;
  final Ref ref;

  WalletsNotifier(this.firebaseService, this.ref) : super([]) {
    // whenever the service becomes available (user logs in) fetch wallets
    if (firebaseService != null) {
      debugPrint('[WalletsNotifier] Service available, fetching wallets...');
      _fetchWallets();
    } else {
      debugPrint('[WalletsNotifier] No service (user not logged in)');
    }
  }

  void clearWallets() {
    debugPrint('[WalletsNotifier] Clearing wallets on logout');
    state = [];
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
    // Only add after successful save to prevent duplicates
    try {
      debugPrint('[WalletsNotifier.addWallet] Saving wallet ${wallet.id}...');
      await firebaseService?.saveWallet(wallet);
      // Add to state only after successful save
      if (!state.any((w) => w.id == wallet.id)) {
        state = [wallet, ...state];
        debugPrint('[WalletsNotifier.addWallet] Wallet added successfully');
      }
    } catch (e) {
      debugPrint('[WalletsNotifier.addWallet] Error saving wallet: $e');
      rethrow;
    }
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
