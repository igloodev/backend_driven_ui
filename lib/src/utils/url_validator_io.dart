import 'dart:io';

/// Native (`dart:io`) check: is [host] an IP literal in a private, loopback,
/// link-local, or unspecified range?
///
/// Returns `false` for non-IP hosts — hostname-based checks (localhost, cloud
/// metadata) are handled by the caller. Used via a conditional import so web
/// builds get the pure-Dart stub instead (see `url_validator_stub.dart`).
bool isPrivateOrLoopbackIp(String host) {
  final address = InternetAddress.tryParse(host);
  if (address == null) return false;
  if (address.isLoopback) return true;

  final bytes = address.rawAddress;

  if (address.type == InternetAddressType.IPv4 && bytes.length == 4) {
    if (bytes[0] == 10) return true; // 10.0.0.0/8
    if (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) return true; // /12
    if (bytes[0] == 192 && bytes[1] == 168) return true; // 192.168.0.0/16
    if (bytes[0] == 169 && bytes[1] == 254) return true; // link-local
    if (bytes[0] == 127) return true; // loopback
    if (bytes[0] == 0) return true; // 0.0.0.0/8
  }

  if (address.type == InternetAddressType.IPv6 && bytes.length == 16) {
    if (bytes[0] == 0xfc || bytes[0] == 0xfd) {
      return true; // fc00::/7 unique-local
    }
    if (bytes[0] == 0xfe && (bytes[1] & 0xc0) == 0x80) return true; // fe80::/10
    var allZeros = true;
    for (var i = 0; i < 15; i++) {
      if (bytes[i] != 0) {
        allZeros = false;
        break;
      }
    }
    if (allZeros && bytes[15] == 1) return true; // ::1 loopback
    if (bytes.every((b) => b == 0)) return true; // :: unspecified
    if (bytes[10] == 0xff && bytes[11] == 0xff) {
      // IPv4-mapped (::ffff:0:0/96) — validate the embedded IPv4.
      if (bytes[12] == 10) return true;
      if (bytes[12] == 172 && bytes[13] >= 16 && bytes[13] <= 31) return true;
      if (bytes[12] == 192 && bytes[13] == 168) return true;
      if (bytes[12] == 169 && bytes[13] == 254) return true;
      if (bytes[12] == 127) return true;
      if (bytes[12] == 0) return true;
    }
  }

  return false;
}
