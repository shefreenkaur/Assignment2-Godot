extends Node3D

@export_group("Grid Settings")
@export var grid_size := Vector2(200, 200)
@export var quad_size := 0.5

@export_group("Height Settings")
@export var height_scale := 50.0
@export var base_height := 10.0

@export_group("Noise Settings")
@export var noise_scale := 50.0
@export var noise_octaves := 4
@export var noise_lacunarity := 2.0
@export var noise_gain := 0.5

var noise: FastNoiseLite
var height_map: Image
var terrain_mesh: MeshInstance3D

func _ready():
	generate_height_map()
	create_terrain_mesh()

func generate_height_map():
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise.seed = randi()
	noise.frequency = 1.0 / noise_scale
	noise.fractal_octaves = noise_octaves
	noise.fractal_lacunarity = noise_lacunarity
	noise.fractal_gain = noise_gain
	
	height_map = Image.create(grid_size.x + 1, grid_size.y + 1, false, Image.FORMAT_RF)
	
	# Calculate center point for distance-based height modification
	var center_x = grid_size.x * 0.5
	var center_z = grid_size.y * 0.5
	var max_distance = sqrt(center_x * center_x + center_z * center_z)
	
	for z in range(height_map.get_height()):
		for x in range(height_map.get_width()):
			var noise_val = noise.get_noise_2d(x, z)
			
			# Calculate distance from center
			var dx = (x - center_x) / grid_size.x
			var dz = (z - center_z) / grid_size.y
			var distance = sqrt(dx * dx + dz * dz)
			
			# Apply smooth falloff from center
			var center_factor = 1.0 - smoothstep(0.0, 0.8, distance)
			
			# Smooth out the noise
			noise_val = (noise_val + 1) * 0.5
			noise_val = lerp(noise_val, smoothstep(0.2, 0.8, noise_val), 0.5)
			
			# Apply center elevation boost
			noise_val = lerp(noise_val, noise_val * 1.5, center_factor)
			
			# Smooth edges
			if distance > 0.7:
				var edge_factor = smoothstep(0.7, 1.0, distance)
				noise_val *= 1.0 - edge_factor
			
			height_map.set_pixel(x, z, Color(noise_val, noise_val, noise_val, 1.0))

func smoothstep(edge0: float, edge1: float, x: float) -> float:
	var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func create_terrain_mesh():
	var vertices = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	# Generate vertices with smooth interpolation
	for z in range(grid_size.y + 1):
		for x in range(grid_size.x + 1):
			var pixel = height_map.get_pixel(x, z)
			var height = pixel.r * height_scale + base_height
			
			# Apply additional smoothing to height
			if x > 0 and x < grid_size.x and z > 0 and z < grid_size.y:
				var neighbors = [
					height_map.get_pixel(x-1, z).r,
					height_map.get_pixel(x+1, z).r,
					height_map.get_pixel(x, z-1).r,
					height_map.get_pixel(x, z+1).r
				]
				var avg_height = (neighbors[0] + neighbors[1] + neighbors[2] + neighbors[3]) / 4.0
				height = lerp(height, avg_height * height_scale + base_height, 0.3)
			
			var vertex = Vector3(x * quad_size, height, z * quad_size)
			vertices.append(vertex)
			
			var uv = Vector2(float(x) / grid_size.x, float(z) / grid_size.y)
			uvs.append(uv)
			
			# Calculate smooth normals
			var normal = Vector3.UP
			if x > 0 and x < grid_size.x and z > 0 and z < grid_size.y:
				var h_left = height_map.get_pixel(x-1, z).r * height_scale
				var h_right = height_map.get_pixel(x+1, z).r * height_scale
				var h_up = height_map.get_pixel(x, z-1).r * height_scale
				var h_down = height_map.get_pixel(x, z+1).r * height_scale
				normal = Vector3(h_left - h_right, 4.0, h_up - h_down).normalized()
			normals.append(normal)
	
	# Generate indices
	for z in range(grid_size.y):
		for x in range(grid_size.x):
			var vertex_index = z * (grid_size.x + 1) + x
			indices.append(vertex_index)
			indices.append(vertex_index + 1)
			indices.append(vertex_index + grid_size.x + 1)
			indices.append(vertex_index + 1)
			indices.append(vertex_index + grid_size.x + 2)
			indices.append(vertex_index + grid_size.x + 1)
	
	# Create mesh
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_TEX_UV] = uvs
	arrays[ArrayMesh.ARRAY_NORMAL] = normals
	arrays[ArrayMesh.ARRAY_INDEX] = indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	terrain_mesh = MeshInstance3D.new()
	terrain_mesh.mesh = array_mesh
	add_child(terrain_mesh)
	
	# Create snow material with softer appearance
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.98, 0.98, 1.0)  # Slightly blue-tinted white
	material.roughness = 0.95  # High roughness for snow
	material.metallic = 0.0
	material.metallic_specular = 0.2
	material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	material.vertex_color_use_as_albedo = true
	terrain_mesh.material_override = material
	
	# Add collision
	var static_body = StaticBody3D.new()
	add_child(static_body)
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = array_mesh.create_trimesh_shape()
	static_body.add_child(collision_shape)

func regenerate():
	if terrain_mesh:
		terrain_mesh.queue_free()
	generate_height_map()
	create_terrain_mesh()
