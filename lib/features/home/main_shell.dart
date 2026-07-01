import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/exit_app_dialog.dart';
import 'dashboard_screen.dart';
import '../questions/questions_screen.dart';
import '../videos/videos_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Lets the dashboard request a specific Questions filter tab
  // (0 = All, 1 = Pending, 2 = Answered) when switching to that tab.
  final ValueNotifier<int> _questionsFilter = ValueNotifier(0);

  // Bumped whenever the dashboard tab is shown so its stats reload.
  final ValueNotifier<int> _dashboardRefresh = ValueNotifier(0);

  void _switchTab(int index) {
    if (index == 0) _dashboardRefresh.value++;
    setState(() => _index = index);
  }

  void _openQuestions(int filter) {
    _questionsFilter.value = filter;
    setState(() => _index = 1);
  }

  late final List<Widget> _screens = [
    DashboardScreen(
        onSwitchTab: _switchTab,
        onOpenQuestions: _openQuestions,
        refreshSignal: _dashboardRefresh),
    QuestionsScreen(filterRequest: _questionsFilter),
    const VideosScreen(),
    const ChatScreen(),
    ProfileScreen(onSwitchTab: _switchTab),
  ];

  @override
  void dispose() {
    _questionsFilter.dispose();
    _dashboardRefresh.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_index != 0) {
      setState(() => _index = 0);
      return false;
    }
    return await ExitAppDialog.show(context);
  }

  static const _iconPaths = [
    'assets/images/bar1.png',
    'assets/images/bar2.png',
    'assets/images/bar3.png',
    'assets/images/bar4.png',
    'assets/images/bar5.png',
  ];

  // Background per tab so the nav bar's rounded corners blend with each page.
  // dashboard(grey), questions(white), videos(white),
  // chat(grey NoData), profile(white)
  static const _navBgColors = [
    Color(0xFFF5F5F7),
    Colors.white,
    Colors.white,
    Color(0xFFF5F5F7),
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _onWillPop();
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        // Match the active tab's background so the nav bar's rounded
        // corners blend instead of showing a mismatched notch.
        // Tabs that show grey content (dashboard, videos, chat) → grey.
        backgroundColor: _navBgColors[_index],
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: List.generate(5, (i) {
                  final selected = _index == i;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _switchTab(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Green bar indicator on top
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 6,
                            width: selected ? 44 : 0,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              _iconPaths[i],
                              fit: BoxFit.contain,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
