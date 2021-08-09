extends Control

export var text = "O"

func _ready():
	var label = Label.new()
	label.text=text
	#label.add_font_override()
	add_child(label)
	pass
