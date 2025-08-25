extends Node

const DARK_SQUARE: Texture2D = preload("res://textures/board/DarkTile.png")
const LIGHT_SQUARE: Texture2D = preload("res://textures/board/LightTile.png")
const piece_textures: Resource = preload("res://resources/piece_textures_02.tres")

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
				#return PAWN_BLACK
				return piece_textures.black_pawn
			else:
				return piece_textures.white_pawn
		Lists.PIECE_TYPE.ROOK:
			if is_black:
				return piece_textures.black_rook
			else:
				return piece_textures.white_rook
		Lists.PIECE_TYPE.KNIGHT:
			if is_black:
				return piece_textures.black_knight
			else:
				return piece_textures.white_knight
		Lists.PIECE_TYPE.BISHOP:
			if is_black:
				return piece_textures.black_bishop
			else:
				return piece_textures.white_bishop
		Lists.PIECE_TYPE.QUEEN:
			if is_black:
				return piece_textures.black_queen
			else:
				return piece_textures.white_queen
		Lists.PIECE_TYPE.KING:
			if is_black:
				return piece_textures.black_king
			else:
				return piece_textures.white_king
		_:
			return piece_textures.black_pawn


func multi_effect_texture(a_type: Lists.PIECE_TYPE) -> Texture2D:
	match a_type:
		Lists.PIECE_TYPE.PAWN:
			return piece_textures.pawn_color
		Lists.PIECE_TYPE.ROOK:
			return piece_textures.rook_color
		Lists.PIECE_TYPE.KNIGHT:
			return piece_textures.knight_color
		Lists.PIECE_TYPE.BISHOP:
			return piece_textures.bishop_color
		Lists.PIECE_TYPE.QUEEN:
			return piece_textures.queen_color
		Lists.PIECE_TYPE.KING:
			return piece_textures.king_color
		_:
			return piece_textures.pawn_color


func is_dark_coord(a_coord: Vector2i) -> bool:
	return (a_coord.x % 2 == 0) == (a_coord.y % 2 == 0)
