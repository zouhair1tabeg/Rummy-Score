# 🃏 Rummy Score — Compteur de Score pour Rami

Application mobile moderne, élégante et intuitive développée avec **Flutter** pour suivre, calculer et gérer facilement les scores des parties de cartes de **Rami** (Rummy) entre amis ou en famille.

---

## ✨ Fonctionnalités Principales

- 👥 **Gestion Multi-joueurs (2 à 4 joueurs)** :
  - Création rapide d'une partie avec noms personnalisés.
  - Configuration de la limite d'élimination (par défaut **151 points**).
- 🧮 **Saisie et Calcul Intelligent des Manches** :
  - Sélection instantanée du vainqueur de manche (reçoit automatiquement **0 point**).
  - Saisie des scores pour les autres joueurs actifs.
  - Prévisualisation dynamique des scores avant validation.
  - Détection automatique des éliminations dès qu'un joueur franchit la limite.
- 🔄 **Système Exclusif de "Revanche"** :
  - Conçu pour les parties à 4 joueurs (avec au moins 3 joueurs actifs).
  - Permet à un joueur éliminé de reprendre le score le plus élevé des autres joueurs actifs (utilisable une seule fois par partie).
- ↩️ **Annulation (Undo) Robuste** :
  - Possibilité d'annuler une manche ou une décision d'élimination/revanche grâce à des snapshots complets de l'état du jeu.
- 📊 **Tableau de Bord & Historique** :
  - Classement en temps réel, indicateurs d'état et badges personnalisés.
  - Historique complet des manches et des anciennes parties terminées ou en cours.
  - Sauvegarde locale automatique et persistante via `shared_preferences`.
- 📖 **Guide et Règles Intégrés** :
  - Écran dédié récapitulant toutes les règles officielles du jeu et le fonctionnement de la Revanche.
- 🎨 **Interface Moderne Glassmorphism** :
  - Design soigné avec effets de verre flouté, palette de couleurs pastel et animations fluides (Material 3).

---

## 📱 Aperçu de l'Architecture du Code

```text
lib/
├── constants/          # Constantes de thème, palette de couleurs glassmorphism
│   ├── app_colors.dart
│   └── app_theme.dart
├── logic/              # Moteur de règles métier pures et calculs
│   └── game_engine.dart
├── models/             # Modèles de données immuables
│   ├── game.dart
│   ├── game_state_snapshot.dart
│   ├── player.dart
│   └── round.dart
├── screens/            # Écrans de l'application
│   ├── home_screen.dart
│   ├── new_game_screen.dart
│   ├── scoreboard_screen.dart
│   ├── add_round_screen.dart
│   ├── game_over_screen.dart
│   ├── history_screen.dart
│   └── rules_screen.dart
├── services/           # Persistance locale (SharedPreferences)
│   └── storage_service.dart
├── state/              # Gestionnaire d'état réactif
│   └── game_notifier.dart
├── utils/              # Fonctions utilitaires
└── widgets/            # Composants graphiques réutilisables (GlassBackground, Cards, etc.)
```

---

## 🚀 Installation & Démarrage Rapide

### Prérequis
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version `>= 3.10.4`)
- [Dart SDK](https://dart.dev/get-dart)
- Xcode (pour iOS / macOS) ou Android Studio (pour Android)

### Étapes d'installation

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/zouhair1tabeg/Rummy-Score.git
   cd Rummy-Score
   ```

2. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```

3. **Lancer l'application** :
   ```bash
   flutter run
   ```

---

## 📦 Compilation & Déploiement

### Android (APK & App Bundle)
```bash
# Générer l'APK Release
flutter build apk --release

# Générer l'App Bundle (.aab pour le Google Play Store)
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

---

## 📜 Règles du Jeu en Bref

1. **Limite d'élimination** : Fixée par défaut à 151 points. Dépasser la limite entraîne l'élimination du joueur.
2. **Décompte** : Le vainqueur de la manche marque 0 pt, tous les autres joueurs marquent la somme des points de leurs cartes en main.
3. **Revanche** : En partie à 4 joueurs, un joueur éliminé peut activer une fois sa revanche s'il reste au moins 3 joueurs actifs ; son score est alors aligné sur le score le plus élevé parmi les autres joueurs actifs.
4. **Victoire** : Le dernier joueur restant non éliminé remporte la partie !

---

## 🛠️ Technologies Utilisées

- **Framework** : [Flutter](https://flutter.dev)
- **Langage** : [Dart](https://dart.dev)
- **Persistance** : `shared_preferences`
- **Internationalisation & Formatage** : `intl`
- **Design System** : Google Material Design 3 + Custom Glassmorphism

---

## 👤 Auteur

- GitHub : [@zouhair1tabeg](https://github.com/zouhair1tabeg)

---

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus d'informations.
