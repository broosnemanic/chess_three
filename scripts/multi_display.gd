extends RichTextLabel

@onready var multi_effect_label: RichTextLabel = %MultiEffectLabel

var font_size: int = 24
var raw_text: String

func _ready() -> void:
	multi_effect_label.modulate = Color(1.0, 1.0, 1.0, 0.0)



func display_multi(a_multi: int):
	raw_text = get_raw_text(a_multi)
	text = raw_text
	text = at_size(text, font_size)
	#text = at_outline(text, 0, "transparent")
	do_effect(a_multi)


func do_effect(a_multi: int):
	var t_text: String = raw_text
	t_text = at_color_name(t_text, "red")
	t_text = at_size(t_text, font_size)
	t_text = at_outline(t_text, 20, "red")
	multi_effect_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	multi_effect_label.text = t_text
	#var tween_scale = get_tree().create_tween()
	#tween_scale.tween_property(multi_effect_label, 'scale', Vector2(2.0, 2.0), 1.5)
	#tween_scale.finished.connect(on_effect_finished)
	var tween_opacity = get_tree().create_tween()
	tween_opacity.tween_property(multi_effect_label, 'modulate', Color(1.0, 1.0, 1.0, 0.0), 1.5)


func at_size(a_string: String, a_size: int) -> String:
	var t_size_string: String = str(a_size)
	return "[font_size=" + t_size_string + "]" + a_string + "[/font_size]"


func at_color_name(a_string: String, a_color_name: String) -> String:
	return "[color=" + a_color_name + "]" + a_string + "[/color]"


func at_outline(a_string: String, a_size: int, a_color_name: String) -> String:
	var t_string: String = "[outline_size=" + str(a_size) + "]" + a_string + "[/outline_size]"
	t_string = "[outline_color=" + a_color_name + "]" + t_string + "[/outline_color]"
	return t_string




func get_raw_text(a_multi: int) -> String:
	return str(a_multi) + "X"



func on_effect_finished():
	multi_effect_label.scale = Vector2.ONE
