extends Resource
class_name LevelData

@export var piece_seed: int
@export var board_seed: int
@export var size: int
@export var level_type: Lists.LEVEL_TYPE
@export var turn_count_max: int = 20
@export var stones: Array[Vector2i]
@export var holes: Array[Vector2i]
@export var is_random_board: bool
