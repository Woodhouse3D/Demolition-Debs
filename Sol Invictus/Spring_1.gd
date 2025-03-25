extends RigidBody2D

enum s_mode {Force,Velocity}

onready var spring = $Springtest2
export(float) var timer = 0.5
export(float) var spring_force = 18000.0
export(float,0,1200,1) var spring_velocity = 10
var timerdelta = 0
export(s_mode) var spring_mode
export(bool) var does_bounce: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if (timerdelta > 0):
		timerdelta -= delta
	if (timerdelta <= 0):
		spring.animation = "Base"

func animate_spring():
	spring.animation = "Bounce"
	timerdelta = timer
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	print(body)
	if (body is Player_Phys):
		if (spring_mode == s_mode.Force):
			body.apply_external_force( Vector2(cos(rotation),
			 sin(rotation)).rotated(deg2rad(90))  * -spring_force )
		else:
			body.overwrite_velocity( Vector2(cos(rotation),
			 sin(rotation)).rotated(deg2rad(90))  * -spring_velocity )
	else: if (body != self and body is RigidBody2D):
		body.apply_impulse( Vector2(0,0), Vector2(cos(rotation), sin(rotation)).rotated(deg2rad(90))  * -spring_force)
		
	if (body != self):
		animate_spring()
