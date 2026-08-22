@tool
class_name ThemeVariationPreset 
extends BaseDataPreset
## Single preset to add in database resource

## Override control theme. If null, keep default project theme
@export var theme: Theme
## Override theme type
@export var theme_type_variation: String


func apply_values(node: Object) -> bool:
    var applied: bool

    if  &"theme" in node:
        node.theme = theme
        applied = true

    if  &"theme_type_variation" in node:
        node.theme_type_variation = theme_type_variation
        applied = true

    return applied
