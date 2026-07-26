extends Node
class_name Character

# Character - Classe de base pour les personnages (Héros, Ennemis, etc.)
# Gère la position, les points de mouvement et les propriétés du personnage

var name: String = "Character"
var grid_x: int = 0
var grid_y: int = 0
var max_hp: int = 100
var current_hp: int = 100
var max_movement_points: int = 6
var current_movement_points: int = 6
var is_player: bool = false  # true pour le héros, false pour les ennemis
var color: Color = Color.BLUE

func _init(p_name: String, p_x: int, p_y: int, p_is_player: bool = false) -> void:
	"""Initialise un personnage"""
	name = p_name
	grid_x = p_x
	grid_y = p_y
	is_player = p_is_player
	current_hp = max_hp
	current_movement_points = max_movement_points
	
	# Couleur différente pour le joueur et les ennemis
	if is_player:
		color = Color.BLUE
	else:
		color = Color.RED

func move_to(new_x: int, new_y: int, cost: int) -> bool:
	"""Essaie de se déplacer vers une nouvelle position"""
	if current_movement_points >= cost:
		grid_x = new_x
		grid_y = new_y
		current_movement_points -= cost
		print("[CHARACTER] ", name, " s'est déplacé à (", grid_x, ",", grid_y, ") - Points restants: ", current_movement_points)
		return true
	else:
		print("[CHARACTER] ", name, " n'a pas assez de points de mouvement! (Besoin: ", cost, ", Actuels: ", current_movement_points, ")")
		return false

func can_move_to(distance: int) -> bool:
	"""Vérifie si le personnage a assez de points de mouvement"""
	return current_movement_points >= distance

func reset_movement_points() -> void:
	"""Réinitialise les points de mouvement (fin de tour)"""
	current_movement_points = max_movement_points
	print("[CHARACTER] ", name, " a regagné ", max_movement_points, " points de mouvement")

func take_damage(damage: int) -> void:
	"""Inflige des dégâts au personnage"""
	current_hp -= damage
	current_hp = max(0, current_hp)
	print("[CHARACTER] ", name, " a pris ", damage, " dégâts. HP: ", current_hp, "/", max_hp)

func is_alive() -> bool:
	"""Vérifie si le personnage est vivant"""
	return current_hp > 0

func get_position() -> Vector2i:
	"""Retourne la position actuelle"""
	return Vector2i(grid_x, grid_y)

func set_position(new_x: int, new_y: int) -> void:
	"""Définit la position (pour initialisation)"""
	grid_x = new_x
	grid_y = new_y
