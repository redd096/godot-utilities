class_name ControlThemeModelData extends Resource

## Name for this Data
@export var name: StringName = "Data"
## Used to help with editor, e.g. to know where this Data is used
@export_multiline var description: String
## Override control theme. If null, keep default project theme
@export var theme: Theme
## Override theme type
@export var theme_type_variation: String