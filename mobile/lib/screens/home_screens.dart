import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/domain.dart';
import '../localization/app_strings.dart';
import '../state/farm_state.dart';
import '../theme/gau_theme.dart';
import '../widgets/app_widgets.dart';
import 'milking_screens.dart';
import 'onboarding_screens.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key, required this.state}); final FarmState state; @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> { int tab = 0; @override Widget build(BuildContext context) { final pages = [DashboardScreen(state: widget.state), CowsScreen(state: widget.state), CowHealthLookupScreen(state: widget.state), MilkLookupScreen(state: widget.state), MoreScreen(state: widget.state)]; return AnimatedBuilder(animation: widget.state, builder: (context, child) => Scaffold(body: pages[tab], floatingActionButton: tab == 0 ? FloatingActionButton.extended(backgroundColor: GauColors.ink, foregroundColor: GauColors.white, icon: const Icon(Icons.auto_awesome), label: Text(tr(widget.state.language, 'askAssistant')), onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true, builder: (_) => GauSaathiSheet(state: widget.state))) : null, bottomNavigationBar: NavigationBar(selectedIndex: tab, height: 76, indicatorColor: GauColors.mint, labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, onDestinationSelected: (value) => setState(() => tab = value), destinations: [NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: tr(widget.state.language, 'home')), NavigationDestination(icon: const Icon(Icons.pets_outlined), selectedIcon: const Icon(Icons.pets), label: tr(widget.state.language, 'cows')), NavigationDestination(icon: const Icon(Icons.monitor_heart_outlined), selectedIcon: const Icon(Icons.monitor_heart), label: tr(widget.state.language, 'health')), NavigationDestination(icon: const Icon(Icons.water_drop_outlined), selectedIcon: const Icon(Icons.water_drop), label: tr(widget.state.language, 'milk')), NavigationDestination(icon: const Icon(Icons.more_horiz), selectedIcon: const Icon(Icons.more_horiz), label: tr(widget.state.language, 'more'))]))); } }

class DashboardScreen extends StatelessWidget { 
  const DashboardScreen({super.key, required this.state}); 
  final FarmState state; 
  
  @override 
  Widget build(BuildContext context) {
    final milkTrend = state.milkTrend;
    final hasMilkData = state.totalMilk > 0 || state.sampleData.isNotEmpty;
    final todayMilk = hasMilkData ? state.totalMilk : 0.0;
    final previousMilk = hasMilkData && milkTrend.length >= 2
        ? milkTrend[milkTrend.length - 2].litres
        : todayMilk;
    final milkDelta = todayMilk - previousMilk;
    final trendMaximum = milkTrend.fold<double>(
      todayMilk,
      (maximum, record) => record.litres > maximum ? record.litres : maximum,
    );
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20), 
        children: [
          Row(
            children: [
              const Brand(small: true), 
              const Spacer(), 
              Container(
                decoration: BoxDecoration(border: Border.all(color: GauColors.forest), borderRadius: BorderRadius.circular(20), color: GauColors.white),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(children: [Icon(state.isOnline && state.authToken != null ? Icons.cloud_done_outlined : Icons.cloud_off_outlined, color: GauColors.forest, size: 18), const SizedBox(width: 4), Text(state.dataModeLabel, style: const TextStyle(color: GauColors.forest, fontWeight: FontWeight.bold))]),
              )
            ]
          ), 
          const SizedBox(height: 28), 
          Text(tr(state.language, 'goodMorning'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GauColors.forest.withValues(alpha: 0.7))),
          Text(state.farm.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: GauColors.ink)), 
          const SizedBox(height: 16),
          _HerdStories(state: state),
          const SizedBox(height: 18), 
          
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              color: GauColors.forest, 
              child: Stack(
                children: [
                  Positioned(
                    right: -60, top: -60,
                    child: Container(
                      width: 200, height: 200, 
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white12, width: 20)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text(tr(state.language, 'todayMilk'), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)), 
                        const SizedBox(height: 8),
                        Text('${todayMilk.toStringAsFixed(1)} L', style: const TextStyle(color: GauColors.white, fontSize: 46, fontWeight: FontWeight.w900)), 
                        const SizedBox(height: 8),
                        Text(hasMilkData ? '${milkDelta >= 0 ? '+' : ''}${milkDelta.toStringAsFixed(1)} L vs yesterday · ${state.cows.length} cows recorded' : 'No milk recorded yet · start a session to build today’s total', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 16),
                        Container(
                          height: 6, width: double.infinity,
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3)),
                          child: LayoutBuilder(
                            builder: (context, constraints) => Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: trendMaximum <= 0 ? 0 : constraints.maxWidth * (todayMilk / trendMaximum).clamp(0, 1),
                                decoration: BoxDecoration(color: const Color(0xFFA5D6A7), borderRadius: BorderRadius.circular(3)),
                              ),
                            ),
                          ),
                        ),
                      ]
                    ),
                  )
                ]
              )
            )
          ), 
          
          const SizedBox(height: 32), 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(tr(state.language, 'herdOverview'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GauColors.ink)),
              Text('Total: ${state.cows.length}', style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold)),
            ]
          ),
          const SizedBox(height: 16), 
          Row(
            children: [
              Expanded(child: _HerdMetric(value: '${state.cows.length}', label: 'Total', icon: Icons.pets, iconColor: GauColors.ink, bgColor: GauColors.white, valueColor: GauColors.ink)), 
              const SizedBox(width: 8), 
              Expanded(child: _HerdMetric(value: '${state.count(RiskLevel.healthy)}', label: 'Healthy', icon: Icons.check_circle_outline, iconColor: GauColors.forest, bgColor: const Color(0xFFE8F5E9), valueColor: GauColors.forest)), 
              const SizedBox(width: 8), 
              Expanded(child: _HerdMetric(value: '${state.count(RiskLevel.monitor)}', label: 'Monitor', icon: Icons.visibility_outlined, iconColor: GauColors.amber, bgColor: const Color(0xFFFFF8E7), valueColor: GauColors.amber)), 
              const SizedBox(width: 8), 
              Expanded(child: _HerdMetric(value: '${state.count(RiskLevel.attention)}', label: 'At risk', icon: Icons.warning_amber_rounded, iconColor: GauColors.red, bgColor: const Color(0xFFFFF0F0), valueColor: GauColors.red)), 
            ]
          ),
          
          const SizedBox(height: 32),
          Text(tr(state.language, 'startMilking'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GauColors.ink)),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScanScreen(state: state))),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(color: GauColors.forest, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFA5D6A7), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.qr_code_scanner, color: GauColors.forest, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(state.language, 'scanCow'), style: const TextStyle(color: GauColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Verify cow, then connect the session', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: GauColors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _DashboardSectionHeader(
            title: 'Cows needing attention',
            trailing: '${state.cows.where((cow) => cow.risk == RiskLevel.attention || cow.risk == RiskLevel.monitor).length} flagged',
          ),
          const SizedBox(height: 12),
          if (state.cows.where((cow) => cow.risk == RiskLevel.attention || cow.risk == RiskLevel.monitor).isEmpty)
            const _DashboardEmpty(
              icon: Icons.verified_outlined,
              title: 'All clear for now',
              message: 'No cows are currently flagged. New sensor or milking changes will appear here.',
            )
          else
            ...state.cows
                .where((cow) => cow.risk == RiskLevel.attention || cow.risk == RiskLevel.monitor)
                .take(3)
                .map((cow) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DashboardAttention(
                        cow: cow,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CowProfileScreen(state: state, cow: cow))),
                      ),
                    )),
          const SizedBox(height: 22),
          _DashboardSectionHeader(title: 'Milk snapshot', trailing: hasMilkData ? '${state.cows.length} cows' : null),
          const SizedBox(height: 12),
          _DashboardMilkSnapshot(state: state, hasMilkData: hasMilkData),
          const SizedBox(height: 22),
          _DashboardSectionHeader(title: 'Recent activity'),
          const SizedBox(height: 12),
          _DashboardActivity(state: state),
          
        ]
      )
    ); 
  } 
}

class _HerdStories extends StatelessWidget {
  const _HerdStories({required this.state});
  final FarmState state;

  @override
  Widget build(BuildContext context) {
    final cows = state.cows.take(8).toList();
    if (cows.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cows.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cow = cows[index];
          final accent = cow.risk == RiskLevel.attention ? GauColors.red : cow.risk == RiskLevel.monitor ? GauColors.amber : GauColors.forest;
          return InkWell(
            borderRadius: BorderRadius.circular(36),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CowProfileScreen(state: state, cow: cow))),
            child: SizedBox(
              width: 64,
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [accent, const Color(0xFFE05191), const Color(0xFFF7A34B)])),
                  child: Container(width: 52, height: 52, decoration: const BoxDecoration(shape: BoxShape.circle, color: GauColors.white), child: Icon(Icons.pets, color: accent, size: 27)),
                ),
                const SizedBox(height: 5),
                Text(cow.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: GauColors.ink)),
          const Spacer(),
          if (trailing != null) Text(trailing!, style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold)),
        ],
      );
}

class _DashboardEmpty extends StatelessWidget {
  const _DashboardEmpty({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(
          children: [
            Icon(icon, color: GauColors.forest, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(message, style: const TextStyle(color: Colors.black54, height: 1.35))])),
          ],
        ),
      );
}

class _DashboardAttention extends StatelessWidget {
  const _DashboardAttention({required this.cow, required this.onTap});
  final Cow cow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: GauColors.white, borderRadius: BorderRadius.circular(18), border: Border(left: BorderSide(color: riskColor(cow.risk), width: 5)), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))]),
          child: Row(children: [CowAvatar(cow: cow), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(cow.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))), StatusBadge(risk: cow.risk)]), const SizedBox(height: 4), Text(cow.factors.isEmpty ? 'Review her latest milking and sensor readings.' : cow.factors.first, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 7), Text('View cow details  ›', style: TextStyle(color: riskColor(cow.risk), fontWeight: FontWeight.w800))]))]),
        ),
      );
}

class _DashboardMilkSnapshot extends StatelessWidget {
  const _DashboardMilkSnapshot({required this.state, required this.hasMilkData});
  final FarmState state;
  final bool hasMilkData;

  @override
  Widget build(BuildContext context) {
    if (!hasMilkData) return const _DashboardEmpty(icon: Icons.water_drop_outlined, title: 'No milk records yet', message: 'Scan a cow and complete a milking session to start a real trend.');
    final ranked = [...state.cows]..sort((a, b) => b.todayMilkLitres.compareTo(a.todayMilkLitres));
    return AppCard(child: Column(children: [Row(children: [const Icon(Icons.water_drop_outlined, color: GauColors.forest), const SizedBox(width: 10), const Text('Today by cow', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), Text('${state.totalMilk.toStringAsFixed(1)} L total', style: const TextStyle(fontWeight: FontWeight.w900, color: GauColors.forest))]), const SizedBox(height: 12), ...ranked.take(3).map((cow) => Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: Text(cow.name)), SizedBox(width: 90, child: LinearProgressIndicator(value: state.totalMilk <= 0 ? 0 : (cow.todayMilkLitres / state.totalMilk).clamp(0, 1), minHeight: 7, borderRadius: BorderRadius.circular(8), color: GauColors.forest, backgroundColor: const Color(0xFFE5EEE6))), const SizedBox(width: 10), SizedBox(width: 45, child: Text('${cow.todayMilkLitres.toStringAsFixed(1)} L', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700)))]))) ]));
  }
}

class _DashboardActivity extends StatelessWidget {
  const _DashboardActivity({required this.state});
  final FarmState state;

  @override
  Widget build(BuildContext context) {
    final items = state.cows.expand((cow) => cow.timeline.take(2).map((event) => (cow: cow, event: event))).take(4).toList();
    if (items.isEmpty) return const _DashboardEmpty(icon: Icons.history, title: 'Your activity feed is ready', message: 'Completed sessions, health checks, and alerts will appear here.');
    return AppCard(child: Column(children: [for (var index = 0; index < items.length; index++) ...[if (index > 0) const Divider(height: 20), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.schedule_outlined, color: GauColors.forest, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(items[index].cow.name, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(items[index].event, style: const TextStyle(color: Colors.black54))]))])]]));
  }
}

class CowsScreen extends StatefulWidget { const CowsScreen({super.key, required this.state}); final FarmState state; @override State<CowsScreen> createState() => _CowsScreenState(); }
class _CowsScreenState extends State<CowsScreen> { String query = ''; RiskLevel? filter; @override Widget build(BuildContext context) { final cows = widget.state.cows.where((cow) => (filter == null || cow.risk == filter) && '${cow.name} ${cow.tag}'.toLowerCase().contains(query.toLowerCase())).toList(); return SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.all(20), child: Row(children: [const Text('My cows', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const Spacer(), IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddCowScreen(state: widget.state))))])), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: TextField(decoration: const InputDecoration(hintText: 'Search name or tag', prefixIcon: Icon(Icons.search)), onChanged: (value) => setState(() => query = value))), Wrap(spacing: 5, children: [FilterChip(label: const Text('All'), selected: filter == null, onSelected: (_) => setState(() => filter = null)), ...RiskLevel.values.map((risk) => FilterChip(label: Text(risk.label), selected: filter == risk, onSelected: (_) => setState(() => filter = risk)))]), Expanded(child: ListView.builder(padding: const EdgeInsets.all(20), itemCount: cows.length, itemBuilder: (context, index) { final cow = cows[index]; return _CowCard(cow: cow, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CowProfileScreen(state: widget.state, cow: cow)))); }))])); } }

class CowProfileScreen extends StatelessWidget {
  const CowProfileScreen({super.key, required this.state, required this.cow});

  final FarmState state;
  final Cow cow;

  @override
  Widget build(BuildContext context) {
    final score = cow.riskScore;
    final cowAlerts = state.alerts.where((item) => item.cowTag == cow.tag).toList();
    final alert = cowAlerts.isEmpty ? null : cowAlerts.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Cow profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CowAvatar(cow: cow, large: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cow.name, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
                    Text(cow.tag, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    StatusBadge(risk: cow.risk),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${cow.breed} • ${cow.age}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current health', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(riskIcon(cow.risk), color: riskColor(cow.risk)),
                    const SizedBox(width: 8),
                    Text(cow.risk.label, style: TextStyle(color: riskColor(cow.risk), fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mastitis risk', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(score == null ? 'More history needed' : '$score / 100', style: TextStyle(fontSize: 28, color: riskColor(cow.risk), fontWeight: FontWeight.w900))),
                    StatusBadge(risk: cow.risk),
                  ],
                ),
                const SizedBox(height: 8),
                Text(cow.factors.isEmpty ? 'The system needs more observations before explaining a change.' : cow.factors.join(' • ')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _ProfileMetric('Today’s milk', '${cow.todayMilkLitres.toStringAsFixed(1)} L', Icons.water_drop_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _ProfileMetric('Trend', cow.trend, Icons.trending_down)),
            ],
          ),
          if (alert != null) ...[
            const SizedBox(height: 10),
            AppHint(icon: Icons.notifications_active_outlined, message: alert.message, color: riskSurface(cow.risk)),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CowHealthLookupScreen(state: state),
              ),
            ),
            icon: const Icon(Icons.monitor_heart_outlined),
            label: const Text('View health and sensor details'),
          ),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Start milking for ${cow.name}', icon: Icons.qr_code_scanner, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScanScreen(state: state, cow: cow)))),
          const SizedBox(height: 18),
          const SectionHeader('Timeline & history'),
          ...cow.timeline.map((item) => ListTile(leading: Icon(Icons.circle, size: 12, color: riskColor(cow.risk)), title: Text(item))),
          OutlinedButton.icon(onPressed: () => state.addHealthRecord(cow, 'Health note'), icon: const Icon(Icons.add_circle_outline), label: const Text('Add health record')),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      const SizedBox(height: 6),
      Icon(icon, color: GauColors.forest),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
    ]),
  );
}

class MilkScreen extends StatelessWidget { const MilkScreen({super.key, required this.state}); final FarmState state; @override Widget build(BuildContext context) { final trend = state.milkTrend; final today = trend.isEmpty ? state.totalMilk : trend.last.litres; final previous = trend.length < 2 ? today : trend[trend.length - 2].litres; final delta = today - previous; return SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const Text('Milk', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text('Production linked to cow sessions. ${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} L vs yesterday.'), const SizedBox(height: 16), _MilkSummary(total: state.totalMilk, delta: delta), const SizedBox(height: 16), const Text('Seven-day production', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8), _MilkTrendChart(values: trend.map((item) => item.litres).toList()), const SizedBox(height: 18), const Text('Cow-wise production', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8), ...state.cows.map((cow) => ListTile(leading: CowAvatar(cow: cow), title: Text(cow.name), subtitle: Text('${cow.tag} • ${cow.trend}'), trailing: Text('${cow.todayMilkLitres.toStringAsFixed(1)} L')))])); } }

class CowHealthLookupScreen extends StatefulWidget {
  const CowHealthLookupScreen({super.key, required this.state});
  final FarmState state;
  @override State<CowHealthLookupScreen> createState() => _CowHealthLookupScreenState();
}

class _CowHealthLookupScreenState extends State<CowHealthLookupScreen> {
  final _cowId = TextEditingController();
  Cow? _cow;
  bool _searched = false;
  bool _loading = false;
  @override void dispose() { _cowId.dispose(); super.dispose(); }
  Future<void> _search() async { setState(() => _loading = true); final cow = await widget.state.findCowFromCsv(_cowId.text); if (mounted) setState(() { _cow = cow; _searched = true; _loading = false; }); }
  @override Widget build(BuildContext context) => _CsvLookupScaffold(
    title: tr(widget.state.language, 'cowHealth'), subtitle: tr(widget.state.language, 'healthSubtitle'), controller: _cowId, buttonLabel: tr(widget.state.language, 'checkHealth'), onSearch: _search, searched: _searched, loading: _loading, cow: _cow, row: widget.state.sampleData.isEmpty ? const {} : widget.state.sampleData.last, language: widget.state.language,
    emptyMessage: 'No health record found. Try COW_0002 or COW-02.', extra: _HealthCsvCharts(rows: widget.state.sampleData), sections: [
      _CsvSection('Health & wearable readings', Icons.monitor_heart_outlined, [
        _CsvMetric('Body temperature', 'body_temperature_c', Icons.thermostat, ' °C'),
        _CsvMetric('Udder temperature', 'udder_temperature_c', Icons.device_thermostat, ' °C'),
        _CsvMetric('Rumination', 'rumination_minutes', Icons.psychology_outlined, ' min'),
        _CsvMetric('Udder swelling', 'udder_swelling_score', Icons.water_damage_outlined, ''),
        _CsvMetric('Udder redness', 'udder_redness_score', Icons.color_lens_outlined, ''),
        _CsvMetric('Risk category', 'risk_category', Icons.warning_amber_rounded, ''),
        _CsvMetric('Risk probability', 'risk_probability', Icons.percent, '%', percentage: true),
        _CsvMetric('Mastitis now', 'mastitis_current', Icons.health_and_safety_outlined, '', yesNo: true),
      ]),
      _CsvSection('Health history & care', Icons.medical_information_outlined, [
        _CsvMetric('Previous mastitis', 'previous_mastitis_history', Icons.history, '', yesNo: true),
        _CsvMetric('Vaccination', 'vaccination_status', Icons.vaccines_outlined, ''),
        _CsvMetric('Previous diseases', 'previous_disease_count', Icons.sick_outlined, ''),
        _CsvMetric('Antibiotics in last 30 days', 'antibiotic_treatment_last_30_days', Icons.medication_outlined, '', yesNo: true),
      ], compact: true),
    ],
  );
}

class MilkLookupScreen extends StatefulWidget {
  const MilkLookupScreen({super.key, required this.state});
  final FarmState state;
  @override State<MilkLookupScreen> createState() => _MilkLookupScreenState();
}

class _MilkLookupScreenState extends State<MilkLookupScreen> {
  final _cowId = TextEditingController();
  Cow? _cow;
  bool _searched = false;
  bool _loading = false;
  @override void dispose() { _cowId.dispose(); super.dispose(); }
  Future<void> _search() async { setState(() => _loading = true); final cow = await widget.state.findCowFromCsv(_cowId.text); if (mounted) setState(() { _cow = cow; _searched = true; _loading = false; }); }
  @override Widget build(BuildContext context) => _CsvLookupScaffold(
    title: tr(widget.state.language, 'milkMonitoring'), subtitle: tr(widget.state.language, 'milkSubtitle'), controller: _cowId, buttonLabel: tr(widget.state.language, 'checkMilk'), onSearch: _search, searched: _searched, loading: _loading, cow: _cow, row: widget.state.sampleData.isEmpty ? const {} : widget.state.sampleData.last, language: widget.state.language,
    emptyMessage: 'No milk record found. Try COW_0002 or COW-02.', extra: _MilkCsvCharts(rows: widget.state.sampleData), sections: [
      _CsvSection('Milk quality & milking readings', Icons.water_drop_outlined, [
        _CsvMetric('Yield', 'milk_yield_liters', Icons.water_drop_outlined, ' L'),
        _CsvMetric('Conductivity', 'milk_conductivity_ms_cm', Icons.speed, ' mS/cm'),
        _CsvMetric('Milk temperature', 'milk_temperature_c', Icons.thermostat, ' °C'),
        _CsvMetric('Milk pH', 'milk_ph', Icons.science_outlined, ''),
        _CsvMetric('Somatic cell count', 'somatic_cell_count', Icons.biotech_outlined, ''),
        _CsvMetric('Milking duration', 'milking_duration_minutes', Icons.timer_outlined, ' min'),
        _CsvMetric('Hygiene score', 'milking_hygiene_score', Icons.clean_hands_outlined, ''),
        _CsvMetric('Milk abnormality', 'milk_abnormality_score', Icons.opacity_outlined, ''),
      ]),
      _CsvSection('Milking session', Icons.event_note_outlined, [
        _CsvMetric('Session', 'reading_session', Icons.wb_sunny_outlined, ''),
        _CsvMetric('Recorded date', 'recorded_date', Icons.calendar_today_outlined, ''),
        _CsvMetric('Recorded time', 'recorded_time', Icons.schedule_outlined, ''),
        _CsvMetric('Milking interval', 'milking_interval_hours', Icons.timelapse_outlined, ' hours'),
      ], compact: true),
    ],
  );
}

class _CsvLookupScaffold extends StatelessWidget {
  const _CsvLookupScaffold({required this.title, required this.subtitle, required this.controller, required this.buttonLabel, required this.onSearch, required this.searched, required this.loading, required this.cow, required this.row, required this.emptyMessage, required this.sections, required this.language, this.extra});
  final String title, subtitle, buttonLabel, emptyMessage;
  final TextEditingController controller;
  final Future<void> Function() onSearch;
  final bool searched, loading;
  final Cow? cow;
  final Map<String, dynamic> row;
  final List<_CsvSection> sections;
  final AppLanguage language;
  final Widget? extra;
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: GauColors.cream, appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent), body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 920), child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
    Container(padding: const EdgeInsets.fromLTRB(18, 18, 18, 16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFE5F4E6), Color(0xFFF8FBF7)]), borderRadius: BorderRadius.circular(22), border: Border.all(color: GauColors.forest.withValues(alpha: 0.10))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: GauColors.forest, borderRadius: BorderRadius.circular(14)), child: Icon(title == tr(language, 'milkMonitoring') ? Icons.water_drop_outlined : Icons.monitor_heart_outlined, color: Colors.white, size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: GauColors.ink)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.black54, height: 1.3))]))])),
    const SizedBox(height: 16),
    LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      final field = TextField(controller: controller, textCapitalization: TextCapitalization.characters, textInputAction: TextInputAction.search, onSubmitted: (_) => onSearch(), decoration: InputDecoration(hintText: tr(language, 'cowIdHint'), prefixIcon: const Icon(Icons.qr_code_scanner), filled: true, fillColor: const Color(0xFFF0F6F0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)));
      final button = FilledButton.icon(onPressed: loading ? null : onSearch, icon: loading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.search), label: Text(buttonLabel));
      return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: GauColors.forest.withValues(alpha: 0.12))), child: compact ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [field, const SizedBox(height: 10), SizedBox(height: 48, child: button)]) : Row(children: [Expanded(child: field), const SizedBox(width: 10), SizedBox(height: 48, child: button)]));
    }),
    const SizedBox(height: 10),
    Text(tr(language, 'idFormats'), style: const TextStyle(fontSize: 12, color: Colors.black54)),
    if (searched && cow == null) Padding(padding: const EdgeInsets.only(top: 16), child: AppHint(icon: Icons.search_off_outlined, message: emptyMessage)),
    if (cow != null) ...[
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [CowAvatar(cow: cow!), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cow!.tag, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text('${_csvText(row, 'breed')} · ${_csvText(row, 'reading_session')}', style: const TextStyle(color: Colors.black54))])), StatusBadge(risk: cow!.risk)]))),
      if (extra != null) Padding(padding: const EdgeInsets.only(top: 12), child: extra!),
      ...sections.map((section) => Padding(padding: const EdgeInsets.only(top: 12), child: _CsvSectionCard(section: section, row: row))),
    ],
  ])))));
}

class _HealthCsvCharts extends StatelessWidget {
  const _HealthCsvCharts({required this.rows});
  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    final temperatures = rows.map((row) => _csvNumber(row, 'udder_temperature_c')).whereType<double>().toList();
    final risk = rows.map((row) => _csvNumber(row, 'risk_probability')).whereType<double>().toList();
    if (temperatures.isEmpty && risk.isEmpty) return const SizedBox.shrink();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wearable trend', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Color-coded bars make changes easy to spot across recent readings.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 14),
          SizedBox(height: 150, child: _CsvBarChart(values: (temperatures.isEmpty ? risk : temperatures).take(12).toList(), colors: const [Color(0xFF2E7D5B), Color(0xFF70B77E), Color(0xFFF2B84B), Color(0xFFE7764B)])),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.bar_chart_rounded, size: 16, color: GauColors.forest), const SizedBox(width: 6), Text(temperatures.isEmpty ? 'Risk probability' : 'Udder temperature', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), const Spacer(), Text('${rows.length} readings', style: const TextStyle(fontSize: 12, color: Colors.black54))]),
          const SizedBox(height: 16),
          const Text('Latest health balance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _HealthBalanceChart(row: rows.last),
        ],
      ),
    );
  }
}

class _MilkCsvCharts extends StatelessWidget {
  const _MilkCsvCharts({required this.rows});
  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    final yields = rows.map((row) => _csvNumber(row, 'milk_yield_liters')).whereType<double>().toList();
    final conductivity = rows.map((row) => _csvNumber(row, 'milk_conductivity_ms_cm')).whereType<double>().toList();
    if (yields.isEmpty) return const SizedBox.shrink();
    final barValues = yields.length > 12 ? yields.sublist(yields.length - 12) : yields;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Milk monitoring', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Recent CSV readings for this cow, with colorful yield and conductivity bars.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 14),
          const Text('Yield by reading (L)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SizedBox(height: 112, child: _CsvBarChart(values: barValues)),
          const SizedBox(height: 16),
          const Text('Conductivity pattern (mS/cm)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SizedBox(height: 112, child: _CsvBarChart(values: conductivity.take(12).toList(), colors: const [Color(0xFFF2B84B), Color(0xFFE7764B), Color(0xFFDD5D7A), Color(0xFF8B6FC4)])),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.insights_outlined, size: 16, color: GauColors.amber), const SizedBox(width: 6), Text('${rows.length} CSV readings loaded', style: const TextStyle(fontSize: 12, color: Colors.black54)), const Spacer(), if (conductivity.isNotEmpty) Text('latest ${conductivity.last.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 18),
          const Text('Yield and quality balance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('The donut compares the latest output with a conductivity quality signal.', style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 8),
          SizedBox(height: 150, child: _MilkBalanceChart(yields: yields, conductivity: conductivity)),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}

class _CsvBarChart extends StatelessWidget {
  const _CsvBarChart({required this.values, this.colors = const [GauColors.mint, GauColors.forest]});
  final List<double> values;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final maximum = values.fold<double>(0, (max, value) => value > max ? value : max);
     return Row(crossAxisAlignment: CrossAxisAlignment.end, children: values.asMap().entries.map((entry) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [Expanded(child: Align(alignment: Alignment.bottomCenter, child: Container(width: double.infinity, height: maximum <= 0 ? 0 : 92 * entry.value / maximum, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [colors[entry.key % colors.length], colors[entry.key % colors.length].withValues(alpha: 0.55)]), borderRadius: BorderRadius.circular(7))))), const SizedBox(height: 4), Text(entry.value.toStringAsFixed(0), style: const TextStyle(fontSize: 9, color: Colors.black54))])))).toList());
  }
}

class _HealthBalanceChart extends StatelessWidget {
  const _HealthBalanceChart({required this.row});
  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final values = [
      _csvNumber(row, 'risk_probability') ?? 0,
      (((_csvNumber(row, 'udder_swelling_score') ?? 0) / 5).clamp(0, 1) * 100).toDouble(),
      (((_csvNumber(row, 'udder_redness_score') ?? 0) / 5).clamp(0, 1) * 100).toDouble(),
      (((_csvNumber(row, 'rumination_minutes') ?? 0) / 600).clamp(0, 1) * 100).toDouble(),
    ];
    return Row(children: [
      SizedBox(width: 126, height: 126, child: CustomPaint(painter: _DonutPainter(values: values, colors: const [Color(0xFFE7764B), Color(0xFFF2B84B), Color(0xFFDD5D7A), Color(0xFF70B77E)]))),
      const SizedBox(width: 14),
      Expanded(child: Wrap(spacing: 10, runSpacing: 8, children: const [
        _ChartLegend(color: Color(0xFFE7764B), label: 'Risk'),
        _ChartLegend(color: Color(0xFFF2B84B), label: 'Swelling'),
        _ChartLegend(color: Color(0xFFDD5D7A), label: 'Redness'),
        _ChartLegend(color: Color(0xFF70B77E), label: 'Rumination'),
      ])),
    ]);
  }
}

class _MilkBalanceChart extends StatelessWidget {
  const _MilkBalanceChart({required this.yields, required this.conductivity});
  final List<double> yields;
  final List<double> conductivity;

  @override
  Widget build(BuildContext context) {
    final double latestYield = yields.isEmpty ? 0.0 : yields.last;
    final double latestConductivity = conductivity.isEmpty ? 0.0 : conductivity.last;
    final quality = (latestConductivity / 8 * 100).clamp(0, 100).toDouble();
    return Row(children: [
      SizedBox(width: 126, height: 126, child: CustomPaint(painter: _DonutPainter(values: [latestYield, quality], colors: const [Color(0xFF2E7D5B), Color(0xFFF2B84B)]))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        _ChartLegend(color: const Color(0xFF2E7D5B), label: 'Yield ${latestYield.toStringAsFixed(1)} L'),
        const SizedBox(height: 10),
        _ChartLegend(color: const Color(0xFFF2B84B), label: 'Conductivity ${latestConductivity.toStringAsFixed(2)} mS/cm'),
      ])),
    ]);
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54))]);
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.values, required this.colors});
  final List<double> values;
  final List<Color> colors;
  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value.abs());
    if (total <= 0) return;
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 22..strokeCap = StrokeCap.round;
    var start = -math.pi / 2;
    for (var index = 0; index < values.length; index++) {
      final sweep = (values[index].abs() / total) * math.pi * 2;
      paint.color = colors[index % colors.length];
      canvas.drawArc(rect.deflate(12), start, sweep - 0.035, false, paint);
      start += sweep;
    }
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 25, Paint()..color = Colors.white);
    canvas.drawCircle(center, 3, Paint()..color = GauColors.forest);
  }
  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.values != values;
}

double? _csvNumber(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

class _CsvSection { const _CsvSection(this.title, this.icon, this.metrics, {this.compact = false}); final String title; final IconData icon; final List<_CsvMetric> metrics; final bool compact; }
class _CsvMetric { const _CsvMetric(this.label, this.key, this.icon, this.suffix, {this.percentage = false, this.yesNo = false}); final String label, key, suffix; final IconData icon; final bool percentage, yesNo; }
class _CsvSectionCard extends StatelessWidget { const _CsvSectionCard({required this.section, required this.row}); final _CsvSection section; final Map<String, dynamic> row; @override Widget build(BuildContext context) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(section.icon, color: GauColors.forest), const SizedBox(width: 8), Expanded(child: Text(section.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)))]), const SizedBox(height: 12), if (section.compact) ...section.metrics.map((metric) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Expanded(child: Text(metric.label, style: const TextStyle(color: Colors.black54))), Text(_csvMetricText(row, metric), style: const TextStyle(fontWeight: FontWeight.w800))]))) else LayoutBuilder(builder: (context, constraints) => Wrap(spacing: 8, runSpacing: 8, children: section.metrics.map((metric) => SizedBox(width: (constraints.maxWidth - 8) / 2, child: _CsvTile(metric: metric, row: row))).toList()))])); }
class _CsvTile extends StatelessWidget { const _CsvTile({required this.metric, required this.row}); final _CsvMetric metric; final Map<String, dynamic> row; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: GauColors.mint, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(metric.icon, color: GauColors.forest, size: 20), const SizedBox(height: 7), Text(metric.label, style: const TextStyle(fontSize: 11, color: Colors.black54)), const SizedBox(height: 2), Text(_csvMetricText(row, metric), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))])); }
String _csvText(Map<String, dynamic> row, String key) { final value = row[key]; return value == null || value.toString().trim().isEmpty ? 'Not available' : value.toString(); }
String _csvMetricText(Map<String, dynamic> row, _CsvMetric metric) { final value = row[metric.key]; if (value == null || value.toString().trim().isEmpty) return 'Not available'; if (metric.yesNo) return ['1', 'true', 'yes', 'y'].contains(value.toString().toLowerCase()) ? 'Yes' : 'No'; final number = value is num ? value.toDouble() : double.tryParse(value.toString()); if (metric.percentage && number != null) return '${(number * 100).toStringAsFixed(1)}%'; if (number != null) return '${number.toStringAsFixed(number % 1 == 0 ? 0 : 2)}${metric.suffix}'; return '$value${metric.suffix}'; }

class _MilkSummary extends StatelessWidget { const _MilkSummary({required this.total, required this.delta}); final double total, delta; @override Widget build(BuildContext context) => AppCard(child: Row(children: [const Icon(Icons.water_drop, color: GauColors.forest, size: 34), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Today’s total', style: TextStyle(color: Colors.black54)), Text('${total.toStringAsFixed(1)} L', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: GauColors.forest))])), Text('${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} L', style: TextStyle(fontWeight: FontWeight.w900, color: delta >= 0 ? GauColors.forest : GauColors.red))])); }

class _MilkTrendChart extends StatelessWidget {
  const _MilkTrendChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const EmptyState(
        icon: Icons.show_chart,
        title: 'More history needed',
        message: 'Complete more milking sessions to see a useful trend.',
      );
    }
    final maximum = values.reduce((a, b) => a > b ? a : b);
    return AppCard(
      child: SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: values.map((value) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      height: maximum <= 0 ? 0 : 92 * value / maximum,
                      decoration: BoxDecoration(
                        color: value == values.last ? GauColors.forest : GauColors.mint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Icon(Icons.circle, size: 5, color: GauColors.forest),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
class AlertsScreen extends StatelessWidget { const AlertsScreen({super.key, required this.state}); final FarmState state; @override Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const Text('Alerts', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 16), if (state.alerts.isEmpty) const EmptyState(icon: Icons.check_circle_outline, title: 'No open alerts', message: 'You have reviewed every current alert.') else ...state.alerts.map((alert) { final cow = state.cowByTag(alert.cowTag); if (cow == null) return Card(child: ListTile(title: const Text('Cow needs attention'), subtitle: Text(alert.message))); return Dismissible(key: ObjectKey(alert), direction: DismissDirection.endToStart, onDismissed: (_) => state.removeAlert(alert), background: Container(color: GauColors.forest), child: _AlertCard(cow: cow, message: alert.message)); })])); }
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.state});
  final FarmState state;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('More', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const Text('Farm tools and account settings', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),
        _Setting(title: 'Alerts', subtitle: state.alerts.isEmpty ? 'No open alerts' : '${state.alerts.length} open alert${state.alerts.length == 1 ? '' : 's'}', icon: Icons.notifications_active_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlertsScreen(state: state)))),
        _Setting(title: 'Farm settings', subtitle: '${state.farm.name} · ${state.farm.location}', icon: Icons.agriculture_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FarmSettingsScreen(state: state)))),
        _Setting(title: 'Profile', subtitle: 'Farmer account and farm access', icon: Icons.person_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(state: state)))),
        _Setting(title: 'Daily barn checklist', subtitle: 'Water, hygiene, sensors, and herd observation', icon: Icons.checklist_rtl_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyChecklistScreen()))),
        _Setting(title: tr(state.language, 'language'), subtitle: state.language.label, icon: Icons.language, onTap: () => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => _LanguagePicker(state: state))),
        _Setting(title: 'Offline and sync', subtitle: state.isOnline ? 'Demo data cached on this device' : 'Working offline; retry sync when connected', icon: Icons.cloud_outlined, onTap: state.toggleConnection),
        _Setting(title: 'Devices', subtitle: state.sensorNodes.isEmpty ? 'No sensor nodes have sent readings yet' : '${state.sensorNodes.length} node${state.sensorNodes.length == 1 ? '' : 's'} connected', icon: Icons.sensors_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SensorNodesScreen(state: state)))),
        const _Setting(title: 'Help', subtitle: 'How to scan, milk, and review alerts', icon: Icons.help_outline),
        _Setting(title: 'Reviews', subtitle: 'Tell us what would make barn work easier', icon: Icons.rate_review_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewsScreen(state: state)))),
        _Setting(title: 'About GauRakshak', subtitle: 'Offline-first herd and milk monitoring', icon: Icons.info_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
      ],
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.state});
  final FarmState state;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      AppCard(child: Column(children: [
        CircleAvatar(radius: 34, backgroundColor: GauColors.mint, child: const Icon(Icons.person, size: 38, color: GauColors.forest)),
        const SizedBox(height: 12),
        const Text('Farm manager', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(state.farm.name, style: const TextStyle(color: Colors.black54)),
      ])),
      const SizedBox(height: 8),
      _InfoTile(icon: Icons.phone_outlined, title: 'Registered mobile', value: 'Verified account'),
      _InfoTile(icon: Icons.location_on_outlined, title: 'Farm location', value: state.farm.location),
      _InfoTile(icon: Icons.pets_outlined, title: 'Herd access', value: '${state.cows.length} cows currently loaded'),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your profile is stored locally on this device.'))), icon: const Icon(Icons.privacy_tip_outlined), label: const Text('Privacy and data note')),
    ]),
  );
}

class FarmSettingsScreen extends StatefulWidget {
  const FarmSettingsScreen({super.key, required this.state});
  final FarmState state;
  @override State<FarmSettingsScreen> createState() => _FarmSettingsScreenState();
}

class _FarmSettingsScreenState extends State<FarmSettingsScreen> {
  late final TextEditingController _name = TextEditingController(text: widget.state.farm.name);
  late final TextEditingController _location = TextEditingController(text: widget.state.farm.location);
  late final TextEditingController _herd = TextEditingController(text: widget.state.farm.herdSize.toString());
  @override void dispose() { _name.dispose(); _location.dispose(); _herd.dispose(); super.dispose(); }
  void _save() {
    final herd = int.tryParse(_herd.text.trim());
    if (_name.text.trim().isEmpty || _location.text.trim().isEmpty || herd == null || herd < 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a farm name, location, and valid herd size.'))); return; }
    widget.state.setupFarm(_name.text.trim(), _location.text.trim(), herd);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Farm settings saved')));
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Farm settings')), body: ListView(padding: const EdgeInsets.all(20), children: [const Text('Keep your farm card up to date', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 6), const Text('These details appear on your dashboard and stay available offline.', style: TextStyle(color: Colors.black54)), const SizedBox(height: 20), TextField(controller: _name, decoration: const InputDecoration(labelText: 'Farm name', prefixIcon: Icon(Icons.agriculture_outlined))), const SizedBox(height: 12), TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on_outlined))), const SizedBox(height: 12), TextField(controller: _herd, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Herd size', prefixIcon: Icon(Icons.pets_outlined))), const SizedBox(height: 24), FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Save settings'))]));
}

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key, required this.state});
  final FarmState state;
  @override State<ReviewsScreen> createState() => _ReviewsScreenState();
}
class _ReviewsScreenState extends State<ReviewsScreen> {
  int _rating = 0;
  final _note = TextEditingController();
  @override void dispose() { _note.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Reviews')), body: ListView(padding: const EdgeInsets.all(20), children: [const Text('Help us improve GauRakshak', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 6), const Text('Your feedback helps us make herd work faster and clearer.', style: TextStyle(color: Colors.black54)), const SizedBox(height: 20), AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('How is your experience?', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 10), Row(children: List.generate(5, (index) => IconButton(onPressed: () => setState(() => _rating = index + 1), icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: GauColors.amber, size: 32)))), TextField(controller: _note, maxLines: 4, decoration: const InputDecoration(hintText: 'What should we improve?', alignLabelWithHint: true)), const SizedBox(height: 14), FilledButton.icon(onPressed: _rating == 0 ? null : () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks — your review was saved on this device.'))); Navigator.pop(context); }, icon: const Icon(Icons.send_outlined), label: const Text('Submit review'))]))]));
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('About GauRakshak')), body: ListView(padding: const EdgeInsets.all(20), children: [AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: GauColors.mint, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.pets, color: GauColors.forest, size: 30)), const SizedBox(width: 12), const Text('GauRakshak', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900))]), const SizedBox(height: 14), const Text('An offline-first dairy companion for cow health, wearable sensor readings, and milk monitoring.'), const SizedBox(height: 16), const Text('Version 1.0 · Phase 2', style: TextStyle(fontWeight: FontWeight.w800, color: GauColors.forest))])), const SizedBox(height: 12), const _InfoTile(icon: Icons.wifi_off_outlined, title: 'Works offline', value: 'Records stay available in the barn and sync when connected.'), const _InfoTile(icon: Icons.monitor_heart_outlined, title: 'Early warning', value: 'Health indicators support review; they do not replace a veterinarian.'), const _InfoTile(icon: Icons.lock_outline, title: 'Your data', value: 'Demo and locally entered records remain on this device.'), const SizedBox(height: 18), Center(child: Text('Made for calmer, clearer dairy work.', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic))) ]));
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.value});
  final IconData icon; final String title, value;
  @override Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: GauColors.forest), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(value)));
}

class DailyChecklistScreen extends StatefulWidget {
  const DailyChecklistScreen({super.key});
  @override State<DailyChecklistScreen> createState() => _DailyChecklistScreenState();
}

class _DailyChecklistScreenState extends State<DailyChecklistScreen> {
  final List<(String, String, IconData)> _items = const [
    ('Clean water available', 'Check troughs before the morning session.', Icons.water_drop_outlined),
    ('Milking hygiene ready', 'Clean equipment and dry teats before milking.', Icons.cleaning_services_outlined),
    ('Wearable sensors checked', 'Confirm battery, fit, and latest sync.', Icons.sensors_outlined),
    ('Herd observation complete', 'Look for appetite, gait, udder, and behaviour changes.', Icons.visibility_outlined),
  ];
  final Set<int> _complete = {};
  @override Widget build(BuildContext context) {
    final allDone = _complete.length == _items.length;
    return Scaffold(appBar: AppBar(title: const Text('Daily barn checklist')), body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(allDone ? 'Barn check complete' : 'Start the day prepared', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6), Text('${_complete.length} of ${_items.length} tasks complete', style: const TextStyle(color: Colors.black54)), const SizedBox(height: 16),
      LinearProgressIndicator(value: _complete.length / _items.length, minHeight: 8, borderRadius: BorderRadius.circular(20), color: GauColors.forest, backgroundColor: GauColors.mint), const SizedBox(height: 18),
      ..._items.indexed.map((entry) { final index = entry.$1; final item = entry.$2; final complete = _complete.contains(index); return Card(child: CheckboxListTile(value: complete, onChanged: (_) => setState(() => complete ? _complete.remove(index) : _complete.add(index)), activeColor: GauColors.forest, secondary: Icon(item.$3, color: complete ? GauColors.forest : Colors.black54), title: Text(item.$1, style: TextStyle(fontWeight: FontWeight.w800, decoration: complete ? TextDecoration.lineThrough : null)), subtitle: Text(item.$2))); }),
      if (allDone) Padding(padding: const EdgeInsets.only(top: 8), child: FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Great work — your daily barn check is complete.'))), icon: const Icon(Icons.celebration_outlined), label: const Text('Mark day ready'))),
    ]));
  }
}

class SensorNodesScreen extends StatefulWidget {
  const SensorNodesScreen({super.key, required this.state});
  final FarmState state;

  @override
  State<SensorNodesScreen> createState() => _SensorNodesScreenState();
}

class _SensorNodesScreenState extends State<SensorNodesScreen> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await widget.state.loadSensorNodes();
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sensor nodes')),
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Wearable and milking nodes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Node status comes from persisted sensor readings. Connect a node during a milking session to see it here.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            if (_refreshing) const LinearProgressIndicator(),
            if (widget.state.sensorNodes.isEmpty)
              const EmptyState(icon: Icons.sensors_off_outlined, title: 'No node activity yet', message: 'Start a sensor-assisted milking session to register a node and collect readings.')
            else
              ...widget.state.sensorNodes.map((node) => AppCard(child: Row(children: [Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: node.isOnline ? GauColors.healthySurface : GauColors.mint, borderRadius: BorderRadius.circular(13)), child: Icon(Icons.sensors, color: node.isOnline ? GauColors.forest : Colors.black54)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(node.sensorId, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), const SizedBox(height: 2), Text('Cow ${node.cowTag} · ${node.readingCount} readings', style: const TextStyle(color: Colors.black54)), const SizedBox(height: 3), Text('Last seen ${node.lastSeenAt.toLocal().toString().substring(0, 16)}', style: const TextStyle(fontSize: 12, color: Colors.black54))])), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: node.isOnline ? GauColors.healthySurface : GauColors.mint, borderRadius: BorderRadius.circular(12)), child: Text(node.isOnline ? 'ONLINE' : 'IDLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: node.isOnline ? GauColors.forest : Colors.black54))) ]))),
          ],
        ),
      ),
    ),
  );
}
class GauSaathiSheet extends StatefulWidget {
  const GauSaathiSheet({super.key, required this.state});

  final FarmState state;

  @override
  State<GauSaathiSheet> createState() => _GauSaathiSheetState();
}

class _GauSaathiSheetState extends State<GauSaathiSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_AssistantMessage>[];
  bool _isReplying = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _ask(String question) async {
    final text = question.trim();
    if (text.isEmpty || _isReplying) return;
    setState(() {
      _messages.add(_AssistantMessage(text, true));
      _isReplying = true;
      _input.clear();
    });
    final backendAnswer = await widget.state.askGauSaathi(text);
    // The demo backend may not have a selected cow yet; use the richer local
    // intent router instead of showing the same generic sentence every time.
    final answer = backendAnswer == null ||
            backendAnswer.startsWith("I can explain your cows' health")
        ? _answer(text)
        : backendAnswer;
    if (!mounted) return;
    setState(() {
      _messages.add(_AssistantMessage(answer, false));
      _isReplying = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _answer(String question) {
    final lower = question.toLowerCase();
    if (RegExp(r'^(hi|hii|hello|hey|namaste)\b').hasMatch(lower)) {
      final selected = widget.state.selectedCow;
      return selected == null
          ? 'Hi! I can help you check cows, milk records, health signals, and sensor-node status. Try “Which cows need attention?” or enter a cow ID in Health or Milk.'
          : 'Hi! ${selected.name} is the cow you last checked. Ask me about her milk, health, risk, or latest sensor reading.';
    }
    final cow = widget.state.cows.firstWhere(
      (item) => lower.contains(item.name.toLowerCase()) || lower.contains(item.tag.toLowerCase()),
      orElse: () => widget.state.selectedCow ?? widget.state.cows.first,
    );
    if (lower.contains('which') || lower.contains('attention') || lower.contains('risk')) {
      final cows = widget.state.cows.where((item) => item.risk != RiskLevel.healthy).toList();
      if (cows.isEmpty) return 'Your herd has no cows marked for attention right now. Keep checking at the next milking.';
      return 'Start with ${cows.map((item) => item.name).join(', ')}. ${cows.first.factors.isEmpty ? 'The system needs more observations for the reason.' : cows.first.factors.join('. ')} Check visible symptoms and contact a veterinarian if needed.';
    }
    if (lower.contains('milk') || lower.contains('production') || lower.contains('yield')) {
      final latest = widget.state.sampleData.isEmpty ? null : widget.state.sampleData.last;
      final conductivity = latest == null ? null : _csvNumber(latest, 'milk_conductivity_ms_cm');
      return '${cow.name} is showing ${cow.todayMilkLitres.toStringAsFixed(1)} L in the latest record. ${conductivity == null ? 'Open Milk to review the chart.' : 'Latest conductivity is ${conductivity.toStringAsFixed(2)} mS/cm. Open Milk to compare the yield bars and pulse chart.'}';
    }
    if (lower.contains('changed') || lower.contains('health')) {
      final history = cow.timeline.take(3).join('. ');
      return '${cow.name} is marked ${cow.risk.label.toLowerCase()}. Recent records: $history. This is an early-warning estimate, not a diagnosis.';
    }
    if (lower.contains('sensor') || lower.contains('node') || lower.contains('device')) {
      if (widget.state.sensorNodes.isEmpty) return 'No sensor nodes have sent a persisted reading yet. Start a sensor-assisted milking session, then open More → Devices.';
      final node = widget.state.sensorNodes.first;
      return '${node.sensorId} is linked to ${node.cowTag} and is ${node.isOnline ? 'online' : 'idle'}. It has ${node.readingCount} persisted readings.';
    }
    return 'I can help with a cow’s milk, health, risk, sensor node, or CSV monitoring charts. Try “How is milk production?” or “Tell me about COW_0002.”';
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Which cows need attention?',
      'Why is Gauri’s risk high?',
      'How is milk production?',
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: GauColors.mint,
                  child: Icon(Icons.chat_bubble_outline, color: GauColors.forest),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GauSaathi', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                      Text('Your farm assistant', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Ask about your herd in simple words. I am a helper, not a veterinarian.'),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) => ActionChip(
                  label: Text(suggestions[index]),
                  onPressed: () => _ask(suggestions[index]),
                ),
              ),
            ),
            if (_messages.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.28,
                child: ListView.builder(
                  controller: _scroll,
                  itemCount: _messages.length,
                  itemBuilder: (_, index) {
                    final message = _messages[index];
                    return Align(
                      alignment: message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 310),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.fromUser ? GauColors.forest : GauColors.mint,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(color: message.fromUser ? Colors.white : GauColors.ink),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_isReplying) const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 8), Text('GauSaathi is checking your farm data…')]),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) => _ask(value),
                    decoration: const InputDecoration(
                      hintText: 'Ask GauSaathi',
                      prefixIcon: Icon(Icons.chat_bubble_outline),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isReplying ? null : () => _ask(_input.text),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.state});

  final FarmState state;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tr(state.language, 'chooseLanguage'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...AppLanguage.values.map((language) => RadioListTile<AppLanguage>(
            value: language,
            groupValue: state.language,
            title: Text(language.label),
            subtitle: Text(language == AppLanguage.english ? 'English' : language == AppLanguage.hindi ? 'Hindi' : 'Marathi'),
            onChanged: (value) {
              if (value == null) return;
              state.setLanguage(value);
              Navigator.pop(context);
            },
          )),
        ],
      ),
    ),
  );
}

class _AssistantMessage {
  const _AssistantMessage(this.text, this.fromUser);

  final String text;
  final bool fromUser;
}
class _CowCard extends StatelessWidget { const _CowCard({required this.cow, required this.onTap}); final Cow cow; final VoidCallback onTap; @override Widget build(BuildContext context) => Card(child: ListTile(onTap: onTap, leading: CowAvatar(cow: cow), title: Text(cow.name), subtitle: Text('${cow.tag} • ${cow.breed}'), trailing: StatusBadge(risk: cow.risk))); }
class _AlertCard extends StatelessWidget { const _AlertCard({required this.cow, required this.message}); final Cow cow; final String message; @override Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(riskIcon(cow.risk), color: riskColor(cow.risk)), title: Text('${cow.name} needs attention'), subtitle: Text(message))); }
class _Setting extends StatelessWidget { const _Setting({required this.title, required this.subtitle, required this.icon, this.onTap}); final String title, subtitle; final IconData icon; final VoidCallback? onTap; @override Widget build(BuildContext context) => Card(child: ListTile(onTap: onTap, leading: Icon(icon, color: GauColors.forest), title: Text(title), subtitle: Text(subtitle), trailing: onTap == null ? null : const Icon(Icons.chevron_right))); }

class _HerdMetric extends StatelessWidget {
  const _HerdMetric({
    required this.value, required this.label, required this.icon, 
    required this.iconColor, required this.bgColor, required this.valueColor
  });
  final String value, label;
  final IconData icon;
  final Color iconColor, bgColor, valueColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
    child: Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: valueColor)),
        const SizedBox(height: 4),
        Icon(icon, color: iconColor, size: 20),
      ],
    ),
  );
}
