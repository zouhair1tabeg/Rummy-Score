import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/game_notifier.dart';
import 'scoreboard_screen.dart';

class NewGameScreen extends StatefulWidget {
  final GameNotifier notifier;

  const NewGameScreen({super.key, required this.notifier});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final _formKey = GlobalKey<FormState>();
  int _playerCount = 4;
  final TextEditingController _limitController = TextEditingController(
    text: '151',
  );

  final List<TextEditingController> _nameControllers = [
    TextEditingController(text: 'Joueur 1'),
    TextEditingController(text: 'Joueur 2'),
    TextEditingController(text: 'Joueur 3'),
    TextEditingController(text: 'Joueur 4'),
  ];

  String? _generalError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _limitController.dispose();
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPlayerCountChanged(int count) {
    setState(() {
      _playerCount = count;
      _generalError = null;
    });
  }

  void _onQuickLimitSelected(int limit) {
    setState(() {
      _limitController.text = limit.toString();
    });
  }

  Future<void> _startGame() async {
    setState(() {
      _generalError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final limit = int.tryParse(_limitController.text.trim());
    if (limit == null || limit <= 0) {
      setState(() {
        _generalError =
            'La limite d\'élimination doit être un nombre positif (ex: 151).';
      });
      return;
    }

    final playerNames = _nameControllers
        .take(_playerCount)
        .map((c) => c.text.trim())
        .toList();

    // Validate empty names
    for (int i = 0; i < playerNames.length; i++) {
      if (playerNames[i].isEmpty) {
        setState(() {
          _generalError = 'Veuillez saisir un nom pour le Joueur ${i + 1}.';
        });
        return;
      }
    }

    // Validate duplicates
    final lowerNames = playerNames.map((n) => n.toLowerCase()).toSet();
    if (lowerNames.length != playerNames.length) {
      setState(() {
        _generalError = 'Chaque joueur doit avoir un nom unique.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.notifier.startNewGame(
        playerNames: playerNames,
        eliminationLimit: limit,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ScoreboardScreen(notifier: widget.notifier),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _generalError = 'Erreur lors de la création de la partie: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle partie')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section: Elimination limit
                _buildSectionHeader(
                  icon: Icons.flag_rounded,
                  title: 'Limite d\'élimination',
                  subtitle:
                      'Le joueur qui atteint ou dépasse cette limite est éliminé.',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Points d\'élimination',
                    suffixText: 'points',
                    prefixIcon: Icon(
                      Icons.speed_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                  validator: (val) {
                    final n = int.tryParse(val?.trim() ?? '');
                    if (n == null || n <= 0) {
                      return 'Entrez un nombre supérieur à 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                // Helper chips
                Row(
                  children: [
                    const Text(
                      'Raccourcis : ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildLimitChip(101),
                    const SizedBox(width: 8),
                    _buildLimitChip(151),
                    const SizedBox(width: 8),
                    _buildLimitChip(201),
                  ],
                ),
                const SizedBox(height: 24),

                // Section: Player Count
                _buildSectionHeader(
                  icon: Icons.group_rounded,
                  title: 'Nombre de joueurs',
                  subtitle: 'Choisissez entre 2 et 4 joueurs.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [2, 3, 4].map((count) {
                    final isSelected = _playerCount == count;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected
                                ? AppColors.primaryLight
                                : AppColors.surface,
                            foregroundColor: isSelected
                                ? AppColors.goldLight
                                : AppColors.textSecondary,
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.border,
                              width: isSelected ? 1.6 : 1.0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _onPlayerCountChanged(count),
                          child: Text(
                            '$count joueurs',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Section: Player names
                _buildSectionHeader(
                  icon: Icons.badge_rounded,
                  title: 'Noms des joueurs',
                  subtitle: 'Personnalisez les noms avant de démarrer.',
                ),
                const SizedBox(height: 12),
                ...List.generate(_playerCount, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _nameControllers[index],
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Joueur ${index + 1}',
                        prefixIcon: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldLight,
                            ),
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Le nom ne peut pas être vide';
                        }
                        return null;
                      },
                    ),
                  );
                }),

                if (_generalError != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.danger),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.danger,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _generalError!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Start button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: _isSubmitting ? null : _startGame,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_filled_rounded, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Commencer la partie',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildLimitChip(int limit) {
    final isSelected = _limitController.text.trim() == limit.toString();
    return ActionChip(
      label: Text('$limit pts'),
      backgroundColor: isSelected ? AppColors.gold : AppColors.surfaceElevated,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isSelected ? AppColors.background : AppColors.textSecondary,
      ),
      side: BorderSide(color: isSelected ? AppColors.gold : AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      onPressed: () => _onQuickLimitSelected(limit),
    );
  }
}
