@tool
class_name CollisionPresetsAPI 
extends RefCounted
## Shared API used by both the editor UI and the runtime autoload


## Returns the preset by ID from this database
static func get_preset_by_id(database: CollisionPresetsDatabase, id: String) -> CollisionPreset:
	if database == null or id.is_empty():
		return null

	# find in array by id
	for preset: CollisionPreset in database.presets:
		if preset != null and preset.id == id:
			return preset

	return null


## Returns the first preset with the given name from this database
static func get_preset_by_name(database: CollisionPresetsDatabase, preset_name: String) -> CollisionPreset:
	if database == null or preset_name.is_empty():
		return null

	# find in array by name
	for preset: CollisionPreset in database.presets:
		if preset != null and preset.name == preset_name:
			return preset

	return null


## Returns the database referenced by a collision node
static func get_node_database(node: Node) -> CollisionPresetsDatabase:
	if node == null or not node.has_meta(CollisionPresetsConstants.META_DATABASE_KEY):
		return null

	# get resource meta
	return node.get_meta(CollisionPresetsConstants.META_DATABASE_KEY) as CollisionPresetsDatabase


## Returns the preset referenced by a collision node
static func get_node_preset(node: Node) -> CollisionPreset:
	# get database
	var database: CollisionPresetsDatabase = get_node_database(node)
	if database == null:
		return null

	# get preset by id
	if node.has_meta(CollisionPresetsConstants.META_ID_KEY):
		var preset_id: String = str(node.get_meta(CollisionPresetsConstants.META_ID_KEY))
		var preset: CollisionPreset = get_preset_by_id(database, preset_id)
		if preset != null:
			return preset

	# else, try find by name
	if node.has_meta(CollisionPresetsConstants.META_NAME_KEY):
		return get_preset_by_name(
			database,
			str(node.get_meta(CollisionPresetsConstants.META_NAME_KEY))
		)

	return null


static func set_node_database(node: Node, database: CollisionPresetsDatabase) -> bool:
	if node == null or database == null:
		return false

	# save in node's meta
	node.set_meta(CollisionPresetsConstants.META_DATABASE_KEY, database)

	return true

## Save database and preset in node's meta. Then apply its values [br]
## Return true if everything works
static func set_node_preset(node: Node, database: CollisionPresetsDatabase, preset: CollisionPreset) -> bool:
	if node == null or database == null or preset == null:
		return false

	# save in node's meta
	node.set_meta(CollisionPresetsConstants.META_DATABASE_KEY, database)
	node.set_meta(CollisionPresetsConstants.META_ID_KEY, preset.id)
	# node.set_meta(CollisionPresetsConstants.META_NAME_KEY, preset.name) # already set by apply_preset_values()

	# and apply in scene
	return apply_preset_values(node, preset)


## Applies the selected preset already stored on a node
static func apply_node_preset(node: Node) -> bool:
	# get preset
	var preset: CollisionPreset = get_node_preset(node)
	if preset == null:
		return false

	return apply_preset_values(node, preset)


## Applies layer and mask values [br]
## Return true if apply at least one value
static func apply_preset_values(node: Node, preset: CollisionPreset) -> bool:
	if node == null or preset == null:
		return false
		
	# If the name was changed, the preset is found by id and save updated name
	node.set_meta(CollisionPresetsConstants.META_NAME_KEY, preset.name)

	var applied := false

	# apply layer
	if CollisionPresetsConstants.PROP_COLLISION_LAYER in node:
		node.collision_layer = preset.layer
		applied = true
	# and mask
	if CollisionPresetsConstants.PROP_COLLISION_MASK in node:
		node.collision_mask = preset.mask
		applied = true

	return applied


## Removes the plugin's database/preset reference from a node. [br]
## Existing collision layer/mask values are left unchanged
static func clear_node_preset_and_database(node: Node) -> void:
	if node == null:
		return

	# remove database meta from node
	for key: StringName in [CollisionPresetsConstants.META_DATABASE_KEY]:
		if node.has_meta(key):
			node.remove_meta(key)
	# and presets meta
	clear_node_preset(node)


## Removes the plugin's database/preset reference from a node. [br]
## Existing collision layer/mask values are left unchanged
static func clear_node_preset(node: Node) -> void:
	if node == null:
		return

	# remove preset meta from node
	for key: StringName in [CollisionPresetsConstants.META_ID_KEY, CollisionPresetsConstants.META_NAME_KEY]:
		if node.has_meta(key):
			node.remove_meta(key)
