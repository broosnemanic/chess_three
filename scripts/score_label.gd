extends RichTextLabel
class_name ScoreLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2(100, 100)
	bbcode_enabled = true
	add_theme_font_size_override("bold_font_size", 48)


# Types: 0 = take; 1 = match; 2 = scorebar; 3 = nerfaplierbar
func initialize(a_type: int, a_start_pos: Vector2, a_score: int):
	text = message(a_type, a_score)
	text = "[outline_color=black]" + text + "[/outline_color]"	
	text = "[outline_size=10]" + text + "[/outline_size]"	
	position = a_start_pos
	var end_pos: Vector2 = Vector2(position.x, position.y - 300.0)
	var tween_pos = get_tree().create_tween()
	tween_pos.tween_property(self, 'position', end_pos, 2.0)
	var tween_opacity = get_tree().create_tween()
	tween_opacity.tween_property(self, 'modulate', Color(1.0, 1.0, 1.0, 0.0), 2.0)
	tween_opacity.finished.connect(queue_free)


func message(a_type, a_score: int) -> String:
	match a_type:
		0:
			return "[b][color=orange]" + str(a_score) + "[/color][/b]"
		1:
			return "[b][color=red]" + str(a_score) + "[/color][/b]"
		2:
			return "[b][color=teal]" + "+" + str(a_score) + "[/color][/b]"
		3:
			return "[b][color=purple]" + str(a_score) + "X" + "[/color][/b]"
	return "Error"
