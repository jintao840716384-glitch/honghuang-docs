extends Control

const MainMenuScene = preload("res://scenes/MainMenuScene.tscn")
const JobSelectScene = preload("res://scenes/JobSelectScene.tscn")
const CharacterPrepScene = preload("res://scenes/CharacterPrepScene.tscn")
const MapScene = preload("res://scenes/MapScene.tscn")
const BattleScene = preload("res://scenes/BattleScene.tscn")
const RunSettlementScene = preload("res://scenes/RunSettlementScene.tscn")
const RunStateScript = preload("res://scripts/run/RunState.gd")

var current_scene: Node
var run_state
var active_node_id := ""

func _ready() -> void:
	show_main_menu()

func show_main_menu() -> void:
	_clear_current_scene()
	run_state = null
	active_node_id = ""
	current_scene = MainMenuScene.instantiate()
	add_child(current_scene)
	current_scene.start_requested.connect(show_job_select)
	current_scene.quit_requested.connect(_on_quit_requested)

func show_job_select() -> void:
	_clear_current_scene()
	current_scene = JobSelectScene.instantiate()
	add_child(current_scene)
	current_scene.job_selected.connect(_on_job_selected)
	if current_scene.has_signal("back_requested"):
		current_scene.back_requested.connect(show_main_menu)

func show_map() -> void:
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

func _on_prep_start_requested(job_id: String, deck_ids: Array = [], reserve_ids: Array = []) -> void:
	run_state = RunStateScript.new()
	run_state.start(job_id, deck_ids, reserve_ids)
	show_map()

func _on_map_node_selected(node_data: Dictionary) -> void:
	if run_state == null:
		return
	active_node_id = str(node_data.get("id", ""))
	if not run_state.is_node_available(active_node_id):
		return
	var block_reason: String = run_state.battle_start_block_reason()
	if block_reason != "":
		run_state.status_message = block_reason
		if current_scene != null and current_scene.has_method("setup"):
			current_scene.setup(run_state)
		return
	run_state.begin_node(active_node_id)
	_clear_current_scene()
	current_scene = BattleScene.instantiate()
	add_child(current_scene)
	current_scene.map_battle_completed.connect(_on_map_battle_completed)
	current_scene.run_abandoned.connect(_on_run_abandoned)
	current_scene.setup_run_battle(
		run_state.job_id,
		run_state.deck_ids,
		run_state.battle_number_for_node(node_data),
		str(node_data.get("type", "normal")),
		run_state.run_context(),
		run_state.battle_spirit_reward(node_data)
	)

func _on_map_battle_completed(deck_ids: Array, reserve_ids: Array, player_hp: int, player_max_hp: int) -> void:
	if run_state == null:
		show_main_menu()
		return
	var completed_node: Dictionary = run_state.get_node_data(active_node_id)
	run_state.update_deck(deck_ids)
	run_state.update_reserve(reserve_ids)
	run_state.update_life(player_hp, player_max_hp)
	var stone_reward: int = run_state.battle_spirit_reward(completed_node)
	run_state.add_spirit_stones(stone_reward)
	run_state.complete_node(active_node_id)
	if str(completed_node.get("type", "")) == "boss":
		if not run_state.advance_to_next_story_layer():
			var settlement: Dictionary = run_state.finish_run_and_save_progression()
			active_node_id = ""
			show_run_settlement(settlement)
			return
	else:
		run_state.status_message = "战斗胜利，继续选择下一个节点。"
	active_node_id = ""
	show_map()

func _on_run_abandoned() -> void:
	if run_state != null:
		var settlement: Dictionary = run_state.finish_run_and_save_progression(true, false)
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

func _clear_current_scene() -> void:
	if current_scene != null:
		remove_child(current_scene)
		current_scene.queue_free()
		current_scene = null
