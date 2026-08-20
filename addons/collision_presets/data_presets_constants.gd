class_name DataPresetsConstants 
extends RefCounted


## Autoload script name
const AUTOLOAD_NAME: String = "DataPresetsRuntime"

## Path to autoload script (autoload can't have class_name)
static var AUTOLOAD_PATH: String: 
	get: return (DataPresetsConstants as Script).resource_path.get_base_dir().path_join("data_presets_runtime.gd")


## Database Resource stored in node's meta
const META_DATABASE_REF_KEY: StringName = &"data_preset_database"
## Preset ID stored in node's meta
const META_PRESET_ID_KEY: StringName = &"data_preset_id"
## Preset name stored in node's meta. The ID remains the authoritative reference.
const META_PRESET_NAME_KEY: StringName = &"data_preset_name"
