extends RigidBody2D
class_name PhysicsPiece

var sprite: Sprite2D	# Matches piece this is simulating

# This obj takes care of its own movement and appearance
func _ready() -> void:
	sprite = $PieceSprite
	z_index = 100
	toss()
	#freeze = true


func toss():
	var t_magnitude: float = randf_range(500.0, 1000.0)
	var t_angle: float = randf_range(30.0, 150.0) * (PI / 180.0)
	var t_avelocity: float = randf_range(-2 * PI, 2 * PI)
	var v_x: float = t_magnitude * cos(t_angle)
	var v_y: float = -t_magnitude * sin(t_angle)
	linear_velocity = Vector2(v_x, v_y)
	lock_rotation = false
	angular_velocity = t_avelocity
