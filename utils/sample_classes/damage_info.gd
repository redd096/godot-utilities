class_name DamageInfo extends RefCounted

# Input

## e.g. hitted enemy
var target: Node
## e.g. player that attacked
var source: Node
## e.g. rifle
var source_weapon: Node

## damage amount
var amount: int
## weapon knockback force
var knockback_force: float

## raycast hit point
var hit_position: Vector3
## raycast hit normal
var hit_normal: Vector3
## raycast direction (e.g. player direction)
var hit_direction: Vector3

## raycast result
## [codeblock lang=gdscript]
## position: Vector2 # point in world space for collision
## normal: Vector2 # normal in world space for collision
## collider: Object # Object collided or null (if unassociated)
## collider_id: ObjectID # Object it collided against
## rid: RID # RID it collided against
## shape: int # shape index of collider
## metadata: Variant() # metadata of collider
## [/codeblock]
var hit_info: Dictionary = {}


# Output

## could be false if target is not damageable object or already dead
var was_applied: bool
## e.g. amount was 10 but enemy had 5 armor, so result is 5
var result_damage: int
## is the target dead after this attack? This is false if the target was already dead
var is_target_dead: bool