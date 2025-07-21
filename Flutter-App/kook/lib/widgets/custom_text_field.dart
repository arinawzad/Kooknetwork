import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final bool enabled;
  final String? errorText;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
    this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    // Get current brightness to determine if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Set colors based on current theme
    final fieldBorderColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final fieldFillColor = isDarkMode 
        ? (enabled ? (readOnly ? Colors.grey.shade800 : Colors.grey.shade900) : Colors.grey.shade800)
        : (enabled ? (readOnly ? Colors.grey.shade100 : Colors.grey.shade50) : Colors.grey.shade200);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final labelColor = isDarkMode ? Colors.white70 : Colors.black87;
    final hintColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          focusNode: focusNode,
          onChanged: onChanged,
          enabled: enabled,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor,
            ),
            prefixIcon: prefixIcon != null 
                ? Icon(
                    prefixIcon,
                    color: isDarkMode ? Colors.grey.shade400 : null,
                  ) 
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      color: isDarkMode ? Colors.grey.shade400 : null,
                    ),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red.shade400 : fieldBorderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red.shade400 : fieldBorderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red.shade400 : Theme.of(context).primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.red.shade400,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            errorText: errorText,
            filled: true,
            fillColor: fieldFillColor,
          ),
        ),
      ],
    );
  }
}