@tool
class_name CollisionPreset 
extends Resource
## Single preset for collisions

## Preset name shown in the inspector
@export var name: String = ""

## Unique identifier, so renaming a preset does not break nodes that already reference it
@export_storage var id: String = ""
#export_storage is like @export but hidden in inspector

## Optional note about what the preset is for or where it is used
@export_multiline var description: String = ""

## Collision layer
@export_flags_3d_physics var layer: int = 1

## Collision mask
@export_flags_3d_physics var mask: int = 1
