# Changelog

All notable changes to this project will be documented in this file.

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
