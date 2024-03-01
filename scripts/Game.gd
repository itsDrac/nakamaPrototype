extends Node2D

@onready var scorePlayer_1 = $CanvasLayer/VBC/MC/HBC/ScorePlayer1
@onready var scorePlayer_2 = $CanvasLayer/VBC/MC/HBC/ScorePlayer2
@onready var result = $CanvasLayer/VBC/MC/HBC/Result


# Called when the node enters the scene tree for the first time.
func _ready():
	SM.player_live_updated.connect(
		func(live, is_server): 
			rpc("update_live_label", live, is_server)
			)
	SM.player_dead.connect(
		func(is_server): 
			rpc("show_result", is_server)
	)
	#get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)

@rpc("any_peer")
func update_live_label(live: int, is_server):
	if is_server:
		scorePlayer_1.text = "%s lives" %live
	else:
		scorePlayer_2.text = "%s lives" %live

@rpc("any_peer")
func show_result(is_server):
	var winner = "2" if is_server else "1"
	$CanvasLayer/VBC/MC/HBC/VS.hide()
	result.text = result.text % winner
	result.show()
	return
