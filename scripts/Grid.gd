extends Node2D
class_name Grid

# Grid - Gère la grille isométrique du jeu
# Structure et positions des cases

var width: int = 15
var height: int = 15
var tile_size: int = 64
var cells: Dictionary = {}  # Dictionnaire pour stocker les données des cases
var is_initialized: bool = false
var selected_cell: Vector2i = Vector2i(-1, -1)
var characters: Array = []  # Liste des personnages

func _ready() -> void:
	print("[GRID] Grid initialisée")
	# Centrer la caméra sur la grille après qu'elle soit dans la scène
	if is_initialized:
		center_camera()

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
	
	is_initialized = true
	queue_redraw()
	print("[GRID] Grille créée: ", width, "x", height, " cases")

func center_camera() -> void:
	"""Centre la caméra sur la grille"""
	var center_pos = get_world_position(width / 2, height / 2)
	position = -center_pos + get_viewport().get_visible_rect().size / 2

func set_characters(chars: Array) -> void:
	"""Définit la liste des personnages à afficher"""
	characters = chars
	queue_redraw()

func get_cell_id(x: int, y: int) -> String:
	"""Retourne un ID unique pour une case"""
	return str(x) + "," + str(y)

func get_world_position(grid_x: int, grid_y: int) -> Vector2:
	"""Convertit les coordonnées de la grille en position mondiale isométrique (style Dofus)"""
	var iso_x = (float(grid_x) - float(grid_y)) * float(tile_size) / 2.0
	var iso_y = (float(grid_x) + float(grid_y)) * float(tile_size) / 4.0
	return Vector2(iso_x, iso_y)

func get_grid_position(world_pos: Vector2) -> Vector2i:
	"""Convertit une position mondiale en coordonnées de grille"""
	# Ajuster pour la position de la node Grid
	var local_pos = world_pos - global_position
	
	var grid_x = int((local_pos.x / (float(tile_size) / 2.0) + local_pos.y / (float(tile_size) / 4.0)) / 2.0)
	var grid_y = int((local_pos.y / (float(tile_size) / 4.0) - local_pos.x / (float(tile_size) / 2.0)) / 2.0)
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
		queue_redraw()

func set_cell_walkable(x: int, y: int, walkable: bool) -> void:
	"""Marque une case comme traversable ou non"""
	var cell_id = get_cell_id(x, y)
	if cell_id in cells:
		cells[cell_id]["walkable"] = walkable
		queue_redraw()

func set_selected_cell(x: int, y: int) -> void:
	"""Sélectionne une case"""
	if x == -1 or y == -1:
		selected_cell = Vector2i(-1, -1)
	elif is_valid_position(x, y):
		selected_cell = Vector2i(x, y)
	queue_redraw()

func get_selected_cell() -> Vector2i:
	"""Retourne la case sélectionnée"""
	return selected_cell

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
	"""Dessine la grille avec des losanges isométriques et les personnages"""
	# Ne rien dessiner si la grille n'est pas initialisée
	if not is_initialized or cells.is_empty():
		return
	
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
			var cell_id = get_cell_id(x, y)
			
			# Vérifier si c'est la case sélectionnée
			if selected_cell == Vector2i(x, y):
				color = Color.YELLOW
			elif cell_id in cells:
				if cells[cell_id]["occupied"]:
					color = Color.RED
				elif not cells[cell_id]["walkable"]:
					color = Color.BLACK
			
			# Dessiner le losange
			draw_colored_polygon(points, color)
			draw_polyline(points, Color.WHITE, 1.0)
	
	# Dessiner les personnages
	for character in characters:
		draw_character(character)

func draw_character(character: Character) -> void:
	"""Dessine un personnage sur la grille"""
	var world_pos = get_world_position(character.grid_x, character.grid_y)
	var radius = tile_size / 4.0
	
	# Dessiner le cercle du personnage
	draw_circle(world_pos, radius, character.color)
	
	# Ajouter une bordure
	draw_arc(world_pos, radius, 0, TAU, 16, Color.WHITE, 2.0)
