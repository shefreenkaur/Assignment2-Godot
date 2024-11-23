extends Node3D

@export_group("Flight Settings")
@export var flight_height := 35.0
@export var circle_radius := 25.0
@export var flight_speed := 5.0

@export_group("Path Visual Settings")
@export var dot_spacing := 1.0
@export var dot_size := 0.12
@export var path_color := Color(1, 0, 1)

var center_x := 50.0
var center_z := 70.0
var path: Path3D
var path_follow: PathFollow3D
var glider: Node3D
var previous_position: Vector3

func _ready():
	# Clear existing paths
	for child in get_children():
		if child is Path3D:
			child.queue_free()
			
	create_circular_path()
	spawn_glider()
	create_dotted_path()
	previous_position = path_follow.global_transform.origin

func create_circular_path():
	path = Path3D.new()
	add_child(path)
	
	var curve = Curve3D.new()
	var points = 60
	
	for i in range(points + 1):
		var angle = i * TAU / points
		var x = center_x + cos(angle) * circle_radius
		var z = center_z + sin(angle) * circle_radius
		var point = Vector3(x, flight_height, z)
		var tangent = Vector3(-sin(angle), 0, cos(angle)) * (circle_radius * 0.01)
		
		if i == points:
			curve.add_point(curve.get_point_position(0), -tangent, curve.get_point_in(0))
		else:
			curve.add_point(point, -tangent, tangent)
	
	path.curve = curve
	
	path_follow = PathFollow3D.new()
	path_follow.loop = true
	path_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	path_follow.use_model_front = true
	path.add_child(path_follow)

func spawn_glider():
	var glider_scene = preload("res://scenes/glider.tscn")
	glider = glider_scene.instantiate()
	
	var orientation_holder = Node3D.new()
	path_follow.add_child(orientation_holder)
	orientation_holder.add_child(glider)
	
	orientation_holder.rotation_degrees = Vector3(0, -90, 0)
	glider.rotation_degrees = Vector3(0, 90, 0)
	
	glider.set_meta("orientation_holder", orientation_holder)

func update_glider_movement(delta: float):
	if !is_instance_valid(glider):
		return
	
	var orientation_holder = glider.get_meta("orientation_holder")
	if !orientation_holder:
		return

	# Simple path following
	path_follow.progress += flight_speed * delta

func _physics_process(delta: float):
	update_glider_movement(delta)

func create_dotted_path():
	for child in get_children():
		if child is MeshInstance3D and child != path:
			child.queue_free()
			
	var path_length = path.curve.get_baked_length()
	var num_dots = int(path_length / dot_spacing)
	
	for i in range(num_dots):
		var dot = create_dot()
		var offset = (float(i) / num_dots) * path_length
		var pos = path.curve.sample_baked(offset)
		dot.position = pos

func create_dot():
	var dot = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = dot_size
	sphere_mesh.height = dot_size * 2
	sphere_mesh.radial_segments = 12
	sphere_mesh.rings = 6
	dot.mesh = sphere_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = path_color
	material.emission_enabled = true
	material.emission = path_color
	material.emission_energy_multiplier = 3.0
	material.metallic = 0.5
	material.roughness = 0.2
	dot.material_override = material
	
	add_child(dot)
	return dot
