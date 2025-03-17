extends Node

## Object for coordination between other game objects
## Relay for signals between abstract game and display

@onready var board: Node2D = %Board
@onready var board_camera: Camera2D = %BoardCamera
@onready var p_container: PanelContainer = %ViewportPanelContainer
@onready var counter: ScrollingCounter = %ScrollingCounter

var composition: Composition		# Abstract representation of a game
var match_finder: MatchFinder
var board_rotation: int = 0			# [0, 1, 2, or 3] 0 == up; then clockwise by 90 deg (PI/2 rad)
var size: int						# Size of one side of board
var score: int						# As it says
var score_multi: int					# As it says
const TEST_SIZE: int = 4			# Keep board square; dif ratios can be faked using blocked off squares


func _ready():
	size = TEST_SIZE
	composition = test_composition()
	match_finder = MatchFinder.new(composition)
	position_viewport()
	board.setup(composition._abst_board)
	board.display_piece_set(composition._internal)
	board.square_clicked.connect(on_square_clicked)
	position_board()
	reset_camera()
	slide(composition, composition.down)
	#slide_test(t_comp)
	#composition_test()
	for i: int in range(10):
		prints(str(i) + ":", fibo(i))


func position_viewport():
	var t_width: float = get_viewport().size.x
	var t_height: float = get_viewport().size.y
	var t_size: Vector2 = Vector2(t_width, t_width)
	t_height = (t_height / 2.0) - t_width
	p_container.size = Vector2(t_width, t_width)
	p_container.position = Vector2(- t_width / 2.0, t_height)
	%BoardSubViewport.size = t_size


func position_board():
	var t_board_width: int = board.size.x * Constants.SQUARE_WIDTH
	var t_delta: float = t_board_width / 2.0
	t_delta -= 0.5 * Constants.SQUARE_WIDTH		# board origin is in *center* of upper left tile
	board.position = Vector2(-t_delta, -t_delta)



# Get key presses
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			rotate_board(true)
			print(composition.down)
		if event.keycode == KEY_L:
			rotate_board(false)
			print(composition.down)


# Increments roation by 1/4 turn
# Ensures board_rotation (just an index) [0 - 3]
func rotate_board(a_is_clockwise: bool):
	board_rotation += 1 if a_is_clockwise else -1
	var t_angle: float = board_rotation * TAU / 4
	var rot_tween = get_tree().create_tween()
	rot_tween.tween_property(board_camera, 'rotation', t_angle, 1.0)
	
	# This looks terrible and makes me nauseated :P
	#var zoom_saved: Vector2 = board_camera.zoom
	#var zoomout_tween = get_tree().create_tween()
	#zoomout_tween.finished.connect(zoom_board_camera.bind(zoom_saved, 0.5))
	#zoomout_tween.tween_property(board_camera, "zoom", board_camera.zoom / sqrt(2.0), 0.5)
	
	
	composition.rotate_down(a_is_clockwise)
	var t_adj: float = 1.0 if a_is_clockwise else -1.0
	board.rotate_pieces(board_camera.rotation + t_adj * PI/2.0)
	do_slide()


func zoom_board_camera(a_zoom: Vector2, a_duration):
	var zoom_tween = get_tree().create_tween()
	zoom_tween.tween_property(board_camera, "zoom", a_zoom, 0.5)


func slide_test(a_composition: Composition):
	while true:
		move_test(a_composition)
		await get_tree().create_timer(1).timeout
		slide(a_composition, Vector2i.DOWN)
		await get_tree().create_timer(0.5).timeout
		move_test(a_composition)
		await get_tree().create_timer(1).timeout
		slide(a_composition, Vector2i.RIGHT)
		await get_tree().create_timer(0.5).timeout
		move_test(a_composition)
		await get_tree().create_timer(1).timeout
		slide(a_composition, Vector2i.UP)
		await get_tree().create_timer(0.5).timeout
		move_test(a_composition)
		await get_tree().create_timer(1).timeout
		slide(a_composition, Vector2i.LEFT)
		await get_tree().create_timer(0.5).timeout


func move_test(a_composition: Composition):
	#await get_tree().create_timer(1).timeout
	var t_move: Move = a_composition.random_move()
	if t_move != null:
		a_composition.do_move(t_move)
		board.animate_move(t_move)
		print(t_move.start)
		print(t_move.end)
	
	

func slide(a_composition: Composition, a_direction: Vector2i):
	a_composition.down = a_direction
	var moveset: Array[Move] = a_composition.slide_moveset()
	a_composition.do_slide()
	for i_move: Move in moveset:
		board.animate_move(i_move)



func composition_test():
	var t_comp: Composition = test_composition()
	t_comp._internal.out_at_width(8)
	t_comp._internal.put(null, Vector2i(0, 4))
	t_comp._internal.put(null, Vector2i(0, 0))
	t_comp._internal.put(null, Vector2i(2, 3))
	t_comp._internal.put(null, Vector2i(2, 2))
	t_comp._internal.put(GamePiece.new(Lists.PIECE_TYPE.KING, Lists.COLOR.BLACK), Vector2i(1, 1))
	print("---------")
	t_comp._internal.out_at_width(8)
	t_comp.do_slide()
	print("---------")
	t_comp._internal.out_at_width(8)


func test_composition() -> Composition:
	var t_comp: Composition = Composition._init_with_linear(Vector2i(size, size), random_linear_data(size * size))
	#place_stone(Vector2i(2, 2), t_comp)
	#place_stone(Vector2i(3, 0), t_comp)
	#place_stone(Vector2i(3, 5), t_comp)
	place_hole(Vector2i(0, 2), t_comp)
	#place_hole(Vector2i(4, 3), t_comp)
	#place_hole(Vector2i(3, 5), t_comp)
	#t_comp._internal.out_at_width(8)
	#t_comp._internal.put(null, Vector2i(0, 4))
	#t_comp._internal.put(null, Vector2i(0, 0))
	#t_comp._internal.put(null, Vector2i(2, 3))
	#t_comp._internal.put(null, Vector2i(2, 2))
	#t_comp._internal.put(GamePiece.new(Lists.PIECE_TYPE.KING, Lists.COLOR.BLACK), Vector2i(1, 1))
	return t_comp


func place_stone(a_coord: Vector2i, a_composition: Composition):
	a_composition.square_at(a_coord).type = Lists.SQUARE_TYPE.STONE
	a_composition.put_piece_at(null, a_coord)


func place_hole(a_coord: Vector2i, a_composition: Composition):
	a_composition.square_at(a_coord).type = Lists.SQUARE_TYPE.HOLE
	a_composition.put_piece_at(null, a_coord)


func random_linear_data(a_count: int) -> Array[GamePiece]:
	var t_data: Array[GamePiece] = []
	for i_index: int in range(a_count):
		var t_piece = GamePiece.init_random()
		t_data.append(t_piece)
	return t_data

# Note board_camera is a child of a subviewport - we want to center it within the viewport
#func reset_camera():
	##var t_corner_offset: Vector2 = Vector2(Constants.SQUARE_WIDTH / 2, Constants.SQUARE_WIDTH / 2)
	#var t_corner_offset: Vector2 = 0.25 * Vector2(Constants.SQUARE_WIDTH, Constants.SQUARE_WIDTH)
	#var t_length: float = minf(get_viewport().size.x, get_viewport().size.y)
	#var t_board_width: int = board.size.x * Constants.SQUARE_WIDTH
	#board_camera.zoom = Vector2(t_length / t_board_width, t_length / t_board_width)
	#board_camera.offset = Vector2(t_board_width / 2.0, t_board_width / 2.0) + t_corner_offset
	##camera.offset = Vector2(t_board_width / 2.0, t_board_width / 2.0)


# Note board_camera is a child of a subviewport - we want to center it within the viewport
func reset_camera():
	var t_width: float = %BoardSubViewport.size.x
	#var t_length: float = minf(get_viewport().size.x, get_viewport().size.y)
	var t_board_width: int = board.size.x * Constants.SQUARE_WIDTH
	board_camera.zoom = Vector2(t_width / t_board_width, t_width / t_board_width)
	board_camera.zoom = Vector2.ONE
	var t_zoom: float =  t_width / t_board_width
	board_camera.zoom = Vector2(t_zoom, t_zoom)
	#board_camera.offset = Vector2(t_width, t_width)
	pass

# Update composition and board depending on selection state
func on_square_clicked(a_square: Square):
	var t_coords = a_square.coords()
	var t_piece: GamePiece = composition.piece_at(t_coords)
	var t_selected: AbstractSquare = composition.selected_square
	if t_selected != null:	# A square is already selected
		board.clear_all_markers()
		if t_selected.coords == t_coords:	# We have just clicked the currently selected square
			composition.selected_square = null
		elif composition.is_valid_move(t_selected.coords, t_coords):
			var t_move: Move = Move.new(t_selected.coords, 
										t_coords, 
										Lists.MOVE_TYPE.TAKE,
										composition.piece_at(t_selected.coords),
										t_piece)
			composition.selected_square = null
			do_move(t_move)
		else:
			composition.selected_square = null
	elif composition.is_selectable_coord(t_coords):
		composition.selected_square = composition.square_at(t_coords)
		board.display_selected_marker(a_square, true)
		board.display_valid_highlights(composition.valid_moveset(composition.square_at(t_coords)))


# Move a single piece (usually moved by player)
func do_move(a_move: Move):
	score_multi = 1		# Player move resets multiplier
	composition.do_move(a_move)		# Happens in one frame
	board.animate_move(a_move)		# Takes MOVE_DURATION seconds
	await get_tree().create_timer(Constants.MOVE_DURATION).timeout
	do_matches()


# Find matches, remove from composition, animate (calculate score?)
func do_matches():
	var t_matches: Array[Array] = matched_sets()
	if not t_matches.is_empty():
		composition.remove_matched_sets(t_matches)
		update_score_from_matches(t_matches)
		board.animate_matches(t_matches)
		await get_tree().create_timer(Constants.MATCH_DURATION).timeout
	do_slide()


func matched_sets() -> Array[Array]:
	match_finder.find_matched_sets()
	return match_finder.all_matched_sets

# Move pieces to fill empty spaces (and refill?)
func do_slide():
	pass
	var t_moveset: Array[Move] = composition.slide_moveset()
	composition.do_moves(t_moveset)
	if t_moveset.is_empty():
		do_fill()
		await get_tree().create_timer(Constants.SLIDE_DURATION).timeout
	else:
		# TODO: This should be board.animate_slide
		for i_move: Move in t_moveset:
			board.animate_move(i_move)
		await get_tree().create_timer(Constants.SLIDE_DURATION).timeout
		do_fill()
		await get_tree().create_timer(Constants.SLIDE_DURATION).timeout
		do_matches()


# Tell composition to fill empty squares and board to animate fill
func do_fill():
	var t_moves: Array[Move] = composition.fill_moveset()
	composition.fill(t_moves)
	board.animate_fill(t_moves, composition.down)
	#var t_coords: Array[Vector2i] = composition.empty_coords()
	#var t_moves: Array[Move] = []
	#composition.fill()
	#for i_coord: Vector2i in t_coords:
		#t_moves.append(fill_move_from_coord(i_coord))
	#board.animate_fill(t_moves, composition.down)

# Generate a move for animation purposes to show new piece entering board
# Note composition.fill() is already run so new pieces are at their end position
func fill_move_from_coord(a_coord: Vector2i) -> Move:
	var t_down: Vector2i = composition.down
	var t_piece: GamePiece = composition.piece_at(a_coord)
	var t_start: Vector2i = a_coord + composition.size.x * t_down
	return Move.new(t_start, a_coord, Lists.MOVE_TYPE.FILL, t_piece, null)

# As it says
func update_score_from_matches(a_matches: Array[Array]):
	for i_set: Array[Vector2i] in a_matches:
		var t_points: int = score_by_match_size(i_set.size())
		t_points *= score_multi
		score += t_points
		prints(t_points, score_multi)
		counter.display_points(t_points)
		score_multi += 1



# From https://gdscript.com/articles/godot-recursive-functions/
func fibo(n):
	# If n is 0 or 1 return 1  
	if n < 2:
		return 1
	# Calculate the number
	return fibo(n - 1) + fibo(n - 2)


func score_by_match_size(a_size: int) -> int:
	return fibo(a_size)
	

func print_composition():
	composition._internal.out_at_width(8)
	print("____________________")
	print("")
