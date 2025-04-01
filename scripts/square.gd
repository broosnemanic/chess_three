extends Area2D
class_name Square

signal square_clicked(a_square: Square)

@onready var selected: Sprite2D = $Selected
@onready var piece: Sprite2D = $Piece
@onready var stone: Sprite2D = $Stone
@onready var ice: Sprite2D = $Ice
@onready var hole: Sprite2D = $Hole
@onready var highlight: Sprite2D = $Highlight
@onready var background: Sprite2D = $Background

var absract_square: AbstractSquare
var is_locked: bool
var is_selected: bool = false:
	set(a_is_selected):
		is_selected = a_is_selected
		selected.visible = a_is_selected
const PIECE_SCALE: Vector2 = Vector2(0.85, 0.85)


func _ready() -> void:
	ice.modulate = Color(1.0, 1.0, 1.0, 0.75)
	piece.scale = PIECE_SCALE


func initialize(a_absract_square: AbstractSquare) -> void:
	absract_square = a_absract_square
	background.texture = Textures.square_texture(a_absract_square.type, a_absract_square.coords)
	stone.visible = a_absract_square.is_stone()
	hole.visible = a_absract_square.is_hole()
	ice.visible = a_absract_square.is_ice()
	piece.visible = not (a_absract_square.is_stone() or a_absract_square.is_hole())


func _input_event(_viewport, event, _shape_idx):
	if !is_locked:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				square_clicked.emit(self)


#func display_piece(a_type: Lists.PIECE_TYPE, a_color: Lists.COLOR):
	#piece.texture = Textures.piece_texture(a_type, a_color)


func display_piece(a_piece: GamePiece):
	piece.texture = Textures.piece_texture(a_piece.type, a_piece.color)
	piece.scale = PIECE_SCALE


# As it says
func hide_piece():
	piece.texture = null


func set_locked(a_is_locked: bool):
	is_locked = a_is_locked


# Mark this square as a valid destination for piece on selected square
func display_valid_move_highlight(a_is_on: bool):
	highlight.visible = a_is_on


func coords() -> Vector2i:
	return absract_square.coords


# Text representation of self
func out():
	print(absract_square.coords)


# Shrink, then hide and restore size to piece sprite
func do_match_animation():
	var tween = get_tree().create_tween()
	tween.tween_property(piece, 'scale', Vector2(0.25, 0.25), Constants.MATCH_DURATION)
	tween.finished.connect(func(): piece.scale = Vector2.ONE; hide_piece())


# Rotate piece; for matching with board rotation
func rotate_piece(a_rotation: float):
	var rot_tween = get_tree().create_tween()
	rot_tween.tween_property(piece, 'rotation', a_rotation, 1.0)
