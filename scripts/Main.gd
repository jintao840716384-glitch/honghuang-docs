extends Control

const MainMenuScene = preload("res://scenes/main/MainMenuScene.tscn")
const JobSelectScene = preload("res://scenes/main/JobSelectScene.tscn")
const CharacterPrepScene = preload("res://scenes/main/CharacterPrepScene.tscn")
const MapScene = preload("res://scenes/map/MapScene.tscn")
const BattleScene = preload("res://scenes/battle/BattleScene.tscn")
const RunSettlementScene = preload("res://scenes/main/RunSettlementScene.tscn")
const RunStateScript = preload("res://scripts/run/RunState.gd")
const InputSettingsScript = preload("res://scripts/settings/InputSettings.gd")
const DisplayModeManagerScript = preload("res://scripts/settings/DisplayModeManager.gd")
const MusicManagerScript = preload("res://scripts/audio/MusicManager.gd")
const SettingsStoreScript = preload("res://scripts/settings/SettingsStore.gd")
const GameSettingsScript = preload("res://scripts/settings/GameSettings.gd")
const DataValidatorScript = preload("res://scripts/data/DataValidator.gd")

var current_scene: Node
var music_manager: Node
var run_state
var active_node_id := ""

func _ready() -> void:
	var validation: Dictionary = DataValidatorScript.assert_valid_for_startup()
	if not bool(validation.get("valid", false)):
		push_error("Active data validation failed: %s" % "; ".join(validation.get("errors", [])))
		get_tree().quit(1)
		return
	var settings: Dictionary = SettingsStoreScript.load_settings()
	InputSettingsScript.apply_bindings(InputSettingsScript.settings_bindings(settings))
	DisplayModeManagerScript.apply_display_settings(settings)
	music_manager = MusicManagerScript.new()
	add_child(music_manager)
	_apply_music_settings(settings)
	show_main_menu()

func show_main_menu() -> void:
	_play_music("music.main_menu")
	_clear_current_scene()
	run_state = null
	active_node_id = ""
	current_scene = MainMenuScene.instantiate()
	add_child(current_scene)
	current_scene.start_requested.connect(show_job_select)
	current_scene.quit_requested.connect(_on_quit_requested)
	if current_scene.has_signal("settings_changed"):
		current_scene.settings_changed.connect(_on_settings_changed)

func show_job_select() -> void:
	_play_music("music.main_menu")
	_clear_current_scene()
	current_scene = JobSelectScene.instantiate()
	add_child(current_scene)
	current_scene.job_selected.connect(_on_job_selected)
	if current_scene.has_signal("back_requested"):
		current_scene.back_requested.connect(show_main_menu)

func show_map() -> void:
	_play_music("music.main_menu")
	_clear_current_scene()
	current_scene = MapScene.instantiate()
	add_child(current_scene)
	current_scene.setup(run_state)
	current_scene.battle_node_selected.connect(_on_map_node_selected)

func show_character_prep(job_id: String) -> void:
	_clear_current_scene()
	run_state = null
	active_node_id = ""
	current_scene = CharacterPrepScene.instantiate()
	add_child(current_scene)
	current_scene.setup(job_id)
	current_scene.start_requested.connect(_on_prep_start_requested)
	current_scene.back_requested.connect(show_job_select)

func show_run_settlement(settlement: Dictionary) -> void:
	if run_state == null:
		show_main_menu()
		return
	_clear_current_scene()
	current_scene = RunSettlementScene.instantiate()
	add_child(current_scene)
	current_scene.setup(run_state, settlement)
	current_scene.return_requested.connect(_on_settlement_return_requested)
	current_scene.retry_requested.connect(_on_settlement_retry_requested)

func _on_job_selected(job_id: String) -> void:
	show_character_prep(job_id)

func _on_prep_start_requested(job_id: String, _deck_ids: Array = [], _reserve_ids: Array = []) -> void:
	run_state = RunStateScript.new()
	run_state.start(job_id)
	show_map()

func _on_map_node_selected(node_data: Dictionary) -> void:
	if run_state == null:
		return
	var payload: Dictionary = run_state.battle_start_payload(str(node_data.get("id", "")))
	if not bool(payload.get("success", false)):
		var message: String = str(payload.get("message", ""))
		if message != "":
			run_state.status_message = message
		if current_scene != null and current_scene.has_method("setup"):
			current_scene.setup(run_state)
		return
	active_node_id = str(payload.get("node_id", ""))
	_play_music("music.battle")
	_clear_current_scene()
	current_scene = BattleScene.instantiate()
	add_child(current_scene)
	current_scene.map_battle_completed.connect(_on_map_battle_completed)
	current_scene.run_abandoned.connect(_on_run_abandoned)
	current_scene.setup_run_battle(
		str(payload.get("job_id", "")),
		(payload.get("deck_ids", []) as Array),
		int(payload.get("battle_number", 1)),
		str(payload.get("encounter_type", "normal")),
		(payload.get("run_context", {}) as Dictionary),
		int(payload.get("spirit_reward", 0))
	)

func _on_map_battle_completed(deck_ids: Array, reserve_ids: Array, player_hp: int, player_max_hp: int) -> void:
	if run_state == null:
		show_main_menu()
		return
	var result: Dictionary = run_state.apply_battle_completion(active_node_id, deck_ids, reserve_ids, player_hp, player_max_hp)
	if not bool(result.get("success", false)):
		run_state.status_message = str(result.get("message", "战斗回流失败。"))
		active_node_id = ""
		show_map()
		return
	if str(result.get("flow", "map")) == "settlement":
		var settlement: Dictionary = (result.get("settlement", {}) as Dictionary)
		active_node_id = ""
		show_run_settlement(settlement)
		return
	active_node_id = ""
	show_map()

func _on_run_abandoned() -> void:
	if run_state != null:
		var settlement: Dictionary = run_state.abandon_run()
		active_node_id = ""
		show_run_settlement(settlement)
	else:
		show_main_menu()

func _on_settlement_return_requested() -> void:
	var job_id := ""
	if run_state != null:
		job_id = run_state.job_id
	run_state = null
	active_node_id = ""
	if job_id != "":
		show_character_prep(job_id)
	else:
		show_job_select()

func _on_settlement_retry_requested() -> void:
	var job_id := "sword"
	if run_state != null and run_state.job_id != "":
		job_id = run_state.job_id
	active_node_id = ""
	run_state = RunStateScript.new()
	run_state.start(job_id)
	show_map()

func _on_quit_requested() -> void:
	get_tree().quit()

func _on_settings_changed(settings: Dictionary) -> void:
	InputSettingsScript.apply_bindings(InputSettingsScript.settings_bindings(settings))
	DisplayModeManagerScript.apply_display_settings(settings)
	_apply_music_settings(settings)

func _apply_music_settings(settings: Dictionary) -> void:
	if music_manager == null:
		return
	var audio: Dictionary = GameSettingsScript.audio_settings(settings)
	music_manager.set_music_volume(float(audio.get("music_volume", GameSettingsScript.DEFAULT_MUSIC_VOLUME)))

func _play_music(event_id: String) -> void:
	if music_manager != null:
		music_manager.play_music(event_id)

func _clear_current_scene() -> void:
	if current_scene != null:
		remove_child(current_scene)
		current_scene.queue_free()
		current_scene = null
