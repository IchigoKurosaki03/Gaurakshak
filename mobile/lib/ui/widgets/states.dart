import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';

/// Friendly empty state — icon in a mint disc, title, supportive line, and an
/// optional primary action. Used when a herd/list/log has no entries yet.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.mint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: AppColors.forest),
            ),
            const SizedBox(height: AppSpace.md),
            Text(title, style: AppText.headlineMd, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpace.xs),
              Text(
                message!,
                style: AppText.bodyMd.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpace.lg),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centered loading indicator with an optional label.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppColors.forest),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpace.md),
            Text(label!, style: AppText.bodyMd.copyWith(color: AppColors.muted)),
          ],
        ],
      ),
    );
  }
}

/// Error state with a retry affordance.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Something went wrong',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.errorSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Text(title, style: AppText.headlineMd, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.xs),
            Text(
              message,
              style: AppText.bodyMd.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpace.lg),
              SecondaryButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Slim, calm offline notice for the top of a scaffold body. Reassures that
/// work is not lost — a key trust signal for low-connectivity farms.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    this.message = "You're offline — changes are saved on this device",
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.xs,
      ),
      color: AppColors.mintDim,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 15,
            color: AppColors.offline,
          ),
          const SizedBox(width: AppSpace.xs),
          Flexible(
            child: Text(
              message,
              style: AppText.labelMd.copyWith(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
