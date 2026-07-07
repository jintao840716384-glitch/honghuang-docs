extends SceneTree

const BattleManagerScript = preload("res://scripts/battle/BattleManager.gd")
const EnemyAIControllerScript = preload("res://scripts/battle/EnemyAIController.gd")
const BattleEncounterRuntimeScript = preload("res://scripts/battle/BattleEncounterRuntime.gd")
const BattleUnitScript = preload("res://scripts/battle/BattleUnit.gd")
const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const CardPoolDatabaseScript = preload("res://scripts/data/CardPoolDatabase.gd")
const DeckBuildRulesScript = preload("res://scripts/run/DeckBuildRules.gd")
const CardAcquisitionRulesScript = preload("res://scripts/run/CardAcquisitionRules.gd")
const RewardServiceScript = preload("res://scripts/run/RewardService.gd")
const ExplorationRulesScript = preload("res://scripts/run/ExplorationRules.gd")
const CardInteractionRulesScript = preload("res://scripts/ui/CardInteractionRules.gd")
const BattleAudioRouterScript = preload("res://scripts/ui/BattleAudioRouter.gd")
const CardDisplayRulesScript = preload("res://scripts/ui/CardDisplayRules.gd")
const BattleFloatingTextRulesScript = preload("res://scripts/ui/BattleFloatingTextRules.gd")
const MapModalChoiceFactoryScript = preload("res://scripts/ui/MapModalChoiceFactory.gd")
const VisualAssetDatabaseScript = preload("res://scripts/assets/VisualAssetDatabase.gd")
const CharacterVisualDatabaseScript = preload("res://scripts/assets/CharacterVisualDatabase.gd")
const BattlePresentationRouterScript = preload("res://scripts/assets/BattlePresentationRouter.gd")
const AudioEventDatabaseScript = preload("res://scripts/audio/AudioEventDatabase.gd")
const AudioManagerScript = preload("res://scripts/audio/AudioManager.gd")
const AssetAttributionDatabaseScript = preload("res://scripts/assets/AssetAttributionDatabase.gd")
const GameSettingsScript = preload("res://scripts/settings/GameSettings.gd")
const SettingsStoreScript = preload("res://scripts/settings/SettingsStore.gd")
const DisplayModeManagerScript = preload("res://scripts/settings/DisplayModeManager.gd")
const InputActionDatabaseScript = preload("res://scripts/settings/InputActionDatabase.gd")
const InputSettingsScript = preload("res://scripts/settings/InputSettings.gd")
const LocalizationDatabaseScript = preload("res://scripts/localization/LocalizationDatabase.gd")
const LocalizationServiceScript = preload("res://scripts/localization/LocalizationService.gd")
const SaveMigrationServiceScript = preload("res://scripts/save/SaveMigrationService.gd")
const EnemyDatabaseScript = preload("res://scripts/data/EnemyDatabase.gd")
const CharacterDatabaseScript = preload("res://scripts/data/CharacterDatabase.gd")
const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const RunStateScript = preload("res://scripts/run/RunState.gd")
const MetaProgressionScript = preload("res://scripts/data/MetaProgression.gd")
const ProgressionDatabaseScript = preload("res://scripts/data/ProgressionDatabase.gd")

func _init() -> void:
	var ok := true
	ok = _report_test("_test_sword_start_and_attack", _test_sword_start_and_attack()) and ok
	ok = _report_test("_test_talisman_spell_flow", _test_talisman_spell_flow()) and ok
	ok = _report_test("_test_reward_to_next_battle", _test_reward_to_next_battle()) and ok
	ok = _report_test("_test_set_defense_ready_on_enemy_turn", _test_set_defense_ready_on_enemy_turn()) and ok
	ok = _report_test("_test_damage_response_chain", _test_damage_response_chain()) and ok
	ok = _report_test("_test_counter_lethal_trade_defeats_player", _test_counter_lethal_trade_defeats_player()) and ok
	ok = _report_test("_test_zero_hp_cannot_start_battle", _test_zero_hp_cannot_start_battle()) and ok
	ok = _report_test("_test_skip_response", _test_skip_response()) and ok
	ok = _report_test("_test_counter_spell_response", _test_counter_spell_response()) and ok
	ok = _report_test("_test_protect_destroy_response", _test_protect_destroy_response()) and ok
	ok = _report_test("_test_lethal_response", _test_lethal_response()) and ok
	ok = _report_test("_test_equipment_cards", _test_equipment_cards()) and ok
	ok = _report_test("_test_equipment_replacement", _test_equipment_replacement()) and ok
	ok = _report_test("_test_unit_equipment_targets", _test_unit_equipment_targets()) and ok
	ok = _report_test("_test_unit_equipment_slots", _test_unit_equipment_slots()) and ok
	ok = _report_test("_test_defeated_units_leave_formation", _test_defeated_units_leave_formation()) and ok
	ok = _report_test("_test_deck_build_limits", _test_deck_build_limits()) and ok
	ok = _report_test("_test_sideboard_moves", _test_sideboard_moves()) and ok
	ok = _report_test("_test_card_definition_database_boundary", _test_card_definition_database_boundary()) and ok
	ok = _report_test("_test_ui_interaction_and_audio_boundaries", _test_ui_interaction_and_audio_boundaries()) and ok
	ok = _report_test("_test_visual_and_audio_asset_boundaries", _test_visual_and_audio_asset_boundaries()) and ok
	ok = _report_test("_test_commercial_foundation_boundaries", _test_commercial_foundation_boundaries()) and ok
	ok = _report_test("_test_map_modal_choice_factory_boundary", _test_map_modal_choice_factory_boundary()) and ok
	ok = _report_test("_test_reward_pool_tiers", _test_reward_pool_tiers()) and ok
	ok = _report_test("_test_reward_pool_scopes", _test_reward_pool_scopes()) and ok
	ok = _report_test("_test_card_acquisition_rules_boundary", _test_card_acquisition_rules_boundary()) and ok
	ok = _report_test("_test_exploration_node_types_and_economy", _test_exploration_node_types_and_economy()) and ok
	ok = _report_test("_test_boss_settlement_and_meta_progression", _test_boss_settlement_and_meta_progression()) and ok
	ok = _report_test("_test_progression_database_boundary", _test_progression_database_boundary()) and ok
	ok = _report_test("_test_failed_run_settlement", _test_failed_run_settlement()) and ok
	ok = _report_test("_test_exploration_battle_completion", _test_exploration_battle_completion()) and ok
	ok = _report_test("_test_battle_unit_framework", _test_battle_unit_framework()) and ok
	ok = _report_test("_test_battle_side_framework", _test_battle_side_framework()) and ok
	ok = _report_test("_test_enemy_card_packages", _test_enemy_card_packages()) and ok
	ok = _report_test("_test_enemy_encounter_architecture", _test_enemy_encounter_architecture()) and ok
	ok = _report_test("_test_battle_encounter_runtime_boundary", _test_battle_encounter_runtime_boundary()) and ok
	ok = _report_test("_test_job_database_uses_character_pool", _test_job_database_uses_character_pool()) and ok
	ok = _report_test("_test_effect_steps_and_enemy_skill", _test_effect_steps_and_enemy_skill()) and ok
	ok = _report_test("_test_target_selection_for_multi_enemy", _test_target_selection_for_multi_enemy()) and ok
	ok = _report_test("_test_summon_and_enemy_target_pool", _test_summon_and_enemy_target_pool()) and ok
	ok = _report_test("_test_player_unit_actions", _test_player_unit_actions()) and ok
	ok = _report_test("_test_enemy_ai_controller_boundary", _test_enemy_ai_controller_boundary()) and ok
	ok = _report_test("_test_enemy_side_action_sequence", _test_enemy_side_action_sequence()) and ok
	ok = _report_test("_test_ally_damage_response_scope", _test_ally_damage_response_scope()) and ok
	ok = _report_test("_test_common_status_and_zone_cards", _test_common_status_and_zone_cards()) and ok
	if ok:
		print("PROTOTYPE_SMOKE_TEST_OK")
		quit(0)
	else:
		push_error("PROTOTYPE_SMOKE_TEST_FAILED")
		quit(1)

func _report_test(test_name: String, passed: bool) -> bool:
	if not passed:
		push_error("%s failed" % test_name)
	return passed

func _test_sword_start_and_attack() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	if battle.player.job_name != "剑修":
		return false
	if battle.deck.hand.size() != 5:
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
	battle.enemy.defense = 2
	var fireball_uid := ""
	for card in battle.deck.hand:
		if card.get("id", "") == "火球符":
			fireball_uid = str(card.get("uid", ""))
			break
	if fireball_uid == "":
		battle.deck.hand.append(CardDatabaseScript.make_card("火球符"))
		fireball_uid = str(battle.deck.hand.back().get("uid", ""))
	var before_hp: int = battle.enemy.hp
	var expected_damage: int = max(0, 4 - battle.enemy.current_defense())
	battle.play_hand_card(fireball_uid)
	return battle.enemy.hp == before_hp - expected_damage and battle.deck.graveyard.size() > 0

func _test_reward_to_next_battle() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	battle.enemy.hp = 1
	for i in range(1, battle.formation.enemy_units.size()):
		var extra_enemy = battle.formation.enemy_units[i]
		if extra_enemy != null:
			extra_enemy.hp = 0
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
	var enemy_hp_before: int = battle.enemy.hp
	battle.add_card_to_chain(str(available[0].get("uid", "")))
	return battle.phase == "player" and battle.enemy.hp < enemy_hp_before and battle.deck.graveyard.size() >= 1

func _test_damage_response_chain() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var guard := _ready_defense("护身符")
	var hide_blade := _ready_defense("藏锋")
	battle.player.spell_zone.append(guard)
	battle.player.spell_zone.append(hide_blade)
	var hp_before: int = battle.player.hp
	var enemy_hp_before: int = battle.enemy.hp
	var expected_damage: int = max(0, battle.enemy.current_attack() - battle.player.current_defense() - 4)
	battle.end_player_turn()
	if battle.phase != "response" or battle.current_event.get("event_type", "") != "player_damage_before":
		return false
	if battle.get_available_responses_for_current_event().size() != 2:
		return false
	battle.add_card_to_chain(str(guard.get("uid", "")))
	if battle.phase != "response":
		return false
	battle.add_card_to_chain(str(hide_blade.get("uid", "")))
	return battle.phase == "player" and battle.player.hp == hp_before - expected_damage and battle.enemy.hp < enemy_hp_before and battle.deck.graveyard.size() >= 2

func _test_counter_lethal_trade_defeats_player() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	battle.player.hp = 3
	battle.enemy.hp = 3
	var hide_blade := _ready_defense("藏锋")
	battle.player.spell_zone.append(hide_blade)
	var damage_event: Dictionary = battle.create_event("player_damage_before", "enemy_attack", battle.player, 5)
	damage_event["attack_source_key"] = "enemy"
	battle.open_timing_window(damage_event)
	if battle.phase != "response":
		return false
	battle.add_card_to_chain(str(hide_blade.get("uid", "")))
	return battle.phase == "defeat" and battle.player.hp == 0 and battle.enemy.hp == 0 and battle.reward_options.is_empty()

func _test_zero_hp_cannot_start_battle() -> bool:
	var run_state = RunStateScript.new()
	run_state.start("sword")
	run_state.update_life(0)
	if not run_state.available_nodes().is_empty():
		return false
	if run_state.battle_start_block_reason() == "":
		return false
	var battle = BattleManagerScript.new()
	battle.start_run_with_deck("sword", run_state.deck_ids, 1, "normal", false, run_state.run_context())
	return battle.phase == "defeat" and battle.player.hp == 0 and battle.deck.hand.is_empty()

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
	var target := CardDatabaseScript.make_card("封存秘卷")
	target["set_turn"] = 0
	battle.player.spell_zone.append(target)
	battle.player.spell_zone.append(_ready_defense("护心符"))
	battle.open_timing_window(battle.create_event("enemy_destroy_zone_card_declared", "enemy", target, 1))
	if battle.phase != "response":
		return false
	battle.add_card_to_chain(str(battle.player.spell_zone[1].get("uid", "")))
	return battle.phase == "player" and battle.player.spell_zone.size() == 1 and battle.player.spell_zone[0].get("id", "") == "封存秘卷"

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
	var charm_card := CardDatabaseScript.make_card("养剑匣")
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
	var charm_card := CardDatabaseScript.make_card("养剑匣")
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
	if not battle.player.has_equipment("养剑匣"):
		return false
	return battle.deck.graveyard.size() >= 1 and battle.player.current_attack() == attack_after_sword - 2

func _test_unit_equipment_targets() -> bool:
	var ally_battle = BattleManagerScript.new()
	ally_battle.start_run("sword")
	if not ally_battle.add_player_summon({"id": "equip_ally", "uid": "equip_ally", "name": "装备测试友军", "max_hp": 5, "attack": 0, "defense": 0}, 1):
		return false
	var ally = ally_battle.formation.living_unit_by_uid("player", "equip_ally")
	if ally == null:
		return false
	var sword_card := CardDatabaseScript.make_card("青锋剑")
	ally_battle.deck.hand.append(sword_card)
	var ally_attack_before: int = ally.current_attack()
	var player_attack_before: int = ally_battle.player.current_attack()
	ally_battle.play_hand_card_on_unit_target(str(sword_card.get("uid", "")), str(ally.uid))
	if ally.equipment.size() != 1 or ally.current_attack() != ally_attack_before + 2:
		return false
	if ally_battle.player.current_attack() != player_attack_before:
		return false
	if not ally_battle.deck.find_hand_card(str(sword_card.get("uid", ""))).is_empty():
		return false

	var enemy_battle = BattleManagerScript.new()
	enemy_battle.start_run("sword")
	var armor_card := CardDatabaseScript.make_card("铁木甲")
	enemy_battle.deck.hand.append(armor_card)
	var enemy_defense_before: int = enemy_battle.enemy.current_defense()
	enemy_battle.play_hand_card_on_unit_target(str(armor_card.get("uid", "")), str(enemy_battle.enemy.uid))
	if enemy_battle.enemy.equipment.size() != 1 or enemy_battle.enemy.current_defense() != enemy_defense_before + 1:
		return false

	var replace_battle = BattleManagerScript.new()
	replace_battle.start_run("sword")
	if not replace_battle.add_player_summon({"id": "replace_ally", "uid": "replace_ally", "name": "替换测试友军", "max_hp": 5, "attack": 0, "defense": 0}, 1):
		return false
	var replace_ally = replace_battle.formation.living_unit_by_uid("player", "replace_ally")
	var replace_sword := CardDatabaseScript.make_card("青锋剑")
	var replace_armor := CardDatabaseScript.make_card("铁木甲")
	replace_battle.deck.hand.append(replace_sword)
	replace_battle.deck.hand.append(replace_armor)
	replace_battle.play_hand_card_on_unit_target(str(replace_sword.get("uid", "")), str(replace_ally.uid))
	var replace_attack_after_sword: int = replace_ally.current_attack()
	replace_battle.play_hand_card_on_unit_target(str(replace_armor.get("uid", "")), str(replace_ally.uid))
	if replace_battle.pending_equipment_replace.is_empty():
		return false
	if str(replace_battle.pending_equipment_replace.get("target_uid", "")) != str(replace_ally.uid):
		return false
	var old_uid := str(replace_ally.equipment[0].get("uid", ""))
	replace_battle.choose_equipment_replacement(old_uid)
	if not replace_battle.pending_equipment_replace.is_empty():
		return false
	if replace_ally.equipment.size() != 1 or not replace_ally.has_equipment("铁木甲"):
		return false
	return replace_ally.current_attack() == replace_attack_after_sword - 2 and replace_ally.current_defense() == 1 and replace_battle.deck.graveyard.size() >= 1

func _test_unit_equipment_slots() -> bool:
	var normal_battle = BattleManagerScript.new()
	normal_battle.start_run_with_deck("sword", ["起剑诀", "青锋剑", "铁木甲", "小无相剑", "藏锋", "护身符", "雷击符", "火球符", "裂石符", "幻象术"], 1, "normal")
	if normal_battle.enemy.unit_rank != "normal" or normal_battle.enemy.equipment_limit != 1:
		return false
	if normal_battle.player.equipment_limit != 2:
		return false
	var elite_battle = BattleManagerScript.new()
	elite_battle.start_run_with_deck("sword", ["起剑诀", "青锋剑", "铁木甲", "小无相剑", "藏锋", "护身符", "雷击符", "火球符", "裂石符", "幻象术"], 1, "elite")
	if elite_battle.enemy.unit_rank != "elite" or elite_battle.enemy.equipment_limit != 2:
		return false
	var boss_battle = BattleManagerScript.new()
	boss_battle.start_run_with_deck("sword", ["起剑诀", "青锋剑", "铁木甲", "小无相剑", "藏锋", "护身符", "雷击符", "火球符", "裂石符", "幻象术"], 1, "boss")
	if boss_battle.enemy.unit_rank != "boss" or boss_battle.enemy.equipment_limit != 3:
		return false
	if not boss_battle.add_player_summon({"id": "slot_test", "uid": "slot_test", "name": "装备槽测试", "max_hp": 1, "attack": 0, "defense": 0}):
		return false
	var summon = boss_battle.formation.living_unit_by_uid("player", "slot_test")
	return summon != null and summon.unit_rank == "normal" and summon.equipment_limit == 1

func _test_defeated_units_leave_formation() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	if not battle.add_player_summon({"id": "retreat_ally", "uid": "retreat_ally", "name": "退场测试友军", "max_hp": 1, "attack": 0, "defense": 0}, 1):
		return false
	var ally = battle.formation.living_unit_by_uid("player", "retreat_ally")
	battle.apply_damage_to_unit(ally, 5, "测试")
	battle.check_victory_or_defeat()
	if battle.formation.unit_by_uid("retreat_ally") != null:
		return false
	if not battle.add_player_summon({"id": "retreat_ally_new", "uid": "retreat_ally_new", "name": "退场后新友军", "max_hp": 1, "attack": 0, "defense": 0}, 1):
		return false
	if not battle.add_enemy_unit({"id": "retreat_enemy", "uid": "retreat_enemy", "name": "退场测试敌人", "max_hp": 1, "attack": 0, "defense": 0, "action_sequence": []}, 1):
		return false
	var enemy_unit = battle.formation.living_unit_by_uid("enemy", "retreat_enemy")
	battle.apply_damage_to_unit(enemy_unit, 5, "测试")
	battle.check_victory_or_defeat()
	if battle.formation.unit_by_uid("retreat_enemy") != null:
		return false
	return battle.add_enemy_unit({"id": "retreat_enemy_new", "uid": "retreat_enemy_new", "name": "退场后新敌人", "max_hp": 1, "attack": 0, "defense": 0, "action_sequence": []}, 1)

func _test_deck_build_limits() -> bool:
	var deck_ids := ["火球符", "火球符", "火球符"]
	if not DeckBuildRulesScript.can_add_card_to_deck("火球符", deck_ids, 0):
		return false
	if not DeckBuildRulesScript.can_add_card_to_deck("雷击符", deck_ids, 20):
		return false
	if DeckBuildRulesScript.can_add_card_to_deck("一剑开天", deck_ids, DeckBuildRulesScript.deck_score(deck_ids) + DeckBuildRulesScript.card_score("一剑开天") - 1):
		return false
	var full_deck: Array = []
	for i in range(DeckBuildRulesScript.max_deck_size()):
		full_deck.append("火球符")
	if DeckBuildRulesScript.can_add_card_to_deck("雷击符", full_deck, 0):
		return false
	var run_state = RunStateScript.new()
	run_state.start("sword")
	var ok: bool = DeckBuildRulesScript.deck_score(run_state.deck_ids) <= run_state.deck_score_limit
	ok = ok and run_state.deck_ids.size() >= DeckBuildRulesScript.min_deck_size()
	ok = ok and run_state.deck_ids.size() <= DeckBuildRulesScript.max_deck_size()
	ok = ok and run_state.deck_build_block_reason([]) != ""
	ok = ok and run_state.deck_build_block_reason([]) == DeckBuildRulesScript.deck_build_block_reason([], run_state.deck_score_limit)
	ok = ok and run_state.deck_build_block_reason(run_state.deck_ids) == ""
	return ok

func _test_sideboard_moves() -> bool:
	var run_state = RunStateScript.new()
	run_state.start("sword")
	var deck_size_before: int = run_state.deck_ids.size()
	if run_state.move_deck_card_to_reserve(0) != "":
		return false
	if run_state.deck_ids.size() != deck_size_before - 1 or run_state.reserve_ids.size() != 1:
		return false
	if run_state.apply_deck_build(run_state.deck_ids, run_state.reserve_ids) == "":
		return false
	var reason: String = run_state.move_reserve_card_to_deck(0)
	if reason != "" or run_state.deck_ids.size() != deck_size_before or not run_state.reserve_ids.is_empty():
		return false
	var over_deck: Array = run_state.deck_ids.duplicate()
	for i in range(DeckBuildRulesScript.max_deck_size() - over_deck.size() + 1):
		over_deck.append("火球符")
	if run_state.apply_deck_build(over_deck, []) == "":
		return false
	var full_deck: Array = []
	for i in range(DeckBuildRulesScript.max_deck_size()):
		full_deck.append("火球符")
	var battle = BattleManagerScript.new()
	battle.start_run_with_deck("sword", full_deck, 1, "normal", false, {"deck_score_limit": 999})
	battle.phase = "reward"
	battle.reward_options = ["雷击符"]
	battle.choose_reward("雷击符")
	return battle.phase == "map_complete" and battle.master_reserve_ids.has("雷击符")

func _test_card_definition_database_boundary() -> bool:
	var common_pool: Array = CardPoolDatabaseScript.common_pool()
	if common_pool.is_empty():
		return false
	var card_id := str(common_pool[0])
	var raw_card: Dictionary = CardDefinitionDatabaseScript.get_card(card_id)
	if raw_card.is_empty():
		return false
	if raw_card.has("unlock_pack") or raw_card.has("default_unlocked"):
		return false
	var compatible_card: Dictionary = CardDatabaseScript.get_card(card_id)
	if compatible_card.is_empty():
		return false
	if not compatible_card.has("unlock_pack") or not compatible_card.has("default_unlocked"):
		return false
	if CardDatabaseScript.card_score(card_id) != CardDefinitionDatabaseScript.card_score(card_id):
		return false
	return CardPoolDatabaseScript.reward_pool_for_job("sword", "normal", 0).has(card_id)

func _test_ui_interaction_and_audio_boundaries() -> bool:
	var defense_card := {
		"type": CardDefinitionDatabaseScript.TYPE_DEFENSE,
		"after_use": "graveyard",
		"effect": {}
	}
	var equipment_card := {
		"type": CardDefinitionDatabaseScript.TYPE_SPELL,
		"after_use": "equipment",
		"effect": {}
	}
	var targeted_card := {
		"type": CardDefinitionDatabaseScript.TYPE_SPELL,
		"after_use": "graveyard",
		"effect": {
			"kind": "multi",
			"effects": [
				{"kind": "draw", "value": 1},
				{"kind": "direct_damage", "value": 2}
			]
		}
	}
	var direct_card := {
		"type": CardDefinitionDatabaseScript.TYPE_SPELL,
		"after_use": "graveyard",
		"effect": {"kind": "draw", "value": 1}
	}
	if CardInteractionRulesScript.card_drag_rule(defense_card) != "spell_zone":
		return false
	if CardInteractionRulesScript.card_drag_rule(equipment_card) != "unit_equipment":
		return false
	if CardInteractionRulesScript.card_drag_rule(targeted_card) != "enemy_unit":
		return false
	if CardInteractionRulesScript.card_drag_rule(direct_card) != "direct":
		return false
	if CardInteractionRulesScript.hand_button_prefix_for_card(defense_card) == "":
		return false
	if CardDisplayRulesScript.card_type_label(equipment_card) == "":
		return false
	if CardDisplayRulesScript.card_type_text(targeted_card, 2) == "":
		return false
	if CardDisplayRulesScript.tags_text(direct_card) == "":
		return false
	var defense_palette: Dictionary = CardDisplayRulesScript.card_palette(defense_card)
	if not defense_palette.has("bg") or not defense_palette.has("border") or not defense_palette.has("name_color"):
		return false
	var slot_palette: Dictionary = CardDisplayRulesScript.zone_slot_palette(equipment_card, true, false)
	if not slot_palette.has("bg") or not slot_palette.has("border"):
		return false
	var audio_events: Array = BattleAudioRouterScript.events_for_combat_event({"type": "damage_applied"})
	if audio_events.size() != 1 or str(audio_events[0]) != "hit":
		return false
	if not BattleAudioRouterScript.events_for_combat_event({"type": "turn_started"}).is_empty():
		return false
	var floating_entries: Array = BattleFloatingTextRulesScript.entries_for_combat_event({
		"type": "damage_applied",
		"target": "enemy",
		"value": 3
	})
	if floating_entries.size() != 1:
		return false
	var floating_entry: Dictionary = floating_entries[0]
	if str(floating_entry.get("target", "")) != "enemy" or str(floating_entry.get("text", "")) != "-3":
		return false
	return BattleFloatingTextRulesScript.entries_for_combat_event({"type": "turn_started"}).is_empty()

func _test_visual_and_audio_asset_boundaries() -> bool:
	if not VisualAssetDatabaseScript.category_ids().has(VisualAssetDatabaseScript.CATEGORY_UI_TEXTURE):
		return false
	if not VisualAssetDatabaseScript.category_ids().has(VisualAssetDatabaseScript.CATEGORY_CHARACTER_SPRITE):
		return false
	if not VisualAssetDatabaseScript.category_ids().has(VisualAssetDatabaseScript.CATEGORY_BATTLE_ANIMATION):
		return false
	if not VisualAssetDatabaseScript.category_ids().has(VisualAssetDatabaseScript.CATEGORY_ICON):
		return false
	if not VisualAssetDatabaseScript.has_asset("character.sword.portrait"):
		return false
	var sword_profile: Dictionary = CharacterVisualDatabaseScript.profile("sword")
	if str(sword_profile.get("portrait_asset_id", "")) != "character.sword.portrait":
		return false
	var sword_character: Dictionary = CharacterDatabaseScript.character_template("sword")
	var sword_unit = BattleUnitScript.new()
	sword_unit.setup_unit(sword_character)
	if str(sword_unit.visual_profile_id) != "sword":
		return false
	var unit_profile: Dictionary = CharacterVisualDatabaseScript.profile_for_unit_data(sword_character)
	if str(unit_profile.get("battle_animation_asset_id", "")) == "":
		return false
	var presentation_actions: Array = BattlePresentationRouterScript.actions_for_combat_event({
		"type": "attack_started",
		"source": "player",
		"target": "enemy"
	})
	if presentation_actions.size() < 2:
		return false
	if str((presentation_actions[0] as Dictionary).get("kind", "")) != BattlePresentationRouterScript.ACTION_ACTOR_ANIMATION:
		return false
	if not AudioEventDatabaseScript.has_event("attack") or not AudioEventDatabaseScript.has_event("ui_click"):
		return false
	if not AudioEventDatabaseScript.event_ids_for_category(AudioEventDatabaseScript.CATEGORY_MUSIC).has("music.battle"):
		return false
	if AudioEventDatabaseScript.cooldown_ms("hit") <= 0:
		return false
	return true

func _test_commercial_foundation_boundaries() -> bool:
	var settings: Dictionary = GameSettingsScript.default_data()
	var sanitized: Dictionary = GameSettingsScript.sanitize({
		"display": {"resolution_id": "bad", "window_mode": "invalid", "vsync_enabled": true},
		"audio": {"master_volume": 2.0, "music_volume": -1.0, "sfx_volume": 0.5},
		"gameplay": {"animation_speed": 9.0},
		"accessibility": {"reduce_motion": true, "text_scale": 3.0}
	})
	var audio: Dictionary = GameSettingsScript.audio_settings(sanitized)
	if float(audio.get("master_volume", 0.0)) != 1.0 or float(audio.get("music_volume", 1.0)) != 0.0:
		return false
	var localization: Dictionary = GameSettingsScript.localization_settings(sanitized)
	if str(localization.get("language_id", "")) != LocalizationDatabaseScript.DEFAULT_LANGUAGE_ID:
		return false
	var english_settings: Dictionary = SettingsStoreScript.set_language_id(settings, "en_us")
	if LocalizationServiceScript.text_for_settings("menu.start_game", english_settings) != "Start Game":
		return false
	if LocalizationServiceScript.text_for_settings("settings.master_volume", english_settings, {"percent": 50}) != "Master Volume  50%":
		return false
	if LocalizationServiceScript.text("missing.text.id", "en_us") != "missing.text.id":
		return false
	var config := ConfigFile.new()
	SaveMigrationServiceScript.apply_config_metadata(config, SaveMigrationServiceScript.SAVE_KIND_SETTINGS)
	if SaveMigrationServiceScript.config_schema_version(config, SaveMigrationServiceScript.SAVE_KIND_SETTINGS) != SaveMigrationServiceScript.CURRENT_SETTINGS_VERSION:
		return false
	var migrated_settings: Dictionary = SaveMigrationServiceScript.migrate_settings({"audio": {"master_volume": 9.0}, "localization": {"language_id": "bad"}}, 0)
	var migrated_audio: Dictionary = GameSettingsScript.audio_settings(migrated_settings)
	if float(migrated_audio.get("master_volume", 0.0)) != 1.0:
		return false
	var migrated_progression: Dictionary = SaveMigrationServiceScript.migrate_meta_progression({
		"version": 1,
		"jobs": {
			"sword": {
				"points_total": -5,
				"points_spent": 3,
				"upgrades": {"attack": -2, "max_hp": 1}
			}
		}
	})
	if int(migrated_progression.get("version", 0)) != SaveMigrationServiceScript.CURRENT_META_PROGRESSION_VERSION:
		return false
	var migrated_sword: Dictionary = ((migrated_progression.get("jobs", {}) as Dictionary).get("sword", {}) as Dictionary)
	var migrated_upgrades: Dictionary = (migrated_sword.get("upgrades", {}) as Dictionary)
	if int(migrated_sword.get("points_total", -1)) != 0 or int(migrated_upgrades.get("attack", -1)) != 0:
		return false
	var display: Dictionary = DisplayModeManagerScript.normalized_display_settings(settings)
	if str(display.get("aspect_policy", "")) != DisplayModeManagerScript.ASPECT_POLICY:
		return false
	if DisplayModeManagerScript.resolution_size("1920x1080") != Vector2i(1920, 1080):
		return false
	if not DisplayModeManagerScript.resolution_ids().has("2560x1440"):
		return false
	if InputActionDatabaseScript.action_definition("end_turn").is_empty():
		return false
	if InputActionDatabaseScript.actions_for_category(InputActionDatabaseScript.CATEGORY_CARD_SHORTCUT).size() != 10:
		return false
	InputSettingsScript.apply_default_bindings()
	if InputSettingsScript.binding_count("end_turn") <= 0:
		return false
	var custom_event := InputEventKey.new()
	custom_event.keycode = KEY_Q
	var custom_spec: Dictionary = InputActionDatabaseScript.spec_from_event(custom_event)
	if str(InputActionDatabaseScript.binding_label(custom_spec)) != "Q":
		return false
	var custom_input_settings: Dictionary = SettingsStoreScript.set_action_binding(settings, "end_turn", custom_spec)
	if InputSettingsScript.binding_label_for_action(custom_input_settings, "end_turn") != "Q":
		return false
	InputSettingsScript.apply_bindings(InputSettingsScript.settings_bindings(custom_input_settings))
	if InputSettingsScript.binding_count("end_turn") != 1:
		return false
	var default_input_settings: Dictionary = SettingsStoreScript.reset_action_binding(custom_input_settings, "end_turn")
	if InputSettingsScript.binding_label_for_action(default_input_settings, "end_turn") == "Q":
		return false
	var updated_settings: Dictionary = SettingsStoreScript.set_audio_volume(settings, "master_volume", 0.25)
	var updated_audio: Dictionary = GameSettingsScript.audio_settings(updated_settings)
	if abs(float(updated_audio.get("master_volume", 0.0)) - 0.25) > 0.001:
		return false
	if not AudioEventDatabaseScript.event_ids_for_category(AudioEventDatabaseScript.CATEGORY_MUSIC).has("music.main_menu"):
		return false
	var audio_manager = AudioManagerScript.new()
	audio_manager.set_sfx_volume(0.35)
	if abs(float(audio_manager.sfx_volume) - 0.35) > 0.001:
		audio_manager.free()
		return false
	audio_manager.free()
	if not AssetAttributionDatabaseScript.has_commercial_clearance("ui.default_background"):
		return false
	return AssetAttributionDatabaseScript.unknown_assets(["unknown.asset"]).size() == 1

func _test_map_modal_choice_factory_boundary() -> bool:
	var parent := VBoxContainer.new()
	var grid: GridContainer = MapModalChoiceFactoryScript.create_card_grid(parent, 2)
	if grid == null or grid.columns != 2 or parent.get_child_count() != 1:
		parent.free()
		return false
	if not MapModalChoiceFactoryScript.add_reward_choice(grid, "test_reward", "test", "test", "test", func() -> void:
		pass
	):
		parent.free()
		return false
	var card_ids: Array = CardDatabaseScript.get_cards().keys()
	if card_ids.is_empty():
		parent.free()
		return false
	var first_card_id := str(card_ids[0])
	if not MapModalChoiceFactoryScript.add_card_choice(grid, first_card_id, "test", func(_card_id: String) -> void:
		pass
	):
		parent.free()
		return false
	var ok := grid.get_child_count() == 2
	parent.free()
	return ok

func _test_reward_pool_tiers() -> bool:
	var default_sword_packs := CardPoolDatabaseScript.unlocked_packs_for_job("sword", 0)
	var full_sword_packs := CardPoolDatabaseScript.unlocked_packs_for_job("sword", 2)
	var normal_pool := CardPoolDatabaseScript.reward_pool_for_job("sword", "normal", 0)
	var elite_pool := CardPoolDatabaseScript.reward_pool_for_job("sword", "elite", 0)
	var locked_boss_pool := CardPoolDatabaseScript.reward_pool_for_job("sword", "boss", 0)
	var unlocked_boss_pool := CardPoolDatabaseScript.reward_pool_for_job("sword", "boss", 2)
	if normal_pool.is_empty() or elite_pool.is_empty() or locked_boss_pool.is_empty() or unlocked_boss_pool.is_empty():
		return false
	if not default_sword_packs.has("common_1") or not default_sword_packs.has("sword_1") or default_sword_packs.has("common_2"):
		return false
	if not full_sword_packs.has("common_3") or not full_sword_packs.has("sword_3"):
		return false
	if normal_pool.has("一剑开天"):
		return false
	if locked_boss_pool.has("一剑开天"):
		return false
	if not unlocked_boss_pool.has("一剑开天"):
		return false
	var pack_slots: Array = CardPoolDatabaseScript.pack_ids_for_job("sword")
	var pack_counts: Dictionary = CardPoolDatabaseScript.pack_card_counts_for_job("sword")
	if not pack_slots.has("common_5") or not pack_slots.has("sword_5"):
		return false
	if int(pack_counts.get("common_4", -1)) != 0 or int(pack_counts.get("sword_4", -1)) != 0:
		return false
	return CardPoolDatabaseScript.card_unlock_tier("一剑开天") == 2 and CardPoolDatabaseScript.card_unlock_pack("一剑开天") == "sword_3" and CardPoolDatabaseScript.card_unlock_pack("火球符") == "common_1" and CardPoolDatabaseScript.card_unlock_pack("雷击符") == "common_2" and CardPoolDatabaseScript.card_unlock_pack("护心镜") == "common_3" and CardDatabaseScript.get_card("火球符").get("default_unlocked", false)

func _test_reward_pool_scopes() -> bool:
	var talisman_pool := CardPoolDatabaseScript.reward_pool_for_job("talisman", "boss", 2)
	if talisman_pool.has("养剑匣"):
		return false
	var sword_job_pool := CardPoolDatabaseScript.job_pool("sword")
	var talisman_job_pool := CardPoolDatabaseScript.job_pool("talisman")
	return sword_job_pool.has("养剑匣") and not talisman_job_pool.has("养剑匣")

func _test_card_acquisition_rules_boundary() -> bool:
	var deck_ids := ["青锋剑", "起剑诀", "藏锋", "疾剑诀", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣"]
	var deck_result: Dictionary = CardAcquisitionRulesScript.card_gain_result("火球符", deck_ids, 20)
	if str(deck_result.get("destination", "")) != "deck":
		return false
	var full_deck := ["青锋剑", "起剑诀", "藏锋", "疾剑诀", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符", "回春符", "金刃符", "小还丹", "固元符", "换气符", "破甲符", "缚身符", "护阵符", "反震符", "封藏符"]
	var reserve_result: Dictionary = CardAcquisitionRulesScript.card_gain_result("护心镜", full_deck, 20)
	if str(reserve_result.get("destination", "")) != "reserve":
		return false
	var compatibility_result: Dictionary = RewardServiceScript.card_gain_result("护心镜", full_deck, 20)
	return str(compatibility_result.get("destination", "")) == str(reserve_result.get("destination", ""))

func _test_exploration_node_types_and_economy() -> bool:
	var run_state = RunStateScript.new()
	run_state.start("sword")
	var has_event := false
	var has_treasure := false
	var has_shop := false
	var has_rest := false
	for node in run_state.map_nodes:
		match str(node.get("type", "")):
			"event":
				has_event = true
			"treasure":
				has_treasure = true
			"shop":
				has_shop = true
			"rest":
				has_rest = true
	if not (has_event and has_treasure and has_shop and has_rest):
		return false
	var normal_node := {"type": "normal"}
	var elite_node := {"type": "elite"}
	if run_state.battle_spirit_reward(elite_node) <= run_state.battle_spirit_reward(normal_node):
		return false
	if run_state.battle_spirit_reward(elite_node) != RewardServiceScript.battle_spirit_reward(run_state.realm_index, elite_node):
		return false
	if run_state.cultivation_reward_for_node({"type": "treasure"}) != RewardServiceScript.cultivation_reward_for_node({"type": "treasure"}):
		return false
	if run_state.cultivation_reward_for_node({"type": "treasure"}) != ExplorationRulesScript.cultivation_reward_for_node({"type": "treasure"}):
		return false
	var gain_result: Dictionary = RewardServiceScript.card_gain_result("雷击符", run_state.deck_ids, run_state.deck_score_limit)
	if not ["deck", "reserve"].has(str(gain_result.get("destination", ""))):
		return false
	var minor_offer: Dictionary = run_state.minor_event_offer()
	if not ["stone", "card"].has(str(minor_offer.get("kind", ""))):
		return false
	run_state.reserve_ids.append("雷击符")
	var trade_offer: Dictionary = run_state.trade_event_offer()
	if (trade_offer.get("stone_option", {}) as Dictionary).is_empty():
		return false
	if (trade_offer.get("hp_option", {}) as Dictionary).is_empty():
		return false
	if (trade_offer.get("fallback_option", {}) as Dictionary).is_empty():
		return false
	if int((trade_offer.get("exchange_option", {}) as Dictionary).get("reserve_index", -1)) < 0:
		return false
	var stones_before_event: int = run_state.spirit_stones
	var event_stone_result: Dictionary = run_state.apply_event_stone_reward(5, "事件：获得 %d 灵石。")
	if not bool(event_stone_result.get("success", false)) or run_state.spirit_stones != stones_before_event + 5:
		return false
	var total_cards_before_event: int = run_state.deck_ids.size() + run_state.reserve_ids.size()
	var event_card_result: Dictionary = run_state.apply_event_card_reward("火球符", "事件")
	if not bool(event_card_result.get("success", false)) or run_state.deck_ids.size() + run_state.reserve_ids.size() != total_cards_before_event + 1:
		return false
	var hp_before_trade: int = run_state.current_hp
	var hp_trade_result: Dictionary = run_state.apply_trade_hp_reward(1, "火球符")
	if not bool(hp_trade_result.get("success", false)) or run_state.current_hp != hp_before_trade - 1:
		return false
	var exchange_option: Dictionary = (trade_offer.get("exchange_option", {}) as Dictionary)
	var total_cards_before_exchange: int = run_state.deck_ids.size() + run_state.reserve_ids.size()
	var reserve_trade_result: Dictionary = run_state.apply_trade_reserve_reward(
		int(exchange_option.get("reserve_index", -1)),
		str(exchange_option.get("offered_id", "")),
		str(exchange_option.get("card_id", ""))
	)
	if not bool(reserve_trade_result.get("success", false)) or run_state.deck_ids.size() + run_state.reserve_ids.size() != total_cards_before_exchange:
		return false
	var treasure_rewards := run_state.treasure_card_rewards()
	if treasure_rewards.size() < 1:
		return false
	for treasure_card_id in treasure_rewards:
		if CardDatabaseScript.get_card(str(treasure_card_id)).is_empty():
			return false
		if CardPoolDatabaseScript.sell_price(str(treasure_card_id)) <= 0:
			return false
	var total_cards_before_treasure: int = run_state.deck_ids.size() + run_state.reserve_ids.size()
	var treasure_result: Dictionary = run_state.apply_treasure_card_reward(str(treasure_rewards[0]))
	if not bool(treasure_result.get("success", false)) or run_state.deck_ids.size() + run_state.reserve_ids.size() != total_cards_before_treasure + 1:
		return false
	if not str(treasure_result.get("message", "")).begins_with("宝箱："):
		return false
	run_state.current_hp = max(1, run_state.max_hp - 4)
	var rest_result: Dictionary = run_state.apply_rest()
	if not bool(rest_result.get("success", false)) or run_state.current_hp != run_state.max_hp:
		return false
	var stones_before_manual_spend: int = run_state.spirit_stones
	run_state.add_spirit_stones(30)
	if not run_state.spend_spirit_stones(12) or run_state.spirit_stones != stones_before_manual_spend + 18:
		return false
	var stock := run_state.generate_shop_stock()
	if stock.size() <= 0 or not stock[0].has("card_id") or not stock[0].has("price"):
		return false
	run_state.add_spirit_stones(200)
	var refresh_cost: int = run_state.shop_start_refresh_cost()
	var refresh_result: Dictionary = run_state.refresh_shop_stock(refresh_cost)
	if not bool(refresh_result.get("success", false)) or int(refresh_result.get("next_refresh_cost", 0)) != refresh_cost * 2:
		return false
	var refreshed_stock: Array = (refresh_result.get("stock", []) as Array)
	if refreshed_stock.is_empty():
		return false
	var shop_item: Dictionary = refreshed_stock[0]
	var size_before_buy: int = run_state.deck_ids.size() + run_state.reserve_ids.size()
	var stones_before_buy: int = run_state.spirit_stones
	var buy_result: Dictionary = run_state.buy_shop_card(str(shop_item.get("card_id", "")), int(shop_item.get("price", 0)))
	if not bool(buy_result.get("success", false)):
		return false
	if run_state.spirit_stones >= stones_before_buy:
		return false
	if run_state.deck_ids.size() + run_state.reserve_ids.size() != size_before_buy + 1:
		return false
	run_state.reserve_ids.append("火球符")
	var stones_before_sell: int = run_state.spirit_stones
	var reserve_before_sell: int = run_state.reserve_ids.size()
	var sell_result: Dictionary = run_state.sell_reserve_card(run_state.reserve_ids.size() - 1)
	return bool(sell_result.get("success", false)) and run_state.spirit_stones > stones_before_sell and run_state.reserve_ids.size() == reserve_before_sell - 1

func _test_boss_settlement_and_meta_progression() -> bool:
	var run_state = RunStateScript.new()
	run_state.start("sword")
	var test_progression = MetaProgressionScript.new()
	test_progression.reset_to_defaults()
	run_state.meta_progression = test_progression
	run_state.meta_bonuses = test_progression.bonuses_for_job("sword")
	var old_max_hp: int = run_state.max_hp
	var old_score_limit: int = run_state.deck_score_limit
	var normal_node_id := ""
	var boss_node_id := ""
	for node in run_state.map_nodes:
		if str(node.get("type", "")) == "normal" and normal_node_id == "":
			normal_node_id = str(node.get("id", ""))
		if str(node.get("type", "")) == "boss":
			boss_node_id = str(node.get("id", ""))
	if normal_node_id == "" or boss_node_id == "":
		return false
	run_state.complete_node(normal_node_id)
	if run_state.run_cultivation_base != 3:
		return false
	var first_boss_result: Dictionary = run_state.apply_battle_completion(
		boss_node_id,
		run_state.deck_ids,
		run_state.reserve_ids,
		run_state.current_hp,
		run_state.max_hp,
		false
	)
	if not bool(first_boss_result.get("success", false)) or str(first_boss_result.get("flow", "")) != "map":
		return false
	if not bool(first_boss_result.get("advanced_layer", false)):
		return false
	if run_state.realm_index != 1 or run_state.current_story_layer_number() != 2:
		return false
	if run_state.campaign_complete or test_progression.points_total("sword") != 0:
		return false
	var second_boss_node_id := ""
	for node in run_state.map_nodes:
		if str(node.get("type", "")) == "boss":
			second_boss_node_id = str(node.get("id", ""))
			break
	if second_boss_node_id == "":
		return false
	var second_boss_result: Dictionary = run_state.apply_battle_completion(
		second_boss_node_id,
		run_state.deck_ids,
		run_state.reserve_ids,
		run_state.current_hp,
		run_state.max_hp,
		false
	)
	if not bool(second_boss_result.get("success", false)) or not bool(second_boss_result.get("advanced_layer", false)):
		return false
	if run_state.realm_index != 2 or run_state.current_story_layer_number() != 3:
		return false
	var third_boss_node_id := ""
	for node in run_state.map_nodes:
		if str(node.get("type", "")) == "boss":
			third_boss_node_id = str(node.get("id", ""))
			break
	if third_boss_node_id == "":
		return false
	var third_boss_result: Dictionary = run_state.apply_battle_completion(
		third_boss_node_id,
		run_state.deck_ids,
		run_state.reserve_ids,
		run_state.current_hp,
		run_state.max_hp,
		false
	)
	if not bool(third_boss_result.get("success", false)) or str(third_boss_result.get("flow", "")) != "settlement":
		return false
	var settlement: Dictionary = (third_boss_result.get("settlement", {}) as Dictionary)
	var ok: bool = run_state.campaign_complete
	ok = ok and int(settlement.get("base", 0)) == 33
	ok = ok and int(settlement.get("awarded", 0)) == 50
	ok = ok and test_progression.points_total("sword") == 50
	ok = ok and not run_state.advance_to_next_story_layer()
	ok = ok and run_state.max_hp == old_max_hp
	ok = ok and run_state.deck_score_limit == old_score_limit
	ok = ok and run_state.available_nodes().is_empty()
	return ok

func _test_progression_database_boundary() -> bool:
	if ProgressionDatabaseScript.title_for_points(0) != "练气":
		return false
	if ProgressionDatabaseScript.title_for_points(90) != "金丹":
		return false
	if not is_equal_approx(ProgressionDatabaseScript.layer_multiplier(2), 1.5):
		return false
	var sword_starting: Dictionary = ProgressionDatabaseScript.upgrade_definition("sword", "starting_sword")
	if int(sword_starting.get("max_level", 0)) != 2:
		return false
	var talisman_defense: Dictionary = ProgressionDatabaseScript.upgrade_definition("talisman", "defense")
	if int(talisman_defense.get("max_level", 0)) != 2:
		return false
	var compatibility: Dictionary = MetaProgressionScript.upgrade_definition("sword", "starting_sword")
	return str(compatibility.get("name", "")) == str(sword_starting.get("name", ""))

func _test_failed_run_settlement() -> bool:
	var run_state = RunStateScript.new()
	run_state.start("sword")
	var test_progression = MetaProgressionScript.new()
	test_progression.reset_to_defaults()
	run_state.meta_progression = test_progression
	run_state.meta_bonuses = test_progression.bonuses_for_job("sword")
	var normal_node_id := ""
	for node in run_state.map_nodes:
		if str(node.get("type", "")) == "normal":
			normal_node_id = str(node.get("id", ""))
			break
	if normal_node_id == "":
		return false
	run_state.complete_node(normal_node_id)
	var settlement: Dictionary = run_state.finish_run_and_save_progression(false, false)
	var ok: bool = run_state.campaign_complete
	ok = ok and not bool(settlement.get("completed", true))
	ok = ok and int(settlement.get("base", 0)) == 3
	ok = ok and int(settlement.get("awarded", 0)) == 3
	ok = ok and test_progression.points_total("sword") == 3
	var repeated: Dictionary = run_state.finish_run_and_save_progression(false, true)
	ok = ok and not bool(repeated.get("completed", true))
	ok = ok and test_progression.points_total("sword") == 3
	var empty_run_state = RunStateScript.new()
	empty_run_state.start("sword")
	var empty_progression = MetaProgressionScript.new()
	empty_progression.reset_to_defaults()
	empty_run_state.meta_progression = empty_progression
	empty_run_state.meta_bonuses = empty_progression.bonuses_for_job("sword")
	var empty_settlement: Dictionary = empty_run_state.finish_run_and_save_progression(false, false)
	var empty_repeated: Dictionary = empty_run_state.finish_run_and_save_progression(false, true)
	ok = ok and int(empty_settlement.get("awarded", -1)) == 0
	ok = ok and not bool(empty_repeated.get("completed", true))
	ok = ok and empty_progression.points_total("sword") == 0
	return ok

func _test_exploration_battle_completion() -> bool:
	var run_state = RunStateScript.new()
	run_state.start("sword")
	run_state.current_hp -= 5
	var available := run_state.available_nodes()
	if available.size() < 1:
		return false
	var node: Dictionary = available[0]
	var payload: Dictionary = run_state.battle_start_payload(str(node.get("id", "")))
	if not bool(payload.get("success", false)):
		return false
	if str(payload.get("node_id", "")) != str(node.get("id", "")):
		return false
	if int(payload.get("battle_number", 0)) != run_state.battle_number_for_node(node):
		return false
	if int(payload.get("spirit_reward", 0)) != run_state.battle_spirit_reward(node):
		return false
	if str(run_state.pending_node_id) != str(node.get("id", "")):
		return false
	var battle = BattleManagerScript.new()
	battle.start_run_with_deck(
		str(payload.get("job_id", "")),
		(payload.get("deck_ids", []) as Array),
		int(payload.get("battle_number", 1)),
		str(payload.get("encounter_type", "normal")),
		false,
		(payload.get("run_context", {}) as Dictionary)
	)
	if battle.auto_advance_after_reward:
		return false
	if battle.player.hp != run_state.current_hp:
		return false
	battle.enemy.hp = 1
	battle.player_normal_attack()
	if battle.phase != "reward" or battle.reward_options.is_empty():
		return false
	var reward_id := str(battle.reward_options[0])
	battle.choose_reward(reward_id)
	if battle.phase != "map_complete" or not (battle.master_deck_ids.has(reward_id) or battle.master_reserve_ids.has(reward_id)):
		return false
	var stones_before: int = run_state.spirit_stones
	var expected_stone_reward: int = run_state.battle_spirit_reward(node)
	var result: Dictionary = run_state.apply_battle_completion(
		str(node.get("id", "")),
		battle.master_deck_ids,
		battle.master_reserve_ids,
		battle.player.hp,
		battle.player.max_hp
	)
	return bool(result.get("success", false)) \
		and str(result.get("flow", "")) == "map" \
		and int(result.get("spirit_stones", 0)) == expected_stone_reward \
		and run_state.spirit_stones == stones_before + expected_stone_reward \
		and (run_state.deck_ids.has(reward_id) or run_state.reserve_ids.has(reward_id)) \
		and run_state.current_hp == battle.player.hp \
		and run_state.completed_node_ids.has(str(node.get("id", "")))

func _test_battle_unit_framework() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var ok := true
	ok = ok and battle.formation.MAX_UNITS_PER_SIDE == 3
	ok = ok and battle.formation.player_units.size() == 1
	ok = ok and battle.formation.enemy_units.size() == 1
	ok = ok and battle.formation.player_units[0] == battle.player
	ok = ok and battle.formation.enemy_units[0] == battle.enemy
	ok = ok and battle.player.team == "player"
	ok = ok and battle.enemy.team == "enemy"
	ok = ok and battle.player.slot_index == 2
	ok = ok and battle.enemy.slot_index == 2
	ok = ok and battle.resolve_target_units("enemy").size() == 1
	battle.add_unit_resource(battle.player, "sword_momentum", 2, "测试")
	ok = ok and battle.player.sword_momentum == 2
	ok = ok and battle.player.get_resource("sword_momentum") == 2
	ok = ok and battle.debug_add_ally()
	ok = ok and battle.debug_add_ally()
	ok = ok and not battle.debug_add_ally()
	ok = ok and battle.player_target_count() == 3
	return ok

func _test_battle_side_framework() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var ok := true
	ok = ok and battle.player_side != null
	ok = ok and battle.enemy_side != null
	ok = ok and battle.player_side.deck_manager == battle.deck
	ok = ok and battle.player_side.units == battle.formation.player_units
	ok = ok and battle.enemy_side.units == battle.formation.enemy_units
	ok = ok and battle.player_side.draw_per_turn == battle.draw_per_turn
	ok = ok and battle.enemy_side.draw_per_turn == 1
	ok = ok and battle.enemy_side.deck_manager.deck.is_empty()
	ok = ok and battle.enemy_side.deck_manager.hand.is_empty()
	ok = ok and battle.enemy_side.visible_zones.get("spell_zone", false)
	ok = ok and not bool(battle.enemy_side.visible_zones.get("hand", true))
	ok = ok and battle.player.has_unit_tag("主单位")
	ok = ok and battle.player.has_unit_tag("剑修")
	battle.player.spell_zone.append(CardDatabaseScript.make_card("护身符"))
	ok = ok and battle.player_side.spell_zone.size() == battle.player.spell_zone.size()
	battle.player.spell_zone.clear()
	battle.debug_add_enemy()
	battle.debug_add_ally()
	ok = ok and battle.enemy_side.units.size() == battle.formation.enemy_units.size()
	ok = ok and battle.player_side.units.size() == battle.formation.player_units.size()
	var elite_battle = BattleManagerScript.new()
	elite_battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "elite", false, {})
	ok = ok and elite_battle.enemy_side.draw_per_turn == 2
	ok = ok and elite_battle.enemy_side.deck_manager.deck.is_empty()
	var boss_battle = BattleManagerScript.new()
	boss_battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "boss", false, {})
	ok = ok and boss_battle.enemy_side.draw_per_turn == 3
	ok = ok and boss_battle.enemy_side.deck_manager.deck.size() == 5
	ok = ok and boss_battle.enemy.has_unit_tag("首领")
	var layer_two_elite = BattleManagerScript.new()
	layer_two_elite.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "elite", false, {"realm_index": 1})
	ok = ok and layer_two_elite.enemy_side.draw_per_turn == 2
	ok = ok and layer_two_elite.enemy_side.deck_manager.deck.size() >= 3
	ok = ok and layer_two_elite.enemy.has_unit_tag("精英")
	return ok

func _test_enemy_card_packages() -> bool:
	var boss_battle = BattleManagerScript.new()
	boss_battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "boss", false, {})
	if boss_battle.enemy_side.draw_per_turn != 3 or boss_battle.enemy_side.deck_ids.size() != 5:
		return false
	if not boss_battle.enemy_side.deck_manager.hand.is_empty():
		return false
	var status_battle = BattleManagerScript.new()
	status_battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "boss", false, {})
	status_battle.enemy_side.draw_per_turn = 0
	status_battle.enemy_side.deck_manager.hand.clear()
	status_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("破甲符"))
	status_battle.end_player_turn()
	if status_battle.phase == "response":
		status_battle.skip_response()
	if status_battle.player.get_status("破甲") != 2 or status_battle.phase != "player":
		return false
	var side_limit_battle = BattleManagerScript.new()
	side_limit_battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "normal", false, {})
	side_limit_battle.debug_add_enemy()
	side_limit_battle.enemy_side.draw_per_turn = 0
	side_limit_battle.enemy_side.deck_manager.hand.clear()
	side_limit_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("破甲符"))
	side_limit_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("缚身符"))
	side_limit_battle.end_player_turn()
	while side_limit_battle.phase == "response":
		side_limit_battle.skip_response()
	return side_limit_battle.player.get_status("虚弱") == 2 and side_limit_battle.player.get_status("破甲") == 0 and side_limit_battle.enemy_side.deck_manager.hand.size() == 1

func _test_enemy_encounter_architecture() -> bool:
	var sword_character: Dictionary = EnemyDatabaseScript.character_template("sword")
	if sword_character.is_empty() or not (sword_character.get("unit_tags", []) as Array).has("剑修"):
		return false
	for layer in [1, 2, 3]:
		var boss_deck_templates: Array = EnemyDatabaseScript.deck_templates_for(layer, "boss", 0)
		if boss_deck_templates.size() < 3:
			return false
		var first_template: Dictionary = (boss_deck_templates[0] as Dictionary)
		if str(first_template.get("template_kind", "")) != "enemy_deck_template":
			return false
		if not first_template.has("deck") or not first_template.has("character_refs"):
			return false
	var layer_three_normal: Dictionary = EnemyDatabaseScript.get_encounter_for_battle(3, "normal", 2, 0, null)
	if str(layer_three_normal.get("encounter_type", "")) != "normal":
		return false
	if str(layer_three_normal.get("deck_template_id", "")) == "":
		return false
	if (layer_three_normal.get("character_refs", []) as Array).is_empty():
		return false
	if (layer_three_normal.get("enemy_units", []) as Array).is_empty():
		return false
	var world_scaled: Dictionary = EnemyDatabaseScript.get_encounter_for_battle(3, "normal", 2, 2, null)
	var base_enemy: Dictionary = (layer_three_normal.get("primary_enemy", {}) as Dictionary)
	var scaled_enemy: Dictionary = (world_scaled.get("primary_enemy", {}) as Dictionary)
	if int(scaled_enemy.get("max_hp", 0)) <= int(base_enemy.get("max_hp", 0)):
		return false
	var battle = BattleManagerScript.new()
	battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 3, "normal", false, {"realm_index": 2})
	if battle.current_encounter_profile.is_empty():
		return false
	if str(battle.current_enemy_deck_profile.get("deck_template_id", "")) == "":
		return false
	return battle.enemy_side.units.size() == battle.formation.enemy_units.size()

func _test_battle_encounter_runtime_boundary() -> bool:
	var encounter: Dictionary = BattleEncounterRuntimeScript.select_encounter(3, "elite", 1, 0, null)
	if encounter.is_empty():
		return false
	var profile: Dictionary = BattleEncounterRuntimeScript.deck_profile(encounter)
	if str(profile.get("deck_template_id", "")) == "":
		return false
	var encounter_deck: Array = (encounter.get("deck", []) as Array)
	if BattleEncounterRuntimeScript.enemy_deck(encounter).size() != encounter_deck.size():
		return false
	var draw_count: int = BattleEncounterRuntimeScript.draw_per_turn(encounter, "elite")
	if draw_count != int(encounter.get("draw_per_turn", 1)):
		return false
	if BattleEncounterRuntimeScript.card_play_limit(encounter, "elite") != int(encounter.get("card_play_limit", draw_count)):
		return false
	var enemy_data: Dictionary = BattleEncounterRuntimeScript.primary_enemy_data(encounter, 3)
	if str(enemy_data.get("id", "")) == "" or int(enemy_data.get("max_hp", 0)) <= 0:
		return false
	var fallback_enemy_data: Dictionary = BattleEncounterRuntimeScript.primary_enemy_data({}, 1)
	return str(fallback_enemy_data.get("id", "")) != "" and int(fallback_enemy_data.get("max_hp", 0)) > 0

func _test_job_database_uses_character_pool() -> bool:
	var sword_job: Dictionary = JobDatabaseScript.get_job("sword")
	var sword_character: Dictionary = CharacterDatabaseScript.character_template(str(sword_job.get("character_id", "")))
	if sword_job.is_empty() or sword_character.is_empty():
		return false
	if str(sword_job.get("character_id", "")) != "sword":
		return false
	if int(sword_job.get("max_hp", 0)) != int(sword_character.get("max_hp", -1)):
		return false
	if int(sword_job.get("attack", 0)) != int(sword_character.get("attack", -1)):
		return false
	if not ((sword_job.get("unit_tags", []) as Array).has("剑修")):
		return false
	return (sword_job.get("start_deck", []) as Array).size() >= DeckBuildRulesScript.min_deck_size()

func _test_effect_steps_and_enemy_skill() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var enemy_hp_before: int = battle.enemy.hp
	battle.effect_resolver.apply_steps(battle, battle.player, [
		{"kind": "damage", "target": "enemy", "value": 4, "ignore_defense": true, "source": "测试伤害"}
	])
	if battle.enemy.hp != enemy_hp_before - 4:
		return false
	battle.enemy.defense = 2
	var enemy_hp_before_defense: int = battle.enemy.hp
	battle.effect_resolver.apply_steps(battle, battle.player, [
		{"kind": "damage", "target": "enemy", "value": 4, "source": "测试防御减伤"}
	])
	if battle.enemy.hp != enemy_hp_before_defense - 2:
		return false
	battle.player.hp = max(1, battle.player.hp - 5)
	var player_hp_before: int = battle.player.hp
	battle.effect_resolver.apply_steps(battle, battle.player, [
		{"kind": "heal", "target": "player", "value": 3, "source": "测试治疗"},
		{"kind": "add_status", "target": "enemy", "status": "poison", "value": 2, "source": "测试状态"}
	])
	if battle.player.hp != player_hp_before + 3 or battle.enemy.get_status("poison") != 2:
		return false
	battle.enemy.skills = {
		"test_skill": {
			"name": "测试妖术",
			"cooldown": 2,
			"effect_steps": [
				{"kind": "damage", "target": "player", "value": 2, "ignore_defense": true, "source": "测试妖术"}
			]
		}
	}
	battle.enemy.actions = [{"kind": "skill", "skill_id": "test_skill", "intent": "测试妖术"}]
	battle.enemy.action_index = 0
	var hp_before_skill: int = battle.player.hp
	battle.end_player_turn()
	return battle.player.hp == hp_before_skill - 2 and int(battle.enemy.skill_cooldowns.get("test_skill", 0)) == 2

func _test_target_selection_for_multi_enemy() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var added: bool = battle.add_enemy_unit({
		"id": "training_dummy",
		"name": "练功桩",
		"max_hp": 12,
		"attack": 0,
		"defense": 0,
		"action_sequence": []
	}, 0)
	if not added:
		return false
	if not battle.select_enemy_target("training_dummy"):
		return false
	var second_enemy = battle.formation.living_unit_by_uid("enemy", "training_dummy")
	if second_enemy == null:
		return false
	var primary_hp_before: int = battle.enemy.hp
	var second_hp_before: int = second_enemy.hp
	battle.effect_resolver.apply_steps(battle, battle.player, [
		{"kind": "damage", "target": "enemy", "value": 5, "ignore_defense": true, "source": "测试选中目标"}
	])
	if battle.enemy.hp != primary_hp_before or second_enemy.hp != second_hp_before - 5:
		return false

	var attack_battle = BattleManagerScript.new()
	attack_battle.start_run("sword")
	attack_battle.add_enemy_unit({
		"id": "training_dummy",
		"name": "练功桩",
		"max_hp": 12,
		"attack": 0,
		"defense": 0,
		"action_sequence": []
	}, 0)
	var attack_dummy = attack_battle.formation.living_unit_by_uid("enemy", "training_dummy")
	if attack_dummy == null:
		return false
	var attack_dummy_hp_before: int = attack_dummy.hp
	var attack_primary_hp_before: int = attack_battle.enemy.hp
	attack_battle.player_normal_attack()
	if attack_battle.phase != "target_select":
		return false
	if attack_battle.player.normal_attack_used:
		return false
	attack_battle.confirm_target_selection("training_dummy")
	if attack_battle.phase != "player":
		return false
	if not attack_battle.player.normal_attack_used:
		return false
	if attack_battle.enemy.hp != attack_primary_hp_before:
		return false
	if attack_dummy.hp >= attack_dummy_hp_before:
		return false

	var card_battle = BattleManagerScript.new()
	card_battle.start_run("talisman")
	card_battle.add_enemy_unit({
		"id": "spell_dummy",
		"name": "试符桩",
		"max_hp": 12,
		"attack": 0,
		"defense": 0,
		"action_sequence": []
	}, 0)
	var fireball_uid := ""
	for card in card_battle.deck.hand:
		if card.get("id", "") == "火球符":
			fireball_uid = str(card.get("uid", ""))
			break
	if fireball_uid == "":
		card_battle.deck.hand.append(CardDatabaseScript.make_card("火球符"))
		fireball_uid = str(card_battle.deck.hand.back().get("uid", ""))
	var spell_dummy = card_battle.formation.living_unit_by_uid("enemy", "spell_dummy")
	if spell_dummy == null:
		return false
	var spell_dummy_hp_before: int = spell_dummy.hp
	var spell_primary_hp_before: int = card_battle.enemy.hp
	card_battle.play_hand_card(fireball_uid)
	if card_battle.phase != "target_select":
		return false
	if card_battle.deck.find_hand_card(fireball_uid).is_empty():
		return false
	card_battle.confirm_target_selection("spell_dummy")
	if card_battle.phase != "player":
		return false
	if not card_battle.deck.find_hand_card(fireball_uid).is_empty():
		return false
	return card_battle.enemy.hp == spell_primary_hp_before and spell_dummy.hp < spell_dummy_hp_before

func _test_summon_and_enemy_target_pool() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var summon_card := CardDatabaseScript.make_card("幻象术")
	battle.deck.hand.append(summon_card)
	battle.play_hand_card(str(summon_card.get("uid", "")))
	if battle.player_target_count() != 3:
		return false
	if battle.formation.living_units("player").size() != 3:
		return false
	if battle.debug_add_ally():
		return false
	var total_hp_before := 0
	for unit in battle.formation.living_units("player"):
		total_hp_before += int(unit.hp)
	battle.end_player_turn()
	var total_hp_after := 0
	for unit in battle.formation.player_units:
		if unit != null:
			total_hp_after += int(unit.hp)
	return battle.phase == "player" and total_hp_after < total_hp_before and battle.player.hp > 0

func _test_player_unit_actions() -> bool:
	var attack_battle = BattleManagerScript.new()
	attack_battle.start_run("sword")
	if not attack_battle.debug_add_ally():
		return false
	var ally = null
	for unit in attack_battle.formation.living_units("player"):
		if unit != attack_battle.player:
			ally = unit
			break
	if ally == null:
		return false
	var enemy_hp_before: int = attack_battle.enemy.hp
	attack_battle.player_unit_attack(str(ally.uid))
	if attack_battle.enemy.hp != enemy_hp_before:
		return false
	if not attack_battle.player_unit_action_used(ally):
		return false

	var defend_battle = BattleManagerScript.new()
	defend_battle.start_run("sword")
	var base_defense: int = defend_battle.player.current_defense()
	var hp_before: int = defend_battle.player.hp
	defend_battle.player_unit_defend(defend_battle.player.uid)
	if not defend_battle.player_unit_action_used(defend_battle.player):
		return false
	var defended_value: int = 1 if base_defense <= 0 else base_defense * 2
	if defend_battle.player.current_defense() != defended_value:
		return false
	defend_battle.end_player_turn()
	var expected_damage: int = max(0, defend_battle.enemy.attack - defended_value)
	return defend_battle.phase == "player" and defend_battle.player.hp == hp_before - expected_damage and defend_battle.player.current_defense() == base_defense and not defend_battle.player_unit_action_used(defend_battle.player)

func _test_enemy_ai_controller_boundary() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	if battle.enemy_controller == null or battle.enemy_controller.get_script() != EnemyAIControllerScript:
		return false
	if battle.has_method("_select_enemy_hand_card") or battle.has_method("_enemy_spell_profile"):
		return false
	battle.enemy_side.deck_manager.hand.clear()
	battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("火球符"))
	battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("雷击符"))
	var source_unit = battle.enemy_controller.side_card_source_unit(battle)
	var selected_card: Dictionary = battle.enemy_controller.select_next_side_card(battle, source_unit)
	if str(selected_card.get("id", "")) != "雷击符":
		return false
	var profile: Dictionary = battle.enemy_controller.side_card_profile("裂石符")
	return int(profile.get("damage", 0)) == 7 and not (profile.get("post_steps", []) as Array).is_empty()

func _test_enemy_side_action_sequence() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	if not battle.debug_add_enemy():
		return false
	if not battle.debug_add_enemy():
		return false
	var hp_before: int = battle.player.hp
	var expected_damage: int = max(0, battle.enemy.current_attack() - battle.player.current_defense())
	expected_damage += max(0, 5 - battle.player.current_defense()) * 2
	battle.end_player_turn()
	return battle.phase == "player" and battle.player.hp == hp_before - expected_damage

func _test_ally_damage_response_scope() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	if not battle.debug_add_ally():
		return false
	var ally = null
	for unit in battle.formation.living_units("player"):
		if unit != battle.player:
			ally = unit
			break
	if ally == null:
		return false
	ally.add_status("taunt", 1)
	var guard := _ready_defense("护身符")
	var hide_blade := _ready_defense("藏锋")
	battle.player.spell_zone.append(guard)
	battle.player.spell_zone.append(hide_blade)
	var ally_hp_before: int = int(ally.hp)
	battle.end_player_turn()
	if battle.phase != "response" or battle.current_event.get("event_type", "") != "player_damage_before":
		return false
	if str(battle.current_event.get("target_key", "")) != str(ally.uid):
		return false
	var available := battle.get_available_responses_for_current_event()
	if available.size() != 1 or available[0].get("id", "") != "护身符":
		return false
	battle.add_card_to_chain(str(guard.get("uid", "")))
	var expected_damage: int = max(0, battle.enemy.current_attack() - ally.current_defense() - 4)
	return battle.phase == "player" and int(ally.hp) == ally_hp_before - expected_damage and battle.deck.graveyard.size() >= 1

func _test_common_status_and_zone_cards() -> bool:
	var status_battle = BattleManagerScript.new()
	status_battle.start_run("sword")
	status_battle.enemy.defense = 2
	var armor_break := CardDatabaseScript.make_card("破甲符")
	status_battle.deck.hand.append(armor_break)
	status_battle.play_hand_card(str(armor_break.get("uid", "")))
	if status_battle.enemy.get_status("破甲") != 2 or status_battle.enemy.current_defense() != 0:
		return false

	var guard_battle = BattleManagerScript.new()
	guard_battle.start_run("sword")
	var solid := CardDatabaseScript.make_card("固元符")
	guard_battle.deck.hand.append(solid)
	guard_battle.play_hand_card(str(solid.get("uid", "")))
	var hp_before_guard: int = guard_battle.player.hp
	guard_battle.open_timing_window(guard_battle.create_event("player_damage_before", "test", guard_battle.player, 5))
	if guard_battle.player.hp != hp_before_guard - 2:
		return false

	var zone_battle = BattleManagerScript.new()
	zone_battle.start_run_with_deck("sword", ["火球符", "火球符", "火球符", "火球符", "火球符", "火球符", "火球符", "火球符", "火球符", "火球符"], 1, "normal")
	var incense := CardDatabaseScript.make_card("凝神香")
	zone_battle.deck.hand.append(incense)
	var hand_before_zone: int = zone_battle.deck.hand.size()
	zone_battle.play_hand_card(str(incense.get("uid", "")))
	if zone_battle.player.spell_zone.size() != 1 or int(zone_battle.player.spell_zone[0].get("zone_countdown", -1)) != 2:
		return false
	zone_battle.resolver.apply_player_turn_start(zone_battle)
	if int(zone_battle.player.spell_zone[0].get("zone_countdown", -1)) != 1:
		return false
	zone_battle.resolver.apply_player_turn_start(zone_battle)
	if not zone_battle.player.spell_zone.is_empty() or zone_battle.deck.hand.size() < hand_before_zone:
		return false

	var cancel_battle = BattleManagerScript.new()
	cancel_battle.start_run("sword")
	cancel_battle.player.spell_zone.append(_ready_defense("攻击无效符"))
	var hp_before_cancel: int = cancel_battle.player.hp
	cancel_battle.end_player_turn()
	if cancel_battle.phase != "response":
		return false
	cancel_battle.add_card_to_chain(str(cancel_battle.player.spell_zone[0].get("uid", "")))
	if cancel_battle.player.hp != hp_before_cancel:
		return false

	var mirror_battle = BattleManagerScript.new()
	mirror_battle.start_run("sword")
	var mirror := CardDatabaseScript.make_card("护心镜")
	mirror_battle.deck.hand.append(mirror)
	mirror_battle.play_hand_card(str(mirror.get("uid", "")))
	mirror_battle.player.hp = 3
	mirror_battle.open_timing_window(mirror_battle.create_event("player_damage_before", "test", mirror_battle.player, 10))
	return mirror_battle.player.hp == 1 and mirror_battle.player.equipment.is_empty() and mirror_battle.phase != "defeat"
