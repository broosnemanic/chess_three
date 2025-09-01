extends Path2D
class_name ArrowStrike

signal go_completed(a_self: ArrowStrike)

var end_pos: Vector2		# End point relative to self
var current_point: Vector2	# Curent pos of end of line
var duration: float
var line: Line2D
var head: Sprite2D	# Arrowhead
var is_going: bool


func _init(a_end_pos: Vector2, a_duration: float, a_head: Sprite2D, a_line: Texture2D) -> void:
	end_pos = a_end_pos
	duration = a_duration
	curve = Curve2D.new()
	curve.add_point(Vector2.ZERO)
	curve.add_point(a_end_pos)
	line = Line2D.new()
	line.texture = a_line
	add_child(line)
	head = a_head
	line.add_child(head)
	line.texture_mode = Line2D.LINE_TEXTURE_TILE


func _process(delta: float) -> void:
	if is_going:
		line.points = []
		curve.set_point_position(1, current_point)
		for point in curve.get_baked_points():
			line.add_point(point)
		head.position = line.points[-1]
		head.rotation = head_rotation(Vector2.ZERO, current_point)

func go():
	is_going = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'current_point', end_pos, duration)
	tween.finished.connect(on_go_end)



func on_go_end():
	is_going = false
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, 'modulate', Color(1.0, 1.0, 1.0, 0.0), 0.25)
	fade_tween.finished.connect(on_fade_end)


func on_fade_end():
	current_point = position
	go_completed.emit(self)


# Rotation to keep arrowhead pointin in direction of line
func head_rotation(a_start: Vector2, a_end: Vector2) -> float:
	var t_x_dist: float = 1.0 * a_end.x - a_start.x
	var t_y_dist: float = 1.0 * (a_end.y - a_start.y)
	var t_hyp: float = sqrt(pow(t_x_dist, 2.0) + pow(t_y_dist, 2.0))
	var t_rot: float = asin(abs(t_y_dist) / t_hyp)
	if t_x_dist > 0.0 and t_y_dist > 0.0:
		t_rot = t_rot
	if t_x_dist > 0.0 and t_y_dist < 0.0:
		t_rot = (2.0 * PI) - t_rot
	if t_x_dist < 0.0 and t_y_dist > 0.0:
		t_rot = PI - t_rot
	if t_x_dist < 0.0 and t_y_dist < 0.0:
		t_rot = PI + t_rot
	t_rot -= 0.5 * PI
	t_rot += PI
	return t_rot
