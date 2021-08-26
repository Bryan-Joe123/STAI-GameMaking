extends Control

var pointed = "" 
var toggle_tip = false

func _physics_process(delta):
	update_ui()
	pass

func update_ui():
	var inventory = get_parent().inventory
	var selected = get_parent().selected
	var required = get_parent().required
	
	$TextEdit.text="Requirements:"
	for x in required:
		$TextEdit.text=$TextEdit.text+"\n"+x.item.capitalize()+"{"+str(x.amount)+"}"
		pass
	
	if Input.is_action_just_pressed("toggle_tip") and toggle_tip==false:
		toggle_tip = true
		$AnimationPlayer.play("Open")
	elif Input.is_action_just_pressed("toggle_tip") and toggle_tip==true:
		toggle_tip = false
		$AnimationPlayer.play("Close")
		
	if required==[]:
		get_tree().change_scene("res://Scenes/Credits.tscn")
	
	$Pointed.text = pointed
	
	for x in $Inventory.get_children().size():
		for y in $Inventory.get_children()[x].get_children():
			y.visible=false
		get_node("Inventory/Item"+str(x)).set_self_modulate("3cffffff")
		pass
	get_node("Inventory/Item"+str(selected)).set_self_modulate("9fffffff")
	
	for x in inventory.size():
		#Display Item
		get_node("Inventory/Item"+str(x)+"/"+inventory[x].item).visible=true
		
		#Amount Display
		if inventory[x].amount>0:
			get_node("Inventory/Item"+str(x)+"/Count").visible = true
			get_node("Inventory/Item"+str(x)+"/Count").text=str(inventory[x].amount)
	pass





