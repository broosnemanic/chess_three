class_name BBUtil

## Static class for conveniently converting strings into bbcode

static func at_color(a_string: String, a_color_name: String) -> String:
	return "[color=" + a_color_name + "]" + a_string + "[/color]"


static func at_bgcolor(a_string: String, a_color_name: String) -> String:
	return "[bgcolor=" + a_color_name + "]" + a_string + "[/bgcolor]"


static func at_size(a_string: String, a_font_size: int) -> String:
	return "[font_size=" + str(a_font_size) + "]" + a_string + "[/font_size]"


static func at_centered(a_string: String) -> String:
	return "[center]" + a_string + "[/center]"
