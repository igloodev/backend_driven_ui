import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/backend_driven_ui.dart';

Widget _build(Map<String, dynamic> json) {
  final schema = WidgetSchema.fromJson(json);
  return MaterialApp(
    home: Scaffold(
      body: Builder(builder: (ctx) => SchemaParser().parse(schema, ctx)),
    ),
  );
}

void main() {
  group('Icon resolver — 120+ icons render without crash', () {
    final icons = [
      // Navigation / arrows
      'expand_more', 'expand_less', 'chevron_left', 'chevron_right',
      'arrow_left', 'arrow_right', 'arrow_upward', 'arrow_downward',
      'more_vert', 'more_horiz', 'first_page', 'last_page',
      'fullscreen', 'fullscreen_exit',
      // Status / actions
      'add_circle', 'remove_circle', 'delete_outline',
      'check_circle', 'check_circle_outline', 'done', 'done_all',
      'cancel', 'block', 'error_outline', 'warning_amber',
      'info_outline', 'help', 'help_outline',
      'visibility', 'visibility_off',
      // People / social
      'person_add', 'person_remove', 'account_circle', 'group', 'groups',
      'logout', 'login',
      // Favorites / ratings
      'favorite_border', 'star_border', 'star_half',
      'thumb_up', 'thumb_down',
      'bookmark', 'bookmark_border', 'bookmark_add',
      // Communication
      'call', 'call_end', 'chat', 'chat_bubble', 'forum',
      'notifications', 'notifications_none', 'notifications_off',
      // Media
      'videocam', 'videocam_off', 'mic', 'mic_off',
      'play', 'pause', 'stop', 'skip_next', 'skip_previous',
      'volume_up', 'volume_down', 'volume_off', 'volume_mute', 'headphones',
      // Files / content
      'photo', 'photo_library', 'folder_open', 'attach_file', 'attachment',
      'description', 'article', 'code', 'print', 'save', 'save_alt',
      // Commerce
      'shopping_cart', 'shopping_bag', 'payment', 'credit_card', 'store',
      'receipt', 'local_offer',
      // Location
      'location_on', 'location_off', 'map', 'navigation', 'explore', 'directions',
      // Time
      'calendar', 'calendar_today', 'date_range', 'schedule', 'access_time',
      'timer', 'history',
      // Device
      'wifi', 'wifi_off', 'bluetooth', 'bluetooth_disabled',
      'battery_full', 'battery_low', 'signal', 'fingerprint',
      // Security
      'security', 'shield', 'qr_code',
      // Analytics / layout
      'trending_up', 'trending_down', 'bar_chart', 'pie_chart', 'dashboard',
      'grid_view', 'list', 'view_list', 'view_module', 'table_chart',
      // Cloud
      'cloud', 'cloud_upload', 'cloud_download',
      // Misc
      'language', 'dark_mode', 'light_mode', 'flash_on', 'flash_off',
      'palette', 'brush', 'bug_report', 'support', 'headset', 'power', 'sync',
      'flag', 'label', 'label_outline', 'new_releases', 'verified',
      'zoom_in', 'zoom_out', 'rotate_left', 'rotate_right', 'crop',
      'tune', 'filter_list', 'sort',
      'send', 'reply', 'link',
    ];

    for (final icon in icons) {
      testWidgets('$icon renders without crash', (tester) async {
        await tester.pumpWidget(_build({
          'type': 'Icon',
          'props': {'icon': icon},
        }));
        expect(find.byType(Icon), findsOneWidget);
      });
    }

    testWidgets('unknown icon falls back to help_outline', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Icon',
        'props': {'icon': 'totally_unknown_icon_xyz'},
      }));
      expect(find.byType(Icon), findsOneWidget);
    });
  });

  group('Icon resolver — original icons still resolve', () {
    for (final icon in ['home', 'search', 'settings', 'back', 'forward', 'star', 'person']) {
      testWidgets('$icon still resolves', (tester) async {
        await tester.pumpWidget(_build({
          'type': 'Icon',
          'props': {'icon': icon},
        }));
        expect(find.byType(Icon), findsOneWidget);
      });
    }
  });
}
