/// Localizable validation error messages for backend-driven form fields.
///
/// Override any field before initializing your widget tree to provide
/// translated or custom messages:
///
/// ```dart
/// void main() {
///   BduiValidatorMessages.required = 'Yeh field zaroori hai';
///   BduiValidatorMessages.email = 'Valid email daalo';
///   runApp(MyApp());
/// }
/// ```
class BduiValidatorMessages {
  BduiValidatorMessages._();

  /// Shown when a `required` validator fails.
  static String required = 'This field is required';

  /// Shown when an `email` validator fails.
  static String email = 'Enter a valid email address';

  /// Shown when a `numeric` validator fails.
  static String numeric = 'Enter a valid number';

  /// Shown when a `phone` validator fails.
  static String phone = 'Enter a valid phone number';

  /// Shown when a `url` validator fails.
  static String url = 'Enter a valid URL';

  /// Called to build the `minLength` error message. Override to translate.
  static String Function(int n) minLength =
      (n) => 'Minimum $n characters required';

  /// Called to build the `maxLength` error message. Override to translate.
  static String Function(int n) maxLength =
      (n) => 'Maximum $n characters allowed';

  /// Called to build the `min` (numeric minimum) error message.
  static String Function(num n) min = (n) => 'Must be at least $n';

  /// Called to build the `max` (numeric maximum) error message.
  static String Function(num n) max = (n) => 'Must be at most $n';

  /// Resets all messages back to their English defaults.
  static void reset() {
    required = 'This field is required';
    email = 'Enter a valid email address';
    numeric = 'Enter a valid number';
    phone = 'Enter a valid phone number';
    url = 'Enter a valid URL';
    minLength = (n) => 'Minimum $n characters required';
    maxLength = (n) => 'Maximum $n characters allowed';
    min = (n) => 'Must be at least $n';
    max = (n) => 'Must be at most $n';
  }
}
