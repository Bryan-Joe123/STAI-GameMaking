extends Control

var inventory

func _ready():
	pass

func _physics_process(delta):
	inventory = get_parent().inventory
	
	var count = 1
	for x in inventory:
		#print("Inventory/Item"+str(count)+"glow-rock")
		get_node("Inventory/Item1/glow-rock").visible = true
		count+=1
		pass
	pass
