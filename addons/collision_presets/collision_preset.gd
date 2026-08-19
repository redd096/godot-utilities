@tool
class_name CollisionPreset 
extends Resource
## A reusable collision layer/mask preset for CollisionObject3D, CSGShape and CollisionObject2D

## Preset name shown in the CollisionObject inspector
@export var name: String = ""

## Stable internal identifier. Hidden from the normal inspector, 
## so renaming a preset does not break nodes that already reference it
@export_storage var id: String = ""

## Optional note about what the preset is for or where it is used
@export_multiline var description: String = ""

## Collision layer
@export_flags_3d_physics var layer: int = 1

## Collision mask
@export_flags_3d_physics var mask: int = 1
