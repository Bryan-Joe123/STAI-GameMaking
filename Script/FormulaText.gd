extends Control

export var text = "O"

func _ready():
	var label = Label.new()
	label.text=text
	add_child(label)
	add_child(label)
	add_child(label)
	add_child(label)
	add_child(label)
	pass
