extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var colorrect1 = $ColorRect
onready var colorrect2 = $ColorRect2
onready var colorrect3 = $ColorRect3
onready var chartext = $Chartext

export(Resource) var char1
export(Resource) var char2
export(Resource) var char3

onready var test = get_node("/root/SingletonTest")
# Called when the node enters the scene tree for the first time.
func _ready():
	add_items()
	test.selectedcharacter = char1
	chartext.text = char1.description
	pass # Replace with function body.


func add_items():
	add_item(" Harvey")
	add_item(" Metal")
	add_item(" Nacht")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Character_Select_item_selected(index):
	
	if (index == 0): 
		colorrect1.visible = true
		test.selectedcharacter = char1
		chartext.text = char1.description
	else: colorrect1.visible = false
	if (index == 1): 
		colorrect2.visible = true
		test.selectedcharacter = char2
		chartext.text = char2.description
	else: colorrect2.visible = false
	if (index == 2): 
		colorrect3.visible = true
		test.selectedcharacter = char3
		chartext.text = char3.description
	else: colorrect3.visible = false
	
	
	pass # Replace with function body.


func _on_CheckBox_toggled(button_pressed):
	test.debug = button_pressed
	pass # Replace with function body.
