class_name BBString

## Utility class that produces a string in BBCode format
## Example code: var my_string: String = BBString.new("some text").bold().italic().color("red").string
## Note the .string is important because BBString functions return itself so we have to ask for the string

var string: String				# Final product

func _init(a_string: String) -> void:
	string = a_string


func bold() -> BBString:
	string = "[b]" + string + "[/b]"
	return self


func underlined() -> BBString:
	string = "[u]" + string + "[/u]"
	return self


func italic() -> BBString:
	string = "[i]" + string + "[/i]"
	return self


func strikethrough() -> BBString:
	string = "[s]" + string + "[/s]"
	return self


func code() -> BBString:
	string = "[code]" + string + "[/code]"
	return self


func fill() -> BBString:
	string = "[fill]" + string + "[/fill]"
	return self


func indent() -> BBString:
	string = "[indent]" + string + "[/indent]"
	return self


func color(a_color_name: String) -> BBString:
	string = "[color=" + a_color_name + "]" + string + "[/color]"
	return self


func hint(a_hint: String) -> BBString:
	string = "[hint=" + a_hint + "]" + string + "[/hint]"
	return self


func bgcolor(a_color_name: String) -> BBString:
	string = "[bgcolor=" + a_color_name + "]" + string + "[/bgcolor]"
	return self


func fgcolor(a_color_name: String) -> BBString:
	string = "[fgcolor=" + a_color_name + "]" + string + "[/fgcolor]"
	return self


func outline_color(a_color_name: String) -> BBString:
	string = "[outline_color=" + a_color_name + "]" + string + "[/outline_color]"
	return self


func center() -> BBString:
	string = "[center]" + string + "[/center]"
	return self


func left() -> BBString:
	string = "[left]" + string + "[/left]"
	return self


func right() -> BBString:
	string = "[right]" + string + "[/right]"
	return self


func size(a_font_size: int) -> BBString:
	string = "[font_size=" + str(a_font_size) + "]" + string + "[/font_size]"
	return self


func outline_size(a_size: int) -> BBString:
	string = "[outline_size=" + str(a_size) + "]" + string + "[/outline_size]"
	return self
