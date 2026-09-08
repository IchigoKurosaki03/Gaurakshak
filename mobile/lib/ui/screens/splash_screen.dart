import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../ui.dart';

/// Opening sequence, faithful to the Stitch splash: a deep-forest gradient
/// field with an emblem inside expanding milk-splash ripples, the
/// "DAIRY HEALTH ASSISTANT" pill + wordmark, a three-step preview of the core
/// flow (Scan -> Auto-Log -> Early Alert), and an explicit entry CTA.
///
/// Entry is tap-driven (matching the design), so [onComplete] fires from the
/// primary button or "Skip to Login" rather than on a timer.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Continuous milk-splash ripples + the "Sync Ready" pulse.
  late final AnimationController _loop;
  // One-shot staged entrance for the emblem, title, and steps.
  late final AnimationController _enter;

  late final Animation<double> _title;
  late final Animation<double> _steps;
  VideoPlayerController? _video;
  bool _videoReady = false;

  static const _grad = [Color(0xFF143823), Color(0xFF1A472C), Color(0xFF0C2316)];
  static const _accent = Color(0xFF98D4A8); // CTA fill (light pasture green)
  static const _accentInk = Color(0xFF0A2315); // CTA label
  static const _mint = Color(0xFFB2DFAD);

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _title = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
    );
    _steps = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _enter.forward();
    _loadOptionalVideo();
  }

  /// A video is an enhancement, never a startup dependency.  The bundled
  /// illustrated scene remains available until the farmer adds splash.mp4.
  Future<void> _loadOptionalVideo() async {
    final controller = VideoPlayerController.asset('assets/videos/splash.mp4');
    try {
      await controller.initialize();
      // The checked-in asset is already trimmed before its old end card, so a
      // native loop is both smoother and cheaper than a position listener.
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _video = controller;
        _videoReady = true;
      });
    } catch (_) {
      // No video has been supplied yet, or this target does not support it.
      // The purpose-built fallback below gives the user a complete splash.
      await controller.dispose();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _enter.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prefer the actual video on every platform. The animated GIF is only a
    // fallback for browsers/devices whose video backend cannot initialize.
    if (!_videoReady) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/videos/splash.gif', fit: BoxFit.cover),
            Positioned(left: 20, right: 20, bottom: 24, child: SafeArea(child: _videoCta())),
          ],
        ),
      );
    }
    // When the farmer supplies a splash video, let it carry the whole story.
    // The older badge, feature cards, and duplicate messaging are intentionally
    // hidden so the animation remains the visual focus.
    if (_videoReady && _video != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _video!.value.size.width,
                height: _video!.value.size.height,
                child: VideoPlayer(_video!),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: SafeArea(child: _videoCta()),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: _grad.first,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pets_rounded, color: _accent, size: 54),
                const SizedBox(height: 16),
                Text('GauRakshak', style: AppText.display.copyWith(color: Colors.white, fontSize: 32)),
                const SizedBox(height: 28),
                SizedBox(width: double.infinity, child: _videoCta()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _videoCta() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Pressable(
        onTap: widget.onComplete,
        child: Container(
          height: AppSpace.touchComfortable,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.94),
            borderRadius: AppRadii.card,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [Text('Enter Farm Assistant', style: AppText.labelLg.copyWith(color: _accentInk, fontSize: 16)), const SizedBox(width: 8), const Icon(Icons.arrow_forward_rounded, color: _accentInk, size: 20)]),
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(onTap: widget.onComplete, child: Text('Skip', style: AppText.labelSm.copyWith(color: Colors.white.withValues(alpha: 0.9), decoration: TextDecoration.underline))),
    ],
  );

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.20),
            borderRadius: AppRadii.pillAll,
            border: Border.all(color: _accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _loop,
                builder: (context, child) {
                  final pulse = 0.45 + 0.55 * (0.5 + 0.5 * math.sin(_loop.value * 2 * math.pi));
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accent.withValues(alpha: pulse),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Text(
                'Sync Ready',
                style: AppText.labelMd.copyWith(
                  color: _mint.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            'FLUTTER APP CORE',
            style: AppText.labelSm.copyWith(
              color: _mint.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );
  }

  Widget _centerNarrative() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _emblemNode(),
        const SizedBox(height: AppSpace.xl),
        _fadeUp(
          _title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _assistantPill(),
              const SizedBox(height: AppSpace.md),
              Text(
                'GauRakshak',
                style: AppText.display.copyWith(color: Colors.white, fontSize: 30),
              ),
              const SizedBox(height: AppSpace.xs),
              SizedBox(
                width: 300,
                child: Text(
                  'Early mastitis warning & milk monitoring for healthy herds',
                  textAlign: TextAlign.center,
                  style: AppText.bodyMd.copyWith(
                    color: _mint.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.xl),
        _fadeUp(_steps, child: _flowPreview()),
      ],
    );
  }

  Widget _emblemNode() {
    if (_videoReady && _video != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AspectRatio(
          aspectRatio: _video!.value.aspectRatio,
          child: VideoPlayer(_video!),
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: 224,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF245D38), Color(0xFF0B2A19)],
        ),
        border: Border.all(color: _accent.withValues(alpha: 0.26)),
      ),
      child: Stack(
        children: [
          Positioned(right: -32, top: -42, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _accent.withValues(alpha: 0.18), width: 20)))),
          Positioned(left: 20, top: 18, child: Text('LIVE HERD CARE', style: AppText.labelSm.copyWith(color: _mint.withValues(alpha: 0.8)))),
          Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(shape: BoxShape.circle, color: _accent), child: const Icon(Icons.health_and_safety_rounded, color: _accentInk, size: 36)),
            const SizedBox(height: 10),
            Text('Every cow. Earlier insight.', style: AppText.headlineSm.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text('Wearable health + milk intelligence', style: AppText.bodySm.copyWith(color: _mint.withValues(alpha: 0.82))),
          ])),
          Positioned(left: 18, right: 18, bottom: 16, child: Row(children: [
            _heroMetric(Icons.sensors_rounded, 'Sensor ready'),
            const SizedBox(width: 8),
            _heroMetric(Icons.cloud_done_outlined, 'Offline-first'),
          ])),
        ],
      ),
    );
  }

  Widget _heroMetric(IconData icon, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: _mint), const SizedBox(width: 6), Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: AppText.labelSm.copyWith(color: Colors.white, letterSpacing: 0)))]),
    ),
  );

  Widget _assistantPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2417).withValues(alpha: 0.55),
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_rounded, size: 15, color: _mint),
          const SizedBox(width: 6),
          Text(
            'DAIRY HEALTH ASSISTANT',
            style: AppText.labelSm.copyWith(color: _mint),
          ),
        ],
      ),
    );
  }

  Widget _flowPreview() {
    return Container(
      padding: const EdgeInsets.only(top: AppSpace.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _accent.withValues(alpha: 0.2)),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _FlowStep(
              icon: Icons.qr_code_scanner_rounded,
              step: '1. Scan Cow',
              detail: 'RFID / Ear-tag',
            ),
          ),
          SizedBox(width: AppSpace.xs),
          Expanded(
            child: _FlowStep(
              icon: Icons.sensors_rounded,
              step: '2. Auto-Log',
              detail: 'Sensor session',
            ),
          ),
          SizedBox(width: AppSpace.xs),
          Expanded(
            child: _FlowStep(
              icon: Icons.health_and_safety_rounded,
              step: '3. Early Alert',
              detail: 'Risk estimate',
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomCta() {
    return _fadeUp(
      _title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Pressable(
            onTap: widget.onComplete,
            child: Container(
              height: AppSpace.touchComfortable,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: AppRadii.card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter Farm Assistant',
                    style: AppText.labelLg.copyWith(
                      color: _accentInk,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: _accentInk, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Opening animation',
                style: AppText.labelSm.copyWith(
                  color: _mint.withValues(alpha: 0.6),
                ),
              ),
              GestureDetector(
                onTap: widget.onComplete,
                child: Text(
                  'Skip to Login',
                  style: AppText.labelSm.copyWith(
                    color: _mint.withValues(alpha: 0.9),
                    decoration: TextDecoration.underline,
                    decorationColor: _accent.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          AnimatedBuilder(
            animation: _loop,
            builder: (context, child) => ClipRRect(
              borderRadius: AppRadii.pillAll,
              child: LinearProgressIndicator(
                minHeight: 4,
                value: _loop.value,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation(_accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fadeUp(Animation<double> a, {required Widget child}) {
    return AnimatedBuilder(
      animation: a,
      builder: (context, c) {
        return Opacity(
          opacity: a.value.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, 12 * (1 - a.value)), child: c),
        );
      },
      child: child,
    );
  }
}

class _MilkingScenePainter extends CustomPainter {
  const _MilkingScenePainter({required this.progress, required this.entrance});

  final double progress;
  final double entrance;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = 0.78 + entrance.clamp(0.0, 1.0) * 0.22;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale, scale);
    final ink = Paint()..color = const Color(0xFFEAF7E8);
    final mint = Paint()..color = const Color(0xFF98D4A8);
    final line = Paint()
      ..color = const Color(0xFFB2DFAD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Ground and pasture marks.
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 82), width: 300, height: 28), mint);
    for (var i = -120; i <= 120; i += 30) {
      canvas.drawLine(Offset(i.toDouble(), 76), Offset(i + 7.0, 63), line);
    }

    // Cow body, neck, head, legs and tail.
    canvas.drawOval(Rect.fromCenter(center: const Offset(18, -16), width: 190, height: 86), ink);
    canvas.drawPath(
      Path()
        ..moveTo(-72, -30)
        ..quadraticBezierTo(-110, -75, -78, -105)
        ..lineTo(-42, -88)
        ..lineTo(-33, -25)
        ..close(),
      ink,
    );
    canvas.drawOval(Rect.fromCenter(center: const Offset(-76, -105), width: 72, height: 48), ink);
    canvas.drawCircle(const Offset(-94, -106), 4, Paint()..color = const Color(0xFF143823));
    canvas.drawLine(const Offset(-58, 10), const Offset(-62, 70), line);
    canvas.drawLine(const Offset(40, 10), const Offset(42, 70), line);
    canvas.drawLine(const Offset(88, -4), const Offset(96, 68), line);
    canvas.drawPath(Path()..moveTo(102, -30)..quadraticBezierTo(142, -2, 126, 30), line);

    // Farmer seated beside the udder.
    canvas.drawCircle(const Offset(-142, -26), 19, mint);
    canvas.drawPath(
      Path()
        ..moveTo(-158, -5)
        ..lineTo(-118, 36)
        ..lineTo(-150, 72)
        ..lineTo(-182, 72)
        ..lineTo(-161, 30)
        ..close(),
      mint,
    );
    canvas.drawLine(const Offset(-145, 35), const Offset(-111, 72), line);
    canvas.drawLine(const Offset(-122, 30), const Offset(-74, 12), line);

    // Bucket and the moving milk streams.
    canvas.drawOval(Rect.fromCenter(center: const Offset(-68, 75), width: 76, height: 22), mint);
    canvas.drawLine(const Offset(-104, 76), const Offset(-94, 113), line);
    canvas.drawLine(const Offset(-32, 76), const Offset(-42, 113), line);
    final wave = math.sin(progress * math.pi * 2) * 4;
    canvas.drawLine(Offset(-92 + wave, 20), const Offset(-79, 68), line);
    canvas.drawLine(Offset(-72 - wave, 20), const Offset(-79, 68), line);
    canvas.drawCircle(const Offset(-79, 70), 7, mint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MilkingScenePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.entrance != entrance;
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({required this.icon, required this.step, required this.detail});

  final IconData icon;
  final String step;
  final String detail;

  @override
  Widget build(BuildContext context) {
    const mint = Color(0xFFB2DFAD);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: mint, size: 20),
          const SizedBox(height: 6),
          Text(
            step,
            textAlign: TextAlign.center,
            style: AppText.labelSm.copyWith(color: Colors.white, letterSpacing: 0),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: AppText.labelSm.copyWith(
              color: mint.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
