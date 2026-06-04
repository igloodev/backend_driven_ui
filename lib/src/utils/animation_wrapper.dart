import 'package:flutter/material.dart';

/// Wraps any widget with an entry animation driven by the `animate` prop.
///
/// Accepts either a string shorthand (`"fadeIn"`) or a full config map:
/// ```json
/// "animate": {
///   "type": "slideUp",
///   "duration": 400,
///   "delay": 100,
///   "curve": "easeOut"
/// }
/// ```
///
/// Supported types: `fadeIn`, `slideUp`, `slideDown`, `slideLeft`,
/// `slideRight`, `scale`, `bounce`.
class AnimationWrapper extends StatefulWidget {
  const AnimationWrapper({
    super.key,
    required this.child,
    required this.animateProp,
  });

  final Widget child;
  final dynamic animateProp;

  @override
  State<AnimationWrapper> createState() => _AnimationWrapperState();
}

class _AnimationWrapperState extends State<AnimationWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Map<String, dynamic> _config;

  // Cached CurvedAnimations — created once in initState, disposed in dispose.
  // Creating them inside build() leaks one instance per frame.
  late final CurvedAnimation _curve;
  CurvedAnimation? _bounceCurve;

  @override
  void initState() {
    super.initState();
    _config = _parseConfig(widget.animateProp);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (_config['duration'] as num?)?.toInt() ?? 300,
      ),
    );
    _curve = CurvedAnimation(
      parent: _ctrl,
      curve: _parseCurve(_config['curve'] as String?),
    );
    // Pre-create bounce curve only when needed to avoid allocation on every build.
    if (_config['type'] == 'bounce') {
      _bounceCurve = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    }
    final delay = (_config['delay'] as num?)?.toInt() ?? 0;
    if (delay <= 0) {
      _ctrl.forward();
    } else {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _bounceCurve?.dispose();
    _curve.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  static Map<String, dynamic> _parseConfig(dynamic prop) {
    if (prop is String) return {'type': prop};
    if (prop is Map) return Map<String, dynamic>.from(prop);
    return {'type': 'fadeIn'};
  }

  static Curve _parseCurve(String? name) {
    switch (name) {
      case 'linear':
        return Curves.linear;
      case 'easeIn':
        return Curves.easeIn;
      case 'easeOut':
        return Curves.easeOut;
      case 'easeInOut':
        return Curves.easeInOut;
      case 'bounceIn':
        return Curves.bounceIn;
      case 'bounceOut':
        return Curves.bounceOut;
      case 'elasticIn':
        return Curves.elasticIn;
      case 'elasticOut':
        return Curves.elasticOut;
      case 'fastOutSlowIn':
        return Curves.fastOutSlowIn;
      default:
        return Curves.easeOut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _config['type'] as String? ?? 'fadeIn';

    switch (type) {
      case 'slideUp':
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_curve),
          child: FadeTransition(opacity: _curve, child: widget.child),
        );
      case 'slideDown':
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.3),
            end: Offset.zero,
          ).animate(_curve),
          child: FadeTransition(opacity: _curve, child: widget.child),
        );
      case 'slideLeft':
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(_curve),
          child: FadeTransition(opacity: _curve, child: widget.child),
        );
      case 'slideRight':
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.3, 0),
            end: Offset.zero,
          ).animate(_curve),
          child: FadeTransition(opacity: _curve, child: widget.child),
        );
      case 'scale':
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(_curve),
          child: FadeTransition(opacity: _curve, child: widget.child),
        );
      case 'bounce':
        return ScaleTransition(
          scale: Tween<double>(begin: 0.6, end: 1.0).animate(_bounceCurve!),
          child: widget.child,
        );
      case 'fadeIn':
      default:
        return FadeTransition(opacity: _curve, child: widget.child);
    }
  }
}
