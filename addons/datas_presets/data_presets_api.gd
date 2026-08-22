class_name DataPresetsAPI 
extends RefCounted
## Shared API used by both the editor UI and the runtime autoload


#region get preset from database


## Returns the preset by ID from this database
static func get_preset_by_id(database: BaseDataPresetsDatabase, preset_id: String) -> BaseDataPreset:
	if database == null or preset_id.is_empty():
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
	
	# get preset id and name for that database type
	var preset_struct: DataPresetStruct = get_node_preset_struct_by_type(node, database.get_database_type())
	if preset_struct == null:
		return null

	# try find preset by id
	var preset: BaseDataPreset = get_preset_by_id(database, preset_struct.id)
	if preset != null:
		return preset

	# else, try find by name
	preset = get_preset_by_name(database, preset_struct.name)
	if preset != null:
		return preset

	return null


#endregion


#region get from node


## Return every database referenced by this node
static func get_node_databases(node: Object) -> Dictionary[String, BaseDataPresetsDatabase]:
	if node == null or not node.has_meta(DataPresetsConstants.META_DATABASES_REF_KEY):
		return {}

	# get array of databases by meta
	return node.get_meta(DataPresetsConstants.META_DATABASES_REF_KEY) as Dictionary[String, BaseDataPresetsDatabase]


## Return every preset struct referenced by this node (key: DatabaseType, value: Preset id and name)
static func get_node_presets_structs(node: Object) -> Dictionary[String, DataPresetStruct]:
	if node == null or not node.has_meta(DataPresetsConstants.META_PRESETS_KEY):
		return {}

	# get dictionary of presets by meta
	return node.get_meta(DataPresetsConstants.META_PRESETS_KEY) as Dictionary[String, DataPresetStruct]


## Return every preset referenced by this node (key: DatabaseType, value: Preset)
static func get_node_presets(node: Object) -> Dictionary[String, BaseDataPreset]:
	# get all databases and presets structs
	var databases: Dictionary[String, BaseDataPresetsDatabase] = get_node_databases(node)
	var presets_structs: Dictionary[String, DataPresetStruct] = get_node_presets_structs(node)

	var presets: Dictionary[String, BaseDataPreset] = {}

	# cycle every database type
	for database_type: String in databases:
		if not databases.has(database_type) or not presets_structs.has(database_type):
			continue
		
		# get database and preset struct
		var database: BaseDataPresetsDatabase = databases[database_type]
		var preset_struct: DataPresetStruct = presets_structs[database_type]
		if database == null or preset_struct == null:
			continue

		# try find preset by id
		var preset: BaseDataPreset = get_preset_by_id(database, preset_struct.id)
		if preset != null:
			presets.get_or_add(database_type, preset)
		# else, try find by name
		else:
			preset = get_preset_by_name(database, preset_struct.name)
			if preset != null:
				presets.get_or_add(database_type, preset)

	return presets


## Returns a specific database referenced by this node
static func get_node_database_by_type(node: Object, database_type: String) -> BaseDataPresetsDatabase:
	# get all databases
	var databases: Dictionary[String, BaseDataPresetsDatabase] = get_node_databases(node)
	
	# and find the specific one by type
	if databases.has(database_type):
		return databases[database_type]
	
	return null


## Returns a specific preset struct referenced by this node
static func get_node_preset_struct_by_type(node: Object, database_type: String) -> DataPresetStruct:
	# get all presets structs
	var presets_structs: Dictionary[String, DataPresetStruct] = get_node_presets_structs(node)
	
	# and find the specific one by type
	if presets_structs.has(database_type):
		return presets_structs[database_type]

	return null


## Returns a specific preset referenced by a node
static func get_node_preset_by_type(node: Object, database_type: String) -> BaseDataPreset:
	# get database by type
	var database: BaseDataPresetsDatabase = get_node_database_by_type(node, database_type)
		
	# find preset inside database
	return get_node_preset_from_database(node, database)


#endregion


#region clear


## Removes the plugin's database/preset reference from a node. [br]
## Changed node values are left unchanged (e.g. layer and mask with collision 3d preset)
static func clear_node_preset_and_database(node: Object, database_type: String) -> void:
	if node == null:
		return
	
	# remove database from dictionary
	var databases: Dictionary[String, BaseDataPresetsDatabase] = get_node_databases(node)
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
static func clear_node_preset(node: Object, database_type: String) -> void:
	if node == null:
		return
	
	# remove preset struct from dictionary
	var presets_structs: Dictionary[String, DataPresetStruct] = get_node_presets_structs(node)
	if presets_structs.has(database_type):
		presets_structs.erase(database_type)
	
	#and save in meta
	if presets_structs.is_empty():
		node.remove_meta(DataPresetsConstants.META_PRESETS_KEY)
	else:
		node.set_meta(DataPresetsConstants.META_PRESETS_KEY, presets_structs)


#endregion


#region set


## Save database in node's meta. [br]
## Return true if both node and database are valids
static func set_node_database(node: Object, database: BaseDataPresetsDatabase) -> bool:
	if node == null or database == null:
		return false
	
	# add to dictionary
	var databases: Dictionary[String, BaseDataPresetsDatabase] = get_node_databases(node)
	databases[database.get_database_type()] = database

	# save in node's meta
	node.set_meta(DataPresetsConstants.META_DATABASES_REF_KEY, databases)

	return true


## Save preset in node's meta. [br]
## Return true if node, database and preset are valids
static func set_node_preset(node: Object, database: BaseDataPresetsDatabase, preset: BaseDataPreset) -> bool:
	if node == null or database == null or preset == null:
		return false
	
	# add to dictionary
	var presets_structs: Dictionary[String, DataPresetStruct] = get_node_presets_structs(node)
	var new_struct: DataPresetStruct = DataPresetStruct.new()
	presets_structs[database.get_database_type()] = new_struct.setup(preset)

	# save in node's meta
	node.set_meta(DataPresetsConstants.META_PRESETS_KEY, presets_structs)
	
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


## If preset in database is different from saved one, update saved one. [br]
## Return true if add or update the saved one. Return false if already correct
static func update_saved_struct_from_database_preset(node: Object, database: BaseDataPresetsDatabase, preset: BaseDataPreset) -> bool:
	if node == null or database == null or preset == null:
		return false
	
	var database_type: String = database.get_database_type()
	
	# if preset still isn't saved, add it
	var presets_structs: Dictionary[String, DataPresetStruct] = get_node_presets_structs(node)
	if not presets_structs.has(database_type):
		var new_struct: DataPresetStruct = DataPresetStruct.new()
		presets_structs.get_or_add(database_type, new_struct.setup(preset))
		node.set_meta(DataPresetsConstants.META_PRESETS_KEY, presets_structs)
		return true
	
	# if saved with different name, update it
	var preset_struct: DataPresetStruct = presets_structs[database_type]
	if preset_struct == null or preset_struct.id != preset.id or preset_struct.name != preset.name:
		var new_struct: DataPresetStruct = DataPresetStruct.new()
		presets_structs[database_type] = new_struct.setup(preset)
		node.set_meta(DataPresetsConstants.META_PRESETS_KEY, presets_structs)
		return true
	
	return false


#endregion


#region apply


## Applies the presets already stored on a node
static func apply_node_preset(node: Object) -> bool:	
	# get all presets
	var presets: Dictionary[String, BaseDataPreset] = get_node_presets(node)

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