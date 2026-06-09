import 'dart:convert';

/// Possible outcomes of client-side QR payload validation.
enum QrValidationResult { valid, expired, malformed, unauthorized }

/// Client-side QR payload validation utility.
///
/// Supports two formats:
///   • Mock  – `SGUARD.SL.{hash}.{unixTimestampSeconds}`
///   • Real  – a standard JWT (header.payload.signature) carrying an `exp` claim.
///
/// In production the server performs authoritative validation; this is a
/// lightweight early-exit guard used on the scanner screen.
abstract final class QrValidator {
  QrValidator._();

  /// Validates [payload] and returns the appropriate [QrValidationResult].
  static QrValidationResult validateQrPayload(String payload) {
    if (payload.trim().isEmpty) return QrValidationResult.malformed;

    // Try mock format first: SGUARD.SL.{hash}.{timestamp}
    if (payload.startsWith('SGUARD.')) {
      return _validateMockPayload(payload);
    }

    // Try real JWT format: header.payload.signature
    final parts = payload.split('.');
    if (parts.length == 3) {
      return _validateJwtPayload(parts);
    }

    return QrValidationResult.malformed;
  }

  // ---------------------------------------------------------------------------
  // Mock format  →  SGUARD.SL.{hash}.{unixTimestampSeconds}
  // ---------------------------------------------------------------------------
  static QrValidationResult _validateMockPayload(String payload) {
    final parts = payload.split('.');
    // Expect exactly 4 segments: SGUARD | SL | hash | timestamp
    if (parts.length != 4) return QrValidationResult.malformed;

    final prefix = parts[0]; // 'SGUARD'
    final type = parts[1]; // 'SL'
    final hash = parts[2]; // non-empty hash string
    final tsRaw = parts[3]; // unix timestamp as string

    if (prefix != 'SGUARD') return QrValidationResult.unauthorized;
    if (type != 'SL') return QrValidationResult.unauthorized;
    if (hash.isEmpty) return QrValidationResult.malformed;

    final ts = int.tryParse(tsRaw);
    if (ts == null) return QrValidationResult.malformed;

    final expiry = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);
    if (DateTime.now().toUtc().isAfter(expiry)) {
      return QrValidationResult.expired;
    }

    return QrValidationResult.valid;
  }

  // ---------------------------------------------------------------------------
  // Real JWT  →  header.payload.signature
  // ---------------------------------------------------------------------------
  static QrValidationResult _validateJwtPayload(List<String> parts) {
    try {
      // Decode the payload (middle segment), padding as needed for base64url.
      final payloadB64 = _padBase64(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payloadB64));
      final Map<String, dynamic> claims =
          json.decode(decoded) as Map<String, dynamic>;

      // Check issuer / audience if present
      final iss = claims['iss'] as String?;
      if (iss != null && iss != 'sguard') {
        return QrValidationResult.unauthorized;
      }

      // Check expiry (`exp` claim is seconds since epoch)
      final exp = claims['exp'];
      if (exp == null) return QrValidationResult.malformed;

      final expInt = exp is int ? exp : int.tryParse(exp.toString());
      if (expInt == null) return QrValidationResult.malformed;

      final expiry = DateTime.fromMillisecondsSinceEpoch(
        expInt * 1000,
        isUtc: true,
      );
      if (DateTime.now().toUtc().isAfter(expiry)) {
        return QrValidationResult.expired;
      }

      return QrValidationResult.valid;
    } catch (_) {
      return QrValidationResult.malformed;
    }
  }

  static String _padBase64(String s) {
    final mod = s.length % 4;
    if (mod == 0) return s;
    return s + '=' * (4 - mod);
  }
}
