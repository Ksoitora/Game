# Jeu Dofus-Like en Godot

Un jeu 2D de type tactique isométrique inspiré par Dofus, développé avec le moteur Godot.

## Structure du Projet

```
.
├── scenes/
│   └── main.tscn          # Scène principale du jeu
├── scripts/
│   ├── GameManager.gd     # Gestionnaire principal du jeu
│   ├── Grid.gd            # Gestion de la grille isométrique
│   └── SelectionManager.gd # Gestion de la sélection des cases
├── project.godot          # Configuration du projet Godot
└── README.md              # Ce fichier
```

## Fonctionnalités Actuelles

### GameManager.gd
- **Gestionnaire principal** du jeu
- Initialise la grille et le système de sélection
- Coordonne les interactions entre les systèmes

### Grid.gd
- **Grille isométrique** 15x15
- Conversion entre coordonnées de grille et position mondiale
- Gestion des propriétés des cases (traversable, occupée, etc.)
- Calcul des cases voisines
- Dessin de la grille pour debug

### SelectionManager.gd
- **Détection du survol** de la souris
- **Sélection des cases** au clic gauche
- **Calcul des mouvements valides** avec BFS
- Gestion de la portée de sélection

## Commandes

- **Clic gauche** sur une case: Sélectionner/se déplacer
- Les cases valides sont calculées automatiquement

## Comment Utiliser

1. Ouvrez le projet dans Godot
2. Lancez la scène `scenes/main.tscn`
3. Cliquez sur les cases pour les sélectionner
4. Les mouvements valides seront automatiquement calculés

## Prochaines Étapes

- [ ] Ajout des entités (personnages, ennemis)
- [ ] Système de combat
- [ ] Animations
- [ ] Interface utilisateur
- [ ] Système de tour par tour
- [ ] Effets de sorts
- [ ] Niveaux et monde

## Version

v0.1.0 - Base initiale
