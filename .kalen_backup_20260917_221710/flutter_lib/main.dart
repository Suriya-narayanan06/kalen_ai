import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'navigation/dynamic_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const KalenVetApp());
}

class KalenVetApp extends StatelessWidget {
  const KalenVetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KALEN VET',
      theme: KalenVetTheme.darkTheme,
      home: const DynamicNavigation(),
    );
  }
}