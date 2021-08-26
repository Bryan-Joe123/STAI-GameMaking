extends StaticBody

export var mat = "iron"
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

func _ready():
	for x in mats:
		if mat == x.item:
			var material = SpatialMaterial.new()
			material.set_albedo(x.color)
			material.set_metallic(1)
			material.set_roughness(0.6)
			$Mesh.set_surface_material(0, material)
	pass
