import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';
import 'ratings_reviews_screen.dart';

class ProfileScreen extends StatefulWidget {
  // Switches the bottom-nav tab (0 = Dashboard) from inside the shell.
  final void Function(int tabIndex)? onSwitchTab;

  const ProfileScreen({super.key, this.onSwitchTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  Map<String, int> _stats = {'answered': 0, 'pending': 0, 'videos': 0};
  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await SupabaseService.getProfile();
      final stats = await SupabaseService.getDashboardStats();
      final reviews = await SupabaseService.getMyReviews();
      if (mounted) {
        setState(() {
          _profile = profile;
          _stats = stats;
          _reviews = reviews;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _profile?['full_name'] as String? ?? 'Expert';
    final email = _profile?['email'] as String? ?? '';
    final avatarUrl = _profile?['avatar_url'] as String?;
    final displayUrl = avatarUrl != null && avatarUrl.isNotEmpty
        ? '$avatarUrl?t=${DateTime.now().millisecondsSinceEpoch}'
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Profile',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined,
                            color: AppColors.primary),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Avatar
                CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.surface,
                    backgroundImage:
                        displayUrl != null ? NetworkImage(displayUrl) : null,
                    child: displayUrl == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold),
                          )
                        : null,
                ),
                const SizedBox(height: 12),

                // Name
                Text(name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),

                // Email in green
                Text(email,
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 13)),
                const SizedBox(height: 14),

                // Edit Profile button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 130),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfileScreen()));
                      _loadData();
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Divider
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),

                // ── Stats ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text('Stats',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => widget.onSwitchTab?.call(0),
                        child: const Text('See Dashboard',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 46,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _StatCard(text: '${_stats['answered']} Answered'),
                      const SizedBox(width: 12),
                      _StatCard(text: '${_stats['pending']} Pending'),
                      const SizedBox(width: 12),
                      _StatCard(text: '${_stats['videos']} Videos Upload'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Divider
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),

                // ── Ratings & Reviews ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text('Ratings & Reviews',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const RatingsReviewsScreen())),
                        child: const Text('See All',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

                if (_reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No reviews yet',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  )
                else
                  ...(() {
                    // Show one review per unique reviewer
                    final seen = <String>{};
                    final unique = <Map<String, dynamic>>[];
                    for (final r in _reviews) {
                      final name = r['reviewer_name'] as String? ?? '';
                      if (seen.add(name)) unique.add(r);
                      if (unique.length == 3) break;
                    }
                    return unique.indexed.map((entry) {
                    final (i, r) = entry;
                    return Column(
                      children: [
                        _ReviewTile(
                          name: r['reviewer_name'] as String? ?? '',
                          text: r['text'] as String? ?? '',
                          stars: (r['stars'] as num?)?.toInt() ?? 0,
                          time: r['created_at'] as String?,
                        ),
                        if (i < 2)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFEEEEEE)),
                          ),
                      ],
                    );
                  });
                  }()),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Simple stat card — grey fill, scrollable ──
class _StatCard extends StatelessWidget {
  final String text;

  const _StatCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}

// ── Review tile — flat, no background ──
class _ReviewTile extends StatelessWidget {
  final String name;
  final String text;
  final int stars;
  final String? time;

  static const _avatarMap = {
    'Fareeha Sadaqat': 'assets/images/img1.png',
    'Muhammad Ali Nizami': 'assets/images/img2.png',
    'Masab Mehmood': 'assets/images/Ellipse 17.png',
    'Muhammad Ali': 'assets/images/img2.png',
    'Gusti Ilham Tauhid': 'assets/images/Ellipse 17 (3).png',
    'Adhitsa Panji KW': 'assets/images/Ellipse 17 (4).png',
  };

  const _ReviewTile({
    required this.name,
    required this.text,
    required this.stars,
    this.time,
  });

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      return '${diff.inDays} days ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _timeAgo(time);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name/time + stars
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: _avatarMap.containsKey(name)
                    ? AssetImage(_avatarMap[name]!)
                    : null,
                backgroundColor: AppColors.primary.withAlpha(30),
                child: !_avatarMap.containsKey(name)
                    ? Text(name.isNotEmpty ? name[0] : '?',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    if (timeText.isNotEmpty)
                      Text(timeText,
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
              ),
              // Green outline stars — only show the number given
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(stars, (i) {
                  return const Icon(
                    Icons.star_border,
                    color: AppColors.primary,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Review text
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}
