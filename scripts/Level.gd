extends Node2D

@export var player: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	print("---------------------------------------------------------")
	print_debug(GM.multiplayerBridge.multiplayer_peer)
	print_debug(get_tree().get_multiplayer().is_server())
	print("---------------------------------------------------------")
	if get_tree().get_multiplayer().is_server():
		spawn_player1()
	else:
		spawn_player2()


func spawn_player1():
	var playerNode = player.instantiate()
	playerNode.global_position =$SpawnPlayer1.global_position
	add_child(playerNode)

func spawn_player2():
	var playerNode = player.instantiate()
	playerNode.global_position =$SpawnPlayer2.global_position
	
	add_child(playerNode)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
