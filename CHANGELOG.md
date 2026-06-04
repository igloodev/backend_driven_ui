# Changelog

All notable changes to this project will be documented in this file.

## [0.5.0] - 2026-06-05

### Added

- **State binding** — `${state.key}` interpolation in any string prop; widgets with state refs rebuild automatically via `ListenableBuilder` when state changes. Example: `"text": "${state.name}"`.
- **`BduiStateManager`** — `ChangeNotifier`-based reactive key-value store. `SchemaParser` creates one automatically; pass your own via `SchemaParser(stateManager: ...)`. Public API: `get()`, `set()`, `setAll()`, `remove()`, `reset()`, `snapshot`.
- **`stateKey` prop** on `TextField`, `TextFormField`, `Switch`, and `Checkbox` — writes the field's current value to `stateManager` on every change. Pre-fills from state when no `value` prop is given.
- **`Form` widget** — wraps form fields for coordinated validation. Props: `formKey` (string ID), `autovalidateMode` (`"disabled"` | `"always"` | `"onUserInteraction"`). Multiple `children` are auto-wrapped in a `Column`.
- **`submitForm` action** — validates and saves a named form. `{"type": "submitForm", "params": {"formKey": "login"}}`. Returns form errors to the UI when validation fails.
- **`setState` action** — sets a `BduiStateManager` key from any action. `{"type": "setState", "params": {"key": "tab", "value": 1}}`.
- **`PageView` widget** — horizontal/vertical swipeable pages from `children`. Props: `scrollDirection`, `reverse`, `physics`, `padEnds`.
- **`PageView.builder` widget** — lazy page builder. Props: `itemCount` (omit for infinite), `scrollDirection`, `reverse`, `physics`, `padEnds`. Uses `child` schema as the page template.
- **`animate` prop** on any widget — entry animation without writing a single line of Dart. Accepts a string shorthand (`"fadeIn"`) or a config map: `{"type": "slideUp", "duration": 400, "delay": 100, "curve": "easeInOut"}`. Supported types: `fadeIn`, `slideUp`, `slideDown`, `slideLeft`, `slideRight`, `scale`, `bounce`.
- **Icon expansion** — `Icons.*` mapping expanded from 35 → 120+ icons across 16 categories (navigation, status, people, favorites, communication, media, files, commerce, location, time, device, security, analytics, layout, cloud, misc).
- **`RichText` widget** — renders inline styled text via `TextSpan` trees. Each span supports `bold`, `italic`, `underline`, `strikethrough`, `color`, `fontSize`, `letterSpacing`, `fontFamily`, `backgroundColor`, and nested `spans`.
- **`Dismissible` widget** — swipe-to-dismiss with `dismissKey`, `direction` (`horizontal` | `vertical` | `startToEnd` | `endToStart`), `background` / `secondaryBackground` slots, and an action fired on dismiss.
- **Cupertino widgets** (5 new types): `CupertinoButton`, `CupertinoSwitch`, `CupertinoSlider`, `CupertinoActivityIndicator`, `CupertinoTextField` — all support `stateKey` integration where applicable.
- **`Semantics` widget** — full accessibility wrapper. Props: `label`, `hint`, `value`, `button`, `enabled`, `readOnly`, `checked`, `toggled`, `selected`, `header`, `image`, `liveRegion`, `excludeSemantics`.
- **`HttpMethod.head` and `HttpMethod.options`** — two new HTTP verb values; all exhaustive switches updated across `ApiWidget`, `BackendDrivenScreen`, `BduiHttpClient`, `DefaultBduiHttpClient`, and `ActionHandler`. `ApiClient` gains `head()` and `options()` static methods.
- **`BduiValidatorMessages`** — static, globally overridable validation message strings for i18n. Override any field before app launch (e.g. `BduiValidatorMessages.required = 'Champ requis'`). Exported from the public library.
- **New validators** — `phone` (E.164-style regex), `url` (must start with `http://` or `https://`), `min:n` (numeric minimum), `max:n` (numeric maximum). All messages go through `BduiValidatorMessages`.

### Fixed

- **`ApiWidget` race condition** — endpoint changes now always issue a new request even when one is in-flight. A generation counter ensures only the latest `whenComplete` clears `_isRequestInFlight`, so polling cannot overlap and stale responses from superseded requests are discarded by `FutureBuilder`.
- **`SchemaParser` cache key collision** — `_propsKey()` now uses `jsonEncode` (sorted keys) instead of raw `:` / `;` delimiters, preventing collisions between props whose values contain those characters.
- **`ActionHandler` double error handling** — `_handleApi()` catch block restructured: the `onError` action branch rethrows so `execute()` runs it; a fallback snackbar is only shown when no `onApiError` callback and no `onError` action are registered. Errors are never handled twice.
- **`CacheControl` unknown policy** — unrecognised `cachePolicy` strings now default to `CachePolicy.noCache` (fail-closed) with a logged warning, instead of silently falling through to `CachePolicy.cache`.
- **`UrlValidator` IPv6 bracket bypass** — host brackets are stripped before `_isMetadataEndpoint` is checked, so `[fd00:ec2::254]` cannot bypass the AWS IPv6 metadata block.
- **`ActionHandler.showModalBottomSheet` unmount safety** — `if (!_isContextMounted) return;` added after `await showModalBottomSheet(...)`, consistent with the same guard already in `_handleShowDialog`.
- **`didUpdateWidget` on all input widgets** — `_BduiTextField`, `_BduiTextFormField`, `_BduiSwitch`, `_BduiCheckbox`, `_CupertinoSwitchWidget`, `_CupertinoSliderWidget`, and `_CupertinoTextFieldWidget` now sync controller / state when the parent rebuilds with a new `value` prop.
- **`BduiStateManager` unnecessary rebuilds** — `set()`, `setAll()`, and `remove()` skip `notifyListeners()` when the value is unchanged.
- **`ApiClient.reset()`** — now clears all static fields (`_httpClient`, `_activeRequests`, `_disposalRequested`, `_isDisposing`, `_cacheInstance`) for a clean slate between tests.
- **`BackendDrivenScreen` empty endpoint guard** — `_makeApiCall()` throws `ArgumentError` immediately when `endpoint` is empty, preventing silent network errors.
- **`AnimationWrapper` `CurvedAnimation` leak** — `_curve` and `_bounceCurve` are created in `initState()` and disposed in `dispose()` instead of being recreated on every `build()`.

### Maintenance

- `AnimationWrapper` (`lib/src/utils/animation_wrapper.dart`) — new file, `StatefulWidget` with `SingleTickerProviderStateMixin`.
- `BduiStateManager` (`lib/src/utils/bdui_state_manager.dart`) — exported from the public library.
- `BduiValidatorMessages` (`lib/src/utils/bdui_validator_messages.dart`) — new utility, exported from the public library.
- `PageViewBuilders` (`lib/src/registry/builders/pageview_builders.dart`) — new builder file.
- `CupertinoBuilders` (`lib/src/registry/builders/cupertino_builders.dart`) — new builder file.
- `SchemaParser.getFormKey(name)` — returns (or creates) a `GlobalKey<FormState>` by name.
- `ActionHandler` gains `onSetState` and `onSubmitForm` callback fields; both are wired automatically by `SchemaParser.createActionHandler()`.
- Widgets with `animate`, state refs, conditions, or actions are excluded from the widget cache.

---

## [0.4.0] - 2026-04-17

### Added
- **Scaffold widgets**: `Scaffold`, `AppBar`, `SafeArea` — full screen layouts from JSON
- **Input widgets**: `TextField`, `TextFormField`, `Switch`, `Checkbox` — form inputs driven by backend schema
- **Navigation widgets**: `BottomNavigationBar`, `NavigationBar`, `DefaultTabController`, `TabBar`, `TabBarView` — tab and bottom-nav layouts from JSON
- **Sliver widgets**: `CustomScrollView`, `SliverAppBar`, `SliverList`, `SliverGrid`, `SliverToBoxAdapter`, `SliverPadding`, `SliverFillRemaining`, `SliverFixedExtentList` — full sliver-based scroll layouts from JSON
- `clipBehavior` prop support for `Container`, `Column`, `Row`, and `Stack` — accepts `"none"`, `"hardEdge"`, `"antiAlias"`, `"antiAliasWithSaveLayer"`
- `SchemaConverters.toClip()` — new converter backing the `clipBehavior` prop
- Total registered widget types raised from 33 to 65

### Fixed
- `Expanded`, `Flexible`, and `Spacer` used outside a `Row`/`Column`/`Flex` no longer crash at layout time — each builder now checks for a `RenderFlex` ancestor via `visitAncestorElements` and falls back to rendering the child directly (with a warning log) instead of triggering Flutter's `ParentDataWidget` layout assertion
- `WidgetSchema.fromJson`: `condition` field now uses `?.toString()` — non-String values (e.g. `true`, `1`) no longer throw a `TypeError` at parse time
- `ActionSchema.fromJson`: `params`, `route`, `endpoint`, `method`, and `condition` fields now use `toStringKeyedMap` / `?.toString()` — unsafe `as` casts replaced throughout
- `Column` and `Row` builders now use `Flex(direction: ...)` internally so `clipBehavior` can be forwarded — `Column()` / `Row()` constructors do not expose that parameter

### Maintenance
- New builder files: `scaffold_builders.dart`, `input_builders.dart`, `navigation_builders.dart`, `sliver_builders.dart` — extends the SRP split started in v0.3.0
- 105 new widget-builder crash tests added (`test/widget_builders_crash_test.dart`) — covers every builder with invalid / edge-case JSON to ensure no runtime crashes; total test suite now 304 tests

---

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
