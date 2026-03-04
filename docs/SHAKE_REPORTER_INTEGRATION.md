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
      ref: v0.1.4
```

## 2. Quick Start (Recommended)

### Bootstrap once in `main()`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapShakeReporter(
    options: const ShakeReporterOptions(
      linear: ShakeReporterLinearConfig(
        token: String.fromEnvironment('LINEAR_TOKEN'),
        teamId: String.fromEnvironment('LINEAR_TEAM_ID'),
        projectId: String.fromEnvironment('LINEAR_PROJECT_ID'),
        apiLink: String.fromEnvironment(
          'LINEAR_LINK',
          defaultValue: 'https://api.linear.app/graphql',
        ),
        appApiLink: String.fromEnvironment(
          'API_LINK',
          defaultValue: 'https://staging2.tagaddod.com/graphql',
        ),
      ),
    ),
  );
  runApp(const MyApp());
}
```

`bootstrapShakeReporter()` will:

- ensure `SharedPreferences` is registered in `GetIt`
- register shake reporter dependencies
- flush pending reports
- initialize shake detector

`--dart-define` values are available inside the package code. The snippet above makes that explicit and app-scoped.

Codemagic build example:

```bash
flutter build apk \
  --dart-define=LINEAR_TOKEN=$LINEAR_TOKEN \
  --dart-define=LINEAR_TEAM_ID=$LINEAR_TEAM_ID \
  --dart-define=LINEAR_PROJECT_ID=$LINEAR_PROJECT_ID \
  --dart-define=LINEAR_LINK=$LINEAR_LINK \
  --dart-define=API_LINK=$API_LINK
```

### Optional: custom Firebase project / RC keys per app

```dart
await bootstrapShakeReporter(
  options: ShakeReporterOptions(
    // Pass this when using a non-default Firebase app for this host app.
    remoteConfig: FirebaseRemoteConfig.instance,
    remoteConfigKeys: const ShakeReporterRemoteConfigKeys(
      enabled: 'collector_shake_enabled',
      sensitivityThreshold: 'collector_shake_threshold',
      cooldownSeconds: 'collector_shake_cooldown',
      screenshotEnabled: 'collector_shake_screenshot_enabled',
      blockedRoutes: 'collector_shake_blocked_routes',
      allowedEnvironments: 'collector_shake_allowed_envs',
      maxLogLines: 'collector_shake_max_log_lines',
    ),
    minimumFetchInterval: Duration.zero, // e.g. for QA builds
  ),
);
```

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

When opened manually, the reporter no longer auto-captures a screenshot.
Users can attach one photo from the device photo library directly inside the sheet.

### Platform permissions for manual photo attach

- iOS (`Info.plist`):
  - `NSPhotoLibraryUsageDescription`
- Android:
  - No extra setup in most cases; `image_picker` handles required manifest entries.

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

registerShakeReporterDependencies(
  sl,
  options: const ShakeReporterOptions(
    linear: ShakeReporterLinearConfig(
      token: String.fromEnvironment('LINEAR_TOKEN'),
      teamId: String.fromEnvironment('LINEAR_TEAM_ID'),
    ),
  ),
);
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
