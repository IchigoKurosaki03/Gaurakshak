import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui.dart';
import '../../../state/farm_state.dart';
import '../../../models/domain.dart';

/// First-run farm profile, faithful to the Stitch setup screen: a "Step 1 of 2"
/// header with an escape hatch, three low-friction field cards (each with its
/// own helper tag + leading icon), a reassuring info note, and two ways forward
/// — register the first cow next, or skip straight to the dashboard.
///
/// Cow registration is a later phase, so both actions currently persist the
/// farm and continue to the dashboard via [onDone].
class FarmSetupScreen extends StatefulWidget {
  const FarmSetupScreen({
    super.key,
    required this.state,
    required this.onDone,
    this.onBack,
  });

  final FarmState state;
  final VoidCallback onDone;
  final VoidCallback? onBack;

  @override
  State<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends State<FarmSetupScreen> {
  late final TextEditingController _name;
  late final TextEditingController _herd;
  late final TextEditingController _location;
  late final TextEditingController _cowName;
  late final TextEditingController _cowTag;
  late final TextEditingController _cowBreed;
  late final TextEditingController _cowAge;
  int _step = 1;
  RiskLevel _health = RiskLevel.healthy;
  bool _previousMastitis = false;
  bool _currentlyTreated = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final farm = widget.state.farm;
    _name = TextEditingController(text: farm.name);
    _herd = TextEditingController(
      text: farm.herdSize > 0 ? '${farm.herdSize}' : '',
    );
    _location = TextEditingController(text: farm.location);
    _cowName = TextEditingController(text: 'Gauri');
    _cowTag = TextEditingController(text: 'COW-024');
    _cowBreed = TextEditingController(text: 'Gir');
    _cowAge = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    _name.dispose();
    _herd.dispose();
    _location.dispose();
    _cowName.dispose();
    _cowTag.dispose();
    _cowBreed.dispose();
    _cowAge.dispose();
    super.dispose();
  }

  bool get _canSave => _name.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (_saving) return;
    final herd = int.tryParse(_herd.text.trim()) ?? widget.state.farm.herdSize;
    setState(() => _saving = true);
    if (_step == 1) {
      if (_name.text.trim().isEmpty || herd < 1) return setState(() => _step = 1);
      setState(() => _step = 2);
      return;
    }
    if (_cowName.text.trim().isEmpty || _cowTag.text.trim().isEmpty || _cowBreed.text.trim().isEmpty) return;
    if (widget.state.authToken != null && widget.state.authToken!.isNotEmpty) {
      await widget.state.createFarm(
        _name.text.trim(),
        _location.text.trim(),
        herd,
        cowName: _cowName.text,
        cowTag: _cowTag.text,
        cowBreed: _cowBreed.text,
        cowAge: _cowAge.text,
        cowHealth: _health.apiValue,
      );
    } else {
      widget.state.setupFarm(_name.text.trim(), _location.text.trim(), herd);
      widget.state.addCow(Cow(
        name: _cowName.text.trim(),
        tag: _cowTag.text.trim().toUpperCase(),
        breed: _cowBreed.text.trim(),
        age: '${_cowAge.text.trim()} years',
        todayMilkLitres: 0,
        risk: _health,
        trend: 'No history yet',
        factors: const [],
        timeline: ['Today: Profile created', 'Health status: ${_health.label}'],
        previousMastitis: _previousMastitis,
        currentlyTreated: _currentlyTreated,
      ));
    }
    if (!mounted) return;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.md,
            AppSpace.xs,
            AppSpace.md,
            AppSpace.md,
          ),
          child: Column(
            children: [
              _topRow(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _step == 1 ? 'Create Your Dairy Farm' : 'Add your first cow',
                        style: AppText.headlineLgMobile
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        _step == 1
                            ? 'Keep it simple. You can register individual cows or complete medical history later.'
                            : 'Start with the details needed to identify and monitor one cow.',
                        style: AppText.bodyMd.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: AppSpace.lg),
                      if (_step == 1) _SetupField(
                        label: 'FARM NAME *',
                        helper: 'Required',
                        helperColor: AppColors.healthy,
                        icon: Icons.agriculture_rounded,
                        iconColor: AppColors.forest,
                        controller: _name,
                        hint: 'Shree Krishna Dairy',
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_step == 1) const SizedBox(height: AppSpace.sm),
                      if (_step == 1) _SetupField(
                        label: 'NUMBER OF COWS *',
                        helper: 'Estimated herd size',
                        helperColor: AppColors.healthy,
                        icon: Icons.pets_rounded,
                        iconColor: AppColors.forest,
                        controller: _herd,
                        hint: '28',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        suffix: 'Cows',
                      ),
                      if (_step == 1) const SizedBox(height: AppSpace.sm),
                      if (_step == 1) _SetupField(
                        label: 'LOCATION / DISTRICT',
                        helper: 'Optional',
                        helperColor: AppColors.muted,
                        icon: Icons.pin_drop_rounded,
                        iconColor: AppColors.muted,
                        controller: _location,
                        hint: 'Mehsana, Gujarat',
                        textCapitalization: TextCapitalization.words,
                      ),
                      if (_step == 1) ...[
                        const SizedBox(height: AppSpace.md),
                        _infoNote(),
                      ] else ...[
                        _SetupField(label: 'COW NAME *', helper: 'Required', helperColor: AppColors.healthy, icon: Icons.pets_rounded, iconColor: AppColors.forest, controller: _cowName, hint: 'Gauri', textCapitalization: TextCapitalization.words),
                        const SizedBox(height: AppSpace.sm),
                        _SetupField(label: 'COW ID / TAG *', helper: 'QR / RFID / ear-tag', helperColor: AppColors.healthy, icon: Icons.qr_code_scanner_rounded, iconColor: AppColors.forest, controller: _cowTag, hint: 'COW-024'),
                        const SizedBox(height: AppSpace.sm),
                        _SetupField(label: 'BREED *', helper: 'Required', helperColor: AppColors.healthy, icon: Icons.agriculture_rounded, iconColor: AppColors.forest, controller: _cowBreed, hint: 'Gir', textCapitalization: TextCapitalization.words),
                        const SizedBox(height: AppSpace.sm),
                        _SetupField(label: 'AGE', helper: 'Years', helperColor: AppColors.muted, icon: Icons.calendar_today_rounded, iconColor: AppColors.muted, controller: _cowAge, hint: '5', keyboardType: TextInputType.number),
                        const SizedBox(height: AppSpace.sm),
                        _healthPicker(),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _previousMastitis,
                          onChanged: (value) => setState(() => _previousMastitis = value),
                          title: const Text('Previous mastitis'),
                          subtitle: const Text('A past mastitis record for this cow'),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _currentlyTreated,
                          onChanged: (value) => setState(() => _currentlyTreated = value),
                          title: const Text('Currently treated for another issue'),
                          subtitle: const Text('Separate from previous mastitis history'),
                        ),
                        const SizedBox(height: AppSpace.md),
                        _infoNote(),
                      ],
                    ],
                  ),
                ),
              ),
              _bottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topRow() {
    return Row(
      children: [
        if (widget.onBack != null)
          Pressable(
            onTap: widget.onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 18, color: AppColors.ink),
            ),
          )
        else
          const SizedBox(width: 36),
        Expanded(
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: AppRadii.pillAll,
                border: Border.all(color: AppColors.forest.withValues(alpha: 0.15)),
              ),
              child: Text(
                _step == 1 ? 'Step 1 of 2: Farm Profile' : 'Step 2 of 2: First Cow',
                style: AppText.labelMd.copyWith(color: AppColors.forestDeep),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: _submit,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              'Skip for now',
              style: AppText.labelMd.copyWith(color: AppColors.muted),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoNote() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.sm),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.forest.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.forest),
          const SizedBox(width: AppSpace.xs),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppText.bodySm.copyWith(color: AppColors.forestDeep),
                children: const [
                  TextSpan(
                    text: 'No long forms required: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: 'In the next screen, you can register your primary '
                        'cow (',
                  ),
                  TextSpan(
                    text: 'Gauri / COW-024',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ') or scan ear-tags in seconds.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthPicker() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.line),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BASIC HEALTH STATUS', style: AppText.labelSm),
          const SizedBox(height: AppSpace.xs),
          Wrap(
            spacing: AppSpace.xs,
            children: RiskLevel.values
                .where((risk) => risk != RiskLevel.insufficientHistory)
                .map(
                  (risk) => ChoiceChip(
                    label: Text(risk.label),
                    selected: _health == risk,
                    onSelected: (_) => setState(() => _health = risk),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Previous mastitis and active treatment can be added from the cow profile later.',
            style: AppText.bodySm.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _bottom() {
    return Column(
      children: [
        PrimaryButton(
          label: _step == 1 ? 'Continue to First Cow' : 'Save & Open Dashboard',
          icon: Icons.arrow_forward_rounded,
          onPressed: _canSave && !_saving ? _submit : null,
        ),
        const SizedBox(height: AppSpace.xxs),
        if (_step == 1) GhostButton(label: "I'll add cows later", onPressed: _saving ? null : () => setState(() => _step = 2)),
      ],
    );
  }
}

class _SetupField extends StatelessWidget {
  const _SetupField({
    required this.label,
    required this.helper,
    required this.helperColor,
    required this.icon,
    required this.iconColor,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  final String label;
  final String helper;
  final Color helperColor;
  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffix;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final labelStrong = label.endsWith('*');
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.line),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppText.labelSm.copyWith(
                  color: labelStrong ? AppColors.forestDeep : AppColors.muted,
                ),
              ),
              Text(helper, style: AppText.labelSm.copyWith(color: helperColor)),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Container(
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: AppRadii.input,
              border: Border.all(color: AppColors.line),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    textCapitalization: textCapitalization,
                    onChanged: onChanged,
                    style: AppText.bodyLg,
                    cursorColor: AppColors.forest,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: hint,
                      hintStyle:
                          AppText.bodyLg.copyWith(color: AppColors.muted),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                if (suffix != null)
                  Text(
                    suffix!,
                    style: AppText.labelMd.copyWith(color: AppColors.muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
