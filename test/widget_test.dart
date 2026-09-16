import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinemax_app/main.dart';


void main() {
  testWidgets('App renders CinemaxApp home widget', (
    WidgetTester tester,
  ) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException) {
        return;
      }
      originalOnError?.call(details);
    };

    await tester.pumpWidget(const CinemaxApp());
    await tester.pump();
    expect(find.byType(CinemaxApp), findsOneWidget);

    FlutterError.onError = originalOnError;
  });
}
