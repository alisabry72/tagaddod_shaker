import 'package:flutter/widgets.dart';

import 'shake_reporter_localization_scope.dart';
import 'shake_reporter_strings.dart';

extension ShakeReporterSizeExtension on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
}

extension ShakeReporterLocalizationExtension on BuildContext {
  ShakeReporterStrings get locale =>
      ShakeReporterLocalizationScope.maybeOf(this)?.strings ??
      const ShakeReporterStrings();
}
