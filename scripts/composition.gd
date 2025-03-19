class_name Composition

## Abstract representation of an arangement of pieces on a board
## (0, 0) is the upper left corner; (0, 1) == Down, (1, 0) == Right

signal set_moved(a_set: Array[Move])	# A_set was just moved in _internal

var moves: Moves = Moves.new()			# Rules about piece movement
var size: Vector2i						# Width x height - note: even oddly-shaped boards are actually rectangles with hidden squares.
var _internal: Array2DGamePiece			# 2D array representing current arrangement of pieces
var _abst_board: Array2DAbstractSquare	# 2D array representing board (keeps track of special areas: e.g. holes)
var selected_square: AbstractSquare		# Currently selected square, null if none
var down: Vector2i						# Current direction that gravity is pulling
const default_down: Vector2i = Vector2i.DOWN
#const default_down: Vector2i = Vector2i.LEFT


# Setup to run on creation
func _init(a_size: Vector2i):
	size = a_size
	_internal = Array2DGamePiece.new(size)
	_abst_board = Array2DAbstractSquare.new(size)
	fill_empty_board(_abst_board)
	down = default_down


static func _init_with_linear(a_size: Vector2i, a_linear_data: Array[GamePiece]) -> Composition:
	var t_composition: Composition = Composition.new(a_size)
	t_composition._internal.construct_from_linear(a_linear_data, a_size)
	return t_composition


# Load squares data from linear
func load_linear_squares_data(a_linear_data: Array[AbstractSquare]):
	_abst_board.load_linear_data(a_linear_data)
	reconsile_board_and_pieces()


# Remove piece whereever it conflitcs with board
func reconsile_board_and_pieces():
	for i_index: int in range(pieces_linear().size()):
		if square_at_index(i_index).type != Lists.SQUARE_TYPE.NORMAL:
			_internal.linear()[i_index] = null


# Convenience for iterating squares
func square_at_index(a_index: int) -> AbstractSquare:
	return _abst_board._internal[a_index]
	


# Fill _abst_board with 
func fill_empty_board(a_board: Array2DAbstractSquare):
	for i_index: int in range(a_board.linear().size()):
		var t_type: Lists.SQUARE_TYPE = Lists.SQUARE_TYPE.NORMAL
		var t_coord: Vector2i = a_board.linear_index_to_coords(i_index)
		a_board._internal[i_index] = AbstractSquare._init_with_type(t_type, t_coord)


func pieces_linear() -> Array[GamePiece]:
	return _internal.linear()


func squares_linear() -> Array[AbstractSquare]:
	return _abst_board.linear()


# Rotate down direction to the right (clockwise) or left
func rotate_down(a_is_clockwise: bool):
	match down:
		Vector2i.DOWN:
			if a_is_clockwise:
				down = Vector2i.LEFT
			else:
				down = Vector2i.RIGHT
		Vector2i.LEFT:
			if a_is_clockwise:
				down = Vector2i.UP
			else:
				down = Vector2i.DOWN
		Vector2i.UP:
			if a_is_clockwise:
				down = Vector2i.RIGHT
			else:
				down = Vector2i.LEFT
		Vector2i.RIGHT:
			if a_is_clockwise:
				down = Vector2i.DOWN
			else:
				down = Vector2i.UP

		

# Slice of _internal starting at cell a_start, in a_direction until out of bounds
# Usually this will just be a column, but this allows for sliding in all 8 directions
func slice(a_start: Vector2i, a_direction: Vector2i) -> Array[GamePiece]:
	# If a_direction is not valid use down
	var t_direction: Vector2i = a_direction if _is_valid_direction(a_direction) else Vector2i(0, 1)
	var t_slice: Array[GamePiece] = _internal.slice(a_start, t_direction)
	return t_slice


# Is a_direction one of the 8 compass directions in unit vector form?
func _is_valid_direction(a_direction: Vector2i) -> bool:
	return abs(a_direction.x) + abs(a_direction.y) <= 2


# Is a coord a valid index in _internal?
func _is_in_range(a_coord: Vector2i) -> bool:
	return a_coord.x < size.x and a_coord.y < size.y


# Convenience function
func piece_at(a_coord: Vector2i) -> GamePiece:
	if not _is_in_range(a_coord): return null
	return _internal.at(a_coord)


# Remove piece at a_coord
func remove_piece_at(a_coord: Vector2i):
	if not _is_in_range(a_coord): return null
	_internal.put(null, a_coord)


func put_piece_at(a_piece: GamePiece, a_coord: Vector2i):
	if not _is_in_range(a_coord): return null
	_internal.put(a_piece, a_coord)


# Convenience function
func square_at(a_coord: Vector2i) -> AbstractSquare:
	if not _is_in_range(a_coord): return null
	return _abst_board.at(a_coord)


func square_at_coords(a_x: int, a_y: int) -> AbstractSquare:
	var t_coords: Vector2i = Vector2i(a_x, a_y)
	if not _is_in_range(t_coords): return null
	return _abst_board.at(t_coords)


# Returns a set of moves that represent a slide from current position and orientation
# Directions could be refactored to less code, but would be less readable
func slide_moveset() -> Array[Move]:
	#var t_start: Vector2i = _slide_origin()
	# Down direction
	var t_moveset: Array[Move] = []
	var t_move: Move
	var t_direction: int = 1
	var t_hole_dict: Dictionary[int, int] = {}		# key is position; value is count of spaces below
	var t_piece: GamePiece
	var t_square: AbstractSquare
	var t_space: int = 0		# Count of spaces so far
	var t_holes: int = 0		# Count of holes so far
	var t_distance: int = 0		# Holes plus spaces
	if down == Vector2i.DOWN:
		for i_x: int in range(size.x):
			t_space = 0
			t_holes = 0
			t_hole_dict = {}
			for i_y: int in range(size.y):
				# We want to count from the bottom up
				var t_y: int = size.y - i_y - 1
				t_piece = _internal.at_coord(i_x, t_y)
				t_square = square_at(Vector2i(i_x, t_y))
				if t_square.type == Lists.SQUARE_TYPE.STONE:
					t_space = 0
					continue
				if t_square.type == Lists.SQUARE_TYPE.HOLE:
					if t_space > 0:
						t_holes += 1
						t_hole_dict[t_y] = t_space
					continue
				if t_piece == null:
					# We are assuming all squares are normal
					t_space += 1
				else:
					t_distance = t_holes + t_space
					t_move = Move.new(Vector2i(i_x, t_y),
									Vector2i(i_x, t_y + t_direction * t_distance),
									Lists.MOVE_TYPE.SLIDE,
									t_piece,
									null)
					if not t_move.is_degenerate():
						t_moveset.append(t_move)
					for i_key: int in t_hole_dict.keys():
						if t_hole_dict[i_key] == 1: 
							t_holes = maxi(0, t_holes - 1)
							t_hole_dict.erase(i_key)
						else:
							t_hole_dict[i_key] = maxi(0, t_hole_dict[i_key] - 1)
	# Up direction
	if down == Vector2i.UP:
		t_direction = -1
		for i_x: int in range(size.x):
			t_space = 0
			t_holes = 0
			t_hole_dict = {}
			for i_y: int in range(size.y):
				# Now top down
				t_piece = _internal.at_coord(i_x, i_y)
				t_square = square_at(Vector2i(i_x, i_y))
				if t_square.type == Lists.SQUARE_TYPE.STONE:
					t_space = 0
					continue
				if t_square.type == Lists.SQUARE_TYPE.HOLE:
					if t_space > 0:
						t_holes += 1
						t_hole_dict[i_y] = t_space
					continue
				if t_piece == null:
					# We are assuming all squares are normal
					t_space += 1
				else:
					t_distance = t_holes + t_space
					t_move = Move.new(Vector2i(i_x, i_y),
									Vector2i(i_x, i_y + t_direction * t_distance),
									Lists.MOVE_TYPE.SLIDE,
									t_piece,
									null)
					#t_move = Move.new(Vector2i(i_x, i_y),
									#Vector2i(i_x, i_y + t_direction * t_space),
									#Lists.MOVE_TYPE.SLIDE,
									#t_piece,
									#null)
					if not t_move.is_degenerate():
						t_moveset.append(t_move)
					for i_key: int in t_hole_dict.keys():
						if t_hole_dict[i_key] == 1: 
							t_holes = maxi(0, t_holes - 1)
							t_hole_dict.erase(i_key)
						else:
							t_hole_dict[i_key] = maxi(0, t_hole_dict[i_key] - 1)
	# Right direction
	if down == Vector2i.RIGHT:
		print("RIGHT")
		t_direction = 1
		for i_y: int in range(size.y):
			t_space = 0
			t_holes = 0
			t_hole_dict = {}
			for i_x: int in range(size.x):
				# We want to count from left to right
				var t_x: int = size.x - i_x - 1
				t_piece = _internal.at_coord(t_x, i_y)
				t_square = square_at(Vector2i(t_x, i_y))
				if t_square.type == Lists.SQUARE_TYPE.STONE:
					t_space = 0
					continue
				if t_square.type == Lists.SQUARE_TYPE.HOLE:
					if t_space > 0:
						t_holes += 1
						t_hole_dict[t_x] = t_space
					continue
				if t_piece == null:
					# We are assuming all squares are normal
					t_space += 1
				else:
					t_distance = t_holes + t_space
					t_move = Move.new(Vector2i(t_x, i_y),
									Vector2i(t_x + t_direction * t_distance, i_y),
									Lists.MOVE_TYPE.SLIDE,
									t_piece,
									null)
					if not t_move.is_degenerate():
						t_moveset.append(t_move)
					for i_key: int in t_hole_dict.keys():
						if t_hole_dict[i_key] == 1: 
							t_holes = maxi(0, t_holes - 1)
							t_hole_dict.erase(i_key)
						else:
							t_hole_dict[i_key] = maxi(0, t_hole_dict[i_key] - 1)
	# Left direction
	if down == Vector2i.LEFT:
		t_direction = -1
		for i_y: int in range(size.y):
			t_space = 0
			t_holes = 0
			t_hole_dict = {}
			for i_x: int in range(size.x):
				# Now right to left
				t_piece = _internal.at_coord(i_x, i_y)
				t_square = square_at(Vector2i(i_x, i_y))
				if t_square.type == Lists.SQUARE_TYPE.STONE:
					t_space = 0
					continue
				if t_square.type == Lists.SQUARE_TYPE.HOLE:
					if t_space > 0:
						t_holes += 1
						t_hole_dict[i_x] = t_space
					continue
				if t_piece == null:
					# We are assuming all squares are normal
					t_space += 1
				else:
					t_distance = t_holes + t_space
					t_move = Move.new(Vector2i(i_x, i_y),
									Vector2i(i_x + t_direction * t_distance, i_y),
									Lists.MOVE_TYPE.SLIDE,
									t_piece,
									null)
					if not t_move.is_degenerate():
						t_moveset.append(t_move)
					for i_key: int in t_hole_dict.keys():
						if t_hole_dict[i_key] == 1: 
							t_holes = maxi(0, t_holes - 1)
							t_hole_dict.erase(i_key)
						else:
							t_hole_dict[i_key] = maxi(0, t_hole_dict[i_key] - 1)
	return t_moveset


# Returns a set of moves that represent refilling board
# Directions could be refactored to less code, but would be less readable
func fill_moveset() -> Array[Move]:
	# Down direction
	var t_moveset: Array[Move] = []
	var t_move: Move
	var t_direction: int = 1 
	var t_piece: GamePiece
	var t_square: AbstractSquare
	var t_space: int = 0
	if down == Vector2i.DOWN:
		for i_x: int in range(size.x):
			t_space = 0
			for i_y: int in range(size.y):
				t_piece = _internal.at_coord(i_x, i_y)
				t_square = square_at(Vector2i(i_x, i_y))
				if t_square.type == Lists.SQUARE_TYPE.STONE or t_piece != null:
					# If something is in the way of filling then this column is done
					# as this runs after sliding
					break
				else:
					t_move = Move.new(Vector2i(i_x, i_y - t_direction * size.y),
									Vector2i(i_x, i_y),
									Lists.MOVE_TYPE.FILL,
									GamePiece.init_random(),
									null)
					if not t_move.is_degenerate():
						t_moveset.append(t_move)
	# Up direction
	if down == Vector2i.UP:
		t_direction = -1
		for i_x: int in range(size.x):
			t_space = 0
			for i_y: int in range(size.y):
				var t_y: int = size.y - i_y - 1
				t_piece = _internal.at_coord(i_x, t_y)
				t_square = square_at(Vector2i(i_x, t_y))
				if t_square.type == Lists.SQUARE_TYPE.STONE or t_piece != null:
					# If something is in the way of filling then this column is done
					# as this runs after sliding
					break
				else:
					t_move = Move.new(Vector2i(i_x, t_y - t_direction * size.y),
									Vector2i(i_x, t_y),
									Lists.MOVE_TYPE.FILL,
									GamePiece.init_random(),
									null)
					if not t_move.is_degenerate():
						t_moveset.append(t_move)
	# Right direction
	if down == Vector2i.RIGHT:
		t_direction = 1
		for i_y: int in range(size.y):
			t_space = 0
			for i_x: int in range(size.x):
				# We want to count from left to right
				#var t_x: int = size.x - i_x - 1
				t_piece = _internal.at_coord(i_x, i_y)
				t_square = square_at(Vector2i(i_x, i_y))
				if t_square.type == Lists.SQUARE_TYPE.STONE or t_piece != null:
					# If something is in the way of filling then this column is done
					# as this runs after sliding
					break
				else:
					t_move = Move.new(Vector2i(i_x - t_direction * size.x, i_y),
									Vector2i(i_x, i_y),
									Lists.MOVE_TYPE.SLIDE,
									GamePiece.init_random(),
									null)
					if not t_move.is_degenerate():
						t_moveset.append(t_move)
	# Left direction
	if down == Vector2i.LEFT:
		t_direction = -1
		for i_y: int in range(size.y):
			t_space = 0
			for i_x: int in range(size.x):
				# We want to count from right to left
				var t_x: int = size.x - i_x - 1
				t_piece = _internal.at_coord(t_x, i_y)
				t_square = square_at(Vector2i(t_x, i_y))
				if t_square.type == Lists.SQUARE_TYPE.STONE or t_piece != null:
					# If something is in the way of filling then this column is done
					# as this runs after sliding
					break
				else:
					t_move = Move.new(Vector2i(t_x - t_direction * size.x, i_y),
									Vector2i(t_x, i_y),
									Lists.MOVE_TYPE.SLIDE,
									GamePiece.init_random(),
									null)
					if not t_move.is_degenerate():
						t_moveset.append(t_move)

	return t_moveset




# Move pieces according to a_moveset in _internal
func do_moves(a_moveset: Array[Move]):
	for i_move: Move in a_moveset:
		do_move(i_move)
		set_moved.emit(a_moveset)


# This can be used externally, but no signal will be emitted
func do_move(a_move: Move):
	if a_move == null or a_move.is_degenerate(): return
	_internal.put(a_move.piece, a_move.end)
	_internal.put(null, a_move.start)


# Slide pieces in current down direction and emit moved signal (for display)
func do_slide():
	var t_moveset: Array[Move] = slide_moveset()
	do_moves(t_moveset)


# Start coord for calulating slide moveset; depends on value of down
# Note we want to start at the _bottom_ of a given row or column
func _slide_origin() -> Vector2i:
	match down:
		Vector2i.DOWN:
			return Vector2i(0, 0)
		Vector2i.UP:
			return Vector2i(0, size.y - 1)
		Vector2i.RIGHT:
			return Vector2i(0, 0)
		Vector2i.LEFT:
			return Vector2i(size.x - 1, 0)
		_:
			return Vector2i(0, 0)


func random_move() -> Move:
	var t_piece: GamePiece
	var t_coord: Vector2i
	for i_counter: int in range(100):
		t_coord = Vector2i(randi_range(0, size.x - 1), randi_range(0, size.y - 1))
		t_piece = _internal.at(t_coord)
		if t_piece != null: break
	if t_piece == null: return null
	#var t_end: Vector2i = Vector2i(randi_range(0, size.x - 1), randi_range(0, size.y - 1))
	var t_valid_coords: Array[Vector2i] = valid_end_coords(_abst_board.at(t_coord))
	if t_valid_coords.is_empty():
		return Move.new(t_coord, t_coord, Lists.MOVE_TYPE.TAKE, t_piece, null)
	var t_end: Vector2i = t_valid_coords[randi_range(0, t_valid_coords.size() - 1)]
	var t_move: Move = Move.new(t_coord, t_end, Lists.MOVE_TYPE.TAKE, t_piece, null)
	return t_move


# List of valid end squares from a_start
func valid_end_coords(a_start: AbstractSquare) -> Array[Vector2i]:
	var t_list: Array[Vector2i] = []
	var t_start: Vector2i = a_start.coords
	var t_piece: GamePiece = piece_at(a_start.coords)
	if t_piece == null: return t_list
	for i_square: AbstractSquare in _abst_board.linear():
		if not is_targetable_square(i_square): continue
		var t_end: Vector2i = i_square.coords
		if moves.is_swappable_pair(self, t_start, t_end):
			t_list.append(t_end)
	return t_list


func is_targetable_square(a_square: AbstractSquare) -> bool:
	return a_square.type == Lists.SQUARE_TYPE.NORMAL


func is_valid_move(a_start: Vector2i, a_end: Vector2i) -> bool:
	return moves.is_valid_move(self, a_start, a_end)


func valid_moveset(a_square: AbstractSquare) -> Array[Move]:
	return moves.valid_moveset(self, a_square)


func is_valid_coords(a_coords: Vector2i) -> bool:
	if a_coords.x < 0 or a_coords.x >= size.x: return false
	if a_coords.y < 0 or a_coords.y >= size.y: return false
	return true


func is_selectable_coord(a_coords: Vector2i) -> bool:
	if not is_valid_coords(a_coords): return false
	return square_at(a_coords).type == Lists.SQUARE_TYPE.NORMAL and piece_at(a_coords) != null



# Remove pieces that have been reported as matched
# Note that a_coords: Array[Array[Vector2i]]
func remove_matched_sets(a_set_of_sets: Array[Array]):
	for i_set: Array[Vector2i] in a_set_of_sets:
		for i_coord: Vector2i in i_set:
			_internal.put(null, i_coord)


# Returns array of coords of squares with no piece
func empty_coords() -> Array[Vector2i]:
	var t_coords: Array[Vector2i]
	for i_x: int in size.x:
		for i_y: int in size.y:
			var t_coord: Vector2i = Vector2i(i_x, i_y)
			if piece_at(t_coord) == null:
				t_coords.append(t_coord)
	return t_coords


# Fill in empty squares with (for now) random pieces
# We supply a moveset from fill_moveset so that this and board can share it
func fill(a_moveset: Array[Move]):
	for i_move: Move in a_moveset:
		put_piece_at(i_move.piece, i_move.end)
