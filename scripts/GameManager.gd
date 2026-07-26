extends Node
class_name GameManager

# GameManager - Gère l'ensemble du jeu
# Ce script contrôle les systèmes principaux et coordonne les interactions

var grid: Grid
var selection_manager: SelectionManager
var characters: Array = []  # Tous les personnages
var player: Character  # Le héros jouable
var current_turn: int = 0

func _ready() -> void:
	print("=== Jeu Dofus-Like Initialisé ===")
	
	# Initialiser la grille
	grid = Grid.new()
	grid.initialize(15, 15)  # Grille 15x15
	add_child(grid)
	
	# Initialiser le gestionnaire de sélection
	selection_manager = SelectionManager.new()
	selection_manager.set_grid(grid)
	selection_manager.set_game_manager(self)
	add_child(selection_manager)
	
	# Créer le héros jouable
	player = Character.new("Héros", 7, 7, true)
	characters.append(player)
	print("[GAMEMANAGER] Héros créé à (7, 7)")
	
	# Créer des ennemis
	var enemy1 = Character.new("Gobelin 1", 3, 3, false)
	characters.append(enemy1)
	print("[GAMEMANAGER] Ennemi créé à (3, 3)")
	
	var enemy2 = Character.new("Gobelin 2", 11, 11, false)
	characters.append(enemy2)
	print("[GAMEMANAGER] Ennemi créé à (11, 11)")
	
	# Redessiner la grille pour afficher les personnages
	grid.set_characters(characters)
	
	print("Grille initialisée: ", grid.width, "x", grid.height)
	print("[GAMEMANAGER] Nombre de personnages: ", characters.size())

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	# Les événements d'entrée sont gérés directement par SelectionManager via _input()
	pass

func get_player() -> Character:
	"""Retourne le héros jouable"""
	return player

func get_characters() -> Array:
	"""Retourne tous les personnages"""
	return characters

func get_character_at(x: int, y: int) -> Character:
	"""Retourne le personnage à une position donnée, null si aucun"""
	for character in characters:
		if character.grid_x == x and character.grid_y == y:
			return character
	return null

func move_character(character: Character, target_x: int, target_y: int) -> bool:
	"""Déplace un personnage vers une cible si possible"""
	# Calculer le chemin le plus court avec BFS
	var path = find_path(character.grid_x, character.grid_y, target_x, target_y)
	
	if path.is_empty():
		print("[GAMEMANAGER] Pas de chemin disponible!")
		return false
	
	# Coût du mouvement = nombre de cases du chemin
	var movement_cost = path.size()
	
	# Vérifier si le personnage a assez de points de mouvement
	if not character.can_move_to(movement_cost):
		print("[GAMEMANAGER] Pas assez de points de mouvement!")
		return false
	
	# Déplacer le personnage
	character.move_to(target_x, target_y, movement_cost)
	grid.queue_redraw()
	return true

func find_path(start_x: int, start_y: int, end_x: int, end_y: int) -> Array:
	"""Trouve le chemin le plus court entre deux points avec BFS"""
	var queue = []
	var visited = {}
	var parent = {}
	
	var start_key = str(start_x) + "," + str(start_y)
	var end_key = str(end_x) + "," + str(end_y)
	
	queue.append(Vector2i(start_x, start_y))
	visited[start_key] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if current == Vector2i(end_x, end_y):
			# Reconstruire le chemin
			var path = []
			var current_key = end_key
			while current_key in parent:
				var parent_key = parent[current_key]
				var parts = parent_key.split(",")
				path.push_front(Vector2i(int(parts[0]), int(parts[1])))
				current_key = parent_key
			return path
		
		# Vérifier les 6 voisins (isométrique)
		var offsets = [
			[-1, 0], [1, 0],
			[0, -1], [0, 1],
			[-1, -1], [1, 1]
		]
		
		for offset in offsets:
			var nx = current.x + offset[0]
			var ny = current.y + offset[1]
			var neighbor_key = str(nx) + "," + str(ny)
			
			if grid.is_valid_position(nx, ny) and neighbor_key not in visited:
				var cell = grid.get_cell(nx, ny)
				# Vérifier que la case est traversable et pas occupée
				if cell["walkable"] and not cell["occupied"]:
					# Vérifier qu'aucun personnage n'est sur cette case (sauf la destination)
					if get_character_at(nx, ny) == null or (nx == end_x and ny == end_y):
						visited[neighbor_key] = true
						parent[neighbor_key] = str(current.x) + "," + str(current.y)
						queue.append(Vector2i(nx, ny))
	
	return []  # Pas de chemin trouvé

func end_turn() -> void:
	"""Termine le tour et réinitialise les points de mouvement"""
	current_turn += 1
	for character in characters:
		character.reset_movement_points()
	print("[GAMEMANAGER] Tour ", current_turn, " - Points de mouvement réinitialisés")
