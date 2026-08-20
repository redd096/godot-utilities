class_name DataPresetsAPI 
extends RefCounted
## Shared API used by both the editor UI and the runtime autoload


## Applies values from preset. [br]
## Return true if apply at least one value
static func apply_preset_values(node: Object, preset: Collision3DPreset) -> bool:
	if node == null or preset == null:
		return false
		
	# If the name was changed, the preset is found by id, so save updated name
	node.set_meta(DataPresetsConstants.META_PRESET_NAME_KEY, preset.name)

	var applied := false

	# apply values in scene
	if DataPresetsConstants.COLLISION_2D_PROP_LAYER in node:
		node.collision_layer = preset.layer
		applied = true

	if DataPresetsConstants.COLLISION_2D_PROP_MASK in node:
		node.collision_mask = preset.mask
		applied = true

	if DataPresetsConstants.COLLISION_3D_PROP_LAYER in node:
		node.collision_layer = preset.layer
		applied = true

	if DataPresetsConstants.COLLISION_3D_PROP_MASK in node:
		node.collision_mask = preset.mask
		applied = true

	return applied


#region get


## Returns the preset by ID from this database
static func get_preset_by_id(database: BaseDataPresetsDatabase, id: String) -> BaseDataPreset:
	if database == null or id.is_empty():
		return null

	# find in array by id
	for preset: BaseDataPreset in database.presets:
		if preset != null and preset.id == id:
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


## Returns the database referenced by a node
static func get_node_database(node: Object) -> BaseDataPresetsDatabase:
	if node == null or not node.has_meta(DataPresetsConstants.META_DATABASE_REF_KEY):
		return null

	# get database by meta
	return node.get_meta(DataPresetsConstants.META_DATABASE_REF_KEY) as BaseDataPresetsDatabase


## Returns the preset referenced by a node
static func get_node_preset(node: Object) -> BaseDataPreset:
	# get database
	var database: BaseDataPresetsDatabase = get_node_database(node)
	if database == null:
		return null

	# get preset by id
	if node.has_meta(DataPresetsConstants.META_PRESET_ID_KEY):
		var preset_id: String = str(node.get_meta(DataPresetsConstants.META_PRESET_ID_KEY))
		var preset: BaseDataPreset = get_preset_by_id(database, preset_id)
		if preset != null:
			return preset

	# else, try find by name
	if node.has_meta(DataPresetsConstants.META_PRESET_NAME_KEY):
		return get_preset_by_name(
			database,
			str(node.get_meta(DataPresetsConstants.META_PRESET_NAME_KEY))
		)

	return null


#endregion


#region clear


## Removes the plugin's database/preset reference from a node. [br]
## Changed node values are left unchanged (e.g. layer and mask with collision 3d preset)
static func clear_node_preset_and_database(node: Object) -> void:
	if node == null:
		return

	# remove database meta from node
	for key: StringName in [DataPresetsConstants.META_DATABASE_REF_KEY]:
		if node.has_meta(key):
			node.remove_meta(key)

	# and remove presets meta
	clear_node_preset(node)


## Removes the plugin's preset reference from a node. [br]
## Changed node values are left unchanged (e.g. layer and mask with collision 3d preset)
static func clear_node_preset(node: Object) -> void:
	if node == null:
		return

	# remove preset meta from node
	for key: StringName in [DataPresetsConstants.META_PRESET_ID_KEY, DataPresetsConstants.META_PRESET_NAME_KEY]:
		if node.has_meta(key):
			node.remove_meta(key)


#endregion


#region set


## Save database in node's meta. [br]
## Return true if both node and database are valids
static func set_node_database(node: Object, database: BaseDataPresetsDatabase) -> bool:
	if node == null or database == null:
		return false

	# save in node's meta
	node.set_meta(DataPresetsConstants.META_DATABASE_REF_KEY, database)

	return true

## Save database and preset in node's meta. Then apply its values. [br]
## Return true if everything works
static func set_node_preset(node: Object, database: BaseDataPresetsDatabase, preset: BaseDataPreset) -> bool:
	if node == null or database == null or preset == null:
		return false

	# save in node's meta
	node.set_meta(DataPresetsConstants.META_DATABASE_REF_KEY, database)
	node.set_meta(DataPresetsConstants.META_PRESET_ID_KEY, preset.id)
	# node.set_meta(DataPresetsConstants.META_NAME_KEY, preset.name) # already set by apply_preset_values()

	# and apply in scene
	return apply_preset_values(node, preset)


#endregion


## Applies the preset already stored on a node
static func apply_node_preset(node: Object) -> bool:
	# get preset in node
	var preset: BaseDataPreset = get_node_preset(node)
	if preset == null:
		return false

	# and apply in scene
	return apply_preset_values(node, preset)