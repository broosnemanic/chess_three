extends Node

enum COLOR{BLACK, WHITE}
enum PIECE_TYPE{PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING , EMPTY, STONE}
enum SQUARE_TYPE{NORMAL, CLIP, HOLE, STONE}
enum MOVE_TYPE{TAKE, MATCH, SLIDE, FILL}

func random_piece_type() -> PIECE_TYPE:
	var t_index: int = randi_range(0, 5) 
	return piece_type_from_index(t_index)


func random_color() -> COLOR:
	var t_index: int = randi_range(1, COLOR.size()) - 1
	##TODO: This change is for testing
	#t_index = randi_range(1, 4)
	#if t_index == 1:
		#t_index = 0
	#else:
		#t_index = 1
	#
	#
	return color_from_index(t_index)


func piece_type_from_index(a_index: int) -> PIECE_TYPE:
	match a_index:
		0:
			return PIECE_TYPE.PAWN
		1:
			return PIECE_TYPE.ROOK
		2:
			return PIECE_TYPE.KNIGHT
		3:
			return PIECE_TYPE.BISHOP
		4:
			return PIECE_TYPE.QUEEN
		5:
			return PIECE_TYPE.KING
		6:
			return PIECE_TYPE.EMPTY
		7:
			return PIECE_TYPE.STONE
		_:
			return PIECE_TYPE.PAWN


func color_from_index(a_index: int) -> COLOR:
	match a_index:
		0:
			return COLOR.BLACK
		1:
			return COLOR.WHITE
		_:
			return COLOR.BLACK
