import 'package:flutter/material.dart';

/// Primary button widget with consistent styling
class PrimaryButton extends StatelessWidget {
  
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDestructive = false,
    this.padding,
    this.width,
  });
  
  /// Creates a destructive button (red color)
  const PrimaryButton.destructive({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.padding,
    this.width,
  }) : isDestructive = true;
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDestructive;
  final EdgeInsetsGeometry? padding;
  final double? width;
  
  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    
    final button = icon != null
        ? ElevatedButton.icon(
            onPressed: effectiveOnPressed,
            icon: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDestructive
                            ? Theme.of(context).colorScheme.onError
                            : Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Icon(icon),
            label: Text(text),
            style: _getButtonStyle(context),
          )
        : ElevatedButton(
            onPressed: effectiveOnPressed,
            style: _getButtonStyle(context),
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDestructive
                            ? Theme.of(context).colorScheme.onError
                            : Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(text),
          );
    
    return width != null
        ? SizedBox(
            width: width,
            child: button,
          )
        : button;
  }
  
  ButtonStyle _getButtonStyle(BuildContext context) {
    final baseStyle = ElevatedButton.styleFrom(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
    
    if (isDestructive) {
      return baseStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.error,
        ),
        foregroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.onError,
        ),
      );
    }
    
    return baseStyle;
  }
}

/// Secondary button widget with outlined style
class SecondaryButton extends StatelessWidget {
  
  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.padding,
    this.width,
  });
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double? width;
  
  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    
    final button = icon != null
        ? OutlinedButton.icon(
            onPressed: effectiveOnPressed,
            icon: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(icon),
            label: Text(text),
            style: _getButtonStyle(context),
          )
        : OutlinedButton(
            onPressed: effectiveOnPressed,
            style: _getButtonStyle(context),
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Text(text),
          );
    
    return width != null
        ? SizedBox(
            width: width,
            child: button,
          )
        : button;
  }
  
  ButtonStyle _getButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Text button widget with consistent styling
class TertiaryButton extends StatelessWidget {
  
  const TertiaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.padding,
    this.width,
  });
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double? width;
  
  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    
    final button = icon != null
        ? TextButton.icon(
            onPressed: effectiveOnPressed,
            icon: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(icon),
            label: Text(text),
            style: _getButtonStyle(context),
          )
        : TextButton(
            onPressed: effectiveOnPressed,
            style: _getButtonStyle(context),
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Text(text),
          );
    
    return width != null
        ? SizedBox(
            width: width,
            child: button,
          )
        : button;
  }
  
  ButtonStyle _getButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
