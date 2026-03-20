import 'package:flutter/material.dart';
import 'package:backend_driven_ui/backend_driven_ui.dart';

/// ============================================================================
/// APP ROUTER - Handles all navigation from backend JSON
/// ============================================================================
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // All screen configs come from "backend"
    final allScreens = BackendScreenConfigs.getAllScreens();
    final routeName = settings.name ?? '/';

    // Home route
    if (routeName == '/') {
      return MaterialPageRoute(
        builder: (_) => const WhatsAppCloneFull(),
        settings: settings,
      );
    }

    // Find screen config for this route
    final screenConfig = allScreens[routeName];
    if (screenConfig == null) {
      return MaterialPageRoute(
        builder: (_) => _ErrorScreen(route: routeName),
      );
    }

    // Build screen from backend config
    return MaterialPageRoute(
      builder: (context) => BackendDrivenScreenWidget(
        config: screenConfig,
        arguments: settings.arguments,
      ),
      settings: settings,
    );
  }
}

/// Error screen for unknown routes
class _ErrorScreen extends StatelessWidget {
  final String route;
  const _ErrorScreen({required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Route not found: $route'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// BACKEND-DRIVEN SCREEN WIDGET - Renders any screen from JSON config
/// ============================================================================
class BackendDrivenScreenWidget extends StatelessWidget {
  final Map<String, dynamic> config;
  final Object? arguments;

  const BackendDrivenScreenWidget({
    super.key,
    required this.config,
    this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    final appBarConfig = config['appBar'] as Map<String, dynamic>?;
    final bodyConfig = config['body'] as Map<String, dynamic>;

    return Scaffold(
      appBar: appBarConfig != null ? _buildAppBar(context, appBarConfig) : null,
      // SchemaWidget now handles actions internally via InkWell/GestureDetector
      body: SchemaWidget.fromJson(bodyConfig),
      floatingActionButton: config['fab'] != null
          ? _buildFAB(context, config['fab'] as Map<String, dynamic>)
          : null,
    );
  }

  AppBar _buildAppBar(BuildContext context, Map<String, dynamic> config) {
    return AppBar(
      title: Text(config['title'] as String? ?? ''),
      backgroundColor: Color(config['backgroundColor'] as int? ?? 0xFF075E54),
      foregroundColor: Color(config['foregroundColor'] as int? ?? 0xFFFFFFFF),
      leading: config['showBack'] == true
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: _buildAppBarActions(context, config['actions'] as List?),
    );
  }

  List<Widget>? _buildAppBarActions(BuildContext context, List? actions) {
    if (actions == null || actions.isEmpty) return null;
    return actions.map<Widget>((action) {
      final actionMap = action as Map<String, dynamic>;
      return IconButton(
        icon: Icon(_getIcon(actionMap['icon'] as String)),
        onPressed: () => _handleAction(context, actionMap['action'] as Map<String, dynamic>?),
      );
    }).toList();
  }

  Widget? _buildFAB(BuildContext context, Map<String, dynamic> fabConfig) {
    return FloatingActionButton(
      onPressed: () => _handleAction(context, fabConfig['action'] as Map<String, dynamic>?),
      backgroundColor: Color(fabConfig['backgroundColor'] as int? ?? 0xFF25D366),
      child: Icon(_getIcon(fabConfig['icon'] as String? ?? 'add'), color: Colors.white),
    );
  }

  void _handleAction(BuildContext context, Map<String, dynamic>? action) {
    if (action == null) return;
    final type = action['type'] as String;
    switch (type) {
      case 'navigate':
        Navigator.of(context).pushNamed(
          action['route'] as String,
          arguments: action['arguments'],
        );
        break;
      case 'pop':
        Navigator.of(context).pop(action['result']);
        break;
      case 'replace':
        Navigator.of(context).pushReplacementNamed(action['route'] as String);
        break;
      case 'showSnackBar':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(action['message'] as String? ?? '')),
        );
        break;
      case 'showDialog':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(action['title'] as String? ?? ''),
            content: Text(action['message'] as String? ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(action['dismissText'] as String? ?? 'OK'),
              ),
            ],
          ),
        );
        break;
    }
  }

  IconData _getIcon(String name) {
    const icons = {
      'arrow_back': Icons.arrow_back,
      'settings': Icons.settings,
      'help': Icons.help_outline,
      'phone': Icons.phone,
      'support': Icons.support_agent,
      'person': Icons.person,
      'edit': Icons.edit,
      'logout': Icons.logout,
      'add': Icons.add,
      'chat': Icons.chat,
      'call': Icons.call,
      'email': Icons.email,
      'lock': Icons.lock,
      'notifications': Icons.notifications,
      'language': Icons.language,
      'dark_mode': Icons.dark_mode,
      'info': Icons.info_outline,
      'privacy': Icons.privacy_tip,
      'verified': Icons.verified_user,
      'security': Icons.security,
      'storage': Icons.storage,
      'qr_code': Icons.qr_code,
      'key': Icons.key,
      'group': Icons.group,
      'history': Icons.history,
      'chevron_right': Icons.chevron_right,
    };
    return icons[name] ?? Icons.help;
  }
}

/// ============================================================================
/// BACKEND SCREEN CONFIGS - All screens defined as JSON (simulating API)
/// ============================================================================
class BackendScreenConfigs {
  static Map<String, Map<String, dynamic>> getAllScreens() {
    return {
      '/profile': _profileScreen(),
      '/phone': _phoneScreen(),
      '/support': _supportScreen(),
      '/account': _accountScreen(),
      '/privacy': _privacyScreen(),
      '/notifications': _notificationsScreen(),
      '/help': _helpScreen(),
      '/about': _aboutScreen(),
    };
  }

  /// PROFILE SCREEN
  static Map<String, dynamic> _profileScreen() {
    return {
      'appBar': {
        'title': 'Profile',
        'backgroundColor': 0xFF075E54,
        'foregroundColor': 0xFFFFFFFF,
        'showBack': true,
        'actions': [
          {'icon': 'edit', 'action': {'type': 'showSnackBar', 'message': 'Edit profile coming soon!'}},
        ],
      },
      'body': {
        'type': 'SingleChildScrollView',
        'child': {
          'type': 'Column',
          'children': [
            // Profile Header
            {
              'type': 'Container',
              'props': {
                'width': double.infinity,
                'padding': 32.0,
                'gradient': {'type': 'linear', 'colors': [0xFF075E54, 0xFF128C7E]},
              },
              'child': {
                'type': 'Column',
                'children': [
                  {
                    'type': 'CircleAvatar',
                    'props': {'radius': 50.0, 'backgroundColor': 0xFFFFFFFF},
                    'child': {'type': 'Icon', 'props': {'icon': 'person', 'size': 60.0, 'color': 0xFF075E54}},
                  },
                  {'type': 'SizedBox', 'props': {'height': 16.0}},
                  {'type': 'Text', 'props': {'text': 'John Doe', 'fontSize': 24.0, 'fontWeight': 'bold', 'color': 0xFFFFFFFF}},
                  {'type': 'SizedBox', 'props': {'height': 4.0}},
                  {'type': 'Text', 'props': {'text': 'Hey there! I am using WhatsApp', 'fontSize': 14.0, 'color': 0xDDFFFFFF}},
                ],
              },
            },
            {'type': 'SizedBox', 'props': {'height': 16.0}},
            // Info Items
            _infoTile('Name', 'John Doe', 'person'),
            {'type': 'Divider', 'props': {'height': 1.0}},
            _infoTile('About', 'Hey there! I am using WhatsApp', 'info'),
            {'type': 'Divider', 'props': {'height': 1.0}},
            _infoTile('Phone', '+1 234 567 8900', 'phone', '/phone'),
            {'type': 'SizedBox', 'props': {'height': 24.0}},
          ],
        },
      },
    };
  }

  /// PHONE NUMBER SCREEN
  static Map<String, dynamic> _phoneScreen() {
    return {
      'appBar': {
        'title': 'Phone Number',
        'backgroundColor': 0xFF075E54,
        'foregroundColor': 0xFFFFFFFF,
        'showBack': true,
      },
      'body': {
        'type': 'SingleChildScrollView',
        'props': {'padding': 16.0},
        'child': {
          'type': 'Column',
          'props': {'crossAxisAlignment': 'start'},
          'children': [
            // Current Number Card
            {
              'type': 'Card',
              'props': {'elevation': 2.0, 'borderRadius': 12.0},
              'child': {
                'type': 'Container',
                'props': {'padding': 20.0},
                'child': {
                  'type': 'Column',
                  'props': {'crossAxisAlignment': 'start'},
                  'children': [
                    {
                      'type': 'Row',
                      'children': [
                        {'type': 'Icon', 'props': {'icon': 'verified', 'color': 0xFF4CAF50, 'size': 24.0}},
                        {'type': 'SizedBox', 'props': {'width': 8.0}},
                        {'type': 'Text', 'props': {'text': 'Current Phone Number', 'fontSize': 14.0, 'color': 0xFF666666}},
                      ],
                    },
                    {'type': 'SizedBox', 'props': {'height': 12.0}},
                    {'type': 'Text', 'props': {'text': '+1 234 567 8900', 'fontSize': 28.0, 'fontWeight': 'bold', 'color': 0xFF075E54}},
                    {'type': 'SizedBox', 'props': {'height': 8.0}},
                    {
                      'type': 'Container',
                      'props': {'padding': {'horizontal': 12.0, 'vertical': 6.0}, 'borderRadius': 16.0, 'color': 0xFFE8F5E9},
                      'child': {'type': 'Text', 'props': {'text': 'Verified', 'fontSize': 12.0, 'color': 0xFF4CAF50, 'fontWeight': 'bold'}},
                    },
                  ],
                },
              },
            },
            {'type': 'SizedBox', 'props': {'height': 24.0}},
            // Change Number Section
            {'type': 'Text', 'props': {'text': 'Change Phone Number', 'fontSize': 18.0, 'fontWeight': 'bold'}},
            {'type': 'SizedBox', 'props': {'height': 8.0}},
            {'type': 'Text', 'props': {'text': 'Changing your phone number will migrate your account info, groups, and settings to your new number.', 'fontSize': 14.0, 'color': 0xFF666666}},
            {'type': 'SizedBox', 'props': {'height': 20.0}},
            // Steps
            _stepItem(1, 'Verify current number', 'We\'ll send OTP to your current phone'),
            _stepItem(2, 'Enter new number', 'Provide your new phone number'),
            _stepItem(3, 'Verify new number', 'Confirm with OTP sent to new number'),
            {'type': 'SizedBox', 'props': {'height': 24.0}},
            // Change Button
            {
              'type': 'InkWell',
              'action': {'type': 'showDialog', 'title': 'Change Number', 'message': 'This feature will be available in the next update!', 'dismissText': 'OK'},
              'child': {
                'type': 'Container',
                'props': {'width': double.infinity, 'padding': 16.0, 'borderRadius': 12.0, 'color': 0xFF075E54},
                'child': {'type': 'Center', 'child': {'type': 'Text', 'props': {'text': 'Change Phone Number', 'fontSize': 16.0, 'fontWeight': 'bold', 'color': 0xFFFFFFFF}}},
              },
            },
            {'type': 'SizedBox', 'props': {'height': 20.0}},
            // Info Box
            {
              'type': 'Container',
              'props': {'padding': 16.0, 'borderRadius': 12.0, 'color': 0xFFFFF8E1},
              'child': {
                'type': 'Row',
                'props': {'crossAxisAlignment': 'start'},
                'children': [
                  {'type': 'Icon', 'props': {'icon': 'info', 'color': 0xFFFF9800, 'size': 24.0}},
                  {'type': 'SizedBox', 'props': {'width': 12.0}},
                  {
                    'type': 'Expanded',
                    'child': {'type': 'Text', 'props': {'text': 'Your phone number is used for account verification and recovery. Keep it up to date.', 'fontSize': 14.0, 'color': 0xFF666666}},
                  },
                ],
              },
            },
          ],
        },
      },
    };
  }

  /// SUPPORT SCREEN
  static Map<String, dynamic> _supportScreen() {
    return {
      'appBar': {
        'title': 'Help & Support',
        'backgroundColor': 0xFF075E54,
        'foregroundColor': 0xFFFFFFFF,
        'showBack': true,
      },
      'body': {
        'type': 'SingleChildScrollView',
        'child': {
          'type': 'Column',
          'children': [
            // Header
            {
              'type': 'Container',
              'props': {'width': double.infinity, 'padding': 32.0, 'gradient': {'type': 'linear', 'colors': [0xFF075E54, 0xFF25D366]}},
              'child': {
                'type': 'Column',
                'children': [
                  {'type': 'Icon', 'props': {'icon': 'support', 'size': 64.0, 'color': 0xFFFFFFFF}},
                  {'type': 'SizedBox', 'props': {'height': 16.0}},
                  {'type': 'Text', 'props': {'text': 'How can we help?', 'fontSize': 24.0, 'fontWeight': 'bold', 'color': 0xFFFFFFFF}},
                  {'type': 'SizedBox', 'props': {'height': 8.0}},
                  {'type': 'Text', 'props': {'text': 'Choose a topic below or contact us', 'fontSize': 14.0, 'color': 0xDDFFFFFF}},
                ],
              },
            },
            {'type': 'SizedBox', 'props': {'height': 16.0}},
            // Support Options
            {
              'type': 'Padding',
              'props': {'padding': 16.0},
              'child': {
                'type': 'Column',
                'children': [
                  _supportCard('FAQ', 'Find answers to common questions', 'help', 0xFF4CAF50, '/help'),
                  {'type': 'SizedBox', 'props': {'height': 12.0}},
                  _supportCard('Contact Us', 'Chat with our support team', 'chat', 0xFF2196F3, null),
                  {'type': 'SizedBox', 'props': {'height': 12.0}},
                  _supportCard('Report a Problem', 'Help us improve the app', 'email', 0xFFF44336, null),
                  {'type': 'SizedBox', 'props': {'height': 12.0}},
                  _supportCard('About', 'App info and licenses', 'info', 0xFF9C27B0, '/about'),
                ],
              },
            },
            // Contact Info
            {
              'type': 'Container',
              'props': {'margin': 16.0, 'padding': 16.0, 'borderRadius': 12.0, 'color': 0xFFF5F5F5},
              'child': {
                'type': 'Column',
                'children': [
                  {'type': 'Text', 'props': {'text': 'Need immediate help?', 'fontSize': 16.0, 'fontWeight': 'bold'}},
                  {'type': 'SizedBox', 'props': {'height': 8.0}},
                  {
                    'type': 'Row',
                    'props': {'mainAxisAlignment': 'center'},
                    'children': [
                      {'type': 'Icon', 'props': {'icon': 'email', 'color': 0xFF666666, 'size': 20.0}},
                      {'type': 'SizedBox', 'props': {'width': 8.0}},
                      {'type': 'Text', 'props': {'text': 'support@whatsapp.com', 'fontSize': 14.0, 'color': 0xFF075E54}},
                    ],
                  },
                ],
              },
            },
          ],
        },
      },
    };
  }

  /// ACCOUNT SCREEN
  static Map<String, dynamic> _accountScreen() {
    return {
      'appBar': {
        'title': 'Account',
        'backgroundColor': 0xFF075E54,
        'foregroundColor': 0xFFFFFFFF,
        'showBack': true,
      },
      'body': {
        'type': 'ListView',
        'children': [
          _settingsNavItem('Privacy', 'Last seen, profile photo, about', 'privacy', '/privacy'),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _settingsNavItem('Security', 'Security notifications, app lock', 'security', null),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _settingsNavItem('Two-Step Verification', 'Add extra security to your account', 'lock', null),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _settingsNavItem('Change Number', 'Change your registered phone number', 'phone', '/phone'),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _settingsNavItem('Request Account Info', 'Request a report of your account', 'info', null),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _settingsNavItem('Delete My Account', 'Delete your account permanently', 'person', null),
        ],
      },
    };
  }

  /// PRIVACY SCREEN
  static Map<String, dynamic> _privacyScreen() {
    return {
      'appBar': {
        'title': 'Privacy',
        'backgroundColor': 0xFF075E54,
        'foregroundColor': 0xFFFFFFFF,
        'showBack': true,
      },
      'body': {
        'type': 'ListView',
        'children': [
          _sectionHeader('Who can see my personal info'),
          _privacyOption('Last Seen', 'Everyone'),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _privacyOption('Profile Photo', 'My Contacts'),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _privacyOption('About', 'Everyone'),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _privacyOption('Status', 'My Contacts'),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _privacyOption('Read Receipts', 'On'),
          _sectionHeader('Disappearing Messages'),
          _privacyOption('Default Message Timer', 'Off'),
          _sectionHeader('Advanced'),
          _privacyOption('Fingerprint Lock', 'Disabled'),
          {'type': 'SizedBox', 'props': {'height': 24.0}},
        ],
      },
    };
  }

  /// NOTIFICATIONS SCREEN
  static Map<String, dynamic> _notificationsScreen() {
    return {
      'appBar': {
        'title': 'Notifications',
        'backgroundColor': 0xFF075E54,
        'foregroundColor': 0xFFFFFFFF,
        'showBack': true,
      },
      'body': {
        'type': 'ListView',
        'children': [
          _sectionHeader('Message Notifications'),
          _toggleOption('Notification Tone', 'Default'),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _toggleOption('Vibrate', 'Default'),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _toggleOption('Popup Notification', 'Only when screen is off'),
          _sectionHeader('Group Notifications'),
          _toggleOption('Notification Tone', 'Default'),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _toggleOption('Vibrate', 'Default'),
          _sectionHeader('Calls'),
          _toggleOption('Ringtone', 'Default'),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _toggleOption('Vibrate', 'Default'),
          {'type': 'SizedBox', 'props': {'height': 24.0}},
        ],
      },
    };
  }

  /// HELP SCREEN (FAQ)
  static Map<String, dynamic> _helpScreen() {
    return {
      'appBar': {
        'title': 'Help Center',
        'backgroundColor': 0xFF075E54,
        'foregroundColor': 0xFFFFFFFF,
        'showBack': true,
      },
      'body': {
        'type': 'ListView',
        'children': [
          _faqItem('How do I change my phone number?', 'Go to Settings > Account > Change Number. You\'ll need to verify both your old and new numbers.'),
          _faqItem('How do I back up my chats?', 'Go to Settings > Chats > Chat Backup. You can set up automatic backups to Google Drive or iCloud.'),
          _faqItem('How do I block a contact?', 'Open the chat, tap the contact name, scroll down and tap "Block". They won\'t be able to send you messages.'),
          _faqItem('How do I enable two-step verification?', 'Go to Settings > Account > Two-Step Verification > Enable. Create a 6-digit PIN.'),
          _faqItem('Can I use WhatsApp on multiple devices?', 'Yes! Go to Settings > Linked Devices to connect up to 4 additional devices.'),
          {'type': 'SizedBox', 'props': {'height': 24.0}},
        ],
      },
    };
  }

  /// ABOUT SCREEN
  static Map<String, dynamic> _aboutScreen() {
    return {
      'appBar': {
        'title': 'About',
        'backgroundColor': 0xFF075E54,
        'foregroundColor': 0xFFFFFFFF,
        'showBack': true,
      },
      'body': {
        'type': 'SingleChildScrollView',
        'child': {
          'type': 'Column',
          'children': [
            {'type': 'SizedBox', 'props': {'height': 40.0}},
            {
              'type': 'Center',
              'child': {
                'type': 'Column',
                'children': [
                  {
                    'type': 'Container',
                    'props': {'width': 100.0, 'height': 100.0, 'borderRadius': 20.0, 'gradient': {'type': 'linear', 'colors': [0xFF25D366, 0xFF128C7E]}},
                    'child': {'type': 'Center', 'child': {'type': 'Icon', 'props': {'icon': 'chat', 'size': 50.0, 'color': 0xFFFFFFFF}}},
                  },
                  {'type': 'SizedBox', 'props': {'height': 16.0}},
                  {'type': 'Text', 'props': {'text': 'WhatsApp Clone', 'fontSize': 24.0, 'fontWeight': 'bold'}},
                  {'type': 'SizedBox', 'props': {'height': 4.0}},
                  {'type': 'Text', 'props': {'text': 'Version 2.24.0', 'fontSize': 14.0, 'color': 0xFF666666}},
                ],
              },
            },
            {'type': 'SizedBox', 'props': {'height': 40.0}},
            _aboutItem('Powered by', 'Backend-Driven UI'),
            {'type': 'Divider', 'props': {'height': 1.0}},
            _aboutItem('Platform', 'Flutter'),
            {'type': 'Divider', 'props': {'height': 1.0}},
            _aboutItem('License', 'MIT License'),
            {'type': 'SizedBox', 'props': {'height': 32.0}},
            {
              'type': 'Center',
              'child': {'type': 'Text', 'props': {'text': 'Built with Backend-Driven UI Framework', 'fontSize': 12.0, 'color': 0xFF999999}},
            },
            {'type': 'SizedBox', 'props': {'height': 8.0}},
            {
              'type': 'Center',
              'child': {'type': 'Text', 'props': {'text': 'Multi-screen navigation via JSON', 'fontSize': 12.0, 'fontWeight': 'bold', 'color': 0xFF075E54}},
            },
            {'type': 'SizedBox', 'props': {'height': 24.0}},
          ],
        },
      },
    };
  }

  // ===== HELPER WIDGET BUILDERS =====

  static Map<String, dynamic> _infoTile(String label, String value, String icon, [String? route]) {
    final List<Map<String, dynamic>> rowChildren = [
      {'type': 'Icon', 'props': {'icon': icon, 'color': 0xFF075E54, 'size': 24.0}},
      {'type': 'SizedBox', 'props': {'width': 16.0}},
      {
        'type': 'Expanded',
        'child': {
          'type': 'Column',
          'props': {'crossAxisAlignment': 'start'},
          'children': [
            {'type': 'Text', 'props': {'text': label, 'fontSize': 12.0, 'color': 0xFF666666}},
            {'type': 'Text', 'props': {'text': value, 'fontSize': 16.0}},
          ],
        },
      },
    ];
    if (route != null) {
      rowChildren.add({'type': 'Icon', 'props': {'icon': 'chevron_right', 'color': 0xFFCCCCCC}});
    }

    final child = {
      'type': 'Container',
      'props': {'padding': 16.0},
      'child': {
        'type': 'Row',
        'children': rowChildren,
      },
    };
    if (route != null) {
      return {'type': 'InkWell', 'action': {'type': 'navigate', 'route': route}, 'child': child};
    }
    return child;
  }

  static Map<String, dynamic> _stepItem(int number, String title, String subtitle) {
    return {
      'type': 'Container',
      'props': {'padding': {'vertical': 8.0}},
      'child': {
        'type': 'Row',
        'props': {'crossAxisAlignment': 'start'},
        'children': [
          {
            'type': 'Container',
            'props': {'width': 28.0, 'height': 28.0, 'borderRadius': 14.0, 'color': 0xFF075E54},
            'child': {'type': 'Center', 'child': {'type': 'Text', 'props': {'text': number.toString(), 'fontSize': 14.0, 'fontWeight': 'bold', 'color': 0xFFFFFFFF}}},
          },
          {'type': 'SizedBox', 'props': {'width': 12.0}},
          {
            'type': 'Expanded',
            'child': {
              'type': 'Column',
              'props': {'crossAxisAlignment': 'start'},
              'children': [
                {'type': 'Text', 'props': {'text': title, 'fontSize': 16.0, 'fontWeight': 'w500'}},
                {'type': 'Text', 'props': {'text': subtitle, 'fontSize': 13.0, 'color': 0xFF666666}},
              ],
            },
          },
        ],
      },
    };
  }

  static Map<String, dynamic> _supportCard(String title, String subtitle, String icon, int color, String? route) {
    final action = route != null
        ? {'type': 'navigate', 'route': route}
        : {'type': 'showSnackBar', 'message': '$title - Coming soon!'};
    return {
      'type': 'InkWell',
      'action': action,
      'child': {
        'type': 'Card',
        'props': {'elevation': 1.0, 'borderRadius': 12.0},
        'child': {
          'type': 'Container',
          'props': {'padding': 16.0},
          'child': {
            'type': 'Row',
            'children': [
              {
                'type': 'Container',
                'props': {'width': 48.0, 'height': 48.0, 'borderRadius': 12.0, 'color': color},
                'child': {'type': 'Center', 'child': {'type': 'Icon', 'props': {'icon': icon, 'color': 0xFFFFFFFF, 'size': 24.0}}},
              },
              {'type': 'SizedBox', 'props': {'width': 16.0}},
              {
                'type': 'Expanded',
                'child': {
                  'type': 'Column',
                  'props': {'crossAxisAlignment': 'start'},
                  'children': [
                    {'type': 'Text', 'props': {'text': title, 'fontSize': 16.0, 'fontWeight': 'bold'}},
                    {'type': 'Text', 'props': {'text': subtitle, 'fontSize': 13.0, 'color': 0xFF666666}},
                  ],
                },
              },
              {'type': 'Icon', 'props': {'icon': 'chevron_right', 'color': 0xFFCCCCCC}},
            ],
          },
        },
      },
    };
  }

  static Map<String, dynamic> _settingsNavItem(String title, String subtitle, String icon, String? route) {
    final action = route != null
        ? {'type': 'navigate', 'route': route}
        : {'type': 'showSnackBar', 'message': '$title - Coming soon!'};
    return {
      'type': 'InkWell',
      'action': action,
      'child': {
        'type': 'Container',
        'props': {'padding': 16.0},
        'child': {
          'type': 'Row',
          'children': [
            {'type': 'Icon', 'props': {'icon': icon, 'color': 0xFF075E54, 'size': 24.0}},
            {'type': 'SizedBox', 'props': {'width': 16.0}},
            {
              'type': 'Expanded',
              'child': {
                'type': 'Column',
                'props': {'crossAxisAlignment': 'start'},
                'children': [
                  {'type': 'Text', 'props': {'text': title, 'fontSize': 16.0}},
                  {'type': 'Text', 'props': {'text': subtitle, 'fontSize': 13.0, 'color': 0xFF666666}},
                ],
              },
            },
            {'type': 'Icon', 'props': {'icon': 'chevron_right', 'color': 0xFFCCCCCC}},
          ],
        },
      },
    };
  }

  static Map<String, dynamic> _sectionHeader(String title) {
    return {
      'type': 'Container',
      'props': {'padding': {'horizontal': 16.0, 'vertical': 12.0}, 'color': 0xFFF5F5F5},
      'child': {'type': 'Text', 'props': {'text': title, 'fontSize': 14.0, 'fontWeight': 'bold', 'color': 0xFF075E54}},
    };
  }

  static Map<String, dynamic> _privacyOption(String title, String value) {
    return {
      'type': 'InkWell',
      'action': {'type': 'showSnackBar', 'message': 'Privacy setting: $title'},
      'child': {
        'type': 'Container',
        'props': {'padding': 16.0},
        'child': {
          'type': 'Row',
          'children': [
            {'type': 'Expanded', 'child': {'type': 'Text', 'props': {'text': title, 'fontSize': 16.0}}},
            {'type': 'Text', 'props': {'text': value, 'fontSize': 14.0, 'color': 0xFF666666}},
          ],
        },
      },
    };
  }

  static Map<String, dynamic> _toggleOption(String title, String value) {
    return {
      'type': 'InkWell',
      'action': {'type': 'showSnackBar', 'message': 'Notification setting: $title'},
      'child': {
        'type': 'Container',
        'props': {'padding': 16.0},
        'child': {
          'type': 'Row',
          'children': [
            {'type': 'Expanded', 'child': {'type': 'Text', 'props': {'text': title, 'fontSize': 16.0}}},
            {'type': 'Text', 'props': {'text': value, 'fontSize': 14.0, 'color': 0xFF666666}},
          ],
        },
      },
    };
  }

  static Map<String, dynamic> _faqItem(String question, String answer) {
    return {
      'type': 'Container',
      'props': {'padding': 16.0},
      'child': {
        'type': 'Column',
        'props': {'crossAxisAlignment': 'start'},
        'children': [
          {'type': 'Text', 'props': {'text': question, 'fontSize': 16.0, 'fontWeight': 'bold'}},
          {'type': 'SizedBox', 'props': {'height': 8.0}},
          {'type': 'Text', 'props': {'text': answer, 'fontSize': 14.0, 'color': 0xFF666666}},
          {'type': 'SizedBox', 'props': {'height': 8.0}},
          {'type': 'Divider', 'props': {'height': 1.0}},
        ],
      },
    };
  }

  static Map<String, dynamic> _aboutItem(String label, String value) {
    return {
      'type': 'Container',
      'props': {'padding': 16.0},
      'child': {
        'type': 'Row',
        'props': {'mainAxisAlignment': 'spaceBetween'},
        'children': [
          {'type': 'Text', 'props': {'text': label, 'fontSize': 14.0, 'color': 0xFF666666}},
          {'type': 'Text', 'props': {'text': value, 'fontSize': 14.0, 'fontWeight': 'w500'}},
        ],
      },
    };
  }
}

/// ============================================================================
/// WHATSAPP CLONE - Home screen with tabs
/// ============================================================================

/// TRULY ZERO DEPENDENCY WhatsApp Clone
/// Everything comes from API - AppBar, Tabs, Content, FAB - EVERYTHING!
class WhatsAppCloneFull extends StatefulWidget {
  const WhatsAppCloneFull({super.key});

  @override
  State<WhatsAppCloneFull> createState() => _WhatsAppCloneFullState();
}

class _WhatsAppCloneFullState extends State<WhatsAppCloneFull> {
  String _variant = 'A';
  Map<String, dynamic>? _appConfig;

  @override
  void initState() {
    super.initState();
    _loadAppConfig();
  }

  void _loadAppConfig() {
    // In real app, this comes from: BackendDrivenScreen(endpoint: '/api/app/config')
    // Backend returns ENTIRE app structure - tabs, screens, everything!
    setState(() {
      _appConfig = _getBackendConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_appConfig == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _WhatsAppScaffold(
      config: _appConfig!,
      variant: _variant,
      onVariantChange: (v) => setState(() => _variant = v),
    );
  }

  /// THIS ENTIRE CONFIG COMES FROM BACKEND API
  /// Endpoint: /api/app/whatsapp-config
  Map<String, dynamic> _getBackendConfig() {
    return {
      'appName': 'WhatsApp',
      'theme': {
        'primaryColor': 0xFF075E54,
        'accentColor': 0xFF25D366,
        'backgroundColor': 0xFFFFFFFF,
      },
      'appBar': {
        'title': 'WhatsApp',
        'backgroundColor': 0xFF075E54,
        'foregroundColor': 0xFFFFFFFF,
        'actions': [
          {'icon': 'search', 'action': 'search'},
          {'icon': 'science', 'action': 'ab_test'},
        ],
      },
      'tabs': [
        {
          'id': 'chats',
          'label': 'CHATS',
          'icon': 'chat',
          'screen': 'chats',
          'fab': {'icon': 'person', 'action': 'new_chat'},
        },
        {
          'id': 'status',
          'label': 'STATUS',
          'icon': 'favorite',
          'screen': 'status',
          'fab': {'icon': 'person', 'action': 'add_status'},
        },
        {
          'id': 'calls',
          'label': 'CALLS',
          'icon': 'call',
          'screen': 'calls',
          'fab': {'icon': 'call', 'action': 'new_call'},
        },
        {
          'id': 'settings',
          'label': 'SETTINGS',
          'icon': 'settings',
          'screen': 'settings',
          'fab': null, // No FAB for settings
        },
      ],
      'screens': {
        'chats': _getChatsScreenConfig(),
        'status': _getStatusScreenConfig(),
        'calls': _getCallsScreenConfig(),
        'settings': _getSettingsScreenConfig(),
      },
    };
  }

  Map<String, dynamic> _getChatsScreenConfig() {
    return {
      'variantA': {
        'type': 'ListView',
        'children': [
          _chatTile('Mom ❤️', 'Don\'t forget groceries!', '10:30 AM', 2, 0xFFE91E63),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _chatTile('Work Group', 'John: Meeting at 3 PM', '9:45 AM', 5, 0xFF2196F3),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _chatTile('Best Friend', 'Haha! 😂', 'Yesterday', 0, 0xFF9C27B0),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _chatTile('Dad', 'Coming late tonight', 'Yesterday', 0, 0xFFFF9800),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _chatTile('Gym Buddy 💪', 'Tomorrow 6 AM?', 'Tuesday', 0, 0xFF4CAF50),
          {'type': 'Divider', 'props': {'height': 1.0}},
          _chatTile('College Group', '25 new messages', 'Tuesday', 25, 0xFF00BCD4),
        ],
      },
      'variantB': {
        'type': 'SingleChildScrollView',
        'props': {'padding': 12.0},
        'child': {
          'type': 'Column',
          'children': [
            {'type': 'Text', 'props': {'text': '⭐ Priority', 'fontWeight': 'bold', 'fontSize': 14.0}},
            {'type': 'SizedBox', 'props': {'height': 8.0}},
            _chatCard('Mom ❤️', 'Don\'t forget groceries!', '10:30 AM', 2, 0xFFE91E63, true),
            _chatCard('Work Group', 'John: Meeting at 3 PM', '9:45 AM', 5, 0xFF2196F3, true),
            {'type': 'SizedBox', 'props': {'height': 16.0}},
            {'type': 'Text', 'props': {'text': '💬 Recent', 'fontWeight': 'bold', 'fontSize': 14.0}},
            {'type': 'SizedBox', 'props': {'height': 8.0}},
            _chatCard('Best Friend', 'Haha! 😂', 'Yesterday', 0, 0xFF9C27B0, false),
            _chatCard('Dad', 'Coming late tonight', 'Yesterday', 0, 0xFFFF9800, false),
            _chatCard('Gym Buddy 💪', 'Tomorrow 6 AM?', 'Tuesday', 0, 0xFF4CAF50, false),
            _chatCard('College Group', '25 new messages', 'Tuesday', 25, 0xFF00BCD4, false),
          ],
        },
      },
    };
  }

  Map<String, dynamic> _getStatusScreenConfig() {
    return {
      'type': 'SingleChildScrollView',
      'props': {'padding': 16.0},
      'child': {
        'type': 'Column',
        'children': [
          // My Status
          {
            'type': 'InkWell',
            'props': {'onTap': true},
            'child': {
              'type': 'Row',
              'children': [
                {
                  'type': 'CircleAvatar',
                  'props': {'radius': 32.0, 'backgroundColor': 0xFF9E9E9E},
                  'child': {'type': 'Icon', 'props': {'icon': 'person', 'color': 0xFFFFFFFF}},
                },
                {'type': 'SizedBox', 'props': {'width': 16.0}},
                {
                  'type': 'Expanded',
                  'child': {
                    'type': 'Column',
                    'props': {'crossAxisAlignment': 'start'},
                    'children': [
                      {'type': 'Text', 'props': {'text': 'My Status', 'fontWeight': 'bold', 'fontSize': 16.0}},
                      {'type': 'Text', 'props': {'text': 'Tap to add status update', 'fontSize': 14.0, 'color': 0xFF666666}},
                    ],
                  },
                },
              ],
            },
          },
          {'type': 'SizedBox', 'props': {'height': 24.0}},
          {'type': 'Text', 'props': {'text': 'Recent updates', 'fontSize': 14.0, 'fontWeight': 'bold'}},
          {'type': 'SizedBox', 'props': {'height': 16.0}},
          _statusTile('Mom ❤️', 'Today, 9:30 AM', 0xFFE91E63),
          _statusTile('Best Friend', 'Today, 8:15 AM', 0xFF9C27B0),
          _statusTile('Dad', 'Yesterday, 6:45 PM', 0xFFFF9800),
        ],
      },
    };
  }

  Map<String, dynamic> _getCallsScreenConfig() {
    return {
      'type': 'ListView',
      'children': [
        _callTile('Mom ❤️', 'Today, 10:30 AM', false, false, 0xFFE91E63),
        {'type': 'Divider', 'props': {'height': 1.0}},
        _callTile('Dad', 'Today, 9:15 AM', false, true, 0xFFFF9800),
        {'type': 'Divider', 'props': {'height': 1.0}},
        _callTile('Best Friend', 'Yesterday, 8:45 PM', false, false, 0xFF9C27B0),
        {'type': 'Divider', 'props': {'height': 1.0}},
        _callTile('Gym Buddy 💪', '15/03/2024', false, false, 0xFF4CAF50),
      ],
    };
  }

  Map<String, dynamic> _getSettingsScreenConfig() {
    return {
      'type': 'ListView',
      'children': [
        // Profile - navigates to /profile
        {
          'type': 'InkWell',
          'action': {'type': 'navigate', 'route': '/profile'},
          'child': {
            'type': 'Container',
            'props': {'padding': 16.0},
            'child': {
              'type': 'Row',
              'children': [
                {
                  'type': 'CircleAvatar',
                  'props': {'radius': 36.0, 'backgroundColor': 0xFF075E54},
                  'child': {'type': 'Icon', 'props': {'icon': 'person', 'size': 40.0, 'color': 0xFFFFFFFF}},
                },
                {'type': 'SizedBox', 'props': {'width': 16.0}},
                {
                  'type': 'Expanded',
                  'child': {
                    'type': 'Column',
                    'props': {'crossAxisAlignment': 'start'},
                    'children': [
                      {'type': 'Text', 'props': {'text': 'John Doe', 'fontSize': 18.0, 'fontWeight': 'bold'}},
                      {'type': 'Text', 'props': {'text': 'Hey there! I am using WhatsApp', 'fontSize': 14.0, 'color': 0xFF666666}},
                    ],
                  },
                },
                {'type': 'Icon', 'props': {'icon': 'qr_code', 'color': 0xFF075E54, 'size': 24.0}},
              ],
            },
          },
        },
        {'type': 'Divider', 'props': {'height': 8.0, 'thickness': 8.0, 'color': 0xFFF5F5F5}},
        // Settings items with navigation
        _settingsTile('Account', 'Privacy, security, change number', 'key', '/account'),
        _settingsTile('Privacy', 'Last seen, profile photo, about', 'lock', '/privacy'),
        _settingsTile('Chats', 'Theme, wallpapers, chat history', 'chat', null),
        _settingsTile('Notifications', 'Message, group & call tones', 'notifications', '/notifications'),
        _settingsTile('Storage and data', 'Network usage, auto-download', 'storage', null),
        _settingsTile('Help', 'Help center, contact us, privacy policy', 'help', '/support'),
        {'type': 'Divider', 'props': {'height': 8.0, 'thickness': 8.0, 'color': 0xFFF5F5F5}},
        _settingsTile('Invite a friend', 'Share WhatsApp with friends', 'group', null),
        {'type': 'SizedBox', 'props': {'height': 16.0}},
        {
          'type': 'Center',
          'child': {'type': 'Text', 'props': {'text': 'from BACKEND DRIVEN UI', 'fontSize': 12.0, 'fontWeight': 'bold', 'color': 0xFF075E54}},
        },
        {'type': 'SizedBox', 'props': {'height': 8.0}},
        {
          'type': 'Center',
          'child': {'type': 'Text', 'props': {'text': 'Tap any item to navigate!', 'fontSize': 11.0, 'color': 0xFF999999}},
        },
        {'type': 'SizedBox', 'props': {'height': 16.0}},
      ],
    };
  }

  // Helper builders
  Map<String, dynamic> _chatTile(String name, String msg, String time, int unread, int color) {
    return {
      'type': 'InkWell',
      'props': {'onTap': true},
      'child': {
        'type': 'Container',
        'props': {'padding': 16.0},
        'child': {
          'type': 'Row',
          'children': [
            {
              'type': 'CircleAvatar',
              'props': {'radius': 28.0, 'backgroundColor': color},
              'child': {'type': 'Icon', 'props': {'icon': 'favorite', 'color': 0xFFFFFFFF}},
            },
            {'type': 'SizedBox', 'props': {'width': 12.0}},
            {
              'type': 'Expanded',
              'child': {
                'type': 'Column',
                'props': {'crossAxisAlignment': 'start'},
                'children': [
                  {
                    'type': 'Row',
                    'props': {'mainAxisAlignment': 'spaceBetween'},
                    'children': [
                      {'type': 'Text', 'props': {'text': name, 'fontWeight': 'bold', 'fontSize': 16.0}},
                      {'type': 'Text', 'props': {'text': time, 'fontSize': 12.0, 'color': 0xFF999999}},
                    ],
                  },
                  {
                    'type': 'Row',
                    'props': {'mainAxisAlignment': 'spaceBetween'},
                    'children': [
                      {'type': 'Expanded', 'child': {'type': 'Text', 'props': {'text': msg, 'fontSize': 14.0, 'color': 0xFF666666, 'maxLines': 1}}},
                      if (unread > 0)
                        {
                          'type': 'Container',
                          'props': {'width': 24.0, 'height': 24.0, 'borderRadius': 12.0, 'color': 0xFF25D366},
                          'child': {'type': 'Center', 'child': {'type': 'Text', 'props': {'text': unread.toString(), 'fontSize': 12.0, 'color': 0xFFFFFFFF, 'fontWeight': 'bold'}}},
                        },
                    ],
                  },
                ],
              },
            },
          ],
        },
      },
    };
  }

  Map<String, dynamic> _chatCard(String name, String msg, String time, int unread, int color, bool priority) {
    return {
      'type': 'Card',
      'props': {'elevation': 2.0, 'margin': {'bottom': 8.0}, 'borderRadius': 12.0},
      'child': {
        'type': 'InkWell',
        'props': {'onTap': true},
        'child': {
          'type': 'Container',
          'props': {
            'padding': 12.0,
            'gradient': priority ? {'type': 'linear', 'colors': [0xFFFFF8E1, 0xFFFFFFFF]} : null,
          },
          'child': {
            'type': 'Row',
            'children': [
              {
                'type': 'CircleAvatar',
                'props': {'radius': 32.0, 'backgroundColor': color},
                'child': {'type': 'Icon', 'props': {'icon': 'favorite', 'color': 0xFFFFFFFF, 'size': 28.0}},
              },
              {'type': 'SizedBox', 'props': {'width': 12.0}},
              {
                'type': 'Expanded',
                'child': {
                  'type': 'Column',
                  'props': {'crossAxisAlignment': 'start'},
                  'children': [
                    {'type': 'Text', 'props': {'text': name, 'fontWeight': 'bold', 'fontSize': 17.0}},
                    {'type': 'Text', 'props': {'text': msg, 'fontSize': 14.0, 'color': 0xFF666666}},
                    if (unread > 0)
                      {
                        'type': 'Container',
                        'props': {'padding': {'horizontal': 8.0, 'vertical': 4.0}, 'borderRadius': 12.0, 'gradient': {'type': 'linear', 'colors': [0xFF25D366, 0xFF128C7E]}},
                        'child': {'type': 'Text', 'props': {'text': '$unread new', 'fontSize': 11.0, 'color': 0xFFFFFFFF}},
                      },
                  ],
                },
              },
            ],
          },
        },
      },
    };
  }

  Map<String, dynamic> _statusTile(String name, String time, int color) {
    return {
      'type': 'InkWell',
      'props': {'onTap': true},
      'child': {
        'type': 'Container',
        'props': {'padding': {'vertical': 12.0}},
        'child': {
          'type': 'Row',
          'children': [
            {
              'type': 'CircleAvatar',
              'props': {'radius': 32.0, 'backgroundColor': color},
              'child': {'type': 'Icon', 'props': {'icon': 'favorite', 'color': 0xFFFFFFFF}},
            },
            {'type': 'SizedBox', 'props': {'width': 16.0}},
            {
              'type': 'Expanded',
              'child': {
                'type': 'Column',
                'props': {'crossAxisAlignment': 'start'},
                'children': [
                  {'type': 'Text', 'props': {'text': name, 'fontWeight': 'bold', 'fontSize': 16.0}},
                  {'type': 'Text', 'props': {'text': time, 'fontSize': 14.0, 'color': 0xFF666666}},
                ],
              },
            },
          ],
        },
      },
    };
  }

  Map<String, dynamic> _callTile(String name, String time, bool isVideo, bool isMissed, int color) {
    return {
      'type': 'InkWell',
      'props': {'onTap': true},
      'child': {
        'type': 'Container',
        'props': {'padding': 16.0},
        'child': {
          'type': 'Row',
          'children': [
            {
              'type': 'CircleAvatar',
              'props': {'radius': 28.0, 'backgroundColor': color},
              'child': {'type': 'Icon', 'props': {'icon': 'person', 'color': 0xFFFFFFFF}},
            },
            {'type': 'SizedBox', 'props': {'width': 16.0}},
            {
              'type': 'Expanded',
              'child': {
                'type': 'Column',
                'props': {'crossAxisAlignment': 'start'},
                'children': [
                  {'type': 'Text', 'props': {'text': name, 'fontWeight': 'bold', 'fontSize': 16.0, 'color': isMissed ? 0xFFF44336 : 0xFF000000}},
                  {
                    'type': 'Row',
                    'children': [
                      {'type': 'Icon', 'props': {'icon': isMissed ? 'error' : 'check', 'size': 16.0, 'color': isMissed ? 0xFFF44336 : 0xFF4CAF50}},
                      {'type': 'SizedBox', 'props': {'width': 4.0}},
                      {'type': 'Text', 'props': {'text': time, 'fontSize': 14.0, 'color': 0xFF666666}},
                    ],
                  },
                ],
              },
            },
            {'type': 'IconButton', 'props': {'icon': isVideo ? 'person' : 'call', 'color': 0xFF075E54}},
          ],
        },
      },
    };
  }

  Map<String, dynamic> _settingsTile(String title, String subtitle, String icon, String? route) {
    // Navigation action from backend - either navigate to route or show snackbar
    final action = route != null
        ? {'type': 'navigate', 'route': route}
        : {'type': 'showSnackBar', 'message': '$title - Coming soon!'};
    return {
      'type': 'InkWell',
      'action': action,
      'child': {
        'type': 'Container',
        'props': {'padding': {'horizontal': 16.0, 'vertical': 14.0}},
        'child': {
          'type': 'Row',
          'children': [
            {
              'type': 'Container',
              'props': {'width': 40.0, 'height': 40.0, 'borderRadius': 20.0, 'color': 0xFFE8F5E9},
              'child': {'type': 'Center', 'child': {'type': 'Icon', 'props': {'icon': icon, 'color': 0xFF075E54, 'size': 22.0}}},
            },
            {'type': 'SizedBox', 'props': {'width': 16.0}},
            {
              'type': 'Expanded',
              'child': {
                'type': 'Column',
                'props': {'crossAxisAlignment': 'start'},
                'children': [
                  {'type': 'Text', 'props': {'text': title, 'fontSize': 16.0}},
                  {'type': 'Text', 'props': {'text': subtitle, 'fontSize': 13.0, 'color': 0xFF666666}},
                ],
              },
            },
            {'type': 'Icon', 'props': {'icon': 'chevron_right', 'color': 0xFFCCCCCC, 'size': 20.0}},
          ],
        },
      },
    };
  }
}

/// Scaffold built from backend config
class _WhatsAppScaffold extends StatefulWidget {
  final Map<String, dynamic> config;
  final String variant;
  final Function(String) onVariantChange;

  const _WhatsAppScaffold({
    required this.config,
    required this.variant,
    required this.onVariantChange,
  });

  @override
  State<_WhatsAppScaffold> createState() => _WhatsAppScaffoldState();
}

class _WhatsAppScaffoldState extends State<_WhatsAppScaffold> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    final tabCount = (widget.config['tabs'] as List).length;
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarConfig = widget.config['appBar'] as Map<String, dynamic>;
    final tabs = widget.config['tabs'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarConfig['title']),
        backgroundColor: Color(appBarConfig['backgroundColor']),
        foregroundColor: Color(appBarConfig['foregroundColor']),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          PopupMenuButton<String>(
            icon: const Icon(Icons.science),
            onSelected: widget.onVariantChange,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'A', child: Text('Variant A')),
              const PopupMenuItem(value: 'B', child: Text('Variant B')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: tabs.map((tab) {
            return Tab(
              icon: _getIconForName(tab['icon']),
              text: tab['label'],
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // Variant indicator
          Container(
            color: widget.variant == 'A' ? Colors.blue[50] : Colors.purple[50],
            padding: const EdgeInsets.all(8),
            child: Text(
              '🧪 Variant ${widget.variant} • Everything from Backend JSON!',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabs.map((tab) => _buildTabContent(tab['screen'])).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(tabs[_currentTab]),
    );
  }

  Widget _buildTabContent(String screenId) {
    final screens = widget.config['screens'] as Map<String, dynamic>;
    final screenConfig = screens[screenId];

    // For chats screen, use variant
    if (screenId == 'chats') {
      final variantKey = 'variant${widget.variant}';
      return SchemaWidget.fromJson(screenConfig[variantKey]);
    }

    return SchemaWidget.fromJson(screenConfig);
  }

  Widget? _buildFAB(Map<String, dynamic> tab) {
    final fabConfig = tab['fab'];
    if (fabConfig == null) return null;

    const gradient = {'type': 'linear', 'colors': [0xFF25D366, 0xFF128C7E]};
    const boxShadow = {'color': 0x40000000, 'offsetY': 4.0, 'blurRadius': 8.0};
    const containerProps = {
      'width': 56.0,
      'height': 56.0,
      'borderRadius': 16.0,
      'gradient': gradient,
      'boxShadow': boxShadow,
    };
    return SchemaWidget.fromJson({
      'type': 'GestureDetector',
      'props': const {'onTap': true},
      'child': {
        'type': 'Container',
        'props': containerProps,
        'child': {
          'type': 'Center',
          'child': {'type': 'Icon', 'props': {'icon': fabConfig['icon'], 'color': 0xFFFFFFFF, 'size': 28.0}},
        },
      },
    });
  }

  Icon _getIconForName(String name) {
    final icons = {
      'chat': Icons.chat,
      'favorite': Icons.circle_outlined,
      'call': Icons.call,
      'settings': Icons.settings,
    };
    return Icon(icons[name] ?? Icons.help);
  }
}
