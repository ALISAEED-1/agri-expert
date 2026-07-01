import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';

class RatingsReviewsScreen extends StatefulWidget {
  const RatingsReviewsScreen({super.key});

  @override
  State<RatingsReviewsScreen> createState() => _RatingsReviewsScreenState();
}

class _RatingsReviewsScreenState extends State<RatingsReviewsScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;

  static const _avatarMap = {
    'Fareeha Sadaqat': 'assets/images/img1.png',
    'Muhammad Ali Nizami': 'assets/images/img2.png',
    'Masab Mehmood': 'assets/images/Ellipse 17.png',
    'Muhammad Ali': 'assets/images/img2.png',
    'Gusti Ilham Tauhid': 'assets/images/Ellipse 17 (3).png',
    'Adhitsa Panji KW': 'assets/images/Ellipse 17 (4).png',
  };

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      _reviews = await SupabaseService.getMyReviews();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.primary, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  const Text('Ratings & Reviews',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
           
            // Reviews list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _reviews.isEmpty
                      ? const Center(
                          child: Text('No reviews yet',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14)),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadReviews,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _reviews.length,
                            itemBuilder: (_, i) {
                              final r = _reviews[i];
                              final name =
                                  r['reviewer_name'] as String? ?? '';
                              final text = r['text'] as String? ?? '';
                              final stars =
                                  (r['stars'] as num?)?.toInt() ?? 0;
                              final time =
                                  _timeAgo(r['created_at'] as String?);

                              return Column(
                                children: [
                                  // Divider before each review (including first)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Color(0xFFEEEEEE)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Avatar + name/time + stars
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundImage:
                                                  _avatarMap.containsKey(name)
                                                      ? AssetImage(
                                                          _avatarMap[name]!)
                                                      : null,
                                              backgroundColor:
                                                  AppColors.primary
                                                      .withAlpha(30),
                                              child: !_avatarMap
                                                      .containsKey(name)
                                                  ? Text(
                                                      name.isNotEmpty
                                                          ? name[0]
                                                          : '?',
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .primary))
                                                  : null,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(name,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600)),
                                                  if (time.isNotEmpty)
                                                    Text(time,
                                                        style: const TextStyle(
                                                            color: AppColors
                                                                .textHint,
                                                            fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                            // Green outline stars
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children:
                                                  List.generate(stars, (j) {
                                                return const Icon(
                                                  Icons.star_border,
                                                  color: AppColors.primary,
                                                  size: 18,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Review text
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 42),
                                          child: Text(text,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  height: 1.4)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
