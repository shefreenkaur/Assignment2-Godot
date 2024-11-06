extends Camera3D

@export var initial_position := Vector3(50, 30, 100)  # Start position relative to terrain center
@export var look_target := Vector3(50, 0, 50)      # Point to look at (center of terrain)
@export var movement_speed := 0.5                   # Camera movement speed
@export var rotation_speed := 0.2                   # Camera rotation speed

func _ready():
	# Set initial position and orientation
	setup_camera()

func setup_camera():
	# Position the camera
	position = initial_position
	
	# Look at the center of the terrain
	look_at(look_target)
	
	# Set camera properties
	fov = 75
	near = 0.1
	far = 1000.0

func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		# Handle rotation
		rotate_y(-event.relative.x * rotation_speed * 0.01)
		
		# Handle vertical rotation with clamping
		var current_rotation = rotation
		current_rotation.x -= event.relative.y * rotation_speed * 0.01
		current_rotation.x = clamp(current_rotation.x, -0.5, 0.5)  # Limit vertical rotation
		rotation = current_rotation
	
	# Handle zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			translate(Vector3(0, 0, -2))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			translate(Vector3(0, 0, 2))
