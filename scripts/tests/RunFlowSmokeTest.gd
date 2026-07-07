extends SceneTree

const MainScene = preload("res://scenes/Main.tscn")
const MainMenuScene = preload("res://scenes/MainMenuScene.tscn")
const JobSelectScene = preload("res://scenes/JobSelectScene.tscn")
const CharacterPrepScene = preload("res://scenes/CharacterPrepScene.tscn")
const MapScene = preload("res://scenes/MapScene.tscn")
const BattleScene = preload("res://scenes/BattleScene.tscn")
const RunSettlementScene = preload("res://scenes/RunSettlementScene.tscn")
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

	var prep_scene := CharacterPrepScene.instantiate()
	root.add_child(prep_scene)
	prep_scene.setup("sword")
	await process_frame
	ok = ok and prep_scene.has_signal("start_requested")
	ok = ok and prep_scene.has_signal("back_requested")
	ok = ok and prep_scene.get_node("CharacterPrepRoot/CharacterActionPanel/StartChallengeButton").text == "开始挑战"
	var prep_signal := {"job_id": "", "deck_size": 0, "reserve_size": 0}
	prep_scene.start_requested.connect(func(job_id: String, deck_ids: Array, reserve_ids: Array) -> void:
		prep_signal["job_id"] = job_id
		prep_signal["deck_size"] = deck_ids.size()
		prep_signal["reserve_size"] = reserve_ids.size()
	)
	var start_challenge_button: Button = prep_scene.get_node("CharacterPrepRoot/CharacterActionPanel/StartChallengeButton") as Button
	start_challenge_button.pressed.emit()
	await process_frame
	ok = ok and str(prep_signal.get("job_id", "")) == "sword"
	ok = ok and int(prep_signal.get("deck_size", 0)) >= 10
	ok = ok and int(prep_signal.get("reserve_size", -1)) == 0
	ok = ok and prep_scene.prep_reserve_ids.size() >= 1
	prep_scene.call("_on_growth_pressed")
	await process_frame
	ok = ok and prep_scene.overlay.visible
	ok = ok and prep_scene.overlay_title_label.text == "角色成长"
	ok = ok and prep_scene.overlay_message_label.text.contains("可用修为点")
	ok = ok and prep_scene.overlay_content.find_child("GrowthSection_基础属性", true, false) != null
	prep_scene.call("_on_pack_pressed")
	await process_frame
	ok = ok and prep_scene.overlay.visible
	ok = ok and prep_scene.overlay_title_label.text == "卡包解锁"
	ok = ok and prep_scene.overlay_content.get_child_count() >= 10
	ok = ok and prep_scene.overlay_content.find_child("PackUnlockButton", true, false) != null
	prep_scene.call("_on_deck_pressed")
	await process_frame
	ok = ok and prep_scene.overlay.visible
	ok = ok and prep_scene.overlay_title_label.text == "开局构筑"
	ok = ok and prep_scene.overlay_content.find_child("PrepDeckContainer", true, false) != null
	ok = ok and prep_scene.overlay_content.find_child("PrepReserveContainer", true, false) != null
	root.remove_child(prep_scene)
	prep_scene.queue_free()

	var run_state = RunStateScript.new()
	run_state.start("sword")
	ok = ok and run_state.available_nodes().size() >= 1

	var settlement_scene := RunSettlementScene.instantiate()
	root.add_child(settlement_scene)
	settlement_scene.setup(run_state, {"base": 9, "multiplier": 1.25, "awarded": 12, "completed": false})
	await process_frame
	ok = ok and settlement_scene.has_signal("return_requested")
	ok = ok and settlement_scene.has_signal("retry_requested")
	ok = ok and settlement_scene.get_node("SettlementRoot/SettlementTitleLabel").text == "探索失败"
	ok = ok and settlement_scene.get_node("SettlementRoot/SettlementPanel/SettlementStatsLayout/SettlementAwardedLabel").text.contains("12")
	root.remove_child(settlement_scene)
	settlement_scene.queue_free()

	var map_scene := MapScene.instantiate()
	root.add_child(map_scene)
	map_scene.setup(run_state)
	await process_frame
	await process_frame
	ok = ok and map_scene.node_layer != null
	ok = ok and map_scene.node_layer.get_child_count() >= run_state.map_nodes.size()
	map_scene.call("_on_deck_builder_pressed")
	await process_frame
	ok = ok and map_scene.deck_builder_overlay.visible
	ok = ok and map_scene.builder_deck_container.get_child_count() >= run_state.deck_ids.size()
	if map_scene.builder_deck_container.get_child_count() > 0:
		var builder_first_card: Control = map_scene.builder_deck_container.get_child(0) as Control
		ok = ok and str(builder_first_card.get_node("CardLayout/ScoreRow/ScoreTitleLabel").get("text")) == "分数"
		ok = ok and str(builder_first_card.get_node("CardLayout/ScoreRow/ScoreValueLabel").get("text")).is_valid_int()
	var original_deck_size: int = run_state.deck_ids.size()
	map_scene.call("_on_builder_card_pressed", "", "deck", 0)
	await process_frame
	ok = ok and map_scene.builder_deck_ids.size() == original_deck_size - 1
	ok = ok and run_state.deck_ids.size() == original_deck_size
	map_scene.call("_on_save_builder_pressed")
	await process_frame
	ok = ok and map_scene.deck_builder_overlay.visible
	ok = ok and run_state.deck_ids.size() == original_deck_size
	map_scene.call("_on_cancel_builder_pressed")
	await process_frame
	ok = ok and map_scene.builder_confirm_panel.visible
	map_scene.call("_discard_builder_and_close")
	await process_frame
	ok = ok and not map_scene.deck_builder_overlay.visible
	ok = ok and run_state.deck_ids.size() == original_deck_size
	var treasure_node := {}
	for map_node in run_state.map_nodes:
		if str(map_node.get("type", "")) == "treasure":
			treasure_node = map_node
			break
	ok = ok and not treasure_node.is_empty()
	if not treasure_node.is_empty():
		run_state.current_hp = max(1, run_state.max_hp - 6)
		map_scene.call("_open_treasure_node", treasure_node)
		await process_frame
		ok = ok and map_scene.map_modal_overlay.visible
		ok = ok and map_scene.map_modal_title_label.text == "遗落宝箱"
		ok = ok and map_scene.map_modal_options_container.get_child_count() >= 1
		var treasure_grid: GridContainer = map_scene.map_modal_options_container.get_child(0) as GridContainer
		ok = ok and treasure_grid != null
		ok = ok and treasure_grid.get_child_count() >= 3
	run_state.reserve_ids.append("雷击符")
	map_scene.call("_open_shop_sell_view", "测试出售。")
	await process_frame
	ok = ok and map_scene.map_modal_overlay.visible
	ok = ok and map_scene.map_modal_title_label.text == "坊市 - 出售"
	ok = ok and map_scene.map_modal_options_container.get_child_count() >= 2
	var sell_scroll: ScrollContainer = map_scene.map_modal_options_container.get_child(1) as ScrollContainer
	if sell_scroll != null:
		var sell_grid: GridContainer = sell_scroll.get_child(0) as GridContainer
		ok = ok and sell_grid != null and sell_grid.get_child_count() >= 1
		if sell_grid != null and sell_grid.get_child_count() > 0:
			var sell_slot: VBoxContainer = sell_grid.get_child(0) as VBoxContainer
			var sell_card: Control = sell_slot.get_child(0) as Control
			var sell_button: Button = sell_slot.get_child(1) as Button
			ok = ok and str(sell_card.get_node("CardLayout/OwnershipLabel").get("text")).contains("备牌")
			ok = ok and sell_button.text.begins_with("出售 ")
	var shop_node := {}
	for map_node in run_state.map_nodes:
		if str(map_node.get("type", "")) == "shop":
			shop_node = map_node
			break
	run_state.add_spirit_stones(999)
	if not shop_node.is_empty():
		map_scene.call("_open_shop_node", shop_node)
		await process_frame
		var buy_scroll: ScrollContainer = map_scene.map_modal_options_container.get_child(1) as ScrollContainer
		if buy_scroll != null:
			var buy_grid: GridContainer = buy_scroll.get_child(0) as GridContainer
			ok = ok and buy_grid != null and buy_grid.get_child_count() >= 1
			if buy_grid != null and buy_grid.get_child_count() > 0:
				var buy_slot: VBoxContainer = buy_grid.get_child(0) as VBoxContainer
				var buy_card: Control = buy_slot.get_child(0) as Control
				var buy_button: Button = buy_slot.get_child(1) as Button
				ok = ok and str(buy_card.get_node("CardLayout/OwnershipLabel").get("text")).contains("卡组")
				ok = ok and buy_button.text.begins_with("购买 ")
	map_scene.call("_open_trade_event")
	await process_frame
	ok = ok and map_scene.map_modal_overlay.visible
	ok = ok and map_scene.map_modal_title_label.text == "试炼交易"
	ok = ok and map_scene.map_modal_options_container.get_child_count() >= 1
	var trade_grid: GridContainer = map_scene.map_modal_options_container.get_child(0) as GridContainer
	ok = ok and trade_grid != null and trade_grid.get_child_count() >= 3
	var saw_trade_payment := false
	var saw_trade_free := false
	if trade_grid != null:
		for trade_child in trade_grid.get_children():
			var trade_slot := trade_child as VBoxContainer
			if trade_slot == null or trade_slot.get_child_count() < 2:
				continue
			var trade_card: Control = trade_slot.get_child(0) as Control
			var trade_button: Button = trade_slot.get_child(1) as Button
			if trade_button == null:
				continue
			saw_trade_payment = saw_trade_payment or trade_button.text.begins_with("支付 ")
			saw_trade_free = saw_trade_free or trade_button.text == "无代价取得"
			if trade_button.text == "无代价取得" and trade_card != null:
				ok = ok and str(trade_card.get_node("CardLayout/BodyLabel").get("text")).is_valid_int()
	ok = ok and saw_trade_payment and saw_trade_free
	root.remove_child(map_scene)
	map_scene.queue_free()

	var node: Dictionary = run_state.available_nodes()[0]
	var battle := BattleScene.instantiate()
	root.add_child(battle)
	run_state.current_hp -= 4
	var expected_stone_reward: int = run_state.battle_spirit_reward(node)
	battle.setup_run_battle(run_state.job_id, run_state.deck_ids, run_state.battle_number_for_node(node), str(node.get("type", "normal")), run_state.run_context(), expected_stone_reward)
	await process_frame
	ok = ok and battle.manager != null
	ok = ok and not battle.manager.auto_advance_after_reward
	ok = ok and battle.manager.player.hp == run_state.current_hp
	battle.manager.enemy.hp = 1
	battle.manager.player_normal_attack()
	battle.render()
	await process_frame
	ok = ok and battle.manager.phase == "reward"
	ok = ok and str(battle.get_node("RewardScene/RewardLayout/RewardTitleLabel").get("text")).contains("选择一张奖励卡")
	var reward_id := str(battle.manager.reward_options[0])
	var signal_state := {"completed": false}
	battle.map_battle_completed.connect(func(deck_ids: Array, reserve_ids: Array, player_hp: int, player_max_hp: int) -> void:
		signal_state["completed"] = (deck_ids.has(reward_id) or reserve_ids.has(reward_id)) and player_hp == battle.manager.player.hp and player_max_hp == battle.manager.player.max_hp
	)
	battle.call("_on_reward_pressed", "", reward_id)
	await process_frame
	ok = ok and not bool(signal_state.get("completed", false))
	ok = ok and str(battle.get_node("RewardScene/RewardLayout/RewardTitleLabel").get("text")).contains("获得 %d 灵石" % expected_stone_reward)
	var continue_button: Button = battle.get_node("RewardScene/RewardLayout/RewardContainer").get_child(0) as Button
	continue_button.pressed.emit()
	await process_frame
	ok = ok and bool(signal_state.get("completed", false))
	root.remove_child(battle)
	battle.queue_free()

	var defeat_battle := BattleScene.instantiate()
	root.add_child(defeat_battle)
	defeat_battle.setup_run_battle(run_state.job_id, run_state.deck_ids, 7, "boss", run_state.run_context())
	await process_frame
	var abandon_state := {"abandoned": false}
	defeat_battle.run_abandoned.connect(func() -> void:
		abandon_state["abandoned"] = true
	)
	defeat_battle.manager.phase = "defeat"
	defeat_battle.render()
	defeat_battle.call("_on_restart")
	await process_frame
	ok = ok and bool(abandon_state.get("abandoned", false))
	root.remove_child(defeat_battle)
	defeat_battle.queue_free()

	if ok:
		print("RUN_FLOW_SMOKE_TEST_OK")
		quit(0)
	else:
		push_error("RUN_FLOW_SMOKE_TEST_FAILED")
		quit(1)
