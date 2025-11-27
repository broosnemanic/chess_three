extends Node

enum COLOR{BLACK, WHITE}
enum PIECE_TYPE{PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING , EMPTY, STONE}
enum SQUARE_TYPE{NORMAL, CLIP, HOLE, STONE, ICE}
enum MOVE_TYPE{TAKE, MATCH, SLIDE, FILL}
enum LEVEL_TYPE{POINTS, THREE_KINGS}
enum POINT_MILESTONE{PAR, ONE_STAR, TWO_STAR, THREE_STAR}

const STAR_FACTORS: Dictionary[POINT_MILESTONE, float] = {	POINT_MILESTONE.PAR : 1.0,
															POINT_MILESTONE.ONE_STAR : 2.0,
															POINT_MILESTONE.TWO_STAR : 3.0,
															POINT_MILESTONE.THREE_STAR : 4.0
															}



func random_piece_type() -> PIECE_TYPE:
	var t_index: int = randi_range(0, 5) 
	return piece_type_from_index(t_index)


func random_color() -> COLOR:
	var t_index: int = randi_range(1, COLOR.size()) - 1
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


func piece_name(a_piece_type: PIECE_TYPE) -> String:
	match a_piece_type:
		PIECE_TYPE.PAWN:
			return "pawn"
		PIECE_TYPE.ROOK:
			return "rook"
		PIECE_TYPE.KNIGHT:
			return "knight"
		PIECE_TYPE.BISHOP:
			return "bishop"
		PIECE_TYPE.QUEEN:
			return "queen"
		PIECE_TYPE.KING:
			return "king"
		_:
			return "error"


func color_from_index(a_index: int) -> COLOR:
	match a_index:
		0:
			return COLOR.BLACK
		1:
			return COLOR.WHITE
		_:
			return COLOR.BLACK
