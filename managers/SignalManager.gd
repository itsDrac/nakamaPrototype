extends Node

signal online_setup_done

signal player_match_joined

signal player_live_updated(live: int, is_server: bool)

signal player_dead(is_server: bool)

signal despawn_ball
