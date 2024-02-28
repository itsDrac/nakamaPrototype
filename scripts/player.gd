extends CharacterBody2D

#const BALL_INST = preload("res://Scenes/ball.tscn")
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var enemy_num := 2
var lives := 5
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_throw := true
var in_knockback := false
var spawnpoints := [Vector2(256, 384), Vector2(896, 384)]
var anim : String:
	set(new_anim): play_anim.rpc(new_anim)

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if not get_tree().get_multiplayer().is_server():
		$Sprite.flip_h = true
	return
	if name.to_int() != 1:
		$Sprite.flip_h = true
		get_parent().start_timer.rpc()
		enemy_num -= 1
	if !is_multiplayer_authority(): return
	
	position = spawnpoints[sign(name.to_int() - 1)]
	print(name, " - ", spawnpoints[sign(name.to_int() - 1)])

func _physics_process(delta: float) -> void:
	update_remote_position.rpc(position, rotation)
	if !is_multiplayer_authority(): return
	
	if !is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_pressed("ui_accept") && can_throw == true:
		shoot.rpc()
		$ReloadTimer.start()
		can_throw = false
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("ui_left", "ui_right") if !in_knockback else 0.0
	if direction:
		velocity.x = direction * SPEED
		anim = "run"
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		anim = "idle"
	
	move_and_slide()
	update_remote_position.rpc(position)

@rpc("any_peer")
func update_remote_position(newPosition, newRotation):
	position = newPosition
	#rotation = newRotation

@rpc("call_local")
func shoot() -> void:
	pass
	#var ball := BALL_INST.instantiate()
	#ball.position = position
	#ball.shooter_id = name
	#ball.dir *= 1 if (name.to_int() == 1) else -1
	#get_parent().add_child(ball)

@rpc("call_local")
func play_anim(new_anim : String) -> void:
	$Sprite.set_animation(new_anim)

func apply_knockback() -> void:
	in_knockback = true
	velocity.x = -2000 if (name.to_int() == 1) else 2000
	await get_tree().create_timer(0.2).timeout
	in_knockback = false

func _on_reload_timer_timeout() -> void:
	can_throw = true

func respawn() -> void:
	lives -= 1
	get_parent().change_score.rpc(name.to_int(), lives, enemy_num)
	position = spawnpoints[sign(name.to_int() - 1)]
