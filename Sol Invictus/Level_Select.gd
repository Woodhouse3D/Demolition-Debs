extends Node2D

export(Resource) var scene1
export(Resource) var scene2
export(Resource) var scene3

func _on_Button_button_down():
	get_tree().change_scene("res://Levels/Tutorial.tscn")
	pass # Replace with function body.

func _on_Iguanopolis_Buttom_button_down():
	get_tree().change_scene("res://Levels/Iguanopolis_Act2.tscn")

func _on_PipelinePine_button_button_down():
	get_tree().change_scene("res://Levels/Sundown Showroom.tscn")


func _on_Testroom_button_button_down():
	get_tree().change_scene("res://Levels/test.tscn")
	pass # Replace with function body.
