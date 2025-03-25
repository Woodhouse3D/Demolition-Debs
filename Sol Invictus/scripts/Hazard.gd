extends Node2D
class_name Hazard
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(int) var spring_force = 12000
signal activated


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	print(body)
	if (body is Player_Phys):
		pass
	pass # Replace with function body.
