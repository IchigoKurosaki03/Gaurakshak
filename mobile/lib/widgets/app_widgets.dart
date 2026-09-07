import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../theme/gau_theme.dart';

class Brand extends StatelessWidget {
  const Brand({super.key, this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: small ? 38 : 56,
        height: small ? 38 : 56,
        decoration: BoxDecoration(color: GauColors.forest, borderRadius: BorderRadius.circular(small ? 12 : 18)),
        child: const Icon(Icons.agriculture_rounded, color: GauColors.white),
      ),
      SizedBox(width: small ? 8 : 12),
      Text('GauRakshak', style: TextStyle(fontSize: small ? 19 : 25, fontWeight: FontWeight.w900)),
    ],
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: GauColors.forest,
          foregroundColor: GauColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    ),
  );
}

class AppField extends StatelessWidget {
  const AppField({super.key, required this.label, required this.controller, required this.hint, this.keyboardType});
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      TextField(controller: controller, keyboardType: keyboardType, decoration: InputDecoration(hintText: hint)),
    ]),
  );
}

class ProgressStrip extends StatelessWidget {
  const ProgressStrip({super.key, required this.step});
  final int step;
  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(4, (index) => Expanded(
      child: Container(
        margin: EdgeInsets.only(right: index == 3 ? 0 : 5), height: 6,
        decoration: BoxDecoration(color: index < step ? GauColors.forest : const Color(0xFFDCE4DA), borderRadius: BorderRadius.circular(6)),
      ),
    )),
  );
}

class AppHint extends StatelessWidget {
  const AppHint({super.key, required this.icon, required this.message, this.color = GauColors.mint});
  final IconData icon;
  final String message;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 17), padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: GauColors.forest), const SizedBox(width: 11), Expanded(child: Text(message)),
    ]),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
  );
}

class CowAvatar extends StatelessWidget {
  const CowAvatar({super.key, required this.cow, this.large = false});
  final Cow cow;
  final bool large;
  @override
  Widget build(BuildContext context) => Container(
    width: large ? 78 : 48, height: large ? 78 : 48,
    decoration: BoxDecoration(color: riskColor(cow.risk).withValues(alpha: .12), borderRadius: BorderRadius.circular(large ? 25 : 16)),
    child: Icon(Icons.pets, size: large ? 38 : 25, color: riskColor(cow.risk)),
  );
}

Color riskColor(RiskLevel risk) => switch (risk) {
  RiskLevel.healthy => GauColors.forest,
  RiskLevel.monitor => GauColors.amber,
  RiskLevel.attention => GauColors.red,
  RiskLevel.insufficientHistory => const Color(0xFF717971),
};

Color riskSurface(RiskLevel risk) => switch (risk) {
  RiskLevel.healthy => GauColors.healthySurface,
  RiskLevel.monitor => GauColors.amberSurface,
  RiskLevel.attention => GauColors.redSurface,
  RiskLevel.insufficientHistory => const Color(0xFFE6F1E4),
};

IconData riskIcon(RiskLevel risk) => switch (risk) {
  RiskLevel.healthy => Icons.check_circle,
  RiskLevel.monitor => Icons.visibility,
  RiskLevel.attention => Icons.warning_rounded,
  RiskLevel.insufficientHistory => Icons.history_toggle_off,
};

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.risk});
  final RiskLevel risk;
  @override
  Widget build(BuildContext context) {
    final color = riskColor(risk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: riskSurface(risk), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(riskIcon(risk), color: color, size: 15), const SizedBox(width: 4),
        Text(risk.label.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: .3)),
      ]),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: GauColors.white, borderRadius: BorderRadius.circular(24)),
    child: Column(children: [
      Icon(icon, color: GauColors.forest, size: 44), const SizedBox(height: 10),
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(message, textAlign: TextAlign.center),
    ]),
  );
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Loading your farm…'});
  final String label;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 12), Text(label)]));
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => EmptyState(icon: Icons.error_outline, title: 'Could not load this view', message: message);
}
