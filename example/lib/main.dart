import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagaddod_shaker/tagaddod_shaker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sl = GetIt.instance;
  final sharedPreferences = await SharedPreferences.getInstance();
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerSingleton<SharedPreferences>(sharedPreferences);
  }

  registerShakeReporterDependencies(sl);
  await sl<FlushPendingReportsUseCase>().call();
  await sl<ShakeDetectorService>().initialize();

  runApp(const ShakeReporterExampleApp());
}

class ShakeReporterExampleApp extends StatelessWidget {
  const ShakeReporterExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tagaddod Shaker Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ShakeReporterExamplePage(),
    );
  }
}

class ShakeReporterExamplePage extends StatefulWidget {
  const ShakeReporterExamplePage({super.key});

  @override
  State<ShakeReporterExamplePage> createState() =>
      _ShakeReporterExamplePageState();
}

class _ShakeReporterExamplePageState extends State<ShakeReporterExamplePage> {
  late final StreamSubscription<void> _shakeSubscription;
  bool _isPresentingReporter = false;

  @override
  void initState() {
    super.initState();
    _shakeSubscription = GetIt.instance<ShakeDetectorService>().onShakeTrigger
        .listen((_) {
          if (_isPresentingReporter) return;
          unawaited(_openReporter());
        });
  }

  @override
  void dispose() {
    _shakeSubscription.cancel();
    super.dispose();
  }

  Future<void> _openReporter() async {
    if (_isPresentingReporter || !mounted) return;

    final detector = GetIt.instance<ShakeDetectorService>();
    final diagnostics = GetIt.instance<ShakeDiagnosticsService>();
    diagnostics.setCurrentRoute('ShakeReporterExamplePage');

    _isPresentingReporter = true;
    detector.setSheetOpen(true);
    try {
      await GetIt.instance<ScreenshotCaptureService>().captureFromBoundary();
      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ShakeReporterLocalizationScope(
          strings: const ShakeReporterStrings(
            shakeReporterSheetTitle: 'Report an Issue',
            shakeReporterSheetSubtitle: 'Shake your device or tap the button',
          ),
          child: BlocProvider(
            create: (_) => GetIt.instance<ShakeReporterCubit>()..initialize(),
            child: const ShakeReporterBottomSheet(),
          ),
        ),
      );
    } finally {
      detector.setSheetOpen(false);
      _isPresentingReporter = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: ScreenshotCaptureService.boundaryKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tagaddod Shaker Example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Try shaking the phone to open the reporter.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'If shake is disabled by config, use the button below for manual trigger.',
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _openReporter,
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('Open Reporter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
