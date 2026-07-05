extends Control

const MainMenuScene = preload("res://scenes/MainMenuScene.tscn")
const JobSelectScene = preload("res://scenes/JobSelectScene.tscn")
const MapScene = preload("res://scenes/MapScene.tscn")
const BattleScene = preload("res://scenes/BattleScene.tscn")
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

func _on_job_selected(job_id: String) -> void:
	run_state = RunStateScript.new()
	run_state.start(job_id)
	show_map()

func _on_map_node_selected(node_data: Dictionary) -> void:
	if run_state == null:
		return
	active_node_id = str(node_data.get("id", ""))
	if not run_state.is_node_available(active_node_id):
		return
	run_state.begin_node(active_node_id)
	_clear_current_scene()
	current_scene = BattleScene.instantiate()
	add_child(current_scene)
	current_scene.map_battle_completed.connect(_on_map_battle_completed)
	current_scene.setup_run_battle(
		run_state.job_id,
		run_state.deck_ids,
		run_state.battle_number_for_node(node_data),
		str(node_data.get("type", "normal"))
	)

func _on_map_battle_completed(deck_ids: Array) -> void:
	if run_state == null:
		show_main_menu()
		return
	run_state.update_deck(deck_ids)
	run_state.complete_node(active_node_id)
	active_node_id = ""
	show_map()

func _on_quit_requested() -> void:
	get_tree().quit()

func _clear_current_scene() -> void:
	if current_scene != null:
		remove_child(current_scene)
		current_scene.queue_free()
		current_scene = null
