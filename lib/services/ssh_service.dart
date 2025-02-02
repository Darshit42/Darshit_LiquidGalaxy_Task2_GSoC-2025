import 'package:flutter/foundation.dart';
import 'package:dartssh2/dartssh2.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/provider.dart';
import 'package:flutter/material.dart';

class SSH extends ChangeNotifier {
  final encoder = const Utf8Encoder();
  final WidgetRef ref;
  bool flag = false;

  SSH({required this.ref});

  Future<bool> ensureConnection(BuildContext context) async {
    if (flag && ref.read(sshClient) != null) {
      return true;
    }
    return await connect(context);
  }

  Future<bool> connect(BuildContext context) async {
    try {
      final socket = await SSHSocket.connect(
        ref.read(ip1),
        ref.read(portpro),
        timeout: const Duration(seconds: 5),
      );

      ref.read(sshClient.notifier).state = SSHClient(
        socket,
        username: ref.read(namepro) ?? '',
        onPasswordRequest: () => ref.read(passpro) ?? '',
      );

      flag = true;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Connection successful')));
      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
      flag = false;
      return false;
    }
  }

  Future<void> disconnect(BuildContext context) async {
    try {
      ref.read(sshClient)?.close();
      ref.read(sshClient.notifier).state = null;
      flag = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Disconnection failed: $e')));
    }
  }

  Future<void> cleanKML(BuildContext context) async {
    try {
      await ensureConnection(context);
      await ref.read(sshClient)?.run('echo "" > /tmp/query.txt');
      await ref.read(sshClient)?.run("echo '' > /var/www/html/kmls.txt");
    } catch (error) {
      print("Error during cleanKML: $error");
    }
  }

  Future<void> kmlFileUpload(
    BuildContext context,
    File inputFile,
    String kmlName,
  ) async {
    try {
      await ensureConnection(context);

      final sshClientInstance = ref.read(sshClient);
      final sftp = await sshClientInstance?.sftp();
      if (sftp == null) {
        throw Exception("Failed to initialize SFTP client.");
      }

      final remoteFile = await sftp.open(
        '/var/www/html/$kmlName.kml',
        mode:
            SftpFileOpenMode.create |
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.write,
      );

      final fileSize = await inputFile.length();
      await remoteFile.write(
        inputFile.openRead().cast(),
        onProgress: (progress) {
          ref.read(percent.notifier).state =
              progress / fileSize;
        },
      );

      ref.read(percent.notifier).state = null;
      print("File upload successful.");
    } catch (error, stackTrace) {
      print("Error during kmlFileUpload: $error");
      print(stackTrace);
    }
  }

  Future<void> runKml(BuildContext context, String kmlName) async {
    try {
      await ensureConnection(context); // Ensure connection
      String command =
          "echo '\nhttp://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt";
      await ref.read(sshClient)?.run(command);
    } catch (error) {
      print("Error during runKml: $error");
    }
  }

  relaunchLG(context) async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        String cmd = """RELAUNCH_CMD="\\
          if [ -f /etc/init/lxdm.conf ]; then
            export SERVICE=lxdm
          elif [ -f /etc/init/lightdm.conf ]; then
            export SERVICE=lightdm
          else
            exit 1
          fi
          if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
            echo ${ref.read(passpro)} | sudo -S service \\\${SERVICE} start
          else
            echo ${ref.read(passpro)} | sudo -S service \\\${SERVICE} restart
          fi
          " && sshpass -p ${ref.read(passpro)} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await ref.read(sshClient)?.run(
            '"/home/${ref.read(namepro)}/bin/lg-relaunch" > /home/${ref.read(namepro)}/log.txt');
        await ref.read(sshClient)?.run(cmd);
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> showLogo(BuildContext context) async {
    final String openLogoKML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document id="logo">
    <name>Ras-logos</name>
    <Folder>
      <name>Logos</name>
      <ScreenOverlay>
        <name>Logo</name>
        <Icon>
          <href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png</href>
        </Icon>
        <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
      </ScreenOverlay>
    </Folder>
  </Document>
</kml>
''';

    try {
      var sshClientInstance = ref.read(sshClient);
      if (sshClientInstance == null) {
        print("SSH client not initialized. Attempting to connect...");
        bool isConnected = await connect(context);
        if (!isConnected) {
          throw Exception("Failed to connect SSH client.");
        }
        sshClientInstance = ref.read(sshClient);
      }

      final command = "echo '$openLogoKML' > /var/www/html/kml/slave_3.kml";
      await sshClientInstance?.run(command);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('logos displayed on screen successfully!')),
      );
    } catch (e) {
      print('Error in showLogos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to display demo logos: $e')),
      );
    }
  }

  Future<void> clearLogo(BuildContext context) async {
    const String logoKML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document id="logo">
    <name>Ras-logos</name>
    <Folder>
      <name>Logos</name>
    </Folder>
  </Document>
</kml>
''';

    try {
      var sshClientInstance = ref.read(sshClient);
      if (sshClientInstance == null) {
        print("SSH client not initialized. Attempting to connect...");
        bool isConnected = await connect(context);
        if (!isConnected) {
          throw Exception("Failed to connect SSH client.");
        }
        sshClientInstance = ref.read(sshClient);
      }


        final command = "echo '$logoKML' > /var/www/html/kml/slave_3.kml";
        await sshClientInstance?.run(command);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logos cleaned successfully!')),
      );
    } catch (e) {
      print('Error in clearLogos: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to clean logos: $e')));
    }
  }

  Future<void> flyTo(
    BuildContext context,
    String latitude,
    String longitude,
  ) async {
    try {
      await ensureConnection(context);
      final command = "echo 'search=$latitude,$longitude' > /tmp/query.txt";
      await ref.read(sshClient)?.run(command);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Flying to $latitude, $longitude successfully!'),
        ),
      );
    } catch (error) {
      print('Error in flyTo: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fly to coordinates: $error')),
      );
    }
  }
}
