extends SceneTree

const MainScene = preload("res://scenes/Main.tscn")
const MainMenuScene = preload("res://scenes/MainMenuScene.tscn")
const JobSelectScene = preload("res://scenes/JobSelectScene.tscn")
const MapScene = preload("res://scenes/MapScene.tscn")
const BattleScene = preload("res://scenes/BattleScene.tscn")
const RunStateScript = preload("res://scripts/run/RunState.gd")

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(1920, 1080)
	var ok := true

	var main := MainScene.instantiate()
	root.add_child(main)
	await process_frame
	ok = ok and main.current_scene != null
	root.remove_child(main)
	main.queue_free()

	var menu := MainMenuScene.instantiate()
	root.add_child(menu)
	await process_frame
	ok = ok and menu.has_signal("start_requested")
	ok = ok and menu.has_signal("quit_requested")
	root.remove_child(menu)
	menu.queue_free()

	var job_select := JobSelectScene.instantiate()
	root.add_child(job_select)
	await process_frame
	ok = ok and job_select.has_signal("job_selected")
	ok = ok and job_select.job_buttons.size() >= 2
	root.remove_child(job_select)
	job_select.queue_free()

	var run_state = RunStateScript.new()
	run_state.start("sword")
	ok = ok and run_state.available_nodes().size() >= 1

	var map_scene := MapScene.instantiate()
	root.add_child(map_scene)
	map_scene.setup(run_state)
	await process_frame
	await process_frame
	ok = ok and map_scene.node_layer != null
	ok = ok and map_scene.node_layer.get_child_count() >= run_state.map_nodes.size()
	root.remove_child(map_scene)
	map_scene.queue_free()

	var node: Dictionary = run_state.available_nodes()[0]
	var battle := BattleScene.instantiate()
	root.add_child(battle)
	battle.setup_run_battle(run_state.job_id, run_state.deck_ids, run_state.battle_number_for_node(node), str(node.get("type", "normal")))
	await process_frame
	ok = ok and battle.manager != null
	ok = ok and not battle.manager.auto_advance_after_reward
	battle.manager.enemy.hp = 1
	battle.manager.player_normal_attack()
	battle.render()
	await process_frame
	ok = ok and battle.manager.phase == "reward"
	var reward_id := str(battle.manager.reward_options[0])
	var signal_state := {"completed": false}
	battle.map_battle_completed.connect(func(deck_ids: Array) -> void:
		signal_state["completed"] = deck_ids.has(reward_id)
	)
	battle.call("_on_reward_pressed", "", reward_id)
	await process_frame
	ok = ok and bool(signal_state.get("completed", false))

	if ok:
		print("RUN_FLOW_SMOKE_TEST_OK")
		quit(0)
	else:
		push_error("RUN_FLOW_SMOKE_TEST_FAILED")
		quit(1)
