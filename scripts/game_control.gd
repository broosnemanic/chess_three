extends Node

## Object for coordination between other game objects
## Relay for signals between abstract game and display

@onready var board: Node2D = %Board
@onready var board_camera: Camera2D = %BoardCamera
@onready var p_container: PanelContainer = %ViewportPanelContainer
@onready var m_container: MarginContainer = %BoardMarginContainer
@onready var top_container: PanelContainer = %TopPanelContainer
@onready var multi_display: RichTextLabel = %MultiDisplay
@onready var counter: ScrollingCounter = %ScrollingCounter
@onready var high_score_label: RichTextLabel = %HighScoreLabel
@onready var rotate_cw_button: TextureButton = %CWButton
@onready var rotate_ccw_button: TextureButton = %CCWButton
@onready var score_progressbar: ProgressBar = %ScoreProgressBar
@onready var turns_progressbar: ProgressBar = %TurnsProgressBar
@onready var star00: TextureRect = %Star00
@onready var star01: TextureRect = %Star01
@onready var star02: TextureRect = %Star02
@onready var star_scroll_container: ScrollContainer = %StarScrollContainer
@onready var physics_piece_prefab = preload("res://scenes/physics_piece.tscn")
@onready var popup_prefab = preload("res://scenes/popup_message.tscn")
@onready var message_box_prefab = preload("res://scenes/meassge_box.tscn")
@onready var filled_star: Resource = preload("res://textures/UI/filled_star_sm.png")
@onready var unfilled_star: Resource = preload("res://textures/UI/unfilled_star_sm.png")

@onready var level_data: LevelData = preload("res://levels/level_data_01.tres")

var piece_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var composition: Composition		# Abstract representation of a game
var match_finder: MatchFinder
var board_rotation: int = 0			# [0, 1, 2, or 3] 0 == up; then clockwise by 90 deg (PI/2 rad)
var size: int						# Size of one side of board
var score: int						# As it says
const TEST_SIZE: int = 10			# Keep board square; dif ratios can be faked using blocked off squares

var score_data: Dictionary = {0:0, 1:0, 2:0}
var default_score_data: Dictionary = {0:0}
var save_path = "user://score_date.save"
var turn_index: int					# What turn are we on for the current level?
var loaded_level_index: int
var high_score: int					# Last high score for loaded level
var message_box: PanelContainer
var multi_moves: Array[Move]		# List of moves that result in a multi_move
									# E.g. multi_gem takes, is taken, or participates in a match
var score_milestones: Dictionary[Lists.POINT_MILESTONE, bool] = {}



func _ready():
	counter.is_rate_by_chunk = true
	counter.chunk_rate = 1.0
	message_box = message_box_prefab.instantiate()
	%MessageBoxContainer.add_child(message_box)
	rotate_cw_button.button_up.connect(rotate_board.bind(false))
	rotate_ccw_button.button_up.connect(rotate_board.bind(true))
	set_level(1)
	#%StarScrollContainer.set_deferred("scroll_vertical", 84)


func load_level(a_level_data: LevelData):
	level_data = a_level_data
	composition = Composition._init_from_level_data(level_data)
	match_finder = MatchFinder.new(composition)
	turn_index = 0
	board_rotation = 0
	board_camera.rotation = 0.0
	setup_board()
	slide(composition, composition.down)
	load_score_data()
	display_high_score(high_score)
	update_turns_left_label()
	setup_progressbars()
	for i_key: Lists.POINT_MILESTONE in Lists.POINT_MILESTONE.values():
		score_milestones[i_key] = false


func setup_progressbars():
	score_progressbar.max_value = level_data.min_point_goal
	score_progressbar.value_changed.connect(on_point_milestone)
	turns_progressbar.max_value = level_data.turn_count_max
	turns_progressbar.value = turns_progressbar.max_value
	var t_style: StyleBoxFlat = StyleBoxFlat.new()
	t_style.bg_color = Constants.TURNS_BAR_START_COLOR
	turns_progressbar.add_theme_stylebox_override("fill", t_style)


func on_point_milestone(_a_points: int):
	if score_progressbar.value < score_progressbar.max_value : return
	var t_container: PanelContainer = score_progressbar.get_parent()
	if not score_milestones[Lists.POINT_MILESTONE.PAR] and is_in_milestone_range(Lists.POINT_MILESTONE.PAR):
		var t_height: float = star_scroll_container.get_child(0).size.y - star_scroll_container.size.y
		score_milestones[Lists.POINT_MILESTONE.PAR] = true
		var t_tween: Tween = get_tree().create_tween()
		t_tween.tween_property(star_scroll_container, "scroll_vertical", t_height, 1.0)
		await get_tree().create_timer(0.5).timeout
		t_tween = get_tree().create_tween()
		t_tween.tween_property(score_progressbar, "max_value", 2 * level_data.min_point_goal, 1.0)
		t_tween = get_tree().create_tween()
		t_tween.tween_property(t_container, "size_flags_stretch_ratio", 0.85, 1.0)

	elif not score_milestones[Lists.POINT_MILESTONE.ONE_STAR] and is_in_milestone_range(Lists.POINT_MILESTONE.ONE_STAR):
		score_milestones[Lists.POINT_MILESTONE.ONE_STAR] = true
		await get_tree().create_timer(1.5).timeout
		var t_tween: Tween = get_tree().create_tween()
		t_tween.tween_property(score_progressbar, "max_value", 3 * level_data.min_point_goal, 1.0)
		t_tween = get_tree().create_tween()
		t_tween.tween_method(modulate_texture_rect.bind(star00), 0.0, 1.0, 1.0)
		t_tween = get_tree().create_tween()
		t_tween.tween_property(t_container, "size_flags_stretch_ratio", 0.70, 1.0)
	elif not score_milestones[Lists.POINT_MILESTONE.TWO_STAR] and is_in_milestone_range(Lists.POINT_MILESTONE.TWO_STAR):
		score_milestones[Lists.POINT_MILESTONE.TWO_STAR] = true
		await get_tree().create_timer(1.5).timeout
		var t_tween: Tween = get_tree().create_tween()
		t_tween.tween_property(score_progressbar, "max_value", 4 * level_data.min_point_goal, 1.0)
		t_tween = get_tree().create_tween()
		t_tween.tween_method(modulate_texture_rect.bind(star01), 0.0, 1.0, 1.0)
		#var t_container: PanelContainer = score_progressbar.get_parent()
		t_tween = get_tree().create_tween()
		t_tween.tween_property(t_container, "size_flags_stretch_ratio", 0.55, 1.0)
	elif not score_milestones[Lists.POINT_MILESTONE.THREE_STAR] and is_in_milestone_range(Lists.POINT_MILESTONE.THREE_STAR):
		score_milestones[Lists.POINT_MILESTONE.THREE_STAR] = true
		await get_tree().create_timer(1.5).timeout
		var t_tween: Tween = get_tree().create_tween()
		t_tween.tween_property(score_progressbar, "max_value", 4 * level_data.min_point_goal, 1.0)
		t_tween = get_tree().create_tween()
		t_tween.tween_method(modulate_texture_rect.bind(star02), 0.0, 1.0, 1.0)



func is_in_milestone_range(a_milestone: Lists.POINT_MILESTONE) -> bool:
	var t_next: Lists.POINT_MILESTONE
	var t_milestone: Lists.POINT_MILESTONE
	var t_min: int = level_data.min_point_goal
	match a_milestone:
		Lists.POINT_MILESTONE.PAR:
			t_next = Lists.POINT_MILESTONE.ONE_STAR
			t_milestone = Lists.POINT_MILESTONE.PAR
			return score >= Lists.STAR_FACTORS[t_milestone] * t_min and score < Lists.STAR_FACTORS[t_next] * t_min
		Lists.POINT_MILESTONE.ONE_STAR:
			t_next = Lists.POINT_MILESTONE.TWO_STAR
			t_milestone = Lists.POINT_MILESTONE.ONE_STAR
			return score >= Lists.STAR_FACTORS[t_milestone] * t_min and score < Lists.STAR_FACTORS[t_next] * t_min
		Lists.POINT_MILESTONE.TWO_STAR:
			t_next = Lists.POINT_MILESTONE.THREE_STAR
			t_milestone = Lists.POINT_MILESTONE.TWO_STAR
			return score >= Lists.STAR_FACTORS[t_milestone] * t_min and score < Lists.STAR_FACTORS[t_next] * t_min
		Lists.POINT_MILESTONE.THREE_STAR:
			t_milestone = Lists.POINT_MILESTONE.THREE_STAR
			return score >= Lists.STAR_FACTORS[t_milestone] * t_min
	return false


	
func modulate_texture_rect(a_alpha: float, a_texture: TextureRect):
	a_texture.modulate = Color(1.0, 1.0, 1.0, a_alpha)

func setup_board():
	#position_viewport()
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


func reset_high_scores():
	for i_key: int in score_data.keys():
		score_data[i_key] = 0
	var save = FileAccess.open(save_path, FileAccess.WRITE)
	save.store_var(score_data)
	save.flush()


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
	var t_width: float = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.9
	var t_height: float = ProjectSettings.get_setting("display/window/size/viewport_height") * 0.9
	var t_size: Vector2 = Vector2(t_width, t_width)
	t_height = (t_height / 2.0) - t_width
	top_container.size = Vector2(t_width, t_width)
	top_container.position = Vector2(- t_width / 2.0, t_height)
	#%BoardSubViewport.size = t_size


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
		if event.keycode == KEY_X:
			reset_high_scores()


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
	animate_turn_index_increment()
	if turn_index >= level_data.turn_count_max:
		on_lose()



func animate_turn_index_increment():
	var t_tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var t_value: float = (level_data.turn_count_max - turn_index) as float
	t_tween.tween_property(turns_progressbar, "value", t_value - 0.2, Constants.DOWN_BOUNCE_DURATION)
	t_tween.finished.connect(turn_progress_bar_up_bounce)
	turn_progress_bar_animate_color()



func turn_progress_bar_up_bounce():
	var t_tween: Tween = get_tree().create_tween()
	var t_value: float = (level_data.turn_count_max - turn_index) as float
	t_tween.tween_property(turns_progressbar, "value", t_value, Constants.UP_BOUNCE_DURATION)


func turn_progress_bar_animate_color():
	var t_tween: Tween = get_tree().create_tween()
	var t_progress: float = turn_index as float / level_data.turn_count_max as float
	var t_start: Color = turns_progressbar.get_theme_stylebox("fill").bg_color
	var t_color: Color
	var t_lerp: float
	var t_end: Color
	if t_progress <= 0.5:
		t_color = Constants.TURNS_BAR_MID_COLOR
		t_lerp = 2.0 * t_progress
		t_end = Constants.TURNS_BAR_START_COLOR.lerp(t_color, t_lerp)
	else:
		t_color = Constants.TURNS_BAR_END_COLOR
		t_lerp = 2.0 * (t_progress - 0.5)
		t_end = Constants.TURNS_BAR_MID_COLOR.lerp(t_color, t_lerp)
	t_tween.tween_method(turn_progress_bar_update_color, t_start, t_end, Constants.DOWN_BOUNCE_DURATION)
	
	

func turn_progress_bar_update_color(a_color: Color):
	var t_style: StyleBoxFlat = StyleBoxFlat.new()
	t_style.bg_color = a_color
	turns_progressbar.add_theme_stylebox_override("fill", t_style)


func is_win_condition_met() -> bool:
	return true
	

func on_win():
	pass


func on_lose():
	pass
	message_box.set_message("Out of Moves :(")


func update_turns_left_label():
	#var t_text: String = str(level_data.turn_count_max - turn_index)
	var t_text: String = BBString.new(str(level_data.turn_count_max - turn_index)).center().b.size(24).color("dark gray").string
	#t_text = BBUtil.at_size(t_text, 24)
	#t_text = BBUtil.at_color(t_text, "green")
	#t_text = BBUtil.at_centered(t_text)
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
		var t_piece = next_piece()
		t_data.append(t_piece)
	return t_data


func next_piece() -> GamePiece:
	return GamePiece.new(piece_rng.randi() % 5, piece_rng.randi() % 2)


# Note board_camera is a child of a subviewport - we want to center it within the viewport
func reset_camera():
	await get_tree().process_frame					# HACK: wait a frame for UI to resize cascade
	var t_width: float = %BoardSubViewport.size.x
	var t_board_width: int = board.size.x * Constants.SQUARE_WIDTH
	board_camera.zoom = Vector2(t_width / t_board_width, t_width / t_board_width)
	var t_zoom: float =  t_width / t_board_width
	board_camera.zoom = Vector2(t_zoom, t_zoom)


func on_move_animation_finished(a_move: Move):
	if a_move == null or a_move.taken_piece == null:
		return
	toss_taken_piece(a_move)


func toss_taken_piece(a_move: Move):
	var t_square: Square = board.squares.at(a_move.end)
	var t_toss_piece: PhysicsPiece = physics_piece_prefab.instantiate()
	t_toss_piece.position = global_pos_from_board_pos(t_square.position)
	add_child(t_toss_piece)
	t_toss_piece.sprite.texture = Textures.piece_texture(a_move.taken_piece.type, a_move.taken_piece.color)
	modulate_piece_by_color(t_toss_piece.sprite, a_move.taken_piece.color)
	t_toss_piece.sprite.scale = board_camera.zoom * 0.85	# 0.85 is to match Square scaling


# HACK: code duplicated from Square
func modulate_piece_by_color(a_piece: Sprite2D, a_color: Lists.COLOR):
	match a_color:
		Lists.COLOR.WHITE:
			a_piece.modulate = Color.BEIGE
		Lists.COLOR.BLACK:
			a_piece.modulate = Color.CRIMSON
		_:
			a_piece.modulate = Color.WHITE



# Note this does not return the actual global value, but the value relative to the board viewport container
func global_pos_from_board_pos(a_pos: Vector2) -> Vector2:
	var t_pos: Vector2 = a_pos + board.position +  Vector2(0, 0.125 * Constants.SQUARE_WIDTH)
	t_pos = transformed_pos_from_board_rot(t_pos)
	t_pos = t_pos * board_camera.zoom
	t_pos = Vector2(t_pos.x, t_pos.y - top_container.position.y)
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
	composition.do_move(a_move)		# Happens in one frame
	board.animate_move(a_move, composition.down)		# Takes MOVE_DURATION seconds
	await get_tree().create_timer(Constants.MOVE_DURATION).timeout
	process_take_score(a_move)
	if a_move.is_take:
		if a_move.piece.multiplier > 1 or (a_move.taken_piece != null and a_move.taken_piece.multiplier > 1):
			store_multi_move(a_move)
		remove_multi(a_move)
	do_multi_moves()
	do_matches()



func remove_multi(a_move: Move):
	if a_move.piece.multiplier > 0:
		a_move.piece.multiplier = 0
		board.squares.at(a_move.start).remove_multi_effect(0.0)
		board.squares.at(a_move.end).remove_multi_effect(0.5)



func process_take_score(a_move: Move):
	var t_points: int = take_score(a_move)
	score += t_points
	add_score(t_points)
	#counter.display_points(t_points)
	display_floating_points([a_move.end], t_points, a_move.piece.multiplier)
	display_points_particles([a_move.end], t_points)


func add_score(a_score: int):
	counter.display_points(a_score)
	var t_tween: Tween = get_tree().create_tween()
	t_tween.tween_property(score_progressbar, "value", score_progressbar.value + a_score, 0.5)



func take_score(a_move: Move) -> int:
	return piece_score_multi(a_move.piece) * maxi(a_move.piece.multiplier, 1)



# Find matches, remove from composition, animate (calculate score?)
func do_matches():
	var t_matches: Array[Array] = matched_sets()
	if not t_matches.is_empty():
		store_multi_moves_from_matches(t_matches)
		update_multipliers(t_matches)
		update_score_from_matches(t_matches)
		composition.remove_matched_sets(t_matches)
		board.animate_matches(t_matches)
		do_multi_moves()
		await get_tree().create_timer(Constants.MATCH_DURATION).timeout
	do_slide()



func store_multi_moves_from_matches(a_matches: Array[Array]):
	var t_flat: Array[Vector2i] = []
	for i_set: Array[Vector2i] in a_matches:
		t_flat.append_array(i_set)
	for i_coord: Vector2i in t_flat:
		var t_piece: GamePiece = composition.piece_at(i_coord)
		if t_piece.multiplier > 1:
			t_piece = GamePiece.init_from_piece(t_piece)
			var t_move: Move = Move.new(i_coord, i_coord, Lists.MOVE_TYPE.MATCH, t_piece, null)
			multi_moves.append(t_move)



func do_multi_moves():
	print_rich("do_multi_moves called " + str(multi_moves.size()))
	var t_move: Move = multi_moves.pop_front()
	if t_move != null:
		do_multi_move(t_move)
	# Iterate through array of multi_moves and effect them
	# set array of multi_moves = temp array multimoves (holds new multimoves triggered by this round of multimoves)
	# if array of multi_moves is not empty -> do_multi_moves()


func do_multi_move(a_move: Move):
	#var t_masks: Array[Vector2i] = multi_move_masks(a_move)
	var t_masks: Array[Vector2i] = composition.multi_move_targets(a_move.piece.type, a_move.end, a_move.piece.multiplier)
	t_masks = rotated_vector_set(t_masks)
	for i_mask: Vector2i in t_masks:
		var t_move: Move = Move.init_from_move(a_move)
		#var t_coord: Vector2i = t_move.end + i_mask
		var t_coord: Vector2i = i_mask
		var t_taken: GamePiece = composition.piece_at(t_coord)
		if t_taken == null: continue
		t_move.end = t_coord
		t_move.taken_piece = t_taken
		do_multi_move_singlet(t_move)



# Multi_move results in removal of multiple pieces - this removes one
func do_multi_move_singlet(a_move: Move):
	composition.remove_piece_at(a_move.end)
	board.squares.at(a_move.end).piece.texture = null
	board.squares.at(a_move.end).show_brief_emphasis()
	toss_taken_piece(a_move)


# Returns set of offsets for a given piece/multi multi_move
func multi_move_masks(a_move: Move) -> Array[Vector2i]:
	var t_piece: GamePiece = a_move.piece
	var t_set: Array[Vector2i] = []
	match t_piece.type:
		Lists.PIECE_TYPE.PAWN:
			t_set = [Vector2i(-1, -1), 
					Vector2i(1, -1)]
		Lists.PIECE_TYPE.ROOK:
			t_set = [Vector2i(0, 1), 
					Vector2i(0, -1), 
					Vector2i(1, 0), 
					Vector2i(-1, 0)]
		Lists.PIECE_TYPE.KNIGHT:
			t_set = [Vector2i(-1, -1), 
					Vector2i(1, -1)]
		Lists.PIECE_TYPE.PAWN:
			t_set = [Vector2i(-1, -1), 
					Vector2i(1, -1)]
		Lists.PIECE_TYPE.PAWN:
			t_set = [Vector2i(-1, -1), 
					Vector2i(1, -1)]
		Lists.PIECE_TYPE.PAWN:
			t_set = [Vector2i(-1, -1), 
					Vector2i(1, -1)]
		_:
			t_set = [Vector2i(0, -1)]
	return rotated_vector_set(t_set)



func rotated_vector(a_vector: Vector2i, a_direction: Vector2i) -> Vector2i:
	match a_direction:
		Vector2i.DOWN:	# Default gravity direction
			return a_vector
		Vector2i.UP:
			return Vector2i(a_vector.x, -1 * a_vector.y)
		Vector2i.LEFT:
			return Vector2i(-1 * a_vector.y, a_vector.x)
		Vector2i.RIGHT:
			return Vector2i(a_vector.y, a_vector.x)
	return Vector2i.ZERO



func rotated_vector_set(a_set: Array[Vector2i]) -> Array[Vector2i]:
	var t_set: Array[Vector2i] = []
	for i_vector: Vector2i in a_set:
		t_set.append(rotated_vector(i_vector, composition.down))
	return t_set


# Preserve data associated with move and add it to the multi_move stack
func store_multi_move(a_move: Move):
	var t_piece: GamePiece = GamePiece.init_from_piece(a_move.piece)
	var t_taken: GamePiece = GamePiece.init_from_piece(a_move.taken_piece)
	var t_move: Move = Move.new(a_move.start, a_move.end, a_move.type_from_bools(), t_piece, t_taken)
	multi_moves.append(t_move)



func update_multipliers(a_matches: Array[Array]):
	for i_set: Array[Vector2i] in a_matches:
		if i_set.size() <= 3: continue
		var t_coord: Vector2i = upper_left_item(i_set)
		var t_piece: GamePiece = composition.piece_at(t_coord)
		t_piece.multiplier += i_set.size() - 2
		#board.squares.at(t_coord).add_multi_effect(t_piece.multiplier, t_piece.type)
		
		t_piece.is_do_not_remove = true		# When matched sets are removed we want to skip


# Of all leftmost coords, which is also highest?
# Used to deterministically decide which of a matched set to make a multi piece
# TODO: make relative to currnet down direction
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
		board.refresh_pieces()
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


# Generate a move for animation purposes to show new piece entering board
# Note composition.fill() is already run so new pieces are at their end position
func fill_move_from_coord(a_coord: Vector2i) -> Move:
	var t_down: Vector2i = composition.down
	var t_piece: GamePiece = composition.piece_at(a_coord)
	var t_start: Vector2i = a_coord + composition.size * t_down
	return Move.new(t_start, a_coord, Lists.MOVE_TYPE.FILL, t_piece, null)


# As it says
func update_score_from_matches(a_matches: Array[Array]):
	for i_set: Array[Vector2i] in a_matches:
		var t_points: int = score_by_match_size(i_set.size())
		var t_multi: int = piece_score_multi(composition.piece_at(i_set[0]))
		t_points *= t_multi
		score += t_points
		#counter.display_points(t_points)
		add_score(t_points)
		display_floating_points(i_set, t_points, t_multi)
		display_points_particles(i_set, t_points)
	score_data[loaded_level_index] = max(score_data[loaded_level_index], score)
	save_score_data()
	display_high_score(score_data[loaded_level_index])
# TODO: Incorporate piece.multiplier


# Roughly based on the inverse of the numberr of squares a piece could reach in one move
func piece_score_multi(a_game_piece: GamePiece) -> int:
	match a_game_piece.type:
		Lists.PIECE_TYPE.PAWN:
			return 16
		Lists.PIECE_TYPE.ROOK:
			return 2
		Lists.PIECE_TYPE.KNIGHT:
			return 8
		Lists.PIECE_TYPE.BISHOP:
			return 2
		Lists.PIECE_TYPE.KING:
			return 4
		Lists.PIECE_TYPE.QUEEN:
			return 1
		_:
			return 0



func display_floating_points(a_set: Array[Vector2i], a_points: int, a_multi: int):
	var t_pos: Vector2 = global_pos_from_board_pos(group_center_local_pos(a_set))
	var t_label: ScoreLabel = ScoreLabel.new()
	add_child(t_label)
	t_label.initialize(t_pos, a_points, a_multi)



func display_points_particles(a_set: Array[Vector2i], a_points: int):
	var t_coord: Vector2i = center_coord(a_set)
	var t_square: Square = board.squares.at(t_coord)
	t_square.emit_score_particles(a_points)


# Center coords for a set of coords; note output coords need not be int pair
func group_center_local_pos(a_set: Array[Vector2i]) -> Vector2:
	var t_xs: float = 0.0
	var t_ys: float = 0.0
	for i_coord: Vector2i in a_set:
		var t_square: Square = board.squares.at(i_coord) 
		t_xs += t_square.position.x
		t_ys += t_square.position.y
	var t_center: Vector2 = Vector2(t_xs, t_ys) / (a_set.size() as float)
	return t_center


# Of <a_set> which coords are best fit for center
func center_coord(a_set: Array[Vector2i]) -> Vector2i:
	var t_coord: Vector2i = a_set[0]
	var t_distance: int = _distance_score(a_set[0], a_set)
	for i_coord: Vector2i in a_set:
		if _distance_score(i_coord, a_set) < t_distance:
			t_coord = i_coord
	return t_coord


# Distance metric between on coord and a set of coords
func _distance_score(a_coord: Vector2i, a_set: Array[Vector2i]) -> int:
	var t_total: int = 0
	for i_coord: Vector2i in a_set:
		var t_dif = i_coord - a_coord 
		t_total += t_dif.x + t_dif.y
	return absi(t_total)


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
# Note this is not for regualr piece movement but for flying debris / pieces
func set_gravity_dir(a_dir: Vector2):
	PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, a_dir)
