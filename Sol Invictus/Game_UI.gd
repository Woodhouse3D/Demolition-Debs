extends CanvasLayer

export(Resource) var scene1

onready var timertext = $TimerText
onready var ringtext = $RingText
onready var speedgauge = $SpeedGauge

var goalring
onready var test = get_node("/root/SingletonTest")
var playerrb

var timer: float = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var level_running: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	goalring = get_parent().get_node("Goal_Ring")
	playerrb = get_parent().get_node("Player_RigidBody")
	goalring.connect("goal_reached", self, "_on_Goal_Ring_goal_reached")
	test.ring_count = 0
	pass # Replace with function body.
	
func _process(delta):
	if (level_running):
		timer += delta
		var txt = "Time:\n " + String(stepify(timer,0.01))
		timertext.text = txt
	
	ringtext.text = String(test.ring_count)
	
	#print(String(speedgauge.name))
	speedgauge.rotation_degrees = -90 + 180 * ( playerrb.linear_velocity.length() / playerrb.speed_limit) 
	

func _on_Back_Button_button_down():
	get_tree().change_scene("res://Level_Select.tscn")


func _on_Goal_Ring_goal_reached():
	print("recieved end message")
	level_running = false
	pass # Replace with function body.
