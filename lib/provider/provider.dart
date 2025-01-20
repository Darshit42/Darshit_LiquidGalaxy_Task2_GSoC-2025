import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartssh2/dartssh2.dart';

StateProvider<bool> loading = StateProvider((ref) => false);
StateProvider<double?> percent = StateProvider((ref) => null);

StateProvider<String> ip1 = StateProvider((ref) => '');
StateProvider<String?> namepro = StateProvider((ref) => null);
StateProvider<String?> passpro = StateProvider((ref) => null);
StateProvider<int> portpro = StateProvider((ref) => 22);

StateProvider<int> rigsProvider = StateProvider((ref) => 3);
StateProvider<int> leftmostRigProvider = StateProvider((ref) => 3);
StateProvider<int> rightmostRigProvider = StateProvider((ref) => 2);

void setRigs(int rig, WidgetRef ref) {
  ref.read(rigsProvider.notifier).state = rig;
  ref.read(leftmostRigProvider.notifier).state = (rig ~/ 2) + 2;
  ref.read(rightmostRigProvider.notifier).state = (rig ~/ 2) + 1;
}

StateProvider<SSHClient?> sshClient = StateProvider((ref) => null);
StateProvider<bool> isConnectedToLGProvider = StateProvider((ref) => false);
StateProvider<bool> isConnectedToInternetProvider = StateProvider(
  (ref) => false,
);
StateProvider<bool> downloadableContentAvailableProvider = StateProvider(
  (ref) => false,
);
