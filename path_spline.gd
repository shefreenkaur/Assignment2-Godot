extends Path3D

@export var path_follow: PathFollow3D  # This is the only declaration you need


# Generate a space-filling curve (Hilbert curve)
func hilbert_curve(order: int, size: float) -> Array:
	var points = []
	hilbert_recursive(order, Vector2(0, 0), Vector2(0, size), Vector2(size, 0), Vector2(size, size), points)
	return points

# Recursive helper function for Hilbert curve
func hilbert_recursive(order: int, p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, points: Array) -> void:
	if order == 0:
		points.append((p1 + p2 + p3 + p4) / 4.0)
	else:
		hilbert_recursive(order - 1, p1, p4, p3, p2, points)
		hilbert_recursive(order - 1, p1 + (p2 - p1) / 2, p1, p4 + (p2 - p1) / 2, p3 + (p4 - p3) / 2, points)
		hilbert_recursive(order - 1, p4, p3, p2, p1 + (p2 - p1) / 2, points)
		hilbert_recursive(order - 1, p2, p3, p1 + (p4 - p3) / 2, p4, points)

# Create a spline path using the generated points
func create_spline():
	var curve = Curve3D.new()
	var points = hilbert_curve(3, 1.0)  # Recursing 3 times with size 1.0
	
	# Scale and elevate the points for the path
	var scaled_points = scale_and_elevate_points(points, 100.0, 10.0)
	
	for point in scaled_points:
		curve.add_point(point)
	
	curve.add_point(scaled_points[0])  # Close the loop by adding the first point again
	self.curve = curve

# Helper function to scale and elevate the points
func scale_and_elevate_points(points: Array, scale: float, elevation: float) -> Array:
	var scaled_points = []
	for point in points:
		var scaled_point = point * scale
		scaled_points.append(Vector3(scaled_point.x, elevation, scaled_point.y))  # Convert 2D to 3D
	return scaled_points

# Move the glider along the path
func _process(delta: float) -> void:
	if path_follow:
		path_follow.progress_ratio += delta * 0.01  # Adjust speed as needed
		if path_follow.progress_ratio >= 1.0:
			path_follow.progress_ratio = 0.0  # Loop back to the start of the path

# Call create_spline when the node enters the scene
func _ready() -> void:
	create_spline()
