import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bohurupi_cms/main.dart';
import 'package:bohurupi_cms/screens/login_screen.dart';

void main() {
  testWidgets('App should start with LoginScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isLoggedIn: false, userRole: '')); // Updated to include required parameters

    // Verify that the LoginScreen is present
    expect(find.byType(LoginScreen), findsOneWidget);

    // Verify that there's a login button
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}
