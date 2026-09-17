import 'package:flutter_test/flutter_test.dart';

import 'package:space_weather/main.dart';

void main() {
  testWidgets('App renders dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const SpaceWeatherApp());
    await tester.pump();

    expect(find.text('空间天气'), findsWidgets);
  });
}
