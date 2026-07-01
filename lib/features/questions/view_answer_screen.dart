import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class ViewAnswerScreen extends StatefulWidget {
  final String questionId;
  final String farmerName;
  final String questionText;

  const ViewAnswerScreen({
    super.key,
    required this.questionId,
    required this.farmerName,
    required this.questionText,
  });

  @override
  State<ViewAnswerScreen> createState() => _ViewAnswerScreenState();
}

class _ViewAnswerScreenState extends State<ViewAnswerScreen> {
  final _answerCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _editing = false;
  Map<String, dynamic>? _answer;

  @override
  void initState() {
    super.initState();
    _loadAnswer();
  }

  Future<void> _loadAnswer() async {
    try {
      final answers = await SupabaseService.getAnswers(widget.questionId);
      if (answers.isNotEmpty && mounted) {
        setState(() {
          _answer = answers.first;
          _answerCtrl.text = _answer!['text'] as String? ?? '';
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Load answer error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveEdit() async {
    final text = _answerCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _saving = true);
    try {
      await SupabaseService.updateAnswer(
        answerId: _answer!['id'] as String,
        text: text,
      );
      if (mounted) {
        setState(() {
          _answer!['text'] = text;
          _editing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Answer updated!'),
              backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteAnswer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Answer?'),
        content: const Text(
            'This removes your answer and moves the question back to Pending.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _saving = true);
    try {
      await SupabaseService.deleteAnswer(
        answerId: _answer!['id'] as String,
        questionId: widget.questionId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Answer deleted. Question moved to Pending.'),
              backgroundColor: AppColors.primary),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('View Answer',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          if (_answer != null && !_editing) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => setState(() => _editing = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _saving ? null : _deleteAnswer,
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Farmer info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surface,
                        child: Text(
                          widget.farmerName.isNotEmpty
                              ? widget.farmerName[0]
                              : '?',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(widget.farmerName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Question text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(widget.questionText,
                        style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 20),

                  // "Your Answer" label
                  Row(
                    children: [
                      const Text('Your Answer',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (!_editing && _answer != null)
                        GestureDetector(
                          onTap: () => setState(() => _editing = true),
                          child: const Text('Edit',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_answer == null)
                    const Text('No answer found.',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14))
                  else if (_editing) ...[
                    // Editable text field
                    TextField(
                      controller: _answerCtrl,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Edit your answer...',
                        hintStyle:
                            const TextStyle(color: AppColors.textHint),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            outlined: true,
                            onPressed: () {
                              _answerCtrl.text =
                                  _answer!['text'] as String? ?? '';
                              setState(() => _editing = false);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Save',
                            loading: _saving,
                            onPressed: _saveEdit,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // Read-only answer display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary.withAlpha(50)),
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primary.withAlpha(10),
                      ),
                      child: Text(
                        _answer!['text'] as String? ?? '',
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
