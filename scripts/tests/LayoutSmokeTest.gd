extends SceneTree

const BattleScene = preload("res://scenes/BattleScene.tscn")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(1920, 1080)
	var scene := BattleScene.instantiate()
	root.add_child(scene)
	scene.setup("sword")
	for card_id in ["起剑诀", "小无相剑", "养剑匣", "藏锋"]:
		scene.manager.deck.hand.append(CardDatabaseScript.make_card(card_id))
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
	choice_scene.manager.deck.hand.append(recover_card)
	choice_scene.manager.deck.graveyard.append(grave_card)
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

	var ok := true
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

	var response_scene := BattleScene.instantiate()
	root.add_child(response_scene)
	response_scene.setup("sword")
	var response_card := CardDatabaseScript.make_card("护身符")
	response_card["set_turn"] = 0
	response_card["cover_turn"] = 0
	response_card["face_down"] = true
	response_card["ready"] = true
	response_card["sealed"] = false
	response_card["already_in_chain"] = false
	response_scene.manager.player.spell_zone.append(response_card)
	response_scene.manager.open_timing_window(response_scene.manager.create_event("player_damage_before", "enemy_attack", "player", 5))
	response_scene.render()
	await process_frame
	await process_frame
	var chain_overlay: Control = response_scene.get_node("ChainOverlay")
	var response_confirm_panel: Control = response_scene.get_node("ResponseConfirmPanel")
	var response_slot: Control = response_scene.get_node("SpellDefenseZone").get_child(0) as Control
	ok = ok and chain_overlay.visible
	ok = ok and str(chain_overlay.get_node("ChainTitleLabel").get("text")) == "发动盖伏卡"
	var result_preview_label: Label = response_scene.get_node("ResultPreviewLabel") as Label
	var response_instruction_text := str(chain_overlay.get_node("ChainEventLabel").get("text"))
	var response_preview_text := str(result_preview_label.text)
	ok = ok and response_instruction_text == "可发动放置区中发光的盖伏卡"
	ok = ok and result_preview_label.visible
	ok = ok and response_preview_text.contains("预计结果")
	ok = ok and result_preview_label.global_position.y + result_preview_label.size.y < (chain_overlay.get_node("ChainTitleLabel") as Control).global_position.y
	ok = ok and str(chain_overlay.get_node("SkipResponseButton").get("text")) == "结束发动"
	ok = ok and bool(response_slot.get("response_available"))
	response_scene.call("_on_spell_zone_slot_pressed", response_card, response_slot.global_position + Vector2(response_slot.size.x * 0.5, response_slot.size.y + 6.0))
	await process_frame
	ok = ok and response_confirm_panel.visible
	response_preview_text = str(result_preview_label.text)
	ok = ok and response_preview_text.contains("发动护身符后")
	response_scene.call("_on_confirm_cancel")
	await process_frame
	ok = ok and not response_confirm_panel.visible
	response_scene.call("_on_spell_zone_slot_pressed", response_card, response_slot.global_position + Vector2(response_slot.size.x * 0.5, response_slot.size.y + 6.0))
	await process_frame
	response_scene.call("_on_confirm_activate")
	await process_frame
	await process_frame
	ok = ok and not chain_overlay.visible
	ok = ok and response_scene.manager.deck.graveyard.size() >= 1

	var indicator_scene := BattleScene.instantiate()
	root.add_child(indicator_scene)
	indicator_scene.setup("sword")
	var indicator_card: Dictionary = response_card.duplicate(true)
	indicator_card["uid"] = "%s_indicator" % str(indicator_card.get("uid", "response"))
	indicator_card["set_turn"] = 0
	indicator_card["cover_turn"] = 0
	indicator_card["face_down"] = true
	indicator_card["ready"] = true
	indicator_card["sealed"] = false
	indicator_card["already_in_chain"] = false
	indicator_scene.manager.player.spell_zone.append(indicator_card)
	indicator_scene.manager.end_player_turn()
	indicator_scene.render()
	await process_frame
	await process_frame
	var indicator_arrow: Control = indicator_scene.get_node("AttackIndicatorLayer")
	var indicator_enemy_actor: Control = indicator_scene.get_node("EnemyActor")
	var indicator_player_actor: Control = indicator_scene.get_node("PlayerActor")
	ok = ok and indicator_scene.manager.phase == "response"
	ok = ok and indicator_arrow.visible
	ok = ok and str(indicator_enemy_actor.get("combat_highlight_mode")) == "source"
	ok = ok and str(indicator_player_actor.get("combat_highlight_mode")) == "target"

	var equipment_scene := BattleScene.instantiate()
	root.add_child(equipment_scene)
	equipment_scene.setup("sword")
	var equip_sword := CardDatabaseScript.make_card("青锋剑")
	var equip_armor := CardDatabaseScript.make_card("铁木甲")
	var equip_charm := CardDatabaseScript.make_card("养剑匣")
	equipment_scene.manager.deck.hand.append(equip_sword)
	equipment_scene.manager.deck.hand.append(equip_armor)
	equipment_scene.manager.deck.hand.append(equip_charm)
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
	ok = ok and equipment_scene.get_node("ResponseConfirmPanel").visible
	ok = ok and first_equipment.position.x > 0.0
	equipment_scene.call("_on_confirm_activate")
	await process_frame
	await process_frame
	ok = ok and equipment_scene.manager.pending_equipment_replace.is_empty()
	ok = ok and equipment_scene.manager.player.equipment.size() == equipment_scene.manager.player.equipment_limit
	ok = ok and equipment_scene.manager.deck.graveyard.size() >= 1

	var drag_target_scene := BattleScene.instantiate()
	root.add_child(drag_target_scene)
	drag_target_scene.setup("sword")
	var drag_damage_card := CardDatabaseScript.make_card("雷击符")
	drag_target_scene.manager.deck.hand.append(drag_damage_card)
	drag_target_scene.manager.add_enemy_unit({
		"id": "drag_dummy",
		"uid": "drag_dummy",
		"name": "拖拽靶",
		"max_hp": 12,
		"attack": 0,
		"defense": 0,
		"action_sequence": []
	}, 0)
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

	var drag_zone_scene := BattleScene.instantiate()
	root.add_child(drag_zone_scene)
	drag_zone_scene.setup("sword")
	var drag_defense_card := CardDatabaseScript.make_card("护身符")
	drag_zone_scene.manager.deck.hand.append(drag_defense_card)
	drag_zone_scene.render()
	await process_frame
	await process_frame
	var drag_defense_button: Control = drag_zone_scene.call("_find_hand_card_button", str(drag_defense_card.get("uid", ""))) as Control
	var drag_zone_slot: Control = drag_zone_scene.get_node("SpellDefenseZone").get_child(0) as Control
	var drag_zone_started: bool = drag_zone_scene.call("_begin_hand_card_drag", drag_defense_button, drag_defense_button.global_position + Vector2(24.0, 24.0))
	await process_frame
	ok = ok and drag_zone_started
	ok = ok and bool(drag_zone_slot.get("drop_available"))
	drag_zone_scene.call("_finish_hand_card_drag", drag_zone_slot.global_position + drag_zone_slot.size * 0.5)
	await process_frame
	await process_frame
	ok = ok and drag_zone_scene.manager.player.spell_zone.size() == 1
	ok = ok and drag_zone_scene.manager.deck.find_hand_card(str(drag_defense_card.get("uid", ""))).is_empty()

	var drag_equipment_scene := BattleScene.instantiate()
	root.add_child(drag_equipment_scene)
	drag_equipment_scene.setup("sword")
	var drag_equipment_card := CardDatabaseScript.make_card("青锋剑")
	drag_equipment_scene.manager.deck.hand.append(drag_equipment_card)
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
	drag_ally_equipment_scene.manager.add_player_summon({
		"id": "drag_equip_ally",
		"uid": "drag_equip_ally",
		"name": "拖拽装备友军",
		"max_hp": 5,
		"attack": 0,
		"defense": 0
	}, 1)
	var drag_ally_equipment_card := CardDatabaseScript.make_card("铁木甲")
	drag_ally_equipment_scene.manager.deck.hand.append(drag_ally_equipment_card)
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
	ok = ok and drag_ally_unit.equipment.size() == 1
	ok = ok and drag_ally_unit.current_defense() == drag_ally_defense_before + 1
	ok = ok and drag_ally_equipment_scene.manager.deck.find_hand_card(str(drag_ally_equipment_card.get("uid", ""))).is_empty()

	var drag_direct_scene := BattleScene.instantiate()
	root.add_child(drag_direct_scene)
	drag_direct_scene.setup("sword")
	var drag_direct_card := CardDatabaseScript.make_card("起剑诀")
	drag_direct_scene.manager.deck.hand.append(drag_direct_card)
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
	ok = ok and formation_scene.get_node_or_null("BattleDebugTools") != null
	ok = ok and formation_scene.get_node_or_null("DebugToolsToggleButton") != null
	ok = ok and not (formation_scene.get_node("BattleDebugTools") as Control).visible
	formation_scene.call("_on_debug_toggle")
	await process_frame
	ok = ok and (formation_scene.get_node("BattleDebugTools") as Control).visible
	formation_scene.call("_on_debug_toggle")
	await process_frame
	ok = ok and not (formation_scene.get_node("BattleDebugTools") as Control).visible
	var enemy_count_before_debug: int = formation_scene.manager.enemy_target_count()
	formation_scene.call("_on_debug_add_enemy")
	ok = ok and formation_scene.manager.enemy_target_count() == enemy_count_before_debug + 1
	var player_count_before_debug: int = formation_scene.manager.player_target_count()
	formation_scene.call("_on_debug_add_ally")
	ok = ok and formation_scene.manager.player_target_count() == player_count_before_debug + 1
	formation_scene.call("_on_debug_clear_extra_enemies")
	ok = ok and formation_scene.manager.enemy_target_count() == 1
	ok = ok and formation_scene.manager.player_target_count() == 1
	formation_scene.manager.add_enemy_unit({
		"id": "training_dummy",
		"name": "练功桩",
		"max_hp": 12,
		"attack": 0,
		"defense": 0,
		"action_sequence": []
	}, 0)
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
	ok = ok and target_preview_text.contains("练功桩")
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
