extends Area2D

var dir := 8
var shooter_id := ""
var can_move: bool = false


func _physics_process(_delta: float) -> void:
	if can_move:
		position.x += dir

func _on_body_entered(body: Node2D) -> void:
	if (body.name != shooter_id):
		body.apply_knockback()
		hide()


func _on_screen_visible_screen_exited():
	queue_free()


func _on_tree_entered():
	can_move = true
