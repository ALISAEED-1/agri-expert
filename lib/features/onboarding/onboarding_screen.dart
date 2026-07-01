import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

  final _pages = const [
    _OnboardingData(
      image: 'assets/images/Frame 134.png',
      title: 'Get Rid of Third\nPerson',
      description:
          'Using this application you can get\nrid of paying commission fee to\nthird person. Now you can directly\nchat with sellers and deal with\nthem.',
    ),
    _OnboardingData(
      image: 'assets/images/Frame 134 (1).png',
      title: 'Help in Market\nAnalysis',
      description:
          'You\'ll have all the market\nanalytics at your pocket. You\'ll get\nto know the Latest and Updated\nMarket Rates of Pakistan.',
    ),
    _OnboardingData(
      image: 'assets/images/Frame 134 (2).png',
      title: 'Multilingual',
      description:
          'Use the platform and start adding your\nitems. It is also available in Urdu\nfor your desired items and\nprices.',
    ),
  ];

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (_) => setState(() {}),
                itemBuilder: (_, i) {
                  final page = _pages[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // Image with bg.png behind it — no right padding
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: SizedBox(
                          height: 280,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // bg.png behind, tilted slightly to bottom-right
                              Positioned(
                                top: 12,
                                left: 8,
                                right: -8,
                                bottom: -12,
                                child: Transform.rotate(
                                  angle: 0.03,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      'assets/images/bg.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              // Actual image on top, full size
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    page.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      const SizedBox(height: 32),
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          page.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Bottom: dots center + skip right
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: Color(0xFFBDBDBD),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 2.5,
                      spacing: 5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _goToLogin,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xff339D44),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String description;

  const _OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
