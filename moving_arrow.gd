extends Path2D

@export var initial_point: Vector2i = Vector2i(400, 600)


func _ready():
	curve = curve.duplicate()
	curve.add_point(initial_point)
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	curve.add_point(mouse_pos)
	#curve.set_point_in(1, Vector2(-200, -25))

func _process(delta):
	$Line2D.points = []
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	curve.set_point_position(1, mouse_pos)
	for point in curve.get_baked_points():
		$Line2D.add_point(point)
	$Line2D/Sprite2D.global_position = $Line2D.points[-1]

	$Line2D/Sprite2D.global_rotation = head_rotation(initial_point, mouse_pos)


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
