extends Node2D

export(Resource) var ringprefab
onready var singleton = get_node("/root/SingletonTest")
onready var player_physics: Player_Phys = get_parent()
onready var invincible_timer = $InvincibilityTimer
onready var playeranim = get_parent().get_node("Animator")

#export(float) var iframe_seconds: float = 2

export(float) var hurtforce: float = 55000

var can_collect_rings: bool = true
var invincible: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn_ring():
	var ring = ringprefab.instance()
	get_parent().get_parent().get_node("Interactable").add_child(ring)
	ring.position = Vector2(global_position.x, global_position.y -23)
	ring.linear_velocity = Vector2(
		rand_range(-500,500),rand_range(-500,500))

func hit():
	var i = 1
	while (i < singleton.ring_count):
		spawn_ring()
		i += 1
	
	singleton.ring_count = 0
	invincible = true
	invincible_timer.start()
	playeranim.hit_animation(true)


func _on_Timer_timeout():
	
	pass # Replace with function body.

func _on_Hitbox_body_entered(body):
	collision(body)
	pass # Replace with function body.

func _on_Hitbox_area_entered(area):
	collision(area)
	pass # Replace with function body.

func collision(body):
	if (body.is_in_group("Hazard") and not invincible):
		#body.linear_velocity = Vector2(0,0)
		print("hit hazard")
		var vec = (body.global_position - Vector2(
			player_physics.global_position.x,player_physics.global_position.y + 23) ).normalized()
		print(vec)
		player_physics.overwrite_velocity( -vec * hurtforce )
		hit()

func _on_InvincibilityTimer_timeout():
	invincible = false
	playeranim.hit_animation(false)
	pass # Replace with function body.



