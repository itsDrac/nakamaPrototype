extends Node2D

@onready var scorePlayer_1 = $CanvasLayer/VBC/MC/HBC/ScorePlayer1
@onready var scorePlayer_2 = $CanvasLayer/VBC/MC/HBC/ScorePlayer2
@onready var result = $CanvasLayer/VBC/MC/HBC/Result
@onready var timer = $Timer


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
	get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)

func _process(_delta):
	var timeLeft = timer.time_left
	update_timer.rpc(timeLeft)

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
	

func _on_peer_connected(peerId):
	start_timer.rpc()
	
@rpc("call_local")
func start_timer():
	timer.start()

@rpc("any_peer")
func update_timer(timeLeft: float):
	var mins = int(timeLeft/60)
	var secs = timeLeft
	$CanvasLayer/VBC/TimerLabel.text = "%s:%.0f"%[int(timeLeft/60), fmod(timeLeft, 60)]
