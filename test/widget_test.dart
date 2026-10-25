import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rummy_score/constants/app_theme.dart';
import 'package:rummy_score/screens/home_screen.dart';
import 'package:rummy_score/screens/new_game_screen.dart';
import 'package:rummy_score/screens/rules_screen.dart';
import 'package:rummy_score/screens/scoreboard_screen.dart';
import 'package:rummy_score/services/storage_service.dart';
import 'package:rummy_score/state/game_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeScreen displays app name and Nouvelle partie button', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    final notifier = GameNotifier(storage);
    await notifier.init();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HomeScreen(notifier: notifier),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Rummy Score'), findsOneWidget);
    expect(find.text('Nouvelle partie'), findsOneWidget);
    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('Règles du jeu'), findsOneWidget);
  });

  testWidgets('NewGameScreen validates players and starts game', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    final notifier = GameNotifier(storage);
    await notifier.init();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: NewGameScreen(notifier: notifier),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nouvelle partie'), findsOneWidget);
    expect(find.text('Limite d\'élimination'), findsOneWidget);
    expect(find.text('Commencer la partie'), findsOneWidget);

    // 1 limit field + 4 player name fields = 5 TextFormFields
    expect(find.byType(TextFormField), findsNWidgets(5));

    // Switch to 2 players
    await tester.tap(find.text('2 joueurs'));
    await tester.pumpAndSettle();

    // 1 limit field + 2 player name fields = 3 TextFormFields
    expect(find.byType(TextFormField), findsNWidgets(3));

    // Scroll and tap Commencer la partie
    final startButton = find.text('Commencer la partie');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    expect(notifier.activeGame, isNotNull);
    expect(notifier.activeGame!.players.length, 2);
  });

  testWidgets(
    'ScoreboardScreen displays players and responds to round actions',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final notifier = GameNotifier(storage);
      await notifier.init();

      await notifier.startNewGame(
        playerNames: ['Alice', 'Bob'],
        eliminationLimit: 151,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ScoreboardScreen(notifier: notifier),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tableau des scores'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Limite: 151 pts'), findsOneWidget);
      expect(find.text('Ajouter une manche'), findsOneWidget);
    },
  );

  testWidgets('RulesScreen renders all game rules', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const RulesScreen()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Règles du jeu de Rami'), findsOneWidget);
    expect(find.text('Limite d\'élimination'), findsOneWidget);
    expect(find.text('La Revanche (Règle clé)'), findsOneWidget);
    expect(find.text('Fin de la partie'), findsOneWidget);
  });
}
