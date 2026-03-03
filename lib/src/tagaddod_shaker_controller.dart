import 'package:requests_inspector/requests_inspector.dart';

/// Simple static API for manually controlling the inspector screen.
class TagaddodShakerController {
  const TagaddodShakerController._();

  static void showInspector() {
    final controller = InspectorController();
    if (!controller.pageController.hasClients) return;
    controller.showInspector();
  }

  static void hideInspector() {
    final controller = InspectorController();
    if (!controller.pageController.hasClients) return;
    controller.hideInspector();
  }

  static void clearRequests() {
    InspectorController().clearAllRequests();
  }

  static void addRequest(RequestDetails requestDetails) {
    InspectorController().addNewRequest(requestDetails);
  }
}
