extends CharacterBody2D

const BALL_INST: PackedScene = preload("res://scenes/Ball.tscn")
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var is_server = true
#var enemy_num := 2
var lives := 5
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_throw := true
var in_knockback := false
#var spawnpoints := [Vector2(256, 384), Vector2(896, 384)]
var anim : String:
	set(new_anim):
		anim = new_anim 
		rpc("play_anim", new_anim)
var currentAnimation = "idle"

@onready var multiplayer_spawner = $MultiplayerSpawner


#
#func _enter_tree() -> void:
	#set_multiplayer_authority(name.to_int())

func _ready() -> void:
	multiplayer_spawner.spawn_function=shoot
	#SM.despawn_ball.connect(multiplayer_spawner.clear_spawnable_scenes)
	if name.to_int() != 1:
		$Sprite.flip_h = true
		is_server = false
		#get_parent().start_timer.rpc()
		#enemy_num -= 1
	#if !is_multiplayer_authority(): return
	
	#position = spawnpoints[sign(name.to_int() - 1)]
	#print(name, " - ", spawnpoints[sign(name.to_int() - 1)])

func _physics_process(delta: float) -> void:
	#update_remote_position.rpc(position, rotation)
	if !is_multiplayer_authority(): return
	if !is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") && can_throw:
		multiplayer_spawner.spawn(name)
		$ReloadTimer.start()
		can_throw = false
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("ui_left", "ui_right") if !in_knockback else 0.0
	if direction:
		velocity.x = direction * SPEED
		currentAnimation = "run"
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		currentAnimation = "idle"
	
	$Sprite.set_animation(currentAnimation)
	move_and_slide()
	rpc("update_remote_player", global_position, currentAnimation)

@rpc("unreliable")
func update_remote_player(newPosition, newCurrentAnimation):
	global_position = newPosition
	$Sprite.set_animation(newCurrentAnimation)
	#rotation = newRotation


func shoot(shooter) -> Area2D:
	var ball := BALL_INST.instantiate()
	if shooter.to_int() == 1:
		ball.position = $BulletSpwanP1.position
		ball.dir *= 1
	else:
		ball.position = $BulletSpwanP2.position
		ball.dir *= -1
	ball.shooter_id = shooter
	return ball

@rpc("any_peer")
func play_anim(new_anim : String) -> void:
	$Sprite.set_animation(new_anim)

func apply_knockback() -> void:
	if in_knockback: return
	in_knockback = true
	velocity.x = -1500 if (name.to_int() == 1) else 1500
	await get_tree().create_timer(0.3).timeout
	in_knockback = false

func _on_reload_timer_timeout() -> void:
	can_throw = true


func respawn():
	if !is_multiplayer_authority(): return
	await get_tree().create_timer(.3).timeout
	var level = get_parent()
	var spwanPos: Vector2
	if is_server:
		spwanPos = level.get_node("SpawnPlayer1").global_position
	else:
		spwanPos = level.get_node("SpawnPlayer2").global_position
	global_position = spwanPos
	update_remote_player.rpc(global_position, "idle")

func _on_screen_visible_screen_exited():
	lives -= 1
	SM.player_live_updated.emit(lives, is_server)
	if lives == 0:
		SM.player_dead.emit(is_server)
		queue_free()
		return
	respawn()
