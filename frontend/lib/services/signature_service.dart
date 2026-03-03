import 'dart:convert';
import 'package:crypto/crypto.dart';

class SignatureService {
  // Generates HMAC-SHA256 signature encoded as Base64 JSON payload
  static String generateQrPayload(
      String globalUuid, String walletId, double amountLimit, int expiryDate, String signatureKey) {
    final Map<String, dynamic> data = {
      'uuid': globalUuid,
      'walletId': walletId,
      'amountLimit': amountLimit,
      'expiryDate': expiryDate,
    };

    final message = json.encode(data);
    final keyBytes = utf8.encode(signatureKey);
    final messageBytes = utf8.encode(message);

    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(messageBytes);

    data['signature'] = digest.toString();
    return base64Encode(utf8.encode(json.encode(data)));
  }

  // Verifies HMAC-SHA256 signature
  static bool verifySignature(Map<String, dynamic> payload, String signatureKey) {
    if (!payload.containsKey('signature')) return false;
    final providedSignature = payload['signature'];

    final Map<String, dynamic> dataToVerify = {
      'uuid': payload['uuid'],
      'walletId': payload['walletId'],
      'amountLimit': payload['amountLimit'],
      'expiryDate': payload['expiryDate'],
    };

    final message = json.encode(dataToVerify);
    final keyBytes = utf8.encode(signatureKey);
    final messageBytes = utf8.encode(message);

    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(messageBytes);

    return digest.toString() == providedSignature;
  }
}
