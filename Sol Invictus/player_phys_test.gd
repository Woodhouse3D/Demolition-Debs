extends KinematicBody2D

onready var debugtext = $VBoxContainer/RichTextLabel
#rays
onready var ray = $Rays/GroundRayL
onready var left_ray = $Rays/LeftRay1
onready var right_ray = $Rays/RightRay2
onready var groundrayL = $Rays/GroundRayL
onready var groundrayR = $Rays/GroundRayR
onready var ceilingrayL = $Rays/CeilingRayL
onready var ceilingrayR = $Rays/CeilingRayR

var ground_normal = Vector2(0,0)
var ground_angle: float = 0
var ground_speed = 0

const GRAVITY = 200.0
const WALK_SPEED = 200

var velocity = Vector2()

func _physics_process(delta):
	
	velocity.y += delta * GRAVITY
	if Input.is_action_pressed("ui_left"):
		velocity.x = -WALK_SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  WALK_SPEED
	else:
		velocity.x = 0


	if Input.is_action_pressed("ui_left"):
		ground_speed += -2 * sin(ground_angle)
	elif Input.is_action_pressed("ui_right"):
		ground_speed += 2 * sin(ground_angle)
	else:
		#ground_speed += cos(ground_angle)
		pass
		
	# We don't need to multiply velocity by delta because "move_and_slide" already takes delta time into account.

	# The second parameter of "move_and_slide" is the normal pointing up.
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	
	if is_grounded():
		move_and_slide(Vector2(ground_speed,0), ground_normal * 10)
	else:
		move_and_slide(velocity, Vector2(0, -1))

	debugtext.text = "Ground: " + String(is_grounded()) + " Ang: " + String(
		ground_angle) + "\n" + String(ground_speed)

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
