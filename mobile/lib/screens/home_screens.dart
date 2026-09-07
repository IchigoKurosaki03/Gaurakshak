import 'package:flutter/material.dart';
import '../models/domain.dart';
import '../state/farm_state.dart';
import '../theme/gau_theme.dart';
import '../widgets/app_widgets.dart';
import 'milking_screens.dart';
import 'onboarding_screens.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key, required this.state}); final FarmState state; @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> { int tab = 0; @override Widget build(BuildContext context) { final pages = [DashboardScreen(state: widget.state), CowsScreen(state: widget.state), MilkScreen(state: widget.state), AlertsScreen(state: widget.state), MoreScreen(state: widget.state)]; return AnimatedBuilder(animation: widget.state, builder: (context, child) => Scaffold(body: pages[tab], floatingActionButton: tab == 0 ? FloatingActionButton.extended(backgroundColor: GauColors.ink, foregroundColor: GauColors.white, icon: const Icon(Icons.auto_awesome), label: const Text('GauSaathi'), onPressed: () => showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => GauSaathiSheet(state: widget.state))) : null, bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (value) => setState(() => tab = value), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'), NavigationDestination(icon: Icon(Icons.pets_outlined), label: 'Cows'), NavigationDestination(icon: Icon(Icons.water_drop_outlined), label: 'Milk'), NavigationDestination(icon: Icon(Icons.notifications_none), label: 'Alerts'), NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More')]))); } }

class DashboardScreen extends StatelessWidget { 
  const DashboardScreen({super.key, required this.state}); 
  final FarmState state; 
  
  @override 
  Widget build(BuildContext context) {
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
                child: const Row(children: [Icon(Icons.cloud_done_outlined, color: GauColors.forest, size: 18), SizedBox(width: 4), Text('Synced', style: TextStyle(color: GauColors.forest, fontWeight: FontWeight.bold))]),
              )
            ]
          ), 
          const SizedBox(height: 28), 
          Text('GOOD MORNING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GauColors.forest.withValues(alpha: 0.7))),
          Text(state.farm.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: GauColors.ink)), 
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
                        const Text('TODAY\'S MILK', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)), 
                        const SizedBox(height: 8),
                        Text('${state.totalMilk.toStringAsFixed(1)} L', style: const TextStyle(color: GauColors.white, fontSize: 46, fontWeight: FontWeight.w900)), 
                        const SizedBox(height: 8),
                        Text('6.2 L more than yesterday • ${state.cows.length} cows recorded', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 16),
                        Container(
                          height: 6, width: double.infinity,
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3)),
                          child: LayoutBuilder(
                            builder: (context, constraints) => Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: constraints.maxWidth * 0.7,
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
              const Text('Herd overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GauColors.ink)),
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
          const Text('Start a milking session', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GauColors.ink)),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scan cow tag', style: TextStyle(color: GauColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Verify cow, then connect the session', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: GauColors.white),
                ],
              ),
            ),
          ),
          
        ]
      )
    ); 
  } 
}

class CowsScreen extends StatefulWidget { const CowsScreen({super.key, required this.state}); final FarmState state; @override State<CowsScreen> createState() => _CowsScreenState(); }
class _CowsScreenState extends State<CowsScreen> { String query = ''; RiskLevel? filter; @override Widget build(BuildContext context) { final cows = widget.state.cows.where((cow) => (filter == null || cow.risk == filter) && '${cow.name} ${cow.tag}'.toLowerCase().contains(query.toLowerCase())).toList(); return SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.all(20), child: Row(children: [const Text('My cows', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const Spacer(), IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddCowScreen(state: widget.state))))])), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: TextField(decoration: const InputDecoration(hintText: 'Search name or tag', prefixIcon: Icon(Icons.search)), onChanged: (value) => setState(() => query = value))), Wrap(spacing: 5, children: [FilterChip(label: const Text('All'), selected: filter == null, onSelected: (_) => setState(() => filter = null)), ...RiskLevel.values.map((risk) => FilterChip(label: Text(risk.label), selected: filter == risk, onSelected: (_) => setState(() => filter = risk)))]), Expanded(child: ListView.builder(padding: const EdgeInsets.all(20), itemCount: cows.length, itemBuilder: (context, index) { final cow = cows[index]; return _CowCard(cow: cow, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CowProfileScreen(state: widget.state, cow: cow)))); }))])); } }

class CowProfileScreen extends StatelessWidget { const CowProfileScreen({super.key, required this.state, required this.cow}); final FarmState state; final Cow cow; @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Cow profile')), body: ListView(padding: const EdgeInsets.all(20), children: [Row(children: [CowAvatar(cow: cow, large: true), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cow.name, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)), Text(cow.tag), const SizedBox(height: 6), StatusBadge(risk: cow.risk)])]), const SizedBox(height: 18), Text('${cow.breed} • ${cow.age} • ${cow.todayMilkLitres.toStringAsFixed(1)} L today'), const SizedBox(height: 18), AppHint(icon: riskIcon(cow.risk), message: cow.risk == RiskLevel.insufficientHistory ? 'Needs more sessions before a reliable prototype risk estimate.' : 'Early-warning risk: ${cow.risk.label}. ${cow.factors.join(' • ')}', color: riskColor(cow.risk).withValues(alpha: .1)), PrimaryButton(label: 'Start milking for ${cow.name}', icon: Icons.qr_code_scanner, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScanScreen(state: state, cow: cow)))), const SizedBox(height: 18), const SectionHeader('Cow timeline'), ...cow.timeline.map((item) => ListTile(leading: const Icon(Icons.circle, size: 12, color: GauColors.forest), title: Text(item))), OutlinedButton.icon(onPressed: () { state.addHealthRecord(cow, 'Health note'); }, icon: const Icon(Icons.add_circle_outline), label: const Text('Add health record'))])); }

class MilkScreen extends StatelessWidget { const MilkScreen({super.key, required this.state}); final FarmState state; @override Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const Text('Milk', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const Text('Simple demo trends, not a laboratory report.'), const SizedBox(height: 20), ...state.cows.map((cow) => ListTile(leading: CowAvatar(cow: cow), title: Text(cow.name), subtitle: Text(cow.trend), trailing: Text('${cow.todayMilkLitres.toStringAsFixed(1)} L')))])); }
class AlertsScreen extends StatelessWidget { const AlertsScreen({super.key, required this.state}); final FarmState state; @override Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const Text('Alerts', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 16), if (state.alerts.isEmpty) const EmptyState(icon: Icons.check_circle_outline, title: 'No open alerts', message: 'You have reviewed every current alert.') else ...state.alerts.map((alert) { final cow = state.cowByTag(alert.cowTag)!; return Dismissible(key: ObjectKey(alert), direction: DismissDirection.endToStart, onDismissed: (_) => state.removeAlert(alert), background: Container(color: GauColors.forest), child: _AlertCard(cow: cow, message: alert.message)); })])); }
class MoreScreen extends StatelessWidget { const MoreScreen({super.key, required this.state}); final FarmState state; @override Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const Text('More', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 16), _Setting(title: 'Language', subtitle: state.useMarathi ? 'मराठी' : 'English', icon: Icons.language, onTap: state.toggleLanguage), _Setting(title: 'Offline and sync', subtitle: state.isOnline ? 'Demo data available locally' : 'Saved locally; API sync is Phase 2', icon: Icons.cloud_outlined, onTap: state.toggleConnection), const _Setting(title: 'Devices', subtitle: 'NODE-03 simulated for demo', icon: Icons.sensors_outlined)])); }
class GauSaathiSheet extends StatelessWidget { const GauSaathiSheet({super.key, required this.state}); final FarmState state; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('GauSaathi', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), const Text('I explain your demo herd in simple words. I am a helper, not a veterinarian.'), ...state.cows.where((cow) => cow.risk == RiskLevel.attention || cow.risk == RiskLevel.monitor).map((cow) => ListTile(leading: CowAvatar(cow: cow), title: Text('Why is ${cow.name} at risk?'), subtitle: Text(cow.factors.join(' • '))))])); }
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
