import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Wide rounded-rectangle filter tabs matching the mockup style.
/// Selected tab: green fill + shadow. Unselected: white with gray border + gray text.
class FilterTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const FilterTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (i) {
        final selected = selectedIndex == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 6,
              right: i == tabs.length - 1 ? 0 : 6,
            ),
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xFFB0B0B0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
