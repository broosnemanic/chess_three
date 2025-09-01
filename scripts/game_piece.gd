class_name GamePiece

## Abstract representation of an piece that can occupy a square

var type: Lists.PIECE_TYPE					# E.g. knight, stone, hole, etc
var color: Lists.COLOR						# Probably only black
var multiplier: int:							# Score multi for this piece
	set(a_multi):
		multiplier = a_multi
		#print("type: " + str(type) + " color: " + str(color) + " multi: " + str(multiplier))
var  is_do_not_remove: bool = false



func _init(a_type: Lists.PIECE_TYPE, a_color: Lists.COLOR):
	type = a_type
	color = a_color


static func init_random() -> GamePiece:
	return GamePiece.new(Lists.random_piece_type(), Lists.random_color())


func out() -> String:
	return Lists.PIECE_TYPE.find_key(type) + ":" + Lists.COLOR.find_key(color)
	pass
