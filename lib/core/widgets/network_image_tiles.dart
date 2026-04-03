import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';

class NetworkImageCard extends StatelessWidget {
  const NetworkImageCard({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.borderRadius = 24,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.backgroundColor = AppColors.activeSoft,
    this.fallbackIcon = Icons.image_rounded,
    this.fallbackTitle,
    this.overlayGradient,
    this.foreground,
    this.showShadow = false,
    this.showBorder = false,
  });

  final String imageUrl;
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;
  final Alignment alignment;
  final Color backgroundColor;
  final IconData fallbackIcon;
  final String? fallbackTitle;
  final Gradient? overlayGradient;
  final Widget? foreground;
  final bool showShadow;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final isNetworkUrl = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: showBorder ? Border.all(color: AppColors.border) : null,
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isNetworkUrl)
              Image.network(
                imageUrl,
                fit: fit,
                alignment: alignment,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _placeholder(context, fallbackIcon, fallbackTitle);
                },
                errorBuilder: (_, __, ___) {
                  return _placeholder(context, fallbackIcon, fallbackTitle);
                },
              )
            else
              Image.asset(
                imageUrl,
                fit: fit,
                alignment: alignment,
                errorBuilder: (_, __, ___) {
                  return _placeholder(context, fallbackIcon, fallbackTitle);
                },
              ),
            if (overlayGradient != null)
              DecoratedBox(decoration: BoxDecoration(gradient: overlayGradient)),
            if (foreground != null) Positioned.fill(child: foreground!),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, IconData icon, String? title) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: AppColors.brand),
            if (title != null) ...[
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkAvatar extends StatelessWidget {
  const NetworkAvatar({
    super.key,
    required this.imageUrl,
    this.size = 72,
    this.backgroundColor = AppColors.activeSoft,
    this.fallbackIcon = Icons.person_rounded,
    this.showShadow = true,
  });

  final String imageUrl;
  final double size;
  final Color backgroundColor;
  final IconData fallbackIcon;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final isNetworkUrl = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: isNetworkUrl
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: backgroundColor,
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: backgroundColor,
                    child: Icon(fallbackIcon, color: AppColors.brand, size: size * 0.45),
                  );
                },
              )
            : Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: backgroundColor,
                    child: Icon(fallbackIcon, color: AppColors.brand, size: size * 0.45),
                  );
                },
              ),
      ),
    );
  }
}

class UserInitialsAvatar extends StatelessWidget {
  const UserInitialsAvatar({
    super.key,
    this.fullName = 'Joel Bonilla',
    this.size = 36,
    this.showShadow = false,
  });

  final String fullName;
  final double size;
  final bool showShadow;

  String get _initials {
    final tokens = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (tokens.length >= 2) {
      return '${tokens[0][0]}${tokens[1][0]}'.toUpperCase();
    }
    if (tokens.isNotEmpty) {
      final first = tokens[0];
      return first.length >= 2
          ? first.substring(0, 2).toUpperCase()
          : first.substring(0, 1).toUpperCase();
    }
    return 'JB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.brand,
        border: Border.all(color: AppColors.border),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
