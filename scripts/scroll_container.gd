extends ScrollContainer

var content_node: Control

func _ready():
	set_deferred("vertical_scroll", Vector2(0.0, 20.0))
