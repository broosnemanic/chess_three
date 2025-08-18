extends Node

## Object for coordination between other game objects
## Relay for signals between abstract game and display

@onready var board: Node2D = %Board
@onready var board_camera: Camera2D = %BoardCamera
@onready var p_container: PanelContainer = %ViewportPanelContainer
@onready var multi_display: RichTextLabel = %MultiDisplay
@onready var counter: ScrollingCounter = %ScrollingCounter
@onready var high_score_label: RichTextLabel = %HighScoreLabel
@onready var physics_piece_prefab = preload("res://scenes/physics_piece.tscn")
@onready var popup_prefab = preload("res://scenes/popup_message.tscn")
@onready var message_box_prefab = preload("res://scenes/meassge_box.tscn")

@onready var level_data: LevelData = preload("res://levels/level_data_01.tres")

var piece_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var composition: Composition		# Abstract representation of a game
var match_finder: MatchFinder
var board_rotation: int = 0			# [0, 1, 2, or 3] 0 == up; then clockwise by 90 deg (PI/2 rad)
var size: int						# Size of one side of board
var score: int						# As it says
var score_multi: int:
		set(a_multi):
			score_multi = a_multi
			multi_display.display_multi(a_multi)
func get_multi_text(a_multi: int) -> String:
	return "[font_size=24]" + str(a_multi) + " X[/font_size]"
	
	
const TEST_SIZE: int = 10			# Keep board square; dif ratios can be faked using blocked off squares

var score_data: Dictionary = {0:0, 1:0, 2:0}
var default_score_data: Dictionary = {0:0}
var save_path = "user://score_date.save"
var turn_index: int					# What turn are we on for the current level?
var loaded_level_index: int
var high_score: int					# Last high score for loaded level
#var popup: PopupPanel
#var popup_label: RichTextLabel
var message_box: PanelContainer


func _ready():
	counter.is_rate_by_chunk = true
	counter.chunk_rate = 1.0
	message_box = message_box_prefab.instantiate()
	%MessageBoxContainer.add_child(message_box)


func load_level(a_level_data: LevelData):
	level_data = a_level_data
	composition = Composition._init_from_level_data(level_data)
	match_finder = MatchFinder.new(composition)
	setup_board()
	slide(composition, composition.down)
	load_score_data()
	display_high_score(high_score)
	update_turns_left_label()



func setup_board():
	position_viewport()
	board.clear()
	board.setup(composition._abst_board)
	board.display_piece_set(composition._internal)
	if not board.square_clicked.is_connected(on_square_clicked):
		board.square_clicked.connect(on_square_clicked)
	if not board.move_animation_finished.is_connected(on_move_animation_finished):
		board.move_animation_finished.connect(on_move_animation_finished)
	position_board()
	reset_camera()


func save_score_data():
	if high_score < score:
		score_data[loaded_level_index] = score
		var save = FileAccess.open(save_path, FileAccess.WRITE)
		save.store_var(score_data)
		save.flush()
		print_debug("Saved: " + str(score_data))


func load_score_data():
	if FileAccess.file_exists(save_path):
		var t_save = FileAccess.open(save_path, FileAccess.READ)
		var t_data = t_save.get_var()
		score_data = default_score_data.duplicate() if t_data == null else t_data
		if not score_data.has(loaded_level_index):
			score_data[loaded_level_index] = 0
		high_score = score_data[loaded_level_index]
		#counter.display_points(score_data[0])


func position_viewport():
	#var t_width: float = get_viewport().size.x
	#var t_height: float = get_viewport().size.y
	#var t_width: float = %TopUIContainer.size.x
	#var t_height: float = %TopUIContainer.size.y
	var t_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
	var t_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
	
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
	pass


# Get key presses
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			rotate_board(true)
		if event.keycode == KEY_L:
			rotate_board(false)
		if event.keycode == KEY_1:
			set_level(1)
		if event.keycode == KEY_2:
			set_level(2)
		if event.keycode == KEY_3:
			set_level(3)


func set_level(a_level_index: int):
	match a_level_index:
		1: 
			level_data = load("res://levels/level_data_01.tres")
		2: 
			level_data = load("res://levels/level_data_02.tres")
		3: 
			level_data = load("res://levels/level_data_03.tres")
	loaded_level_index = a_level_index
	load_level(level_data)


func display_high_score(a_score: int):
	var t_text: String = BBString.new(str(a_score)).center().b.size(24).color("dark gray").string
	high_score_label.text = t_text


func increment_turn_index():
	turn_index += 1
	update_turns_left_label()
	if turn_index >= level_data.turn_count_max:
		on_lose()


func is_win_condition_met() -> bool:
	return true
	

func on_win():
	pass


func on_lose():
	pass
	message_box.set_message("Out of Moves :(")


#func display_popup_message(a_message: String):
	#var t_text: String = a_message
	#t_text = BBUtil.at_color(t_text, "dark gray")
	#t_text = BBUtil.at_centered(t_text)
	#t_text = BBUtil.at_size(t_text, 24)
	#popup.set_text(t_text)
	#popup.visible = true
	#popup.position = Vector2((p_container.size.x) / 2.0, 0.0) + Vector2(-popup.size.x / 2.0, 200.0)
	#pass


func update_turns_left_label():
	var t_text: String = str(level_data.turn_count_max - turn_index)
	t_text = BBUtil.at_size(t_text, 24)
	t_text = BBUtil.at_color(t_text, "green")
	t_text = BBUtil.at_centered(t_text)
	%TurnsLeftLabel.text = t_text


# Increments roation by 1/4 turn
# Ensures board_rotation (just an index) [0 - 3]
func rotate_board(a_is_clockwise: bool):
	increment_turn_index()
	board_rotation += 1 if a_is_clockwise else -1
	var t_angle: float = board_rotation * TAU / 4
	var rot_tween = get_tree().create_tween()
	rot_tween.tween_property(board_camera, 'rotation', t_angle, 1.0)
	composition.rotate_down(a_is_clockwise)
	#set_gravity_dir(board_rotation_to_vector(board_rotation))
	#set_gravity_dir(composition.down)
	var t_adj: float = 1.0 if a_is_clockwise else -1.0
	board.rotate_pieces(board_camera.rotation + t_adj * PI/2.0)
	do_slide()


# A_rot is the integer
#func transformed_pos_from_board_rot(a_pos: Vector2) -> Vector2:
	#var t_pos: Vector2
	#match board_rotation:
		#0:	# Default orientation
			#t_pos = a_pos
		#1:
			#t_pos = Vector2(a_pos.y, -a_pos.x)
		#2:
			#t_pos = Vector2(-a_pos.x, -a_pos.y)
		#3:
			#t_pos = Vector2(-a_pos.y, a_pos.x)
		#_:
			#t_pos = Vector2.ZERO
	#return t_pos
			
func transformed_pos_from_board_rot(a_pos: Vector2) -> Vector2:
	var t_pos: Vector2
	match composition.down:
		Vector2i.DOWN:	# Default orientation
			t_pos = a_pos
		Vector2i.LEFT:
			t_pos = Vector2(a_pos.y, -a_pos.x)
		Vector2i.UP:
			t_pos = Vector2(-a_pos.x, -a_pos.y)
		Vector2i.RIGHT:
			t_pos = Vector2(-a_pos.y, a_pos.x)
		_:
			t_pos = Vector2.ZERO
	return t_pos
			


func board_rotation_to_vector(a_rot: int) -> Vector2:
	var t_rot: int = a_rot % 4
	if t_rot < 0:
		t_rot = (t_rot + 4) % 4
	# The above code translates any a_rot to be in the interval [0, 3]
	match t_rot:
		0:
			return Vector2i.DOWN
		1:
			return Vector2i.DOWN
		2:
			return Vector2i.DOWN
		3:
			return Vector2i.DOWN
		_:
			return Vector2i.DOWN


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
	#var t_comp: Composition = Composition._init_with_linear(size, random_linear_data(size * size))
	var t_comp: Composition = Composition._init_from_level_data(level_data)
	#place_stone(Vector2i(2, 2), t_comp)
	#place_stone(Vector2i(3, 0), t_comp)
	#place_stone(Vector2i(3, 5), t_comp)
	#place_hole(Vector2i(0, 2), t_comp)
	#place_stone(Vector2i(0, 1), t_comp)
	# With size 7 this crashes when down = RIGHT
	#place_hole(Vector2i(0, 0), t_comp)
	#place_hole(Vector2i(4, 3), t_comp)
	#place_hole(Vector2i(3, 0), t_comp)
	#place_hole(Vector2i(3, 1), t_comp)
	#place_hole(Vector2i(3, 2), t_comp)
	#place_stone(Vector2i(3, 3), t_comp)
	#place_hole(Vector2i(3, 4), t_comp)
	#place_hole(Vector2i(3, 5), t_comp)
	#place_hole(Vector2i(3, 6), t_comp)
	#place_hole(Vector2i(1, 0), t_comp)
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
		#var t_piece = GamePiece.init_random()
		var t_piece = next_piece()
		t_data.append(t_piece)
	return t_data


func next_piece() -> GamePiece:
	return GamePiece.new(piece_rng.randi() % 5, piece_rng.randi() % 2)

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
	#var t_width: float = %BoardSubViewport.size.x
	var t_width: float = %TopUIContainer.size.x
	#var t_length: float = minf(get_viewport().size.x, get_viewport().size.y)
	var t_board_width: int = board.size.x * Constants.SQUARE_WIDTH
	board_camera.zoom = Vector2(t_width / t_board_width, t_width / t_board_width)
	#board_camera.zoom = Vector2.ONE
	var t_zoom: float =  t_width / t_board_width
	board_camera.zoom = Vector2(t_zoom, t_zoom)
	#board_camera.offset = Vector2(t_width, t_width)
	pass


func on_move_animation_finished(a_move: Move):
	if a_move == null or a_move.taken_piece == null:
		return
	toss_taken_piece(a_move)


func toss_taken_piece(a_move: Move):
	var t_square: Square = board.squares.at(a_move.end)
	#var t_pos: Vector2 = t_square.position + board.position +  Vector2(0, 0.125 * Constants.SQUARE_WIDTH)
	#t_pos = transformed_pos_from_board_rot(t_pos)
	#t_pos = t_pos * board_camera.zoom
	#t_pos = Vector2(t_pos.x, t_pos.y - p_container.position.y)
	var t_toss_piece: PhysicsPiece = physics_piece_prefab.instantiate()
	#t_toss_piece.position = t_pos
	
	t_toss_piece.position = global_pos_from_board_pos(t_square.position)
	add_child(t_toss_piece)
	t_toss_piece.sprite.texture = Textures.piece_texture(a_move.taken_piece.type, a_move.taken_piece.color)
	t_toss_piece.sprite.scale = board_camera.zoom * 0.85	# 0.85 is to match Square scaling


# Note this does not return the actual global value, but the value relative to the board viewport container
func global_pos_from_board_pos(a_pos: Vector2) -> Vector2:
	var t_pos: Vector2 = a_pos + board.position +  Vector2(0, 0.125 * Constants.SQUARE_WIDTH)
	t_pos = transformed_pos_from_board_rot(t_pos)
	t_pos = t_pos * board_camera.zoom
	t_pos = Vector2(t_pos.x, t_pos.y - p_container.position.y)
	return t_pos

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
			composition.most_recent_player_move = t_move
			do_move(t_move)
		else:
			composition.selected_square = null
	elif composition.is_selectable_coord(t_coords):
		composition.selected_square = composition.square_at(t_coords)
		board.display_selected_marker(a_square, true)
		board.display_valid_highlights(composition.valid_moveset(composition.square_at(t_coords)))


# Move a single piece (usually moved by player)
func do_move(a_move: Move):
	increment_turn_index()
	score_multi = maxi(1, score_multi - 1)		# Player move reduces multiplier
	composition.do_move(a_move)		# Happens in one frame
	board.animate_move(a_move, composition.down)		# Takes MOVE_DURATION seconds
	await get_tree().create_timer(Constants.MOVE_DURATION).timeout
	do_matches()


# Find matches, remove from composition, animate (calculate score?)
func do_matches():
	var t_matches: Array[Array] = matched_sets()
	update_multipliers(t_matches)
	if not t_matches.is_empty():
		composition.remove_matched_sets(t_matches)
		update_score_from_matches(t_matches)
		board.animate_matches(t_matches)
		await get_tree().create_timer(Constants.MATCH_DURATION).timeout
	do_slide()


func update_multipliers(a_matches: Array[Array]):
	for i_set: Array[Vector2i] in a_matches:
		if i_set.size() <= 3: continue
		var t_coord: Vector2i = upper_left_item(i_set)
		var t_piece: GamePiece = composition.piece_at(t_coord)
		t_piece.multiplier += i_set.size() - 0
		pass

func upper_left_item(a_set: Array[Vector2i]) -> Vector2i:
	var t_lefts: Array[Vector2i] = []	# All vectors which are most left
	var t_leftest: Vector2i = a_set[0]
	var t_upest: Vector2i
	for i_coord: Vector2i in a_set:		# Find leftmost x-coord
		if i_coord.x <= t_leftest.x:
			t_leftest = i_coord
	for i_coord: Vector2i in a_set:		# Find all coords with leftmost x-coord
		if i_coord.x == t_leftest.x:
			t_lefts.append(i_coord)
	t_upest = t_lefts[0]
	for i_coord: Vector2i in a_set:
		if i_coord.y <= t_upest.y:
			t_upest = i_coord
	return t_upest
	




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
		board.animate_slide(t_moveset, composition.down)
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
	var t_start: Vector2i = a_coord + composition.size * t_down
	return Move.new(t_start, a_coord, Lists.MOVE_TYPE.FILL, t_piece, null)

# As it says
func update_score_from_matches(a_matches: Array[Array]):
	var t_count: int = 0
	for i_set: Array[Vector2i] in a_matches:
		var t_points: int = score_by_match_size(i_set.size())
		t_points *= score_multi
		score += t_points
		counter.display_points(t_points)
		display_floating_points(i_set, t_points)
		t_count += i_set.size() - 1
	score_multi += t_count
	score_data[loaded_level_index] = max(score_data[loaded_level_index], score)
	save_score_data()
	display_high_score(score_data[loaded_level_index])
# TODO: Incorporate piece.multiplier


func display_floating_points(a_set: Array[Vector2i], a_points: int):
	var t_pos: Vector2 = global_pos_from_board_pos(group_center_local_pos(a_set))
	var t_label: ScoreLabel = ScoreLabel.new()
	add_child(t_label)
	t_label.initialize(t_pos, a_points)


# Center coords for a set of coords; note output coords need not be int pair
func group_center_local_pos(a_set: Array[Vector2i]) -> Vector2:
	var t_xs: float
	var t_ys: float
	for i_coord: Vector2i in a_set:
		var t_square: Square = board.squares.at(i_coord) 
		t_xs += t_square.position.x
		t_ys += t_square.position.y
	var t_center: Vector2 = Vector2(t_xs, t_ys) / (a_set.size() as float)
	return t_center


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


# Sets direction of gravity
# Note this is not for regualr piece movement but for flying depris / pieces
func set_gravity_dir(a_dir: Vector2):
	PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, a_dir)
