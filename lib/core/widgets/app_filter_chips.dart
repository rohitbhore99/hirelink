import "package:flutter/material.dart";
import "package:hirelink1/theme/app_theme.dart";

class AppFilterChips extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const AppFilterChips({
    super.key,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: options.map((option) {
          final isSelected = selected == option;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Material(
              color: isSelected ? HirelinkColors.primaryContainerLight : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: () => onSelected(option),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? HirelinkColors.primary : HirelinkColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? HirelinkColors.primaryDark : HirelinkColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
