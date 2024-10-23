import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Map<String, dynamic>?> getLatestAppVersion() async {
  try {
    final url = Uri.parse('https://apk.bohurupi.com/app_version.json');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return jsonBody is Map ? Map<String, dynamic>.from(jsonBody) : null;
    } else {
      print('Error fetching app version: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching app version: $e');
    return null;
  }
}

Future<void> checkForAppUpdate(BuildContext context) async {
  final latestVersion = await getLatestAppVersion();
  if (latestVersion == null) return;

  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version;

  if (latestVersion['version'] != currentVersion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Update Available'),
        content: Text('A newer version of the app (${latestVersion['version']}) is available. Would you like to update?'),
        actions: [
          TextButton(
            onPressed: () async {
              final url = Uri.parse(latestVersion['download_url'] ?? '');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch URL')),
                );
              }
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
