@tool
extends VBoxContainer

const PROJECT_SCAN_SCENE_EXTENSIONS := {
	"tscn": true,
	"scn": true,
}

const PROJECT_SCAN_RESOURCE_EXTENSIONS := {
	"tres": true,
	"res": true,
	"material": true,
	"theme": true,
}

const TEXT_SEARCH_EXTENSIONS := {
	"gd": true,
	"cs": true,
	"shader": true,
	"gdshader": true,
	"gdshaderinc": true,
	"cfg": true,
	"json": true,
	"txt": true,
}

const STRUCTURED_TEXT_REFERENCE_EXTENSIONS := {
	"tscn": true,
	"scn": true,
	"tres": true,
	"res": true,
	"material": true,
	"theme": true,
}

const POPUP_COPY_CELL := 1
const POPUP_COPY_ROW := 2

var _plugin: EditorPlugin

var _title_label: Label
var _status_label: Label
var _tree: Tree
var _preview_text: TextEdit
var _rescan_button: Button
var _clear_button: Button
var _copy_button: Button
var _cell_popup: PopupMenu

var _last_request: Dictionary = {}
var _last_results: Array[Dictionary] = []
var _popup_item: TreeItem = null
var _popup_column: int = -1


func setup(plugin: EditorPlugin) -> void:
	_plugin = plugin
	name = "GodotReferenceFinder"
	_build_ui()


func start_scene_search(selected_nodes: Array, include_children: bool) -> void:
	if selected_nodes.is_empty():
		_set_status("No node selected.")
		return

	var scene_root: Node = _plugin.get_editor_interface().get_edited_scene_root()
	if scene_root == null:
		_set_status("No scene is currently open.")
		return

	var target_nodes: Array[Node] = []
	for value in selected_nodes:
		if value is Node:
			target_nodes.append(value)

	if target_nodes.is_empty():
		_set_status("The current selection does not contain scene nodes.")
		return

	_last_request = {
		"mode": "scene",
		"include_children": include_children,
		"target_paths": _collect_scene_target_paths(scene_root, target_nodes, include_children),
	}

	var pretty_target: String = _build_scene_target_label(target_nodes, include_children)
	_title_label.text = "Current Scene References — %s" % pretty_target
	_set_status("Scanning current scene...")

	var results: Array[Dictionary] = _scan_current_scene(scene_root, target_nodes, include_children)
	_show_results(results)


func start_project_search(paths: PackedStringArray) -> void:
	if paths.is_empty():
		_set_status("No file selected.")
		return

	var target_path := String(paths[0])
	_last_request = {
		"mode": "project",
		"target_path": target_path,
	}

	_title_label.text = "Project References — %s" % target_path
	_set_status("Scanning project...")

	var results: Array[Dictionary] = _scan_project_for_resource_path(target_path)
	_show_results(results)


func _build_ui() -> void:
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var toolbar := HBoxContainer.new()
	toolbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(toolbar)

	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(labels)

	_title_label = Label.new()
	_title_label.text = "Reference Finder"
	_title_label.clip_text = true
	labels.add_child(_title_label)

	_status_label = Label.new()
	_status_label.text = "Right click a node in the Scene tree or a file in the FileSystem dock."
	_status_label.clip_text = true
	labels.add_child(_status_label)

	var button_bar := HBoxContainer.new()
	toolbar.add_child(button_bar)

	_rescan_button = Button.new()
	_rescan_button.text = "Rescan"
	_rescan_button.pressed.connect(_on_rescan_pressed)
	button_bar.add_child(_rescan_button)

	_copy_button = Button.new()
	_copy_button.text = "Copy Summary"
	_copy_button.pressed.connect(_on_copy_summary_pressed)
	button_bar.add_child(_copy_button)

	_clear_button = Button.new()
	_clear_button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_clear_button.text = "Clear All"
	_clear_button.pressed.connect(_on_clear_pressed)
	button_bar.add_child(_clear_button)

	_tree = Tree.new()
	_tree.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.columns = 4
	_tree.column_titles_visible = true
	_tree.select_mode = Tree.SELECT_ROW
	_tree.hide_root = true
	_tree.set_column_title(0, "Location")
	_tree.set_column_title(1, "Kind")
	_tree.set_column_title(2, "Details")
	_tree.set_column_title(3, "Target")
	_tree.set_column_expand(0, true)
	_tree.set_column_expand(1, true)
	_tree.set_column_expand(2, true)
	_tree.set_column_expand(3, true)
	_tree.set_column_expand_ratio(0, 1)
	_tree.set_column_expand_ratio(1, 1)
	_tree.set_column_expand_ratio(2, 1)
	_tree.set_column_expand_ratio(3, 1)
	_tree.set_column_custom_minimum_width(0, 220)
	_tree.set_column_custom_minimum_width(1, 220)
	_tree.set_column_custom_minimum_width(2, 220)
	_tree.set_column_custom_minimum_width(3, 220)
	_tree.item_activated.connect(_on_tree_item_activated)
	_tree.item_selected.connect(_on_tree_item_selected)
	_tree.gui_input.connect(_on_tree_gui_input)
	add_child(_tree)

	var preview_label := Label.new()
	preview_label.text = "Selected Result"
	add_child(preview_label)

	_preview_text = TextEdit.new()
	_preview_text.custom_minimum_size = Vector2(0, 120)
	_preview_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview_text.size_flags_vertical = Control.SIZE_SHRINK_END
	_preview_text.editable = false
	_preview_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_preview_text.placeholder_text = "Select a result to inspect the full text. Double click to open it."
	add_child(_preview_text)

	_cell_popup = PopupMenu.new()
	_cell_popup.id_pressed.connect(_on_cell_popup_id_pressed)
	add_child(_cell_popup)
	_cell_popup.add_item("Copy Cell", POPUP_COPY_CELL)
	_cell_popup.add_item("Copy Row", POPUP_COPY_ROW)


func _set_status(text: String) -> void:
	_status_label.text = text


func _show_results(results: Array[Dictionary]) -> void:
	_last_results = results
	_tree.clear()
	var root := _tree.create_item()
	_preview_text.text = ""

	for result in results:
		var item := _tree.create_item(root)
		item.set_text(0, result.get("location", ""))
		item.set_text(1, result.get("kind", ""))
		item.set_text(2, result.get("details", ""))
		item.set_text(3, result.get("target", ""))
		item.set_metadata(0, result)
		item.set_tooltip_text(0, result.get("location", ""))
		item.set_tooltip_text(1, result.get("kind", ""))
		item.set_tooltip_text(2, result.get("details", ""))
		item.set_tooltip_text(3, result.get("target", ""))
		
		for column in range(4):
			item.set_auto_translate_mode(column, Node.AUTO_TRANSLATE_MODE_DISABLED)

	if results.is_empty():
		_set_status("No references found.")
	else:
		_set_status("%d reference(s) found." % results.size())


func _on_tree_item_selected() -> void:
	var item := _tree.get_selected()
	if item == null:
		_preview_text.text = ""
		return

	var result: Dictionary = item.get_metadata(0)
	_preview_text.text = _format_result_text(result)


func _on_tree_item_activated() -> void:
	var item := _tree.get_selected()
	if item == null:
		return

	var column := _tree.get_selected_column()
	var result: Dictionary = item.get_metadata(0)
	_open_result_for_column(result, column)


func _open_result_for_column(result: Dictionary, column: int) -> void:
	if column == 3:
		_open_target(result)
		return

	_open_location(result)


func _open_location(result: Dictionary) -> void:
	var action := String(result.get("location_action", result.get("action", "")))
	match action:
		"scene_current":
			_plugin.focus_current_scene_node(String(result.get("location_node_path", result.get("node_path", "."))))
		"scene_file":
			_plugin.focus_scene_node(
				String(result.get("location_scene_path", result.get("scene_path", ""))),
				String(result.get("location_node_path", result.get("node_path", ".")))
			)
		"scene_asset":
			_plugin.focus_scene_file(String(result.get("location_scene_path", result.get("scene_path", ""))))
		"file":
			_plugin.focus_file(String(result.get("location_file_path", result.get("file_path", ""))))
		_:
			pass


func _open_target(result: Dictionary) -> void:
	var action := String(result.get("target_action", ""))
	match action:
		"scene_current":
			_plugin.focus_current_scene_node(String(result.get("target_node_path", ".")))
		"scene_file":
			_plugin.focus_scene_node(
				String(result.get("target_scene_path", "")),
				String(result.get("target_node_path", "."))
			)
		"scene_asset":
			_plugin.focus_scene_file(String(result.get("target_scene_path", "")))
		"file":
			_plugin.focus_file(String(result.get("target_file_path", result.get("target", ""))))
		_:
			_open_location(result)


func _on_rescan_pressed() -> void:
	if _last_request.is_empty():
		return

	var mode := String(_last_request.get("mode", ""))
	if mode == "scene":
		var scene_root: Node = _plugin.get_editor_interface().get_edited_scene_root()
		if scene_root == null:
			_set_status("No scene is currently open.")
			return

		var target_paths: PackedStringArray = _last_request.get("target_paths", PackedStringArray())
		var include_children := bool(_last_request.get("include_children", false))
		var target_nodes: Array[Node] = []
		for target_path in target_paths:
			var node := _get_node_from_scene_root(scene_root, String(target_path))
			if node != null:
				target_nodes.append(node)

		if target_nodes.is_empty():
			_set_status("The originally selected node(s) are no longer available in the open scene.")
			return

		start_scene_search(target_nodes, include_children)
	elif mode == "project":
		start_project_search(PackedStringArray([String(_last_request.get("target_path", ""))]))


func _on_copy_summary_pressed() -> void:
	if _last_results.is_empty():
		DisplayServer.clipboard_set("No references found.")
		_set_status("Summary copied.")
		return

	var lines: Array[String] = []
	lines.append(_title_label.text)
	lines.append("")
	for result in _last_results:
		lines.append("- %s | %s | %s | %s" % [
			result.get("location", ""),
			result.get("kind", ""),
			result.get("details", ""),
			result.get("target", ""),
		])

	DisplayServer.clipboard_set("\n".join(lines))
	_set_status("Summary copied.")


func _on_clear_pressed() -> void:
	_last_request.clear()
	_last_results.clear()
	_title_label.text = "Reference Finder"
	_set_status("Cleared.")
	_preview_text.text = ""
	_tree.clear()
	_tree.create_item()


func _on_tree_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed:
		return

	var item := _tree.get_item_at_position(mouse_event.position)
	if item == null:
		return

	var column := _tree.get_column_at_position(mouse_event.position)
	if mouse_event.button_index != MOUSE_BUTTON_RIGHT:
		return

	_popup_item = item
	_popup_column = column
	_tree.set_selected(item, column)
	var result: Dictionary = item.get_metadata(0)
	_preview_text.text = _format_result_text(result)
	_cell_popup.position = get_screen_position() + mouse_event.position
	_cell_popup.popup()


func _on_cell_popup_id_pressed(id: int) -> void:
	if _popup_item == null:
		return

	if id == POPUP_COPY_CELL:
		DisplayServer.clipboard_set(_popup_item.get_text(_popup_column))
		_set_status("Cell copied.")
		return

	if id == POPUP_COPY_ROW:
		var result: Dictionary = _popup_item.get_metadata(0)
		DisplayServer.clipboard_set(_format_result_line(result))
		_set_status("Row copied.")


func _scan_current_scene(scene_root: Node, target_nodes: Array[Node], include_children: bool) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var target_path_set := _build_target_path_set(scene_root, target_nodes, include_children)
	var packed := PackedScene.new()
	var pack_error := packed.pack(scene_root)
	if pack_error != OK:
		_set_status("Failed to pack the open scene. Error code: %d" % pack_error)
		return results

	var state := packed.get_state()
	if state == null:
		return results

	for node_idx in range(state.get_node_count()):
		var node_path := _normalize_node_path_string(state.get_node_path(node_idx))
		var owner_node := _get_node_from_scene_root(scene_root, node_path)

		for prop_idx in range(state.get_node_property_count(node_idx)):
			var property_name := String(state.get_node_property_name(node_idx, prop_idx))
			var property_value: Variant = state.get_node_property_value(node_idx, prop_idx)
			_scan_variant_for_scene_node_reference(
				results,
				target_path_set,
				scene_root,
				owner_node,
				property_value,
				node_path,
				"Property",
				property_name,
				{},
				0
			)

	for connection_idx in range(state.get_connection_count()):
		var source_path := _normalize_node_path_string(state.get_connection_source(connection_idx))
		var target_path := _normalize_node_path_string(state.get_connection_target(connection_idx))
		if target_path_set.has(target_path):
			_add_unique_result(results, {
				"location": source_path,
				"kind": "Signal",
				"details": "%s -> %s()" % [
					String(state.get_connection_signal(connection_idx)),
					String(state.get_connection_method(connection_idx))
				],
				"target": target_path,
				"location_action": "scene_current",
				"location_node_path": source_path,
				"target_action": "scene_current",
				"target_node_path": target_path,
			})

		var source_node := _get_node_from_scene_root(scene_root, source_path)
		var bind_values: Array = state.get_connection_binds(connection_idx)
		for bind_idx in range(bind_values.size()):
			var bind_value: Variant = bind_values[bind_idx]
			_scan_variant_for_scene_node_reference(
				results,
				target_path_set,
				scene_root,
				source_node,
				bind_value,
				source_path,
				"Signal Bind",
				"bind[%d]" % bind_idx,
				{},
				0
			)

	return results


func _scan_project_for_resource_path(target_path: String) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var files: PackedStringArray = []
	_collect_project_files("res://", files)

	for file_path in files:
		var extension := file_path.get_extension().to_lower()
		if file_path == target_path:
			continue

		if PROJECT_SCAN_SCENE_EXTENSIONS.has(extension):
			_scan_scene_file_for_resource_path(results, file_path, target_path)
		elif PROJECT_SCAN_RESOURCE_EXTENSIONS.has(extension):
			_scan_resource_file_for_resource_path(results, file_path, target_path)

		if STRUCTURED_TEXT_REFERENCE_EXTENSIONS.has(extension):
			_scan_structured_text_reference_file(results, file_path, target_path)
		elif TEXT_SEARCH_EXTENSIONS.has(extension):
			_scan_text_file_for_target_path(results, file_path, target_path)

	return results


func _scan_scene_file_for_resource_path(results: Array[Dictionary], scene_path: String, target_path: String) -> void:
	var scene := ResourceLoader.load(scene_path)
	if scene == null or not (scene is PackedScene):
		return

	var state := (scene as PackedScene).get_state()
	if state == null:
		return

	var base_state := state.get_base_scene_state()
	if base_state != null and base_state.get_path() == target_path:
		_add_unique_result(results, {
			"location": scene_path,
			"kind": "Inherited Scene",
			"details": "Base scene reference",
			"target": target_path,
			"location_action": "scene_asset",
			"location_scene_path": scene_path,
			"target_action": "file",
			"target_file_path": target_path,
		})

	for node_idx in range(state.get_node_count()):
		var node_path := _normalize_node_path_string(state.get_node_path(node_idx))

		var instance_scene := state.get_node_instance(node_idx)
		if instance_scene != null and instance_scene.resource_path == target_path:
			_add_unique_result(results, {
				"location": "%s :: %s" % [scene_path, node_path],
				"kind": "Instanced Scene",
				"details": "Node instance source scene",
				"target": target_path,
				"location_action": "scene_file",
				"location_scene_path": scene_path,
				"location_node_path": node_path,
				"target_action": "file",
				"target_file_path": target_path,
			})

		for prop_idx in range(state.get_node_property_count(node_idx)):
			var property_name := String(state.get_node_property_name(node_idx, prop_idx))
			if property_name == "script":
				continue

			var property_value: Variant = state.get_node_property_value(node_idx, prop_idx)
			_scan_variant_for_resource_path(
				results,
				target_path,
				property_value,
				"%s :: %s" % [scene_path, node_path],
				"Property",
				property_name,
				{
					"location_action": "scene_file",
					"location_scene_path": scene_path,
					"location_node_path": node_path,
					"target_action": "file",
					"target_file_path": target_path,
				},
				{},
				0,
				scene_path
			)

		var script_path := _extract_script_path_from_node_property(state, node_idx)
		if not script_path.is_empty() and script_path == target_path:
			_add_unique_result(results, {
				"location": "%s :: %s" % [scene_path, node_path],
				"kind": "Script",
				"details": "Attached script",
				"target": target_path,
				"location_action": "scene_file",
				"location_scene_path": scene_path,
				"location_node_path": node_path,
				"target_action": "file",
				"target_file_path": target_path,
			})

	for connection_idx in range(state.get_connection_count()):
		var bind_values: Array = state.get_connection_binds(connection_idx)
		var source_path := _normalize_node_path_string(state.get_connection_source(connection_idx))
		for bind_idx in range(bind_values.size()):
			_scan_variant_for_resource_path(
				results,
				target_path,
				bind_values[bind_idx],
				"%s :: %s" % [scene_path, source_path],
				"Signal Bind",
				"bind[%d]" % bind_idx,
				{
					"location_action": "scene_file",
					"location_scene_path": scene_path,
					"location_node_path": source_path,
					"target_action": "file",
					"target_file_path": target_path,
				},
				{},
				0,
				scene_path
			)


func _extract_script_path_from_node_property(state: SceneState, node_idx: int) -> String:
	for prop_idx in range(state.get_node_property_count(node_idx)):
		var property_name := String(state.get_node_property_name(node_idx, prop_idx))
		if property_name != "script":
			continue

		var property_value: Variant = state.get_node_property_value(node_idx, prop_idx)
		if property_value is Script:
			return (property_value as Script).resource_path
		if property_value is Resource:
			return (property_value as Resource).resource_path
	return ""


func _scan_resource_file_for_resource_path(results: Array[Dictionary], resource_path: String, target_path: String) -> void:
	var resource := ResourceLoader.load(resource_path)
	if resource == null:
		return

	_scan_variant_for_resource_path(
		results,
		target_path,
		resource,
		resource_path,
		"Resource",
		"root",
		{
			"location_action": "file",
			"location_file_path": resource_path,
			"target_action": "file",
			"target_file_path": target_path,
		},
		{},
		0,
		resource_path
	)


func _scan_structured_text_reference_file(results: Array[Dictionary], file_path: String, target_path: String) -> void:
	if _file_already_has_resource_result(results, file_path, target_path):
		return

	var text := _read_small_text_file(file_path)
	if text.is_empty():
		return

	if text.find(target_path) == -1:
		return

	var line_number := _find_first_line_number(text, target_path)
	var details := "Direct resource reference at line %d" % line_number
	if text.find("[ext_resource") != -1:
		details = "External resource reference at line %d" % line_number

	_add_unique_result(results, {
		"location": file_path,
		"kind": "Resource Reference",
		"details": details,
		"target": target_path,
		"location_action": "file",
		"location_file_path": file_path,
		"target_action": "file",
		"target_file_path": target_path,
	})


func _scan_text_file_for_target_path(results: Array[Dictionary], file_path: String, target_path: String) -> void:
	var text := _read_small_text_file(file_path)
	if text.is_empty():
		return

	if text.find(target_path) == -1:
		return

	var line_number := _find_first_line_number(text, target_path)
	_add_unique_result(results, {
		"location": file_path,
		"kind": "Text Match",
		"details": "Path literal at line %d" % line_number,
		"target": target_path,
		"location_action": "file",
		"location_file_path": file_path,
		"target_action": "file",
		"target_file_path": target_path,
	})


func _scan_variant_for_scene_node_reference(
	results: Array[Dictionary],
	target_path_set: Dictionary,
	scene_root: Node,
	owner_node: Node,
	value: Variant,
	source_node_path: String,
	reference_kind: String,
	detail_path: String,
	visited: Dictionary,
	depth: int
) -> void:
	if depth > 16:
		return

	if value is Node:
		var node_value := value as Node
		if node_value != null:
			var relative := _normalize_node_path_string(scene_root.get_path_to(node_value))
			if target_path_set.has(relative):
				_add_unique_result(results, {
					"location": source_node_path,
					"kind": reference_kind,
					"details": detail_path,
					"target": relative,
					"location_action": "scene_current",
					"location_node_path": source_node_path,
					"target_action": "scene_current",
					"target_node_path": relative,
				})
		return

	if value is NodePath:
		var resolved := _resolve_node_path_reference(scene_root, owner_node, value)
		if resolved != null:
			var resolved_relative := _normalize_node_path_string(scene_root.get_path_to(resolved))
			if target_path_set.has(resolved_relative):
				_add_unique_result(results, {
					"location": source_node_path,
					"kind": reference_kind,
					"details": detail_path,
					"target": resolved_relative,
					"location_action": "scene_current",
					"location_node_path": source_node_path,
					"target_action": "scene_current",
					"target_node_path": resolved_relative,
				})
		return

	if value is Resource:
		var resource := value as Resource
		if resource == null:
			return

		var object_id := resource.get_instance_id()
		if visited.has(object_id):
			return
		visited[object_id] = true

		_scan_object_storage_properties_for_scene_reference(
			results,
			target_path_set,
			scene_root,
			owner_node,
			resource,
			source_node_path,
			reference_kind,
			detail_path,
			visited,
			depth + 1
		)
		return

	match typeof(value):
		TYPE_ARRAY:
			for index in range(value.size()):
				_scan_variant_for_scene_node_reference(
					results,
					target_path_set,
					scene_root,
					owner_node,
					value[index],
					source_node_path,
					reference_kind,
					"%s[%d]" % [detail_path, index],
					visited,
					depth + 1
				)
		TYPE_DICTIONARY:
			for key in value.keys():
				_scan_variant_for_scene_node_reference(
					results,
					target_path_set,
					scene_root,
					owner_node,
					value[key],
					source_node_path,
					reference_kind,
					"%s[%s]" % [detail_path, String(key)],
					visited,
					depth + 1
				)
		_:
			pass


func _scan_object_storage_properties_for_scene_reference(
	results: Array[Dictionary],
	target_path_set: Dictionary,
	scene_root: Node,
	owner_node: Node,
	object: Object,
	source_node_path: String,
	reference_kind: String,
	base_detail_path: String,
	visited: Dictionary,
	depth: int
) -> void:
	for property_info in object.get_property_list():
		var usage := int(property_info.get("usage", 0))
		if (usage & PROPERTY_USAGE_STORAGE) == 0:
			continue

		var property_name := String(property_info.get("name", ""))
		if property_name.is_empty():
			continue

		var property_value: Variant = object.get(property_name)
		_scan_variant_for_scene_node_reference(
			results,
			target_path_set,
			scene_root,
			owner_node,
			property_value,
			source_node_path,
			reference_kind,
			"%s.%s" % [base_detail_path, property_name],
			visited,
			depth + 1
		)


func _scan_variant_for_resource_path(
	results: Array[Dictionary],
	target_path: String,
	value: Variant,
	location: String,
	kind: String,
	detail_path: String,
	action_data: Dictionary,
	visited: Dictionary,
	depth: int,
	owner_file_path: String
) -> void:
	if depth > 20:
		return

	if value is Resource:
		var resource := value as Resource
		if resource == null:
			return

		if resource.resource_path == target_path:
			var result := action_data.duplicate(true)
			result.merge({
				"location": location,
				"kind": kind,
				"details": detail_path,
				"target": target_path,
			}, true)
			_add_unique_result(results, result)

		if resource is Mesh:
			_scan_mesh_surface_materials_for_resource_path(
				results,
				target_path,
				resource as Mesh,
				location,
				kind,
				detail_path,
				action_data
			)

		if _should_skip_resource_recursion(resource, owner_file_path):
			return

		var object_id := resource.get_instance_id()
		if visited.has(object_id):
			return
		visited[object_id] = true

		for property_info in resource.get_property_list():
			var usage := int(property_info.get("usage", 0))
			if (usage & PROPERTY_USAGE_STORAGE) == 0:
				continue

			var property_name := String(property_info.get("name", ""))
			if property_name.is_empty():
				continue

			var property_value: Variant = resource.get(property_name)
			_scan_variant_for_resource_path(
				results,
				target_path,
				property_value,
				location,
				kind,
				"%s.%s" % [detail_path, property_name],
				action_data,
				visited,
				depth + 1,
				owner_file_path
			)
		return

	match typeof(value):
		TYPE_ARRAY:
			for index in range(value.size()):
				_scan_variant_for_resource_path(
					results,
					target_path,
					value[index],
					location,
					kind,
					"%s[%d]" % [detail_path, index],
					action_data,
					visited,
					depth + 1,
					owner_file_path
				)
		TYPE_DICTIONARY:
			for key in value.keys():
				_scan_variant_for_resource_path(
					results,
					target_path,
					value[key],
					location,
					kind,
					"%s[%s]" % [detail_path, String(key)],
					action_data,
					visited,
					depth + 1,
					owner_file_path
				)
		_:
			pass


func _scan_mesh_surface_materials_for_resource_path(
	results: Array[Dictionary],
	target_path: String,
	mesh: Mesh,
	location: String,
	kind: String,
	detail_path: String,
	action_data: Dictionary
) -> void:
	for surface_index in range(mesh.get_surface_count()):
		var material := mesh.surface_get_material(surface_index)
		if material == null:
			continue
		if material.resource_path != target_path:
			continue

		var result := action_data.duplicate(true)
		result.merge({
			"location": location,
			"kind": kind,
			"details": "%s.surface_material[%d]" % [detail_path, surface_index],
			"target": target_path,
		}, true)
		_add_unique_result(results, result)


func _should_skip_resource_recursion(resource: Resource, owner_file_path: String) -> bool:
	var resource_path := resource.resource_path
	if resource_path.is_empty():
		return false

	if resource_path == owner_file_path:
		return false

	return true


func _build_scene_target_label(target_nodes: Array[Node], include_children: bool) -> String:
	if target_nodes.size() == 1:
		var label := target_nodes[0].name
		if include_children:
			label += " (+ children)"
		return label

	var label := "%d selected nodes" % target_nodes.size()
	if include_children:
		label += " (+ children)"
	return label


func _collect_scene_target_paths(scene_root: Node, target_nodes: Array[Node], include_children: bool) -> PackedStringArray:
	var set := _build_target_path_set(scene_root, target_nodes, include_children)
	var output: PackedStringArray = []
	for key in set.keys():
		output.append(String(key))
	return output


func _build_target_path_set(scene_root: Node, target_nodes: Array[Node], include_children: bool) -> Dictionary:
	var target_path_set: Dictionary = {}
	for node in target_nodes:
		if node == null:
			continue
		if not scene_root.is_ancestor_of(node) and node != scene_root:
			continue

		var relative := _normalize_node_path_string(scene_root.get_path_to(node))
		target_path_set[relative] = true

		if include_children:
			for descendant in _collect_descendants(node):
				var descendant_relative := _normalize_node_path_string(scene_root.get_path_to(descendant))
				target_path_set[descendant_relative] = true

	return target_path_set


func _collect_descendants(root: Node) -> Array[Node]:
	var output: Array[Node] = []
	for child in root.get_children():
		if child is Node:
			output.append(child)
			output.append_array(_collect_descendants(child))
	return output


func _resolve_node_path_reference(scene_root: Node, owner_node: Node, node_path_value: NodePath) -> Node:
	if owner_node != null:
		var relative_candidate := owner_node.get_node_or_null(node_path_value)
		if relative_candidate != null:
			return relative_candidate

	if scene_root != null:
		var root_candidate := scene_root.get_node_or_null(node_path_value)
		if root_candidate != null:
			return root_candidate

	return null


func _collect_project_files(directory_path: String, output: PackedStringArray) -> void:
	var dir := DirAccess.open(directory_path)
	if dir == null:
		return

	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name.is_empty():
			break

		if name.begins_with("."):
			continue

		var full_path := directory_path.path_join(name)
		if dir.current_is_dir():
			if name == ".godot":
				continue
			_collect_project_files(full_path, output)
		else:
			output.append(full_path)

	dir.list_dir_end()


func _read_small_text_file(file_path: String) -> String:
	if not FileAccess.file_exists(file_path):
		return ""

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return ""

	if file.get_length() > 2 * 1024 * 1024:
		file.close()
		return ""

	var bytes := file.get_buffer(file.get_length())
	file.close()
	return bytes.get_string_from_utf8()
	# var text := file.get_as_text()
	# file.close()
	# return text


func _file_already_has_resource_result(results: Array[Dictionary], file_path: String, target_path: String) -> bool:
	for result in results:
		if String(result.get("target", "")) != target_path:
			continue

		var location := String(result.get("location", ""))
		if location == file_path or location.begins_with("%s :: " % file_path):
			return true

	return false


func _find_first_line_number(text: String, needle: String) -> int:
	var lines := text.split("\n")
	for index in range(lines.size()):
		if lines[index].find(needle) != -1:
			return index + 1
	return 1


func _add_unique_result(results: Array[Dictionary], result: Dictionary) -> void:
	var key := "%s|%s|%s|%s" % [
		String(result.get("location", "")),
		String(result.get("kind", "")),
		String(result.get("details", "")),
		String(result.get("target", "")),
	]

	for existing in results:
		var existing_key := "%s|%s|%s|%s" % [
			String(existing.get("location", "")),
			String(existing.get("kind", "")),
			String(existing.get("details", "")),
			String(existing.get("target", "")),
		]
		if existing_key == key:
			return

	results.append(result)


func _normalize_node_path_string(path_value: Variant) -> String:
	var text := String(path_value)
	if text.is_empty():
		return "."
	return text


func _get_node_from_scene_root(scene_root: Node, node_path: String) -> Node:
	if scene_root == null:
		return null
	if node_path.is_empty() or node_path == ".":
		return scene_root
	return scene_root.get_node_or_null(NodePath(node_path))


func _format_result_text(result: Dictionary) -> String:
	return "Location: %s\nKind: %s\nDetails: %s\nTarget: %s" % [
		String(result.get("location", "")),
		String(result.get("kind", "")),
		String(result.get("details", "")),
		String(result.get("target", "")),
	]


func _format_result_line(result: Dictionary) -> String:
	return "%s | %s | %s | %s" % [
		String(result.get("location", "")),
		String(result.get("kind", "")),
		String(result.get("details", "")),
		String(result.get("target", "")),
	]
