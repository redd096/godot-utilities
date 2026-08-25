@tool
class_name ThemeVariationPreset 
extends BaseDataPreset
## Single preset to add in database resource

## Override control theme. If null, use project theme. [br]
## See [member Control.theme]
@export var theme: Theme:
    set(new_value):
        if theme != new_value:
            theme = new_value
            notify_property_list_changed()
            emit_changed()

## Control type used to filter compatible [member theme type variations]. [br]
## The inspector selector includes every class derived from [Control]
@export_custom(PROPERTY_HINT_TYPE_STRING, "Control") var control_type: String:
    set(new_value):
        if control_type != new_value:
            control_type = new_value
            notify_property_list_changed()
            emit_changed()

## Override theme type. If empty, use default values in theme. [br]
## See [member Control.theme_type_variation]
@export var theme_type_variation: StringName = &"":
    set(new_value):
        if theme_type_variation != new_value:
            theme_type_variation = new_value
            emit_changed()


func apply_values(node: Object) -> bool:
    var applied: bool

    if  &"theme" in node:
        node.theme = theme
        applied = true

    if  &"theme_type_variation" in node:
        node.theme_type_variation = theme_type_variation
        applied = true

    return applied


#region custom properties inspector


func _validate_property(property: Dictionary) -> void:
    # property "theme_type_variation" show dropdown of every theme type in overrided theme, and project theme
    if property.name == &"theme_type_variation":
        property.hint = PROPERTY_HINT_ENUM_SUGGESTION
        property.hint_string = ",".join(_get_theme_type_variations())


func _get_theme_type_variations() -> PackedStringArray:
    var variations := PackedStringArray()

    _append_theme_type_variations(theme, variations)                        # overrided theme variations
    _append_theme_type_variations(ThemeDB.get_project_theme(), variations)  # custom project theme
    _append_theme_type_variations(ThemeDB.get_default_theme(), variations)  # default godot theme

    # and sort
    variations.sort()
    return variations


func _append_theme_type_variations(source_theme: Theme, variations: PackedStringArray) -> void:
    if source_theme == null:
        return
    
    # use control_type to filter, else show every variation for every Control
    var c_type: String = "Control" if control_type.is_empty() else control_type

    # add variations to array
    for variation in source_theme.get_type_variation_list(c_type):
        if not variations.has(variation):
            variations.append(variation)


#endregion
