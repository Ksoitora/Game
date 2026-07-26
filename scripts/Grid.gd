extends Node2D
class_name Grid

# Grid - Gère la grille isométrique du jeu
# Structure et positions des cases

var width: int = 15
var height: int = 15
var tile_size: int = 64
var cells: Dictionary = {}  # Dictionnaire pour stocker les données des cases

func _ready() -> void:
	print("[GRID] Grid initialisée")

func initialize(grid_width: int, grid_height: int) -> void:
	"""Initialise la grille avec les dimensions spécifiées"""
	width = grid_width
	height = grid_height
	
	# Créer les cases de la grille
	for x in range(width):
		for y in range(height):
			var cell_id = get_cell_id(x, y)
			cells[cell_id] = {
				"x": x,
				"y": y,
				"walkable": true,
				"occupied": false,
				"entity": null
			}
	
	print("[GRID] Grille créée: ", width, "x", height, " cases")

func get_cell_id(x: int, y: int) -> String:
	"""Retourne un ID unique pour une case"""
	return str(x) + "," + str(y)

func get_world_position(grid_x: int, grid_y: int) -> Vector2:
	"""Convertit les coordonnées de la grille en position mondiale isométrique"""
	var iso_x = (float(grid_x) - float(grid_y)) * float(tile_size) / 2.0
	var iso_y = (float(grid_x) + float(grid_y)) * float(tile_size) / 4.0
	return Vector2(iso_x, iso_y)

func get_grid_position(world_pos: Vector2) -> Vector2i:
	"""Convertit une position mondiale en coordonnées de grille"""
	var grid_x = int((world_pos.x / (float(tile_size) / 2.0) + world_pos.y / (float(tile_size) / 4.0)) / 2.0)
	var grid_y = int((world_pos.y / (float(tile_size) / 4.0) - world_pos.x / (float(tile_size) / 2.0)) / 2.0)
	return Vector2i(grid_x, grid_y)

func is_valid_position(x: int, y: int) -> bool:
	"""Vérifie si une position est valide sur la grille"""
	return x >= 0 and x < width and y >= 0 and y < height

func get_cell(x: int, y: int) -> Dictionary:
	"""Récupère les données d'une case"""
	if not is_valid_position(x, y):
		return {}
	return cells.get(get_cell_id(x, y), {})

func set_cell_occupied(x: int, y: int, occupied: bool) -> void:
	"""Marque une case comme occupée ou libre"""
	var cell_id = get_cell_id(x, y)
	if cell_id in cells:
		cells[cell_id]["occupied"] = occupied

func set_cell_walkable(x: int, y: int, walkable: bool) -> void:
	"""Marque une case comme traversable ou non"""
	var cell_id = get_cell_id(x, y)
	if cell_id in cells:
		cells[cell_id]["walkable"] = walkable

func get_neighbor_cells(x: int, y: int) -> Array:
	"""Retourne les cases voisines (jusqu'à 6 en isométrique)"""
	var neighbors = []
	var offsets = [
		[-1, 0], [1, 0],  # Gauche, Droite
		[0, -1], [0, 1],  # Haut, Bas
		[-1, -1], [1, 1]  # Diagonales
	]
	
	for offset in offsets:
		var nx = x + offset[0]
		var ny = y + offset[1]
		if is_valid_position(nx, ny):
			neighbors.append(get_cell(nx, ny))
	
	return neighbors

func _draw() -> void:
	"""Dessine la grille avec des rectangles"""
	for x in range(width):
		for y in range(height):
			var world_pos = get_world_position(x, y)
			var half_size = tile_size / 2.0
			var quarter_size = tile_size / 4.0
			
			# Créer les points pour un losange isométrique
			var points = PackedVector2Array([
				world_pos + Vector2(half_size, 0),      # Droite
				world_pos + Vector2(0, quarter_size),   # Bas
				world_pos + Vector2(-half_size, 0),     # Gauche
				world_pos + Vector2(0, -quarter_size)   # Haut
			])
			
			# Déterminer la couleur en fonction de l'état
			var color = Color.GRAY
			if cells[get_cell_id(x, y)]["occupied"]:
				color = Color.RED
			elif not cells[get_cell_id(x, y)]["walkable"]:
				color = Color.BLACK
			
			# Dessiner le losange
			draw_colored_polygon(points, color)
			draw_polyline(points, Color.WHITE, 1.0)
