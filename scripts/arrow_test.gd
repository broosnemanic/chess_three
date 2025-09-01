extends Sprite2D

@export var head_texture: Texture2D
@export var line_texture: Texture2D

var is_cooldown_elapsed: bool = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and is_cooldown_elapsed:
			is_cooldown_elapsed = false
			get_tree().create_timer(0.2).timeout.connect(func(): is_cooldown_elapsed = true)
			var mouse_pos: Vector2 = get_viewport().get_mouse_position()
			var t_delta_pos = mouse_pos - position
			#var t_delta_pos = position
			var t_head: Sprite2D = Sprite2D.new()
			t_head.texture = head_texture
			var t_arrow: ArrowStrike = ArrowStrike.new(t_delta_pos, 1.0, t_head, line_texture)
			add_child(t_arrow)
			t_arrow.z_index = -1
			t_arrow.line.width = 10
			t_arrow.go_completed.connect(on_arrow_completed)
			t_arrow.go()


func on_arrow_completed(a_arrow: ArrowStrike):
	a_arrow.queue_free()
	
