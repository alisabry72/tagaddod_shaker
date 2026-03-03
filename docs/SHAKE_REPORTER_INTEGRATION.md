# Shake Reporter Integration

This package supports two integration modes:

- Quick Start (recommended): `bootstrapShakeReporter` + `ShakeReporterListener`
- Manual (advanced): register services and open the sheet yourself

## 1. Install

```yaml
dependencies:
  tagaddod_shaker:
    git:
      url: git@github.com:alisabry72/tagaddod_shaker.git
      ref: v0.1.0
```

## 2. Quick Start (Recommended)

### Bootstrap once in `main()`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapShakeReporter();
  runApp(const MyApp());
}
```

`bootstrapShakeReporter()` will:

- ensure `SharedPreferences` is registered in `GetIt`
- register shake reporter dependencies
- flush pending reports
- initialize shake detector

### Wrap your root screen/app

```dart
ShakeReporterListener(
  routeNameResolver: () => 'HomeRoute',
  child: YourScreen(),
)
```

This listener automatically:

- listens for shake events
- captures screenshot via `RepaintBoundary`
- opens `ShakeReporterBottomSheet`
- prevents duplicate sheet opens

### Manual fallback button (optional)

```dart
FilledButton(
  onPressed: () => showShakeReporterSheet(context: context),
  child: const Text('Open Reporter'),
)
```

### Localization override (optional)

```dart
ShakeReporterListener(
  stringsBuilder: (context) => const ShakeReporterStrings(
    shakeReporterSheetTitle: 'Report an Issue',
  ),
  child: YourScreen(),
)
```

## 3. Manual Integration (Advanced)

Use this only when you need custom lifecycle or custom navigation flow.

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

Then open sheet yourself:

```dart
showShakeReporterSheet(context: context);
```

## Required Build-Time Variables

- `LINEAR_TOKEN`
- `LINEAR_TEAM_ID`

Optional:

- `LINEAR_LINK` (defaults to `https://api.linear.app/graphql`)
- `LINEAR_PROJECT_ID`
- `API_LINK`
- `APP_ENV`

## Runnable Demo

See `example/lib/main.dart`.
