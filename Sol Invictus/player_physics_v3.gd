extends RigidBody2D
class_name Player_Phys

enum physics_state {Ground,Ball,Air}

export(Resource) var char_data
onready var debugtext = $Debugtext_rect/Debugtext
onready var debug_back = $ColorRect
#rays
onready var rayparent = $Rays
onready var ray = $Rays/GroundRayL
onready var left_ray = $Rays/LeftRay1
onready var right_ray = $Rays/RightRay2
onready var groundrayL = $Rays/GroundRayL
onready var groundrayR = $Rays/GroundRayR
onready var groundrayM = $Rays/GroundRayM
onready var ceilingrayL = $Rays/CeilingRayL
onready var ceilingrayR = $Rays/CeilingRayR
var space

export(bool) var move_wallstick = true
export(bool) var move_machclimb = true
export(bool) var move_dash = true
export(bool) var move_machturn = true
export(bool) var move_drilldive = true
export(bool) var move_homingattack = true
export(bool) var move_spindash = true
export(bool) var move_dropdash = true

export(int) var X_Acceleration = 150
export(Curve) var Horizontal_Acceleration
export(int) var push_force = 900
export(int) var speed_limit = 500
export(int) var mach_speed = 250
export(int) var uncurl_speed = 150
export(int) var glue_force = 500
export(int) var glue_force_damp = 10
export(int) var max_attach_angle = 60
export(int) var mach_turn_speedlimit = 500
export(float) var normal_gravity = 1
export(float) var fall_gravity = 3
export(float) var ball_gravitydownslope = 2
export(float) var dropdash_charge_time = 4
export(float) var spindash_force = 3000

export(int) var drag_force = 20
export(int) var no_input_drag_force = 70
var jump_force = 17000
export(float) var angle_limit = 45.0
export(float) var jump_buffer_seconds = 0.2
var jump_buffer_timer = 0
export(bool) var debug = true

var player_state: int = physics_state.Air
var is_ball: bool = false
var is_diving: bool = false
var is_machturn: bool = false
var is_spindash: bool = false
var is_dropdash: bool = false
var did_homingattack: bool = false
var ground_speed: float = 0
var ground_distance: float
var ground_angle: float = 0
var ray_origin: Vector2
var ground_point: Vector2
var player_angle: float
var ground_normal = Vector2(0,0)
var external_force = Vector2(0,0)

var touching_ground: bool = false
var touching_jumpground: bool = false
var touching_leftwall: bool = false
var touching_ceiling: bool = false
var touching_rightwall: bool = false
var movingleft: bool

var jump: bool
var trick: bool # special move button, called the "trick button"
var trick_justpressed: bool
var horizontal: float
var up: bool
var left: bool
var right: bool
var down: bool
var vertical: float

export(float) var floatdist = 7.0

var grounded_graceperiod_time: float = 0.2
var grounded_graceperiod_timer: float = 0
var machturn_momentum: float = 0
var special_timer: float = 0
var special_value: float = 0

var homing_distance:float = 600
var close_enemy = []
export(Texture) var reticletexture

onready var chartest = get_node("/root/SingletonTest")
func _ready():
	
	# read character data
	char_data = chartest.selectedcharacter
	#mainsprite.frames = char_data.frames
	move_machclimb = char_data.move_machclimb
	move_dash = char_data.move_dash
	move_machturn = char_data.move_machturn
	move_drilldive = char_data.move_drilldive
	move_homingattack = char_data.move_homingattack
	move_spindash = char_data.move_spindash
	move_dropdash = char_data.move_dropdash
	Horizontal_Acceleration = char_data.Horizontal_Acceleration
	jump_force = char_data.jump_force
	mass = char_data.mass
	
	#_draw()
	debug = chartest.debug
	if (not debug):
		debugtext.visible = false
		debug_back.visible = false
	pass # Replace with function body.


func _process(delta):
	
	update()
	if (jump_buffer_timer > 0):
		jump_buffer_timer -= delta
	else:
		jump = false
	# issue: the player may still have downward velocity when they jump, 
	# reducing the jump height drastically.
	if Input.is_action_just_pressed("jump"): 
		jump = true
		jump_buffer_timer = jump_buffer_seconds
	
	if Input.is_action_pressed("trick"): trick = true
	else: trick = false
	
	if Input.is_action_just_pressed("trick"): trick_justpressed = true
	else: trick_justpressed = false
	
	if Input.is_action_pressed("jump"): up = true
	else: up = false
	
	if Input.is_action_pressed("ui_left"): left = true
	else: left = false
	
	if Input.is_action_pressed("ui_right"): right = true
	else: right = false
	
	if (Input.is_action_pressed("ui_down")): down = true
	else: down = false
	pass
	
	if (grounded_graceperiod_timer > 0):
		grounded_graceperiod_timer -= delta
		
	if (special_timer > 0):
		special_timer -= delta
	
	if (is_dropdash and player_state == physics_state.Air):
		if (special_value < 1):
			special_value += delta / dropdash_charge_time
	
	#position = Vector2(floor(position.x),floor(position.y)) # doesn't work on a rigidbody.

func _integrate_forces(_state):
	
	space = get_world_2d().direct_space_state
	applied_force = Vector2(0,0)
	is_grounded()

	match (player_state):
		
	# State Transitions
		physics_state.Air:
			
			if ( touching_jumpground and jump_buffer_timer <= 0):
				#print(String(abs(rayparent.rotation - deg2rad(ground_angle)) ))
				player_state = physics_state.Ground
				
				#eliminate vertical movement
				var vec = linear_velocity.dot(ground_normal)
				linear_velocity -= vec * ground_normal
				
				if (is_diving and ground_angle > 0 ):
					#linear_velocity = ground_normal.rotated(deg2rad(90)) * linear_velocity.length() * sin(deg2rad(ground_angle))
					#print("transfered dive momentum.")
					pass
				if (is_diving and ground_angle < 0 ):
					#linear_velocity = ground_normal.rotated(deg2rad(-90)) * linear_velocity.length() * sin(deg2rad(ground_angle))
					#print("transfered dive momentum.")
					pass
				
				is_diving = false
				
			external_force()
			
			if (jump_buffer_timer > 0):
				is_ball = true
			
			
			move_machclimb()
			if (move_homingattack):
				move_homingattack()
				
			if move_dropdash:
				move_DropDash()
		
		physics_state.Ground:
			ground_attachment()
			
			if ( not touching_ground or angle_difference(rayparent.rotation_degrees, ground_angle) >  max_attach_angle ):
				detach_from_wall()
			
			if ((rayparent.rotation_degrees > angle_limit) and linear_velocity.length() < mach_speed):
				#detach_from_wall()
				pass
				#print("too slow, fell off")
			
			if !(groundrayL.is_colliding() and groundrayR.is_colliding()):
				detach_from_wall()
			
			if jump:
				var vec = linear_velocity.dot(ground_normal)
				linear_velocity -= vec * ground_normal
				applied_force += ground_normal * jump_force
				jump = false
				is_machturn = false
				detach_from_wall()
			
			external_force()
			
		_:
			player_state = physics_state.Air
			detach_from_wall()
	
	match (player_state):
	# States
		physics_state.Air:
			if Input.is_action_pressed("ui_left"):
				applied_force += Vector2(-X_Acceleration,0)
			
			if Input.is_action_pressed("ui_right"):
				applied_force += Vector2(X_Acceleration,0)
			
			move_drilldive()
			# Apply spring force

			
			if (not up and grounded_graceperiod_timer > 0):
				gravity_scale = fall_gravity
			else: 
				gravity_scale = normal_gravity
			
			pass
		physics_state.Ground:
			
#			if (movingleft):
#				linear_velocity = ground_normal.rotated(deg2rad(90)) * -linear_velocity.length()
#			else:
#				linear_velocity = ground_normal.rotated(deg2rad(90)) * linear_velocity.length()
			
			float_capsule()
			applied_force += ground_normal * linear_velocity.dot(ground_normal) * 0.5
			
			
			
			if left and not is_machturn:
				applied_force += ground_normal.rotated(deg2rad(90)) * -Horizontal_Acceleration.interpolate(acceleration_curve_value())
				# turnaround force
				if (not movingleft):
					#applied_force += ground_normal.rotated(deg2rad(90)) * -linear_velocity.x * 4 / 1
					pass
				if (touching_leftwall):
					applied_force += ground_normal.rotated(deg2rad(90)) * -push_force
			if right and not is_machturn:
				applied_force += ground_normal.rotated(deg2rad(90)) * Horizontal_Acceleration.interpolate(acceleration_curve_value()) #* abs(cos(ground_angle))
				
				# turnaround force
				if (movingleft):
					#applied_force -= ground_normal.rotated(deg2rad(90)) * linear_velocity.x * 4 / 1
					pass
				if (touching_rightwall):
					applied_force += ground_normal.rotated(deg2rad(90)) * push_force
			
				#is_ball = true # doesnt work ??
			
			if down: is_ball = true
			else: is_ball = false
			
			if (move_spindash): move_SpinDash()
			if (trick or is_machturn): move_MachTurn()
			if move_dropdash: move_DropDash()
				
			# no input drag force
			if (not left and not right and not is_ball and not trick):
				applied_force -= linear_velocity.normalized() * no_input_drag_force
			else:
				applied_force -= linear_velocity.normalized() * drag_force
			
			
			

			
			
			if (move_wallstick and not is_ball):
				gravity_scale = 0
			else:
				gravity_scale = normal_gravity
			
			
			if (is_ball and linear_velocity.y >= 0):
				gravity_scale = ball_gravitydownslope
			else: 
				gravity_scale = normal_gravity
			
			# slow speed
			if (linear_velocity.length() < 2 and !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right") ) :
				linear_velocity = Vector2(0,0)
				pass
			
	
	clamp_velocity()
	if (debug): debug_text()
	
func overwrite_velocity(vel:Vector2):
	if (grounded_graceperiod_timer <= 0):
		vel = vel.clamped(speed_limit)
		linear_velocity = vel
		player_state = physics_state.Air
		grounded_graceperiod_timer = grounded_graceperiod_time # grace period timer
		detach_from_wall()
	
func apply_external_force(force):
	print("springforce")
	if (grounded_graceperiod_timer <= 0):
		external_force = force
		detach_from_wall()

func detach_from_wall():
	player_state = physics_state.Air
	gravity_scale = 1
	rayparent.rotation_degrees = 0
	jump_buffer_timer = jump_buffer_seconds
	grounded_graceperiod_timer = grounded_graceperiod_time 

func ground_attachment():
	
	if (angle_difference(rayparent.rotation_degrees, ground_angle) <= 90 and is_ball):
		rayparent.rotation_degrees = ground_angle
	if angle_difference(rayparent.rotation_degrees, ground_angle) <= max_attach_angle :
		rayparent.rotation_degrees = ground_angle
		#print(String(rayparent.rotation_degrees) + " " + String(ground_angle))
	else:
		print( "Kicked off slope: Player-ang: " + String(rayparent.rotation_degrees) + " Ground-ang: " + String( ground_angle ) + " | max-ang:" + String(max_attach_angle) )

func angle_difference(angle1, angle2):
	var diff = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))


func debug_text():
	var statetext
	match(player_state):
		physics_state.Air:
			statetext = "Air"
		physics_state.Ground:
			statetext = "Ground"
		physics_state.Ball:
			statetext = "Ball"
		_:
			statetext = "Invalid State"
	statetext += " State"
	debugtext.text = String(statetext) + "\nGrnd: " + String(touching_ground) + " | Ang: " + String(round(
		ground_angle)) + " | Player Ang: " + String(round(rad2deg(rayparent.rotation))) + "\n Grnd Dist: " + String(ground_distance) + "\n Vel: " + String(round(linear_velocity.length())
		) + " | " + String(linear_velocity.round()) + "\n movingleft: " + String(movingleft) + "\n " + String(acceleration_curve_value()) + "\n Ground Speed: " + String((ground_speed)
		) + "\n" + String(groundrayL.get_collision_normal().angle_to( Vector2(cos(rayparent.rotation), sin(rayparent.rotation)) ) - deg2rad(90)
		) + "\n" + String(trick) + " \n linvel dot normal: " + String(linear_velocity.dot(ground_normal)
		) + "\n Special Value: " + String(special_value)

func _draw():
	
	#draw_texture(reticletexture,Vector2(0,0))
	#draw_texture(reticletexture,position)
	
	if (closest_enemy() != null and move_homingattack and player_state == physics_state.Air):
		draw_texture(reticletexture,closest_enemy().position - position + Vector2(-40,-40))
	
	if (debug):
		draw_line(Vector2(0,0),ground_normal * 50,Color.crimson,1,false)
		draw_line(Vector2(0,0),ground_normal.rotated(deg2rad(90)) * 50,Color.chartreuse,1,false)
		draw_line(Vector2(0,0),linear_velocity,Color.cornflower,1,false)
	#draw_line(Vector2(0,0),target_pos,Color.bisque,1,false)
	#draw_line(Vector2(0,0),Vector2(spring_forceX,spring_forceY),Color.bisque,1,false)

func clamp_velocity():
	# speed limiter
	if (linear_velocity.length() > speed_limit):
		#applied_force += -linear_velocity.normalized() * pow((linear_velocity.length() - speed_limit),2)
		linear_velocity = linear_velocity.clamped(speed_limit)

func float_capsule():
	var spring_force = ground_normal * (floatdist - ground_distance) * glue_force
	var damp_force = ground_normal * linear_velocity.dot(ground_normal) * glue_force_damp
	#if (is_ball): damp_force = ground_normal * linear_velocity.dot(ground_normal) * glue_force_damp * ball_gravitydownslope
	applied_force += spring_force - damp_force

func move_dash():
	#boost
	if (move_dash):
		if (trick and left):
			applied_force += -1400 * ground_normal.rotated(deg2rad(90))
		if (trick and right):
			applied_force += 1400 * ground_normal.rotated(deg2rad(90))
			
func move_drilldive():
	if (trick and down and not is_diving and move_drilldive):
		linear_velocity = linear_velocity.length() * Vector2(0,1)
		external_force =  -55000 * Vector2(0,-1)
		is_diving = true

func move_MachTurn():
	if ( abs(ground_speed) > mach_speed and not is_machturn):
		if ( ((left and not movingleft) or (right and movingleft)) and trick ):
			is_machturn = true
			machturn_momentum = -clamp(ground_speed,-mach_turn_speedlimit,mach_turn_speedlimit)
	#if (is_machturn and abs(ground_speed) < 70):
	if (is_machturn):
		var val = -(ground_speed - machturn_momentum)
		
#		if (abs(val) > 400):
#			applied_force = ground_normal.rotated(deg2rad(90)) * val * 2
#		else:
		applied_force = ground_normal.rotated(deg2rad(90)) * 600 * sign(val) * 2
		
		#machturn_momentum = clamp(machturn_momentum,-mach_turn_speedlimit,mach_turn_speedlimit)
		#linear_velocity += ground_normal.rotated(deg2rad(90)) * -machturn_momentum * 2
		pass
		#machturn_momentum = 0
	
	if ( (touching_leftwall and machturn_momentum < 0 ) 
	or (touching_rightwall and machturn_momentum > 0) and player_state != physics_state.Air):
		is_machturn = false
	
	if (jump):
		is_machturn = false
	
	if (is_machturn and abs(ground_speed - machturn_momentum) <= 20):
		is_machturn = false


#func move_MachTurn():
#	if ( abs(ground_speed) > mach_speed and not is_machturn):
#		if ( ((left and not movingleft) or (right and movingleft)) and trick ):
#			is_machturn = true
#			machturn_momentum = ground_speed
#			special_timer = 0.7
#	#if (is_machturn and abs(ground_speed) < 70):
#	if (is_machturn and special_timer <= 0):
#		machturn_momentum = clamp(machturn_momentum,-mach_turn_speedlimit,mach_turn_speedlimit)
#		linear_velocity += ground_normal.rotated(deg2rad(90)) * -machturn_momentum * 2
#		machturn_momentum = 0
#		is_machturn = false

func move_machclimb():
	if (move_machclimb and linear_velocity.length() > mach_speed and not is_diving):
		if (touching_leftwall and not touching_ground): 
			player_state = physics_state.Ground
			rayparent.rotation_degrees = rad2deg( left_ray.get_collision_normal().angle() ) + 90
			linear_velocity = left_ray.get_collision_normal().rotated(deg2rad(-90)) * linear_velocity.length()
			print("Climbed onto left wall.")
		if (touching_rightwall and not touching_ground): 
			player_state = physics_state.Ground
			rayparent.rotation_degrees = rad2deg( right_ray.get_collision_normal().angle() ) + 90
			linear_velocity = right_ray.get_collision_normal().rotated(deg2rad(90)) * linear_velocity.length()
			print("Climbed onto right wall.")

func move_SpinDash():
	if (touching_ground and ground_speed < 40 and down and trick_justpressed):
		is_spindash = true
	
	if (is_spindash):
		linear_velocity = Vector2(0,0)
	
	if (is_spindash and not down):
		is_spindash = false
		if (movingleft):
			applied_force += -spindash_force * 4 * ground_normal.rotated(deg2rad(90))
		else: 
			applied_force += spindash_force * 4 *  ground_normal.rotated(deg2rad(90))

func move_DropDash():
	if (trick_justpressed and player_state == physics_state.Air and not down):
		is_dropdash = true
		special_value = 0
	
	if (is_dropdash and is_diving):
		is_dropdash = false
	
	if (is_dropdash and player_state == physics_state.Ground):
		is_dropdash = false
		if (left):
			applied_force += -jump_force  * ground_normal.rotated(deg2rad(90)) * special_value
		else: if (right):
			applied_force += jump_force *  ground_normal.rotated(deg2rad(90)) * special_value
		else: if (movingleft):
			applied_force += -jump_force  * ground_normal.rotated(deg2rad(90)) * special_value
		else: 
			applied_force += jump_force *  ground_normal.rotated(deg2rad(90)) * special_value


func closest_enemy():
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	var closestenemy = null
	for enemy in all_enemy:
		var enemy_distance = position.distance_to(enemy.position)
		if enemy_distance < homing_distance:
			if (closestenemy == null):
				closestenemy = enemy
			if enemy_distance < position.distance_to(closestenemy.position):
				closestenemy = enemy
	return closestenemy
			

func move_homingattack():
	var enemy = closest_enemy()
	if (player_state == physics_state.Ground):
		did_homingattack = false
	
	if (trick and !down and !is_diving and  enemy != null and !did_homingattack):
		var direction = enemy.position - position
		linear_velocity = direction.normalized() * 600
		did_homingattack = true
	

func external_force():
	if ( external_force != Vector2(0,0) ):
		
		var vec = linear_velocity.dot(external_force.normalized())
		#if (vec > 0): vec = 0
		#linear_velocity -= vec * external_force.normalized()
		applied_force += external_force
		external_force = Vector2(0,0)
		detach_from_wall()
		#grounded_graceperiod_timer = grounded_graceperiod_time # grace period timer
		#rayparent.rotation_degrees = 0

func acceleration_curve_value():
	var OldValue = abs(ground_speed)
	if left and not movingleft:
		OldValue = -ground_speed
	if right and movingleft:
		OldValue = -abs(ground_speed)
	
	var OldMin = -speed_limit
	var OldRange = speed_limit + speed_limit
	var NewRange = 1
	var NewMin = 0

	var NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin
	return NewValue


func is_grounded():
	
	if (grounded_graceperiod_timer > 0):
		touching_ground = false
		return false
	if (linear_velocity.length() > 40):
		if (linear_velocity.angle_to(ground_normal) > deg2rad(45)):
			movingleft = true
		else:
			movingleft = false
	else:
		if left:
			movingleft = true
		else: if right:
			movingleft = false
	
	if left_ray.is_colliding(): touching_leftwall = true
	else: touching_leftwall = false
	
	if right_ray.is_colliding(): touching_rightwall = true
	else: touching_rightwall = false
	
	if (groundrayM.is_colliding()): 
		touching_jumpground = true
		if (not touching_ground): pass
	else: touching_jumpground = false
	
	if ( groundrayL.is_colliding() and groundrayL.is_colliding() ):
		if ( groundrayL.global_position.distance_to(groundrayL.get_collision_point()) < groundrayR.global_position.distance_to( groundrayR.get_collision_point()) ):
			if ( groundrayL.get_collision_normal().angle_to( Vector2(cos(rayparent.rotation), sin(rayparent.rotation)) ) - deg2rad(90) > deg2rad(max_attach_angle) ):
				touching_ground = false
				return false
			if (groundrayL.get_collider() != null):
				if groundrayL.get_collider().get_collision_layer() == 4 and linear_velocity.y <= 0 :
					touching_ground = false
					return false
			ground_normal = groundrayL.get_collision_normal()
			ground_angle = rad2deg( groundrayL.get_collision_normal().angle() ) + 90
			ground_distance = groundrayL.global_position.distance_to( groundrayL.get_collision_point() )
			ground_speed = linear_velocity.dot( ground_normal.rotated(deg2rad(90)) )
			ground_point = groundrayL.get_collision_point()
			ray_origin = groundrayL.global_position
			touching_ground = true
			return true
		else:
			if ( groundrayR.get_collision_normal().angle_to( Vector2(cos(rayparent.rotation), sin(rayparent.rotation)) ) - deg2rad(90) > deg2rad(max_attach_angle) ):
				touching_ground = false
				return false
			if (groundrayR.get_collider() != null):
				if groundrayR.get_collider().get_collision_layer() == 4 and linear_velocity.y <= 0 :
					touching_ground = false
					return false
			ground_normal = groundrayR.get_collision_normal()
			ground_angle = rad2deg(groundrayR.get_collision_normal().angle()) + 90
			ground_distance = groundrayR.global_position.distance_to(groundrayR.get_collision_point())
			touching_ground = true
			ground_point = groundrayR.get_collision_point()
			ray_origin = groundrayR.global_position
			ground_speed = linear_velocity.dot( ground_normal.rotated(deg2rad(90)) )
			return true
	else: 
		if groundrayL.is_colliding(): 
			if ( groundrayL.get_collision_normal().angle_to( Vector2(cos(rayparent.rotation), sin(rayparent.rotation)) ) - deg2rad(90) > deg2rad(max_attach_angle) ):
				touching_ground = false
				return false
			if (groundrayL.get_collider() != null):
				if groundrayL.get_collider().get_collision_layer() == 4 and linear_velocity.y <= 0 :
					touching_ground = false
					return false
			ground_normal = groundrayL.get_collision_normal()
			ground_angle = rad2deg( groundrayL.get_collision_normal().angle() ) + 90
			ground_distance = groundrayL.global_position.distance_to( groundrayL.get_collision_point() )
			ground_speed = linear_velocity.dot( ground_normal.rotated(deg2rad(90)) )
			ground_point = groundrayL.get_collision_point()
			ray_origin = groundrayL.global_position
			touching_ground = true
			return true
		if groundrayR.is_colliding():
			if ( groundrayR.get_collision_normal().angle_to( Vector2(cos(rayparent.rotation), sin(rayparent.rotation)) ) - deg2rad(90) > deg2rad(max_attach_angle) ):
				touching_ground = false
				return false
			if (groundrayR.get_collider() != null):
				if groundrayR.get_collider().get_collision_layer() == 4 and linear_velocity.y <= 0 :
					touching_ground = false
					return false
			ground_normal = groundrayR.get_collision_normal()
			ground_angle = rad2deg(groundrayR.get_collision_normal().angle()) + 90
			ground_distance = groundrayR.global_position.distance_to(groundrayR.get_collision_point())
			touching_ground = true
			ground_speed = linear_velocity.dot( ground_normal.rotated(deg2rad(90)) )
			ground_point = groundrayR.get_collision_point()
			ray_origin = groundrayR.global_position
			return true

	if not groundrayL.is_colliding() and not groundrayL.is_colliding():
		touching_ground = false
		return false
