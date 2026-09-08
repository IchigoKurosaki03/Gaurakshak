import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Standard labelled text field. White fill, hairline border, forest focus
/// ring, 12px radius — matches the Stitch login/setup forms.
class GauTextField extends StatelessWidget {
  const GauTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppText.labelLg),
          const SizedBox(height: AppSpace.xs),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          style: AppText.bodyLg,
          cursorColor: AppColors.forest,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.bodyLg.copyWith(color: AppColors.muted),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.muted, size: 20)
                : null,
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpace.md,
              vertical: AppSpace.md,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: const BorderSide(color: AppColors.forest, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Boxed one-time-code entry. Renders [length] single-digit boxes, auto-advances
/// focus, supports backspace, and reports the assembled code via [onChanged] /
/// [onCompleted].
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Paste of a full code.
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final target = digits.length.clamp(0, widget.length - 1);
      _nodes[target].requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }
    setState(() {});
    widget.onChanged?.call(_code);
    if (_code.length == widget.length) widget.onCompleted?.call(_code);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const gap = 8.0;
      final boxWidth = ((constraints.maxWidth - gap * (widget.length - 1)) / widget.length).clamp(42.0, 86.0);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) const SizedBox(width: gap),
            SizedBox(
              width: boxWidth,
              child: _OtpBox(
                controller: _controllers[i],
                focusNode: _nodes[i],
                onChanged: (v) => _onChanged(i, v),
                onBackspace: () {
                  if (_controllers[i].text.isEmpty && i > 0) {
                    _controllers[i - 1].clear();
                    _nodes[i - 1].requestFocus();
                    setState(() {});
                    widget.onChanged?.call(_code);
                  }
                },
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    return KeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          onBackspace();
        }
      },
      child: AspectRatio(
        aspectRatio: 0.82,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
          style: AppText.headlineMd,
          cursorColor: AppColors.forest,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: filled ? AppColors.mint : AppColors.card,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: BorderSide(
                color: filled ? AppColors.forest : AppColors.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: const BorderSide(color: AppColors.forest, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
