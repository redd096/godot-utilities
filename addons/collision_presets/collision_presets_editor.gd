@tool
class_name CollisionPresetsEditor
extends VBoxContainer
## Inspector UI shown on CollisionObject3D, CSGShape and CollisionObject2D nodes.

## node target of this ui
var target: Node
## selected database for this object
var database: CollisionPresetsDatabase
## list of presets from database, sorted by name
var sorted_presets: Array[CollisionPreset] = []

## ui picker to select database
var database_picker: EditorResourcePicker
## ui dropdown to select preset
var preset_dropdown: OptionButton
## ui label for description of the preset
var description_label: Label

## when synced from target, use this to avoid call events on change database and on change preset
var _syncing_ui: bool = false


func _init() -> void:
	# add database picker and preset dropdown in inspector
	_build_ui()


## Set the node target of this ui
func set_target(object: Node) -> void:
	# set target, and update ui from it
	target = object
	_sync_from_target()

	# preset ui is showed only when use_collision is true in CSGShape3D
	# so activate process to continue check use_collision
	if target is CSGShape3D:
		set_process(true)
		_update_csg_visibility()
	# for other nodes, can deactivate process because is always showed
	else:
		set_process(false)


func _process(_delta: float) -> void:
	# check if use_collision change, to show or hide preset ui
	if target is CSGShape3D:
		_update_csg_visibility()


func _update_csg_visibility() -> void:
	# show preset ui only if use_collision is true
	if not is_instance_valid(target) or not (target is CSGShape3D):
		return
	visible = (target as CSGShape3D).use_collision


func _build_ui() -> void:
	custom_minimum_size = Vector2(0, 54)

	# add database row
	var database_row := HBoxContainer.new()
	database_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(database_row)

	# database row - label
	var database_label := Label.new()
	database_label.text = "Preset Database"
	database_label.custom_minimum_size.x = 110
	database_row.add_child(database_label)

	# database row - resource picker to select database
	database_picker = EditorResourcePicker.new()
	database_picker.base_type = CollisionPresetsConstants.DATABASE_NAME
	database_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	database_picker.tooltip_text = "Database resource used by this collision object."
	database_picker.resource_changed.connect(_on_database_selected)
	database_row.add_child(database_picker)

	# add preset row
	var preset_row := HBoxContainer.new()
	preset_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(preset_row)

	# preset row - label
	var preset_label := Label.new()
	preset_label.text = "Preset"
	preset_label.custom_minimum_size.x = 110
	preset_row.add_child(preset_label)

	# preset row - dropdown to select preset name from database
	preset_dropdown = OptionButton.new()
	preset_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preset_dropdown.disabled = true
	preset_dropdown.item_selected.connect(_on_preset_selected)
	preset_row.add_child(preset_dropdown)

	# add description row - description label
	description_label = Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.visible = false
	description_label.modulate.a = 0.75
	add_child(description_label)


## update ui from target
func _sync_from_target() -> void:
	if not is_instance_valid(target):
		return

	_syncing_ui = true

	# update database
	_set_database(CollisionPresetsAPI.get_node_database(target))
	database_picker.edited_resource = database
	_refresh_dropdown()

	# update preset
	var preset: CollisionPreset = CollisionPresetsAPI.get_node_preset(target)
	if preset != null:
		# if preset is in dropdown, select it
		var index: int = _find_dropdown_index_by_id(preset.id)
		if index >= 0:
			preset_dropdown.select(index)
			_show_description(preset)
			CollisionPresetsAPI.apply_preset_values(target, preset)
			_syncing_ui = false
			return

	# else, reset to 0
	preset_dropdown.select(0)
	_show_description(null)

	_syncing_ui = false


func _set_database(value: CollisionPresetsDatabase) -> void:
	# if already same database, do nothing
	if database == value:
		return

	# disconnect previous database
	if database != null and database.changed.is_connected(_on_database_contents_changed):
		database.changed.disconnect(_on_database_contents_changed)

	database = value

	# connect new database
	if database != null:
		if not database.changed.is_connected(_on_database_contents_changed):
			database.changed.connect(_on_database_contents_changed)
		_ensure_preset_ids(database)


## database selected by picker in ui
func _on_database_selected(resource: Resource) -> void:
	if _syncing_ui or not is_instance_valid(target):
		return

	# when selected from UI Picker, set database in node
	var new_database := resource as CollisionPresetsDatabase
	_set_database(new_database)
	
	# clear presets meta, set only database meta
	CollisionPresetsAPI.clear_node_preset_and_database(target)
	if new_database != null:
		CollisionPresetsAPI.set_node_database(target, new_database)

	# reset presets dropdown and description
	_refresh_dropdown()
	_show_description(null)

	# and mark scene to save
	EditorInterface.mark_scene_as_unsaved()


## preset selected from dropdown in ui
func _on_preset_selected(index: int) -> void:
	if _syncing_ui or not is_instance_valid(target) or database == null:
		return
	
	# index 0 is None Preset, not present in sorted_presets
	index = index - 1

	# set preset metas and show description in ui
	if index >= 0 and index < sorted_presets.size():
		var preset: CollisionPreset = sorted_presets[index]
		CollisionPresetsAPI.set_node_preset(target, database, preset)
		_show_description(preset)
	# if wrong preset, clear presets meta and hide description
	else:
		CollisionPresetsAPI.clear_node_preset(target)
		_show_description(null)
		
	# and mark scene to save
	EditorInterface.mark_scene_as_unsaved()


## on edit variables in database resource
func _on_database_contents_changed() -> void:
	if database == null:
		return

	# refresh presets dropdown
	_ensure_preset_ids(database)
	_refresh_dropdown()

	if not is_instance_valid(target):
		return

	# try update preset (e.g. preset was renamed inside database)
	var preset: CollisionPreset = CollisionPresetsAPI.get_node_preset(target)
	if preset != null:
		var index: int = _find_dropdown_index_by_id(preset.id)
		if index >= 0:
			preset_dropdown.select(index)
			CollisionPresetsAPI.apply_preset_values(target, preset)
			_show_description(preset)
			EditorInterface.mark_scene_as_unsaved()
			return

	preset_dropdown.select(0)
	_show_description(null)


func _refresh_dropdown() -> void:
	# first item in dropdown "No Preset"
	preset_dropdown.clear()
	preset_dropdown.add_item("Select a preset...")
	sorted_presets.clear()

	if database == null:
		preset_dropdown.disabled = true
		return

	# then copy database presets and sort by name
	for preset: CollisionPreset in database.presets:
		if preset != null:
			sorted_presets.append(preset)

	sorted_presets.sort_custom(func(a: CollisionPreset, b: CollisionPreset) -> bool:
		return a.name.to_lower() < b.name.to_lower()
	)

	# add every preset to the dropdown (if no name, show "Unnamed Preset")
	for preset: CollisionPreset in sorted_presets:
		var label: String = preset.name if not preset.name.strip_edges().is_empty() else "<Unnamed Preset>"
		preset_dropdown.add_item(label)

	# enable dropdown only if there are available presets
	preset_dropdown.disabled = sorted_presets.is_empty()


func _find_dropdown_index_by_id(id: String) -> int:
	if id.is_empty():
		return -1

	# find index in presets by id
	for i: int in range(sorted_presets.size()):
		if sorted_presets[i].id == id:
			return i + 1

	return -1


func _show_description(preset: CollisionPreset) -> void:
	# hide
	if preset == null or preset.description.strip_edges().is_empty():
		description_label.text = ""
		description_label.visible = false
		return

	# or show description
	description_label.text = preset.description
	description_label.visible = true


## Ensures every preset in a database has a unique stable ID.
## This also repairs duplicated IDs if a preset resource was duplicated manually.
func _ensure_preset_ids(db: CollisionPresetsDatabase) -> void:
	var used_ids: Dictionary = {}
	var changed: bool = false

	for preset: CollisionPreset in db.presets:
		if preset == null:
			continue

		# if id empty or already used, generate new one
		if preset.id.is_empty() or used_ids.has(preset.id):
			preset.id = str(ResourceUID.create_id())
			changed = true

		used_ids[preset.id] = true

	if not changed:
		return

	# call event on changed database content
	db.emit_changed()

	# External database resources are saved immediately so generated IDs survive
	# even before the scene itself is saved.
	if not db.resource_path.is_empty() and not db.resource_path.contains("::"):
		var error: Error = ResourceSaver.save(db, db.resource_path)
		if error != OK:
			push_warning("Collision Presets: Could not save generated preset IDs to %s" % db.resource_path)
