extends Area2D

signal goal_reached


func _on_Goal_Ring_body_entered(body):
	if (body is Player_Phys):
		print("Reached Goal.")
		emit_signal("goal_reached")
		pass
	pass # Replace with function body.
