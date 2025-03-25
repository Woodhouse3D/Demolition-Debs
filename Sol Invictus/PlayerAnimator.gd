extends Node2D

enum physics_state {Ground,Ball,Air}
onready var playerrb: Player_Phys = get_parent()

onready var mainsprite = $Rotator/MainSprite
onready var ballglow = $Rotator/Ball_glow
onready var rotator = $Rotator
onready var machsprite = $MachParent/Mach
onready var machparent = $MachParent
#onready var rayparent = $Rays
onready var cameraparent = $CameraParent
onready var dropdash_glow = $Rotator/Glow_dropdash
onready var dropdash_animator = $Rotator/Glow_dropdash/AnimationPlayer
export(Resource) var char_data
onready var chartest = get_node("/root/SingletonTest")

var flash: bool = false
var flash_on: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# read character data
	char_data = chartest.selectedcharacter
	mainsprite.frames = char_data.frames
	#dropdash_animator.playback_active = true
	pass # Replace with function body.


func _process(delta):
	animate()

func hit_animation(active:bool):
	
	if (active): flash = true
	else: flash = false

func animate():
	
	var spriteanim = "Idle"
	
	match (playerrb.player_state):
		physics_state.Air:
			spriteanim = animation_air()
		physics_state.Ground:
			spriteanim = animation_ground()
	
	if (mainsprite.animation != spriteanim):
		mainsprite.play(spriteanim)

	cameraparent.global_position = Vector2(playerrb.linear_velocity.x / 2, -128 + playerrb.linear_velocity.y / 4) + playerrb.position
	if (playerrb.linear_velocity.y > 0):
		cameraparent.global_position = Vector2(playerrb.linear_velocity.x / 2, -128 + playerrb.linear_velocity.y / 3) + playerrb.position
	cameraparent.global_position = Vector2(floor(cameraparent.global_position.x),floor(cameraparent.global_position.y))
	
	if (flash and flash_on):
		mainsprite.material.set_shader_param("flash",true)
	else: mainsprite.material.set_shader_param("flash",false)
	
#	if (abs(playerrb.linear_velocity.length()) > playerrb.mach_speed):
#		if (playerrb.player_state == physics_state.Air): 
#			machsprite.visible = false
#			ballglow.visible = true
#		else: 
#			machsprite.visible = true
#			ballglow.visible = false
#	else:
#		machsprite.visible = false
#		ballglow.visible = false
	if (abs(playerrb.linear_velocity.length()) > playerrb.mach_speed):
		machsprite.visible = true
	else:
		machsprite.visible = false
		ballglow.visible = false
	
	#mainsprite.speed_scale = 10 * abs(ground_speed) / speed_limit
	
	var ang = rotator.rotation_degrees
	if (playerrb.touching_ground):
		ang = playerrb.ground_angle
	else:
		if (ang > 0):
			ang -= 1
		else:
			ang += 1
	rotator.rotation_degrees = ang
	if (playerrb.player_state == physics_state.Air):
		#rayparent.rotation_degrees = ang
		pass
	var scale = 4
	
	
	machparent.rotation = playerrb.linear_velocity.angle()
	
	if playerrb.linear_velocity.length() > 5 and not playerrb.is_machturn:
		if (not playerrb.movingleft):
			rotator.scale = Vector2(scale,scale)
		else: if (playerrb.movingleft):
			rotator.scale = Vector2(-scale,scale)

func animation_air():
	var spriteanim
	if (true):
		spriteanim = "Ball"
		mainsprite.speed_scale = 10 * abs(playerrb.ground_speed) / playerrb.speed_limit
		ballglow.speed_scale = 10 * abs(playerrb.ground_speed) / playerrb.speed_limit
		if (abs(playerrb.ground_speed) < 100 and playerrb.player_state == physics_state.Air): mainsprite.speed_scale = 2
	if (playerrb.is_diving):
		spriteanim = "Dive"
	
	if playerrb.is_dropdash:
		dropdash_glow.visible = true
		dropdash_animator.set_speed_scale(7 * playerrb.special_value)
	else:
		dropdash_glow.visible = false
		
	return spriteanim


func animation_ground():
	var spriteanim
	
	dropdash_glow.visible = false
	
	if (playerrb.is_ball):
		spriteanim = "Ball"
		mainsprite.speed_scale = 10 * abs(playerrb.ground_speed) / playerrb.speed_limit
		if (abs(playerrb.ground_speed) < 100 and playerrb.player_state == physics_state.Air): mainsprite.speed_scale = 2
	
	if (playerrb.is_machturn):
		spriteanim = "Mach Turn"
	
	if (playerrb.is_spindash):
		spriteanim = "Spin Dash"
	
	if not playerrb.is_ball and not playerrb.is_diving and not playerrb.is_machturn:
		if (abs(playerrb.ground_speed) > playerrb.speed_limit * 0.5):
			spriteanim = "Run"
			mainsprite.speed_scale = 1
		else: if (abs(playerrb.ground_speed) > 50):
			spriteanim = "Walk"
			mainsprite.speed_scale = 10 * abs(playerrb.ground_speed) / playerrb.speed_limit
		else: if (abs(playerrb.ground_speed) > 5):
			spriteanim = "Tip Toe"
			mainsprite.speed_scale = 1
		else: 
			spriteanim = "Idle"
			mainsprite.speed_scale = 1
			
			pass
	
	
	return spriteanim


func _on_Flasher_timeout():
	flash_on = !flash_on
	pass # Replace with function body.
