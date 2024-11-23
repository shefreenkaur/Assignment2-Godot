extends Node3D

@export_group("Path Settings")
@export var flight_height := 30.0
@export var path_radius := 50.0
@export var flight_speed := 10.0
@export var bank_angle := 35.0

# Node references
var path: Path3D
var path_follow: PathFollow3D
var glider: Node3D
var path_visual: MeshInstance3D

func _ready():
	create_flight_path()
	spawn_glider()
	create_path_visual()

func create_flight_path():
	# Create path node
	path = Path3D.new()
	add_child(path)
	
	# Create circular curve
	var curve = Curve3D.new()
	var points = 32  # Number of points in circle
	
	for i in range(points + 1):
		var angle = i * TAU / points
		var x = cos(angle) * path_radius
		var z = sin(angle) * path_radius
		var point = Vector3(x, flight_height, z)
		
		# Add point with handles for smooth curve
		var handle_in = Vector3(-sin(angle), 0, cos(angle)) * (path_radius * 0.25)
		var handle_out = -handle_in
		curve.add_point(point, handle_in, handle_out)
	
	path.curve = curve
	
	# Create PathFollow node
	path_follow = PathFollow3D.new()
	path_follow.loop = true
	path_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	path.add_child(path_follow)

func spawn_glider():
	# Load and instance glider scene
	var glider_scene = preload("res://scenes/glider.tscn")  # Make sure path is correct
	glider = glider_scene.instantiate()
	path_follow.add_child(glider)
	
	# Orient glider properly
	glider.rotation_degrees = Vector3(0, 180, 0)

func create_path_visual():
	# Create red path visualization
	var mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0)  # Red color
	material.emission_enabled = true
	material.emission = Color(1, 0, 0)
	
	path_visual = MeshInstance3D.new()
	path_visual.mesh = mesh
	path_visual.material_override = material
	add_child(path_visual)
	
	# Draw path
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	var points = 100
	for i in range(points + 1):
		var offset = float(i) / points
		var pos = path.curve.sample_baked(offset * path.curve.get_baked_length())
		mesh.surface_add_vertex(pos)
	
	mesh.surface_end()

func _process(delta):
	# Move along path
	path_follow.progress += flight_speed * delta
	
	# Calculate banking for turns
	if glider:
		var current_pos = path_follow.global_transform.origin
		var next_pos = path_follow.global_transform.origin + path_follow.transform.basis.z
		var direction = (next_pos - current_pos).normalized()
		
		# Calculate and apply banking
		var up = Vector3.UP
		var right = direction.cross(up).normalized()
		var bank = asin(right.dot(direction)) * bank_angle
		
		# Apply banking to glider
		glider.rotation.z = deg_to_rad(bank)
