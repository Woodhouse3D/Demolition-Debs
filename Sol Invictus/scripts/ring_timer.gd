extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func _process(delta):
	pass

func _on_Timer_timeout():
	get_parent().queue_free()
	pass # Replace with function body.
