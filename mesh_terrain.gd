@tool
extends MeshInstance3D

@export var xSize = 20
@export var zSize = 20
@export var update = false
@export var clear_vert_vis = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_terrain()

func generate_terrain():
	# Create the mesh and SurfaceTool
	var a_mesh = ArrayMesh.new()
	var suftool = SurfaceTool.new()
	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.frequency = 0.1
	
	suftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var vertices = []  # Store vertices
	
	# Generate vertices
	for z in range(zSize + 1):
		for x in range(xSize + 1):
			var y = n.get_noise_2d(float(x*2), float(z*2)) * 5  # Now x and z are in scope
			var uv = Vector2()
			uv.x = inverse_lerp(0,xSize,x)
			uv.y = inverse_lerp(0,zSize,z)
			suftool.set_uv(uv)
			
			var vertex = Vector3(x, y, z)
			suftool.add_vertex(vertex)
			vertices.append(vertex)
			draw_sphere(vertex)  # Optionally visualize vertices with spheres
	
	# Generate triangles
	for z in range(zSize):
		for x in range(xSize):
			var i = z * (xSize + 1) + x
			var i_right = i + 1
			var i_below = i + (xSize + 1)
			var i_below_right = i_below + 1
			
			# First triangle (bottom-left)
			suftool.add_index(i)
			suftool.add_index(i_right)
			suftool.add_index(i_below)
			
			# Second triangle (top-right)
			suftool.add_index(i_below)
			suftool.add_index(i_right)
			suftool.add_index(i_below_right)
	
	# Commit the mesh and assign it to the MeshInstance3D
	suftool.generate_normals()
	a_mesh = suftool.commit()
	mesh = a_mesh

func draw_sphere(pos:Vector3):
	var ins = MeshInstance3D.new()
	add_child(ins)
	ins.position = pos
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	ins.mesh = sphere

func _process(delta):
	if update:
		generate_terrain()
		update = false
		
		if clear_vert_vis:
			for i in get_children():
				i.free()
