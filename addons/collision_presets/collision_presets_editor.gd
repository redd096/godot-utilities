@tool
class_name CollisionPresetsEditor
extends VBoxContainer
## Inspector UI shown on CollisionObject3D, CSGShape and CollisionObject2D nodes.

var target: Node
var database: CollisionPresetsDatabase
var sorted_presets: Array[CollisionPreset] = []

var database_picker: EditorResourcePicker
var preset_dropdown: OptionButton
var description_label: Label

var _syncing_ui: bool = false


func _init() -> void:
	_build_ui()


func set_target(object: Node) -> void:
	target = object
	_sync_from_target()

	# CSG collision presets are only meaningful while Use Collision is enabled.
	if target is CSGShape3D:
		set_process(true)
		_update_csg_visibility()
	else:
		set_process(false)


func _process(_delta: float) -> void:
	if target is CSGShape3D:
		_update_csg_visibility()


func _update_csg_visibility() -> void:
	if not is_instance_valid(target) or not (target is CSGShape3D):
		return
	visible = (target as CSGShape3D).use_collision


func _build_ui() -> void:
	custom_minimum_size = Vector2(0, 54)

	var database_row := HBoxContainer.new()
	database_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(database_row)

	var database_label := Label.new()
	database_label.text = "Preset Database"
	database_label.custom_minimum_size.x = 110
	database_row.add_child(database_label)

	database_picker = EditorResourcePicker.new()
	database_picker.base_type = "CollisionPresetsDatabase"
	database_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	database_picker.tooltip_text = "CollisionPresetsDatabase resource used by this collision object."
	database_picker.resource_changed.connect(_on_database_changed)
	database_row.add_child(database_picker)

	var preset_row := HBoxContainer.new()
	preset_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(preset_row)

	var preset_label := Label.new()
	preset_label.text = "Preset"
	preset_label.custom_minimum_size.x = 110
	preset_row.add_child(preset_label)

	preset_dropdown = OptionButton.new()
	preset_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preset_dropdown.disabled = true
	preset_dropdown.item_selected.connect(_on_preset_selected)
	preset_row.add_child(preset_dropdown)

	description_label = Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.visible = false
	description_label.modulate.a = 0.75
	add_child(description_label)


func _sync_from_target() -> void:
	if not is_instance_valid(target):
		return

	_syncing_ui = true

	_set_database(CollisionPresetsAPI.get_node_database(target))
	database_picker.edited_resource = database
	_refresh_dropdown()

	var preset: CollisionPreset = CollisionPresetsAPI.get_node_preset(target)
	if preset != null:
		var index := _find_dropdown_index_by_id(preset.id)
		if index >= 0:
			preset_dropdown.select(index)
			_show_description(preset)
			CollisionPresetsAPI.apply_preset_values(target, preset)
			# Refresh the cached name after a rename without changing the stable ID.
			target.set_meta(CollisionPresetsConstants.META_NAME_KEY, preset.name)
		else:
			preset_dropdown.select(0)
			_show_description(null)
	else:
		preset_dropdown.select(0)
		_show_description(null)

	_syncing_ui = false


func _set_database(value: CollisionPresetsDatabase) -> void:
	if database == value:
		return

	if database != null and database.changed.is_connected(_on_database_contents_changed):
		database.changed.disconnect(_on_database_contents_changed)

	database = value

	if database != null:
		if not database.changed.is_connected(_on_database_contents_changed):
			database.changed.connect(_on_database_contents_changed)
		_ensure_preset_ids(database)


func _on_database_changed(resource: Resource) -> void:
	if _syncing_ui or not is_instance_valid(target):
		return

	var new_database := resource as CollisionPresetsDatabase
	_set_database(new_database)

	if new_database == null:
		CollisionPresetsAPI.clear_node_preset(target)
	else:
		target.set_meta(CollisionPresetsConstants.META_DATABASE_KEY, new_database)
		if target.has_meta(CollisionPresetsConstants.META_ID_KEY):
			target.remove_meta(CollisionPresetsConstants.META_ID_KEY)
		if target.has_meta(CollisionPresetsConstants.META_NAME_KEY):
			target.remove_meta(CollisionPresetsConstants.META_NAME_KEY)

	_refresh_dropdown()
	_show_description(null)
	EditorInterface.mark_scene_as_unsaved()


func _on_preset_selected(index: int) -> void:
	if _syncing_ui or not is_instance_valid(target) or database == null:
		return

	if index <= 0 or index - 1 >= sorted_presets.size():
		if target.has_meta(CollisionPresetsConstants.META_ID_KEY):
			target.remove_meta(CollisionPresetsConstants.META_ID_KEY)
		if target.has_meta(CollisionPresetsConstants.META_NAME_KEY):
			target.remove_meta(CollisionPresetsConstants.META_NAME_KEY)
		_show_description(null)
		EditorInterface.mark_scene_as_unsaved()
		return

	var preset: CollisionPreset = sorted_presets[index - 1]
	CollisionPresetsAPI.set_node_preset(target, database, preset)
	_show_description(preset)
	EditorInterface.mark_scene_as_unsaved()


func _on_database_contents_changed() -> void:
	if database == null:
		return

	_ensure_preset_ids(database)
	_refresh_dropdown()

	if not is_instance_valid(target):
		return

	var preset := CollisionPresetsAPI.get_node_preset(target)
	if preset != null:
		var index := _find_dropdown_index_by_id(preset.id)
		if index >= 0:
			preset_dropdown.select(index)
			CollisionPresetsAPI.apply_node_preset(target)
			_show_description(preset)
			EditorInterface.mark_scene_as_unsaved()
			return

	preset_dropdown.select(0)
	_show_description(null)


func _refresh_dropdown() -> void:
	preset_dropdown.clear()
	preset_dropdown.add_item("Select a preset...")
	sorted_presets.clear()

	if database == null:
		preset_dropdown.disabled = true
		return

	for preset: CollisionPreset in database.presets:
		if preset != null:
			sorted_presets.append(preset)

	sorted_presets.sort_custom(func(a: CollisionPreset, b: CollisionPreset) -> bool:
		return a.name.to_lower() < b.name.to_lower()
	)

	for preset: CollisionPreset in sorted_presets:
		var label := preset.name if not preset.name.strip_edges().is_empty() else "<Unnamed Preset>"
		preset_dropdown.add_item(label)

	preset_dropdown.disabled = sorted_presets.is_empty()


func _find_dropdown_index_by_id(id: String) -> int:
	if id.is_empty():
		return -1

	for i: int in range(sorted_presets.size()):
		if sorted_presets[i].id == id:
			return i + 1

	return -1


func _show_description(preset: CollisionPreset) -> void:
	if preset == null or preset.description.strip_edges().is_empty():
		description_label.text = ""
		description_label.visible = false
		return

	description_label.text = preset.description
	description_label.visible = true


## Ensures every preset in a database has a unique stable ID.
## This also repairs duplicated IDs if a preset resource was duplicated manually.
func _ensure_preset_ids(db: CollisionPresetsDatabase) -> void:
	var used_ids: Dictionary = {}
	var changed := false

	for preset: CollisionPreset in db.presets:
		if preset == null:
			continue

		if preset.id.is_empty() or used_ids.has(preset.id):
			preset.id = str(ResourceUID.create_id())
			changed = true

		used_ids[preset.id] = true

	if not changed:
		return

	db.emit_changed()

	# External database resources are saved immediately so generated IDs survive
	# even before the scene itself is saved.
	if not db.resource_path.is_empty() and not db.resource_path.contains("::"):
		var error := ResourceSaver.save(db, db.resource_path)
		if error != OK:
			push_warning("Collision Presets: Could not save generated preset IDs to %s" % db.resource_path)
