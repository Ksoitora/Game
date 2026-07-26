extends Node

# GameManager - Gère l'ensemble du jeu
# Ce script contrôle les systèmes principaux et coordonne les interactions

var grid: Grid
var selection_manager: SelectionManager

func _ready() -> void:
	print("=== Jeu Dofus-Like Initialisé ===")
	
	# Initialiser la grille
	grid = Grid.new()
	grid.initialize(15, 15)  # Grille 15x15
	add_child(grid)
	
	# Initialiser le gestionnaire de sélection
	selection_manager = SelectionManager.new()
	selection_manager.set_grid(grid)
	add_child(selection_manager)
	
	print("Grille initialisée: ", grid.width, "x", grid.height)

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	# Les événements d'entrée sont gérés directement par SelectionManager via _input()
	pass
