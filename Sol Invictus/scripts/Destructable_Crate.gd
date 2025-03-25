extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(bool) var mach_required = true
export(bool) var is_ring = false
export(bool) var can_interact = true
onready var test = get_node("/root/SingletonTest")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	
	if (body is Player_Phys and can_interact):
		print("Hit player")
		if (is_ring):
			test.ring_count += 1
		
		if (not mach_required):
			self.queue_free()
		if (abs(body.linear_velocity.length()) > body.mach_speed):
				self.queue_free()
		
	pass # Replace with function body.


func _on_Timer_timeout():
	pass # Replace with function body.


func _on_CanCollectTimer_timeout():
	can_interact = true
	pass # Replace with function body.
