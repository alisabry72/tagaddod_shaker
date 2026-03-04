# tagaddod_shaker

Reusable package that includes:

- extracted `features/shake_reporter` from Collector
- `TagaddodShakerHost`, `TagaddodShakerController`, `TagaddodShakerTrigger`

## Status

Current package state is ready for integration and validated with:

- `flutter analyze` (clean)
- `flutter test` (passing)

## Install

```yaml
dependencies:
  tagaddod_shaker:
    git:
      url: git@github.com:alisabry72/tagaddod_shaker.git
      ref: v0.1.4
```

For local development:

```yaml
dependencies:
  tagaddod_shaker:
    path: ../tagaddod_shaker
```

## Quick Exports

```dart
import 'package:tagaddod_shaker/tagaddod_shaker.dart';
```

Recommended quick integration:

```dart
await bootstrapShakeReporter(
  options: const ShakeReporterOptions(
    linear: ShakeReporterLinearConfig(
      token: String.fromEnvironment('LINEAR_TOKEN'),
      teamId: String.fromEnvironment('LINEAR_TEAM_ID'),
    ),
  ),
);

ShakeReporterListener(
  routeNameResolver: () => 'HomeRoute',
  child: YourScreen(),
)
```

Codemagic example (`--dart-define` forwarding):

```bash
flutter build ipa \
  --dart-define=LINEAR_TOKEN=$LINEAR_TOKEN \
  --dart-define=LINEAR_TEAM_ID=$LINEAR_TEAM_ID \
  --dart-define=LINEAR_PROJECT_ID=$LINEAR_PROJECT_ID \
  --dart-define=LINEAR_LINK=$LINEAR_LINK \
  --dart-define=API_LINK=$API_LINK
```

Core exports:

- `bootstrapShakeReporter`
- `ShakeReporterListener`
- `showShakeReporterSheet`
- `registerShakeReporterDependencies`
- `ShakeDetectorService`
- `ShakeReporterCubit`
- `ShakeReporterBottomSheet`
- `ScreenshotCaptureService`
- `ShakeDiagnosticsService`

## Docs

- Integration guide: `docs/SHAKE_REPORTER_INTEGRATION.md`
- Runnable example app: `example/lib/main.dart`
