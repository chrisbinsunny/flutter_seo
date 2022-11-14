import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seo/html/tree/semantics_tree.dart';

import 'base.dart';
import 'widgets/test_seo_controller.dart';
import 'widgets/test_seo_image.dart';
import 'widgets/test_seo_link.dart';
import 'widgets/test_seo_page.dart';
import 'widgets/test_seo_text.dart';

void main() {
  testWidgets('Seo.text is processed correctly', (tester) async {
    await tester.pumpWidget(TestSeoController(
      tree: (_) => SemanticsTree(),
      child: const TestSeoText(),
    ));
    await tester.pumpAndSettle(debounceTime);

    expect(
      html,
      '<div><p>$text</p></div>',
    );
  });

  testWidgets('Seo.image is processed correctly', (tester) async {
    await tester.pumpWidget(TestSeoController(
      tree: (_) => SemanticsTree(),
      child: const TestSeoImage(),
    ));
    await tester.pumpAndSettle(debounceTime);

    expect(
      html,
      '<div><noscript><img src="$src" alt="$alt" height="$height" width="$width"></noscript></div>',
    );
  });

  testWidgets('Seo.link is processed correctly', (tester) async {
    await tester.pumpWidget(TestSeoController(
      tree: (_) => SemanticsTree(),
      child: const TestSeoLink(),
    ));
    await tester.pumpAndSettle(debounceTime);

    expect(
      html,
      '<div><div><a href="$href"><p>$anchor</p></a></div></div>',
    );
  });

  testWidgets('multiple Seo\'s are processed correctly', (tester) async {
    await tester.pumpWidget(TestSeoController(
      tree: (_) => SemanticsTree(),
      child: TestSeoLink(
        child: Row(
          children: const [
            TestSeoImage(),
            TestSeoText(),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle(debounceTime);

    expect(
      html,
      '<div><div><a href="$href"><p>$anchor</p></a><noscript><img src="$src" alt="$alt" height="$height" width="$width"></noscript><p>$text</p></div></div>',
    );
  });

  testWidgets('traverse executes <0.5ms for single widget', (tester) async {
    late SemanticsTree tree;
    await tester.pumpWidget(TestSeoController(
      tree: (_) {
        tree = SemanticsTree();
        return tree;
      },
      child: const TestSeoText(),
    ));

    final duration =
        List.generate(10, (_) => measure(() => tree.traverse()?.toHtml()))
            .mapIndexed((index, duration) {
      tester.printToConsole('$index - $duration');
      return duration.inMicroseconds;
    }).average;

    expect(duration, lessThanOrEqualTo(500));
    tester.printToConsole('average - ${duration / 1000.0}ms');
  });

  testWidgets('traverse executes <30ms for complex page', (tester) async {
    await tester.binding.setSurfaceSize(largeScreenSize);

    late SemanticsTree tree;
    await tester.pumpWidget(TestSeoController(
      tree: (_) {
        tree = SemanticsTree();
        return tree;
      },
      child: const TestSeoPage(),
    ));

    final duration =
        List.generate(10, (_) => measure(() => tree.traverse()?.toHtml()))
            .mapIndexed((index, duration) {
      tester.printToConsole('$index - $duration');
      return duration.inMicroseconds;
    }).average;

    expect(duration, lessThanOrEqualTo(30000));
    tester.printToConsole('average - ${duration / 1000.0}ms');

    await tester.binding.setSurfaceSize(null);
  });
}
