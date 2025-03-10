class_name MatchFinder

# ADDCOMMENT
#var pegs: Array[Array]		# Passed from board.initialize()
#var all_peg_sets: Array[Array]
var all_coord_sets: Array[Array]
#var size: Vector2i
var all_matched_sets: Array[Array]
var composition: Composition		# Board state to evaluate

# ADDCOMMENT
func _init(a_composition: Composition):
	composition = a_composition
	all_matched_sets = []
	setup_coord_sets()
	
# ADDCOMMENT	
#func setup_peg_sets():
	#all_peg_sets = []
	#var i_set: Array[Array]
	#for col: Array[StaticBody2D] in pegs:
		#for peg: StaticBody2D in col:
			#i_set = jem_sets_to_evaluate(peg)
			#for ii_set in i_set:
				#all_peg_sets.append(ii_set)

# See commment for coord_sets_to_evaluate, but for all coords
func setup_coord_sets():
	all_coord_sets = []
	var i_set: Array[Array]
	for i_x: int in range(composition.size.x):
		for i_y: int in range(composition.size.y):
			var i_coord: Vector2i = Vector2i(i_x, i_y)
			i_set = coord_sets_to_evaluate(i_coord)
			for j_set: Array[Vector2i] in i_set:
				all_coord_sets.append(j_set)


#Returns a set of sets of pegs; each set of jems(each owned by a given peg) is to be evaluated as a possilbe matched set	
#func jem_sets_to_evaluate(a_seed_peg: StaticBody2D) -> Array[Array]:
	#var set_of_sets: Array[Array] = []
	#var i_set: Array[StaticBody2D]
	#for count: int in [3, 4, 5]:
		#i_set = linear_set(a_seed_peg, count, true)
		#if i_set.size() == count:
			#set_of_sets.append(i_set)
	#for count: int in [3, 4, 5]:
		#i_set = linear_set(a_seed_peg, count, false)
		#if i_set.size() == count:
			#set_of_sets.append(i_set)
	#for count: int in [3, 4, 5]:
		#i_set = diagonal_set(a_seed_peg, count, true)
		#if i_set.size() == count:
			#set_of_sets.append(i_set)
	#for count: int in [3, 4, 5]:
		#i_set = diagonal_set(a_seed_peg, count, false)
		#if i_set.size() == count:
			#set_of_sets.append(i_set)
	#return set_of_sets


# Starting at a_coord - find all sets of coords that a_coord could potentially participate in a match
# I.e. collect sets in all (really only half) directions from a_coord up to a distance of 5 (linear match size)
func coord_sets_to_evaluate(a_coord: Vector2i) -> Array[Array]:
	var set_of_sets: Array[Array] = []
	var i_set: Array[Vector2i]
	for count: int in [3, 4, 5]:
		i_set = linear_set(a_coord, count, true)
		if i_set.size() == count:
			set_of_sets.append(i_set)
	for count: int in [3, 4, 5]:
		i_set = linear_set(a_coord, count, false)
		if i_set.size() == count:
			set_of_sets.append(i_set)
	for count: int in [3, 4, 5]:
		i_set = diagonal_set(a_coord, count, true)
		if i_set.size() == count:
			set_of_sets.append(i_set)
	for count: int in [3, 4, 5]:
		i_set = diagonal_set(a_coord, count, false)
		if i_set.size() == count:
			set_of_sets.append(i_set)
	return set_of_sets

# ADDCOMMENT
#func find_matched_sets():
	#for i_set: Array[StaticBody2D] in all_peg_sets:
		#var i_peg: StaticBody2D = i_set[0]
		#if i_peg.column == 1 && i_peg.row == 2:		# I assume this was for debugging?
			#pass
		#if is_matching_set(i_set):
			#all_matched_sets.append(i_set)
	#reduce_matched_sets_by_closure()

# This is the call to find all the matches
func find_matched_sets():
	all_matched_sets = []
	for i_set: Array[Vector2i] in all_coord_sets:
		if is_matching_set(i_set):
			all_matched_sets.append(i_set)
	reduce_matched_sets_by_closure()


# Combine sets in all_matched_sets which overlap
func reduce_matched_sets_by_closure():
	var temp_array: Array[Array] = get_set_closures(all_matched_sets)
	all_matched_sets = temp_array


# Given set of sets of pegs, return union of all pegs with none duplicated
#func consolidated_peg_array(a_set_of_sets: Array[Array]) -> Array[StaticBody2D]:		# a_set: Array[Array[StaticBody2D]]
	#var consolidator: Dictionary
	#for i_set: Array[StaticBody2D] in a_set_of_sets:
		#for i_peg: StaticBody2D in i_set:
			#var key: Vector2i = Vector2i(i_peg.column, i_peg.row)
			#consolidator[key] = i_peg
	#return untyped_array_to_array_of_pegs(consolidator.values())			# Will this complain because Dictionary.values() returns an untyped array? 


# Returns an array containing all unique values in all sets in a_set_of_sets
func consolidated_coord_array(a_set_of_sets: Array[Array]) -> Array[Vector2i]:		# a_set_of_sets: Array[Array[Vector2i]]
	var t_consolidator: Dictionary
	for i_set: Array[Vector2i] in a_set_of_sets:
		for i_coord: Vector2i in i_set:
			var t_key: Vector2i = i_coord
			t_consolidator[t_key] = i_coord
	return untyped_array_to_array_of_vector2i(t_consolidator.values())


# ADDCOMMENT
#func untyped_array_to_array_of_pegs(a_array: Array) -> Array[StaticBody2D]:
	#var temp_array: Array[StaticBody2D] = []
	#for i_peg in a_array:
		#temp_array.append(i_peg)
	#return temp_array


func untyped_array_to_array_of_vector2i(a_array: Array) -> Array[Vector2i]:
	var temp_array: Array[Vector2i] = []
	for i_coord in a_array:
		temp_array.append(i_coord)
	return temp_array


# Could we just do a_peg_1 == a_peg_2? Maybe.
func is_same_peg(a_peg_1, a_peg_2: StaticBody2D) -> bool:
	return (a_peg_1.column == a_peg_2.column) && (a_peg_1.row == a_peg_2.row)
	
	
# Combine sets with common pegs. Return set of sets with no pegs in common
#func get_set_closures(a_set_of_sets: Array[Array]) -> Array[Array]:
	#var is_closure: bool = true												# Set to false if any sets overlap
	#var temp_set_of_sets: Array[Array] = a_set_of_sets.duplicate()			# We do not want to modify a_set_of_sets
	#var consolidated_set: Array[StaticBody2D]
	#for i: int in range(0, temp_set_of_sets.size()):
		#var i_set: Array[StaticBody2D] = untyped_array_to_array_of_pegs(temp_set_of_sets[i])
		#consolidated_set = i_set.duplicate()
		#if !i_set.is_empty():
			#for j: int in range(i + 1, temp_set_of_sets.size()):
				#var j_set: Array[StaticBody2D] = untyped_array_to_array_of_pegs(temp_set_of_sets[j])
				#if !j_set.is_empty():
					#if is_overlapping_set(i_set, j_set):
						#is_closure = false									# Two sets overlap so closure is not complete
						#consolidated_set = consolidated_peg_array([consolidated_set, j_set])
						#temp_set_of_sets[j] = []							# We remove
		#temp_set_of_sets[i] = consolidated_set
	#if is_closure:
		#return empty_removed_array(temp_set_of_sets)
	#else:
		#return get_set_closures(temp_set_of_sets)


func get_set_closures(a_set_of_sets: Array[Array]) -> Array[Array]:
	var is_closure: bool = true												# Set to false if any sets overlap
	var t_set_of_sets: Array[Array] = a_set_of_sets.duplicate()			# We do not want to modify a_set_of_sets
	var consolidated_set: Array[Vector2i]
	for i: int in range(t_set_of_sets.size()):
		var i_set: Array[Vector2i] = untyped_array_to_array_of_vector2i(t_set_of_sets[i])
		consolidated_set = i_set.duplicate()
		if  not i_set.is_empty():
			for j: int in range(i + 1, t_set_of_sets.size()):
				var j_set: Array[Vector2i] = untyped_array_to_array_of_vector2i(t_set_of_sets[j])
				if not j_set.is_empty():
					if is_overlapping_set(i_set, j_set):
						is_closure = false									# Two sets overlap so closure is not complete
						consolidated_set = consolidated_coord_array([consolidated_set, j_set])
						t_set_of_sets[j] = []							# We remove
		t_set_of_sets[i] = consolidated_set
	if is_closure:
		return empty_removed_array(t_set_of_sets)
	else:
		return get_set_closures(t_set_of_sets)


# Return version of a_set_of_sets with all empty arrays removed
func empty_removed_array(a_set_of_sets: Array[Array]) -> Array[Array]:
	var temp_array: Array[Array] = []
	for i_set: Array in a_set_of_sets:
		if !i_set.is_empty():
			temp_array.append(i_set)
	return temp_array

# ADDCOMMENT
#func is_overlapping_set(a_set_1, a_set_2: Array[StaticBody2D]) -> bool:
	#for i_peg: StaticBody2D in a_set_1:
		#for j_peg: StaticBody2D in a_set_2:
			#if is_same_peg(i_peg, j_peg):
				#return true
	#return false
#

# Do a_set_1 and a_set_2 contain at least on coord in common?
func is_overlapping_set(a_set_1: Array[Vector2i], a_set_2: Array[Vector2i]) -> bool:
	for i_coord: Vector2i in a_set_1:
		for j_coord: Vector2i in a_set_2:
			if i_coord == j_coord:
				return true
	return false


# As it says
func clear_all_matched_sets():
	all_matched_sets.clear()

#Set returned is up to size a_length (including a_seed_peg) in row or column direction
#func linear_set(a_seed_peg: StaticBody2D, a_length: int, a_is_horizontal: bool) -> Array[StaticBody2D]:
	#if a_seed_peg.column == 5:
		#pass
	#var peg_set: Array[StaticBody2D] = [a_seed_peg]
	#var i: int = 1
	#var i_peg: StaticBody2D = a_seed_peg
	#while i < a_length:
		#if a_is_horizontal:
			#i_peg = peg_to_right(i_peg)
		#else:
			#i_peg = peg_below(i_peg)
		#if i_peg == null:
			#return peg_set
		#peg_set.append(i_peg)
		#i = i + 1
	#return peg_set


# Returns straight set starting at a_coord then up or to the right
# of length a_length or truncated at board edge
func linear_set(a_coord: Vector2i, a_length: int, a_is_horizontal: bool) -> Array[Vector2i]:
	var t_set: Array[Vector2i] = [a_coord]
	var i: int = 1
	var i_coord: Vector2i = a_coord
	while i < a_length:
		if a_is_horizontal:
			i_coord = coord_to_right(i_coord)
		else:
			i_coord = coord_below(i_coord)
		if not composition.is_valid_coords(i_coord):
			return t_set
		t_set.append(i_coord)
		i = i + 1
	return t_set


# ADDCOMMENT
#func diagonal_set(a_seed_peg: StaticBody2D, a_length: int, a_is_up: bool) -> Array[StaticBody2D]:
	#var peg_set: Array[StaticBody2D] = [a_seed_peg]
	#var i: int = 1
	#var i_peg: StaticBody2D = a_seed_peg
	#while i < a_length:
		#if a_is_up:
			#i_peg = peg_up_right(i_peg)
		#else:
			#i_peg = peg_down_right(i_peg)
		#if i_peg == null:
			#return peg_set
		#peg_set.append(i_peg)
		#i = i + 1
	#return peg_set


# Returns diagonal set starting at a_coord up / down and to the right
# of length a_length or truncated at board edge
func diagonal_set(a_coord: Vector2i, a_length: int, a_is_up: bool) -> Array[Vector2i]:
	var t_set: Array[Vector2i] = [a_coord]
	var i: int = 1
	var i_coord: Vector2i = a_coord
	while i < a_length:
		if a_is_up:
			i_coord = coord_up_right(i_coord)
		else:
			i_coord = coord_down_right(i_coord)
		if not composition.is_valid_coords(i_coord):
			return t_set
		t_set.append(i_coord)
		i = i + 1
	return t_set

# Square to the right and above a_coord
# Note valid coord check must be done by caller
func coord_up_right(a_coord: Vector2i) -> Vector2i:
	return Vector2i(a_coord.x + 1, a_coord.y - 1)


# Square to the right and below a_coord
# Note valid coord check must be done by caller
func coord_down_right(a_coord: Vector2i) -> Vector2i:
	return Vector2i(a_coord.x + 1, a_coord.y + 1)

	
# ADDCOMMENT
#func peg_to_right(a_seed_peg: StaticBody2D) -> StaticBody2D:
	#var col: int = a_seed_peg.column + 1
	#var row: int = a_seed_peg.row
	#if col < size.x:
		#return pegs[col][row]
	#return null


# Square to the right of a_coord
# Note valid coord check must be done by caller
func coord_to_right(a_coord: Vector2i) -> Vector2i:
	return Vector2i(a_coord.x + 1, a_coord.y)


# ADDCOMMENT
#func peg_below(a_seed_peg: StaticBody2D) -> StaticBody2D:
	#var col: int = a_seed_peg.column
	#var row: int = a_seed_peg.row + 1
	#if row < size.y:
		#return pegs[col][row]
	#return null


# Square under a_coord
# Note valid coord check must be done by caller
func coord_below(a_coord: Vector2i) -> Vector2i:
	return Vector2i(a_coord.x, a_coord.y + 1)


# ADDCOMMENT
#func is_valid_peg_coord(a_coord: Vector2i) -> bool:
	#var col: int = a_coord.x
	#var row: int = a_coord.y
	#var is_valid_col: bool = col >= 0 && col < size.x
	#var is_valid_row: bool = row >= 0 && row < size.y
	#return is_valid_col && is_valid_row  
	
# ADDCOMMENT
#func is_matching_set(a_pegs: Array[StaticBody2D]) -> bool:
	#return is_all_non_null_set(a_pegs) && is_contiguous_set(a_pegs) && (is_linear_set(a_pegs) || is_diagonal_set(a_pegs)) && is_match_by_value(a_pegs)


# Do pieces at coords in a_coord_set make a match?
func is_matching_set(a_coord_set: Array[Vector2i]) -> bool:
	var t_is_contig: bool = is_contiguous_set(a_coord_set)
	var t_is_line: bool = is_linear_set(a_coord_set) or is_diagonal_set(a_coord_set)
	var t_is_match: bool = is_match_by_value(a_coord_set)
	return t_is_contig and t_is_line and t_is_match



# As we are converting StaticBody references to Vector2i I do ntothink this will be necessary	
func is_all_non_null_set(a_pegs: Array[StaticBody2D]) -> bool:
	for i_peg: StaticBody2D in a_pegs:
		if i_peg.jem() == null: return false
	return true

# ADDCOMMENT
#func is_horizontal_set(a_pegs: Array[StaticBody2D]) -> bool:
	#for i: int in range(1, a_pegs.size()):
		#if a_pegs[i - 1].row != a_pegs[i].row:
			#return false
	#return true

# Are all coords in a_coord_set in a horizontal line?
func is_horizontal_set(a_coord_set: Array[Vector2i]) -> bool:
	for i: int in range(1, a_coord_set.size()):
		if a_coord_set[i - 1].y != a_coord_set[i].y:
			return false
	return true

# ADDCOMMENT
#func is_vertical_set(a_pegs: Array[StaticBody2D]) -> bool:
	#for i: int in range(1, a_pegs.size()):
		#if a_pegs[i - 1].column != a_pegs[i].column:
			#return false
	#return true


# Are all coords in a_coord_set in a vertical line?
func is_vertical_set(a_coord_set: Array[Vector2i]) -> bool:
	for i: int in range(1, a_coord_set.size()):
		if a_coord_set[i - 1].x != a_coord_set[i].x:
			return false
	return true

# ADDCOMMENT
#func is_linear_set(a_pegs: Array[StaticBody2D]) -> bool:
	#return is_horizontal_set(a_pegs) || is_vertical_set(a_pegs)


# Are all coords in a_coord_set in a line?
func is_linear_set(a_coord_set: Array[Vector2i]) -> bool:
	return is_horizontal_set(a_coord_set) or is_vertical_set(a_coord_set)


# Is every coord in a_coord_set diagonal to at least one other coord in a_coord_set?
# TODO: I think this allows for v-shaped sets - which is maybe a problem?
func is_diagonal_set(a_coord_set: Array[Vector2i]) -> bool:
	var t_coords: Array[Vector2i] = a_coord_set.duplicate()
	for i_coord: Vector2i in a_coord_set:
		if not is_any_diagonally_adjacent(i_coord, t_coords):
			return false
	return true

# ADDCOMMENT
#func is_match_by_value(a_pegs: Array[StaticBody2D]) -> bool:
	##var area: Area2D = a_pegs[0].area
	#var type: int = a_pegs[0].jem().type
	##var is_black: bool = a_pegs[0].jem().is_black
	#var color_code: int = a_pegs[0].jem().color_code
	#for i_peg: StaticBody2D in a_pegs:
		#if i_peg.jem() == null: return false
		#if i_peg.jem().type != type || i_peg.jem().color_code != color_code:
			#return false
	#return true

# Do all the pieces at a_coord_set match?
func is_match_by_value(a_coord_set: Array[Vector2i]) -> bool:
	if a_coord_set.is_empty(): return false
	var t_piece: GamePiece = composition.piece_at(a_coord_set[0])
	if t_piece == null: return false
	var t_type: Lists.PIECE_TYPE = t_piece.type
	var t_color: Lists.COLOR = t_piece.color
	for i_coord: Vector2i in a_coord_set:
		t_piece = composition.piece_at(i_coord)
		if t_piece == null: return false
		if t_piece.type != t_type or t_piece.color != t_color:
			return false
	return true


# Is every peg in a_pegs adjacent (inc diagonally) to some other peg in a_pegs?
#func is_contiguous_set(a_pegs: Array[StaticBody2D]) -> bool:
	#var temp_pegs: Array[StaticBody2D] = Array(a_pegs)
	#for i_peg:StaticBody2D in a_pegs:
		#if !is_any_adjacent(i_peg, temp_pegs) && !is_any_diagonally_adjacent(i_peg, temp_pegs):
			#return false
	#return true


func is_contiguous_set(a_coord_set: Array[Vector2i]) -> bool:
	var t_coord_set: Array[Vector2i] = a_coord_set.duplicate()
	for i_coord: Vector2i in a_coord_set:
		if not is_any_adjacent(i_coord, t_coord_set) and not is_any_diagonally_adjacent(i_coord, t_coord_set):
			return false
	return true


# Are any coords in a_coord_set next to a_coord (not diagonally)
func is_any_adjacent(a_coord: Vector2i, a_coord_set: Array[Vector2i]) -> bool:
	for i_coord: Vector2i in a_coord_set:
		if is_pair_adjacent(a_coord, i_coord):
			return true
	return false


# Are any coords in a_coord_set diagonal to a_coord
func is_any_diagonally_adjacent(a_coord: Vector2i, a_coord_set: Array[Vector2i]) -> bool:
	for i_coord: Vector2i in a_coord_set:
		if is_pair_diagonally_adjacent(a_coord, i_coord):
			return true
	return false	


# Are a_coord_1 and a_coord_2 next to each other (not diagonally)
func is_pair_adjacent(a_coord_1: Vector2i, a_coord_2: Vector2i) -> bool:
	return is_adjacent(a_coord_1, a_coord_2)


# Looks like this was used to convert pegs to coords
func is_pair_diagonally_adjacent(a_coord_1: Vector2i, a_coord_2: Vector2i) -> bool:
	return is_diagonally_adjacent(a_coord_1, a_coord_2)


# As it says
func is_adjacent(a_coord_1: Vector2i, a_coord_2: Vector2i) -> bool:
	var t_value: int = absi(a_coord_1.x - a_coord_2.x) + abs(a_coord_1.y - a_coord_2.y)
	return t_value == 1


# As it says
func is_diagonally_adjacent(a_coord_1: Vector2i, a_coord_2: Vector2i) -> bool:
	var t_delta_x: int = absi(a_coord_1.x - a_coord_2.x)
	var t_delta_y: int = abs(a_coord_1.y - a_coord_2.y)
	return t_delta_y == 1 && t_delta_x == 1
	
