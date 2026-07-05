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
	for card_id in ["起剑诀", "小无相剑", "剑心通明", "藏锋"]:
		scene.manager.deck.hand.append(CardDatabaseScript.make_card(card_id))
	scene.render()
	await process_frame
	await process_frame

	var player_actor: Control = scene.get_node("PlayerActor")
	var enemy_actor: Control = scene.get_node("EnemyActor")
	var spell_zone: Control = scene.get_node("SpellDefenseZone")
	var hand_container: Control = scene.get_node("HandContainer")
	var log_panel: Control = scene.get_node("LogPanel")
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
	ok = ok and not scene.has_node("GroundBand")
	ok = ok and not scene.has_node("HandScroll")
	ok = ok and hand_container.global_position.y > 500.0
	ok = ok and player_actor.global_position.x > 240.0
	ok = ok and player_actor.global_position.x < 430.0
	ok = ok and enemy_actor.global_position.x > 1100.0
	ok = ok and second_slot_position.y > first_slot_position.y
	ok = ok and abs(second_slot_position.x - first_slot_position.x) < 8.0
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
	ok = ok and bool(response_slot.get("response_available"))
	response_scene.call("_on_spell_zone_slot_pressed", response_card, response_slot.global_position + Vector2(response_slot.size.x + 6.0, response_slot.size.y * 0.5))
	await process_frame
	ok = ok and response_confirm_panel.visible
	response_scene.call("_on_confirm_cancel")
	await process_frame
	ok = ok and not response_confirm_panel.visible
	response_scene.call("_on_spell_zone_slot_pressed", response_card, response_slot.global_position + Vector2(response_slot.size.x + 6.0, response_slot.size.y * 0.5))
	await process_frame
	response_scene.call("_on_confirm_activate")
	await process_frame
	await process_frame
	ok = ok and not chain_overlay.visible
	ok = ok and response_scene.manager.deck.graveyard.size() >= 1

	var equipment_scene := BattleScene.instantiate()
	root.add_child(equipment_scene)
	equipment_scene.setup("sword")
	var equip_sword := CardDatabaseScript.make_card("青锋剑")
	var equip_armor := CardDatabaseScript.make_card("铁木甲")
	var equip_charm := CardDatabaseScript.make_card("聚灵佩")
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
	ok = ok and first_equipment.global_position.x < (equipment_scene.get_node("PlayerActor") as Control).global_position.x
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

	if ok:
		print("LAYOUT_SMOKE_TEST_OK")
		quit(0)
	else:
		push_error("LAYOUT_SMOKE_TEST_FAILED")
		quit(1)
