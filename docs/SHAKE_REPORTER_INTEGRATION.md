# Shake Reporter Integration

This package contains the extracted `shake_reporter` feature from Collector.

## 1. Install

```yaml
dependencies:
  tagaddod_shaker:
    git:
      url: git@github.com:alisabry72/tagaddod_shaker.git
      ref: v0.1.0
```

## 2. Register Dependencies

`SharedPreferences` must be registered in `GetIt` before calling the package DI.

```dart
final sl = GetIt.instance;
final sharedPreferences = await SharedPreferences.getInstance();
if (!sl.isRegistered<SharedPreferences>()) {
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
}

registerShakeReporterDependencies(sl);
await sl<FlushPendingReportsUseCase>().call();
await sl<ShakeDetectorService>().initialize();
```

## 3. Wrap Screen For Screenshot Capture

```dart
RepaintBoundary(
  key: ScreenshotCaptureService.boundaryKey,
  child: YourScreen(),
)
```

## 4. Open Bottom Sheet

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => BlocProvider(
    create: (_) => GetIt.instance<ShakeReporterCubit>()..initialize(),
    child: const ShakeReporterBottomSheet(),
  ),
);
```

## 5. Localization Override (Optional)

```dart
ShakeReporterLocalizationScope(
  strings: const ShakeReporterStrings(
    shakeReporterSheetTitle: 'Report an Issue',
  ),
  child: const ShakeReporterBottomSheet(),
)
```

## Required Build-Time Variables

- `LINEAR_TOKEN`
- `LINEAR_TEAM_ID`

Optional:

- `LINEAR_LINK` (defaults to `https://api.linear.app/graphql`)
- `LINEAR_PROJECT_ID`
- `API_LINK`
- `APP_ENV`

## Full Runnable Demo

See `example/lib/main.dart`.
