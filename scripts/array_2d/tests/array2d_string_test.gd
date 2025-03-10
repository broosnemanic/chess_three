extends Node2D

signal test_signal


var test_linear01: Array[String] = ["one", "two", "three", "four", 
		"five", "six", "seven", "eight", 
		"nine", "ten", "eleven", "twelve", 
		"thirteen", ]

var test_linear02: Array[String] = ["one", "two", "three", "four", 
		"five", "six", "seven", "eight", 
		"nine", "ten",]

var test_row_00: Array[String] = ["apple", "beet", "carrot", "daikon", "eggplant"]
var test_row_01: Array[String] = ["ant", "bear", "cat", "dog", "elephant"]
var test_row_02: Array[String] = ["Aluminium", "Boron", "Carbon", "Deuterium", "Eggplantium"]
var test_row_03: Array[String] = ["armchair", "baseball", "can", "drill", "endoscope"]


var test_array2d_00: Array2DString
var test_array2d_01: Array2DString
var test_array2d_02: Array2DString

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_construct_from_rows()
	test_construct_from_columns()
	test_rows()
	test_columns()
	test_at()
	test_append_row()
	test_append_column()
	test_linear_index_to_coords()
	test_put()
	test_replace_row()
	test_replace_column()

func get_test_array2d_00() -> Array2DString:
	test_array2d_00 = Array2DString.new(Vector2i(1, 1))
	return test_array2d_00


func get_test_array2d_01() -> Array2DString:
	test_array2d_01 = Array2DString.new(Vector2i(1, 1))
	test_array2d_01.construct_from_linear(test_linear01, Vector2i(3, 5))
	return test_array2d_01


func get_test_array2d_02() -> Array2DString:
	test_array2d_02 = Array2DString.new(Vector2i(1, 1))
	test_array2d_02.construct_from_linear(test_linear02, Vector2i(3, 4))
	return test_array2d_02


func test_construct_from_rows():
	print("test_construct_from_rows\n")
	var t_array: Array2DString = get_test_array2d_00()
	t_array.construct_from_rows([test_row_00, test_row_01, test_row_02, test_row_03, ])
	t_array.out()
	print("\n________________")

func test_construct_from_columns():
	print("test_construct_from_columns\n")
	var t_array: Array2DString = get_test_array2d_00()
	t_array.construct_from_columns([test_row_00, test_row_01, test_row_02, test_row_03, ])
	t_array.out()
	print("\n________________")


func test_rows():
	print("test_rows\n")
	var t_array: Array2DString = get_test_array2d_01()
	print(t_array.rows())
	print("\n________________")


func test_columns():
	print("test_columns\n")
	var t_array: Array2DString = get_test_array2d_01()
	print(t_array.columns())
	print("\n________________")


func test_at():
	print("test_at\n")
	var t_array: Array2DString = get_test_array2d_02()
	var t_column: int = randi_range(0, t_array.size.x - 1)
	var t_row: int = randi_range(0, t_array.size.y - 1)
	print("[" + str(t_column) + ", " + str(t_row) + "]: " + str(t_array.at(Vector2i(t_column, t_row))))
	print("\n________________")


func test_append_row():
	print("test_append_row\n")
	var t_array: Array2DString = get_test_array2d_01()
	t_array.append_row(["new00", "new01", "new02", "new03", "new04", "new05", "new06", "new07", ])
	t_array.out()
	print("\n________________")


func test_append_column():
	print("test_append_column\n")
	var t_array: Array2DString = get_test_array2d_01()
	t_array.append_column(["NEW00", "NEW01", "NEW02", "NEW03", "NEW04", "NEW05", "NEW06", "NEW07", ])
	t_array.out()
	print("\n________________")


func test_linear_index_to_coords():
	print("test_linear_index_to_coords\n")
	var t_array: Array2DString = get_test_array2d_02()
	var t_index_00: int = 0
	var t_index_01: int = t_array.linear().size() - 1
	var t_index_02: int = randi_range(1, t_array.linear().size() - 2)
	print("Size: " + str(t_array.size))
	print("index == " + str(t_index_00) + " -> " + str(t_array.linear_index_to_coords(t_index_00)))
	print("index == " + str(t_index_01) + " -> " + str(t_array.linear_index_to_coords(t_index_01)))
	print("index == " + str(t_index_02) + " -> " + str(t_array.linear_index_to_coords(t_index_02)))
	print("\n________________")


func test_put():
	print("test_put\n")
	var t_array: Array2DString = get_test_array2d_02()
	t_array.out()
	print("")
	var t_coord: Vector2i = Vector2i(randi_range(0, t_array.size.x - 1), randi_range(0, t_array.size.y - 1))
	print(t_coord)
	print("--")
	t_array.put("REPLACED", t_coord)
	t_array.out()
	print("\n________________")


func test_replace_row():
	print("test_replace_row\n")
	var t_array: Array2DString = get_test_array2d_01()
	var t_row_index: int = randi_range(0, t_array.size.y - 1)
	print("replaced row index: " + str(t_row_index))
	t_array.replace_row(t_row_index, ["REPLACED", "REPLACED", "REPLACED", "REPLACED", "REPLACED", "REPLACED", "REPLACED", "REPLACED", ])
	t_array.out()
	print("\n________________")


func test_replace_column():
	print("test_replace_column\n")
	var t_array: Array2DString = get_test_array2d_01()
	var t_column_index: int = randi_range(0, t_array.size.x - 1)
	print("replaced column index: " + str(t_column_index))
	t_array.replace_column(t_column_index, ["REPLACED", "REPLACED", "REPLACED", "REPLACED", "REPLACED", "REPLACED", "REPLACED", "REPLACED", ])
	t_array.out()
	print("\n________________")
