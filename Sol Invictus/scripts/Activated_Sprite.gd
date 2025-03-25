extends AnimatedSprite

export(float) var timer = 0.2
var timerdelta = 0

func _process(delta):
	if (timerdelta > 0):
		timerdelta -= delta
	if (timerdelta <= 0):
		animation = "Base"
		
func animate_spring():
	animation = "Active"
	timerdelta = timer



func _on_Round_Bumper_activated():
	animate_spring()
	pass # Replace with function body.
