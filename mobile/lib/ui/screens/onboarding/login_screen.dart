import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui.dart';
import '../../../state/farm_state.dart';

/// Sign-in, faithful to the Stitch login screen: a single screen carrying the
/// brand lockup + language toggle, a "Welcome back" prompt, one card holding a
/// +91-prefixed mobile field and a 4-digit OTP, the offline-barn reassurance,
/// and a "Verify & Continue" CTA.
///
/// Backend auth is attempted via [FarmState.loginAndSync]; when the barn has no
/// network the seeded demo herd carries the session forward, exactly as the
/// on-screen offline notice promises.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.state,
    required this.onAuthenticated,
  });

  final FarmState state;
  final VoidCallback onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phone =
      TextEditingController(text: '9823044819');
  String _otp = '';
  bool _phoneValid = true;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  bool get _canVerify => _phoneValid && _otp.length == 6;

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    // Attempt backend auth; the app is fully explorable on the seeded herd if
    // the barn is offline, so the session proceeds either way.
    final result = await widget.state.loginAndSync(_phone.text.trim(), _otp);
    if (!mounted) return;
    if (result == LoginResult.success || result == LoginResult.offline) {
      widget.onAuthenticated();
      return;
    }
    final message = widget.state.errorMessage ?? 'The code was not accepted.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.state,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.md,
                AppSpace.xs,
                AppSpace.md,
                AppSpace.md,
              ),
              child: Column(
                children: [
                  _header(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: AppText.headlineLgMobile
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            'Enter your registered mobile number to manage '
                            'your herd and milk logs.',
                            style: AppText.bodyMd
                                .copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: AppSpace.xl),
                          _formCard(),
                          const SizedBox(height: AppSpace.md),
                          _offlineNotice(),
                        ],
                      ),
                    ),
                  ),
                  _bottom(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.forest,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpace.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GauRakshak',
                    style: AppText.headlineSm
                        .copyWith(color: AppColors.forestDeep),
                  ),
                  Text(
                    'Farm Assistant',
                    style: AppText.bodySm.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadii.pillAll,
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.translate_rounded,
                    size: 15, color: AppColors.forest),
                const SizedBox(width: 6),
                Text(
                  'English / हिन्दी',
                  style: AppText.labelMd.copyWith(color: AppColors.forestDeep),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.line),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MOBILE NUMBER', style: AppText.labelSm),
          const SizedBox(height: AppSpace.xs),
          _phoneField(),
          const SizedBox(height: AppSpace.md),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: AppSpace.md),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            children: [
              Text(
                'Enter 6-Digit OTP',
                style: AppText.labelLg.copyWith(
                  color: AppColors.forestDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text.rich(
                TextSpan(
                  style: AppText.bodySm,
                  children: const [
                    TextSpan(text: 'Resend in '),
                    TextSpan(
                      text: '24s',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          OtpInput(
            length: 6,
            onChanged: (v) => setState(() => _otp = v),
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              const Icon(Icons.lock_rounded, size: 14, color: AppColors.forest),
              const SizedBox(width: 6),
              Text(
                'OTP auto-verified from SMS',
                style: AppText.labelSm.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Demo mode: use OTP 123456 when the backend is running.',
            style: AppText.bodySm.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadii.input,
        border: Border.all(
          color: AppColors.forest.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _miniFlag(),
                const SizedBox(width: 8),
                Text(
                  '+91',
                  style: AppText.labelLg.copyWith(
                    color: AppColors.forestDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 26, color: AppColors.line),
          Expanded(
            child: TextField(
              controller: _phone,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: AppText.bodyLg,
              cursorColor: AppColors.forest,
              onChanged: (v) => setState(() => _phoneValid = v.length == 10),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: '98230 44819',
                hintStyle: AppText.bodyLg.copyWith(color: AppColors.muted),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
              ),
            ),
          ),
          if (_phoneValid)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.check_circle_rounded,
                  color: AppColors.healthy, size: 20),
            ),
        ],
      ),
    );
  }

  /// Tricolour chip standing in for the flag emoji, which does not render on
  /// desktop/web Chrome — keeps the prefix crisp on every review surface.
  Widget _miniFlag() {
    return Container(
      width: 22,
      height: 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.outline, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const Expanded(child: ColoredBox(color: Color(0xFFFF9933))),
          Expanded(
            child: ColoredBox(
              color: Colors.white,
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0A3A8C),
                  ),
                ),
              ),
            ),
          ),
          const Expanded(child: ColoredBox(color: Color(0xFF138808))),
        ],
      ),
    );
  }

  Widget _offlineNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.sm),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: AppRadii.input,
        border: Border.all(color: AppColors.forest.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 18, color: AppColors.forest),
          const SizedBox(width: AppSpace.xs),
          Expanded(
            child: Text(
              'Works seamlessly offline inside barn sheds. Herd records '
              'automatically sync once network restores.',
              style: AppText.bodySm.copyWith(color: AppColors.forestDeep),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottom() {
    return Column(
      children: [
        PrimaryButton(
          label: 'Verify & Continue',
          icon: Icons.arrow_forward_rounded,
          loading: widget.state.isLoading,
          onPressed: _canVerify ? _verify : null,
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          'By continuing, you agree to GauRakshak Dairy Management Terms',
          textAlign: TextAlign.center,
          style: AppText.labelSm.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
