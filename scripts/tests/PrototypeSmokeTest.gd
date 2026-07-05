extends SceneTree

const BattleManagerScript = preload("res://scripts/battle/BattleManager.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const RunStateScript = preload("res://scripts/run/RunState.gd")

func _init() -> void:
	var ok := true
	ok = _test_sword_start_and_attack() and ok
	ok = _test_talisman_spell_flow() and ok
	ok = _test_reward_to_next_battle() and ok
	ok = _test_set_defense_ready_on_enemy_turn() and ok
	ok = _test_damage_response_chain() and ok
	ok = _test_skip_response() and ok
	ok = _test_counter_spell_response() and ok
	ok = _test_protect_destroy_response() and ok
	ok = _test_lethal_response() and ok
	ok = _test_equipment_cards() and ok
	ok = _test_equipment_replacement() and ok
	ok = _test_exploration_battle_completion() and ok
	if ok:
		print("PROTOTYPE_SMOKE_TEST_OK")
		quit(0)
	else:
		push_error("PROTOTYPE_SMOKE_TEST_FAILED")
		quit(1)

func _test_sword_start_and_attack() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	if battle.player.job_name != "剑修":
		return false
	if battle.deck.hand.size() != 6:
		return false
	var before_hp: int = battle.enemy.hp
	battle.player_normal_attack()
	if battle.enemy.hp >= before_hp:
		return false
	if battle.player.sword_momentum < 1:
		return false
	return true

func _test_talisman_spell_flow() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("talisman")
	var fireball_uid := ""
	for card in battle.deck.hand:
		if card.get("id", "") == "火球符":
			fireball_uid = str(card.get("uid", ""))
			break
	if fireball_uid == "":
		battle.deck.hand.append(CardDatabaseScript.make_card("火球符"))
		fireball_uid = str(battle.deck.hand.back().get("uid", ""))
	var before_hp: int = battle.enemy.hp
	battle.play_hand_card(fireball_uid)
	return battle.enemy.hp < before_hp and battle.deck.graveyard.size() > 0

func _test_reward_to_next_battle() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	battle.enemy.hp = 1
	battle.player_normal_attack()
	if battle.phase != "reward":
		return false
	if battle.reward_options.size() != 3:
		return false
	var reward_id := str(battle.reward_options[0])
	battle.choose_reward(reward_id)
	return battle.phase == "player" and battle.battle_number == 2

func _test_set_defense_ready_on_enemy_turn() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var hide_blade := CardDatabaseScript.make_card("藏锋")
	battle.deck.hand.append(hide_blade)
	battle.play_hand_card(str(hide_blade.get("uid", "")))
	if battle.player.spell_zone.is_empty() or bool(battle.player.spell_zone[0].get("ready", true)):
		return false
	battle.end_player_turn()
	if battle.phase != "response" or battle.current_event.get("event_type", "") != "player_damage_before":
		return false
	var available := battle.get_available_responses_for_current_event()
	if available.size() != 1 or available[0].get("id", "") != "藏锋":
		return false
	battle.add_card_to_chain(str(available[0].get("uid", "")))
	return battle.phase == "player" and battle.player.sword_momentum >= 1 and battle.deck.graveyard.size() >= 1

func _test_damage_response_chain() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var guard := _ready_defense("护身符")
	var hide_blade := _ready_defense("藏锋")
	battle.player.spell_zone.append(guard)
	battle.player.spell_zone.append(hide_blade)
	var hp_before: int = battle.player.hp
	battle.end_player_turn()
	if battle.phase != "response" or battle.current_event.get("event_type", "") != "player_damage_before":
		return false
	if battle.get_available_responses_for_current_event().size() != 2:
		return false
	battle.add_card_to_chain(str(guard.get("uid", "")))
	if battle.phase != "response":
		return false
	battle.add_card_to_chain(str(hide_blade.get("uid", "")))
	return battle.phase == "player" and battle.player.hp == hp_before and battle.player.sword_momentum >= 1 and battle.deck.graveyard.size() >= 2

func _test_skip_response() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	battle.player.spell_zone.append(_ready_defense("护身符"))
	var hp_before: int = battle.player.hp
	battle.end_player_turn()
	if battle.phase != "response":
		return false
	battle.skip_response()
	return battle.phase == "player" and battle.player.hp < hp_before

func _test_counter_spell_response() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	battle.player.spell_zone.append(_ready_defense("破法符"))
	var hp_before: int = battle.player.hp
	battle.open_timing_window(battle.create_event("enemy_spell_declared", "enemy", "player", 8))
	if battle.phase != "response":
		return false
	battle.add_card_to_chain(str(battle.player.spell_zone[0].get("uid", "")))
	return battle.phase == "player" and battle.player.hp == hp_before and battle.deck.graveyard.size() == 1

func _test_protect_destroy_response() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var target := CardDatabaseScript.make_card("剑心通明")
	target["set_turn"] = 0
	battle.player.spell_zone.append(target)
	battle.player.spell_zone.append(_ready_defense("护心符"))
	battle.open_timing_window(battle.create_event("enemy_destroy_zone_card_declared", "enemy", target, 1))
	if battle.phase != "response":
		return false
	battle.add_card_to_chain(str(battle.player.spell_zone[1].get("uid", "")))
	return battle.phase == "player" and battle.player.spell_zone.size() == 1 and battle.player.spell_zone[0].get("id", "") == "剑心通明"

func _test_lethal_response() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	battle.player.hp = 3
	battle.player.spell_zone.append(_ready_defense("替身纸人"))
	battle.open_timing_window(battle.create_event("player_damage_before", "enemy_attack", "player", 10))
	if battle.phase != "response" or battle.current_event.get("event_type", "") != "player_lethal_damage_before":
		return false
	battle.add_card_to_chain(str(battle.player.spell_zone[0].get("uid", "")))
	return battle.phase == "player" and battle.player.hp == 1 and battle.deck.exile.size() == 1

func _ready_defense(card_id: String) -> Dictionary:
	var card := CardDatabaseScript.make_card(card_id)
	card["set_turn"] = 0
	card["cover_turn"] = 0
	card["face_down"] = true
	card["ready"] = true
	card["sealed"] = false
	card["already_in_chain"] = false
	return card

func _test_equipment_cards() -> bool:
	var attack_battle = BattleManagerScript.new()
	attack_battle.start_run("sword")
	var sword_card := CardDatabaseScript.make_card("青锋剑")
	attack_battle.deck.hand.append(sword_card)
	var attack_before: int = attack_battle.player.current_attack()
	attack_battle.play_hand_card(str(sword_card.get("uid", "")))
	if attack_battle.player.current_attack() != attack_before + 2 or attack_battle.player.equipment.size() != 1:
		return false

	var defense_battle = BattleManagerScript.new()
	defense_battle.start_run("sword")
	var armor_card := CardDatabaseScript.make_card("铁木甲")
	defense_battle.deck.hand.append(armor_card)
	var defense_before: int = defense_battle.player.current_defense()
	defense_battle.play_hand_card(str(armor_card.get("uid", "")))
	if defense_battle.player.current_defense() != defense_before + 1 or defense_battle.player.equipment.size() != 1:
		return false

	var charm_battle = BattleManagerScript.new()
	charm_battle.start_run("sword")
	var charm_card := CardDatabaseScript.make_card("聚灵佩")
	charm_battle.deck.hand.append(charm_card)
	charm_battle.play_hand_card(str(charm_card.get("uid", "")))
	var sword_before: int = charm_battle.player.sword_momentum
	charm_battle.resolver.apply_player_turn_start(charm_battle)
	return charm_battle.player.sword_momentum == sword_before + 1 and charm_battle.player.equipment.size() == 1

func _test_equipment_replacement() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var sword_card := CardDatabaseScript.make_card("青锋剑")
	var armor_card := CardDatabaseScript.make_card("铁木甲")
	var charm_card := CardDatabaseScript.make_card("聚灵佩")
	battle.deck.hand.append(sword_card)
	battle.deck.hand.append(armor_card)
	battle.deck.hand.append(charm_card)
	battle.play_hand_card(str(sword_card.get("uid", "")))
	battle.play_hand_card(str(armor_card.get("uid", "")))
	if battle.player.equipment.size() != battle.player.equipment_limit:
		return false
	var attack_after_sword: int = battle.player.current_attack()
	battle.play_hand_card(str(charm_card.get("uid", "")))
	if battle.pending_equipment_replace.is_empty():
		return false
	if battle.player.equipment.size() != battle.player.equipment_limit:
		return false
	var old_uid := str(battle.player.equipment[0].get("uid", ""))
	battle.choose_equipment_replacement(old_uid)
	if not battle.pending_equipment_replace.is_empty():
		return false
	if battle.player.equipment.size() != battle.player.equipment_limit:
		return false
	if battle.player.has_equipment("青锋剑"):
		return false
	if not battle.player.has_equipment("聚灵佩"):
		return false
	return battle.deck.graveyard.size() >= 1 and battle.player.current_attack() == attack_after_sword - 2

func _test_exploration_battle_completion() -> bool:
	var run_state = RunStateScript.new()
	run_state.start("sword")
	var available := run_state.available_nodes()
	if available.size() < 1:
		return false
	var node: Dictionary = available[0]
	var battle = BattleManagerScript.new()
	battle.start_run_with_deck(run_state.job_id, run_state.deck_ids, run_state.battle_number_for_node(node), "elite", false)
	if battle.auto_advance_after_reward:
		return false
	battle.enemy.hp = 1
	battle.player_normal_attack()
	if battle.phase != "reward" or battle.reward_options.is_empty():
		return false
	var reward_id := str(battle.reward_options[0])
	battle.choose_reward(reward_id)
	if battle.phase != "map_complete" or not battle.master_deck_ids.has(reward_id):
		return false
	run_state.update_deck(battle.master_deck_ids)
	run_state.complete_node(str(node.get("id", "")))
	return run_state.deck_ids.has(reward_id) and run_state.completed_node_ids.has(str(node.get("id", "")))
