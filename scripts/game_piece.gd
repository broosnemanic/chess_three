class_name GamePiece

## Abstract representation of an piece that can occupy a square

var type: Lists.PIECE_TYPE					# E.g. knight, stone, hole, etc
var color: Lists.COLOR						# Probably only black


func _init(a_type: Lists.PIECE_TYPE, a_color: Lists.COLOR):
	type = a_type
	color = a_color


static func init_random() -> GamePiece:
	return GamePiece.new(Lists.random_piece_type(), Lists.random_color())


func out() -> String:
	return Lists.PIECE_TYPE.find_key(type) + ":" + Lists.COLOR.find_key(color)
	pass
