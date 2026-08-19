@tool
class_name CollisionPresetsConstants 
extends RefCounted


const AUTOLOAD_NAME: String = "CollisionPresetRuntime"


## Database Resource stored in node's meta
const META_DATABASE_KEY: StringName = &"collision_preset_database"
## Preset ID stored in node's meta
const META_ID_KEY: StringName = &"collision_preset_id"
## Preset name stored in node's meta. The ID remains the authoritative reference.
const META_NAME_KEY: StringName = &"collision_preset_name"


## Variable to set in node
const PROP_COLLISION_LAYER: StringName = &"collision_layer"
## Variable to set in node
const PROP_COLLISION_MASK: StringName = &"collision_mask"


static var AUTOLOAD_PATH: String:
	get:
		return _get_base_dir().path_join("collision_presets_runtime.gd")


static var INSPECTOR_SCRIPT_PATH: String:
	get:
		return _get_base_dir().path_join("collision_presets_inspector.gd")


static func _get_base_dir() -> String:
	return (CollisionPresetsConstants as Script).resource_path.get_base_dir()
