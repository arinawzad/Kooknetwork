// lib/services/app_version_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/version_provider.dart';
import '../localization/app_localizations.dart';

class AppVersionService {
  // Singleton pattern
  AppVersionService._privateConstructor();
  static final AppVersionService instance = AppVersionService._privateConstructor();
  
  bool _hasCheckedForUpdates = false;
  
  // Check for updates on app startup
  Future<void> checkForUpdatesOnStartup(BuildContext context) async {
    if (_hasCheckedForUpdates) return;
    
    final versionProvider = Provider.of<VersionProvider>(context, listen: false);
    final needsUpdate = await versionProvider.checkVersion();
    _hasCheckedForUpdates = true;
    
    if (!context.mounted) return;
    
    if (needsUpdate && versionProvider.forceUpdate) {
      _showUpdateRequiredDialog(context);
    } else if (needsUpdate) {
      _showUpdateAvailableDialog(context);
    }
  }
  
  // Show dialog for required updates that blocks app usage
  void _showUpdateRequiredDialog(BuildContext context) {
    final versionProvider = Provider.of<VersionProvider>(context, listen: false);
    final versionInfo = versionProvider.versionInfo;
    final localizations = AppLocalizations.of(context);
    
    if (versionInfo == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Prevent dismissal with back button
          child: AlertDialog(
            title: Text(localizations.translate('updateRequired')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(versionInfo.updateMessage ?? localizations.translate('updateRequiredMessage')),
                const SizedBox(height: 12),
                Text('${localizations.translate('currentVersion')}: ${versionInfo.currentVersion}'),
                Text('${localizations.translate('requiredVersion')}: ${versionInfo.minimumVersion}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  final success = await versionProvider.openUpdateUrl(versionInfo.updateUrl);
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.translate('storeOpenError'))),
                    );
                  }
                },
                child: Text(localizations.translate('updateNow')),
              ),
              TextButton(
                onPressed: () {
                  exit(0); // Close the app if user can't update
                },
                child: Text(localizations.translate('exitApp')),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Show dialog for optional updates
  void _showUpdateAvailableDialog(BuildContext context) {
    final versionProvider = Provider.of<VersionProvider>(context, listen: false);
    final versionInfo = versionProvider.versionInfo;
    final localizations = AppLocalizations.of(context);
    
    if (versionInfo == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('updateAvailable')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(versionInfo.updateMessage ?? localizations.translate('updateAvailableMessage')),
              const SizedBox(height: 12),
              Text('${localizations.translate('currentVersion')}: ${versionInfo.currentVersion}'),
              Text('${localizations.translate('latestVersion')}: ${versionInfo.latestVersion}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.translate('later')),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await versionProvider.openUpdateUrl(versionInfo.updateUrl);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.translate('storeOpenError'))),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text(localizations.translate('updateNow')),
            ),
          ],
        );
      },
    );
  }
  
  // Add this method to the app initialization in SplashScreen
  static Future<void> initAppVersion(BuildContext context) async {
    try {
      debugPrint('Checking for app updates...');
      
      // Check for updates
      await AppVersionService.instance.checkForUpdatesOnStartup(context);
    } catch (e) {
      debugPrint('Error initializing app version: $e');
    }
  }
}