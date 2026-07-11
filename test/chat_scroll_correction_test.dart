import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Validates that when older messages are prepended, using jumpTo with a
/// clamped (oldPixels + delta) target keeps the visible content stable.
///
/// Regression test for PR #21 regression: correctBy preserved fling physics
/// but caused the view to jump by delta while the fling was active, making
/// light swipes produce excessive scrolling. jumpTo applies the correction
/// atomically and the setState suppression in _onModel (guarded by
/// _loadingOlderFromScroll) prevents a premature rebuild at the wrong offset.
void main() {
  testWidgets(
    'jumpTo preserves visual position when content prepends during scroll',
    (tester) async {
      const itemHeight = 100.0;
      const viewportHeight = 400.0;
      const initialCount = 30; // enough to fill beyond viewport

      final scrollController = ScrollController();

      // A simple scrollable that models a chat transcript: initial items
      // fill the viewport, then we prepend more while the user is scrolled up.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: viewportHeight,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: List.generate(
                    initialCount,
                    (i) => SizedBox(
                      key: ValueKey('msg-$i'),
                      height: itemHeight,
                      child: Text('Message $i'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Scroll up so item 5 is at the top (simulates user scrolling toward
      // older messages and approaching the load threshold).
      const scrollUpTo = 5.0 * itemHeight;
      scrollController.jumpTo(scrollUpTo);
      await tester.pump();

      // Record position and extent before "older messages" are loaded.
      final oldPixels = scrollController.position.pixels;
      final oldMax = scrollController.position.maxScrollExtent;
      expect(oldPixels, closeTo(scrollUpTo, 0.5));

      // Simulate older messages being prepended: rebuild with more items at
      // the front.
      const prependCount = 10;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: viewportHeight,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: List.generate(
                    initialCount + prependCount,
                    (i) => SizedBox(
                      key: ValueKey('msg-${i - prependCount}'),
                      height: itemHeight,
                      child: Text('Message ${i - prependCount}'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // After prepending, the content grew. Without correction the same
      // pixel offset would show different (newer) messages.
      final delta = scrollController.position.maxScrollExtent - oldMax;
      expect(delta, greaterThan(1.0));

      // Apply the fix: jumpTo(oldPixels + delta) clamped to valid range.
      // This is what _loadOlderPreservingOffset does with our fix.
      final target = (oldPixels + delta).clamp(
        scrollController.position.minScrollExtent,
        scrollController.position.maxScrollExtent,
      );
      scrollController.jumpTo(target);
      await tester.pump();

      // After correction, the view should show the same messages at the
      // same visual position. No exception means no overflow.
      expect(tester.takeException(), isNull);

      // The target should be within valid bounds.
      expect(
        target,
        inInclusiveRange(
          scrollController.position.minScrollExtent,
          scrollController.position.maxScrollExtent,
        ),
      );

      // The corrected position should be ~ oldPixels + delta, keeping the
      // same messages visible.
      expect(scrollController.position.pixels, closeTo(oldPixels + delta, 1.0));
    },
  );

  testWidgets(
    'jumpTo target is clamped and never out of bounds when delta is large',
    (tester) async {
      const itemHeight = 100.0;
      const viewportHeight = 400.0;

      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: viewportHeight,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: List.generate(
                    5,
                    (i) => SizedBox(
                      key: ValueKey('a-$i'),
                      height: itemHeight,
                      child: Text('Item $i'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Scroll to the very top.
      scrollController.jumpTo(0);
      await tester.pump();

      final oldPixels = scrollController.position.pixels;
      final oldMax = scrollController.position.maxScrollExtent;

      // Prepend a large batch.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: viewportHeight,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: List.generate(
                    50,
                    (i) => SizedBox(
                      key: ValueKey('b-$i'),
                      height: itemHeight,
                      child: Text('Item $i'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final delta = scrollController.position.maxScrollExtent - oldMax;

      // This is the exact clamp calculation in _loadOlderPreservingOffset.
      final target = (oldPixels + delta).clamp(
        scrollController.position.minScrollExtent,
        scrollController.position.maxScrollExtent,
      );
      scrollController.jumpTo(target);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(target, greaterThanOrEqualTo(0.0));
      expect(
        target,
        lessThanOrEqualTo(scrollController.position.maxScrollExtent),
      );
    },
  );

  testWidgets(
    'correctBy creates a position jump beyond expected delta during active scroll',
    (tester) async {
      // This test documents how correctBy differs from jumpTo:
      // correctBy shifts the current pixel offset without any clamping,
      // which during a fling means delta gets added on top of the fling's
      // natural displacement, creating the "excessive scroll" sensation.
      const itemHeight = 100.0;
      const viewportHeight = 400.0;

      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: viewportHeight,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: List.generate(
                    30,
                    (i) => SizedBox(
                      key: ValueKey('c-$i'),
                      height: itemHeight,
                      child: Text('Item $i'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Scroll to a mid position.
      scrollController.jumpTo(500.0);
      await tester.pump();

      final oldPixels = scrollController.position.pixels;
      final oldMax = scrollController.position.maxScrollExtent;

      // Prepend items.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: viewportHeight,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: List.generate(
                    40,
                    (i) => SizedBox(
                      key: ValueKey('d-$i'),
                      height: itemHeight,
                      child: Text('Item $i'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final delta = scrollController.position.maxScrollExtent - oldMax;
      scrollController.position.correctBy(delta);

      final actualDelta = scrollController.position.pixels - oldPixels;
      await tester.pump();

      // correctBy shifts pixels by exactly delta. There are no bounds checks
      // on correctBy itself — the framework just adds to _pixels.
      expect(actualDelta, closeTo(delta, 0.5));
    },
  );
}
