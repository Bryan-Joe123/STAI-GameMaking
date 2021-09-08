extends KinematicBody

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT
var gravity = 5
var jump = 10
var tutorial = false
var tut_num = 0
var tut_timer = true
const tut_lines = [
	"WELCOME TO THE TUTORIAL",
	"You will learn how to play the Game",
	"Pick Up metals on the floor",
	"Switch to Bronze(CuSn) with scroll wheel and right click on the seperator",
	"Now you have seperated Bronze into Copper and Tin",
	"Right Click on the space ship with copper in you hand",
	"Notice how the requirments for the bronze went down"
]

var seperate_data=[
	{"in":"steel","out1":"iron","out2":"carbon","amount":1},
	{"in":"brass","out1":"copper","out2":"zinc","amount":1},
	{"in":"magnalium","out1":"aluminum","out2":"magnesium","amount":1},
	{"in":"bronze","out1":"copper","out2":"tin","amount":1},
]

var combine_data=[
	{"in":["iron","carbon"],"out":"steel","amount":1},
	{"in":["tin","copper"],"out":"bronze","amount":1},
	{"in":["copper","zinc"],"out":"brass","amount":1},
	{"in":["aluminum","magnesium"],"out":"magnalium","amount":1},
]

var required=[
	{"item":"copper","amount":3},
	{"item":"brass","amount":2},
	{"item":"steel","amount":5},
	{"item":"aluminum","amount":5},
	{"item":"magnalium","amount":3},
]

var combine_selected = ""
var inventory = []
var selected = 0

var pause = false

var cam_accel = 40
var mouse_sense = 0.15
var snap

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

onready var head = $Head
onready var camera = $Head/Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion and pause==false:
		
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
	
	#Switch Inv
	if event is InputEventMouseButton:
		if event.is_pressed():
			# UP
			if event.button_index == BUTTON_WHEEL_UP:
				if selected < 1:
					selected = 7
				else:
					selected -= 1
			# DOWN
			if event.button_index == BUTTON_WHEEL_DOWN:
				if selected > 6:
					selected = 0
				else:
					selected += 1

func _process(delta):
	if tutorial:
		print(tutorial)
		$UI/Tutorial.visible=true
		$UI/Tutorial/Label.text = tut_lines[tut_num]
		if tut_timer and (tut_num in [1,4,0]):
			$TutTimer.start()
			tut_timer=false
		
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.iterations_per_second and pause==false:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	elif pause==false:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform
	
	#Flask Light
	if $Head/FlashLight.visible == true and Input.is_action_just_pressed("flash_light"):
		$Head/FlashLight.visible = false
	elif Input.is_action_just_pressed("flash_light"):
		$Head/FlashLight.visible = true
	
	#Pick
	if Input.is_action_just_pressed("pick"):
		pick()
		pass
	
	$UI.pointed=""
	
	#Change UI
	if $Head/RayCast.is_colliding():
		var body = $Head/RayCast.get_collider()
		if body.is_in_group("Pickable"):
			change_pickUI("round")
			$UI.pointed=body.mat.capitalize()
		elif body.name=="Seperator":
			$UI/Pointed.text = body.name
			change_pickUI("RMouse")
			if Input.is_action_just_pressed("rMouse") and selected < inventory.size() and inventory.size()<8:
				seperate(inventory[selected].item)
				if tutorial and tut_num==3:
					next_tut_line()
				pass
		elif body.name=="Combiner":
			$UI/Pointed.text = body.name
			change_pickUI("RMouse")
			if Input.is_action_just_pressed("rMouse") and selected < inventory.size():
				combine_selected = inventory[selected].item
				$Timer.start()
				pass
		elif body.name=="Trash":
			$UI/Pointed.text = body.name
			change_pickUI("RMouse")
			if Input.is_action_just_pressed("rMouse") and selected < inventory.size():
				remove_inventory(inventory[selected].item,1)
				pass
		elif body.name=="Rocket":
			$UI/Pointed.text = body.name
			change_pickUI("RMouse")
			if Input.is_action_just_pressed("rMouse") and selected < inventory.size():
				add_completed(inventory[selected].item,1)
				remove_inventory(inventory[selected].item,1)
				
				pass
		else:
			change_pickUI("normal")
	else:
		change_pickUI("normal")
	
	#Cancel
	if Input.is_action_just_pressed("ui_cancel") and pause==false:
		pause=true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("ui_cancel") and pause==true:
		pause=false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	#Get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	#Jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
		if Input.is_action_just_pressed("move_forward"):
			$Particles.emitting=true
		else:
			$Particles.emitting=false
	else:
		$Particles.emitting=false
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	#Make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP, false,4,0.785398,true)

func pick():
	if $Head/RayCast.is_colliding():
		var body = $Head/RayCast.get_collider()
		if body.is_in_group("Pickable"):
			if(inventory.size()<8):
				add_inventory(body.mat,1)
				if tutorial and tut_num==2:
					next_tut_line()
				body.queue_free()
			pass
	pass

func change_pickUI(cursor):
	if cursor == "round":
		$UI/CrossHair/RectCrossHair.visible = false
		$UI/CrossHair/CirCrossHair.visible = true
		$UI/Tut/Pick.visible=true
		$UI/Tut/RMouse.visible=false
		pass
	elif cursor == "RMouse":
		$UI/CrossHair/RectCrossHair.visible = false
		$UI/CrossHair/CirCrossHair.visible = true
		$UI/Tut/RMouse.visible=true
		pass
	else:
		$UI/CrossHair/RectCrossHair.visible = true
		$UI/CrossHair/CirCrossHair.visible = false
		$UI/Tut/Pick.visible=false
		$UI/Tut/RMouse.visible=false
		pass
	pass

func seperate(item):
	for x in seperate_data:
		if x.in == item:
			for y in inventory:
				if y.item == item:
					remove_inventory(x.in,1)
					add_inventory(x.out1,x.amount)
					add_inventory(x.out2,x.amount)
				pass
			break
	pass

func add_completed(item,amount):
	if check_inventory(item):
		var count = 0
		for x in required:
			if x.item == item:
				if x.amount > amount:
					required[count].amount-=amount
					pass
				else:
					required.remove(count)
					
					pass
			pass
			count+=1
	pass
	pass

func combine(in1, in2):
	if check_inventory(in1) and check_inventory(in2):
		for x in combine_data:
			if (in1 in x.in and in2 in x.in) and in1 != in2:
				remove_inventory(in1,1)
				remove_inventory(in2,1)
				add_inventory(x.out,1)
			pass
	pass

func add_inventory(item,amount):
	if check_inventory(item):
		var count = 0
		for x in inventory:
			if x.item == item:
				inventory[count].amount+=amount
				pass
			pass
			count+=1
	else:
		inventory.append({"item":item,"amount":amount})
	pass

func remove_inventory(item,amount):
	if check_inventory(item):
		var count = 0
		for x in inventory:
			if x.item == item:
				if x.amount > amount:
					inventory[count].amount-=amount
					pass
				else:
					inventory.remove(count)
					pass
			pass
			count+=1
	pass

func next_tut_line():
	tut_num+=1

func check_inventory(item):
	for x in inventory:
		if x.item == item:
			return(true)
		pass
	pass


func _on_Timer_timeout():
	if selected < inventory.size():
		if combine_selected:
			combine(combine_selected,inventory[selected].item)
		combine_selected=""
	pass


func _on_TutTimer_timeout():
	tut_timer=true
	next_tut_line()
	pass
