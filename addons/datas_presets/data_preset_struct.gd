@tool
class_name DataPresetStruct
extends RefCounted
## Struct that contains Preset id and Preset name

var id: String
var name: String

func setup(preset: BaseDataPreset) -> DataPresetStruct:
    id = preset.id
    name = preset.name
    return self