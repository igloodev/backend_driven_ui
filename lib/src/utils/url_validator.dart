import '../core/bdui_config.dart';
import 'bdui_logger.dart';
// Platform-specific IP-literal check: dart:io InternetAddress on native,
// a pure-Dart stub on web.
import 'url_validator_stub.dart' if (dart.library.io) 'url_validator_io.dart';

/// URL validation utility to reduce SSRF attack surface.
///
/// **Limitation — DNS rebinding:** validation runs on the hostname string
/// before the request is made. A malicious hostname that resolves to a private
/// IP at request time (DNS rebinding) will pass this check. This is a
/// best-effort mitigation, not a complete SSRF defence. For stricter
/// environments, combine this with network-level controls (firewall rules,
/// egress proxies) that enforce IP restrictions at the socket layer.
class UrlValidator {
  /// Returns `true` if the URL is safe to request.
  ///
  /// Rejects private/loopback IPs, cloud metadata endpoints, and non-http(s)
  /// schemes. Can be disabled entirely via [BduiConfig.enableUrlValidation].
  static bool isUrlSafe(String url) {
    if (!BduiConfig.enableUrlValidation) {
      return true;
    }

    try {
      final uri = Uri.parse(url);

      // Must have valid scheme
      if (!BduiConfig.allowedUrlSchemes.contains(uri.scheme)) {
        BduiLogger.warn('URL rejected: invalid scheme "${uri.scheme}"');
        return false;
      }

      // Must have a host
      if (uri.host.isEmpty) {
        BduiLogger.warn('URL rejected: empty host');
        return false;
      }

      // Normalize host: strip IPv6 brackets so all downstream checks see the
      // bare address (Uri.parse usually does this, but be explicit).
      var host = uri.host.toLowerCase();
      if (host.startsWith('[') && host.endsWith(']')) {
        host = host.substring(1, host.length - 1);
      }

      // Block metadata endpoints first (string match)
      if (_isMetadataEndpoint(host)) {
        BduiLogger.warn('URL rejected: cloud metadata endpoint');
        return false;
      }

      // Try to parse as IP address for proper validation
      if (_isUnsafeHost(host)) {
        BduiLogger.warn('URL rejected: unsafe host (private/loopback)');
        return false;
      }

      return true;
    } catch (e) {
      BduiLogger.warn('URL validation failed: $e');
      return false;
    }
  }

  /// Check if host is unsafe (loopback or private)
  static bool _isUnsafeHost(String host) {
    // Remove brackets from IPv6
    var cleanHost = host;
    if (cleanHost.startsWith('[') && cleanHost.endsWith(']')) {
      cleanHost = cleanHost.substring(1, cleanHost.length - 1);
    }

    // Check for localhost hostname
    if (cleanHost == 'localhost') {
      return true;
    }

    // Platform IP-literal check: full IPv4/IPv6 private/loopback validation on
    // native (dart:io InternetAddress); a no-op on web (see stub).
    if (isPrivateOrLoopbackIp(cleanHost)) {
      return true;
    }

    // Pure-Dart fallback: manual IPv4 check (covers web and edge cases).
    if (_isPrivateIPv4String(cleanHost)) {
      return true;
    }

    return false;
  }

  /// Fallback IPv4 string check
  static bool _isPrivateIPv4String(String host) {
    final parts = host.split('.');
    if (parts.length != 4) return false;

    final octets = <int>[];
    for (final part in parts) {
      final octet = int.tryParse(part);
      if (octet == null || octet < 0 || octet > 255) return false;
      octets.add(octet);
    }

    final a = octets[0];
    final b = octets[1];

    if (a == 10) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    if (a == 192 && b == 168) return true;
    if (a == 169 && b == 254) return true;
    if (a == 127) return true;
    if (a == 0) return true;

    return false;
  }

  /// Check if host is a cloud metadata endpoint
  static bool _isMetadataEndpoint(String host) {
    const metadataHosts = {
      '169.254.169.254', // AWS, GCP, Azure
      'metadata.google.internal',
      'metadata.goog',
      '169.254.170.2', // ECS task metadata
      'fd00:ec2::254', // AWS IPv6 metadata
    };
    return metadataHosts.contains(host);
  }
}
