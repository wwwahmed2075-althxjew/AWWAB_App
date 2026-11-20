import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Mishkat app starts with Arabic identity and navigation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MishkatApp());
    await tester.pump();
    for (final label in ['الرئيسية', 'القرآن', 'الأذكار', 'الصلاة', 'المزيد']) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
