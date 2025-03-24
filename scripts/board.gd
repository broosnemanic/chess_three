extends Node2D

## Display of board and pieces - no game logic

signal square_clicked(a_square: Square)	# Relays signal from a clicked square to game control
signal move_animation_finished(a_move: Move)


@onready var square_prefab: Resource = preload("res://scenes/square.tscn")


var size: Vector2i						# [column count, row count]
var squares: Array2DSquare				# Squares by coordinate (keeps track of special squares e.g. holes)
var pieces: Array2DGamePiece			# Pieces by cordinate
# Array[Array[Move]]
var animation_queue: Array[Array]		# List of sets of animations to be played sequentially


#func _ready() -> void:
	#var t_piece: PhysicsPiece = physics_piece_prefab.instantiate()
	#add_child(t_piece)


func setup(a_abst_board: Array2DAbstractSquare):
	size = a_abst_board.size
	squares = Array2DSquare.new(size)
	for i_x: int in range(a_abst_board.size.x):
		for i_y: int in range(a_abst_board.size.y):
			var t_coord: Vector2i = Vector2i(i_x, i_y)
			var t_abst_square: AbstractSquare = a_abst_board.at(t_coord)
			place_square(t_abst_square)


func display_piece_set(a_piece_set: Array2DGamePiece):
	pieces = a_piece_set
	for i_index: int in range(a_piece_set.linear().size()):
		var t_square: Square = squares.at(squares.linear_index_to_coords(i_index))
		var t_linear = a_piece_set.linear()
		var t_piece: GamePiece = t_linear[i_index]
		if t_piece == null: continue
		t_square.display_piece(t_piece)


# We start with an AbstractSquare as Square cannot be fully initialized until added to tree
# Note that this both creates and places square
func place_square(a_abst_square: AbstractSquare):
	var t_square: Square = square_prefab.instantiate()
	add_child(t_square)
	t_square.initialize(a_abst_square)
	t_square.position = 128 * a_abst_square.coords
	t_square.square_clicked.connect(on_square_clicked)
	squares.put(t_square, a_abst_square.coords)


# Clear both selected shqare and valid move highlights
func clear_all_markers():
	#var t_stack: Array = get_stack()
	#print(self.get_script().get_path())
	clear_selected_square()
	clear_valid_move_highlights()


# Only one square should be selecected, but we deselect all squares
func clear_selected_square():
	for i_square: Square in squares.linear():
		i_square.is_selected = false


func clear_valid_move_highlights():
	for i_square: Square in squares.linear():
		i_square.display_valid_move_highlight(false)


# Board emits signal to receive instructions on how to handle click
func on_square_clicked(a_square: Square):
	square_clicked.emit(a_square)
	# TODO: handle takes, emit signal to game_control to, for example
	# highlight valid moves from selected square


func display_valid_highlights(a_destination_set: Array[Move]):
	clear_valid_move_highlights()
	for i_move: Move in a_destination_set:
		var t_square: Square = squares.at(i_move.end)
		t_square.display_valid_move_highlight(true)


# Mark a_square as is / not selected
func display_selected_marker(a_square: Square, a_is_selected: bool):
	a_square.is_selected = a_is_selected


func is_piece_present(a_square: Square) -> bool:
	return pieces.at(a_square.coords()) != null


func animate_move(a_move: Move):
	var t_start: Square = squares.at(a_move.start)
	var t_end: Square = squares.at(a_move.end)
		# Move sprite from start to end squares
	t_start.piece.z_index = 5
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
	var t_delta: Vector2 = Vector2(t_end.position - t_start.position)
	#var t_duration: float = a_move.animation_duration() *  distance(t_start.coords(), t_end.coords())
	tween.tween_property(t_start.piece, 'position', t_delta, a_move.animation_duration())
	tween.finished.connect(on_animated_move_finished.bind(a_move))


# We have moved the actual Sprite2D from the start to the end square - 
# We have to move that back, and display the correct pieces 
func on_animated_move_finished(a_move: Move):
	move_animation_finished.emit(a_move)
	var t_start: Square = squares.at(a_move.start)
	var t_end: Square = squares.at(a_move.end)
	# Move start square sprite back to start square position, and clear
	t_start.piece.z_index = 1
	t_start.piece.position = Vector2(0, 0)
	t_start.piece.texture = null
	# Restore display of moved piece to end square
	t_end.display_piece(a_move.piece)


# Distance in units of square width
func distance(a_start: Vector2i, a_end: Vector2i) -> float:
	var t_x: int = a_end.x - a_start.x
	var t_y: int = a_end.y - a_start.y
	var t_value: int = pow(t_x, 2) + pow(t_y, 2)
	return sqrt(t_value as float)

func animate_next_moveset():
	if animation_queue.is_empty():
		return
	var t_moveset: Array[Move] = animation_queue[0]
	if not t_moveset.is_empty():
		for i_move: Move in t_moveset:
			animate_move(i_move)


# Animate removal of matched set
func animate_match(a_matched_set: Array[Vector2i]):
	for i_coord: Vector2i in a_matched_set:
		var t_square: Square = squares.at(i_coord)
		t_square.do_match_animation()


# Do match animation for all squares in a_set_of_sets
func animate_matches(a_set_of_sets: Array[Array]):
	for i_set: Array[Vector2i] in a_set_of_sets:
		animate_match(i_set)


# A_coords are end squares for new pieces to land
# A_down is the direction pieces will fall
func animate_fill(a_moves: Array[Move], a_down: Vector2i):
	var t_board_width: float = size.x * Constants.SQUARE_WIDTH		# We drop piece from one board width
	for i_move: Move in a_moves:
		var t_square: Square = squares.at(i_move.end)
		t_square.display_piece(i_move.piece)
		var t_piece: Sprite2D = t_square.piece
		t_piece.position = -1.0 * a_down * t_board_width
		var tween = get_tree().create_tween()#.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		#var down_tween = get_tree().create_tween()
		#var up_tween = get_tree().create_tween()
		tween.tween_property(t_piece, 'position', Vector2.ZERO, i_move.animation_duration())
		tween.finished.connect(down_bounce.bind(t_piece))



func down_bounce(a_piece: Sprite2D):
	var down_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var rot_tween = get_tree().create_tween()
	var t_rot_saved: float = a_piece.rotation
	var t_rot: float = randf_range(-0.05, 0.05)
	down_tween.tween_property(a_piece, 'position', Vector2(0, 2.0), Constants.DOWN_BOUNCE_DURATION)
	down_tween.finished.connect(up_bounce.bind(a_piece, t_rot_saved))
	rot_tween.tween_property(a_piece, 'rotation', t_rot + t_rot_saved, Constants.DOWN_BOUNCE_DURATION)
	
	
	
func up_bounce(a_piece: Sprite2D, a_saved_rot: float):
	var up_tween = get_tree().create_tween()#.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	up_tween.tween_property(a_piece, 'position', Vector2.ZERO, Constants.UP_BOUNCE_DURATION)
	var rot_tween = get_tree().create_tween()
	rot_tween.tween_property(a_piece, 'rotation', a_saved_rot, Constants.UP_BOUNCE_DURATION)


# Rotate piece sprites to counter board rotation (so the still look upright)
func rotate_pieces(a_rotation: float):
	for i_square: Square in squares.linear():
		i_square.rotate_piece(a_rotation)
	pass

func set_piece_visible(a_square: Square):
	a_square.piece.visible = true
