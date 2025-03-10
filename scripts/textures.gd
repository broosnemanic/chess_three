extends Node

const PAWN_BLACK: Texture2D = preload("res://textures/pieces/pawn_black.png")
const PAWN_WHITE: Texture2D = preload("res://textures/pieces/pawn_white.png")
const ROOK_BLACK: Texture2D = preload("res://textures/pieces/rook_black.png")
const ROOK_WHITE: Texture2D = preload("res://textures/pieces/rook_white.png")
const KNIGHT_BLACK: Texture2D = preload("res://textures/pieces/knight_black.png")
const KNIGHT_WHITE: Texture2D = preload("res://textures/pieces/knight_white.png")
const BISHOP_BLACK: Texture2D = preload("res://textures/pieces/bishop_black.png")
const BISHOP_WHITE: Texture2D = preload("res://textures/pieces/bishop_white.png")
const QUEEN_BLACK: Texture2D = preload("res://textures/pieces/queen_black.png")
const QUEEN_WHITE: Texture2D = preload("res://textures/pieces/queen_white.png")
const KING_BLACK: Texture2D = preload("res://textures/pieces/king_black.png")
const KING_WHITE: Texture2D = preload("res://textures/pieces/king_white.png")
const DARK_SQUARE: Texture2D = preload("res://textures/board/DarkTile.png")
const LIGHT_SQUARE: Texture2D = preload("res://textures/board/LightTile.png")


func square_texture(a_type: Lists.SQUARE_TYPE, a_coords: Vector2i) -> Texture2D:
	match a_type:
		Lists.SQUARE_TYPE.NORMAL:
			if is_dark_coord(a_coords):
				return Textures.DARK_SQUARE
			else:
				return Textures.LIGHT_SQUARE
		Lists.SQUARE_TYPE.STONE:
			if is_dark_coord(a_coords):
				return Textures.DARK_SQUARE
			else:
				return Textures.LIGHT_SQUARE
		_:
			return Textures.KNIGHT_BLACK


func piece_texture(a_type: Lists.PIECE_TYPE, a_color: Lists.COLOR) -> Texture2D:
	var is_black: bool = a_color == Lists.COLOR.BLACK
	match a_type:
		Lists.PIECE_TYPE.PAWN:
			if is_black:
				return PAWN_BLACK
			else:
				return PAWN_WHITE
		Lists.PIECE_TYPE.ROOK:
			if is_black:
				return ROOK_BLACK
			else:
				return ROOK_WHITE
		Lists.PIECE_TYPE.KNIGHT:
			if is_black:
				return KNIGHT_BLACK
			else:
				return KNIGHT_WHITE
		Lists.PIECE_TYPE.BISHOP:
			if is_black:
				return BISHOP_BLACK
			else:
				return BISHOP_WHITE
		Lists.PIECE_TYPE.QUEEN:
			if is_black:
				return QUEEN_BLACK
			else:
				return QUEEN_WHITE
		Lists.PIECE_TYPE.KING:
			if is_black:
				return KING_BLACK
			else:
				return KING_WHITE
		_:
			return PAWN_BLACK


func is_dark_coord(a_coord: Vector2i) -> bool:
	return (a_coord.x % 2 == 0) == (a_coord.y % 2 == 0)
