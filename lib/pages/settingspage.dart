import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ssh_service.dart';
import '../provider/provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ip = TextEditingController(text: ref.watch(ip1));
    final port = TextEditingController(
      text: ref.watch(portpro).toString(),
    );
    final usernameController = TextEditingController(
      text: ref.watch(namepro) ?? '',
    );
    final passwordController = TextEditingController(
      text: ref.watch(passpro) ?? '',
    );
    final flag = ref.watch(isConnectedToLGProvider);
    final service = SSH(ref: ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: Hero(
          tag: 'settings_icon',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildConnectionStatus(flag),
              const SizedBox(height: 24),
              _buildSettingsCard(
                children: [
                  _buildAnimatedTextField(
                    controller: ip,
                    label: 'IP Address',
                    icon: Icons.computer,
                    delay: 100,
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedTextField(
                    controller: port,
                    label: 'Port',
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    delay: 200,
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedTextField(
                    controller: usernameController,
                    label: 'Username',
                    icon: Icons.person,
                    delay: 300,
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedTextField(
                    controller: passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                    delay: 400,
                  ),
                  const SizedBox(height: 24),
                  _buildConnectionButtons(
                    context,
                    ref,
                    flag,
                    service,
                    ip,
                    port,
                    usernameController,
                    passwordController,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(bool flag) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: flag ? Colors.green[100] : Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  flag ? Icons.check_circle : Icons.info,
                  color: flag ? Colors.green[700] : Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Text(
                  flag ? 'Connected' : 'Not Connected',
                  style: TextStyle(
                    color: flag ? Colors.green[700] : Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    required int delay,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionButtons(
    BuildContext context,
    WidgetRef ref,
    bool isConnected,
    SSH sshService,
    TextEditingController ip,
    TextEditingController port,
    TextEditingController name,
    TextEditingController pass,
  ) {
    return Column(
      children: [
        _buildAnimatedButton(
          icon: Icons.link,
          label: 'Connect',
          onPressed:
              isConnected
                  ? null
                  : () async {
                    ref.read(ip1.notifier).state = ip.text;
                    ref.read(portpro.notifier).state =
                        int.tryParse(port.text) ?? 22;
                    ref.read(namepro.notifier).state =
                        name.text;
                    ref.read(passpro.notifier).state =
                        pass.text;

                    final success = await sshService.connect(context);
                    if (success) {
                      ref.read(isConnectedToLGProvider.notifier).state = true;
                    }
                  },
        ),
        const SizedBox(height: 16),
        _buildAnimatedButton(
          icon: Icons.link_off,
          label: 'Disconnect',
          onPressed:
              isConnected
                  ? () async {
                    await sshService.disconnect(context);
                    ref.read(isConnectedToLGProvider.notifier).state = false;
                  }
                  : null,
        ),
        const SizedBox(height: 16),
        _buildAnimatedButton(
          icon: Icons.refresh,
          label: 'Relaunch LG',
          onPressed:
              isConnected
                  ? () async {
                    await sshService.relaunchLG(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Relaunch LG command sent.'),
                      ),
                    );
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildAnimatedButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor:
                  onPressed == null ? Colors.blue[200] : Colors.blue[600],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
