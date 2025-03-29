class_name PlayerController extends Node

@export var set_dont_destroy_on_load : bool = true
var current_pawn : PlayerPawn

func _ready() -> void:
	#set don't destroy on load if setted
	if set_dont_destroy_on_load:
		dont_destroy_on_load(self)

##possess pawn - if already possessing a pawn, it will be unpossessed
func possess(player_pawn : PlayerPawn):
	#if this controller has already a pawn, unpossess it
	unpossess()
	if player_pawn:
		#if the new pawn for some reason has already a controller, call unpossess on it
		player_pawn.unpossess()
		#then set pawn and controller
		current_pawn = player_pawn
		current_pawn.current_controller = self
		current_pawn.on_possess(self)

##unpossess current pawn
func unpossess():
	if current_pawn:
		#remove pawn and controller
		current_pawn.current_controller = null
		current_pawn.on_unpossess(self)
		current_pawn = null

## Equivalent of unity DontDestroyOnLoad(GameObject)
static func dont_destroy_on_load(node : Node) -> void:
	#check if this is already child of root node
	var parent : Node = node.get_parent()
	var root : Node = Engine.get_main_loop().root
	if parent and parent == root:
		return
	#else remove from current parent
	if parent:
		parent.remove_child.call_deferred(node)
	#and set child of root node (this isn't destroyed when change scene)
	root.add_child.call_deferred(node)
