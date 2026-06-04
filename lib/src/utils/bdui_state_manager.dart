import 'package:flutter/foundation.dart';

/// Reactive key-value store for backend-driven UI state binding.
///
/// Attach to a [SchemaParser] to enable `${state.key}` interpolation in
/// JSON props and `stateKey` on input widgets. Any widget whose props
/// reference a state key will automatically rebuild when that key changes.
///
/// ```dart
/// final stateManager = BduiStateManager();
/// final parser = SchemaParser(stateManager: stateManager);
///
/// // Read state
/// stateManager.get('username'); // → current value or null
///
/// // Write state (notifies listeners → UI rebuilds)
/// stateManager.set('username', 'Alice');
/// ```
class BduiStateManager extends ChangeNotifier {
  final Map<String, dynamic> _state = {};

  /// Returns the current value for [key], or `null` if not set.
  dynamic get(String key) => _state[key];

  /// Sets [key] to [value] and notifies listeners.
  /// No-op (no notification) when the new value equals the current value.
  void set(String key, dynamic value) {
    if (_state[key] == value) return;
    _state[key] = value;
    notifyListeners();
  }

  /// Merges [values] into state and notifies listeners once — only if at
  /// least one value actually changed.
  void setAll(Map<String, dynamic> values) {
    var changed = false;
    for (final entry in values.entries) {
      if (_state[entry.key] != entry.value) {
        _state[entry.key] = entry.value;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Removes [key] from state and notifies listeners.
  /// No-op when [key] does not exist.
  void remove(String key) {
    if (!_state.containsKey(key)) return;
    _state.remove(key);
    notifyListeners();
  }

  /// Clears all state and notifies listeners.
  void reset() {
    _state.clear();
    notifyListeners();
  }

  /// Returns an unmodifiable snapshot of the current state.
  Map<String, dynamic> get snapshot => Map.unmodifiable(_state);
}
