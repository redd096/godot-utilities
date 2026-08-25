@tool
class_name ThemeVariationPreset 
extends BaseDataPreset
## Single preset to add in database resource

## Override control theme. If null, keep default project theme. [br]
## See [member Control.theme]
@export var theme: Theme:
    set(new_value):
        if theme != new_value:
            theme = new_value
            emit_changed()

## Override theme type. If null, use default values in theme. [br]
## See [member Control.theme_type_variation]
@export var theme_type_variation: String:
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
