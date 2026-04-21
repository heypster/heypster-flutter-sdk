import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heypster_flutter_sdk/heypster_flutter_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final apiKey = dotenv.env['HEYPSTER_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw StateError('HEYPSTER_API_KEY missing from example/.env');
  }

  HeypsterFlutterSDK.configure(apiKey: apiKey);
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heypster SDK Example',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: HeypsterLocalizations.localizationsDelegates,
      supportedLocales: HeypsterLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: HeypsterTheme.heypsterNavy,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          surfaceContainerHighest: Color(0xFFEEEFF2),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          surface: Color(0xFF141E2B),
          onSurface: Colors.white,
          surfaceContainerHighest: Color(0xFF1E2A38),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    implements HeypsterMediaSelectionListener {
  HeypsterMedia? _selectedMedia;

  @override
  void initState() {
    super.initState();
    HeypsterDialog.instance.addListener(this);
  }

  @override
  void dispose() {
    HeypsterDialog.instance.removeListener(this);
    super.dispose();
  }

  @override
  void onMediaSelect(HeypsterMedia media) {
    setState(() => _selectedMedia = media);
  }

  @override
  void onDismiss() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('heypster'),
        centerTitle: false,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: Column(
        children: [
          if (_selectedMedia != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: AspectRatio(
                  aspectRatio: _selectedMedia!.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: HeypsterMediaView(
                      key: ValueKey(_selectedMedia!.id),
                      media: _selectedMedia!,
                      renditionType: HeypsterRendition.original,
                      resizeMode: HeypsterResizeMode.contain,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: HeypsterGridView(
              content: HeypsterContentRequest.trendingGifs(),
              cellPadding: 10,
              onMediaSelect: (media) {
                setState(() => _selectedMedia = media);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HeypsterDialog.instance.show(context: context);
        },
        tooltip: 'Open GIF picker',
        icon: const Icon(Icons.gif_box),
        label: const Text('Pick a GIF'),
      ),
    );
  }
}
