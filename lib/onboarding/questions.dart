import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/splash_screen.dart';

class Question extends StatelessWidget {
    const Question({super.key});
    @override
    Widget build(BuildContext context) {
        return const MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Question',
            home: SplashScreen(),
        );
    }
}
