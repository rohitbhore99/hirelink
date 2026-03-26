import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/core/theme/theme_controller.dart';

final appThemeControllerProvider = ChangeNotifierProvider<ThemeController>((
  ref,
) {
  final controller = ThemeController();
  controller.loadTheme(); // Load theme on initialization
  return controller;
});
