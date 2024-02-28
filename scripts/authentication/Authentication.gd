extends CenterContainer

var session : NakamaSession
@onready var loginEmail = $TabContainer/Login/MC/VBC/Email
@onready var loginUsername = $TabContainer/Login/MC/VBC/Username
@onready var loginPassword = $TabContainer/Login/MC/VBC/Password
@onready var registerEmail = $TabContainer/Register/MC/VBC/Email
@onready var registerUsername = $TabContainer/Register/MC/VBC/Username
@onready var registerPassword = $TabContainer/Register/MC/VBC/Password
@onready var confirmPassword = $TabContainer/Register/MC/VBC/ConfirmPassword
@onready var errorPanel = $ErrorPanel


# Called when the node enters the scene tree for the first time.
func _ready():
	errorPanel.hide()
	SM.UserAuthenticated.connect(make_socket)

func _on_login_button_pressed():
	var username: String = loginUsername.text.strip_edges().strip_escapes()
	var email: String = loginEmail.text.strip_edges().strip_escapes()
	if (email.is_empty() or 
	username.is_empty() or 
	loginPassword.text.is_empty()):
		errorPanel.show()
		errorPanel.set_message("Username or password not provided")
		return
	var password = str(hash(loginPassword.text))
	session = await GM.client.authenticate_email_async(email, password, username, false)
	if session.is_exception():
		errorPanel.show()
		errorPanel.set_message("An error occurred: %s" % session, false)
		return
	
	GM.session = session
	SM.UserAuthenticated.emit()
	

func _on_register_button_pressed():
	var username: String = registerUsername.text.strip_edges().strip_escapes()
	var email: String = registerEmail.text.strip_edges().strip_escapes()
	if (email.is_empty() or 
	username.is_empty() or 
	registerPassword.text.is_empty()):
		errorPanel.show()
		errorPanel.set_message("Username or password not provided")
		return
	var password = str(hash(registerPassword.text))
	session = await GM.client.authenticate_email_async(email, password, username, true)
	if session.is_exception():
		errorPanel.show()
		errorPanel.set_message("An error occurred: %s" % session, false)
		return
	
	GM.session = session
	SM.UserAuthenticated.emit()
	

func make_socket():
	var socket = Nakama.create_socket_from(GM.client)
	var connected : NakamaAsyncResult = await socket.connect_async(GM.session)
	if connected.is_exception():
		errorPanel.show()
		print("An error occurred: %s" % connected)
		errorPanel.set_message("An error occurred: %s" % connected, false)
		return
	GM.socket = socket
	

func match_making():
	var matchmaker_ticket : NakamaRTAPI.MatchmakerTicket = await GM.socket.add_matchmaker_async()
	

func _on_matchmaker_matched(p_matched : NakamaRTAPI.MatchmakerMatched):
	print_debug("Here")
	#var joined_match : NakamaRTAPI.Match = await GM.socket.join_match_async(p_matched)
