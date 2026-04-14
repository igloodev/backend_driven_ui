import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api_client.dart';
import '../core/bdui_config.dart';
import '../models/action_schema.dart';
import '../utils/helpers.dart';
import '../utils/bdui_logger.dart';
import '../utils/url_validator.dart';

/// Callback for custom action handling
typedef CustomActionCallback = Future<void> Function(String name, Map<String, dynamic>? params);

/// Callback for navigation - allows app to override default navigation
typedef NavigationCallback = Future<void> Function(String route, Map<String, dynamic>? arguments);

/// Callback for URL launching - wire in url_launcher or any custom handler.
///
/// Example:
/// ```dart
/// onLaunchUrl: (url) async {
///   if (await canLaunchUrl(Uri.parse(url))) {
///     await launchUrl(Uri.parse(url));
///   }
/// }
/// ```
typedef LaunchUrlCallback = Future<void> Function(String url);

/// Callback for API responses
typedef ApiCallback = void Function(String endpoint, dynamic data);

/// Callback for API errors
typedef ApiErrorCallback = void Function(String endpoint, String error);

/// Centralized action executor for backend-driven UI
///
/// Supports all action types:
/// - navigate, pop, replace, popUntil
/// - showSnackBar, showDialog, showBottomSheet
/// - api (GET, POST, PUT, DELETE)
/// - sequence, conditional
/// - launchUrl, copy, share
/// - custom
class ActionHandler {
  /// The Flutter [BuildContext] used for navigation, dialogs, and snackbars.
  final BuildContext context;

  /// Called when a `navigate` action is triggered. Receives the route name
  /// and optional arguments map.
  final NavigationCallback? onNavigate;

  /// Called when a `launchUrl` action is triggered. Wire in `url_launcher`
  /// or any custom handler — the package has no direct dependency on it.
  final LaunchUrlCallback? onLaunchUrl;

  /// Called after a successful `api` action. Receives the endpoint and
  /// the parsed response data.
  final ApiCallback? onApiSuccess;

  /// Called when an `api` action fails. Receives the endpoint and the
  /// error message string.
  final ApiErrorCallback? onApiError;

  /// Called when a `custom` action is triggered. Receives the action name
  /// and optional params map.
  final CustomActionCallback? onCustomAction;

  /// Creates an [ActionHandler] with the given [context] and optional
  /// callbacks for navigation, URL launching, API results, and custom actions.
  ActionHandler({
    required this.context,
    this.onNavigate,
    this.onLaunchUrl,
    this.onApiSuccess,
    this.onApiError,
    this.onCustomAction,
  });

  /// Check if context is still valid (widget not unmounted)
  bool get _isContextMounted => context.mounted;

  /// Validate URL for security - prevents SSRF attacks
  ///
  /// Delegates to [UrlValidator.isUrlSafe].
  static bool isUrlSafe(String url) => UrlValidator.isUrlSafe(url);

  /// Execute an action from a Map (raw JSON)
  ///
  /// Handles invalid action schemas gracefully by logging errors.
  Future<void> executeFromMap(Map<String, dynamic> actionMap) async {
    try {
      final action = ActionSchema.fromJson(actionMap);
      await execute(action);
    } on ArgumentError catch (e) {
      BduiLogger.error('ActionHandler: Invalid action schema - ${e.message}');
    } catch (e) {
      BduiLogger.error('ActionHandler: Error parsing action - $e');
    }
  }

  /// Execute an ActionSchema
  /// [depth] tracks nesting level to prevent infinite recursion
  Future<void> execute(ActionSchema action, {int depth = 0}) async {
    // Safety check: prevent infinite recursion
    if (depth > BduiConfig.maxActionDepth) {
      BduiLogger.warn('ActionHandler: Max action depth (${BduiConfig.maxActionDepth}) exceeded, stopping execution');
      return;
    }

    // Safety check: don't execute if context is no longer valid
    if (!_isContextMounted) {
      BduiLogger.warn('ActionHandler: Context no longer mounted, skipping action ${action.type}');
      return;
    }

    try {
      switch (action.type) {
        // Navigation actions
        case 'navigate':
          await _handleNavigate(action);
          break;
        case 'pop':
          _handlePop(action);
          break;
        case 'replace':
          await _handleReplace(action);
          break;
        case 'popUntil':
          _handlePopUntil(action);
          break;

        // UI feedback actions
        case 'showSnackBar':
          _handleShowSnackBar(action);
          break;
        case 'showDialog':
          await _handleShowDialog(action);
          break;
        case 'showBottomSheet':
          await _handleShowBottomSheet(action);
          break;

        // API actions
        case 'api':
          await _handleApi(action, depth);
          break;

        // Utility actions
        case 'launchUrl':
          await _handleLaunchUrl(action);
          break;
        case 'copy':
          await _handleCopy(action);
          break;
        case 'share':
          await _handleShare(action);
          break;

        // Control flow actions
        case 'sequence':
          await _handleSequence(action, depth);
          break;
        case 'conditional':
          await _handleConditional(action, depth);
          break;

        // Custom actions
        case 'custom':
          await _handleCustom(action);
          break;

        default:
          BduiLogger.warn('Unknown action type: ${action.type}');
      }

      // Execute onSuccess if defined and no error occurred
      if (action.onSuccess != null) {
        await execute(action.onSuccess!, depth: depth + 1);
      }
    } catch (e) {
      BduiLogger.error('Error executing action ${action.type}: $e');
      if (action.onError != null) {
        await execute(action.onError!, depth: depth + 1);
      }
    }
  }

  // ============ Navigation Actions ============

  Future<void> _handleNavigate(ActionSchema action) async {
    final route = action.route ?? action.params?['route'] as String?;
    if (route == null) {
      BduiLogger.warn('Navigate action requires route parameter');
      return;
    }

    final arguments = toStringKeyedMap(action.params?['arguments']);

    if (onNavigate != null) {
      await onNavigate!(route, arguments);
    } else if (_isContextMounted) {
      Navigator.of(context).pushNamed(route, arguments: arguments);
    }
  }

  void _handlePop(ActionSchema action) {
    if (!_isContextMounted) return;
    final navigator = Navigator.of(context);
    if (!navigator.canPop()) {
      BduiLogger.warn('Pop action: No routes to pop');
      return;
    }
    navigator.pop(action.params?['result']);
  }

  Future<void> _handleReplace(ActionSchema action) async {
    final route = action.route ?? action.params?['route'] as String?;
    if (route == null) {
      BduiLogger.warn('Replace action requires route parameter');
      return;
    }

    final arguments = toStringKeyedMap(action.params?['arguments']);

    if (onNavigate != null) {
      await onNavigate!(route, arguments);
    } else if (_isContextMounted) {
      Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
    }
  }

  void _handlePopUntil(ActionSchema action) {
    if (!_isContextMounted) return;

    final navigator = Navigator.of(context);
    final route = action.route ?? action.params?['route'] as String?;

    if (route == null) {
      navigator.popUntil((r) => r.isFirst);
    } else {
      navigator.popUntil(ModalRoute.withName(route));
    }
  }

  // ============ UI Feedback Actions ============

  void _handleShowSnackBar(ActionSchema action) {
    if (!_isContextMounted) return;

    final message = action.params?['message'] as String? ?? '';
    final duration = Duration(
      milliseconds: action.params?['duration'] as int? ?? 3000,
    );
    final actionLabel = action.params?['actionLabel'] as String?;
    final actionAction = toStringKeyedMap(action.params?['action']);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: () {
                  if (actionAction != null) {
                    executeFromMap(actionAction);
                  }
                },
              )
            : null,
      ),
    );
  }

  Future<void> _handleShowDialog(ActionSchema action) async {
    if (!_isContextMounted) return;

    final title = action.params?['title'] as String? ?? '';
    final message = action.params?['message'] as String? ?? '';
    final confirmText = action.params?['confirmText'] as String? ?? 'OK';
    final cancelText = action.params?['cancelText'] as String?;
    final confirmAction = toStringKeyedMap(action.params?['onConfirm']);
    final cancelAction = toStringKeyedMap(action.params?['onCancel']);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: action.params?['dismissible'] as bool? ?? true,
      builder: (ctx) => AlertDialog(
        title: title.isNotEmpty ? Text(title) : null,
        content: Text(message),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    // Check context after async operation
    if (!_isContextMounted) return;

    if (result == true && confirmAction != null && _isContextMounted) {
      await executeFromMap(confirmAction);
    } else if (result == false && cancelAction != null && _isContextMounted) {
      await executeFromMap(cancelAction);
    }
  }

  Future<void> _handleShowBottomSheet(ActionSchema action) async {
    if (!_isContextMounted) return;

    final title = action.params?['title'] as String?;
    final message = action.params?['message'] as String? ?? '';
    final actions = action.params?['actions'] as List?;

    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(message),
              ),
            if (actions != null)
              ...actions.map((a) {
                final actionMap = toStringKeyedMap(a);
                if (actionMap == null) return const SizedBox.shrink();
                return ListTile(
                  leading: actionMap['icon'] != null
                      ? Icon(_getIconData(actionMap['icon'].toString()))
                      : null,
                  title: Text(actionMap['label']?.toString() ?? ''),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    final nestedAction = toStringKeyedMap(actionMap['action']);
                    if (nestedAction != null) {
                      executeFromMap(nestedAction);
                    }
                  },
                );
              }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ============ API Actions ============

  Future<void> _handleApi(ActionSchema action, int depth) async {
    final endpoint = action.endpoint ?? action.params?['endpoint'] as String?;
    if (endpoint == null) {
      BduiLogger.warn('API action requires endpoint parameter');
      return;
    }

    final method = (action.method ?? action.params?['method'] as String? ?? 'GET')
        .toUpperCase();

    try {
      final response = await _makeApiCall(method, endpoint, action);

      // Call API success callback if registered
      if (onApiSuccess != null) {
        onApiSuccess!(endpoint, response.data);
      }
      // Note: onSuccess action is handled by execute() method, not here
    } catch (e) {
      final errorMessage = e.toString();

      // Call API error callback if registered
      if (onApiError != null) {
        onApiError!(endpoint, errorMessage);
      }

      // Show default error snackbar if no onError action defined
      if (action.onError == null) {
        _handleShowSnackBar(ActionSchema(
          type: 'showSnackBar',
          params: {'message': 'Request failed: $errorMessage'},
        ));
      }

      // Re-throw so execute() can handle onError action
      rethrow;
    }
  }

  Future<dynamic> _makeApiCall(
    String method,
    String endpoint,
    ActionSchema action,
  ) async {
    final headers = action.params?['headers'] as Map<String, dynamic>?;
    final Map<String, String>? stringHeaders = headers?.map(
      (k, v) => MapEntry(k, v.toString()),
    );

    switch (method) {
      case 'GET':
        return await ApiClient.get(endpoint, headers: stringHeaders);
      case 'POST':
        return await ApiClient.post(endpoint, body: action.body, headers: stringHeaders);
      case 'PUT':
        return await ApiClient.put(endpoint, body: action.body, headers: stringHeaders);
      case 'DELETE':
        return await ApiClient.delete(endpoint, headers: stringHeaders);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // ============ Utility Actions ============

  Future<void> _handleLaunchUrl(ActionSchema action) async {
    final url = action.params?['url'] as String?;
    if (url == null) {
      BduiLogger.warn('LaunchUrl action requires url parameter');
      return;
    }

    // Security: Validate URL before launching
    if (!isUrlSafe(url)) {
      BduiLogger.warn('LaunchUrl blocked: URL failed security validation');
      if (_isContextMounted) {
        _handleShowSnackBar(const ActionSchema(
          type: 'showSnackBar',
          params: {'message': 'Cannot open this URL for security reasons'},
        ));
      }
      return;
    }

    if (onLaunchUrl != null) {
      await onLaunchUrl!(url);
    } else {
      // No handler registered — app must provide onLaunchUrl to open URLs.
      // Wire in url_launcher or any custom implementation via ActionHandler.onLaunchUrl.
      BduiLogger.warn(
        'LaunchUrl: no onLaunchUrl handler registered. '
        'Provide onLaunchUrl in ActionHandler to open URLs.',
      );
    }
  }

  Future<void> _handleCopy(ActionSchema action) async {
    final text = action.params?['text'] as String?;
    if (text == null) {
      BduiLogger.warn('Copy action requires text parameter');
      return;
    }

    await Clipboard.setData(ClipboardData(text: text));

    final showFeedback = action.params?['showFeedback'] as bool? ?? true;
    if (showFeedback) {
      _handleShowSnackBar(ActionSchema(
        type: 'showSnackBar',
        params: {'message': action.params?['feedbackMessage'] as String? ?? 'Copied to clipboard'},
      ));
    }
  }

  Future<void> _handleShare(ActionSchema action) async {
    final text = action.params?['text'] as String?;
    if (text == null) {
      BduiLogger.warn('Share action requires text parameter');
      return;
    }

    // Note: In a real app, use share_plus package
    // For now, we'll copy to clipboard as fallback
    await Clipboard.setData(ClipboardData(text: text));
    _handleShowSnackBar(const ActionSchema(
      type: 'showSnackBar',
      params: {'message': 'Content copied for sharing'},
    ));
  }

  // ============ Control Flow Actions ============

  Future<void> _handleSequence(ActionSchema action, int depth) async {
    if (action.actions == null || action.actions!.isEmpty) {
      BduiLogger.warn('Sequence action requires actions list');
      return;
    }

    for (final subAction in action.actions!) {
      await execute(subAction, depth: depth + 1);
    }
  }

  Future<void> _handleConditional(ActionSchema action, int depth) async {
    if (action.condition == null) {
      BduiLogger.warn('Conditional action requires condition parameter');
      return;
    }

    final shouldExecute = evaluateCondition(action.condition!, context);

    if (shouldExecute && action.thenAction != null) {
      await execute(action.thenAction!, depth: depth + 1);
    } else if (!shouldExecute && action.elseAction != null) {
      await execute(action.elseAction!, depth: depth + 1);
    }
  }

  // ============ Custom Actions ============

  Future<void> _handleCustom(ActionSchema action) async {
    final name = action.params?['name'] as String? ?? 'unknown';
    if (onCustomAction != null) {
      await onCustomAction!(name, action.params);
    } else {
      BduiLogger.warn('Custom action "$name" called but no handler registered');
    }
  }

  // ============ Helpers ============

  /// Get icon data by name
  IconData _getIconData(String name) => _iconMap[name] ?? Icons.help_outline;

  /// Static icon map for performance (avoid recreating on each call)
  static const Map<String, IconData> _iconMap = {
    'share': Icons.share,
    'copy': Icons.copy,
    'delete': Icons.delete,
    'edit': Icons.edit,
    'info': Icons.info,
    'settings': Icons.settings,
    'close': Icons.close,
    'check': Icons.check,
    'add': Icons.add,
    'remove': Icons.remove,
    'favorite': Icons.favorite,
    'star': Icons.star,
    'home': Icons.home,
    'person': Icons.person,
    'email': Icons.email,
    'phone': Icons.phone,
    'message': Icons.message,
    'camera': Icons.camera_alt,
    'image': Icons.image,
    'file': Icons.insert_drive_file,
    'folder': Icons.folder,
    'download': Icons.download,
    'upload': Icons.upload,
    'link': Icons.link,
    'lock': Icons.lock,
    'unlock': Icons.lock_open,
  };
}
