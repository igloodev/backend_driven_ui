import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Safely convert a dynamic value to a String-keyed Map.
/// Returns null if conversion fails.
Map<String, dynamic>? toStringKeyedMap(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    try {
      return Map<String, dynamic>.from(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// Evaluate condition strings for conditional rendering/actions.
///
/// Supports:
/// - Boolean: 'true', 'false'
/// - Platform: 'isAndroid', 'isIOS', 'isMobile', 'isWeb', 'isDesktop'
/// - Screen: 'isSmallScreen', 'isMediumScreen', 'isLargeScreen'
/// - Theme: 'isDarkMode', 'isLightMode'
bool evaluateCondition(String condition, BuildContext context) {
  // Normalize
  final cond = condition.trim().toLowerCase();

  // Boolean
  if (cond == 'true') return true;
  if (cond == 'false') return false;

  // Platform checks
  final platform = Theme.of(context).platform;

  if (cond == 'isandroid') {
    return platform == TargetPlatform.android;
  }
  if (cond == 'isios') {
    return platform == TargetPlatform.iOS;
  }
  if (cond == 'ismobile') {
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }
  if (cond == 'isweb') {
    return kIsWeb;
  }
  if (cond == 'isdesktop') {
    return !kIsWeb &&
        (platform == TargetPlatform.linux ||
            platform == TargetPlatform.macOS ||
            platform == TargetPlatform.windows);
  }

  // Screen size checks
  final width = MediaQuery.of(context).size.width;
  if (cond == 'issmallscreen') return width < 600;
  if (cond == 'ismediumscreen') return width >= 600 && width < 1200;
  if (cond == 'islargescreen') return width >= 1200;

  // Theme checks
  final brightness = Theme.of(context).brightness;
  if (cond == 'isdarkmode') return brightness == Brightness.dark;
  if (cond == 'islightmode') return brightness == Brightness.light;

  // Unknown condition - default false
  return false;
}
