class_name DataPresetsAPI 
extends RefCounted
## Shared API used by both the editor UI and the runtime autoload


#region get preset from database


## Returns the preset by ID from this database
static func get_preset_by_id(database: BaseDataPresetsDatabase, preset_id: int) -> BaseDataPreset:
	if database == null or preset_id == ResourceUID.INVALID_ID:
		return null

	# find in array by id
	for preset: BaseDataPreset in database.presets:
		if preset != null and preset.id == preset_id:
			return preset

	return null


## Returns the first preset with the given name from this database
static func get_preset_by_name(database: BaseDataPresetsDatabase, preset_name: String) -> BaseDataPreset:
	if database == null or preset_name.is_empty():
		return null

	# find in array by name
	for preset: BaseDataPreset in database.presets:
		if preset != null and preset.name == preset_name:
			return preset

	return null


## Returns a specific preset referenced by a node
static func get_node_preset_from_database(node: Object, database: BaseDataPresetsDatabase) -> BaseDataPreset:
	if database == null:
		return null
	
	var database_type: StringName = database.get_database_type()

	# try find preset by id
	var preset_ids: Dictionary[StringName, int] = get_node_preset_ids(node)
	if preset_ids.has(database_type):
		var preset: BaseDataPreset = get_preset_by_id(database, preset_ids[database_type])
		if preset != null:
			return preset

	# else, try find by name
	var preset_names: Dictionary[StringName, String] = get_node_preset_names(node)
	if preset_names.has(database_type):
		return get_preset_by_name(database, preset_names[database_type])

	return null


#endregion


#region get from node


## Return every database referenced by this node (key: DatabaseType, value: reference to Database Resource)
static func get_node_databases(node: Object) -> Dictionary[StringName, BaseDataPresetsDatabase]:
	if node == null or not node.has_meta(DataPresetsConstants.META_DATABASES_REF_KEY):
		return {}

	return node.get_meta(DataPresetsConstants.META_DATABASES_REF_KEY) as Dictionary[StringName, BaseDataPresetsDatabase]


## Return every preset ID referenced by this node (key: DatabaseType, value: Preset ID)
static func get_node_preset_ids(node: Object) -> Dictionary[StringName, int]:
	if node == null or not node.has_meta(DataPresetsConstants.META_PRESET_IDS_KEY):
		return {}

	return node.get_meta(DataPresetsConstants.META_PRESET_IDS_KEY) as Dictionary[StringName, int]


## Return every preset name referenced by this node (key: DatabaseType, value: Preset name)
static func get_node_preset_names(node: Object) -> Dictionary[StringName, String]:
	if node == null or not node.has_meta(DataPresetsConstants.META_PRESET_NAMES_KEY):
		return {}

	return node.get_meta(DataPresetsConstants.META_PRESET_NAMES_KEY) as Dictionary[StringName, String]


## Return every preset referenced by this node (key: DatabaseType, value: Preset)
static func get_node_presets(node: Object) -> Dictionary[StringName, BaseDataPreset]:
	# get all databases and saved preset identifiers
	var databases: Dictionary[StringName, BaseDataPresetsDatabase] = get_node_databases(node)
	var preset_ids: Dictionary[StringName, int] = get_node_preset_ids(node)
	var preset_names: Dictionary[StringName, String] = get_node_preset_names(node)

	var presets: Dictionary[StringName, BaseDataPreset] = {}

	# cycle every database type
	for database_type: StringName in databases:		
		var database: BaseDataPresetsDatabase = databases[database_type]
		if database == null:
			continue

		# try find preset by id
		if preset_ids.has(database_type):
			var preset: BaseDataPreset = get_preset_by_id(database, preset_ids[database_type])
			if preset != null:
				presets.get_or_add(database_type, preset)
		# else, try find by name
		elif preset_names.has(database_type):
			var preset: BaseDataPreset = get_preset_by_name(database, preset_names[database_type])
			if preset != null:
				presets.get_or_add(database_type, preset)

	return presets


## Returns a specific database referenced by this node
static func get_node_database_by_type(node: Object, database_type: StringName) -> BaseDataPresetsDatabase:
	# get all databases
	var databases: Dictionary[StringName, BaseDataPresetsDatabase] = get_node_databases(node)
	
	# and find the specific one by type
	if databases.has(database_type):
		return databases[database_type]
	
	return null


## Returns a specific preset referenced by a node
static func get_node_preset_by_type(node: Object, database_type: StringName) -> BaseDataPreset:
	# get database by type
	var database: BaseDataPresetsDatabase = get_node_database_by_type(node, database_type)
		
	# find preset inside database
	return get_node_preset_from_database(node, database)


#endregion


#region clear


## Removes the plugin's database/preset reference from a node. [br]
## Changed node values are left unchanged (e.g. layer and mask with collision 3d preset)
static func clear_node_preset_and_database(node: Object, database_type: StringName) -> void:
	if node == null:
		return
	
	# remove database from dictionary
	var databases: Dictionary[StringName, BaseDataPresetsDatabase] = get_node_databases(node)
	if databases.has(database_type):
		databases.erase(database_type)
	
	#and save in meta
	if databases.is_empty():
		node.remove_meta(DataPresetsConstants.META_DATABASES_REF_KEY)
	else:
		node.set_meta(DataPresetsConstants.META_DATABASES_REF_KEY, databases)

	# and remove presets meta
	clear_node_preset(node, database_type)


## Removes the plugin's preset reference from a node. [br]
## Changed node values are left unchanged (e.g. layer and mask with collision 3d preset)
static func clear_node_preset(node: Object, database_type: StringName) -> void:
	if node == null:
		return
	
	# remove id and name from dictionaries
	var preset_ids: Dictionary[StringName, int] = get_node_preset_ids(node)
	var preset_names: Dictionary[StringName, String] = get_node_preset_names(node)
	preset_ids.erase(database_type)
	preset_names.erase(database_type)

	# and save in meta
	if preset_ids.is_empty():
		node.remove_meta(DataPresetsConstants.META_PRESET_IDS_KEY)
	else:
		node.set_meta(DataPresetsConstants.META_PRESET_IDS_KEY, preset_ids)

	if preset_names.is_empty():
		node.remove_meta(DataPresetsConstants.META_PRESET_NAMES_KEY)
	else:
		node.set_meta(DataPresetsConstants.META_PRESET_NAMES_KEY, preset_names)


#endregion


#region set


## Save database in node's meta. [br]
## Return true if both node and database are valids
static func set_node_database(node: Object, database: BaseDataPresetsDatabase) -> bool:
	if node == null or database == null:
		return false
	
	# add to dictionary
	var databases: Dictionary[StringName, BaseDataPresetsDatabase] = get_node_databases(node)
	databases[database.get_database_type()] = database

	# save in node's meta
	node.set_meta(DataPresetsConstants.META_DATABASES_REF_KEY, databases)

	return true


## Save preset in node's meta. [br]
## Return true if node, database and preset are valids
static func set_node_preset(node: Object, database: BaseDataPresetsDatabase, preset: BaseDataPreset) -> bool:
	if node == null or database == null or preset == null:
		return false
	
	# add to dictionaries
	var database_type: StringName = database.get_database_type()
	var preset_ids: Dictionary[StringName, int] = get_node_preset_ids(node)
	var preset_names: Dictionary[StringName, String] = get_node_preset_names(node)
	preset_ids[database_type] = preset.id
	preset_names[database_type] = preset.name

	# save in node's meta
	node.set_meta(DataPresetsConstants.META_PRESET_IDS_KEY, preset_ids)
	node.set_meta(DataPresetsConstants.META_PRESET_NAMES_KEY, preset_names)
	
	return true


## Save database and preset in node's meta. Then apply its values. [br]
## Return true if everything works
static func set_node_and_apply(node: Object, database: BaseDataPresetsDatabase, preset: BaseDataPreset) -> bool:
	if node == null or database == null or preset == null:
		return false
	
	# save database and preset, then apply in scene
	set_node_database(node, database)
	set_node_preset(node, database, preset)
	return apply_preset_values(node, preset)


## If preset in database is different from the saved ID/name, update it. [br]
## Return true if add or update the saved one. Return false if already correct
static func update_saved_preset_reference(node: Object, database: BaseDataPresetsDatabase, preset: BaseDataPreset) -> bool:
	if node == null or database == null or preset == null:
		return false
	
	var database_type: StringName = database.get_database_type()
	
	# get saved id and name
	var preset_ids: Dictionary[StringName, int] = get_node_preset_ids(node)
	var preset_names: Dictionary[StringName, String] = get_node_preset_names(node)
	var saved_id: int = preset_ids.get(database_type, ResourceUID.INVALID_ID)
	var saved_name: String = preset_names.get(database_type, "")

	# if different from preset, update them
	if saved_id != preset.id or saved_name != preset.name:
		preset_ids[database_type] = preset.id
		preset_names[database_type] = preset.name
		node.set_meta(DataPresetsConstants.META_PRESET_IDS_KEY, preset_ids)
		node.set_meta(DataPresetsConstants.META_PRESET_NAMES_KEY, preset_names)
		return true
	
	return false


#endregion


#region apply


## Applies the presets already stored on a node
static func apply_node_preset(node: Object) -> bool:	
	# get all presets
	var presets: Dictionary[StringName, BaseDataPreset] = get_node_presets(node)

	# and apply in scene
	var applied: bool
	
	for preset in presets.values():
		if apply_preset_values(node, preset):
			applied = true

	return applied


## Applies values from preset. [br]
## Return true if apply at least one value
static func apply_preset_values(node: Object, preset: BaseDataPreset) -> bool:
	if node == null or preset == null:
		return false

	# apply values in scene
	return preset.apply_values(node)


#endregion
