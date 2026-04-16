# Changelog

All notable changes to this project will be documented in this file.

## [0.3.0] - 2026-04-16

### Added
- 4 screenshots added to pub.dev gallery showcasing the WhatsApp-clone example (Chats, Status, Calls, Settings screens)
- `BduiHttpClient` abstract class — inject a custom HTTP backend into `ApiWidget` for testing or alternative HTTP libraries without modifying widget code
- `DefaultBduiHttpClient` — default implementation backed by `ApiClient`, used automatically when no `httpClient` is provided
- `ApiRequest` model — bundles all API call parameters into a reusable, composable value object with `copyWith()` support; pass to `ApiWidget(request: ...)` instead of individual params
- `HttpMethod` enum (`get`, `post`, `put`, `delete`, `patch`) — replaces raw string method values; exposes `.value` for the uppercase string representation
- `ApiWidget.httpClient` — inject a `BduiHttpClient` implementation per-widget (useful for mocking in tests)
- `ApiWidget.request` — shorthand: pass one `ApiRequest` instead of separate `endpoint`, `method`, `headers`, `body`, `cacheDuration`, `maxRetries`, `timeout` params
- `BduiConfig.defaultContentType` — configurable default `Content-Type` header (default: `'application/json'`)

### Changed
- `ApiWidget.method` type changed from `String` to `HttpMethod` (default: `HttpMethod.get`)
- `ApiWidget.maxRetries` changed from `int = 3` to `int?` — `null` resolves to `BduiConfig.defaultMaxRetries` so changing config once applies everywhere
- `ApiWidget.timeout` changed from `Duration = const Duration(seconds: 30)` to `Duration?` — `null` resolves to `BduiConfig.defaultTimeout`
- `BackendDrivenScreen.method` type changed from `String` to `HttpMethod`
- `BackendDrivenScreen.maxRetries` changed from `int = 3` to `int?` — resolves to `BduiConfig.defaultMaxRetries`
- `ApiClient._fetch` now uses `BduiConfig.defaultContentType` instead of the hardcoded string `'application/json'`
- `ApiClient._refreshInBackground` now uses `BduiConfig.defaultCacheDuration` instead of the hardcoded `const Duration(minutes: 5)`

### Fixed
- `ApiClient._fetch` now throws `ApiException` on invalid JSON responses instead of silently passing the raw response body to the caller — `ApiWidget` and `BackendDrivenScreen` both route to their error state correctly
- `ApiWidget.didUpdateWidget` now triggers a refetch when `widget.request` changes (was only watching `endpoint`, `method`, and `body`)
- `ApiWidget` error callback now deduplicates via `dataHash` (same guard already applied to `onSuccess`) — prevents repeated `onError` calls for the same error
- `ApiWidget` now throws immediately when both `request` and `endpoint` are absent instead of making a request to an empty URL
- `RetryHandler.defaultShouldRetry` now inspects `ApiException.statusCode` directly instead of string-matching the error message — 4xx errors no longer retry, 5xx always retry, network/timeout errors retry correctly
- `ActionHandler._handleReplace` delegates to `onNavigate` when provided (GoRouter / AutoRoute compatibility), otherwise calls `Navigator.pushReplacementNamed`
- `api_client.dart`, `api_cache.dart`, and `retry_handler.dart` removed from public exports — these are internal implementation details
- `WidgetRegistry.global` renamed to `WidgetRegistry.instance` (Flutter singleton convention)
- `SchemaParser.parse()` documented: widget cache is context-unaware; call `clearCache()` after theme or locale changes to force rebuilds
- `UrlValidator` class-level doc updated to document the DNS-rebinding limitation and recommend network-level controls for stricter environments
- `toIconData` in `SchemaConverters` expanded from 8 to 35 icons; unknown icon names now log a warning listing all supported values
- Codebase refactored for single responsibility: `builtin_widgets.dart` reduced from ~1 500 lines to 68-line registration map; type converters moved to `SchemaConverters`; widget builders split into `display_builders`, `layout_builders`, `material_builders`, `interactive_builders`, `scrollable_builders`, `effects_builders`; `ActionHandler` typedefs moved to `action_callbacks.dart`
- `BackendDrivenScreen.didUpdateWidget` now refetches the schema when `endpoint`, `method`, or `body` changes — previously only callback changes triggered a re-init
- `BackendDrivenScreen` now accepts a `timeout` parameter; previously the 30-second default was hardcoded and could not be overridden
- `Button`, `ElevatedButton`, `TextButton`, `OutlinedButton`, `IconButton` builders now route actions through `SchemaParser.createActionHandler()`, ensuring `onNavigate`, `onCustomAction`, `onApiSuccess`, `onApiError`, and `onLaunchUrl` callbacks set on the parser are honoured — previously these widgets created a bare `ActionHandler` that ignored all parser callbacks
- `GestureDetector` and `InkWell` builders now execute `onDoubleTap` and `onLongPress` action maps from `props` instead of logging a debug message
- `ListTile` builder now supports `onTap` via the schema `action` field
- `ActionHandler` `api` action now passes `BduiConfig.defaultMaxRetries` and `BduiConfig.defaultTimeout` to all API calls — previously these were ignored and the hardcoded SDK defaults were used regardless of config
- `ActionHandler` `api` action no longer shows a default error snackbar when an `onApiError` callback is registered — previously both the callback and the snackbar fired simultaneously
- `ApiWidget` now uses separate deduplication hashes for `onSuccess` and `onError` — previously a single shared hash could suppress one callback when the other fired with an identical hash value
- `ApiWidget.didUpdateWidget` now also refetches when `headers` change, covering auth-token refresh without other param changes

### Maintenance
- `HttpMethod.patch` now fully implemented across `ApiClient`, `BduiHttpClient`, `DefaultBduiHttpClient`, `ActionHandler`, `ApiWidget`, and `BackendDrivenScreen` — previously the enum value existed but all execution paths threw "Unsupported HTTP method: PATCH"
- `ApiRequest.copyWith()` body sentinel fix — passing `body: null` now correctly clears the body on the copy; previously `null` was silently ignored and the original body was retained
- Resolved all static analysis issues in test files — unused import removed, redundant `const` keywords fixed; `flutter analyze` now reports zero issues

### Exports
- `BduiHttpClient`, `DefaultBduiHttpClient` now exported from the package root
- `ApiRequest` now exported from the package root
- `HttpMethod` now exported from the package root

---

## [0.2.1] - 2026-04-14

### Fixed
- Restored `example/` in the published archive so pub.dev awards the example pub points (was incorrectly excluded in 0.2.0 `.pubignore`)
- Added missing dartdoc comments to `ActionHandler` constructor and fields (`context`, `onApiSuccess`, `onApiError`, `onCustomAction`)

---

## [0.2.0] - 2026-04-13

### Added
- `BduiConfig.baseUrl` — set a global base URL once; all relative endpoints resolve against it automatically
- `SchemaParser.register()` — convenience method to add custom widget builders without accessing the registry directly
- Named color support in JSON: `"color": "blue"`, `"color": "Colors.deepPurple"`, `"color": "#1976D2"` (all Flutter color names + CSS hex + ARGB hex — any format now works)
- `onLaunchUrl` callback on `ActionHandler`, `SchemaParser`, and `BackendDrivenScreen` — wire in `url_launcher` or any custom handler to handle `launchUrl` actions from JSON schemas
- 74 tests covering `ApiCache`, `WidgetSchema`, `BduiConfig`, `helpers`, `ApiClient`, `SchemaWidget`, and custom widget registration

### Fixed
- `WidgetRegistry.instance` referenced in README docs was incorrect — corrected to use `SchemaParser.register()` API
- Cache key generation now uses a deterministic polynomial hash and sorted props keys — previously XOR-based hashing caused collisions for schemas with swapped or duplicate children
- `ApiClient.dispose()` now guards against `_performDisposal()` being called more than once when multiple in-flight requests complete simultaneously
- JSON response unwrapping for `ui`/`data` keys now validates the value is a `Map` before extracting — previously a non-Map value (e.g. String) would propagate and crash the schema parser
- `evaluateCondition` now logs a warning with the full list of supported conditions when an unknown condition string is received, instead of silently returning `false`

### Changed
- `logger.dart` renamed to `bdui_logger.dart` for clarity — internal change, no public API impact

### Removed
- "Early stage" disclaimer from README — the API is stable

---

## [0.1.0] - 2025-03-17

### Added

#### ApiWidget
* 🎯 Declarative API data fetching widget (FutureBuilder alternative)
* Built-in loading, success, error, and empty states
* Automatic caching with configurable TTL
* Retry logic with exponential backoff
* Polling support for real-time updates
* Success/error callbacks
* Retry button on errors

#### Backend-Driven UI
* 🚀 `BackendDrivenScreen` - Fetch and render UI from JSON schemas
* `SchemaParser` - Parse JSON into Flutter widgets
* `WidgetRegistry` - Extensible widget system
* **33 Built-in widgets:**
  - Layout (12): Column, Row, Stack, Center, Padding, SizedBox, Expanded, Flexible, Wrap, Spacer, AspectRatio, Container
  - Display (4): Text, Icon, Image, Divider
  - Material (5): Card, ListTile, CircleAvatar, Chip, ClipRRect
  - Interactive (7): Button, ElevatedButton, TextButton, OutlinedButton, IconButton, GestureDetector, InkWell
  - Scrollable (3): ListView, GridView, SingleChildScrollView
  - Effects (2): Visibility, Opacity
* Conditional rendering (platform, screen size, theme detection)
* Widget schema caching for performance

#### Core Features
* 📦 Lightweight HTTP client (only `http` package dependency)
* Custom retry handler with exponential backoff
* LRU cache with TTL for API responses
* **Server-controlled caching** - Backend can specify cache policy per response:
  - `cache` - Cache with optional TTL
  - `noCache` - Always fetch fresh
  - `refresh` - Stale-while-revalidate pattern
* Action handler system (navigate, API calls, dialogs, etc.)
* Type-safe models for requests/responses

#### Documentation
* 📖 Comprehensive README with examples
* JSON Schema Reference Guide (SCHEMA_REFERENCE.md)
* Working example app with multiple demos
* Inline code documentation

### Technical Details
* Zero heavy dependencies (50KB vs 350KB+ with dio)
* Production-ready error handling
* Material Design 3 support
* Platform-agnostic architecture
