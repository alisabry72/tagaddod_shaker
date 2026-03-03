import 'package:flutter/material.dart';
import 'package:tagaddod_shaker/tagaddod_shaker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await bootstrapShakeReporter();
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
      home: const _ExampleHomePage(),
    );
  }
}

class _ExampleHomePage extends StatelessWidget {
  const _ExampleHomePage();

  ShakeReporterStrings _strings(BuildContext context) {
    return const ShakeReporterStrings(
      shakeReporterSheetTitle: 'Report an Issue',
      shakeReporterSheetSubtitle: 'Shake your device or tap the button',
      shakeReporterSubmitButton: 'Submit Report',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShakeReporterListener(
      routeNameResolver: () => 'ShakeReporterExampleHome',
      stringsBuilder: _strings,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tagaddod Shaker Example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shake the device to open the reporter.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text('Manual fallback trigger:'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => showShakeReporterSheet(
                  context: context,
                  stringsBuilder: _strings,
                ),
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
