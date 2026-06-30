import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/chat/poll_composer_view.dart';
import 'package:mithka/l10n/app_localizations.dart';
import 'package:mithka/theme/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'PollComposerView renders full-page composer (no Material dialog)',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      (String, List<String>)? result;
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeController(prefs),
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context)
                      .push<(String, List<String>)>(
                        MaterialPageRoute(
                          builder: (_) => const PollComposerView(),
                        ),
                      );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Full-page composer, not an AlertDialog.
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.text(AppStrings.t(AppStringKeys.pollComposerCreatePollTitle)),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.t(AppStringKeys.composerSend)),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.t(AppStringKeys.pollComposerAddOption)),
        findsOneWidget,
      );
      expect(
        find.text(
          AppStrings.t(AppStringKeys.pollComposerOptionLabel, {'value1': 1}),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          AppStrings.t(AppStringKeys.pollComposerOptionLabel, {'value1': 2}),
        ),
        findsOneWidget,
      );

      // Add an option → a third row appears.
      await tester.tap(
        find.text(AppStrings.t(AppStringKeys.pollComposerAddOption)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          AppStrings.t(AppStringKeys.pollComposerOptionLabel, {'value1': 3}),
        ),
        findsOneWidget,
      );

      // Fill question + two options, send returns (question, options).
      await tester.enterText(find.byType(TextField).at(0), 'Dinner plan');
      await tester.enterText(find.byType(TextField).at(1), 'Hotpot');
      await tester.enterText(find.byType(TextField).at(2), 'Barbecue');
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.t(AppStringKeys.composerSend)));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.$1, 'Dinner plan');
      expect(result!.$2, ['Hotpot', 'Barbecue']);
    },
  );
}
