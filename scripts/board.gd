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
var move_count_array: Array2DInt		# item is count of pieces above which have moved this turn
										# for calulating bounce depth


#func _ready() -> void:
	#var t_piece: PhysicsPiece = physics_piece_prefab.instantiate()
	#add_child(t_piece)


func setup(a_abst_board: Array2DAbstractSquare):
	size = a_abst_board.size
	move_count_array = Array2DInt.new(size)
	squares = Array2DSquare.new(size)
	for i_x: int in range(a_abst_board.size.x):
		for i_y: int in range(a_abst_board.size.y):
			var t_coord: Vector2i = Vector2i(i_x, i_y)
			var t_abst_square: AbstractSquare = a_abst_board.at(t_coord)
			place_square(t_abst_square)


# Remove current boared squares
func clear():
	if squares == null: return
	for i_square: Square in squares.linear():
		i_square.queue_free()


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


# Clear both selected sqare and valid move highlights
func clear_all_markers():
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


func animate_move(a_move: Move, a_down: Vector2i):
	var t_start: Square = squares.at(a_move.start)
	var t_end: Square = squares.at(a_move.end)
		# Move sprite from start to end squares
	t_start.piece.z_index = 5
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
	var t_delta: Vector2 = Vector2(t_end.position - t_start.position)
	#var t_duration: float = a_move.animation_duration() *  distance(t_start.coords(), t_end.coords())
	tween.tween_property(t_start.piece, 'position', t_delta, a_move.animation_duration())
	tween.finished.connect(on_animated_move_finished.bind(a_move, a_down))


# We have moved the actual Sprite2D from the start to the end square - 
# We have to move that back, and display the correct pieces 
func on_animated_move_finished(a_move: Move, a_down: Vector2i):
	move_animation_finished.emit(a_move)
	var t_start: Square = squares.at(a_move.start)
	var t_end: Square = squares.at(a_move.end)
	# Move start square sprite back to start square position, and clear
	t_start.piece.z_index = 1
	t_start.piece.position = Vector2(0, 0)
	t_start.piece.texture = null
	# Restore display of moved piece to end square
	t_end.display_piece(a_move.piece)
	t_end.bounce(move_count_array.at(t_end.coords()), a_down)


# Distance in units of square width
func distance(a_start: Vector2i, a_end: Vector2i) -> float:
	var t_x: int = a_end.x - a_start.x
	var t_y: int = a_end.y - a_start.y
	var t_value: int = pow(t_x, 2) + pow(t_y, 2)
	return sqrt(t_value as float)

func animate_next_moveset(a_down: Vector2i):
	if animation_queue.is_empty():
		return
	var t_moveset: Array[Move] = animation_queue[0]
	if not t_moveset.is_empty():
		for i_move: Move in t_moveset:
			animate_move(i_move, a_down)


# Animate removal of matched set
func animate_match(a_matched_set: Array[Vector2i]):
	for i_coord: Vector2i in a_matched_set:
		var t_square: Square = squares.at(i_coord)
		var t_piece: GamePiece = piece_at(i_coord)
		var is_preserve: bool = t_piece != null and t_piece.multiplier > 0
		if not is_preserve:
			t_square.do_match_animation()
		t_square.show_brief_emphasis()


func piece_at(a_coord: Vector2i) -> GamePiece:
	return pieces.at(a_coord)


# Do match animation for all squares in a_set_of_sets
func animate_matches(a_set_of_sets: Array[Array]):
	for i_set: Array[Vector2i] in a_set_of_sets:
		animate_match(i_set)


# A_down is the direction pieces will fall
func animate_fill(a_moves: Array[Move], a_down: Vector2i):
	refresh_move_count_array(a_moves, a_down)
	var t_board_width: float = size.x * Constants.SQUARE_WIDTH		# We drop piece from one board width
	for i_move: Move in a_moves:
		var t_square: Square = squares.at(i_move.end)
		t_square.display_piece(i_move.piece)
		var t_piece: Sprite2D = t_square.piece
		t_piece.position = -1.0 * a_down * t_board_width
		var tween = get_tree().create_tween()#.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		#var t_distance: float = abs((i_move.end * a_down).length()) + 1.0
		var t_distance: float = move_count_array.at(t_square.coords()) + 1.0
		tween.tween_property(t_piece, 'position', Vector2.ZERO, i_move.animation_duration())
		#tween.finished.connect(down_bounce.bind(t_piece, a_down, t_distance))
		tween.finished.connect(t_square.bounce.bind(t_distance, a_down))


func animate_slide(a_moves: Array[Move], a_down: Vector2i):
	refresh_move_count_array(a_moves, a_down)
	for i_move: Move in a_moves:
		animate_move(i_move, a_down)



# Used to calculate bounce depth for moved pieces
func refresh_move_count_array(a_moves: Array[Move], a_down: Vector2i):
	move_count_array = Array2DInt.new(size)
	var t_is_moved_array: Array2DBool = Array2DBool.new(size)
	for i_move: Move in a_moves:
		t_is_moved_array.put(true, i_move.end)


	for i: int in size.x:
		#var t_start: int = 1 if is_negative_direction(a_down) else (size.x - 2)
		#var t_end: int = size.x - 1 if is_negative_direction(a_down) else 0
		var t_direction: int = -1 if is_negative_direction(a_down) else 1
		var t_current: Vector2i
		var t_lower: Vector2i
		var t_count: int = 0
		for j: int in size.x:
			# If a_down is apositive direction (eg DOWN) we count backwards
			var t_j: int = j if is_negative_direction(a_down) else (size.x - 1) - j
			if is_horizontal_direction(a_down):
				t_current = Vector2i(t_j, i)
				t_lower = Vector2i(t_j + t_direction, i)
			else:
				t_current = Vector2i(i, t_j)
				t_lower = Vector2i(i, t_j + t_direction)
			if t_is_moved_array.is_valid_coord(t_lower) and t_is_moved_array.at(t_lower):
				t_count += 1
			else:
				t_count = 0
			move_count_array.put(t_count, t_current)



func is_horizontal_direction(a_direction: Vector2i) -> bool:
	if a_direction.y == 0: return true
	return false


# AKA Vector2i.UP and Vector2i.LEFT
func is_negative_direction(a_direction: Vector2i) -> bool:
	if a_direction.x < 0 or a_direction.y < 0: return true
	return false


#func down_bounce(a_piece: Sprite2D, a_down: Vector2i, a_distance: float):
	#var down_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	#var rot_tween = get_tree().create_tween()
	#var t_rot_saved: float = a_piece.rotation
	#var t_rot: float = randf_range(-0.05, 0.05)
	##down_tween.tween_property(a_piece, 'position', Vector2(0, 2.0), Constants.DOWN_BOUNCE_DURATION)
	#down_tween.tween_property(a_piece, 'position', 10.0 * a_distance * a_down, Constants.DOWN_BOUNCE_DURATION)
	#down_tween.finished.connect(up_bounce.bind(a_piece, t_rot_saved))
	#rot_tween.tween_property(a_piece, 'rotation', t_rot + t_rot_saved, Constants.DOWN_BOUNCE_DURATION)
	#
	#
	#
#func up_bounce(a_piece: Sprite2D, a_saved_rot: float):
	#var up_tween = get_tree().create_tween()#.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	#up_tween.tween_property(a_piece, 'position', Vector2.ZERO, Constants.UP_BOUNCE_DURATION)
	#var rot_tween = get_tree().create_tween()
	#rot_tween.tween_property(a_piece, 'rotation', a_saved_rot, Constants.UP_BOUNCE_DURATION)


# Rotate piece sprites to counter board rotation (so the still look upright)
func rotate_pieces(a_rotation: float):
	for i_square: Square in squares.linear():
		i_square.rotate_piece(a_rotation)
	pass

func set_piece_visible(a_square: Square):
	a_square.piece.visible = true


# Sometimes a piece will not display correctly after a move
func refresh_pieces():
	for i_x: int in range(size.x):
		for i_y: int in range(size.y):
			var t_coord: Vector2i = Vector2i(i_x, i_y)
			var t_piece: GamePiece = piece_at(t_coord)
			if t_piece != null:
				squares.at(t_coord).display_piece(t_piece)
