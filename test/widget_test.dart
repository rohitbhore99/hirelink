import 'package:flutter_test/flutter_test.dart';

import 'package:hirelink1/core/theme/app_radius.dart';
import 'package:hirelink1/core/theme/app_spacing.dart';

void main() {
  testWidgets('Design tokens are accessible', (WidgetTester tester) async {
    expect(AppSpacing.md, 16);
    expect(AppSpacing.lg, 24);
    expect(AppRadius.lg, 16);
    expect(AppRadius.full, 999);
  });
}
