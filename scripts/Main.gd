extends Node

@export var gameScene: PackedScene

func _ready():
	GM.client = make_client()
	GM.session = await make_session(GM.client)
	GM.socket = await make_socket(GM.client, GM.session)
	SM.online_setup_done.emit()

func make_client() -> NakamaClient:
	var client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
	client.timeout = 10
	return client
	

func make_session(client) -> NakamaSession:
	var randId = var_to_str(randi_range(100000,999999))
	var device_id = randId
	var session : NakamaSession = await client.authenticate_custom_async(device_id)
	if session.is_exception():
		print_debug("An error occurred is session: %s" % session)
		return
	return session
	

func make_socket(client, session) -> NakamaSocket:
	var socket = Nakama.create_socket_from(client)
	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print_debug("An error occurred in socket: %s" % connected)
		return
	return socket
	

func add_game():
	get_tree().change_scene_to_packed(gameScene)

