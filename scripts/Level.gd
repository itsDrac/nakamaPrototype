extends Node2D

@export var player: PackedScene
var connectedPeers: Array[int]

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)
	if get_tree().get_multiplayer().is_server():
		add_player(1)
	

func add_player(peerId):
	connectedPeers.append(peerId)
	var playerNode = player.instantiate()
	playerNode.global_position = $SpawnPlayer1.global_position if peerId == 1 else $SpawnPlayer2.global_position
	playerNode.name = str(peerId)
	playerNode.set_multiplayer_authority(peerId)
	add_child(playerNode)

@rpc
func add_new_player(peerId):
	add_player(peerId)

@rpc
func add_old_player(peerIds:Array):
	for peerId in peerIds:
		add_player(peerId)

func _on_peer_connected(peerId):
	rpc("add_new_player", peerId)
	rpc_id(peerId, "add_old_player", connectedPeers)
	add_player(peerId)
	
