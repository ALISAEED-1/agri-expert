import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/no_data_widget.dart';
import 'answer_screen.dart';
import 'view_answer_screen.dart';

class SearchQuestionsScreen extends StatefulWidget {
  const SearchQuestionsScreen({super.key});

  @override
  State<SearchQuestionsScreen> createState() => _SearchQuestionsScreenState();
}

class _SearchQuestionsScreenState extends State<SearchQuestionsScreen> {
  final _queryCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _searched = false;

  static const _avatarMap = {
    'Fareeha Sadaqat': 'assets/images/img1.png',
    'Muhammad Ali Nizami': 'assets/images/img2.png',
    'Masab Mehmood': 'assets/images/Ellipse 17.png',
    'Gusti Ilham Tauhid': 'assets/images/Ellipse 17 (3).png',
    'Adhitsa Panji KW': 'assets/images/Ellipse 17 (4).png',
  };

  static const _avatarList = [
    'assets/images/img1.png',
    'assets/images/img2.png',
    'assets/images/Ellipse 17.png',
    'assets/images/img2.png',
    'assets/images/Ellipse 17 (1).png',
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final all = await SupabaseService.getQuestions();
      _results = all.take(2).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _search() async {
    final query = _queryCtrl.text.trim();
    if (query.isEmpty) {
      _loadAll();
      return;
    }

    setState(() {
      _loading = true;
      _searched = true;
    });
    try {
      _results = await SupabaseService.searchQuestions(query);
    } catch (_) {}
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

  String _avatarAsset(String name, int index) =>
      _avatarMap[name] ?? _avatarList[index % _avatarList.length];

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
                    icon: const Icon(Icons.close,
                        size: 22, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Search field — plain, no icons
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                controller: _queryCtrl,
                onSubmitted: (_) => _search(),
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  hintStyle:
                      const TextStyle(color: AppColors.textHint, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            // Results
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty && _searched
                      ? _buildNoResults()
                      : _results.isEmpty
                          ? const SizedBox()
                          : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _results.length,
                          itemBuilder: (_, i) {
                            final q = _results[i];
                            final name =
                                q['farmer_name'] as String? ?? '';
                            final time =
                                _timeAgo(q['created_at'] as String?);
                            final status =
                                q['status'] as String? ?? 'pending';
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 14),
                                // Avatar + name + time + Answer
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: AssetImage(
                                            _avatarAsset(name, i)),
                                        backgroundColor:
                                            AppColors.surface,
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
                                                        FontWeight.w600)),
                                            if (time.isNotEmpty)
                                              Text(time,
                                                  style: const TextStyle(
                                                      color: AppColors
                                                          .textHint,
                                                      fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if (status == 'pending') {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AnswerScreen(
                                                  questionId:
                                                      q['id'] as String,
                                                  name: name,
                                                  question: q['text']
                                                          as String? ??
                                                      '',
                                                ),
                                              ),
                                            );
                                          } else {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ViewAnswerScreen(
                                                  questionId:
                                                      q['id'] as String,
                                                  farmerName: name,
                                                  questionText: q['text']
                                                          as String? ??
                                                      '',
                                                ),
                                              ),
                                            );
                                          }
                                          _search();
                                        },
                                        child: const Text('Answer',
                                            style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Question text
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                      q['text'] as String? ?? '',
                                      style: const TextStyle(
                                          fontSize: 14, height: 1.4)),
                                ),
                                const SizedBox(height: 14),
                                // Divider
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Color(0xFFEEEEEE)),
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    if (!_searched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            const Text('Search for questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Type a keyword and press search',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }
    return NoDataWidget(
      title: 'No Data Found',
      subtitle: 'You have not answered any\nquestions yet',
    );
  }
}
