@tool
extends EditorPlugin

const FinderPanelScript := preload("res://addons/asset_usage_detector/finder_panel.gd")

var _panel: Control
var _panel_button: Button
var _scene_context_menu: EditorContextMenuPlugin
var _filesystem_context_menu: EditorContextMenuPlugin


class SceneContextMenuPluginImpl:
	extends EditorContextMenuPlugin

	var _plugin: EditorPlugin

	func _init(plugin: EditorPlugin) -> void:
		_plugin = plugin

	func _popup_menu(paths: PackedStringArray) -> void:
		if paths.is_empty():
			return

		add_context_menu_item(
			"Find References in Current Scene",
			Callable(_plugin, "_on_scene_context_find").bind(false)
		)
		add_context_menu_item(
			"Find References in Current Scene (Include Children)",
			Callable(_plugin, "_on_scene_context_find").bind(true)
		)


class FilesystemContextMenuPluginImpl:
	extends EditorContextMenuPlugin

	var _plugin: EditorPlugin

	func _init(plugin: EditorPlugin) -> void:
		_plugin = plugin

	func _popup_menu(paths: PackedStringArray) -> void:
		if paths.is_empty():
			return

		add_context_menu_item(
			"Find References in Project",
			Callable(_plugin, "_on_filesystem_context_find")
		)


func _enter_tree() -> void:
	_panel = FinderPanelScript.new()
	_panel.setup(self)
	_panel_button = add_control_to_bottom_panel(_panel, "References")

	_scene_context_menu = SceneContextMenuPluginImpl.new(self)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, _scene_context_menu)

	_filesystem_context_menu = FilesystemContextMenuPluginImpl.new(self)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, _filesystem_context_menu)


func _exit_tree() -> void:
	if _scene_context_menu != null:
		remove_context_menu_plugin(_scene_context_menu)
		_scene_context_menu = null

	if _filesystem_context_menu != null:
		remove_context_menu_plugin(_filesystem_context_menu)
		_filesystem_context_menu = null

	if _panel != null:
		remove_control_from_bottom_panel(_panel)
		_panel.queue_free()
		_panel = null
		_panel_button = null


func _on_scene_context_find(selected_nodes: Array, include_children: bool) -> void:
	if _panel == null:
		return

	_panel.start_scene_search(selected_nodes, include_children)
	make_bottom_panel_item_visible(_panel)


func _on_filesystem_context_find(paths: PackedStringArray) -> void:
	if _panel == null:
		return

	_panel.start_project_search(paths)
	make_bottom_panel_item_visible(_panel)


func focus_current_scene_node(node_path: String) -> void:
	var scene_root: Node = get_editor_interface().get_edited_scene_root()
	if scene_root == null:
		return

	var node: Node = _get_node_from_relative_path(scene_root, node_path)
	if node == null:
		return

	var selection := get_editor_interface().get_selection()
	selection.clear()
	selection.add_node(node)
	get_editor_interface().edit_node(node)


func focus_scene_node(scene_path: String, node_path: String) -> void:
	if scene_path.is_empty():
		focus_current_scene_node(node_path)
		return

	get_editor_interface().open_scene_from_path(scene_path)
	call_deferred("_focus_scene_node_deferred", scene_path, node_path, 0)


func focus_scene_file(scene_path: String) -> void:
	if scene_path.is_empty():
		return

	get_editor_interface().select_file(scene_path)


func _focus_scene_node_deferred(scene_path: String, node_path: String, attempt: int) -> void:
	var roots: Array[Node] = get_editor_interface().get_open_scene_roots()
	for root in roots:
		if root != null and root.scene_file_path == scene_path:
			var node: Node = _get_node_from_relative_path(root, node_path)
			if node == null:
				get_editor_interface().select_file(scene_path)
				return

			var selection := get_editor_interface().get_selection()
			selection.clear()
			selection.add_node(node)
			get_editor_interface().edit_node(node)
			return

	if attempt < 8:
		call_deferred("_focus_scene_node_deferred", scene_path, node_path, attempt + 1)
	else:
		get_editor_interface().select_file(scene_path)


func focus_file(path: String) -> void:
	if path.is_empty():
		return

	get_editor_interface().select_file(path)

	var resource: Resource = ResourceLoader.load(path)
	if resource != null:
		get_editor_interface().edit_resource(resource)


func _get_node_from_relative_path(root: Node, node_path: String) -> Node:
	if root == null:
		return null

	if node_path.is_empty() or node_path == ".":
		return root

	return root.get_node_or_null(NodePath(node_path))
