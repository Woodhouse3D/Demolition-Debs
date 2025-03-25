extends KinematicBody2D


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


func _physics_process(delta):
	var new_velocity = Vector2(0,0)
	
	move_and_collide(Vector2(0, 1))
	
	space = get_world_2d().direct_space_state
	
	if (is_grounded()):
		new_velocity.x = ground_speed * cos(ground_angle)
		new_velocity.y = ground_speed * -sin(ground_angle)
		#move_and_collide(new_velocity)
		move_and_slide(new_velocity)
	
	
	if Input.is_action_pressed("ui_left"):
		if (is_grounded() and ground_normal != Vector2(0,0)):
			ground_speed = 50
			pass
		
	if Input.is_action_pressed("ui_right"):
		if (is_grounded() and ground_normal != Vector2(0,0) ):
			ground_speed = -50
	
	
	debugtext.text = "Ground: " + String(is_grounded()) + " Ang: " + String(ground_angle) + "\n" + String(new_velocity)

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
