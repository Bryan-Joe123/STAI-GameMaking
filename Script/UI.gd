extends Control

var inventory
var selected = 1


func _ready():
	pass

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		event as InputEventMouseButton
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_DOWN:
					get_node("Inventory/Item"+str(selected)).set_self_modulate('#87ffffff')
					if selected<8:
						selected += 1
					else:
						selected = 1
					get_node("Inventory/Item"+str(selected)).set_self_modulate('#ffffffff')
				BUTTON_WHEEL_UP:
					get_node("Inventory/Item"+str(selected)).set_self_modulate('#87ffffff')
					if selected>1:
						selected -= 1
					else:
						selected = 8
					get_node("Inventory/Item"+str(selected)).set_self_modulate('#ffffffff')
			
			print(selected)

func _physics_process(delta):
	inventory = get_parent().inventory
	
	var count = 1
	for x in inventory:
		print(inventory[count-1].item)
		get_node("Inventory/Item"+str(count)+"/"+str(inventory[count-1].item)).visible = true
		get_node("Inventory/Item"+str(count)+"/Count").text = str(x.value)
		
		if x.value>0:
			get_node("Inventory/Item"+str(count)+"/Count").visible = true
		else:
			get_node("Inventory/Item"+str(count)+"/Count").visible = false
		
		count+=1
		pass
	pass
