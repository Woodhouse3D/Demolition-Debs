extends RigidBody2D


# Declare member variables here. Examples:
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var springforce = 2000
onready var ray = $RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready():
	contact_monitor = true
	contacts_reported = 2
	pass # Replace with function body.

func _process(_delta):
	
	if (ray.is_colliding()):
		pass
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Spring_body_entered(body):
	
	print("34")
	if body.layer == 2:
		print("345345")
	pass # Replace with function body.
