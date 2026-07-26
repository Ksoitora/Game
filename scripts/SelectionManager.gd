extends Node
class_name SelectionManager

# SelectionManager - Gère la sélection des cases de la grille
# Détection du survol et de la sélection des cases

var grid: Grid
var selected_cell: Vector2i = Vector2i(-1, -1)
var hovered_cell: Vector2i = Vector2i(-1, -1)
var selection_range: int = 1  # Portée de sélection

var selected_cells: Array = []  # Cellules actuellement sélectionnées
var valid_moves: Array = []  # Mouvements valides

func _ready() -> void:
	print("[SELECTION] SelectionManager initialisé")

func set_grid(new_grid: Grid) -> void:
	"""Définit la grille à utiliser"""
	grid = new_grid

func _process(_delta: float) -> void:
	"""Met à jour le survol de la souris chaque frame"""
	if grid:
		var mouse_pos = get_global_mouse_position()
		hovered_cell = grid.get_grid_position(mouse_pos)
		
		# Vérifier si la case survolée est valide
		if not grid.is_valid_position(hovered_cell.x, hovered_cell.y):
			hovered_cell = Vector2i(-1, -1)

func on_mouse_click(event: InputEventMouseButton) -> void:
	"""Gère les clics de la souris"""
	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if grid and grid.is_valid_position(hovered_cell.x, hovered_cell.y):
			select_cell(hovered_cell.x, hovered_cell.y)

func select_cell(x: int, y: int) -> void:
	"""Sélectionne une case"""
	if not grid.is_valid_position(x, y):
		print("[SELECTION] Position invalide: ", x, ",", y)
		return
	
	selected_cell = Vector2i(x, y)
	print("[SELECTION] Case sélectionnée: ", x, ",", y)
	
	# Calculer les mouvements valides
	calculate_valid_moves()

func calculate_valid_moves() -> void:
	"""Calcule les mouvements valides à partir de la case sélectionnée"""
	valid_moves.clear()
	
	if selected_cell.x == -1:
		return
	
	# BFS (Breadth-First Search) pour trouver les cases accessibles
	var queue = []
	var visited = {}
	
	queue.append({"x": selected_cell.x, "y": selected_cell.y, "distance": 0})
	visited[grid.get_cell_id(selected_cell.x, selected_cell.y)] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if current["distance"] < selection_range:
			var neighbors = grid.get_neighbor_cells(current["x"], current["y"])
			
			for neighbor in neighbors:
				var cell_id = grid.get_cell_id(neighbor["x"], neighbor["y"])
				
				if cell_id not in visited and neighbor["walkable"] and not neighbor["occupied"]:
					visited[cell_id] = true
					valid_moves.append(Vector2i(neighbor["x"], neighbor["y"]))
					queue.append({"x": neighbor["x"], "y": neighbor["y"], "distance": current["distance"] + 1})
	
	print("[SELECTION] Mouvements valides trouvés: ", valid_moves.size())

func is_cell_valid(x: int, y: int) -> bool:
	"""Vérifie si une case est un mouvement valide"""
	return Vector2i(x, y) in valid_moves

func get_hovered_cell() -> Vector2i:
	"""Retourne la case survolée"""
	return hovered_cell

func get_selected_cell() -> Vector2i:
	"""Retourne la case sélectionnée"""
	return selected_cell

func clear_selection() -> void:
	"""Efface la sélection actuelle"""
	selected_cell = Vector2i(-1, -1)
	selected_cells.clear()
	valid_moves.clear()
