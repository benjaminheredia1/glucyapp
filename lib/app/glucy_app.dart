import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/glucy_router.dart';
import 'theme/glucy_palette.dart';

class GlucyApp extends ConsumerWidget {
  const GlucyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Glucy AI',
      theme: GlucyPalette.tema,
      routerConfig: ref.watch(glucyRouterProvider),
    );
  }
}
