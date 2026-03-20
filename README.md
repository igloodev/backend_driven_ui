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

> **Note:** This package is at an early stage (v0.1.0). While we support 33 built-in widgets, some widgets you need might not be available yet. There might also be some edge case issues. Please [open an issue](https://github.com/igloodev/backend_driven_ui/issues) to let us know which widgets you require or any issues you encounter — we'll address them as soon as possible!

---

## 🚀 Quick Start

### Installation

```yaml
dependencies:
  backend_driven_ui: ^0.1.0
```

### Basic Usage

#### The FutureBuilder Hell 😭

```dart
FutureBuilder(
  future: api.fetchProducts(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Text('No data');
    }
    return ProductList(snapshot.data);
  }
)
```

#### The ApiWidget Magic ✨

```dart
ApiWidget(
  endpoint: '/api/products',
  loadingWidget: ShimmerLoader(),
  successWidget: (data) => ProductList(data),
  errorWidget: (error) => ErrorCard(error),
)
```

**That's it!** Caching, retry, polling, error handling—all built in.

---

## 📖 Documentation

### ApiWidget

The declarative way to fetch and display API data.

```dart
ApiWidget(
  endpoint: '/api/products/featured',
  method: 'GET',

  // Optional: Headers
  headers: {'Authorization': 'Bearer $token'},

  // Optional: Request body (for POST/PUT)
  body: {'category': 'electronics'},

  // Optional: Cache duration
  cacheDuration: Duration(minutes: 5),

  // Optional: Max retry attempts
  maxRetries: 3,

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

### Backend-Driven UI

Build entire screens from JSON schemas.

#### Basic Usage

```dart
BackendDrivenScreen(
  endpoint: '/api/screens/home',
  cacheDuration: Duration(minutes: 5),
  onSchemaLoaded: (schema) => print('UI loaded from backend'),
)
```

#### Built-in Widgets (33 Total)

The framework includes these widgets out of the box - **NO custom registration needed!**

**Layout (12):**
- Column, Row, Stack - Basic layouts
- Center, Padding, SizedBox - Alignment & spacing
- Expanded, Flexible - Flexible layouts
- Wrap - Wrapping layout
- Spacer - Spacing helper
- AspectRatio - Maintain aspect ratio
- Container - Box with styling (colors, borders, padding)

**Display (4):**
- Text - Text with styling
- Icon - Material icons
- Image - Network images
- Divider - Horizontal lines

**Material (5):**
- Card - Material card with elevation
- ListTile - Standard list item
- CircleAvatar - User avatars
- Chip - Tags/labels
- ClipRRect - Rounded corners

**Interactive (7):**
- Button, ElevatedButton, TextButton, OutlinedButton - Buttons
- IconButton - Icon buttons
- GestureDetector, InkWell - Tap detection

**Scrollable (3):**
- ListView - Scrollable lists (lazy loading)
- GridView - Scrollable grids
- SingleChildScrollView - Scrollable content

**Effects (2):**
- Visibility - Show/hide widgets
- Opacity - Transparency control

**Build complex, interactive UIs by combining these - no app updates needed!** 🚀

#### JSON Schema Format

```json
{
  "type": "Column",
  "props": {
    "mainAxisAlignment": "center",
    "crossAxisAlignment": "center"
  },
  "children": [
    {
      "type": "Text",
      "props": {
        "text": "Hello from Backend!",
        "fontSize": 24,
        "fontWeight": "bold",
        "color": 4278190080
      }
    },
    {
      "type": "SizedBox",
      "props": {"height": 16}
    },
    {
      "type": "Container",
      "props": {
        "padding": 16,
        "color": 4293848814,
        "borderRadius": 8,
        "border": true,
        "borderColor": 4278190080,
        "borderWidth": 2
      },
      "child": {
        "type": "Text",
        "props": {
          "text": "This UI is rendered from JSON!"
        }
      }
    }
  ]
}
```

#### Conditional Rendering

Show/hide widgets based on platform, screen size, or theme:

```json
{
  "type": "Text",
  "props": {
    "text": "Only on Android"
  },
  "condition": "isAndroid"
}
```

**Available conditions:**
- `isAndroid`, `isIOS`, `isMobile`, `isWeb`
- `isSmallScreen`, `isMediumScreen`, `isLargeScreen`
- `isDarkMode`, `isLightMode`

#### Using Local Schemas

Render UI from local JSON without API:

```dart
// From JSON Map
SchemaWidget.fromJson({
  "type": "Column",
  "children": [
    {
      "type": "Text",
      "props": {
        "text": "Hello from JSON!",
        "fontSize": 24
      }
    }
  ]
})

// Or from WidgetSchema
final schema = WidgetSchema.fromJson(myJsonData);
SchemaWidget(schema: schema)
```

#### Custom Widget Registration

Extend with your own widgets:

```dart
void main() {
  final registry = WidgetRegistry.instance;

  // Register custom widget
  registry.register('ProductCard', (schema, context) {
    final props = schema.props ?? {};
    return ProductCard(
      title: props['title'],
      price: props['price'],
      imageUrl: props['imageUrl'],
    );
  });

  runApp(MyApp());
}
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
- `api` - Make API calls
- `showDialog` - Show dialogs
- `showSnackBar` - Show snackbars
- `pop` - Go back
- `sequence` - Execute multiple actions
- `conditional` - Conditional execution

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

See [SCHEMA_REFERENCE.md](./SCHEMA_REFERENCE.md) for complete documentation of all 33 widgets, props, actions, and conditions.

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
