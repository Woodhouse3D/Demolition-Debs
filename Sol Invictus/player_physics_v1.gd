extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum physics_state {Ground,Ball,Air}

#rays
onready var ray = $Rays/GroundRayL
onready var left_ray = $Rays/LeftRay1
onready var right_ray = $Rays/RightRay2
onready var groundrayL = $Rays/GroundRayL
onready var groundrayR = $Rays/GroundRayR
onready var ceilingrayL = $Rays/CeilingRayL
onready var ceilingrayR = $Rays/CeilingRayR


onready var debugtext = $VBoxContainer/RichTextLabel
onready var mainsprite = $Rotator/AnimatedSprite
onready var rotator = $Rotator

var space
var ground_normal = Vector2(0,0)
var ground_ray
var up = Vector2(0,-100)
var pos = Vector2(0,0)
export(int) var X_Acceleration = 30
export(int) var speed_limit = 200
export(int) var glue_force = 10
var raydist = 10
var downweight= 20
export(int) var jump_force = 8000
export(float) var angle_limit = 45

var ground_speed: float = 10
var player_angle: float
var ground_angle: float = 0

var touch_floor: bool = false
var touch_leftwall: bool = false
var touch_ceiling: bool = false
var touch_rightwall: bool = false

var jump_speed = 200
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _integrate_forces(state):
	
	applied_force = Vector2(0,0)
	var new_velocity = Vector2(0,0)
	#var ground_angle = 0
	
	space = get_world_2d().direct_space_state
	#normaler_grounded()
	
	if Input.is_action_just_pressed("ui_up") && is_grounded():
		#jump()
		new_velocity.y = -jump_speed
		if (ground_normal == Vector2(0,0)):
			applied_force = Vector2(0,-jump_force)
		else:
			applied_force = ground_normal * jump_force
		#print("dffhgh")
	
	if Input.is_action_pressed("ui_left"):
		if (is_grounded() and ground_normal != Vector2(0,0)):
			#apply_impulse(pos, ground_normal.rotated(deg2rad(90)) * -X_Acceleration)
			#applied_force += ground_normal.rotated(deg2rad(90)) * -X_Acceleration
			ground_speed += 1
			pass
		else:
			#apply_impulse(pos,Vector2(-X_Acceleration,0))
			applied_force = Vector2(-X_Acceleration,0)
		
	if Input.is_action_pressed("ui_right"):
		if (is_grounded() and ground_normal != Vector2(0,0) ):
			#applied_force += ground_normal.rotated(deg2rad(90)) * X_Acceleration
			ground_speed -= 1
			#apply_impulse(pos, ground_normal.rotated(deg2rad(90)) * X_Acceleration)
			pass
		else:
			applied_force = Vector2(X_Acceleration,0)
		
	
#	if (linear_velocity.x > speed_limit):
#		linear_velocity = Vector2(speed_limit,linear_velocity.y)
#	if (linear_velocity.x < -speed_limit):
#		linear_velocity = Vector2(-speed_limit,linear_velocity.y)
	
	# sprite flipper
	if (linear_velocity.x > 0):
		mainsprite.scale = Vector2(1,1)
	else: if (linear_velocity.x < 0):
		mainsprite.scale = Vector2(-1,1)
	
	if (linear_velocity.x > 0 or linear_velocity.x < 0):
		mainsprite.animation = "Run"
	else:
		mainsprite.animation = "Idle"
	
#	if (linear_velocity.y < 0):
#		weight = downweight
#	else:
#		weight = 9.8
	
	
	
	if is_grounded():
		new_velocity.x = ground_speed * cos(-ground_angle) * X_Acceleration
		new_velocity.y = ground_speed * -sin(-ground_angle) * X_Acceleration
		applied_force = new_velocity
		applied_force += ground_normal * -glue_force
		#apply_impulse(pos,ground_normal * -glue_force)
		pass
	
	rotate_to_ground()
	
	debugtext.text = "Ground: " + String(is_grounded()) + " Ang: " + String(ground_angle) + "\n" + "V: [" + String(round(linear_velocity.x)
	) + "," + String(round(linear_velocity.y)) + "]\n" + String(rotation_degrees
	) + String(ground_normal)

func jump():
	if (!normaler_grounded()):
			return
	apply_impulse(pos,ground_normal * jump_force)

func is_grounded():
	
	if groundrayL.is_colliding():
		ground_normal = groundrayL.get_collision_normal()
		ground_angle = rad2deg(groundrayL.get_collision_normal().angle()) + 90
		return true
	
	if groundrayR.is_colliding():
		ground_normal = groundrayR.get_collision_normal()
		ground_angle = rad2deg(groundrayR.get_collision_normal().angle()) + 90
		return true
	
	return false
	
func get_floor_angle():
	 pass
	


func normaler_grounded():
	var ray2 = space.intersect_ray(Vector2(position.x,position.y),Vector2(position.x,position.y+raydist),[self])
	update()
	#_draw()
	if ray2:
		ground_normal = ray2.normal
		ground_ray = ray2
		return true
	return false


func _draw():
	draw_line(Vector2(0,0),Vector2(0,raydist),Color.whitesmoke,1,false)

func rotate_to_ground():
	var ang = rotator.rotation_degrees
	if (is_grounded()):
		
		ang = ground_angle
	else:
		if (ang > 0):
			ang -= 1
		else:
			ang += 1
	rotator.rotation_degrees = ang

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
