extends Camera3D

@export_group("Follow Settings")
@export var target_path: NodePath
@export var distance := 40.0     # Distance behind the glider
@export var height := 20.0       # Height above the glider
@export var follow_speed := 0.1  # Camera smoothness

var target: Node3D

func _ready():
	# Wait for the glider to be instantiated
	await get_tree().create_timer(0.1).timeout
	
	# Try to get the glider node
	var flight_system = $"../FlightSystem"
	if flight_system:
		var path = flight_system.get_node("Path3D")
		if path:
			var path_follow = path.get_node("PathFollow3D")
			if path_follow:
				var glider = path_follow.get_node_or_null("Glider")
				if glider:
					target = glider
	
	# Set initial camera position
	position = Vector3(0, height, distance)
	look_at(Vector3.ZERO)

func _process(delta):
	if !target:
		# Try to find the glider if we don't have it yet
		var glider = get_node_or_null("../FlightSystem/Path3D/PathFollow3D/Glider")
		if glider:
			target = glider
		return
	
	# Get target info
	var target_pos = target.global_transform.origin
	var target_forward = -target.global_transform.basis.z
	
	# Calculate desired camera position (behind and above target)
	var offset = Vector3(0, height, distance)
	var desired_pos = target_pos + offset
	
	# Smoothly move camera
	global_transform.origin = global_transform.origin.lerp(desired_pos, follow_speed)
	
	# Look at point slightly ahead of target
	var look_at_pos = target_pos + target_forward * 10.0
	look_at(look_at_pos)
	
	# Match banking angle partially
	rotation.z = lerp(rotation.z, target.rotation.z * 0.5, follow_speed)

func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		# Allow manual camera adjustment with right mouse
		var sensitivity = 0.1
		distance += event.relative.y * sensitivity
		height += event.relative.x * sensitivity
		
		# Clamp values to reasonable ranges
		distance = clamp(distance, 20.0, 100.0)
		height = clamp(height, 10.0, 50.0)
