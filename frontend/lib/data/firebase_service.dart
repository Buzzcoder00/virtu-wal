import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/wallet.dart';

class FirebaseService {
  // real-time database base URL – use your project link (asia-southeast1 endpoint)
  final String _dbUrl =
      'https://virtuwal-8ba9b-default-rtdb.asia-southeast1.firebasedatabase.app/wallets';
  final String _userId;

  // userId is the Firebase Auth UID of the signed-in user
  FirebaseService(this._userId);

  String _userBasePath() => '$_dbUrl/$_userId';

  Future<List<Wallet>> fetchWallets() async {
    final url = Uri.parse('${_userBasePath()}.json');
    debugPrint('[FirebaseService] Fetching wallets from: $url');
    try {
      final response = await http.get(url);
      debugPrint('[FirebaseService] Response status: ${response.statusCode}');
      debugPrint('[FirebaseService] Response body: ${response.body}');

      if (response.statusCode == 200 && response.body != 'null') {
        final Map<String, dynamic> data = json.decode(response.body);
        final wallets = data.values
            .map((w) => Wallet.fromJson(Map<String, dynamic>.from(w)))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        debugPrint('[FirebaseService] Fetched ${wallets.length} wallets');
        return wallets;
      } else {
        debugPrint('[FirebaseService] No wallets found or empty response');
        return [];
      }
    } catch (e, stack) {
      debugPrint('[FirebaseService] Error fetching wallets: $e');
      debugPrint('[FirebaseService] Stack: $stack');
      return [];
    }
  }

  Future<void> saveWallet(Wallet wallet) async {
    final url = Uri.parse('${_userBasePath()}/${wallet.id}.json');
    debugPrint('[FirebaseService] Saving wallet: ${wallet.id} to: $url');
    try {
      final response = await http.put(
        url,
        body: json.encode(wallet.toJson()),
      );
      debugPrint(
          '[FirebaseService] Wallet saved. Status: ${response.statusCode}');
    } catch (e) {
      debugPrint('[FirebaseService] Error saving wallet: $e');
    }
  }

  Future<void> updateWalletBalance(String walletId, double newBalance) async {
    final url = Uri.parse('${_userBasePath()}/$walletId.json');
    try {
      await http.patch(
        url,
        body: json.encode({'balance': newBalance}),
      );
    } catch (e) {
      print('Error updating wallet balance: $e');
    }
  }

  Future<void> deleteWallet(String walletId) async {
    final url = Uri.parse('${_userBasePath()}/$walletId.json');
    try {
      await http.delete(url);
    } catch (e) {
      print('Error deleting wallet: $e');
    }
  }

  // Allow anyone to fetch a specific wallet using global endpoint if needed
  // This is used when scanning a QR code made by another user (simulated)
  Future<Wallet?> fetchWalletById(String globalUuid, String walletId) async {
    final url = Uri.parse(
        '$_dbUrl/$globalUuid/$walletId.json'); // global access still same
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body);
        return Wallet.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      print('Error fetching wallet by ID: $e');
    }
    return null;
  }
}
