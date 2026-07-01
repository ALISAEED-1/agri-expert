import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/filter_tabs.dart';

class VideoCommentsScreen extends StatefulWidget {
  final String videoId;
  final String videoTitle;

  const VideoCommentsScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
  });

  @override
  State<VideoCommentsScreen> createState() => _VideoCommentsScreenState();
}

class _VideoCommentsScreenState extends State<VideoCommentsScreen> {
  int _selectedTab = 0;
  final _tabs = ['All', 'Most Recent', 'Relevant'];
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;

  // Avatar images mapped by commenter name (Ellipse 17 series)
  static const _avatarMap = {
    'Masab Mehmood': 'assets/images/Ellipse 17.png',
    'Gusti Ilham Tauhid': 'assets/images/Ellipse 17 (1).png',
    'Adhitsa Panji KW': 'assets/images/Ellipse 17 (2).png',
    'Dazzy': 'assets/images/Ellipse 17 (3).png',
    'Althaf Ukail': 'assets/images/Ellipse 17 (4).png',
  };

  // Fallback: assign by index
  static const _avatarList = [
    'assets/images/Ellipse 17.png',
    'assets/images/Ellipse 17 (1).png',
    'assets/images/Ellipse 17 (2).png',
    'assets/images/Ellipse 17 (3).png',
    'assets/images/Ellipse 17 (4).png',
  ];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      _comments = await SupabaseService.getVideoComments(widget.videoId);
    } catch (e) {
      debugPrint('Comments load error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _avatarForName(String name, int index) {
    return _avatarMap[name] ??
        _avatarList[index % _avatarList.length];
  }

  List<Map<String, dynamic>> get _filteredComments {
    // All tabs return same data (Most Recent is already sorted desc)
    return _comments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Header: back arrow + "Comments (N)"
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Comments ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: '(${_comments.length})',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter tabs with shadow on selected
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
            const SizedBox(height: 20),

            // "Video : How to Start A Tractor" — Video in green bold
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Video',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const TextSpan(
                      text: ' : ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: widget.videoTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Comments list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredComments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  size: 56, color: AppColors.border),
                              const SizedBox(height: 12),
                              const Text('No comments yet',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredComments.length,
                          itemBuilder: (_, i) {
                            final c = _filteredComments[i];
                            final name =
                                c['commenter_name'] as String? ?? '';
                            return _CommentTile(
                              avatarAsset: _avatarForName(name, i),
                              name: name,
                              date: _formatDate(
                                  c['created_at'] as String?),
                              text: c['text'] as String? ?? '',
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

class _CommentTile extends StatelessWidget {
  final String avatarAsset;
  final String name;
  final String date;
  final String text;

  const _CommentTile({
    required this.avatarAsset,
    required this.name,
    required this.date,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar image
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(avatarAsset),
            backgroundColor: AppColors.surface,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                // Date
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(date,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12)),
                ],
                const SizedBox(height: 8),
                // Comment text
                Text(text,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
