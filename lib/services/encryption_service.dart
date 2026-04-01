import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyAlias = 'lifeease_enc_key';

  Future<Encrypter> _getEncrypter() async {
    String? keyStr = await _storage.read(key: _keyAlias);
    if (keyStr == null) {
      final key = Key.fromSecureRandom(32);
      keyStr = key.base64;
      await _storage.write(key: _keyAlias, value: keyStr);
    }
    final key = Key.fromBase64(keyStr);
    return Encrypter(AES(key, mode: AESMode.cbc));
  }

  Future<String> encrypt(String plaintext) async {
    final enc = await _getEncrypter();
    final iv = IV.fromSecureRandom(16);
    final encrypted = enc.encrypt(plaintext, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  Future<String> decrypt(String ciphertext) async {
    final parts = ciphertext.split(':');
    if (parts.length != 2) {
      throw Exception(
          'Invalid ciphertext format: expected IV:encrypted, got ${parts.length} part(s)');
    }
    final enc = await _getEncrypter();
    final iv = IV.fromBase64(parts[0]);
    return enc.decrypt64(parts[1], iv: iv);
  }
}
