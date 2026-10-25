import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../widgets/glass_background.dart';

class AddRoundScreen extends StatefulWidget {
  final Game game;
  final Future<void> Function({
    required String winnerId,
    required Map<String, int> scoresToAdd,
  })
  onCommitRound;

  const AddRoundScreen({
    super.key,
    required this.game,
    required this.onCommitRound,
  });

  @override
  State<AddRoundScreen> createState() => _AddRoundScreenState();
}

class _AddRoundScreenState extends State<AddRoundScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedWinnerId;
  final Map<String, TextEditingController> _scoreControllers = {};
  String? _validationError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (final player in widget.game.activePlayers) {
      _scoreControllers[player.id] = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    for (final c in _scoreControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSelectWinner(String playerId) {
    setState(() {
      _selectedWinnerId = playerId;
      _scoreControllers[playerId]?.text = '0';
      _validationError = null;
    });
  }

  Map<String, int> _gatherScores() {
    final scores = <String, int>{};
    for (final player in widget.game.activePlayers) {
      if (player.id == _selectedWinnerId) {
        scores[player.id] = 0;
      } else {
        final text = _scoreControllers[player.id]?.text.trim() ?? '';
        final val = int.tryParse(text);
        if (val != null) {
          scores[player.id] = val;
        }
      }
    }
    return scores;
  }

  Future<void> _submitRound() async {
    setState(() {
      _validationError = null;
    });

    if (_selectedWinnerId == null) {
      setState(() {
        _validationError =
            'Veuillez sélectionner le vainqueur de cette manche.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final scores = _gatherScores();
    for (final player in widget.game.activePlayers) {
      if (player.id != _selectedWinnerId && !scores.containsKey(player.id)) {
        setState(() {
          _validationError = 'Veuillez renseigner le score de ${player.name}.';
        });
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onCommitRound(
        winnerId: _selectedWinnerId!,
        scoresToAdd: scores,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _validationError = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundNumber = widget.game.rounds.length + 1;
    final activePlayers = widget.game.activePlayers;

    return Scaffold(
      appBar: AppBar(title: Text('Ajouter la manche $roundNumber')),
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instruction banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sélectionnez le vainqueur (0 pt). Entrez ensuite les points restants des autres joueurs.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Joueurs actifs (${activePlayers.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...activePlayers.map((player) {
                    return _buildPlayerInputCard(player);
                  }),

                  const SizedBox(height: 16),

                  // Live Preview Card
                  _buildLivePreview(activePlayers),

                  if (_validationError != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.danger,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _validationError!,
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

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isSubmitting ? null : _submitRound,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Valider la manche',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInputCard(Player player) {
    final isWinner = _selectedWinnerId == player.id;
    final controller = _scoreControllers[player.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isWinner
            ? const Color(0xFFF0F4FD)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWinner
              ? AppColors.primary.withValues(alpha: 0.45)
              : Colors.white,
          width: isWinner ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25283B).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isWinner
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Score actuel : ${player.cumulativeScore} pts',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Winner toggle pill
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _onSelectWinner(player.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isWinner
                        ? AppColors.primary
                        : const Color(0xFFF1F3F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 15,
                        color: isWinner ? Colors.white : AppColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isWinner ? 'Vainqueur (0 pt)' : 'Désigner vainqueur',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isWinner
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!isWinner) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                labelText: 'Points marqués cette manche',
                hintText: 'Ex: 25',
                prefixIcon: Icon(Icons.add, color: AppColors.primary),
                suffixText: 'pts',
              ),
              onChanged: (_) => setState(() {}),
              validator: (val) {
                if (isWinner) return null;
                final text = val?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Requis pour les autres joueurs';
                }
                final n = int.tryParse(text);
                if (n == null || n < 0) {
                  return 'Doit être un entier positif (≥ 0)';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLivePreview(List<Player> activePlayers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.preview_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Aperçu des nouveaux scores cumulés',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activePlayers.map((player) {
            final isWinner = _selectedWinnerId == player.id;
            final inputStr = _scoreControllers[player.id]?.text.trim() ?? '';
            final added = isWinner ? 0 : (int.tryParse(inputStr) ?? 0);
            final newTotal = player.cumulativeScore + added;
            final isAtOrOverLimit = newTotal >= widget.game.eliminationLimit;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isWinner
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${player.cumulativeScore} + $added = ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$newTotal pts',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isAtOrOverLimit
                          ? AppColors.danger
                          : (isWinner
                                ? AppColors.success
                                : AppColors.textPrimary),
                    ),
                  ),
                  if (isAtOrOverLimit) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.danger,
                      size: 15,
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
