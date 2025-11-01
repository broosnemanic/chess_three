class_name GamePiece

## Abstract representation of an piece that can occupy a square

var type: Lists.PIECE_TYPE					# E.g. knight, stone, hole, etc
var color: Lists.COLOR						# Probably only black
var multiplier: int:							# Score multi for this piece
	set(a_multi):
		is_multi_changed = multiplier != a_multi
		multiplier = a_multi
var  is_do_not_remove: bool = false
var is_multi_changed: bool



func _init(a_type: Lists.PIECE_TYPE, a_color: Lists.COLOR):
	type = a_type
	color = a_color


# Use case: preserves state, especially multiplier for multi_move
static func init_from_piece(a_piece: GamePiece) -> GamePiece:
	var t_piece: GamePiece = GamePiece.new(a_piece.type, a_piece.color)
	t_piece.multiplier = a_piece.multiplier
	return t_piece



static func init_random() -> GamePiece:
	return GamePiece.new(Lists.random_piece_type(), Lists.random_color())


func out() -> String:
	return Lists.PIECE_TYPE.find_key(type) + ":" + Lists.COLOR.find_key(color)
