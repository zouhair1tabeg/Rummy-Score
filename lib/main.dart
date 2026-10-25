import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'state/game_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize French locale data for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Set system UI overlay style for dark felt aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B1712),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = await StorageService.initialize();
  final gameNotifier = GameNotifier(storageService);
  await gameNotifier.init();

  runApp(RummyScoreApp(notifier: gameNotifier));
}

class RummyScoreApp extends StatelessWidget {
  final GameNotifier notifier;

  const RummyScoreApp({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rummy Score',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(notifier: notifier),
    );
  }
}
