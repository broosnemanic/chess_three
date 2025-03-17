class_name AbstractSquare

## Abstract representation of a square

var seal_level: int			# Level zero is no seal
var type: Lists.SQUARE_TYPE	# E.g. NORMAL, CLIP, HOLE
var coords: Vector2i


static func _init_with_type(a_type: Lists.SQUARE_TYPE, a_coords: Vector2i) -> AbstractSquare:
	var t_square: AbstractSquare = AbstractSquare.new()
	t_square.coords = a_coords
	t_square.type = a_type
	return t_square


# Convenience func
func is_stone() -> bool:
	return type == Lists.SQUARE_TYPE.STONE

# Convenience func
func is_hole() -> bool:
	return type == Lists.SQUARE_TYPE.HOLE

# Convenience func
func x():
	return coords.x


# Convenience func
func y():
	return coords.y
