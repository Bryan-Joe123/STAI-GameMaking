extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("story")
	pass # Replace with function body.

func change():
	get_tree().change_scene("res://Scenes/MainScene.tscn")

func _physics_process(delta):
	if Input.is_action_pressed("ui_accept"):
		change()
