import 'package:flutter/material.dart';
import '../models/task.dart';
import '../localization/app_localizations.dart'; // Add this import

class VerificationDialog extends StatefulWidget {
  final Task task;
  final Function(String) onVerify;

  const VerificationDialog({
    super.key,
    required this.task,
    required this.onVerify,
  });

  @override
  State<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<VerificationDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verify() {
    final localizations = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = localizations.translate('pleaseEnterCode');
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    widget.onVerify(code);
    
    // Reset state if dialog is still open
    if (mounted) {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    // Generate prompt based on task type
    String prompt = '';
    switch (widget.task.actionType) {
      case TaskActionType.url:
        prompt = localizations.translate('enterCodeAfterTask');
        break;
      case TaskActionType.video:
        prompt = localizations.translate('enterCodeFromVideo');
        break;
      case TaskActionType.inApp:
        prompt = localizations.translate('enterVerificationCode');
        break;
      default:
        prompt = localizations.translate('enterCodeToComplete');
    }

    return AlertDialog(
      title: Text('${localizations.translate('verifyTask')}: ${widget.task.title}'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prompt
          Text(prompt),
          const SizedBox(height: 16),
          
          // Code input field
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              hintText: localizations.translate('verificationCode'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              errorText: _errorMessage,
            ),
            style: const TextStyle(
              fontSize: 16,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            autofocus: true,
            onSubmitted: (_) => _verify(),
          ),
          
          // Task reward info
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 8),
                Text(
                  '${localizations.translate('youWillEarn')} ${widget.task.reward.toStringAsFixed(1)} KOOK',
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.translate('cancel')),
        ),
        
        // Verify button
        ElevatedButton(
          onPressed: _isVerifying ? null : _verify,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(localizations.translate('verify')),
        ),
      ],
    );
  }
}