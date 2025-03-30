extends RichTextLabel
class_name ScoreLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2(10, 10)
	bbcode_enabled = true
	add_theme_font_size_override("bold_font_size", 236)


# Types: 0 = take; 1 = match; 2 = scorebar; 3 = nerfaplierbar
func initialize(a_start_pos: Vector2, a_score: int):
	clip_contents = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	text = message(a_score)
	text = "[outline_color=black]" + text + "[/outline_color]"	
	text = "[outline_size=1]" + text + "[/outline_size]"	
	position = a_start_pos
	var end_pos: Vector2 = a_start_pos - 300 * Vector2(0.0, 1.0)
	var tween_pos = get_tree().create_tween()
	tween_pos.tween_property(self, 'position', end_pos, 1.5)
	scale = Vector2(0.1, 0.1)
	var tween_scale = get_tree().create_tween()
	tween_scale.tween_property(self, 'scale', Vector2(1.0, 1.0), 1.5)
	var tween_opacity = get_tree().create_tween()
	tween_opacity.tween_property(self, 'modulate', Color(1.0, 1.0, 1.0, 0.0), 1.5)
	tween_opacity.finished.connect(queue_free)


func message(a_score: int) -> String:
	var t_color_index: int = randi_range(0, 3)
	match t_color_index:
		0:
			return "[b][color=orange]" + str(a_score) + "[/color][/b]"
		1:
			return "[b][color=red]" + str(a_score) + "[/color][/b]"
		2:
			return "[b][color=teal]" + str(a_score) + "[/color][/b]"
		3:
			return "[b][color=purple]" + str(a_score) + "[/color][/b]"
	return "Error"
