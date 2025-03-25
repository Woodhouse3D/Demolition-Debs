extends Area2D


export(float) var spring_force = 18000
var body_rotation = 0
signal spring

# Called when the node enters the scene tree for the first time.
func _ready():
	body_rotation = self.get_parent().rotation
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	print(body)
	if (body is Player_Phys):
		body.apply_impulse( Vector2(0,0), Vector2( cos(body_rotation),sin(body_rotation)).rotated(deg2rad(90) )  * -spring_force )
		emit_signal("spring")
	pass # Replace with function body.
