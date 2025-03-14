class_name PlayerController extends Node

var current_pawn : PlayerPawn

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
