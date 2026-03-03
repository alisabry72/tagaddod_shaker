import 'package:flutter/widgets.dart';

import 'tagaddod_shaker_controller.dart';

/// Tap trigger that opens the inspector.
class TagaddodShakerTrigger extends StatelessWidget {
  const TagaddodShakerTrigger({
    super.key,
    required this.child,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
    this.onTap,
  });

  final Widget child;
  final bool enabled;
  final HitTestBehavior behavior;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: behavior,
      onTap: () {
        onTap?.call();
        if (enabled) {
          TagaddodShakerController.showInspector();
        }
      },
      child: child,
    );
  }
}
