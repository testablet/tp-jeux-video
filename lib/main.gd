extends Node3D

@onready var menu:CanvasLayer = $Menu

var save:SaveManager = SaveManager.new()
var current_level_change = null

func _ready():
	GameState.player = $Player
	save.load_game()
	_enter_level("default", GameState.current_level_key, GameState.player.position == Vector3.ZERO)
	menu.visible = false

func _input(_event):
	if (not get_tree().paused):
		if Input.is_action_just_pressed("player_interact"):
			if (current_level_change != null):
				_enter_level(GameState.current_level.key, current_level_change.destination)
	if Input.is_action_just_released("menu"):
		_pause()

func _pause():
	menu.visible = not menu.visible
	if get_tree().paused:
		GameState.player.capture_mouse()
	else:
		GameState.player.release_mouse()
	get_tree().paused = not get_tree().paused

func _enter_level(from:String, to:String, use_spawn_point:bool = true):
	if (GameState.current_level != null): 
		GameState.current_level.call_deferred("queue_free")
	GameState.current_level = load("res://levels/" + to + ".tscn").instantiate()
	GameState.current_level_key = to
	add_child(GameState.current_level)
	GameState.current_level.process_mode  = PROCESS_MODE_PAUSABLE
	if (use_spawn_point):
		for spawnpoint:SpawnPoint in GameState.current_level.find_children("", "SpawnPoint"):
			if (spawnpoint.key == from):
				GameState.player.position = spawnpoint.position
				GameState.player.rotation = spawnpoint.rotation

func _on_player_interaction_detected_end(_node):
	current_level_change = null
	
func _on_button_start_pressed():
	get_tree().paused = not get_tree().paused
	menu.visible = not menu.visible
	GameState.player.capture_mouse()

func _on_button_settings_pressed():
	# TODO : settings
	pass
	
func _on_button_save_pressed():
	save.save_game()

func _on_button_save_and_quit_pressed():
	save.save_game()
	get_tree().quit()
