extends Area2D

var dir := 8
var shooter_id := ""

func _ready():
	print_debug("here")

func _physics_process(_delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	return
	if (body.name != shooter_id):
		#body.apply_knockback()
		print_debug("should hit player, now")
		queue_free()


func _on_screen_visible_screen_exited():
	queue_free()
