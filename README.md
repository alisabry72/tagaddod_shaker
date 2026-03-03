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
      ref: v0.1.0
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

Includes:

- `registerShakeReporterDependencies`
- `ShakeDetectorService`
- `ShakeReporterCubit`
- `ShakeReporterBottomSheet`
- `ScreenshotCaptureService`
- `ShakeDiagnosticsService`

## Docs

- Integration guide: `docs/SHAKE_REPORTER_INTEGRATION.md`
- Runnable example app: `example/lib/main.dart`
