extends SceneTree

const BattleScene = preload("res://scenes/battle/BattleScene.tscn")
const MainMenuScene = preload("res://scenes/main/MainMenuScene.tscn")
const CharacterPrepScene = preload("res://scenes/main/CharacterPrepScene.tscn")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(1920, 1080)
	var main_menu := MainMenuScene.instantiate()
	root.add_child(main_menu)
	await process_frame
	main_menu.call("_on_settings_pressed")
	await process_frame
	var settings_panel: Control = main_menu.get("settings_panel") as Control
	var game_page_scroll: Control = main_menu.get("game_page_scroll") as Control
	var keys_page_scroll: Control = main_menu.get("keys_page_scroll") as Control
	var game_tab_button: Button = main_menu.get("game_tab_button") as Button
	var keys_tab_button: Button = main_menu.get("keys_tab_button") as Button
	var controls_section_label = main_menu.get("controls_section_label")
	var settings_confirm_button: Button = main_menu.get("settings_confirm_button") as Button
	var settings_cancel_button: Button = main_menu.get("settings_cancel_button") as Button
	var settings_default_button: Button = main_menu.get("settings_default_button") as Button
	var main_menu_ok := settings_panel != null
	main_menu_ok = main_menu_ok and settings_panel.visible
	main_menu_ok = main_menu_ok and game_page_scroll != null and game_page_scroll.visible
	main_menu_ok = main_menu_ok and keys_page_scroll != null and not keys_page_scroll.visible
	main_menu_ok = main_menu_ok and game_tab_button != null and game_tab_button.button_pressed
	main_menu_ok = main_menu_ok and keys_tab_button != null and not keys_tab_button.button_pressed
	main_menu_ok = main_menu_ok and controls_section_label == null
	main_menu_ok = main_menu_ok and settings_confirm_button != null and settings_confirm_button.text != ""
	main_menu_ok = main_menu_ok and settings_cancel_button != null and settings_cancel_button.text != ""
	main_menu_ok = main_menu_ok and settings_default_button != null and settings_default_button.text != ""
	main_menu.call("_set_settings_tab", "keys")
	await process_frame
	main_menu_ok = main_menu_ok and not game_page_scroll.visible
	main_menu_ok = main_menu_ok and keys_page_scroll.visible
	main_menu_ok = main_menu_ok and not game_tab_button.button_pressed
	main_menu_ok = main_menu_ok and keys_tab_button.button_pressed
	main_menu.call("_on_settings_cancel_pressed")
	await process_frame
	main_menu_ok = main_menu_ok and not settings_panel.visible
	main_menu.queue_free()
	await process_frame

	var prep_scene := CharacterPrepScene.instantiate()
	root.add_child(prep_scene)
	prep_scene.setup("sword")
	await process_frame
	var prep_layout_ok := prep_scene.find_child("DeckButton", true, false) == null
	prep_layout_ok = prep_layout_ok and prep_scene.find_child("StartChallengeButton", true, false) != null
	prep_layout_ok = prep_layout_ok and prep_scene.find_child("GrowthButton", true, false) != null
	prep_layout_ok = prep_layout_ok and prep_scene.find_child("PackButton", true, false) != null
	prep_scene.call("_on_growth_pressed")
	await process_frame
	prep_layout_ok = prep_layout_ok and prep_scene.overlay.visible
	prep_layout_ok = prep_layout_ok and prep_scene.overlay_title_label.text == "角色成长"
	prep_scene.call("_on_pack_pressed")
	await process_frame
	prep_layout_ok = prep_layout_ok and prep_scene.overlay.visible
	prep_layout_ok = prep_layout_ok and prep_scene.overlay_title_label.text == "卡包解锁"
	var prep_signal := {"job_id": "", "deck_size": -1, "reserve_size": -1}
	prep_scene.start_requested.connect(func(job_id: String, deck_ids: Array, reserve_ids: Array) -> void:
		prep_signal["job_id"] = job_id
		prep_signal["deck_size"] = deck_ids.size()
		prep_signal["reserve_size"] = reserve_ids.size()
	)
	var prep_start_button: Button = prep_scene.find_child("StartChallengeButton", true, false) as Button
	if prep_start_button != null:
		prep_start_button.pressed.emit()
		await process_frame
		prep_layout_ok = prep_layout_ok and str(prep_signal.get("job_id", "")) == "sword"
		prep_layout_ok = prep_layout_ok and int(prep_signal.get("deck_size", -1)) == 0
		prep_layout_ok = prep_layout_ok and int(prep_signal.get("reserve_size", -1)) == 0
	else:
		prep_layout_ok = false
	root.remove_child(prep_scene)
	prep_scene.queue_free()
	await process_frame

	var scene := BattleScene.instantiate()
	root.add_child(scene)
	scene.setup("sword")
	for card_id in ["起剑诀", "小无相剑", "养剑匣", "防御准备"]:
		scene.manager._manager.deck.hand.append(CardDatabaseScript.make_card(card_id))
	scene.manager.refresh()
	scene.render()
	await process_frame
	await scene.get_tree().create_timer(4.0).timeout
	scene.render()
	await process_frame
	await process_frame

	var player_actor: Control = scene.get_node("PlayerActor")
	var enemy_actor: Control = scene.get_node("EnemyActor")
	var spell_zone: Control = scene.get_node("SpellDefenseZone")
	var enemy_spell_zone: Control = scene.get_node("EnemySpellDefenseZone")
	var hand_container: Control = scene.get_node("HandContainer")
	var log_panel: Control = scene.get_node("LogPanel")
	var end_turn_button: Button = scene.get_node("ActionRow/EndTurnButton") as Button
	var exile_pile_button: Control = scene.get_node("ExilePileButton")
	var attack_indicator_layer: Control = scene.get_node("AttackIndicatorLayer")
	var player_portrait_box: Control = player_actor.get_node("ActorLayout/PortraitBox")
	var player_portrait_label: Control = player_actor.get_node("ActorLayout/PortraitBox/PortraitLabel")
	var player_hp_bar: Control = player_actor.get_node("ActorLayout/HpBar")
	var player_position := player_actor.global_position
	var enemy_position := enemy_actor.global_position
	var player_size := player_actor.size
	var enemy_size := enemy_actor.size
	var first_slot_position := Vector2.ZERO
	var second_slot_position := Vector2.ZERO
	if spell_zone.get_child_count() >= 2:
		first_slot_position = (spell_zone.get_child(0) as Control).global_position
		second_slot_position = (spell_zone.get_child(1) as Control).global_position

	scene.call("_apply_log_state", true)
	await process_frame
	await process_frame
	scene.call("_on_deck_pile_pressed")
	await process_frame
	await process_frame
	var pile_viewer: Control = scene.get_node("PileViewer")
	var pile_overlay: Control = scene.get_node("PileModalOverlay")
	var pile_card_position_before := Vector2.ZERO
	var pile_card_position_after := Vector2.ZERO
	var pile_card_stays_still := false
	var pile_card_container: Control = pile_viewer.get_node("ViewerLayout/CardScroll/CardContainer")
	if pile_card_container.get_child_count() > 0:
		var pile_card := pile_card_container.get_child(0) as Control
		pile_card.call("cache_base_position")
		pile_card_position_before = pile_card.position
		pile_card.call("_on_mouse_entered")
		await create_timer(0.18).timeout
		pile_card_position_after = pile_card.position
		pile_card.call("_on_mouse_exited")
		pile_card_stays_still = pile_card_position_after.distance_to(pile_card_position_before) < 1.0
	scene.get_node("CardTooltip").call("show_card", scene.manager.deck.hand[0], Vector2(120.0, 120.0))
	await process_frame
	await process_frame
	var tooltip: Control = scene.get_node("CardTooltip")
	tooltip.call("show_card", CardDatabaseScript.get_card("铁木甲"), Vector2(120.0, 120.0))
	await process_frame
	await process_frame
	var ironwood_tooltip_size := tooltip.size
	tooltip.call("hide_tooltip")
	var choice_scene := BattleScene.instantiate()
	root.add_child(choice_scene)
	choice_scene.setup("talisman")
	var recover_card := CardDatabaseScript.make_card("拾符诀")
	var grave_card := CardDatabaseScript.make_card("火球符")
	choice_scene.manager._manager.deck.hand.append(recover_card)
	choice_scene.manager._manager.deck.graveyard.append(grave_card)
	choice_scene.manager.refresh()
	choice_scene.manager.play_hand_card(str(recover_card.get("uid", "")))
	choice_scene.render()
	await process_frame
	await process_frame
	var choice_panel: Control = choice_scene.get_node("ChoicePanel")
	var choice_card_container: Control = choice_scene.get_node("ChoicePanel/ChoiceLayout/ChoiceContainer")
	var choice_tooltip: Control = choice_scene.get_node("CardTooltip")
	var choice_card_stays_still := false
	var choice_tooltip_stays_hidden := false
	if choice_card_container.get_child_count() > 0:
		var choice_card := choice_card_container.get_child(0) as Control
		choice_card.call("cache_base_position")
		var choice_card_position_before := choice_card.position
		choice_card.call("_on_mouse_entered")
		await create_timer(0.18).timeout
		choice_card_stays_still = choice_card.position.distance_to(choice_card_position_before) < 1.0
		choice_tooltip_stays_hidden = not choice_tooltip.visible
		choice_card.call("_on_mouse_exited")
	var first_hand_card: Control = hand_container.get_child(0) as Control
	var last_hand_card: Control = hand_container.get_child(hand_container.get_child_count() - 1) as Control
	var first_card_base_z := first_hand_card.z_index
	var last_card_base_z := last_hand_card.z_index
	var stacked_step := 9999.0
	if hand_container.get_child_count() >= 2:
		stacked_step = ((hand_container.get_child(1) as Control).position.x - first_hand_card.position.x)
	first_hand_card.call("cache_base_position")
	var hand_base_position := first_hand_card.position
	var hand_base_bottom := first_hand_card.global_position.y + first_hand_card.size.y
	first_hand_card.call("_on_mouse_entered")
	await create_timer(0.18).timeout
	var hand_hover_position := first_hand_card.position
	var hand_hover_bottom := first_hand_card.global_position.y + first_hand_card.size.y
	var hand_hover_z := first_hand_card.z_index
	first_hand_card.call("_on_mouse_entered")
	await create_timer(0.18).timeout
	var hand_second_hover_position := first_hand_card.position
	first_hand_card.call("_on_mouse_exited")
	await create_timer(0.18).timeout
	var hand_exit_position := first_hand_card.position
	var hand_exit_z := first_hand_card.z_index

	var ok := main_menu_ok and prep_layout_ok
	ok = ok and spell_zone.get_child_count() == 5
	ok = ok and enemy_spell_zone.get_child_count() == 5
	ok = ok and enemy_spell_zone.global_position.x > spell_zone.global_position.x
	ok = ok and not scene.has_node("GroundBand")
	ok = ok and not scene.has_node("HandScroll")
	ok = ok and hand_container.global_position.y > 500.0
	ok = ok and player_actor.global_position.x > 190.0
	ok = ok and player_actor.global_position.x < 430.0
	ok = ok and enemy_actor.global_position.x > 1400.0
	ok = ok and end_turn_button.global_position.y + end_turn_button.size.y < exile_pile_button.global_position.y
	ok = ok and end_turn_button.size.x > exile_pile_button.size.x
	ok = ok and attack_indicator_layer != null
	ok = ok and not attack_indicator_layer.visible
	ok = ok and player_portrait_box.mouse_filter == Control.MOUSE_FILTER_IGNORE
	ok = ok and player_portrait_label.mouse_filter == Control.MOUSE_FILTER_IGNORE
	ok = ok and player_hp_bar.mouse_filter == Control.MOUSE_FILTER_IGNORE
	ok = ok and second_slot_position.x > first_slot_position.x
	ok = ok and abs(second_slot_position.y - first_slot_position.y) < 8.0
	ok = ok and log_panel.visible
	ok = ok and pile_viewer.visible
	ok = ok and pile_overlay.visible
	ok = ok and pile_overlay.get_index() < pile_viewer.get_index()
	ok = ok and pile_card_stays_still
	ok = ok and hand_hover_position.y < hand_base_position.y
	ok = ok and abs(hand_second_hover_position.y - hand_hover_position.y) < 1.0
	ok = ok and hand_exit_position.distance_to(hand_base_position) < 1.0
	ok = ok and hand_container.get_child_count() >= 9
	ok = ok and stacked_step < first_hand_card.size.x
	ok = ok and last_card_base_z > first_card_base_z
	ok = ok and hand_hover_z > last_card_base_z
	ok = ok and hand_exit_z == first_card_base_z
	ok = ok and not tooltip.visible
	ok = ok and first_hand_card.size.x == 225.0
	ok = ok and first_hand_card.size.y == 315.0
	ok = ok and hand_base_bottom > float(root.size.y)
	ok = ok and hand_hover_bottom <= float(root.size.y)
	ok = ok and str(first_hand_card.get_node("CardLayout/NameLabel").get("text")).length() > 0
	ok = ok and str(first_hand_card.get_node("CardLayout/TypeLabel").get("text")).length() > 0
	ok = ok and str(first_hand_card.get_node("CardLayout/BodyLabel").get("text")).length() > 0
	ok = ok and tooltip.size.y <= 210.0
	ok = ok and ironwood_tooltip_size.y <= 210.0
	ok = ok and choice_panel.visible
	ok = ok and choice_card_stays_still
	ok = ok and choice_tooltip_stays_hidden
	ok = ok and player_actor.global_position == player_position
	ok = ok and enemy_actor.global_position == enemy_position
	ok = ok and player_actor.size == player_size
	ok = ok and enemy_actor.size == enemy_size
	ok = ok and not scene.has_node("ResponsePanel")
	var outside_click := InputEventMouseButton.new()
	outside_click.button_index = MOUSE_BUTTON_LEFT
	outside_click.pressed = true
	scene.call("_on_pile_modal_overlay_input", outside_click)
	await process_frame
	ok = ok and not pile_viewer.visible
	ok = ok and not pile_overlay.visible

	var equipment_scene := BattleScene.instantiate()
	root.add_child(equipment_scene)
	equipment_scene.setup("sword")
	var equip_sword := CardDatabaseScript.make_card("青锋剑")
	var equip_armor := CardDatabaseScript.make_card("铁木甲")
	var equip_charm := CardDatabaseScript.make_card("养剑匣")
	equipment_scene.manager._manager.deck.hand.append(equip_sword)
	equipment_scene.manager._manager.deck.hand.append(equip_armor)
	equipment_scene.manager._manager.deck.hand.append(equip_charm)
	equipment_scene.manager.refresh()
	equipment_scene.manager.play_hand_card(str(equip_sword.get("uid", "")))
	equipment_scene.manager.play_hand_card(str(equip_armor.get("uid", "")))
	equipment_scene.render()
	await process_frame
	await process_frame
	var equipment_zone: Control = equipment_scene.get_node("EquipmentZone")
	var equipment_hint: Control = equipment_scene.get_node("EquipmentReplaceHintPanel")
	ok = ok and equipment_zone.visible
	ok = ok and equipment_zone.get_child_count() == 2
	var first_equipment: Control = equipment_zone.get_child(0) as Control
	var second_equipment: Control = equipment_zone.get_child(1) as Control
	var equipment_player_actor: Control = equipment_scene.get_node("PlayerActor") as Control
	var equipment_gap: float = equipment_player_actor.global_position.x - (first_equipment.global_position.x + first_equipment.size.x)
	ok = ok and first_equipment.global_position.x < (equipment_scene.get_node("PlayerActor") as Control).global_position.x
	ok = ok and equipment_gap >= 0.0
	ok = ok and equipment_gap <= 24.0
	ok = ok and second_equipment.position.y > first_equipment.position.y
	equipment_scene.manager.play_hand_card(str(equip_charm.get("uid", "")))
	equipment_scene.render()
	await process_frame
	await process_frame
	ok = ok and not equipment_scene.manager.pending_equipment_replace.is_empty()
	ok = ok and equipment_hint.visible
	first_equipment = equipment_zone.get_child(0) as Control
	ok = ok and bool(first_equipment.get("response_available"))
	equipment_scene.call("_on_equipment_slot_pressed", equipment_scene.manager.player.equipment[0], first_equipment.global_position + Vector2(first_equipment.size.x + 6.0, first_equipment.size.y * 0.5))
	await process_frame
	ok = ok and equipment_scene.get_node("EquipmentConfirmPanel").visible
	ok = ok and first_equipment.position.x > 0.0
	equipment_scene.call("_on_equipment_confirm_activate")
	await process_frame
	await process_frame
	ok = ok and equipment_scene.manager.pending_equipment_replace.is_empty()
	ok = ok and equipment_scene.manager.player.equipment.size() == equipment_scene.manager.player.equipment_limit
	ok = ok and equipment_scene.manager.deck.graveyard.size() >= 1

	var drag_target_scene := BattleScene.instantiate()
	root.add_child(drag_target_scene)
	drag_target_scene.setup("sword")
	var drag_damage_card := CardDatabaseScript.make_card("雷击符")
	drag_target_scene.manager._manager.deck.hand.append(drag_damage_card)
	drag_target_scene.manager._manager.add_enemy_unit({
		"id": "drag_dummy",
		"uid": "drag_dummy",
		"name": "拖拽目标",
		"max_hp": 12,
		"attack": 0,
		"defense": 0,
		"action_sequence": []
	}, 0)
	drag_target_scene.manager.refresh()
	drag_target_scene.render()
	await process_frame
	await process_frame
	var drag_damage_button: Control = drag_target_scene.call("_find_hand_card_button", str(drag_damage_card.get("uid", ""))) as Control
	var drag_dummy_actor: Control = drag_target_scene.get_node("FormationActor_drag_dummy") as Control
	var drag_damage_started: bool = drag_target_scene.call("_begin_hand_card_drag", drag_damage_button, drag_damage_button.global_position + Vector2(24.0, 24.0))
	await process_frame
	ok = ok and drag_damage_started
	ok = ok and bool(drag_dummy_actor.get("drop_available"))
	drag_target_scene.call("_finish_hand_card_drag", drag_dummy_actor.global_position + drag_dummy_actor.size * drag_dummy_actor.scale * 0.5)
	await process_frame
	await process_frame
	var drag_dummy = drag_target_scene.manager.formation.living_unit_by_uid("enemy", "drag_dummy")
	ok = ok and drag_dummy != null
	ok = ok and int(drag_dummy.hp) < 12
	ok = ok and drag_target_scene.manager.deck.find_hand_card(str(drag_damage_card.get("uid", ""))).is_empty()
	ok = ok and not bool(drag_dummy_actor.get("drop_available"))

	var drag_equipment_scene := BattleScene.instantiate()
	root.add_child(drag_equipment_scene)
	drag_equipment_scene.setup("sword")
	var drag_equipment_card := CardDatabaseScript.make_card("青锋剑")
	drag_equipment_scene.manager._manager.deck.hand.append(drag_equipment_card)
	drag_equipment_scene.manager.refresh()
	drag_equipment_scene.render()
	await process_frame
	await process_frame
	var drag_equipment_button: Control = drag_equipment_scene.call("_find_hand_card_button", str(drag_equipment_card.get("uid", ""))) as Control
	var drag_player_actor: Control = drag_equipment_scene.get_node("PlayerActor") as Control
	var drag_attack_before: int = drag_equipment_scene.manager.player.current_attack()
	var drag_equipment_started: bool = drag_equipment_scene.call("_begin_hand_card_drag", drag_equipment_button, drag_equipment_button.global_position + Vector2(24.0, 24.0))
	await process_frame
	ok = ok and drag_equipment_started
	ok = ok and bool(drag_player_actor.get("drop_available"))
	drag_equipment_scene.call("_finish_hand_card_drag", drag_player_actor.global_position + drag_player_actor.size * 0.5)
	await process_frame
	await process_frame
	ok = ok and drag_equipment_scene.manager.player.equipment.size() == 1
	ok = ok and drag_equipment_scene.manager.player.current_attack() == drag_attack_before + 2
	ok = ok and drag_equipment_scene.manager.deck.find_hand_card(str(drag_equipment_card.get("uid", ""))).is_empty()

	var drag_ally_equipment_scene := BattleScene.instantiate()
	root.add_child(drag_ally_equipment_scene)
	drag_ally_equipment_scene.setup("sword")
	drag_ally_equipment_scene.manager._manager.add_player_summon({
		"id": "drag_equip_ally",
		"uid": "drag_equip_ally",
		"name": "拖拽装备友军",
		"max_hp": 5,
		"attack": 0,
		"defense": 0
	}, 1)
	var drag_ally_equipment_card := CardDatabaseScript.make_card("铁木甲")
	drag_ally_equipment_scene.manager._manager.deck.hand.append(drag_ally_equipment_card)
	drag_ally_equipment_scene.manager.refresh()
	drag_ally_equipment_scene.render()
	await process_frame
	await process_frame
	var drag_ally_equipment_button: Control = drag_ally_equipment_scene.call("_find_hand_card_button", str(drag_ally_equipment_card.get("uid", ""))) as Control
	var drag_ally_actor: Control = drag_ally_equipment_scene.get_node("FormationActor_drag_equip_ally") as Control
	var drag_ally_unit = drag_ally_equipment_scene.manager.formation.living_unit_by_uid("player", "drag_equip_ally")
	var drag_ally_defense_before: int = drag_ally_unit.current_defense()
	var drag_ally_equipment_started: bool = drag_ally_equipment_scene.call("_begin_hand_card_drag", drag_ally_equipment_button, drag_ally_equipment_button.global_position + Vector2(24.0, 24.0))
	await process_frame
	ok = ok and drag_ally_equipment_started
	ok = ok and bool(drag_ally_actor.get("drop_available"))
	drag_ally_equipment_scene.call("_finish_hand_card_drag", drag_ally_actor.global_position + drag_ally_actor.size * drag_ally_actor.scale * 0.5)
	await process_frame
	await process_frame
	drag_ally_unit = drag_ally_equipment_scene.manager.formation.living_unit_by_uid("player", "drag_equip_ally")
	ok = ok and drag_ally_unit.equipment.size() == 1
	ok = ok and drag_ally_unit.current_defense() == drag_ally_defense_before + 1
	ok = ok and drag_ally_equipment_scene.manager.deck.find_hand_card(str(drag_ally_equipment_card.get("uid", ""))).is_empty()

	var drag_direct_scene := BattleScene.instantiate()
	root.add_child(drag_direct_scene)
	drag_direct_scene.setup("sword")
	var drag_direct_card := CardDatabaseScript.make_card("起剑诀")
	drag_direct_scene.manager._manager.deck.hand.append(drag_direct_card)
	drag_direct_scene.manager.refresh()
	drag_direct_scene.render()
	await process_frame
	await process_frame
	var drag_direct_button: Control = drag_direct_scene.call("_find_hand_card_button", str(drag_direct_card.get("uid", ""))) as Control
	ok = ok and not bool(drag_direct_scene.call("_begin_hand_card_drag", drag_direct_button, drag_direct_button.global_position + Vector2(24.0, 24.0)))

	var formation_scene := BattleScene.instantiate()
	root.add_child(formation_scene)
	formation_scene.setup("sword")
	var formation_player_position := (formation_scene.get_node("PlayerActor") as Control).global_position
	var formation_enemy_position := (formation_scene.get_node("EnemyActor") as Control).global_position
	ok = ok and formation_scene.get_node_or_null("BattleDebugTools") == null
	ok = ok and formation_scene.get_node_or_null("DebugToolsToggleButton") == null
	formation_scene.call("_on_debug_toggle")
	await process_frame
	ok = ok and formation_scene.get_node_or_null("BattleDebugTools") == null
	ok = ok and formation_scene.get_node_or_null("DebugToolsToggleButton") == null
	var enemy_count_before_debug: int = formation_scene.manager.enemy_target_count()
	formation_scene.call("_on_debug_add_enemy")
	ok = ok and formation_scene.manager.enemy_target_count() == enemy_count_before_debug
	var player_count_before_debug: int = formation_scene.manager.player_target_count()
	formation_scene.call("_on_debug_add_ally")
	ok = ok and formation_scene.manager.player_target_count() == player_count_before_debug
	formation_scene.call("_on_debug_clear_extra_enemies")
	ok = ok and formation_scene.manager.enemy_target_count() == enemy_count_before_debug
	ok = ok and formation_scene.manager.player_target_count() == player_count_before_debug
	var debug_target = formation_scene.manager.selected_debug_unit()
	if debug_target != null:
		var debug_hp_before: int = int(debug_target.hp)
		var debug_attack_before: int = int(debug_target.attack)
		var debug_defense_before: int = int(debug_target.defense)
		formation_scene.call("_on_debug_damage_target", 5)
		formation_scene.call("_on_debug_heal_target", 5)
		formation_scene.call("_on_debug_modify_target_attack", 1)
		formation_scene.call("_on_debug_modify_target_defense", 1)
		ok = ok and int(debug_target.hp) == debug_hp_before
		ok = ok and int(debug_target.attack) == debug_attack_before
		ok = ok and int(debug_target.defense) == debug_defense_before
	formation_scene.manager._manager.add_enemy_unit({
		"id": "training_dummy",
		"name": "练功傀儡",
		"max_hp": 12,
		"attack": 0,
		"defense": 0,
		"action_sequence": []
	}, 0)
	formation_scene.manager.refresh()
	formation_scene.render()
	await process_frame
	await process_frame
	var formation_actor: Control = formation_scene.get_node("FormationActor_training_dummy") as Control
	var formation_portrait_box: Control = formation_actor.get_node("ActorLayout/PortraitBox")
	var formation_extra_label: Label = formation_actor.get_node("ActorLayout/ExtraLabel") as Label
	var formation_equipment_zone: Control = formation_scene.get_node("UnitEquipmentZone_training_dummy") as Control
	var formation_enemy_equipment_zone: Control = formation_scene.get_node("UnitEquipmentZone_%s" % formation_scene.manager.enemy.uid) as Control
	var formation_player_equipment_zone: Control = formation_scene.get_node("EquipmentZone") as Control
	ok = ok and formation_actor != null
	ok = ok and formation_actor.visible
	ok = ok and formation_actor.scale.x < 1.0
	ok = ok and formation_equipment_zone != null
	ok = ok and formation_equipment_zone.visible
	ok = ok and formation_equipment_zone.get_child_count() == 1
	ok = ok and formation_enemy_equipment_zone != null
	ok = ok and formation_enemy_equipment_zone.get_child_count() == formation_scene.manager.enemy.equipment_limit
	ok = ok and formation_player_equipment_zone.visible
	ok = ok and formation_player_equipment_zone.get_child_count() == formation_scene.manager.player.equipment_limit
	var formation_player_equipment_slot: Control = formation_player_equipment_zone.get_child(0) as Control
	var formation_enemy_equipment_slot: Control = formation_enemy_equipment_zone.get_child(0) as Control
	var formation_unit_equipment_slot: Control = formation_equipment_zone.get_child(0) as Control
	ok = ok and formation_player_equipment_slot.size == formation_unit_equipment_slot.size
	ok = ok and formation_enemy_equipment_slot.size == formation_unit_equipment_slot.size
	ok = ok and abs(formation_player_equipment_zone.global_position.y - ((formation_scene.get_node("PlayerActor") as Control).global_position.y + 12.0)) < 3.0
	ok = ok and abs(formation_enemy_equipment_zone.global_position.y - ((formation_scene.get_node("EnemyActor") as Control).global_position.y + 12.0)) < 3.0
	ok = ok and not (formation_player_equipment_slot.get_node("GlowLayer") as Control).visible
	ok = ok and not (formation_enemy_equipment_slot.get_node("GlowLayer") as Control).visible
	ok = ok and formation_portrait_box.mouse_filter == Control.MOUSE_FILTER_IGNORE
	ok = ok and str(formation_extra_label.text) == "装备 0/1"
	ok = ok and formation_scene.get_node("EnemyActor").scale.x == 1.0
	ok = ok and (formation_scene.get_node("PlayerActor") as Control).global_position == formation_player_position
	ok = ok and (formation_scene.get_node("EnemyActor") as Control).global_position == formation_enemy_position
	var player_actor_for_action: Control = formation_scene.get_node("PlayerActor") as Control
	var player_action_click := InputEventMouseButton.new()
	player_action_click.button_index = MOUSE_BUTTON_LEFT
	player_action_click.pressed = true
	formation_scene.call("_on_actor_gui_input", player_action_click, player_actor_for_action)
	await process_frame
	await formation_scene.get_tree().create_timer(4.0).timeout
	formation_scene.render()
	await process_frame
	ok = ok and formation_scene.get_node_or_null("UnitActionPanel") == null
	var player_inline_panel: Control = formation_scene.get_node_or_null("InlineActionPanel_%s" % formation_scene.manager.player.uid) as Control
	ok = ok and player_inline_panel != null
	ok = ok and player_inline_panel.visible
	ok = ok and player_inline_panel.global_position.y > player_actor_for_action.global_position.y
	formation_scene.call("_on_inline_unit_attack_pressed", str(formation_scene.manager.player.uid))
	await process_frame
	ok = ok and formation_scene.manager.phase == "target_select"
	ok = ok and formation_scene.get_node_or_null("InlineActionPanel_%s" % formation_scene.manager.player.uid) == null
	formation_scene.call("_on_actor_mouse_entered", formation_actor)
	await process_frame
	ok = ok and formation_scene.manager.selected_enemy_uid == "training_dummy"
	ok = ok and bool(formation_actor.get("selected"))
	var target_result_preview_label: Label = formation_scene.get_node("ResultPreviewLabel") as Label
	var target_preview_text := str(target_result_preview_label.text)
	ok = ok and target_result_preview_label.visible
	ok = ok and target_preview_text.contains("预计结果")
	ok = ok and target_preview_text.contains("预计造成")
	ok = ok and target_preview_text.contains("练功傀儡")
	var dummy_hp_before: int = int(formation_scene.manager.formation.living_unit_by_uid("enemy", "training_dummy").hp)
	var formation_click := InputEventMouseButton.new()
	formation_click.button_index = MOUSE_BUTTON_LEFT
	formation_click.pressed = true
	formation_scene.call("_on_actor_gui_input", formation_click, formation_actor)
	await process_frame
	ok = ok and formation_scene.manager.selected_enemy_uid == "training_dummy"
	ok = ok and formation_scene.manager.phase == "player"
	ok = ok and not target_result_preview_label.visible
	var formation_end_turn_button: Button = formation_scene.get_node("ActionRow/EndTurnButton") as Button
	var formation_end_style := formation_end_turn_button.get_theme_stylebox("normal") as StyleBoxFlat
	ok = ok and formation_end_style != null
	ok = ok and formation_end_style.shadow_size >= 10
	ok = ok and int(formation_scene.manager.formation.living_unit_by_uid("enemy", "training_dummy").hp) < dummy_hp_before
	formation_scene.manager.apply_damage_to_unit(formation_scene.manager.formation.living_unit_by_uid("enemy", "training_dummy"), 99, "测试")
	formation_scene.manager.check_victory_or_defeat()
	formation_scene.render()
	await process_frame
	await process_frame
	ok = ok and formation_scene.manager.formation.unit_by_uid("training_dummy") == null
	ok = ok and formation_scene.get_node_or_null("FormationActor_training_dummy") == null
	ok = ok and formation_scene.get_node_or_null("UnitEquipmentZone_training_dummy") == null

	if ok:
		print("LAYOUT_SMOKE_TEST_OK")
		quit(0)
	else:
		push_error("LAYOUT_SMOKE_TEST_FAILED")
		quit(1)
