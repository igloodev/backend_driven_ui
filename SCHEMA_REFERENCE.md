# JSON Schema Reference

Complete reference for all 65 built-in widget types supported by Backend-Driven UI.

---

## Table of Contents

- [Schema Structure](#schema-structure)
- [Scaffold Widgets](#scaffold-widgets)
- [Layout Widgets](#layout-widgets)
- [Display Widgets](#display-widgets)
- [Material Widgets](#material-widgets)
- [Interactive Widgets](#interactive-widgets)
- [Input Widgets](#input-widgets)
- [Scrollable Widgets](#scrollable-widgets)
- [Sliver Widgets](#sliver-widgets)
- [Navigation Widgets](#navigation-widgets)
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

## Scaffold Widgets

### Scaffold

Top-level screen structure.

```json
{
  "type": "Scaffold",
  "props": {
    "backgroundColor": "#FFFFFF",
    "resizeToAvoidBottomInset": true,
    "extendBody": false,
    "extendBodyBehindAppBar": false,
    "floatingActionButtonLocation": "endFloat",
    "appBar": { "type": "AppBar", "props": { "title": "My Screen" } },
    "floatingActionButton": { "type": "FloatingActionButton", "props": { "icon": "add" } },
    "bottomNavigationBar": { "type": "BottomNavigationBar", "children": [] },
    "drawer": { "type": "Column", "children": [] }
  },
  "child": { "type": "Column", "children": [] }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `backgroundColor` | String/Number | Scaffold background color |
| `resizeToAvoidBottomInset` | Boolean | Resize body when keyboard appears (default `true`) |
| `extendBody` | Boolean | Extend body behind bottom navigation bar (default `false`) |
| `extendBodyBehindAppBar` | Boolean | Extend body behind app bar (default `false`) |
| `floatingActionButtonLocation` | String | `centerFloat`, `endFloat`, `centerDocked`, `endDocked`, `centerTop`, `endTop`, `miniCenterFloat`, `miniEndFloat`, `miniCenterDocked`, `miniEndDocked` |
| `appBar` | Widget schema | AppBar widget rendered as `PreferredSizeWidget` |
| `floatingActionButton` | Widget schema | FAB widget |
| `bottomNavigationBar` | Widget schema | Bottom navigation widget |
| `drawer` | Widget schema | Left drawer widget |
| `endDrawer` | Widget schema | Right drawer widget |
| `bottomSheet` | Widget schema | Persistent bottom sheet widget |

`child` — the body widget.

---

### AppBar

Material design app bar for use inside `Scaffold`.

```json
{
  "type": "AppBar",
  "props": {
    "title": "My Screen",
    "centerTitle": true,
    "backgroundColor": "#2196F3",
    "foregroundColor": "#FFFFFF",
    "elevation": 4,
    "automaticallyImplyLeading": true,
    "leading": { "type": "IconButton", "props": { "icon": "menu" } },
    "bottom": { "type": "TabBar", "children": [] }
  },
  "children": []
}
```

| Property | Type | Description |
|----------|------|-------------|
| `title` | String | App bar title text |
| `centerTitle` | Boolean | Center the title |
| `backgroundColor` | String/Number | App bar background color |
| `foregroundColor` | String/Number | Icon and text color |
| `shadowColor` | String/Number | Shadow color |
| `surfaceTintColor` | String/Number | Surface tint color |
| `elevation` | Number | Shadow depth |
| `scrolledUnderElevation` | Number | Elevation when content scrolls under |
| `toolbarHeight` | Number | Custom height |
| `leadingWidth` | Number | Width of the leading widget area |
| `titleSpacing` | Number | Horizontal space around the title |
| `automaticallyImplyLeading` | Boolean | Show back button automatically (default `true`) |
| `leading` | Widget schema | Leading widget (back button area) |
| `flexibleSpace` | Widget schema | Widget behind the toolbar |
| `bottom` | Widget schema | Must be a `PreferredSizeWidget` (e.g. `TabBar`) |

`children` — rendered as `actions` (right-side icon buttons).

---

### SafeArea

Insets its child to avoid OS intrusions (notch, home bar, status bar).

```json
{
  "type": "SafeArea",
  "props": {
    "top": true,
    "bottom": true,
    "left": true,
    "right": true,
    "minimum": 8
  },
  "child": {}
}
```

| Property | Type | Description |
|----------|------|-------------|
| `top` | Boolean | Avoid top intrusion (default `true`) |
| `bottom` | Boolean | Avoid bottom intrusion (default `true`) |
| `left` | Boolean | Avoid left intrusion (default `true`) |
| `right` | Boolean | Avoid right intrusion (default `true`) |
| `minimum` | Number/Object | Minimum inset padding |

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
    "mainAxisSize": "max",
    "clipBehavior": "none"
  },
  "children": []
}
```

| Property | Type | Values |
|----------|------|--------|
| `mainAxisAlignment` | String | `start`, `end`, `center`, `spaceBetween`, `spaceAround`, `spaceEvenly` |
| `crossAxisAlignment` | String | `start`, `end`, `center`, `stretch`, `baseline` |
| `mainAxisSize` | String | `min`, `max` |
| `clipBehavior` | String | `none` (default), `hardEdge`, `antiAlias`, `antiAliasWithSaveLayer` |

---

### Row

Horizontal layout.

```json
{
  "type": "Row",
  "props": {
    "mainAxisAlignment": "spaceBetween",
    "crossAxisAlignment": "center",
    "clipBehavior": "none"
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
    "fit": "loose",
    "clipBehavior": "hardEdge"
  },
  "children": []
}
```

| Property | Type | Values |
|----------|------|--------|
| `alignment` | String | `topLeft`, `topCenter`, `topRight`, `centerLeft`, `center`, `centerRight`, `bottomLeft`, `bottomCenter`, `bottomRight` |
| `fit` | String | `loose`, `expand`, `passthrough` |
| `clipBehavior` | String | `hardEdge` (default), `none`, `antiAlias`, `antiAliasWithSaveLayer` |

---

### Positioned

Positions a child at a specific offset inside a `Stack`.

```json
{
  "type": "Positioned",
  "props": {
    "left": 16,
    "top": 16,
    "right": null,
    "bottom": null,
    "width": 100,
    "height": 50
  },
  "child": {}
}
```

| Property | Type | Description |
|----------|------|-------------|
| `left` | Number | Distance from left edge |
| `top` | Number | Distance from top edge |
| `right` | Number | Distance from right edge |
| `bottom` | Number | Distance from bottom edge |
| `width` | Number | Fixed width |
| `height` | Number | Fixed height |

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

> **Priority:** `paddingLeft/Right/Top/Bottom` > `paddingHorizontal/paddingVertical` > `padding`.

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

Box with styling (background, border, padding, gradient, shadow).

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
    "borderWidth": 2,
    "alignment": "center",
    "clipBehavior": "none"
  },
  "child": {}
}
```

| Property | Type | Description |
|----------|------|-------------|
| `width` | Number | Fixed width |
| `height` | Number | Fixed height |
| `color` | String/Number | Background color (ignored when `gradient` is set) |
| `padding` | Number/Object | Inner padding |
| `margin` | Number/Object | Outer margin |
| `borderRadius` | Number/Object | Corner radius |
| `border` | Boolean | Show border |
| `borderColor` | String/Number | Border color |
| `borderWidth` | Number | Border width |
| `alignment` | String | Child alignment (`topLeft`, `center`, `bottomRight`, etc.) |
| `clipBehavior` | String | `none` (default), `hardEdge`, `antiAlias`, `antiAliasWithSaveLayer` |
| `gradient` | Object | Gradient definition (see Gradient section) |
| `boxShadow` | Object/Array | Shadow(s) |
| `backgroundImage` | String | Network image URL for background |
| `backgroundFit` | String | `fill`, `contain`, `cover`, `fitWidth`, `fitHeight`, `none`, `scaleDown` |

---

### Expanded

Expand child to fill available space inside `Row`/`Column`. Falls back to rendering the child directly if used outside a flex widget.

```json
{
  "type": "Expanded",
  "props": {
    "flex": 2
  },
  "child": {}
}
```

| Property | Type | Description |
|----------|------|-------------|
| `flex` | Number | Flex factor (default: 1, clamped to 1–99999) |

---

### Flexible

Flexible sizing within `Row`/`Column`. Falls back to rendering the child directly if used outside a flex widget.

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
| `flex` | Number | Flex factor (default: 1, clamped to 1–99999) |
| `fit` | String | `tight`, `loose` (default: `tight`) |

---

### Wrap

Wrap children to next line when space runs out.

```json
{
  "type": "Wrap",
  "props": {
    "alignment": "start",
    "spacing": 8,
    "runSpacing": 8
  },
  "children": []
}
```

| Property | Type | Values |
|----------|------|--------|
| `alignment` | String | `start`, `end`, `center`, `spaceBetween`, `spaceAround`, `spaceEvenly` |
| `spacing` | Number | Space between children |
| `runSpacing` | Number | Space between lines |

---

### Spacer

Flexible space in `Row`/`Column`. Falls back to `SizedBox.shrink()` if used outside a flex widget.

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
    "ratio": 1.78
  },
  "child": {}
}
```

| Property | Type | Description |
|----------|------|-------------|
| `ratio` | Number | Width/height ratio. Clamped to 0.1–10; invalid values default to 1.0 |

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
| `fontWeight` | String | `normal`, `bold`, `w100`–`w900` |
| `fontStyle` | String | `normal`, `italic` |
| `color` | String/Number | Text color (hex, named, or integer) |
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
| `color` | String/Number | Icon color (hex, named, or integer) |

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

### CircularProgressIndicator

Circular spinner.

```json
{
  "type": "CircularProgressIndicator",
  "props": {
    "value": 0.7,
    "color": "#2196F3",
    "backgroundColor": "#E3F2FD",
    "strokeWidth": 4.0,
    "strokeCap": "round"
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `value` | Number | 0.0–1.0 for determinate; omit for indeterminate spinner |
| `color` | String/Number | Progress arc color |
| `backgroundColor` | String/Number | Track color |
| `strokeWidth` | Number | Arc stroke width (default `4.0`) |
| `strokeCap` | String | `round`, `square`, `butt` |

---

### LinearProgressIndicator

Horizontal progress bar.

```json
{
  "type": "LinearProgressIndicator",
  "props": {
    "value": 0.5,
    "color": "#2196F3",
    "backgroundColor": "#E3F2FD",
    "minHeight": 4,
    "borderRadius": 4
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `value` | Number | 0.0–1.0 for determinate; omit for indeterminate |
| `color` | String/Number | Progress bar color |
| `backgroundColor` | String/Number | Track color |
| `minHeight` | Number | Bar height |
| `borderRadius` | Number | Rounded ends |

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
  "action": {}
}
```

> `leading` and `trailing` are passed as widget schemas inside `props['leading']` and `props['trailing']`.

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
    "labelStyle": { "color": "#1976D2" },
    "deleteIcon": "close",
    "avatar": "tag"
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `label` | String | Chip label text |
| `backgroundColor` | String/Number | Background color |
| `labelStyle` | Object | Text style map |
| `avatar` | String | Icon name for the avatar slot |
| `deleteIcon` | String | Icon name for the delete slot |
| `borderColor` | String/Number | Outline color |
| `borderWidth` | Number | Outline width |

---

### ClipRRect

Rounded corners clip.

```json
{
  "type": "ClipRRect",
  "props": {
    "borderRadius": 16,
    "clipBehavior": "antiAlias"
  },
  "child": {}
}
```

| Property | Type | Description |
|----------|------|-------------|
| `borderRadius` | Number | Uniform corner radius |
| `clipBehavior` | String | `antiAlias` (default), `hardEdge`, `antiAliasWithSaveLayer`, `none` |

---

### FloatingActionButton

Circular action button, typically placed in `Scaffold.floatingActionButton`.

```json
{
  "type": "FloatingActionButton",
  "props": {
    "icon": "add",
    "label": "New Item",
    "tooltip": "Create",
    "backgroundColor": "#2196F3",
    "foregroundColor": "#FFFFFF",
    "elevation": 6,
    "mini": false
  },
  "action": { "type": "navigate", "route": "/create" }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `icon` | String | Icon name |
| `label` | String | Text label — switches to extended FAB when present |
| `tooltip` | String | Long-press tooltip |
| `backgroundColor` | String/Number | Background color |
| `foregroundColor` | String/Number | Icon/text color |
| `elevation` | Number | Shadow depth |
| `mini` | Boolean | Smaller FAB variant (default `false`) |
| `heroTag` | String | Custom Hero tag; use `"null"` string to disable Hero animation |

---

### ExpansionTile

Collapsible tile with children.

```json
{
  "type": "ExpansionTile",
  "props": {
    "title": "Section Title",
    "subtitle": "Optional subtitle",
    "initiallyExpanded": false,
    "maintainState": false,
    "backgroundColor": "#F5F5F5",
    "collapsedBackgroundColor": "#FFFFFF",
    "textColor": "#2196F3",
    "collapsedTextColor": "#333333",
    "iconColor": "#2196F3",
    "collapsedIconColor": "#757575",
    "tilePadding": 16,
    "childrenPadding": 8,
    "dense": false,
    "expandedAlignment": "center",
    "leading": { "type": "Icon", "props": { "icon": "folder" } },
    "trailing": { "type": "Icon", "props": { "icon": "arrow_forward" } }
  },
  "children": [],
  "action": { "type": "custom", "name": "onExpansionChanged" }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `title` | String | Tile title text |
| `subtitle` | String | Subtitle below the title |
| `initiallyExpanded` | Boolean | Starts expanded (default `false`) |
| `maintainState` | Boolean | Keep children alive when collapsed (default `false`) |
| `backgroundColor` | String/Number | Background when expanded |
| `collapsedBackgroundColor` | String/Number | Background when collapsed |
| `textColor` | String/Number | Title/subtitle color when expanded |
| `collapsedTextColor` | String/Number | Title/subtitle color when collapsed |
| `iconColor` | String/Number | Arrow icon color when expanded |
| `collapsedIconColor` | String/Number | Arrow icon color when collapsed |
| `tilePadding` | Number/Object | Padding inside the tile header |
| `childrenPadding` | Number/Object | Padding around the expanded children |
| `dense` | Boolean | Reduce vertical padding (default `false`) |
| `enableFeedback` | Boolean | Enable haptic/audio feedback |
| `expandedAlignment` | String | Alignment of children when expanded (`topLeft`, `center`, etc.) |
| `leading` | Widget schema | Widget before the title (passed inside `props`) |
| `trailing` | Widget schema | Widget after the title (passed inside `props`) |

`action` — fired on expand/collapse.

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

## Input Widgets

### TextField

Single or multi-line text input.

```json
{
  "type": "TextField",
  "props": {
    "value": "Initial text",
    "hint": "Enter your name",
    "label": "Name",
    "helperText": "We will never share your name",
    "filled": true,
    "fillColor": "#F5F5F5",
    "borderRadius": 8,
    "obscureText": false,
    "enabled": true,
    "readOnly": false,
    "maxLines": 1,
    "minLines": 1,
    "maxLength": 100,
    "keyboardType": "text",
    "textInputAction": "done",
    "textCapitalization": "sentences",
    "textAlign": "left",
    "cursorColor": "#2196F3",
    "autocorrect": true
  },
  "action": { "type": "custom", "name": "onSubmit" }
}
```

| Property | Type | Values / Description |
|----------|------|----------------------|
| `value` | String | Initial text |
| `hint` | String | Placeholder text |
| `label` | String | Floating label |
| `helperText` | String | Helper text below the field |
| `errorText` | String | Error text below the field |
| `prefixText` | String | Text prefix inside the field |
| `suffixText` | String | Text suffix inside the field |
| `prefixIcon` | String | Icon name for prefix |
| `suffixIcon` | String | Icon name for suffix |
| `filled` | Boolean | Fill background (default `false`) |
| `fillColor` | String/Number | Fill color |
| `borderRadius` | Number | Corner radius |
| `obscureText` | Boolean | Hide text (password mode, default `false`) |
| `enabled` | Boolean | Enable/disable input (default `true`) |
| `readOnly` | Boolean | Read-only mode (default `false`) |
| `maxLines` | Number | Maximum lines (default `1`; `null` = unlimited for multiline) |
| `minLines` | Number | Minimum lines |
| `maxLength` | Number | Character limit |
| `keyboardType` | String | `text`, `number`, `email`, `phone`, `multiline`, `url`, `visiblePassword` |
| `textInputAction` | String | `done`, `next`, `search`, `send`, `go`, `newline` |
| `textCapitalization` | String | `none`, `words`, `sentences`, `characters` |
| `textAlign` | String | `left`, `center`, `right`, `justify` |
| `cursorColor` | String/Number | Cursor color |
| `cursorWidth` | Number | Cursor width (default `2.0`) |
| `autocorrect` | Boolean | Enable autocorrect (default `true`) |
| `enableSuggestions` | Boolean | Enable suggestions (default `true`) |
| `onChanged` | Object | Action map fired on every keystroke |
| `style` | Object | Text style map |

`action` — fired when the keyboard action key is pressed (submit).

---

### TextFormField

Like `TextField` but integrates with `Form` / `FormState` for validation.

```json
{
  "type": "TextFormField",
  "props": {
    "hint": "Email address",
    "label": "Email",
    "keyboardType": "email",
    "validators": ["required", "email"]
  }
}
```

Supports all `TextField` props, plus:

| Property | Type | Description |
|----------|------|-------------|
| `validators` | Array | Validation rules applied in order |

**Built-in validators:**

| Rule | Description |
|------|-------------|
| `"required"` | Field must not be empty |
| `"email"` | Must be a valid email address |
| `"numeric"` | Must be a valid number |
| `"minLength:N"` | Minimum N characters (e.g. `"minLength:8"`) |
| `"maxLength:N"` | Maximum N characters |

---

### Switch

Toggle between on/off states.

```json
{
  "type": "Switch",
  "props": {
    "value": false,
    "activeColor": "#2196F3",
    "activeTrackColor": "#BBDEFB",
    "inactiveThumbColor": "#BDBDBD",
    "inactiveTrackColor": "#E0E0E0"
  },
  "action": { "type": "custom", "name": "onToggle" }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `value` | Boolean | Initial state (default `false`) |
| `activeColor` | String/Number | Thumb color when on |
| `activeTrackColor` | String/Number | Track color when on |
| `inactiveThumbColor` | String/Number | Thumb color when off |
| `inactiveTrackColor` | String/Number | Track color when off |

`action` — fired on every toggle.

---

### Checkbox

Tick box for boolean selection.

```json
{
  "type": "Checkbox",
  "props": {
    "value": false,
    "tristate": false,
    "activeColor": "#2196F3",
    "checkColor": "#FFFFFF",
    "fillColor": "#2196F3",
    "borderColor": "#BDBDBD",
    "borderWidth": 2,
    "visualDensity": "standard"
  },
  "action": { "type": "custom", "name": "onCheck" }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `value` | Boolean | Initial state (default `false`) |
| `tristate` | Boolean | Allow `null` intermediate state (default `false`) |
| `activeColor` | String/Number | Fill color when checked |
| `checkColor` | String/Number | Check mark color |
| `fillColor` | String/Number | Fill color (overrides `activeColor` via `WidgetStateProperty`) |
| `borderColor` | String/Number | Outline color when unchecked |
| `borderWidth` | Number | Outline width (default `2.0`) |
| `visualDensity` | String | `compact`, `comfortable`, `standard` |

`action` — fired on every toggle.

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
| `separator` | Boolean | Show dividers between items |

**Variants:** `ListView`, `ListView.builder`, `ListView.separated`, `ListView.custom` — all accept the same props.

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
| `crossAxisCount` | Number | Columns count (clamped to 1+) |
| `mainAxisSpacing` | Number | Vertical spacing |
| `crossAxisSpacing` | Number | Horizontal spacing |
| `childAspectRatio` | Number | Width/height ratio (clamped to 0.01+) |

**Variants:** `GridView`, `GridView.builder`, `GridView.count`, `GridView.extent`, `GridView.custom`.

Use `GridView.extent` with `maxCrossAxisExtent` instead of `crossAxisCount` for responsive grids.

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

## Sliver Widgets

Sliver widgets must be used inside `CustomScrollView`.

### CustomScrollView

Scrollable area composed of slivers.

```json
{
  "type": "CustomScrollView",
  "props": {
    "scrollDirection": "vertical",
    "reverse": false,
    "shrinkWrap": false,
    "physics": "bouncing"
  },
  "children": [
    { "type": "SliverAppBar", "props": { "title": "My App" } },
    { "type": "SliverList", "children": [] }
  ]
}
```

| Property | Type | Values |
|----------|------|--------|
| `scrollDirection` | String | `vertical` (default), `horizontal` |
| `reverse` | Boolean | Reverse scroll direction (default `false`) |
| `shrinkWrap` | Boolean | Shrink to content size (default `false`) |
| `physics` | String | `bouncing`, `clamping`, `never` |

`children` — must be sliver widgets.

---

### SliverAppBar

Collapsible app bar for use inside `CustomScrollView`.

```json
{
  "type": "SliverAppBar",
  "props": {
    "title": "My Screen",
    "expandedHeight": 200,
    "floating": false,
    "pinned": true,
    "snap": false,
    "centerTitle": true,
    "backgroundColor": "#2196F3",
    "foregroundColor": "#FFFFFF",
    "elevation": 4
  },
  "child": { "type": "Image", "props": { "url": "https://..." } }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `title` | String | App bar title |
| `expandedHeight` | Number | Height when fully expanded |
| `floating` | Boolean | Appear on scroll up (default `false`) |
| `pinned` | Boolean | Stay visible when collapsed (default `false`) |
| `snap` | Boolean | Snap fully visible on partial scroll (requires `floating: true`) |
| `centerTitle` | Boolean | Center the title |
| `backgroundColor` | String/Number | Background color |
| `foregroundColor` | String/Number | Text/icon color |
| `elevation` | Number | Shadow depth |

`child` — rendered as `FlexibleSpaceBar.background` (visible in expanded state).

---

### SliverList

Scrollable list inside `CustomScrollView`.

```json
{
  "type": "SliverList",
  "children": [
    { "type": "ListTile", "props": { "title": "Item 1" } },
    { "type": "ListTile", "props": { "title": "Item 2" } }
  ]
}
```

> Add `"id"` to a child's `props` to use a stable key for that item.

---

### SliverGrid

Scrollable grid inside `CustomScrollView`.

```json
{
  "type": "SliverGrid",
  "props": {
    "crossAxisCount": 2,
    "mainAxisSpacing": 8,
    "crossAxisSpacing": 8,
    "childAspectRatio": 1.0
  },
  "children": []
}
```

| Property | Type | Description |
|----------|------|-------------|
| `crossAxisCount` | Number | Fixed columns (clamped to 1+) |
| `maxCrossAxisExtent` | Number | Max item width for responsive layout (alternative to `crossAxisCount`) |
| `mainAxisSpacing` | Number | Vertical spacing |
| `crossAxisSpacing` | Number | Horizontal spacing |
| `childAspectRatio` | Number | Width/height ratio (clamped to 0.01+) |

---

### SliverToBoxAdapter

Wraps a regular (box) widget inside a sliver.

```json
{
  "type": "SliverToBoxAdapter",
  "child": { "type": "Text", "props": { "text": "Header" } }
}
```

---

### SliverPadding

Adds padding around another sliver.

```json
{
  "type": "SliverPadding",
  "props": {
    "padding": 16
  },
  "child": { "type": "SliverList", "children": [] }
}
```

---

### SliverFillRemaining

Fills the remaining space in the viewport.

```json
{
  "type": "SliverFillRemaining",
  "props": {
    "hasScrollBody": false,
    "fillOverscroll": false
  },
  "child": {}
}
```

| Property | Type | Description |
|----------|------|-------------|
| `hasScrollBody` | Boolean | Child is scrollable (default `false`) |
| `fillOverscroll` | Boolean | Extend fill into overscroll area (default `false`) |

---

### SliverFixedExtentList

List where every item has the same height (more efficient than `SliverList` for uniform items).

```json
{
  "type": "SliverFixedExtentList",
  "props": {
    "itemExtent": 72
  },
  "children": []
}
```

| Property | Type | Description |
|----------|------|-------------|
| `itemExtent` | Number | Fixed height per item (default `56`, clamped to 0.1+) |

---

## Navigation Widgets

### BottomNavigationBar

Classic bottom tab bar. Requires at least 2 items.

```json
{
  "type": "BottomNavigationBar",
  "props": {
    "currentIndex": 0,
    "type": "fixed",
    "backgroundColor": "#FFFFFF",
    "selectedItemColor": "#2196F3",
    "unselectedItemColor": "#757575",
    "elevation": 8,
    "showSelectedLabels": true,
    "showUnselectedLabels": true
  },
  "children": [
    {
      "type": "Item",
      "props": { "icon": "home", "label": "Home", "activeIcon": "home" },
      "action": { "type": "navigate", "route": "/home" }
    },
    {
      "type": "Item",
      "props": { "icon": "search", "label": "Search" },
      "action": { "type": "navigate", "route": "/search" }
    }
  ]
}
```

**Bar props:**

| Property | Type | Description |
|----------|------|-------------|
| `currentIndex` | Number | Initially selected tab index (default `0`) |
| `type` | String | `fixed` (default), `shifting` |
| `backgroundColor` | String/Number | Bar background color |
| `selectedItemColor` | String/Number | Selected item color |
| `unselectedItemColor` | String/Number | Unselected item color |
| `elevation` | Number | Shadow depth |
| `iconSize` | Number | Icon size (default `24`) |
| `selectedFontSize` | Number | Selected label font size (default `14`) |
| `unselectedFontSize` | Number | Unselected label font size (default `12`) |
| `showSelectedLabels` | Boolean | Show selected label (default `true`) |
| `showUnselectedLabels` | Boolean | Show unselected labels (default `true`) |

**Per-item props** (in each child's `props`):

| Property | Type | Description |
|----------|------|-------------|
| `icon` | String | Icon name |
| `label` | String | Tab label |
| `activeIcon` | String | Icon name when selected |
| `backgroundColor` | String/Number | Per-item background (shifting type only) |

Each child's `action` is executed when that tab is tapped.

---

### NavigationBar

Material 3 bottom navigation bar.

```json
{
  "type": "NavigationBar",
  "props": {
    "selectedIndex": 0,
    "backgroundColor": "#FFFFFF",
    "indicatorColor": "#E3F2FD",
    "elevation": 3,
    "labelBehavior": "alwaysShow"
  },
  "children": [
    {
      "type": "Destination",
      "props": { "icon": "home", "selectedIcon": "home", "label": "Home" },
      "action": { "type": "navigate", "route": "/home" }
    }
  ]
}
```

**Bar props:**

| Property | Type | Description |
|----------|------|-------------|
| `selectedIndex` | Number | Initially selected index (default `0`) |
| `backgroundColor` | String/Number | Bar background color |
| `indicatorColor` | String/Number | Selection indicator color |
| `shadowColor` | String/Number | Shadow color |
| `surfaceTintColor` | String/Number | Surface tint color |
| `elevation` | Number | Shadow depth |
| `height` | Number | Bar height |
| `animationDuration` | Number | Transition duration in milliseconds |
| `labelBehavior` | String | `alwaysShow`, `alwaysHide`, `onlyShowSelected` |

**Per-destination props** (in each child's `props`):

| Property | Type | Description |
|----------|------|-------------|
| `icon` | String | Icon name (unselected) |
| `selectedIcon` | String | Icon name when selected |
| `label` | String | Destination label |

Each child's `action` is executed when that destination is tapped.

---

### DefaultTabController

Provides a `TabController` to all descendant widgets. Wrap this around a widget tree that contains both a `TabBar` and a `TabBarView`.

```json
{
  "type": "DefaultTabController",
  "props": {
    "length": 3,
    "initialIndex": 0
  },
  "child": {
    "type": "Column",
    "children": [
      {
        "type": "TabBar",
        "children": [
          { "type": "Tab", "props": { "text": "Tab 1" } },
          { "type": "Tab", "props": { "text": "Tab 2" } },
          { "type": "Tab", "props": { "text": "Tab 3" } }
        ]
      },
      {
        "type": "Expanded",
        "child": {
          "type": "TabBarView",
          "children": [
            { "type": "Text", "props": { "text": "Page 1" } },
            { "type": "Text", "props": { "text": "Page 2" } },
            { "type": "Text", "props": { "text": "Page 3" } }
          ]
        }
      }
    ]
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `length` | Number | **Required.** Number of tabs (clamped to 1–999) |
| `initialIndex` | Number | Initially selected tab (default `0`) |

---

### TabBar

Row of tabs. Must be a descendant of `DefaultTabController`.

```json
{
  "type": "TabBar",
  "props": {
    "isScrollable": false,
    "labelColor": "#2196F3",
    "unselectedLabelColor": "#757575",
    "indicatorColor": "#2196F3",
    "indicatorWeight": 2.0,
    "tabAlignment": "fill"
  },
  "children": [
    { "type": "Tab", "props": { "text": "Photos", "icon": "image" } },
    { "type": "Tab", "props": { "text": "Videos", "icon": "camera" } }
  ]
}
```

| Property | Type | Description |
|----------|------|-------------|
| `isScrollable` | Boolean | Scrollable tabs (default `false`) |
| `labelColor` | String/Number | Selected tab label/icon color |
| `unselectedLabelColor` | String/Number | Unselected tab color |
| `indicatorColor` | String/Number | Tab indicator color |
| `indicatorWeight` | Number | Indicator height (default `2.0`, clamped to 0.1+) |
| `dividerColor` | String/Number | Divider line color below the tab bar |
| `padding` | Number | Tab bar padding |
| `tabAlignment` | String | `start`, `startOffset`, `fill`, `center` |

**Per-tab props** (in each child's `props`):

| Property | Type | Description |
|----------|------|-------------|
| `text` | String | Tab label |
| `icon` | String | Icon name shown above/beside the label |

---

### TabBarView

Page view synced with `TabBar`. Must be a descendant of `DefaultTabController`.

```json
{
  "type": "TabBarView",
  "props": {
    "physics": "never"
  },
  "children": []
}
```

| Property | Type | Values |
|----------|------|--------|
| `physics` | String | `never`, `bouncing`, `clamping` |

`children` — one widget per tab page. Count must match `DefaultTabController.length`.

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

| Property | Type | Description |
|----------|------|-------------|
| `opacity` | Number | 0.0–1.0 (clamped) |

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
| `isMediumScreen` | 600px ≤ Width < 1200px |
| `isLargeScreen` | Width ≥ 1200px |
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

Four formats are accepted wherever a color prop appears:

| Format | Example | Notes |
|--------|---------|-------|
| Named | `"color": "blue"` | All Flutter `Colors.*` names (e.g. `red`, `green`, `amber`) |
| `Colors.x` | `"color": "Colors.deepPurple"` | Flutter dot-notation directly |
| Hex `#RRGGBB` | `"color": "#1976D2"` | Standard CSS hex, fully opaque |
| Hex `#AARRGGBB` | `"color": "#FF1976D2"` | With alpha channel |
| Integer | `"color": 4278190080` | Raw Flutter ARGB int (`0xFF000000`) |

**Material shade names** are also supported — append the shade number to the color name:

```
"red50", "red100" … "red900"
"blue50", "blue100" … "blue900"
"deepPurple200", "teal400", "amber700" …
```

**CSS color names** (`navy`, `coral`, `gold`, `salmon`, `teal`, `olive`, `maroon`, `violet`, `indigo`, `crimson`, `turquoise`, `skyblue`, `hotpink`, `lime`, `aqua`, `fuchsia`, `silver`, `gray` / `grey`, …) are recognized as well.

**Common colors quick reference:**

| Color | Named | Hex |
|-------|-------|-----|
| Black | `"black"` | `"#000000"` |
| White | `"white"` | `"#FFFFFF"` |
| Red | `"red"` | `"#FF0000"` |
| Blue | `"blue"` | `"#0000FF"` |
| Green | `"green"` | `"#00FF00"` |
| Grey | `"grey"` | `"#9E9E9E"` |
| Transparent | `"transparent"` | `"#00000000"` |

---

## Best Practices

1. **Keep schemas simple** - Avoid deeply nested structures
2. **Use conditions sparingly** - Prefer responsive layouts over conditional widgets
3. **Cache aggressively** - Use `cacheDuration` for stable content
4. **Handle errors** - Always provide `onError` for API actions
5. **Test on all platforms** - Verify conditions work as expected

---

**Built with Backend-Driven UI**
