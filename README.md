# Backend-Driven UI

[![pub package](https://img.shields.io/pub/v/backend_driven_ui.svg)](https://pub.dev/packages/backend_driven_ui)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

**Flutter UIs That Update Themselves. Seriously.**

Server-driven UI framework with ApiWidget - build data-driven interfaces without FutureBuilder boilerplate.

---

## ✨ Features

- 🎯 **33 Built-in Widgets** - Fully interactive apps from JSON
- ⚡ **Zero App Releases** - Update UI from backend JSON instantly
- 🔓 **100% Open Source** - MIT licensed, yours forever
- 📦 **ApiWidget** - FutureBuilder's smarter, faster cousin
- 🚀 **Lightweight & Fast** - Optimized parsing, lazy loading
- 💎 **Production Ready** - Buttons, lists, gestures, caching

---

## 🚀 Quick Start

### Installation

```yaml
dependencies:
  backend_driven_ui: ^0.3.0
```

### Global Base URL (optional)

Set once at app startup to avoid repeating the full URL on every widget:

```dart
void main() {
  BduiConfig.baseUrl = 'https://api.myapp.com';
  runApp(MyApp());
}
```

All relative endpoints are then resolved automatically:

```dart
BackendDrivenScreen(endpoint: '/screens/home')  // → https://api.myapp.com/screens/home
ApiWidget(endpoint: '/products')                // → https://api.myapp.com/products
```

Full URLs (`https://...`) are always used as-is regardless of `baseUrl`.

---

## 📖 Documentation

### Backend-Driven UI (the wow factor)

Render an entire screen from a JSON schema your backend returns.
No app update needed — change the JSON, the UI changes instantly.

```dart
BackendDrivenScreen(
  endpoint: '/api/screens/home',
  cacheDuration: Duration(minutes: 5),
  onNavigate: (route, args) => Navigator.pushNamed(context, route),
)
```

**Backend returns JSON → Flutter renders the UI:**

```json
{
  "type": "Column",
  "props": { "mainAxisAlignment": "center" },
  "children": [
    {
      "type": "Text",
      "props": { "text": "Hello from Backend!", "fontSize": 24, "color": "#1976D2" }
    },
    { "type": "SizedBox", "props": { "height": 16 } },
    {
      "type": "ElevatedButton",
      "props": { "text": "Shop Now" },
      "action": { "type": "navigate", "route": "/shop" }
    }
  ]
}
```

#### Colors in JSON

Three formats are supported — use whichever fits your backend:

| Format | Example | Notes |
|--------|---------|-------|
| Named | `"color": "blue"` | All Flutter `Colors.*` names |
| `Colors.x` | `"color": "Colors.deepPurple"` | Flutter notation directly |
| Hex `#RRGGBB` | `"color": "#1976D2"` | Standard CSS hex |
| Hex `#AARRGGBB` | `"color": "#FF1976D2"` | With alpha channel |
| ARGB int | `"color": 4278190080` | Raw Flutter int |

#### Local Schema (no API call needed)

```dart
SchemaWidget.fromJson({
  "type": "Column",
  "children": [
    { "type": "Text", "props": { "text": "Hello from JSON!", "fontSize": 24 } }
  ]
})
```

---

### ApiWidget

The declarative way to fetch and display API data.

```dart
ApiWidget(
  endpoint: '/api/products/featured',
  method: HttpMethod.get,

  // Optional: Headers
  headers: {'Authorization': 'Bearer $token'},

  // Optional: Request body (for POST/PUT)
  body: {'category': 'electronics'},

  // Optional: Cache duration
  cacheDuration: Duration(minutes: 5),

  // Optional: Auto-refresh (polling)
  pollInterval: Duration(seconds: 30),

  // State widgets
  loadingWidget: CircularProgressIndicator(),

  successWidget: (data) {
    final products = data['products'] as List;
    return ProductGrid(products: products);
  },

  errorWidget: (error) {
    return ErrorCard(
      message: error,
      onRetry: () => setState(() {}),
    );
  },

  // Optional: Empty state
  emptyWidget: EmptyState(message: 'No products found'),

  // Optional: Callbacks
  onSuccess: (data) => print('Loaded ${data.length} products'),
  onError: (error) => print('Error: $error'),
)
```

#### Using ApiRequest (reusable request config)

Bundle all request parameters into one object — compose it outside the widget tree and reuse across screens:

```dart
final productsRequest = ApiRequest(
  endpoint: '/api/products',
  method: HttpMethod.get,
  headers: {'Authorization': 'Bearer $token'},
  cacheDuration: Duration(minutes: 5),
);

// Use it directly
ApiWidget(
  request: productsRequest,
  successWidget: (data) => ProductList(data),
)

// Derive a variant with copyWith
final filteredRequest = productsRequest.copyWith(
  endpoint: '/api/products?category=electronics',
);
```

#### Injecting a custom HTTP client

Implement `BduiHttpClient` to swap the network layer — useful for testing or custom HTTP libraries:

```dart
class MockHttpClient implements BduiHttpClient {
  @override
  Future<ApiResponse> get(String url, { ... }) async {
    return ApiResponse(statusCode: 200, data: {'products': []});
  }
  // implement remaining methods...
}

ApiWidget(
  endpoint: '/api/products',
  httpClient: MockHttpClient(),
  successWidget: (data) => ProductList(data),
)
```

#### Custom Widget Registration

Extend with your own widgets using `SchemaParser.register`:

```dart
final parser = SchemaParser();

parser.register('ProductCard', (schema, context) {
  final props = schema.props ?? {};
  return ProductCard(
    title: props['title'],
    price: props['price'],
    imageUrl: props['imageUrl'],
  );
});
```

**Use it from backend:**

```json
{
  "type": "ProductCard",
  "props": {
    "title": "iPhone 15",
    "price": 79999,
    "imageUrl": "https://cdn.app.com/iphone15.jpg"
  }
}
```

---

## 🎯 Advanced Features

### Action Handling

Execute actions from your backend schemas:

```json
{
  "type": "navigate",
  "route": "/products"
}
```

**Supported actions:**
- `navigate` - Navigate to a route
- `pop` - Go back
- `replace` - Replace current route
- `popUntil` - Pop to a named route (or root)
- `api` - Make API calls
- `showDialog` - Show alert dialogs (supports `onConfirm`, `onCancel`, `onDismiss`)
- `showSnackBar` - Show snackbars
- `showBottomSheet` - Show modal bottom sheets
- `launchUrl` - Open a URL (requires `onLaunchUrl` callback)
- `copy` - Copy text to clipboard
- `share` - Share text content
- `sequence` - Execute multiple actions in order
- `conditional` - Conditional execution
- `custom` - App-defined custom actions

### Caching & Performance

```dart
// Enable widget caching
final parser = SchemaParser(enableCache: true);

// Clear cache when needed
parser.clearCache();

// API caching
ApiWidget(
  endpoint: '/api/products',
  cacheDuration: Duration(minutes: 5), // Cache for 5 minutes
)
```

### Server-Controlled Caching

Let your backend control cache behavior per response:

```json
{
  "cachePolicy": "cache",
  "cacheTTL": 300,
  "ui": {
    "type": "Column",
    "children": [...]
  }
}
```

**Cache policies:**
- `cache` - Cache response (default)
- `noCache` - Never cache, always fetch fresh
- `refresh` - Return cached data, refresh in background (stale-while-revalidate)

**Handle background refresh:**
```dart
ApiWidget(
  endpoint: '/api/live-data',
  onBackgroundRefresh: (newData) {
    // UI automatically updates with fresh data
    print('Data refreshed in background!');
  },
)
```

### Auto-Retry & Error Handling

```dart
ApiWidget(
  endpoint: '/api/products',
  maxRetries: 3, // Retry up to 3 times
  showRetryButton: true, // Show retry button on error
  onError: (error) => logError(error),
)
```

---

## 📚 Schema Reference

See the [Schema Reference](https://igloodev.in/docs/backend-driven-ui/schema) for complete documentation of all 33 widgets, props, actions, and conditions — also available as [SCHEMA_REFERENCE.md](./SCHEMA_REFERENCE.md).

---

## 📱 Examples

Check out the [example](./example) directory for complete samples:

- **ApiWidget Examples** - Basic & list API calls with caching
- **Backend-Driven UI** - JSON schema rendering
- **Local Schema** - Use JSON without API calls
- **Conditional Rendering** - Platform & theme-based UI

---

## 🤝 Contributing

Contributions are welcome! Feel free to [open issues](https://github.com/igloodev/backend_driven_ui/issues) or submit pull requests on [GitHub](https://github.com/igloodev/backend_driven_ui).

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🌟 Show Your Support

If you like this package, please give it a ⭐ on [GitHub](https://github.com/igloodev/backend_driven_ui)!

---

**Built with ❤️ for the Flutter community**
