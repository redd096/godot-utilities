@tool
@abstract
class_name BaseDataUI
extends VBoxContainer
## Inspector UI instantiated from custom inspector


## target that implement this ui
var target: Object
## selected database for this object
var database: BaseDataPresetsDatabase
## list of presets from database, sorted by name
var sorted_presets: Array[BaseDataPreset] = []

## ui picker to select database
var database_editor: EditorProperty
## ui dropdown to select preset
var preset_dropdown: OptionButton
## ui label for description of the preset
var description_label: Label

## when synced from target, use this to avoid call events on change database and on change preset
var _syncing_ui: bool = false


func _init() -> void:
	# add database picker and preset dropdown in inspector
	_build_ui()


## Set the target of this ui
func set_target(object: Object) -> void:
	# set target, and update ui from it
	target = object
	_sync_from_target()
	

@abstract
func _get_database_type() -> StringName


func _build_ui() -> void:
	custom_minimum_size = Vector2(0, 54)

	# add database row
	database_editor = EditorInspector.instantiate_property_editor(
		self,
		TYPE_OBJECT,
		&"database",
		PROPERTY_HINT_RESOURCE_TYPE,
		String(_get_database_type()),
		PROPERTY_USAGE_DEFAULT,
		false
	)

	database_editor.label = "Preset Database"
	database_editor.use_folding = true
	database_editor.tooltip_text = "Database resource used by this object."

	database_editor.set_object_and_property(self, &"database")
	database_editor.property_changed.connect(_on_database_selected)
	database_editor.update_property()

	add_child(database_editor)

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
	_set_database(DataPresetsAPI.get_node_database_by_type(target, _get_database_type()))
	database_editor.update_property()
	_refresh_dropdown()

	# update preset
	var preset: BaseDataPreset = DataPresetsAPI.get_node_preset_from_database(target, database)
	if preset != null:
		# if preset is in dropdown, select it
		var index: int = _find_dropdown_index_by_id(preset.id)
		if index >= 0:
			preset_dropdown.select(index)
			_show_description(preset)
			DataPresetsAPI.apply_preset_values(target, preset)
			DataPresetsAPI.update_saved_struct_from_database_preset(target, database, preset)
			_syncing_ui = false
			return

	# else, reset to 0
	preset_dropdown.select(0)
	_show_description(null)

	_syncing_ui = false


func _set_database(value: BaseDataPresetsDatabase) -> void:
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


#region events


## database selected by picker in ui
func _on_database_selected(property: StringName, value: Variant, _field: StringName, _changing: bool) -> void:
	if _syncing_ui or property != &"database" or not is_instance_valid(target):
		return

	# when selected from UI Picker, set database in node
	var new_database := value as BaseDataPresetsDatabase
	_set_database(new_database)
	
	# clear presets meta, set only database meta
	DataPresetsAPI.clear_node_preset_and_database(target, _get_database_type())
	if new_database != null:
		DataPresetsAPI.set_node_database(target, new_database)

	# reset presets dropdown and description
	_refresh_dropdown()
	preset_dropdown.select(0)
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
		var preset: BaseDataPreset = sorted_presets[index]
		DataPresetsAPI.set_node_and_apply(target, database, preset)
		_show_description(preset)
	# if wrong preset, clear presets meta and hide description
	else:
		DataPresetsAPI.clear_node_preset(target, _get_database_type())
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
	var preset: BaseDataPreset = DataPresetsAPI.get_node_preset_from_database(target, database)
	if preset != null:
		var index: int = _find_dropdown_index_by_id(preset.id)
		if index >= 0:
			preset_dropdown.select(index)
			_show_description(preset)
			DataPresetsAPI.apply_preset_values(target, preset)
			DataPresetsAPI.update_saved_struct_from_database_preset(target, database, preset)
			EditorInterface.mark_scene_as_unsaved()
			return

	preset_dropdown.select(0)
	_show_description(null)


#endregion


func _refresh_dropdown() -> void:
	# first item in dropdown "No Preset"
	preset_dropdown.clear()
	preset_dropdown.add_item("Select a preset...")
	sorted_presets.clear()

	if database == null:
		preset_dropdown.disabled = true
		return

	# then copy database presets
	for preset: BaseDataPreset in database.presets:
		if preset != null:
			sorted_presets.append(preset)

	# # and sort by name
	# sorted_presets.sort_custom(func(a: BaseDataPreset, b: BaseDataPreset) -> bool:
	# 	return a.name.to_lower() < b.name.to_lower()
	# )

	# add every preset to the dropdown (if no name, show "Unnamed Preset")
	for preset: BaseDataPreset in sorted_presets:
		var label: String = preset.name if not preset.name.strip_edges().is_empty() else "<Unnamed Preset>"
		preset_dropdown.add_item(label)

	# enable dropdown only if there are available presets
	preset_dropdown.disabled = sorted_presets.is_empty()


func _find_dropdown_index_by_id(id: int) -> int:
	if id == ResourceUID.INVALID_ID:
		return -1

	# find index in presets by id
	for i: int in range(sorted_presets.size()):
		if sorted_presets[i].id == id:
			return i + 1

	return -1


func _show_description(preset: BaseDataPreset) -> void:
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
func _ensure_preset_ids(db: BaseDataPresetsDatabase) -> void:
	var used_ids: Array[int] = []
	var changed: bool = false

	for preset: BaseDataPreset in db.presets:
		if preset == null:
			continue

		# if id is invalid or already used, generate a new one
		if preset.id == ResourceUID.INVALID_ID or used_ids.has(preset.id):
			preset.id = ResourceUID.create_id()
			changed = true

		used_ids.append(preset.id)

	if not changed:
		return

	# External database resources are saved immediately so generated IDs survive
	# even before the scene itself is saved.
	if not db.resource_path.is_empty() and not db.resource_path.contains("::"):
		var error: Error = ResourceSaver.save(db, db.resource_path)
		if error != OK:
			push_warning("Database Presets: Could not save generated preset IDs to %s" % db.resource_path)
