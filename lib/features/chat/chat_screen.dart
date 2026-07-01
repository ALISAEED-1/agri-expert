import 'package:flutter/material.dart';
import '../../core/widgets/no_data_widget.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NoDataWidget(
          title: 'No Data Found',
          subtitle: 'You have not answered any\nquestions yet',
        ),
      ),
    );
  }
}
