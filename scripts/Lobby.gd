extends Control

@onready var matchName = $MatchName
var multiplayer_bridge
# Called when the node enters the scene tree for the first time.
func _ready():
	SM.online_setup_done.connect(make_multiplayer_bridge)
	

func make_multiplayer_bridge():
	multiplayer_bridge = NakamaMultiplayerBridge.new(GM.socket)
	multiplayer_bridge.match_joined.connect(_on_match_joined)
	get_tree().get_multiplayer().set_multiplayer_peer(multiplayer_bridge.multiplayer_peer)
	get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)
	GM.multiplayerBridge = multiplayer_bridge

func _on_match_joined():
	print("---------------------------------------------------------")
	print_debug("Match Joined......")
	print_debug(get_tree().get_multiplayer().is_server())
	SM.player_match_joined.emit()
	print("---------------------------------------------------------")
	

func _on_peer_connected(pear_id):
	print("---------------------------------------------------------")
	print_debug("pear id -> ", pear_id)
	print("---------------------------------------------------------")
	


func _on_join_button_pressed():
	print("---------------------------------------------------------")
	var matchNameText: String = matchName.text
	multiplayer_bridge.join_named_match(matchNameText)
	print("---------------------------------------------------------")
