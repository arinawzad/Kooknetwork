import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../services/notification_service.dart';

class NotificationPermissionDialog extends StatefulWidget {
  final Function(bool) onPermissionResult;

  const NotificationPermissionDialog({
    super.key,
    required this.onPermissionResult,
  });

  @override
  State<NotificationPermissionDialog> createState() => _NotificationPermissionDialogState();
}

class _NotificationPermissionDialogState extends State<NotificationPermissionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _iconAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRtl = localizations.locale.languageCode == 'ar' || 
                  localizations.locale.languageCode == 'fa';
    
    // Theme
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = isDarkMode ? const Color(0xFF3949AB) : const Color(0xFF3949AB);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      title: Text(
        localizations.translate('notificationPermissionTitle') ?? 
        'Mining Reminders',
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mining icon with notification
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Mining machine icon
                  Icon(
                    Icons.memory,
                    size: 80,
                    color: primaryColor.withOpacity(0.8),
                  ),
                  
                  // Animated notification icon
                  AnimatedBuilder(
                    animation: _iconAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 10,
                        right: 80 - (_iconAnimation.value * 40),
                        child: Transform.scale(
                          scale: _iconAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Timer indicator
                  Positioned(
                    bottom: 10,
                    right: 80,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "1h",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description text
            Text(
              localizations.translate('notificationPermissionMessage') ?? 
              'Get notified 1 hour before your mining session ends! Enable notifications to never miss your mining rewards.',
              style: theme.textTheme.bodyMedium,
              textAlign: isRtl ? TextAlign.right : TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onPermissionResult(false);
          },
          child: Text(
            localizations.translate('notificationPermissionDecline') ?? 
            'Not Now',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () async {
            final granted = await NotificationService().requestPermissions();
            Navigator.pop(context);
            widget.onPermissionResult(granted);
          },
          child: Text(
            localizations.translate('notificationPermissionAccept') ?? 
            'Enable Reminders',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}