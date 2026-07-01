import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int tabIndex)? onSwitchTab;
  // Opens the Questions tab on a specific filter (0=All, 1=Pending, 2=Answered)
  final void Function(int filter)? onOpenQuestions;
  // Bumped by the shell when this tab is shown, so stats reload.
  final ValueNotifier<int>? refreshSignal;

  const DashboardScreen({
    super.key,
    this.onSwitchTab,
    this.onOpenQuestions,
    this.refreshSignal,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> _stats = {
    'total': 0,
    'answered': 0,
    'views': 0,
    'videos': 0
  };
  String _userName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.refreshSignal?.addListener(_loadData);
  }

  @override
  void dispose() {
    widget.refreshSignal?.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final stats = await SupabaseService.getDashboardStats();
      final profile = await SupabaseService.getProfile();
      if (mounted) {
        setState(() {
          _stats = stats;
          _userName = profile?['full_name'] as String? ?? 'Expert';
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Dashboard load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dashboard!',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Welcome to Dashboard $_userName',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 28),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.5,
                        children: [
                          _StatCard(
                              iconPath: 'assets/images/Group (4).png',
                              value: '${_stats['total']}',
                              label: 'Total\nQuestions',
                              onTap: () => widget.onOpenQuestions?.call(0)),
                          _StatCard(
                              iconPath: 'assets/images/d_tick.png',
                              value: '${_stats['answered']}',
                              label: 'Answered\nQuestions',
                              onTap: () => widget.onOpenQuestions?.call(2)),
                          _StatCard(
                              iconPath: 'assets/images/eye.png',
                              value: '${_stats['views']}',
                              label: 'Total Views',
                              iconWidth: 52,
                              iconHeight: 52,
                              onTap: () {}),
                          _StatCard(
                              iconPath: 'assets/images/bar3.png',
                              value: '${_stats['videos']}',
                              label: 'Total Videos',
                              onTap: () => widget.onSwitchTab?.call(2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String iconPath;
  final String value;
  final String label;
  final VoidCallback? onTap;
  final double iconWidth;
  final double iconHeight;

  const _StatCard({
    required this.iconPath,
    required this.value,
    required this.label,
    this.onTap,
    this.iconWidth = 50,
    this.iconHeight = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: iconWidth,
              height: iconHeight,
              child: Image.asset(iconPath,
                  fit: BoxFit.contain,
                  color: const Color(0xFFAEAEAE)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: GoogleFonts.raleway(
                          fontSize: 23.04,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          letterSpacing: 0)),
                  const SizedBox(height: 2),
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
