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



var multi_effect_material: ShaderMaterial = ShaderMaterial.new()
var absract_square: AbstractSquare
var score_particles: GPUParticles2D = GPUParticles2D.new()
var is_locked: bool
var is_selected: bool = false:
	set(a_is_selected):
		is_selected = a_is_selected
		selected.visible = a_is_selected
const PIECE_SCALE: Vector2 = Vector2(0.85, 0.85)


func _ready() -> void:
	ice.modulate = Color(1.0, 1.0, 1.0, 0.75)
	piece.scale = PIECE_SCALE
	add_child(score_particles)
	multi_effect_material.shader = load("res://shaders/nested_tinted_zooms_mod.gdshader")
	#multi_effect_material.shader = load("res://shaders/glitch.gdshader")
	setup_score_particles()


func add_multi_effect(a_multi: int, a_piece_type: int):
	var t_zoom: float = 2.0 + (a_multi - 2.0) / 5.0		# a_multi [2, 7] -> [2, 3]
	var t_speed: float = 0.1 + (a_multi - 2.0) / 2.0	# a_multi [2, 7] -> [0.1, 2.6]
	piece.material = multi_effect_material
	multi_effect_material.set_shader_parameter("layer_count", a_multi)
	multi_effect_material.set_shader_parameter("sample", Textures.multi_effect_texture(a_piece_type))
	multi_effect_material.set_shader_parameter("is_use_colors", false)
	multi_effect_material.set_shader_parameter("speed", t_speed)
	multi_effect_material.set_shader_parameter("modulate", piece.modulate)
	multi_effect_material.set_shader_parameter("max_zoom", t_zoom)
	multi_effect_material.set_shader_parameter("boarder_zoom", t_zoom)
	multi_effect_material.set_shader_parameter("is_only_bigger", false)
		# Shaders do not repsect Sprite2D.modulate, so we have to set in manually


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
	score_particles.process_material.alpha_curve = new_curve()


func new_curve() -> CurveTexture:
	var t_curve_texure: CurveTexture = CurveTexture.new()
	var t_curve: Curve = Curve.new()
	t_curve_texure.curve = t_curve
	t_curve.add_point(Vector2(0.0, 1.0))
	#t_curve.add_point(Vector2(0.5, 1.0))
	t_curve.add_point(Vector2(1.0, 0.0))
	return t_curve_texure


func emit_score_particles(a_score: int):
	score_particles.amount = a_score
	score_particles.emitting = true




func remove_multi_effect():
	piece.material = null


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
	modulate_piece_by_color(piece, a_piece.color)
	modulate_piece_by_type(piece, a_piece.type)
	piece.scale = PIECE_SCALE
	if a_piece.multiplier <= 0:
		remove_multi_effect()
	else:
		add_multi_effect(a_piece.multiplier, a_piece.type)


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


#func down_bounce(a_piece: Sprite2D, a_down: Vector2i, a_distance: float):
	#var down_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	#var rot_tween = get_tree().create_tween()
	#var t_rot_saved: float = a_piece.rotation
	#var t_rot: float = randf_range(-0.05, 0.05)
	##down_tween.tween_property(a_piece, 'position', Vector2(0, 2.0), Constants.DOWN_BOUNCE_DURATION)
	#down_tween.tween_property(a_piece, 'position', 10.0 * a_distance * a_down, Constants.DOWN_BOUNCE_DURATION)
	#down_tween.finished.connect(up_bounce.bind(a_piece, t_rot_saved))
	#rot_tween.tween_property(a_piece, 'rotation', t_rot + t_rot_saved, Constants.DOWN_BOUNCE_DURATION)
	
	
	
func up_bounce(a_saved_rot: float):
	var up_tween = get_tree().create_tween()#.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	up_tween.tween_property(piece, 'position', Vector2.ZERO, Constants.UP_BOUNCE_DURATION)
	var rot_tween = get_tree().create_tween()
	rot_tween.tween_property(piece, 'rotation', a_saved_rot, Constants.UP_BOUNCE_DURATION)


func show_brief_emphasis():
	var tween = get_tree().create_tween()
	tween.tween_property(background, "modulate", Color.REBECCA_PURPLE, 0.5)
	tween.tween_property(background, "modulate", Color(1, 1, 1, 1), 0.5)
