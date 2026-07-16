import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mithka/components/full_page_back_swipe.dart';

void main() {
  testWidgets('back swipe can begin from the middle of the page', (
    tester,
  ) async {
    var backCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FullPageBackSwipe(
            enabled: true,
            onBack: () => backCount++,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    final pageCenter = tester.getCenter(find.byType(FullPageBackSwipe));
    expect(pageCenter.dx, greaterThan(28));
    final gesture = await tester.startGesture(pageCenter);
    await gesture.moveBy(const Offset(130, 0));
    await gesture.up();
    await tester.pump();

    expect(backCount, 1);
  });

  testWidgets('vertical and disabled swipes do not navigate back', (
    tester,
  ) async {
    var enabled = true;
    var backCount = 0;
    late StateSetter setState;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, update) {
            setState = update;
            return FullPageBackSwipe(
              enabled: enabled,
              onBack: () => backCount++,
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );

    final center = tester.getCenter(find.byType(FullPageBackSwipe));
    var gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(80, 130));
    await gesture.up();
    await tester.pump();
    expect(backCount, 0);

    setState(() => enabled = false);
    await tester.pump();
    gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(130, 0));
    await gesture.up();
    await tester.pump();
    expect(backCount, 0);
  });
}
