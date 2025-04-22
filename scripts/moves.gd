class_name Moves

#TODO: Should a_start, a_end pairs instead be Move type?

func valid_moveset(a_composition: Composition, a_square: AbstractSquare) -> Array[Move]:
	var t_moves: Array[Move] = []
	var t_move: Move
	if a_square == null or a_square.type != Lists.SQUARE_TYPE.NORMAL: return t_moves
	var t_piece: GamePiece = a_composition.piece_at(a_square.coords)
	if t_piece == null: return t_moves
	var t_take_piece: GamePiece
	for i_square: AbstractSquare in a_composition.squares_linear():
		if i_square.coords == Vector2i(2, 3):
			pass
		if is_valid_move(a_composition, a_square.coords, i_square.coords):
			if is_blocked_move(a_composition, a_square.coords, i_square.coords): continue
			t_take_piece = a_composition.piece_at(i_square.coords)
			t_move = Move.new(a_square.coords,
								i_square.coords,
								Lists.MOVE_TYPE.TAKE,
								t_piece,
								t_take_piece)
			t_moves.append(t_move)
	return t_moves


# Assumption: Move is in some cardinal / half cardinal direction
func is_blocked_move(a_composition: Composition, a_start: Vector2i, a_end: Vector2i) -> bool:
	if a_composition.piece_at(a_start).type == Lists.PIECE_TYPE.KNIGHT:
		return a_composition.square_at(a_end).is_stone()
	var t_delta_x: int = sign(a_end.x - a_start.x)
	var t_delta_y: int = sign(a_end.y - a_start.y)
	var t_delta: Vector2i = Vector2i(t_delta_x, t_delta_y)
	var t_coord: Vector2i = Vector2i(a_start)
	for i: int in a_composition.size:
		t_coord += t_delta
		if not a_composition.is_valid_coords(t_coord): break
		if a_composition.square_at(t_coord).is_stone(): return true
		if t_coord == a_end: break
	return false



# Could a_peg_1 move to location of a_peg_2?
func is_valid_move(a_composition: Composition, a_start: Vector2i, a_end: Vector2i) -> bool:
	if a_composition.square_at(a_end).type != Lists.SQUARE_TYPE.NORMAL: return false
	if is_blocked_move(a_composition, a_start, a_end): return false
	var t_piece: GamePiece = a_composition.piece_at(a_start)
	if t_piece == null:
		return false
	if is_matching_colors(t_piece, a_composition.piece_at(a_end)):
		return false
	if t_piece.type == Lists.PIECE_TYPE.BISHOP:
		return is_on_diagonal(a_start, a_end)
	if t_piece.type == Lists.PIECE_TYPE.ROOK:
		return is_on_col_row(a_start, a_end)
	if t_piece.type == Lists.PIECE_TYPE.KING:
		return is_pair_radially_adjacent(a_start, a_end)
	if t_piece.type == Lists.PIECE_TYPE.QUEEN:
		return is_on_diagonal(a_start, a_end) || is_on_col_row(a_start, a_end)
	if t_piece.type == Lists.PIECE_TYPE.KNIGHT:
		return is_on_knight_move(a_start, a_end)
	if t_piece.type == Lists.PIECE_TYPE.PAWN:
		return is_on_pawn_move(a_composition.down, a_start, a_end)
	return true


# Is a_piece_1 the smae color as a_piece_2?
func is_matching_colors(a_piece_1: GamePiece, a_piece_2: GamePiece) -> bool:
	if a_piece_1 == null || a_piece_2 == null: return false
	return a_piece_1.color == a_piece_2.color


func is_pair_radially_adjacent(a_start: Vector2i, a_end: Vector2i) -> bool:
	return abs(a_start.x - a_end.x) <= 1 && abs(a_start.y - a_end.y) <= 1


# Not necessarily adjacent
func is_on_diagonal(a_start: Vector2i, a_end: Vector2i) -> bool:
	return abs(a_start.x - a_end.x) == abs(a_start.y - a_end.y)
	
	
# Not necessarily adjacent
func is_on_col_row(a_start: Vector2i, a_end: Vector2i) -> bool:
	return (a_start.x == a_end.x) || (a_start.y == a_end.y)


# Is a_other_peg a knight move away from a_peg?
func is_on_knight_move(a_start: Vector2i, a_end: Vector2i) -> bool:
	var t_cdistance: int = abs(a_start.x - a_end.x)
	var t_rdistance: int = abs(a_start.y - a_end.y)
	return (t_cdistance == 1 && t_rdistance == 2) || (t_cdistance == 2 && t_rdistance == 1)


# Is a_other_peg up and diagonal from a_peg?
# Note: we assume a valid value for a_down: one value (-1, 0, or 1) values one always 0
func is_on_pawn_move(a_down: Vector2i, a_start: Vector2i, a_end: Vector2i) -> bool:
	var t_delta_x: int = a_start.x - a_end.x
	var t_delta_y: int = a_start.y - a_end.y
	if a_down.x == 0:	#UP or DOWN
		return absi(t_delta_x) == 1 and t_delta_y == 1 * a_down.y
	elif a_down.y == 0:	#Right or LEFT
		return absi(t_delta_y) == 1 and t_delta_x == 1 * a_down.x
	else:
		return false
