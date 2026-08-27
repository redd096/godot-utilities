class_name DataPresetsConstants 
extends RefCounted


## Autoload script name
const AUTOLOAD_NAME: String = "DataPresetsRuntime"

## Path to autoload script (autoload can't have class_name)
static var AUTOLOAD_PATH: String: 
	get: return (DataPresetsConstants as Script).resource_path.get_base_dir().path_join("data_presets_runtime.gd")


## Dictionary[StringName, BaseDataPresetsDatabase]
## key: Database type, value: reference to database resource of that type
const META_DATABASES_REF_KEY: StringName = &"data_preset_databases"

## Dictionary[StringName, int]
## key: Database type, value: stable preset ID
const META_PRESET_IDS_KEY: StringName = &"data_preset_ids"

## Dictionary[StringName, String]
## key: Database type, value: preset name used as a fallback
const META_PRESET_NAMES_KEY: StringName = &"data_preset_names"
