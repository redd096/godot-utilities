class_name DataPresetsConstants 
extends RefCounted


const AUTOLOAD_NAME: String = "DataPresetsRuntime"

# base path to this plugin directory
static func _get_base_dir() -> String:
	return (DataPresetsConstants as Script).resource_path.get_base_dir()

## Path to autoload script
static var AUTOLOAD_PATH: String: 
	get: return _get_base_dir().path_join("data_presets_runtime.gd")


## Database Resource stored in node's meta
const META_DATABASE_REF_KEY: StringName = &"data_preset_database"
## Preset ID stored in node's meta
const META_PRESET_ID_KEY: StringName = &"data_preset_id"
## Preset name stored in node's meta. The ID remains the authoritative reference.
const META_PRESET_NAME_KEY: StringName = &"data_preset_name"


#region collision 2d

const COLLISION_2D_DATABASE_NAME: String = "Collision2DPresetsDatabase"

## Path to custom inspector
static var COLLISION_2D_INSPECTOR_PATH: String:
	get: return _get_base_dir().path_join("collision_2d").path_join("collision_2d_custom_inspector.gd")

## UI added by custom inspector
static var COLLISION_2D_UI_PATH: String:
	get: return _get_base_dir().path_join("collision_2d").path_join("collision_2d_ui.gd")

## Variable to set in node
const COLLISION_2D_PROP_LAYER: StringName = &"collision_layer"
## Variable to set in node
const COLLISION_2D_PROP_MASK: StringName = &"collision_mask"

#endregion


#region collision 3d

const COLLISION_3D_DATABASE_NAME: String = "Collision3DPresetsDatabase"

## Path to custom inspector
static var COLLISION_3D_INSPECTOR_PATH: String:
	get: return _get_base_dir().path_join("collision_3d").path_join("collision_3d_custom_inspector.gd")

## UI added by custom inspector
static var COLLISION_3D_UI_PATH: String:
	get: return _get_base_dir().path_join("collision_3d").path_join("collision_3d_ui.gd")

## Variable to set in node
const COLLISION_3D_PROP_LAYER: StringName = &"collision_layer"
## Variable to set in node
const COLLISION_3D_PROP_MASK: StringName = &"collision_mask"

#endregion