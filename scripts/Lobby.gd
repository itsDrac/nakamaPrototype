extends Control

@onready var matchName = $MC/VBC/MatchName
@export var gameScene: PackedScene

var multiplayer_bridge
# Called when the node enters the scene tree for the first time.
func _ready(): 
	SM.online_setup_done.connect(make_multiplayer_bridge)
	

func make_multiplayer_bridge():
	multiplayer_bridge = NakamaMultiplayerBridge.new(GM.socket)
	multiplayer_bridge.match_joined.connect(_on_match_joined)
	get_tree().get_multiplayer().set_multiplayer_peer(multiplayer_bridge.multiplayer_peer)
	#get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)
	GM.multiplayerBridge = multiplayer_bridge
	GM.socket.received_match_presence.connect(_on_match_presence)

func _on_match_joined():
	get_tree().change_scene_to_packed(gameScene)
	

func _on_join_button_pressed():
	var matchNameText: String = matchName.text
	await multiplayer_bridge.join_named_match(matchNameText)
	print("-----------------------------------")
	print_debug(GM.multiplayerBridge.match_id)
	print("-----------------------------------")


## This Method isn't getting called 
func _on_match_presence(p_presence: NakamaRTAPI.MatchPresenceEvent):
	for p in p_presence.joins:
		print(p)
	pass
