class_name BBString

## Utility class that produces a string in BBCode format
## Example code: var my_string: String = BBString.new("some text").bold.italic.color("red").string
## Using func alias this becomes: BBString.new("some text").b.i.c("red").string
## Note the .string is important because BBString functions return itself, so we have to ask for the string
## A BBString can be easily reset / reused by setting its string attribute: e.g. my_bbstring.string = "my_new_string"


var string: String			# Final product
var base_string: String		# String attribute before formatting

func _init(a_string: String) -> void:
	string = a_string
	base_string = a_string


func clear_formatting() -> BBString:
	string = base_string
	return self


var bold: BBString:
	get:
			string = "[b]" + string + "[/b]"
			return self


# Short alias for bold
var b: BBString:
	get:
			string = "[b]" + string + "[/b]"
			return self


var underline: BBString:
	get:
			string = "[u]" + string + "[/u]"
			return self


# Short alias for underline
var u: BBString:
	get:
			string = "[u]" + string + "[/u]"
			return self


var italic: BBString:
	get:
			string = "[i]" + string + "[/i]"
			return self


# Short alias for italic
var i: BBString:
	get:
			string = "[i]" + string + "[/i]"
			return self


var strikethrough: BBString:
	get:
			string = "[s]" + string + "[/s]"
			return self


# Short alias for strikethrough
var s: BBString:
	get:
			string = "[s]" + string + "[/s]"
			return self


var code: BBString:
	get:
			string = "[code]" + string + "[/code]"
			return self


var fill: BBString:
	get:
			string = "[f]" + string + "[/f]"
			return self


# Short alias for fill
var f: BBString:
	get:
			string = "[f]" + string + "[/f]"
			return self


var indent: BBString:
	get:
			string = "[indent]" + string + "[/indent]"
			return self


func color(a_color_name: String) -> BBString:
	string = "[color=" + a_color_name + "]" + string + "[/color]"
	return self


# Short alias for color
func c(a_color_name: String) -> BBString:
	string = "[color=" + a_color_name + "]" + string + "[/color]"
	return self


func hint(a_hint: String) -> BBString:
	string = "[hint=" + a_hint + "]" + string + "[/hint]"
	return self


# Short alias for hint
func h(a_hint: String) -> BBString:
	string = "[hint=" + a_hint + "]" + string + "[/hint]"
	return self


func bgcolor(a_color_name: String) -> BBString:
	string = "[bgcolor=" + a_color_name + "]" + string + "[/bgcolor]"
	return self


# Short alias for bgcolor
func bg(a_color_name: String) -> BBString:
	string = "[bgcolor=" + a_color_name + "]" + string + "[/bgcolor]"
	return self


func fgcolor(a_color_name: String) -> BBString:
	string = "[fgcolor=" + a_color_name + "]" + string + "[/fgcolor]"
	return self


func outline_color(a_color_name: String) -> BBString:
	string = "[outline_color=" + a_color_name + "]" + string + "[/outline_color]"
	return self


func outline_size(a_size: int) -> BBString:
	string = "[outline_size=" + str(a_size) + "]" + string + "[/outline_size]"
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
