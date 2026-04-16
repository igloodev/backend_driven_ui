/// Backend-Driven UI Framework for Flutter
///
/// Server-Driven UI framework with ApiWidget - build data-driven interfaces
/// without FutureBuilder boilerplate.
///
/// ## Features
/// - 🎯 Update UIs from your backend
/// - ⚡ Instant app updates without app store reviews
/// - 🔓 100% open source, MIT licensed
/// - 📦 Built-in caching, retry, and error handling
/// - 🚀 ApiWidget - FutureBuilder's better alternative
///
/// ## Quick Start
///
/// ```dart
/// ApiWidget(
///   endpoint: '/api/products',
///   loading: ShimmerLoader(),
///   success: (data) => ProductList(data),
///   error: (e) => ErrorCard(e),
/// )
/// ```
library;

// Core
export 'src/core/api_client.dart';
export 'src/core/bdui_http_client.dart';
export 'src/core/bdui_config.dart';

// Models
export 'src/models/api_request.dart';
export 'src/models/api_response.dart';
export 'src/models/api_exception.dart';
export 'src/models/cache_control.dart';
export 'src/models/http_method.dart';
export 'src/models/widget_schema.dart';
export 'src/models/action_schema.dart';

// Widgets
export 'src/widgets/api_widget.dart';
export 'src/widgets/backend_driven_screen.dart';
export 'src/widgets/schema_widget.dart';

// Registry (for custom widget registration)
export 'src/registry/widget_registry.dart';

// Handlers (for custom action handling)
export 'src/handlers/action_handler.dart';

// Parser (for advanced usage)
export 'src/parser/schema_parser.dart';
