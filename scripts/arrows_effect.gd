extends Node2D


# Naming: n == -1; arrow_[x-dir]_[y-dir]
@onready var arrow_1_0: Sprite2D = $Arrow_1_0
@onready var arrow_1_n: Sprite2D = $Arrow_1_n
@onready var arrow_0_n: Sprite2D = $Arrow_0_n
@onready var arrow_n_n: Sprite2D = $Arrow_n_n
@onready var arrow_n_0: Sprite2D = $Arrow_n_0
@onready var arrow_n_1: Sprite2D = $Arrow_n_1
@onready var arrow_0_1: Sprite2D = $Arrow_0_1
@onready var arrow_1_1: Sprite2D = $Arrow_1_1

var arrows: Dictionary[Vector2i, Sprite2D]

func _ready() -> void:
	arrows = {}
	arrows[Vector2i(1, 0)] = arrow_1_0
	arrows[Vector2i(1, -1)] = arrow_1_n
	arrows[Vector2i(0, -1)] = arrow_0_n
	arrows[Vector2i(-1, -1)] = arrow_n_n
	arrows[Vector2i(-1, 0)] = arrow_n_0
	arrows[Vector2i(-1, 1)] = arrow_n_1
	arrows[Vector2i(0, 1)] = arrow_0_1
	arrows[Vector2i(1, 1)] = arrow_1_1


# Takes a set of unit vectors
func set_visibility(a_dirs: Array[Vector2i], a_is_vis: bool):
	for i_dir: Vector2i in a_dirs:
		if arrows.has(i_dir):
			arrows[i_dir].visible = a_is_vis


# Show or hide all arrows
func set_all_visibility(a_is_vis: bool):
	for i_key: Vector2i in arrows.keys():
		arrows[i_key].visible = a_is_vis


# Arrow directions for a piece type at a given intensity
func unit_vector_set(a_piece_type: Lists.PIECE_TYPE, a_level: int) -> Array[Vector2i]:
	match a_piece_type:
		Lists.PIECE_TYPE.PAWN:
			if a_level == 0:
				return []
			else:
				return []
		Lists.PIECE_TYPE.ROOK:
			if a_level == 0:
				return []
			else:
				return []
		Lists.PIECE_TYPE.KNIGHT:
			if a_level == 0:
				return []
			else:
				return []
		Lists.PIECE_TYPE.BISHOP:
			if a_level == 0:
				return []
			else:
				return []
		Lists.PIECE_TYPE.QUEEN:
			if a_level == 0:
				return []
			else:
				return []
		Lists.PIECE_TYPE.KING:
			if a_level == 0:
				return []
			else:
				return []
		_:
			return []
