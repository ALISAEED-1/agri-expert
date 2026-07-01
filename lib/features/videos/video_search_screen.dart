import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/no_data_widget.dart';
import 'video_comments_screen.dart';
import 'video_player_screen.dart';

class VideoSearchScreen extends StatefulWidget {
  const VideoSearchScreen({super.key});

  @override
  State<VideoSearchScreen> createState() => _VideoSearchScreenState();
}

class _VideoSearchScreenState extends State<VideoSearchScreen> {
  final _queryCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = true;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _loadAllVideos();
  }

  /// Pre-load only the first 2 videos so the page isn't empty on open.
  Future<void> _loadAllVideos() async {
    setState(() => _loading = true);
    try {
      final all = await SupabaseService.getMyVideos();
      _results = all.take(2).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _search() async {
    final query = _queryCtrl.text.trim();
    if (query.isEmpty) {
      _loadAllVideos();
      return;
    }

    setState(() {
      _loading = true;
      _searched = true;
    });
    try {
      _results = await SupabaseService.searchVideos(query);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      return timeago.format(DateTime.parse(iso));
    } catch (_) {
      return '';
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final weekdays = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday',
        'Friday', 'Saturday', 'Sunday'
      ];
      return '${dt.day} ${months[dt.month]}, ${dt.year} ${weekdays[dt.weekday - 1]}';
    } catch (_) {
      return '';
    }
  }

  /// Recent = timeago, old = full date
  String _displayDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays < 7) return _timeAgo(iso);
      return _formatDate(iso);
    } catch (_) {
      return _timeAgo(iso);
    }
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header: "Training Videos" + green X
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Training Videos',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search field — simple rounded, no icons
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                controller: _queryCtrl,
                onSubmitted: (_) => _search(),
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(
                      color: AppColors.textHint, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
            ),

            // Results
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? _searched
                          ? const NoDataWidget(
                              title: 'No Data Found',
                              subtitle: 'No videos match your search',
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search,
                                      size: 64, color: AppColors.border),
                                  const SizedBox(height: 16),
                                  const Text('Search for videos',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  const Text(
                                      'Type a keyword and press search',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14)),
                                ],
                              ),
                            )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _results.length,
                          itemBuilder: (_, i) {
                            final v = _results[i];
                            return _SearchVideoCard(
                              index: i,
                              videoId: v['id'] as String,
                              title: v['title'] as String? ?? 'Untitled',
                              dateDisplay: _displayDate(
                                  v['created_at'] as String?),
                              thumbnailUrl:
                                  v['thumbnail_url'] as String?,
                              videoUrl: v['video_url'] as String?,
                              views: (v['views'] as num?)?.toInt() ?? 0,
                              onCommentsTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VideoCommentsScreen(
                                      videoId: v['id'] as String,
                                      videoTitle:
                                          v['title'] as String? ??
                                              'Untitled',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchVideoCard extends StatefulWidget {
  final int index;
  final String videoId;
  final String title;
  final String dateDisplay;
  final String? thumbnailUrl;
  final String? videoUrl;
  final int views;
  final VoidCallback? onCommentsTap;

  static const _defaultThumbnails = [
    'assets/images/Rectangle 2.png',
    'assets/images/Rectangle 3.png',
  ];

  const _SearchVideoCard({
    required this.index,
    required this.videoId,
    required this.title,
    required this.dateDisplay,
    this.thumbnailUrl,
    this.videoUrl,
    this.views = 0,
    this.onCommentsTap,
  });

  @override
  State<_SearchVideoCard> createState() => _SearchVideoCardState();
}

class _SearchVideoCardState extends State<_SearchVideoCard> {
  int _commentCount = 0;
  late int _views = widget.views;

  @override
  void initState() {
    super.initState();
    _loadCommentCount();
  }

  Future<void> _loadCommentCount() async {
    try {
      final count =
          await SupabaseService.getVideoCommentCount(widget.videoId);
      if (mounted) setState(() => _commentCount = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with 3-dot menu (padded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      // "Upload Date: 15 mins ago" — date part underlined
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 12),
                          children: [
                            const TextSpan(text: 'Upload Date: '),
                            TextSpan(
                              text: widget.dateDisplay,
                              style: const TextStyle(

                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.more_vert,
                      color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Thumbnail — full page width, no rounded corners, no padding
          GestureDetector(
            onTap: () async {
              final url = widget.videoUrl;
              if (url == null || url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No video available')),
                );
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(
                    videoUrl: url,
                    title: widget.title,
                    videoId: widget.videoId,
                  ),
                ),
              );
              if (mounted) setState(() => _views++);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  color: AppColors.surface,
                  child: widget.thumbnailUrl != null &&
                          widget.thumbnailUrl!.isNotEmpty
                      ? Image.network(widget.thumbnailUrl!,
                          fit: BoxFit.cover)
                      : Image.asset(
                          _SearchVideoCard._defaultThumbnails[
                              widget.index %
                                  _SearchVideoCard
                                      ._defaultThumbnails.length],
                          fit: BoxFit.cover,
                        ),
                ),
                // White circle with green play arrow
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_outlined,
                      color: AppColors.primary, size: 30),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Stats row: centered, bigger (padded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatItem(
                    icon: Icons.visibility_outlined, label: '$_views Views'),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: widget.onCommentsTap,
                  child: _StatItem(
                      icon: Icons.chat_bubble_outline,
                      label: '$_commentCount Comments'),
                ),
                const SizedBox(width: 24),
                const _StatItem(
                    icon: Icons.bookmark_border, label: '23 Saved'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
