extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	$HTerrain/Camera.rotation_degrees.y+=0.1
	pass

func _on_New_Game_pressed():
	get_tree().change_scene("res://Scenes/Story.tscn")
	pass


func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/Settings.tscn")
	pass


func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.play()
	pass


func _on_Quit_pressed():
	get_tree().quit()
	pass # Replace with function body.
