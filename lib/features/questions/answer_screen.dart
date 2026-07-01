import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class AnswerScreen extends StatefulWidget {
  final String questionId;
  final String name;
  final String question;

  static const _avatarMap = {
    'Fareeha Sadaqat': 'assets/images/img1.png',
    'Muhammad Ali Nizami': 'assets/images/img2.png',
    'Masab Mehmood': 'assets/images/Ellipse 17.png',
    'Gusti Ilham Tauhid': 'assets/images/Ellipse 17 (3).png',
    'Adhitsa Panji KW': 'assets/images/Ellipse 17 (4).png',
  };

  const AnswerScreen({
    super.key,
    required this.questionId,
    required this.name,
    required this.question,
  });

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final _answerCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submitAnswer() async {
    final text = _answerCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your answer'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await SupabaseService.submitAnswer(
        questionId: widget.questionId,
        text: text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Answer sent!'),
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
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
          icon: const Icon(Icons.arrow_back,color: Color(0xff339D44),),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Answer',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(
                    AnswerScreen._avatarMap[widget.name] ??
                        'assets/images/Ellipse 17.png',
                  ),
                  backgroundColor: AppColors.surface,
                ),
                const SizedBox(width: 8),
                Text(widget.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            Text(widget.question, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 24),
            TextField(
              controller: _answerCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your answer',
                hintStyle: const TextStyle(color: AppColors.textHint),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const Spacer(),
            CustomButton(
              text: 'Send',
              loading: _loading,
              onPressed: _submitAnswer,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
