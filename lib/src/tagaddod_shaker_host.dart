import 'package:flutter/widgets.dart';
import 'package:requests_inspector/requests_inspector.dart';

/// Wraps the app with [RequestsInspector] and exposes a stable package API.
class TagaddodShakerHost extends StatelessWidget {
  const TagaddodShakerHost({
    super.key,
    required this.child,
    this.enabled = true,
    this.hideInspectorBanner = false,
    this.showInspectorOn = ShowInspectorOn.Both,
    this.navigatorKey,
  });

  final Widget child;
  final bool enabled;
  final bool hideInspectorBanner;
  final ShowInspectorOn showInspectorOn;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    return RequestsInspector(
      enabled: enabled,
      hideInspectorBanner: hideInspectorBanner,
      showInspectorOn: showInspectorOn,
      navigatorKey: navigatorKey,
      child: child,
    );
  }
}
