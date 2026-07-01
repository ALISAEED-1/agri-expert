import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/filter_tabs.dart';
import '../../core/widgets/no_data_widget.dart';
import 'add_video_screen.dart';
import 'video_comments_screen.dart';
import 'video_player_screen.dart';
import 'video_search_screen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List<Map<String, dynamic>> _videos = [];
  bool _loading = true;
  int _selectedTab = 0;
  final _tabs = ['All', 'Recently Uploaded'];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => _loading = true);
    try {
      _videos = await SupabaseService.getMyVideos();
    } catch (e) {
      debugPrint('Videos load error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
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

  List<Map<String, dynamic>> get _filteredVideos {
    if (_selectedTab == 1) {
      // Recently uploaded – last 7 days
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      return _videos.where((v) {
        final created = v['created_at'] as String?;
        if (created == null) return false;
        try {
          return DateTime.parse(created).isAfter(cutoff);
        } catch (_) {
          return false;
        }
      }).toList();
    }
    return _videos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Training Videos + search + add
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
                    icon: const Icon(Icons.search, color: AppColors.textPrimary),
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VideoSearchScreen()));
                      _loadVideos();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.textPrimary),
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddVideoScreen()));
                      _loadVideos();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Filter tabs — wide rounded rectangles matching mockup
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FilterTabs(
                tabs: _tabs,
                selectedIndex: _selectedTab,
                onTap: (i) {
                  setState(() => _selectedTab = i);
                },
              ),
            ),
            const SizedBox(height: 12),

            // Video list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredVideos.isEmpty
                      ? const NoDataWidget(
                          title: 'No Data Found',
                          subtitle: 'You have not uploaded any videos yet',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadVideos,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _filteredVideos.length,
                            itemBuilder: (_, i) {
                              final v = _filteredVideos[i];
                              return _VideoCard(
                                index: i,
                                videoId: v['id'] as String,
                                title: v['title'] as String? ?? 'Untitled',
                                description:
                                    v['description'] as String? ?? '',
                                timeAgo:
                                    _formatDate(v['created_at'] as String?),
                                dateFormatted:
                                    _formatDate(v['created_at'] as String?),
                                thumbnailUrl:
                                    v['thumbnail_url'] as String?,
                                videoUrl: v['video_url'] as String?,
                                views: (v['views'] as num?)?.toInt() ?? 0,
                                onChanged: _loadVideos,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final int index;
  final String videoId;
  final String title;
  final String description;
  final String timeAgo;
  final String dateFormatted;
  final String? thumbnailUrl;
  final String? videoUrl;
  final int views;
  final VoidCallback? onCommentsTap;
  final VoidCallback? onChanged;

  static const _defaultThumbnails = [
    'assets/images/Rectangle 2.png',
    'assets/images/Rectangle 2 (1).png',
    'assets/images/Rectangle 3.png',
  ];

  const _VideoCard({
    required this.index,
    required this.videoId,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.dateFormatted,
    this.thumbnailUrl,
    this.videoUrl,
    this.views = 0,
    this.onCommentsTap,
    this.onChanged,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
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

  Future<void> _onEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVideoScreen(
          videoId: widget.videoId,
          initialTitle: widget.title,
          initialDescription: widget.description,
          initialThumbnailUrl: widget.thumbnailUrl,
        ),
      ),
    );
    widget.onChanged?.call();
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Delete "${widget.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await SupabaseService.deleteVideo(widget.videoId);
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 12),
                          children: [
                            const TextSpan(text: 'Upload Date: '),
                            TextSpan(
                              text: widget.timeAgo,
                              style: const TextStyle(

                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textSecondary, size: 20),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _onEdit();
                    } else if (val == 'delete') {
                      _onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
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
              // A view was counted server-side; reflect it immediately.
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
                          _VideoCard._defaultThumbnails[
                              widget.index %
                                  _VideoCard._defaultThumbnails.length],
                          fit: BoxFit.cover,
                        ),
                ),
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
          const SizedBox(height: 10),

          // Stats row: left-aligned (padded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatItem(
                    icon: Icons.visibility_outlined, label: '$_views Views'),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: widget.onCommentsTap,
                  child: _StatItem(
                      icon: Icons.chat_bubble_outline,
                      label: '$_commentCount Comments'),
                ),

              ],
            ),
          ),
          const SizedBox(height: 16),

          // Divider
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
