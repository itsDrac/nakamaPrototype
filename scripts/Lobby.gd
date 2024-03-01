extends Control

@onready var matchName = $MatchName
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
	print("---------------------------------------------------------")
	print_debug("Is Server: ", get_tree().get_multiplayer().is_server())
	get_tree().change_scene_to_packed(gameScene)
	
	print("---------------------------------------------------------")
	

func _on_peer_connected(pear_id):
	print("---------------------------------------------------------")
	print_debug("pear id -> ", pear_id)
	#SM.player_match_joined.emit()
	#get_tree().change_scene_to_packed(gameScene)
	print("---------------------------------------------------------")
	


func _on_join_button_pressed():
	print("---------------------------------------------------------")
	var matchNameText: String = matchName.text
	var a = await multiplayer_bridge.join_named_match(matchNameText)
	print_debug(a)
	print("---------------------------------------------------------")


func _on_match_presence(p_presence: NakamaRTAPI.MatchPresenceEvent):
	print("---------------------------------------------------------")
	for p in p_presence.joins:
		print(p)
	pass
