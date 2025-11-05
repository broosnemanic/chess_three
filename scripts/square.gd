extends Area2D
class_name Square

## Handles display of square and effects (e.g. multi effect, hole, etc) ##

signal square_clicked(a_square: Square)

@onready var selected: Sprite2D = $Selected
@onready var piece: Sprite2D = $Piece
@onready var multi_effect: Sprite2D = $Piece/MultiEffect
@onready var stone: Sprite2D = $Stone
@onready var ice: Sprite2D = $Ice
@onready var hole: Sprite2D = $Hole
@onready var highlight: Sprite2D = $Highlight
@onready var background: Sprite2D = $Background


var absract_square: AbstractSquare							# Data version used to build this
var score_particles: GPUParticles2D = GPUParticles2D.new()	# More score -> more shiny particles!
var is_locked: bool											# True -> unselectable
var is_selected: bool = false:
	set(a_is_selected):
		is_selected = a_is_selected
		selected.visible = a_is_selected
const PIECE_SCALE: Vector2 = Vector2(0.85, 0.85)


func _ready() -> void:
	ice.modulate = Color(1.0, 1.0, 1.0, 0.75)
	piece.scale = PIECE_SCALE
	add_child(score_particles)
	setup_score_particles()


# Adds pulsing arrows in directions that megagem will take on activation
func add_multi_effect(a_multi: int, a_piece_type: int, a_duration: float):
	if not multi_effect.visible:
		var t_mat: ShaderMaterial = multi_effect.material
		var t_angles = multi_angles(a_multi, a_piece_type)
		t_mat.set_shader_parameter("arrow_count", t_angles.size())
		t_mat.set_shader_parameter("angles", t_angles)
		set_multi_effect_visible(true)
		var t_tween = get_tree().create_tween()
		t_tween.tween_method(_set_multi_fade_parameter, 0.0, 1.0, a_duration)


# Directions that point towards target pieces on megagem activation
# TODO: incorporate a_multi
func multi_angles(_a_multi: int, a_piece_type: Lists.PIECE_TYPE) -> Array[float]:
	match a_piece_type:
		Lists.PIECE_TYPE.PAWN:
			return [-45.0, -135.0]
		Lists.PIECE_TYPE.ROOK:
			return [0.0, 90.0, 180.0, 270.0]		
		Lists.PIECE_TYPE.KNIGHT:
			return [30.0, 60.0, 120.0, 150.0, -30.0, -60.0, -120.0, -150.0]
		Lists.PIECE_TYPE.BISHOP:
			return [45.0, 225.0, -45.0, -225.0]
		Lists.PIECE_TYPE.QUEEN:
			return [0.0, 90.0, 180.0, 270.0, 45.0, 135.0, 225.0, 315.0]
		Lists.PIECE_TYPE.KING:
			return [0.0, 90.0, 180.0, 270.0, 45.0, 135.0, 225.0, 315.0]
		_:
			return [0.0, 270.0]


# As it says
func setup_score_particles():
	score_particles.emitting = false
	score_particles.one_shot = true
	score_particles.z_index = 10
	score_particles.texture = load("res://textures/star_1.png")
	score_particles.amount = 10
	score_particles.process_material = ParticleProcessMaterial.new()
	score_particles.explosiveness = 0.67
	score_particles.process_material.spread = 180.0
	score_particles.process_material.angular_velocity_max = 200
	score_particles.process_material.angular_velocity_min = -200
	score_particles.process_material.gravity = Vector3(0.0, 200.0, 0.0)
	score_particles.process_material.scale_max = 0.2
	score_particles.process_material.scale_min = 0.2
	score_particles.process_material.initial_velocity_max = 300.0
	score_particles.process_material.initial_velocity_min = 100.0
	score_particles.process_material.alpha_curve = _new_curve()


# Math for setting alpha dropoff of particles
func _new_curve() -> CurveTexture:
	var t_curve_texure: CurveTexture = CurveTexture.new()
	var t_curve: Curve = Curve.new()
	t_curve_texure.curve = t_curve
	t_curve.add_point(Vector2(0.0, 1.0))
	t_curve.add_point(Vector2(1.0, 0.0))
	return t_curve_texure


# Particle emitter will spit out a_score number of particles and then turn off
func emit_score_particles(a_score: int):
	score_particles.amount = a_score
	score_particles.emitting = true



# TODO: Do we need fade effect?
func remove_multi_effect(a_duration: float):
	pass
	if a_duration == 0.0:
		on_remove_multi_effect_finished()
		#set_multi_effect_visible(false)
	else:
		var t_tween = get_tree().create_tween()
		t_tween.tween_method(_set_multi_fade_parameter, 1.0, 0.0, 0.5)
		t_tween.finished.connect(on_remove_multi_effect_finished)


# Func for tween to ref
func _set_multi_fade_parameter(a_value: Variant):
	multi_effect.material.set_shader_parameter("fade", a_value)


func on_remove_multi_effect_finished():
	set_multi_effect_visible(false)
	_set_multi_fade_parameter(1.0)
	

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



func display_piece(a_piece: GamePiece):
	piece.texture = Textures.piece_texture(a_piece.type, a_piece.color)
	modulate_piece_by_color(piece, a_piece.color)
	modulate_piece_by_type(piece, a_piece.type)
	piece.scale = PIECE_SCALE
	
	if a_piece.multiplier <= 0 and multi_effect.visible:
		pass
		remove_multi_effect(0.0)
	if a_piece.multiplier > 0:
		var t_duration = 0.5 if a_piece.is_multi_changed else 0.0
		add_multi_effect(a_piece.multiplier, a_piece.type, t_duration)
		a_piece.is_multi_changed = false


func modulate_piece_by_color(a_piece: Sprite2D, a_color: Lists.COLOR):
	match a_color:
		Lists.COLOR.WHITE:
			a_piece.modulate = Color.BEIGE
		Lists.COLOR.BLACK:
			a_piece.modulate = Color.CRIMSON
		_:
			a_piece.modulate = Color.WHITE


func modulate_piece_by_type(a_piece: Sprite2D, a_type: Lists.PIECE_TYPE):
	var t_type_index: int = a_type as int
	var t_offset: float
	t_offset = (2.5 - t_type_index as float) / 40.0
	a_piece.modulate += Color(t_offset, t_offset, t_offset)



func set_multi_effect_visible(a_is_visible: bool):
	multi_effect.visible = a_is_visible


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



func bounce(a_magnitude: float, a_down: Vector2i):
	var down_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	#var down_tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	var rot_tween = get_tree().create_tween()
	var t_rot_saved: float = piece.rotation
	var t_rot: float = randf_range(-0.05, 0.05)
	down_tween.tween_property(piece, 'position', 10.0 * a_magnitude * a_down, Constants.DOWN_BOUNCE_DURATION)
	down_tween.finished.connect(up_bounce.bind(t_rot_saved))
	rot_tween.tween_property(piece, 'rotation', t_rot + t_rot_saved, Constants.DOWN_BOUNCE_DURATION)



func up_bounce(a_saved_rot: float):
	var up_tween = get_tree().create_tween()#.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	up_tween.tween_property(piece, 'position', Vector2.ZERO, Constants.UP_BOUNCE_DURATION)
	var rot_tween = get_tree().create_tween()
	rot_tween.tween_property(piece, 'rotation', a_saved_rot, Constants.UP_BOUNCE_DURATION)


func show_brief_emphasis():
	var tween = get_tree().create_tween()
	tween.tween_property(background, "modulate", Color.REBECCA_PURPLE, 0.5)
	tween.tween_property(background, "modulate", Color(1, 1, 1, 1), 0.5)
