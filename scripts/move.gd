class_name Move

## Represents a move: Take, match, or slide

var start: Vector2i			# Coord move starts at
var end: Vector2i			# Coord move ends at
var is_take: bool			# Is this a capture?
var is_match: bool			# Is this the resolution of a match?
var is_slide: bool			# Is this a slide move?
var is_fill: bool			# Is this a fill move?
var piece: GamePiece		# Piece doing the moving
var taken_piece: GamePiece	# Piece, if any, that has been captured
var direction: Vector2i		# This can be inferred from start and end
var type: int


func _init(a_start: Vector2i, a_end: Vector2i, a_type: int, a_piece: GamePiece, a_taken: GamePiece):
	start = a_start
	end = a_end
	type = a_type
	set_bool_from_type(a_type)
	piece = a_piece
	taken_piece = a_taken


static func init_from_move(a_move: Move) -> Move:
	return Move.new(a_move.start, a_move.end, a_move.type, a_move.piece, a_move.taken_piece)


func is_degenerate() -> bool:
	return start == null or end == null or start == end or piece == null


func distance() -> float:
	return start.distance_to(end)


func set_bool_from_type(a_type: Lists.MOVE_TYPE):
	is_take = a_type == Lists.MOVE_TYPE.TAKE
	is_match = a_type == Lists.MOVE_TYPE.MATCH
	is_slide = a_type == Lists.MOVE_TYPE.SLIDE
	is_fill = a_type == Lists.MOVE_TYPE.FILL


# HACK: why not just store MOVE_TYPE?
func type_from_bools() -> Lists.MOVE_TYPE:
	if is_take: return Lists.MOVE_TYPE.TAKE
	if is_match: return Lists.MOVE_TYPE.MATCH
	if is_slide: return Lists.MOVE_TYPE.SLIDE
	if is_fill: return Lists.MOVE_TYPE.FILL
	return Lists.MOVE_TYPE.TAKE



func animation_duration() -> float:
	if is_take: return Constants.MOVE_DURATION
	if is_slide: return Constants.SLIDE_DURATION
	if is_fill: return Constants.FILL_DURATION
	return Constants.MOVE_DURATION
	
