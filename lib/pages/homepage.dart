import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/settingspage.dart';
import '../services/ssh_service.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final kml1provider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sshService = SSH(ref: ref);
    final isKml1Sent = ref.watch(kml1provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liquid Galaxy App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue[900]),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildButton(
                    'Send KML1',
                    Icons.upload_file,
                    Colors.blue[600]!,
                    () async {
                      try {
                        final data = await rootBundle.loadString(
                          'assets/kml1.kml',
                        );
                        final tempDir = await getTemporaryDirectory();
                        final file = File('${tempDir.path}/kml1.kml');
                        await file.writeAsString(data);
                        await sshService.kmlFileUpload(context, file, 'kml1');
                        await sshService.runKml(context, 'kml1');

                        ref.read(kml1provider.notifier).state = true;

                        _showSnackBar(
                          context,
                          'KML1 uploaded and executed successfully!',
                          Colors.green[600]!,
                        );
                      } catch (e) {
                        _showSnackBar(
                          context,
                          'Failed to upload or execute KML1: $e',
                          Colors.red[600]!,
                        );
                      }
                    },
                  ),
                  if (isKml1Sent) ...[
                    const SizedBox(height: 16),
                    _buildButton(
                      'Fly to kml',
                      Icons.flight_takeoff,
                      Colors.blue!,
                      () async {
                        try {
                          await sshService.flyTo(
                            context,
                            "41",
                            "-77"
                          );
                          _showSnackBar(
                            context,
                            'Successfully navigated to Pennsylvania!',
                            Colors.green[600]!,
                          );
                        } catch (e) {
                          _showSnackBar(
                            context,
                            'Failed to navigate: $e',
                            Colors.red[600]!,
                          );
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildButton(
                    'Send KML2',
                    Icons.upload_file,
                    Colors.blue[500]!,
                    () async {
                      try {
                        final data = await rootBundle.loadString(
                          'assets/kml2.kml',
                        );
                        final tempDir = await getTemporaryDirectory();
                        final file = File('${tempDir.path}/kml2.kml');
                        await file.writeAsString(data);
                        await sshService.kmlFileUpload(context, file, 'kml2');
                        await sshService.runKml(context, 'kml2');
                        _showSnackBar(
                          context,
                          'KML2 uploaded and executed successfully!',
                          Colors.green[600]!,
                        );
                      } catch (e) {
                        _showSnackBar(
                          context,
                          'Failed to upload or execute KML1: $e',
                          Colors.red[600]!,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    'Show Logo',
                    Icons.image,
                    Colors.blue[400]!,
                    () async => await sshService.showLogo(context),
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    'Clear Logo',
                    Icons.clear,
                    Colors.blue[300]!,
                    () async => await sshService.clearLogo(context),
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    'Clear KML',
                    Icons.delete,
                    Colors.blue[700]!,
                    () async => await sshService.cleanKML(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        routes: {'/settings': (context) => const SettingsPage()},
      ),
    ),
  );
}
