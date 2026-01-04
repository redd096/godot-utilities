class_name PlayerController extends Node

@export var set_dont_destroy_on_load : bool = true
var current_pawn : PlayerPawn

func _ready() -> void:
	#set don't destroy on load if setted
	if set_dont_destroy_on_load:
		_dont_destroy_on_load(self)

## Possess pawn - if already possessing another pawn, it will be unpossessed
func possess(player_pawn : PlayerPawn):
	# if this controller has already a pawn, unpossess it
	unpossess()
	if player_pawn:
		# if the new pawn for some reason has already a controller, call unpossess on it
		player_pawn.unpossess()
		# then set pawn and controller
		current_pawn = player_pawn
		current_pawn.current_controller = self
		current_pawn.on_possess(self)

## Unpossess current pawn
func unpossess():
	if current_pawn:
		# remove pawn and controller
		current_pawn.current_controller = null
		current_pawn.on_unpossess(self)
		current_pawn = null

## Equivalent of unity DontDestroyOnLoad(GameObject)
static func _dont_destroy_on_load(node : Node) -> void:
	# set root as parent (this isn't destroyed when change scene)
	var root: Node = Engine.get_main_loop().root
	# check if this is already child of this parent
	var current_parent = node.get_parent()
	if current_parent and current_parent == root:
		return
	# else remove from current parent
	if current_parent:
		current_parent.remove_child.call_deferred(node)
	# and set child of new parent
	root.add_child.call_deferred(node)
