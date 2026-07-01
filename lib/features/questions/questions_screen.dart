import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/filter_tabs.dart';
import '../../core/widgets/no_data_widget.dart';
import 'answer_screen.dart';
import 'search_questions_screen.dart';
import 'view_answer_screen.dart';

class QuestionsScreen extends StatefulWidget {
  /// Lets another screen (e.g. the dashboard) request a filter tab:
  /// 0 = All, 1 = Pending, 2 = Answered.
  final ValueNotifier<int>? filterRequest;

  const QuestionsScreen({super.key, this.filterRequest});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  int _selectedTab = 0;
  final _tabs = ['All', 'Pending', 'Answered'];

  List<Map<String, dynamic>> _questions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.filterRequest?.value ?? 0;
    widget.filterRequest?.addListener(_onFilterRequest);
    _loadQuestions();
  }

  void _onFilterRequest() {
    final requested = widget.filterRequest!.value;
    setState(() => _selectedTab = requested);
    _loadQuestions();
  }

  @override
  void dispose() {
    widget.filterRequest?.removeListener(_onFilterRequest);
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _loading = true);
    try {
      String? status;
      if (_selectedTab == 1) status = 'pending';
      if (_selectedTab == 2) status = 'answered';
      _questions = await SupabaseService.getQuestions(status: status);
    } catch (e) {
      debugPrint('Questions load error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return timeago.format(dt);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Questions',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.primary, size: 28),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SearchQuestionsScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Filter tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FilterTabs(
                tabs: _tabs,
                selectedIndex: _selectedTab,
                onTap: (i) {
                  setState(() => _selectedTab = i);
                  _loadQuestions();
                },
              ),
            ),
            const SizedBox(height: 12),

            // Question list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _questions.isEmpty
                      ? NoDataWidget(
                          title: 'No Data Found',
                          subtitle: _selectedTab == 1
                              ? 'You have no pending questions yet'
                              : _selectedTab == 2
                                  ? 'You have not answered any\nquestions yet'
                                  : 'No questions available yet',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadQuestions,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _questions.length,
                            itemBuilder: (_, i) {
                              final q = _questions[i];
                              return _QuestionTile(
                                index: i,
                                name: q['farmer_name'] as String? ?? '',
                                time: _timeAgo(q['created_at'] as String?),
                                text: q['text'] as String? ?? '',
                                hasImage: q['image_url'] != null,
                                status: q['status'] as String? ?? 'pending',
                                onAnswer: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AnswerScreen(
                                        questionId: q['id'] as String,
                                        name:
                                            q['farmer_name'] as String? ?? '',
                                        question:
                                            q['text'] as String? ?? '',
                                      ),
                                    ),
                                  );
                                  _loadQuestions();
                                },
                                onViewAnswer: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewAnswerScreen(
                                        questionId: q['id'] as String,
                                        farmerName:
                                            q['farmer_name'] as String? ?? '',
                                        questionText:
                                            q['text'] as String? ?? '',
                                      ),
                                    ),
                                  );
                                  _loadQuestions();
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

class _QuestionTile extends StatelessWidget {
  final int index;
  final String name;
  final String time;
  final String text;
  final bool hasImage;
  final String status;
  final VoidCallback onAnswer;
  final VoidCallback onViewAnswer;

  static const _defaultImages = [
    'assets/images/Rectangle 3.png',
    'assets/images/Rectangle 2.png',
    'assets/images/Rectangle 2 (1).png',
  ];

  static const _avatarList = [
    'assets/images/img1.png',
    'assets/images/img2.png',
    'assets/images/Ellipse 17.png',
    'assets/images/img2.png',
    'assets/images/Ellipse 17 (1).png',
  ];

  static const _avatarMap = {
    'Fareeha Sadaqat': 'assets/images/img1.png',
    'Muhammad Ali Nizami': 'assets/images/img2.png',
    'Masab Mehmood': 'assets/images/Ellipse 17.png',
    'Gusti Ilham Tauhid': 'assets/images/Ellipse 17 (3).png',
    'Adhitsa Panji KW': 'assets/images/Ellipse 17 (4).png',
  };

  const _QuestionTile({
    required this.index,
    required this.name,
    required this.time,
    required this.text,
    required this.hasImage,
    required this.status,
    required this.onAnswer,
    required this.onViewAnswer,
  });

  String get _avatarAsset =>
      _avatarMap[name] ?? _avatarList[index % _avatarList.length];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),

        // Name row: avatar + name/time + Answer button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Profile avatar image
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(_avatarAsset),
                backgroundColor: AppColors.surface,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    if (time.isNotEmpty)
                      Text(time,
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
              ),
              if (status == 'pending')
                TextButton(
                  onPressed: onAnswer,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Answer',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                )
              else
                GestureDetector(
                  onTap: onViewAnswer,
                  child: const Text('Answer',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Question text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(text,
              style: const TextStyle(fontSize: 14, height: 1.4)),
        ),

        // Image — full width, no padding, with Frame 14 dots at bottom
        if (hasImage) ...[
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.asset(
                  _defaultImages[index % _defaultImages.length],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 10,
                child: Image.asset(
                  'assets/images/Frame 14.png',
                  height: 10,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 14),

        // Divider
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        ),
      ],
    );
  }
}
