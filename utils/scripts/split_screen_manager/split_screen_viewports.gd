class_name SplitScreenViewports

## Try get camera inside cameras_parents
static func get_child_cameras(number_of_cameras : int, cameras_parents : Array[Node], is_camera_2d : bool) -> Array[Node]:
	var cameras : Array[Node]
	var type : String = "Camera2D" if is_camera_2d else "Camera3D"
	for i in range(number_of_cameras):
		#inside this node, try find camera 2D or 3D
		var found_cameras = cameras_parents[i].find_children("*", type)
		#show error if can't find it
		if found_cameras.size() == 0:
			push_error(str("Impossible to find camera ", i, ". Are you sure is a ", type, "?"))
			return []
		#else add to list
		cameras.append(found_cameras[0])
	
	return cameras

## Get viewports rects
static func get_viewports_rects(number_of_cameras : int, prefer_vertical : bool) -> Array[Rect2]:
	var rects : Array[Rect2]
	#positions
	var pos0 = Vector2(0, 0)
	var pos1 = Vector2(0, 0.5) if prefer_vertical else Vector2(0.5, 0)
	var pos2 = Vector2(0.5, 0) if prefer_vertical else Vector2(0, 0.5)
	#size
	var full_screen = Vector2(1, 1)
	var half_screen = Vector2(1, 0.5) if prefer_vertical else Vector2(0.5, 1)
	var quarter_screen = Vector2(0.5, 0.5)
	
	if number_of_cameras == 1:
		rects.append(Rect2(pos0, full_screen))
	elif number_of_cameras == 2:
		rects.append(Rect2(pos0, half_screen))
		rects.append(Rect2(pos1, half_screen))
	elif number_of_cameras == 3:
		rects.append(Rect2(pos0, half_screen))
		rects.append(Rect2(pos1, quarter_screen))
		rects.append(Rect2(quarter_screen, quarter_screen))
	elif number_of_cameras == 4:
		rects.append(Rect2(pos0, quarter_screen))
		rects.append(Rect2(pos2, quarter_screen))
		rects.append(Rect2(pos1, quarter_screen))
		rects.append(Rect2(quarter_screen, quarter_screen))
	else:
		push_error(str("Impossible to create viewports rects for this number of cameras: ", number_of_cameras))

	return rects

## Add subviewport for this camera. 
## (NB if root.content_scale_mode is CONTENT_SCALE_MODE_DISABLED, you can register to root.size_changed and call update_viewport_screen)
static func set_camera_viewport(camera : Node, viewport_rect : Rect2, container_name : String, keep_camera_parents : int) -> SubViewportContainer:
	#create subviewport and container
	var viewport = SubViewport.new()
	var viewport_container = SubViewportContainer.new()
	viewport_container.name = container_name
	viewport_container.stretch = true
	update_viewport_screen(viewport_container, camera.get_tree().root, viewport_rect)
	#set hierarchy (set subviewport parent of camera, or parent of N camera's parent)
	#e.g. with keep_camera_parents = 2
	# | target_node_parent - parent of 2 keep_camera_parents (camera.get_parent().get_parent().get_parent())
	# |- viewport_container
	# |-- viewport
	# |--- target_node - 2 keep_camera_parents (camera.get_parent().get_parent())
	# |---- 1 keep_camera_parents (camera.get_parent())
	# |----- 0 keep_camera_parents (camera)
	var target_node : Node = camera
	for i in range(1, keep_camera_parents + 1):
		target_node = target_node.get_parent()
	var target_node_parent : Node = target_node.get_parent()
	target_node_parent.remove_child.call_deferred(target_node)
	target_node_parent.add_child.call_deferred(viewport_container)
	viewport_container.add_child.call_deferred(viewport)
	viewport.add_child.call_deferred(target_node)
	
	return viewport_container

## Update Viewport Position and Size
static func update_viewport_screen(viewport_container : SubViewportContainer, root : Window, viewport_rect : Rect2) -> void:
	#get correct screen size based on content_scale_mode
	#print(root.size, DisplayServer.screen_get_size(), root.content_scale_size, root.get_viewport().size)
	var screen_size : Vector2
	if root.content_scale_mode == root.ContentScaleMode.CONTENT_SCALE_MODE_DISABLED:
		screen_size = root.size
	else:
		screen_size = root.content_scale_size
	#update viewport position and size
	viewport_container.position = screen_size * viewport_rect.position
	viewport_container.size = screen_size * viewport_rect.size

## Call this function to remove SubViewport added with set_camera_viewport and reset Camera's parent
static func reset_camera_viewport(camera : Node) -> void:
	#find SubViewport
	var target_node : Node = camera
	var viewport : Node = camera
	while target_node.get_parent():
		viewport = target_node.get_parent()
		if viewport and viewport is SubViewport:
			break
		target_node = viewport
	#if found, there is also SubViewportContainer as viewport parent
	var viewport_container : SubViewportContainer = viewport.get_parent()
	if viewport_container:
		#reset hierarchy
		var target_node_parent : Node = viewport_container.get_parent()
		target_node_parent.remove_child.call_deferred(viewport_container)
		viewport.remove_child.call_deferred(target_node)
		target_node_parent.add_child.call_deferred(target_node)
		#destroy viewport and container
		viewport_container.queue_free()
		viewport.queue_free()
	else:
		push_warning("Impossible to find SubViewport and SubViewportContainer as parent of camera")
