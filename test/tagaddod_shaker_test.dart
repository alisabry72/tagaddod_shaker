import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagaddod_shaker/tagaddod_shaker.dart';

void main() {
  testWidgets('TagaddodShakerHost renders child when disabled', (tester) async {
    await tester.pumpWidget(
      const TagaddodShakerHost(enabled: false, child: Text('Host Child')),
    );

    expect(find.text('Host Child'), findsOneWidget);
  });

  testWidgets('TagaddodShakerTrigger renders child', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: TagaddodShakerTrigger(enabled: false, child: Text('LOGS')),
      ),
    );

    expect(find.text('LOGS'), findsOneWidget);
  });
}
