# JSON Schema Reference

Complete reference for all 33 built-in widgets supported by Backend-Driven UI.

---

## Table of Contents

- [Schema Structure](#schema-structure)
- [Layout Widgets](#layout-widgets)
- [Display Widgets](#display-widgets)
- [Material Widgets](#material-widgets)
- [Interactive Widgets](#interactive-widgets)
- [Scrollable Widgets](#scrollable-widgets)
- [Effect Widgets](#effect-widgets)
- [Actions](#actions)
- [Conditions](#conditions)

---

## Schema Structure

Every widget follows this basic structure:

```json
{
  "type": "WidgetName",
  "props": {
    "property1": "value1",
    "property2": "value2"
  },
  "child": { },
  "children": [ ],
  "action": { },
  "condition": "conditionName"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `type` | String | **Required.** Widget type name |
| `props` | Object | Widget properties |
| `child` | Object | Single child widget |
| `children` | Array | List of child widgets |
| `action` | Object | Action to execute (e.g., on tap) |
| `condition` | String | Conditional rendering |

---

## Layout Widgets

### Column

Vertical layout.

```json
{
  "type": "Column",
  "props": {
    "mainAxisAlignment": "center",
    "crossAxisAlignment": "start",
    "mainAxisSize": "max"
  },
  "children": []
}
```

| Property | Type | Values |
|----------|------|--------|
| `mainAxisAlignment` | String | `start`, `end`, `center`, `spaceBetween`, `spaceAround`, `spaceEvenly` |
| `crossAxisAlignment` | String | `start`, `end`, `center`, `stretch`, `baseline` |
| `mainAxisSize` | String | `min`, `max` |

---

### Row

Horizontal layout.

```json
{
  "type": "Row",
  "props": {
    "mainAxisAlignment": "spaceBetween",
    "crossAxisAlignment": "center"
  },
  "children": []
}
```

*Same properties as Column.*

---

### Stack

Overlay widgets on top of each other.

```json
{
  "type": "Stack",
  "props": {
    "alignment": "center",
    "fit": "loose"
  },
  "children": []
}
```

| Property | Type | Values |
|----------|------|--------|
| `alignment` | String | `topLeft`, `topCenter`, `topRight`, `centerLeft`, `center`, `centerRight`, `bottomLeft`, `bottomCenter`, `bottomRight` |
| `fit` | String | `loose`, `expand`, `passthrough` |

---

### Center

Center a child widget.

```json
{
  "type": "Center",
  "child": {}
}
```

---

### Padding

Add padding around a child.

```json
{
  "type": "Padding",
  "props": {
    "padding": 16,
    "paddingLeft": 8,
    "paddingRight": 8,
    "paddingTop": 12,
    "paddingBottom": 12,
    "paddingHorizontal": 16,
    "paddingVertical": 8
  },
  "child": {}
}
```

| Property | Type | Description |
|----------|------|-------------|
| `padding` | Number | All sides |
| `paddingLeft` | Number | Left only |
| `paddingRight` | Number | Right only |
| `paddingTop` | Number | Top only |
| `paddingBottom` | Number | Bottom only |
| `paddingHorizontal` | Number | Left + Right |
| `paddingVertical` | Number | Top + Bottom |

---

### SizedBox

Fixed size box or spacer.

```json
{
  "type": "SizedBox",
  "props": {
    "width": 100,
    "height": 50
  },
  "child": {}
}
```

---

### Container

Box with styling (background, border, padding).

```json
{
  "type": "Container",
  "props": {
    "width": 200,
    "height": 100,
    "color": "#FF5733",
    "padding": 16,
    "margin": 8,
    "borderRadius": 8,
    "border": true,
    "borderColor": "#000000",
    "borderWidth": 2
  },
  "child": {}
}
```

| Property | Type | Description |
|----------|------|-------------|
| `width` | Number | Fixed width |
| `height` | Number | Fixed height |
| `color` | String/Number | Background color (`#RRGGBB` or integer) |
| `padding` | Number | Inner padding |
| `margin` | Number | Outer margin |
| `borderRadius` | Number | Corner radius |
| `border` | Boolean | Show border |
| `borderColor` | String/Number | Border color |
| `borderWidth` | Number | Border width |

---

### Expanded

Expand child to fill available space.

```json
{
  "type": "Expanded",
  "props": {
    "flex": 2
  },
  "child": {}
}
```

---

### Flexible

Flexible sizing within Row/Column.

```json
{
  "type": "Flexible",
  "props": {
    "flex": 1,
    "fit": "loose"
  },
  "child": {}
}
```

| Property | Type | Values |
|----------|------|--------|
| `flex` | Number | Flex factor (default: 1) |
| `fit` | String | `tight`, `loose` |

---

### Wrap

Wrap children to next line when space runs out.

```json
{
  "type": "Wrap",
  "props": {
    "direction": "horizontal",
    "alignment": "start",
    "spacing": 8,
    "runSpacing": 8
  },
  "children": []
}
```

| Property | Type | Values |
|----------|------|--------|
| `direction` | String | `horizontal`, `vertical` |
| `alignment` | String | `start`, `end`, `center`, `spaceBetween`, `spaceAround`, `spaceEvenly` |
| `spacing` | Number | Space between children |
| `runSpacing` | Number | Space between lines |

---

### Spacer

Flexible space in Row/Column.

```json
{
  "type": "Spacer",
  "props": {
    "flex": 1
  }
}
```

---

### AspectRatio

Maintain aspect ratio.

```json
{
  "type": "AspectRatio",
  "props": {
    "aspectRatio": 1.78
  },
  "child": {}
}
```

---

## Display Widgets

### Text

Display text with styling.

```json
{
  "type": "Text",
  "props": {
    "text": "Hello World",
    "fontSize": 16,
    "fontWeight": "bold",
    "fontStyle": "italic",
    "color": "#333333",
    "textAlign": "center",
    "maxLines": 2,
    "overflow": "ellipsis",
    "letterSpacing": 1.2,
    "lineHeight": 1.5,
    "decoration": "underline"
  }
}
```

| Property | Type | Values |
|----------|------|--------|
| `text` | String | **Required.** Text content |
| `fontSize` | Number | Font size in pixels |
| `fontWeight` | String | `normal`, `bold`, `w100`-`w900` |
| `fontStyle` | String | `normal`, `italic` |
| `color` | String/Number | Text color |
| `textAlign` | String | `left`, `right`, `center`, `justify`, `start`, `end` |
| `maxLines` | Number | Maximum lines |
| `overflow` | String | `clip`, `fade`, `ellipsis`, `visible` |
| `decoration` | String | `none`, `underline`, `overline`, `lineThrough` |

---

### Icon

Material icon.

```json
{
  "type": "Icon",
  "props": {
    "icon": "favorite",
    "size": 24,
    "color": "#FF0000"
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `icon` | String | Material icon name (e.g., `home`, `settings`, `favorite`) |
| `size` | Number | Icon size |
| `color` | String/Number | Icon color |

**Available icons:** `home`, `settings`, `favorite`, `star`, `person`, `email`, `phone`, `message`, `camera`, `image`, `file`, `folder`, `download`, `upload`, `share`, `copy`, `delete`, `edit`, `add`, `remove`, `check`, `close`, `search`, `menu`, `arrow_back`, `arrow_forward`, `refresh`, `info`, `warning`, `error`, `help`, `lock`, `unlock`, `visibility`, `visibility_off`

---

### Image

Network image.

```json
{
  "type": "Image",
  "props": {
    "url": "https://example.com/image.jpg",
    "width": 200,
    "height": 150,
    "fit": "cover",
    "borderRadius": 8
  }
}
```

| Property | Type | Values |
|----------|------|--------|
| `url` | String | **Required.** Image URL |
| `width` | Number | Image width |
| `height` | Number | Image height |
| `fit` | String | `fill`, `contain`, `cover`, `fitWidth`, `fitHeight`, `none`, `scaleDown` |
| `borderRadius` | Number | Corner radius |

---

### Divider

Horizontal line.

```json
{
  "type": "Divider",
  "props": {
    "height": 1,
    "thickness": 1,
    "color": "#E0E0E0",
    "indent": 16,
    "endIndent": 16
  }
}
```

---

## Material Widgets

### Card

Material card with elevation.

```json
{
  "type": "Card",
  "props": {
    "elevation": 4,
    "color": "#FFFFFF",
    "borderRadius": 8,
    "margin": 8,
    "padding": 16
  },
  "child": {}
}
```

---

### ListTile

Standard list item.

```json
{
  "type": "ListTile",
  "props": {
    "title": "List Item Title",
    "subtitle": "Subtitle text",
    "dense": false,
    "enabled": true
  },
  "leading": {
    "type": "Icon",
    "props": {"icon": "person"}
  },
  "trailing": {
    "type": "Icon",
    "props": {"icon": "arrow_forward"}
  },
  "action": {}
}
```

---

### CircleAvatar

Circular avatar.

```json
{
  "type": "CircleAvatar",
  "props": {
    "imageUrl": "https://example.com/avatar.jpg",
    "text": "AB",
    "radius": 24,
    "backgroundColor": "#2196F3"
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `imageUrl` | String | Avatar image URL |
| `text` | String | Fallback text (initials) |
| `radius` | Number | Avatar radius |
| `backgroundColor` | String/Number | Background color |

---

### Chip

Tag/label chip.

```json
{
  "type": "Chip",
  "props": {
    "label": "Tag Name",
    "backgroundColor": "#E3F2FD",
    "labelColor": "#1976D2",
    "deleteIcon": true
  },
  "avatar": {
    "type": "Icon",
    "props": {"icon": "tag"}
  },
  "action": {}
}
```

---

### ClipRRect

Rounded corners clip.

```json
{
  "type": "ClipRRect",
  "props": {
    "borderRadius": 16,
    "topLeft": 8,
    "topRight": 8,
    "bottomLeft": 0,
    "bottomRight": 0
  },
  "child": {}
}
```

---

## Interactive Widgets

### Button / ElevatedButton

Elevated button with action.

```json
{
  "type": "ElevatedButton",
  "props": {
    "text": "Click Me",
    "color": "#2196F3",
    "textColor": "#FFFFFF",
    "elevation": 2,
    "borderRadius": 8,
    "padding": 16,
    "disabled": false
  },
  "action": {
    "type": "navigate",
    "route": "/details"
  }
}
```

---

### TextButton

Flat text button.

```json
{
  "type": "TextButton",
  "props": {
    "text": "Learn More",
    "textColor": "#2196F3"
  },
  "action": {}
}
```

---

### OutlinedButton

Outlined button.

```json
{
  "type": "OutlinedButton",
  "props": {
    "text": "Cancel",
    "borderColor": "#757575",
    "textColor": "#757575"
  },
  "action": {}
}
```

---

### IconButton

Icon button.

```json
{
  "type": "IconButton",
  "props": {
    "icon": "favorite",
    "size": 24,
    "color": "#FF0000"
  },
  "action": {}
}
```

---

### GestureDetector

Tap detection wrapper.

```json
{
  "type": "GestureDetector",
  "action": {
    "type": "navigate",
    "route": "/details"
  },
  "child": {}
}
```

---

### InkWell

Tap with ripple effect.

```json
{
  "type": "InkWell",
  "props": {
    "borderRadius": 8,
    "splashColor": "#2196F3"
  },
  "action": {},
  "child": {}
}
```

---

## Scrollable Widgets

### ListView

Scrollable list (lazy loading).

```json
{
  "type": "ListView",
  "props": {
    "scrollDirection": "vertical",
    "padding": 16,
    "shrinkWrap": true,
    "physics": "bouncing",
    "separator": true,
    "separatorHeight": 1
  },
  "children": []
}
```

| Property | Type | Values |
|----------|------|--------|
| `scrollDirection` | String | `vertical`, `horizontal` |
| `padding` | Number | List padding |
| `shrinkWrap` | Boolean | Shrink to content size |
| `physics` | String | `bouncing`, `clamping`, `never`, `always` |
| `separator` | Boolean | Show dividers |

---

### GridView

Scrollable grid.

```json
{
  "type": "GridView",
  "props": {
    "crossAxisCount": 2,
    "mainAxisSpacing": 8,
    "crossAxisSpacing": 8,
    "childAspectRatio": 1.0,
    "padding": 16,
    "shrinkWrap": true
  },
  "children": []
}
```

| Property | Type | Description |
|----------|------|-------------|
| `crossAxisCount` | Number | Columns count |
| `mainAxisSpacing` | Number | Vertical spacing |
| `crossAxisSpacing` | Number | Horizontal spacing |
| `childAspectRatio` | Number | Width/height ratio |

---

### SingleChildScrollView

Scrollable content.

```json
{
  "type": "SingleChildScrollView",
  "props": {
    "scrollDirection": "vertical",
    "padding": 16,
    "physics": "bouncing"
  },
  "child": {}
}
```

---

## Effect Widgets

### Visibility

Show/hide widget.

```json
{
  "type": "Visibility",
  "props": {
    "visible": true,
    "maintainSize": false,
    "maintainState": false
  },
  "child": {}
}
```

---

### Opacity

Transparency control.

```json
{
  "type": "Opacity",
  "props": {
    "opacity": 0.5
  },
  "child": {}
}
```

---

## Actions

Actions define what happens when a user interacts with a widget.

### Navigate

```json
{
  "type": "navigate",
  "route": "/products",
  "arguments": {
    "id": 123
  }
}
```

### Pop

```json
{
  "type": "pop",
  "result": "success"
}
```

### API Call

```json
{
  "type": "api",
  "endpoint": "/api/products",
  "method": "POST",
  "body": {
    "name": "Product"
  },
  "onSuccess": {
    "type": "showSnackBar",
    "message": "Saved!"
  },
  "onError": {
    "type": "showSnackBar",
    "message": "Failed to save"
  }
}
```

### Show Dialog

```json
{
  "type": "showDialog",
  "title": "Confirm",
  "message": "Are you sure?",
  "confirmText": "Yes",
  "cancelText": "No",
  "onConfirm": {
    "type": "api",
    "endpoint": "/api/delete"
  }
}
```

### Show SnackBar

```json
{
  "type": "showSnackBar",
  "message": "Item saved successfully",
  "duration": 3000,
  "actionLabel": "Undo",
  "action": {
    "type": "api",
    "endpoint": "/api/undo"
  }
}
```

### Sequence

Execute multiple actions in order.

```json
{
  "type": "sequence",
  "actions": [
    {"type": "showSnackBar", "message": "Saving..."},
    {"type": "api", "endpoint": "/api/save"},
    {"type": "navigate", "route": "/success"}
  ]
}
```

### Conditional

```json
{
  "type": "conditional",
  "condition": "isAndroid",
  "then": {
    "type": "navigate",
    "route": "/android-page"
  },
  "else": {
    "type": "navigate",
    "route": "/ios-page"
  }
}
```

### Copy

```json
{
  "type": "copy",
  "text": "Text to copy",
  "showFeedback": true,
  "feedbackMessage": "Copied!"
}
```

### Custom

```json
{
  "type": "custom",
  "name": "myCustomAction",
  "params": {
    "key": "value"
  }
}
```

---

## Conditions

Conditions control when widgets are rendered.

| Condition | Description |
|-----------|-------------|
| `isAndroid` | Android platform |
| `isIOS` | iOS platform |
| `isMobile` | Android or iOS |
| `isWeb` | Web platform |
| `isDesktop` | Desktop (Windows, macOS, Linux) |
| `isSmallScreen` | Width < 600px |
| `isMediumScreen` | 600px <= Width < 1200px |
| `isLargeScreen` | Width >= 1200px |
| `isDarkMode` | Dark theme active |
| `isLightMode` | Light theme active |

**Usage:**

```json
{
  "type": "Text",
  "props": {
    "text": "Only visible on mobile"
  },
  "condition": "isMobile"
}
```

---

## Color Formats

Colors can be specified as:

1. **Hex string:** `"#RRGGBB"` or `"#AARRGGBB"`
2. **Integer:** `4278190080` (0xFF000000 in hex = black)

**Common colors:**

| Color | Hex | Integer |
|-------|-----|---------|
| Black | `#000000` | `4278190080` |
| White | `#FFFFFF` | `4294967295` |
| Red | `#FF0000` | `4294901760` |
| Green | `#00FF00` | `4278255360` |
| Blue | `#0000FF` | `4278190335` |
| Grey | `#9E9E9E` | `4288585374` |

---

## Best Practices

1. **Keep schemas simple** - Avoid deeply nested structures
2. **Use conditions sparingly** - Prefer responsive layouts over conditional widgets
3. **Cache aggressively** - Use `cacheDuration` for stable content
4. **Handle errors** - Always provide `onError` for API actions
5. **Test on all platforms** - Verify conditions work as expected

---

**Built with Backend-Driven UI**
