import 'package:uuid/uuid.dart';

enum WalletStatus { active, expired, limitReached }

class Wallet {
  final String id;
  final String name;
  final double amountLimit;
  final double balance;
  final int expiryDate;
  final int createdAt;
  final String signatureKey;

  Wallet({
    required this.id,
    required this.name,
    required this.amountLimit,
    required this.balance,
    required this.expiryDate,
    required this.createdAt,
    required this.signatureKey,
  });

  /// Creates a wallet initialized for fundraising.
  ///
  /// The new wallet starts with a zero balance (since funds are raised via
  /// payments) and you can optionally specify a target/limit (defaults to 100).
  factory Wallet.create({
    required String name,
    double amountLimit = 100.0,
    required int durationMinutes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Wallet(
      id: const Uuid().v4(),
      name: name,
      amountLimit: amountLimit,
      balance: 0.0, // start empty for a fundraiser
      expiryDate: now + (durationMinutes * 60 * 1000),
      createdAt: now,
      signatureKey: const Uuid().v4(), // random secret for signatures
    );
  }

  WalletStatus get status {
    // fundraiser wallets start at 0 so treat zero as active rather than
    // limitReached. only negative balances are invalid.
    if (balance < 0) return WalletStatus.limitReached;
    if (DateTime.now().millisecondsSinceEpoch > expiryDate)
      return WalletStatus.expired;
    return WalletStatus.active;
  }

  Wallet copyWith({
    String? id,
    String? name,
    double? amountLimit,
    double? balance,
    int? expiryDate,
    int? createdAt,
    String? signatureKey,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      amountLimit: amountLimit ?? this.amountLimit,
      balance: balance ?? this.balance,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      signatureKey: signatureKey ?? this.signatureKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amountLimit': amountLimit,
      'balance': balance,
      'expiryDate': expiryDate,
      'createdAt': createdAt,
      'signatureKey': signatureKey,
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      name: json['name'] as String,
      amountLimit: (json['amountLimit'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      expiryDate: json['expiryDate'] as int,
      createdAt: json['createdAt'] as int,
      signatureKey: json['signatureKey'] as String,
    );
  }
}
