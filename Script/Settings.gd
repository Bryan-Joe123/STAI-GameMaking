extends Control

func _ready():
	pass

func _on_Slider_value_changed(value):
	if value == 0:
		global.graphics="lowest"
	elif value == 1:
		global.graphics="low"
	elif value == 2:
		global.graphics="mid"
	elif value == 3:
		global.graphics="high"


func _on_New_Game_pressed():
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
	pass
