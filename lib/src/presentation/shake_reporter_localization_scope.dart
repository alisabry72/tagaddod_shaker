import 'package:flutter/widgets.dart';

import 'shake_reporter_strings.dart';

class ShakeReporterLocalizationScope extends InheritedWidget {
  const ShakeReporterLocalizationScope({
    super.key,
    required super.child,
    this.strings = const ShakeReporterStrings(),
  });

  final ShakeReporterStrings strings;

  static ShakeReporterLocalizationScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ShakeReporterLocalizationScope>();
  }

  @override
  bool updateShouldNotify(ShakeReporterLocalizationScope oldWidget) {
    return oldWidget.strings != strings;
  }
}
