class_name GizmosDebug

static func create_rect(parent_node: Node, bottom_left: Vector2, top_right: Vector2, pos_y: float, color: Color = Color(0, 1, 0, 0.5)) -> MeshInstance3D:
	# create mesh
	var mesh_instance = MeshInstance3D.new()
	var immediate := ImmediateMesh.new()
	mesh_instance.mesh = immediate

	# create material
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	mesh_instance.material_override = mat

	# draw corners
	var corners: Array[Vector3] = [
		Vector3(bottom_left.x, pos_y, bottom_left.y),
		Vector3(top_right.x, pos_y, bottom_left.y),
		Vector3(top_right.x, pos_y, top_right.y),
		Vector3(bottom_left.x, pos_y, top_right.y),
	]

	immediate.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for corner in corners:
		immediate.surface_add_vertex(corner)

	# close the rectangle
	immediate.surface_add_vertex(corners[0])
	immediate.surface_end()

	# add to scene
	parent_node.add_child(mesh_instance)
	return mesh_instance

static func create_circle(parent_node: Node, position: Vector3, radius: float, color: Color = Color(0, 1, 0, 0.5)) -> MeshInstance3D:
	# create mesh
	var mesh_instance := MeshInstance3D.new()
	var immediate := ImmediateMesh.new()
	mesh_instance.mesh = immediate

	# create material
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	mesh_instance.material_override = mat

	# draw circle with line segments
	var segments := 64
	immediate.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in segments + 1:
		var angle := (float(i) / float(segments)) * TAU
		immediate.surface_add_vertex(Vector3(cos(angle) * radius, 0, sin(angle) * radius))
	immediate.surface_end()

	# set position
	mesh_instance.global_position = position

	# add to scene
	parent_node.add_child(mesh_instance)
	return mesh_instance