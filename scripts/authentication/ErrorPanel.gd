extends PanelContainer

@onready var message = $CC/VBC/Message
@onready var retry = $CC/VBC/HBC/Retry

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_message(msg: String, is_retryable: bool = true):
	message.text = msg
	
	if not is_retryable:
		retry.hide()


func _on_retry_pressed():
	hide()


func _on_quit_pressed():
	get_tree().quit()
