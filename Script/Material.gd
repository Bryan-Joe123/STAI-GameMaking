extends StaticBody

export(String) var mat = null
var rng = RandomNumberGenerator.new()

var mats = [
	{"item":"iron","color":"#B7B7B7"},
	{"item":"copper","color":"#CE7337"},
	{"item":"brass","color":"#eff229"},
	{"item":"steel","color":"#b0b0ab"},
	{"item":"aluminum","color":"#a3a3a3"},
	{"item":"magnalium","color":"#616161"},
	{"item":"bronze","color":"#663c1b"},
	{"item":"zinc","color":"#728e8f"},
	{"item":"carbon","color":"#474747"},
	{"item":"magnesium","color":"#a6a6a6"},
]
const items = ["iron","aluminum","bronze","zinc","magnesium","carbon"]

func _ready():
	rng.randomize()
	var my_random_number = rng.randi_range(0, items.size())
	
	if !mat:
		for x in mats:
			if x.item == items[my_random_number-1]:
				mat=x.item
				var material = SpatialMaterial.new()
				material.set_albedo(x.color)
				material.set_metallic(1)
				material.set_roughness(0.6)
				$Mesh.set_surface_material(0, material)
				break
	else:
		var material = SpatialMaterial.new()
		for x in mats:
			print(mat)
			if x.item == mat:
				material.set_albedo(x.color)
				
				break
		material.set_metallic(1)
		material.set_roughness(0.6)
		$Mesh.set_surface_material(0, material)
	pass


func _on_Timer_timeout():
	if $RayCast.enabled==true:
		$RayCast.get_collision_point()
		translation=$RayCast.get_collision_point()+Vector3(0,1,0)
	pass
