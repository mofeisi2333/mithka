import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/chat/message_action_menu.dart';
import 'package:mithka/settings/translation_controller.dart';
import 'package:mithka/tdlib/td_models.dart';
import 'package:mithka/theme/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('message action rows stay balanced', () {
    expect(MessageActionMenu.rowCountsForActionCount(6), (first: 3, second: 3));
    expect(MessageActionMenu.rowCountsForActionCount(7), (first: 4, second: 3));
    expect(MessageActionMenu.rowCountsForActionCount(8), (first: 4, second: 4));
    expect(MessageActionMenu.rowCountsForActionCount(9), (first: 5, second: 4));

    for (var count = 6; count <= 24; count++) {
      final rows = MessageActionMenu.rowCountsForActionCount(count);
      expect(rows.first - rows.second, inInclusiveRange(0, 1));
    }
  });

  test('wide menus expose half of the fourth action', () {
    const actionWidth = 68.0;
    const horizontalPadding = 16.0;
    final viewport = MessageActionMenu.viewportWidthForColumnCount(
      5,
      availableWidth: 400,
    );
    expect(viewport, horizontalPadding + (actionWidth * 3.5));
  });

  test('+1 preserves sender by default and persists the override', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final theme = ThemeController(prefs);
    expect(theme.preserveSenderWhenRepeating, isTrue);

    theme.preserveSenderWhenRepeating = false;
    expect(ThemeController(prefs).preserveSenderWhenRepeating, isFalse);
  });

  testWidgets('message menu renders +1 in a narrow scroll viewport', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final translation = TranslationController(prefs);
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: translation,
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: MessageActionMenu(
                message: ChatMessage(
                  id: 1,
                  isOutgoing: false,
                  text: 'message',
                  date: 1,
                  contentType: 'messageText',
                ),
                isPinned: false,
                onSelect: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('+1'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('message-action-menu-surface')))
          .width,
      254,
    );
  });
}
