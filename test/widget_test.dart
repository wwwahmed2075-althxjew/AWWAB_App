import 'package:flutter_test/flutter_test.dart';
import 'package:malaz/main.dart';

void main() {
  testWidgets('Malaz app starts with Arabic identity and navigation', (tester) async {
    await tester.pumpWidget(const MalazApp());
    expect(find.text('ملاذ'), findsWidgets);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('القرآن'), findsOneWidget);
    expect(find.text('الأذكار'), findsOneWidget);
    expect(find.text('الصلاة'), findsOneWidget);
    expect(find.text('المزيد'), findsOneWidget);
  });
}
