extends SceneTree

const BattleManagerScript = preload("res://scripts/battle/BattleManager.gd")
const EnemyAIControllerScript = preload("res://scripts/battle/EnemyAIController.gd")
const BattleEncounterRuntimeScript = preload("res://scripts/battle/BattleEncounterRuntime.gd")
const BattleUnitScript = preload("res://scripts/battle/BattleUnit.gd")
const ResponseWindowRulesScript = preload("res://scripts/battle/ResponseWindowRules.gd")
const DeckManagerScript = preload("res://scripts/battle/DeckManager.gd")
const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const CardPoolDatabaseScript = preload("res://scripts/data/CardPoolDatabase.gd")
const EventDatabaseScript = preload("res://scripts/data/EventDatabase.gd")
const StatusDatabaseScript = preload("res://scripts/data/StatusDatabase.gd")
const StatusRulesScript = preload("res://scripts/battle/StatusRules.gd")
const DeckBuildRulesScript = preload("res://scripts/run/DeckBuildRules.gd")
const CardAcquisitionRulesScript = preload("res://scripts/run/CardAcquisitionRules.gd")
const EventServiceScript = preload("res://scripts/run/EventService.gd")
const RewardServiceScript = preload("res://scripts/run/RewardService.gd")
const ExplorationRulesScript = preload("res://scripts/run/ExplorationRules.gd")
const CardInteractionRulesScript = preload("res://scripts/ui/CardInteractionRules.gd")
const BattleAudioRouterScript = preload("res://scripts/ui/BattleAudioRouter.gd")
const CardDisplayRulesScript = preload("res://scripts/ui/CardDisplayRules.gd")
const BattleFloatingTextRulesScript = preload("res://scripts/ui/BattleFloatingTextRules.gd")
const MapModalChoiceFactoryScript = preload("res://scripts/ui/MapModalChoiceFactory.gd")
const VisualAssetDatabaseScript = preload("res://scripts/assets/VisualAssetDatabase.gd")
const CharacterVisualDatabaseScript = preload("res://scripts/assets/CharacterVisualDatabase.gd")
const AudioEventDatabaseScript = preload("res://scripts/audio/AudioEventDatabase.gd")
const AudioManagerScript = preload("res://scripts/audio/AudioManager.gd")
const GameSettingsScript = preload("res://scripts/settings/GameSettings.gd")
const SettingsStoreScript = preload("res://scripts/settings/SettingsStore.gd")
const DisplayModeManagerScript = preload("res://scripts/settings/DisplayModeManager.gd")
const InputActionDatabaseScript = preload("res://scripts/settings/InputActionDatabase.gd")
const InputSettingsScript = preload("res://scripts/settings/InputSettings.gd")
const LocalizationDatabaseScript = preload("res://scripts/localization/LocalizationDatabase.gd")
const LocalizationServiceScript = preload("res://scripts/localization/LocalizationService.gd")
const SaveMigrationServiceScript = preload("res://scripts/save/SaveMigrationService.gd")
const EncounterFactoryScript = preload("res://scripts/data/EncounterFactory.gd")
const EnemyDeckTemplateDatabaseScript = preload("res://scripts/data/EnemyDeckTemplateDatabase.gd")
const CharacterDatabaseScript = preload("res://scripts/data/CharacterDatabase.gd")
const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const RunStateScript = preload("res://scripts/run/RunState.gd")
const MetaProgressionScript = preload("res://scripts/data/MetaProgression.gd")
const ProgressionDatabaseScript = preload("res://scripts/data/ProgressionDatabase.gd")

class FixedEventRng:
	extends RefCounted

	var fixed_value: float

	func _init(value: float) -> void:
		fixed_value = value

	func randf() -> float:
		return fixed_value

func _submit_request_accepted(battle, request: Dictionary) -> bool:
	var result: Dictionary = battle.submit_request(request)
	return bool(result.get("accepted", false))

func _play_response(battle, card_uid: String) -> bool:
	return _submit_request_accepted(battle, {"request_type": "play_response", "side": "player", "card_uid": card_uid})

func _skip_response(battle) -> bool:
	return _submit_request_accepted(battle, {"request_type": "skip_response", "side": "player"})

func _skip_response_for_side(battle, side: String) -> bool:
	return _submit_request_accepted(battle, {"request_type": "skip_response", "side": side})

func _select_target(battle, target_uid: String) -> bool:
	return _submit_request_accepted(battle, {"request_type": "select_target", "side": "player", "target_side": "enemy", "target_uid": target_uid})

func _init() -> void:
	var ok := true
	ok = _report_test("_test_sword_start_and_attack", _test_sword_start_and_attack()) and ok
	ok = _report_test("_test_battle_opening_draw_rules", _test_battle_opening_draw_rules()) and ok
	ok = _report_test("_test_player_battle_request_entrypoints", _test_player_battle_request_entrypoints()) and ok
	ok = _report_test("_test_enemy_battle_request_entrypoints", _test_enemy_battle_request_entrypoints()) and ok
	ok = _report_test("_test_enemy_unit_action_request_entrypoints", _test_enemy_unit_action_request_entrypoints()) and ok
	ok = _report_test("_test_enemy_spell_attack_request_entrypoint", _test_enemy_spell_attack_request_entrypoint()) and ok
	ok = _report_test("_test_talisman_spell_flow", _test_talisman_spell_flow()) and ok
	ok = _report_test("_test_reward_to_next_battle", _test_reward_to_next_battle()) and ok
	ok = _report_test("_test_set_defense_ready_on_enemy_turn", _test_set_defense_ready_on_enemy_turn()) and ok
	ok = _report_test("_test_damage_response_chain", _test_damage_response_chain()) and ok
	ok = _report_test("_test_battle_event_field_normalization", _test_battle_event_field_normalization()) and ok
	ok = _report_test("_test_response_chain_link_lifecycle", _test_response_chain_link_lifecycle()) and ok
	ok = _report_test("_test_response_window_owner_pass_state", _test_response_window_owner_pass_state()) and ok
	ok = _report_test("_test_response_window_rules_shell", _test_response_window_rules_shell()) and ok
	ok = _report_test("_test_counter_lethal_trade_defeats_player", _test_counter_lethal_trade_defeats_player()) and ok
	ok = _report_test("_test_zero_hp_cannot_start_battle", _test_zero_hp_cannot_start_battle()) and ok
	ok = _report_test("_test_skip_response", _test_skip_response()) and ok
	ok = _report_test("_test_counter_spell_response", _test_counter_spell_response()) and ok
	ok = _report_test("_test_protect_destroy_response", _test_protect_destroy_response()) and ok
	ok = _report_test("_test_lethal_response", _test_lethal_response()) and ok
	ok = _report_test("_test_event_window_continues_without_responses", _test_event_window_continues_without_responses()) and ok
	ok = _report_test("_test_equipment_cards", _test_equipment_cards()) and ok
	ok = _report_test("_test_equipment_helper_snapshots", _test_equipment_helper_snapshots()) and ok
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
	ok = _report_test("_test_active_entry_sources_use_first_edition_cards", _test_active_entry_sources_use_first_edition_cards()) and ok
	ok = _report_test("_test_active_card_effect_step_schema", _test_active_card_effect_step_schema()) and ok
	ok = _report_test("_test_run_card_id_canonical_boundaries", _test_run_card_id_canonical_boundaries()) and ok
	ok = _report_test("_test_card_acquisition_rules_boundary", _test_card_acquisition_rules_boundary()) and ok
	ok = _report_test("_test_event_database_boundary", _test_event_database_boundary()) and ok
	ok = _report_test("_test_exploration_node_types_and_economy", _test_exploration_node_types_and_economy()) and ok
	ok = _report_test("_test_boss_settlement_and_meta_progression", _test_boss_settlement_and_meta_progression()) and ok
	ok = _report_test("_test_progression_database_boundary", _test_progression_database_boundary()) and ok
	ok = _report_test("_test_failed_run_settlement", _test_failed_run_settlement()) and ok
	ok = _report_test("_test_exploration_battle_completion", _test_exploration_battle_completion()) and ok
	ok = _report_test("_test_battle_unit_framework", _test_battle_unit_framework()) and ok
	ok = _report_test("_test_status_field_helpers", _test_status_field_helpers()) and ok
	ok = _report_test("_test_battle_side_framework", _test_battle_side_framework()) and ok
	ok = _report_test("_test_hand_limit_and_turn_end_reshuffle", _test_hand_limit_and_turn_end_reshuffle()) and ok
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
	ok = _report_test("_test_first_edition_interaction_cards", _test_first_edition_interaction_cards()) and ok
	ok = _report_test("_test_noop_card_and_negative_defense", _test_noop_card_and_negative_defense()) and ok
	ok = _report_test("_test_inactive_enemy_deck_candidates", _test_inactive_enemy_deck_candidates()) and ok
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

func _isolate_enemy_unit_actions(battle) -> void:
	if battle == null or battle.enemy_side == null or battle.enemy_side.deck_manager == null:
		return
	battle.enemy_side.draw_per_turn = 0
	battle.enemy_side.deck_ids.clear()
	var manager: DeckManager = battle.enemy_side.deck_manager
	manager.deck.clear()
	manager.hand.clear()
	manager.graveyard.clear()
	manager.exile.clear()
	manager.messages.clear()
	manager.reshuffle_pending = false

func _battle_request_state_signature(battle) -> Dictionary:
	return {
		"phase": str(battle.phase),
		"player_hp": int(battle.player.hp),
		"enemy_hp": int(battle.enemy.hp),
		"hand_size": int(battle.deck.hand.size()),
		"deck_size": int(battle.deck.deck.size()),
		"graveyard_size": int(battle.deck.graveyard.size()),
		"exile_size": int(battle.deck.exile.size()),
		"player_actions": battle.player_unit_actions_used.duplicate(true),
		"pending_target": battle.pending_target_action.duplicate(true)
	}

func _battle_request_state_unchanged(before: Dictionary, battle) -> bool:
	return str(before) == str(_battle_request_state_signature(battle))

func _test_sword_start_and_attack() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	if battle.player.job_name != "剑修":
		return false
	if battle.deck.hand.size() != DeckManagerScript.DEFAULT_HAND_LIMIT:
		return false
	var first_target = battle.selected_enemy_unit()
	if first_target == null:
		return false
	first_target.defense = 0
	first_target.hp = max(first_target.hp, 20)
	var before_hp: int = first_target.hp
	if not _submit_request_accepted(battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_PLAYER,
		"source_uid": str(battle.player.uid),
		"target_uid": str(first_target.uid)
	}):
		return false
	if first_target.hp >= before_hp:
		return false
	if battle.player.sword_momentum < 1:
		return false
	return true

func _test_battle_opening_draw_rules() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	if battle.deck.hand.size() != DeckManagerScript.DEFAULT_HAND_LIMIT:
		return false
	if battle.deck.deck.size() != battle.master_deck_ids.size() - DeckManagerScript.DEFAULT_HAND_LIMIT:
		return false
	if battle.enemy_side.deck_manager.hand.size() != 0:
		return false

	var enemy_turn_battle = BattleManagerScript.new()
	enemy_turn_battle.start_run("sword")
	var enemy_manager: DeckManager = enemy_turn_battle.enemy_side.deck_manager
	enemy_manager.hand.clear()
	enemy_manager.deck.clear()
	enemy_manager.graveyard.clear()
	enemy_manager.exile.clear()
	enemy_manager.deck.append(CardDatabaseScript.make_card("heal_wound"))
	enemy_turn_battle.enemy.hp = enemy_turn_battle.enemy.max_hp
	enemy_turn_battle.enemy_side.draw_per_turn = 1
	enemy_turn_battle.call("_start_enemy_turn")
	return enemy_manager.hand.size() == 1 and str(enemy_manager.hand[0].get("id", "")) == "heal_wound"

func _test_player_battle_request_entrypoints() -> bool:
	var card_battle = BattleManagerScript.new()
	card_battle.start_run("sword")
	card_battle.deck.hand.clear()
	var blank_card := CardDatabaseScript.make_card("blank_card")
	card_battle.deck.hand.append(blank_card)
	var blank_uid := str(blank_card.get("uid", ""))
	if not _submit_request_accepted(card_battle, {
		"type": "play_card",
		"side": BattleUnitScript.TEAM_PLAYER,
		"card_uid": blank_uid
	}):
		return false
	if not card_battle.deck.find_hand_card(blank_uid).is_empty():
		return false
	if card_battle.deck.graveyard.size() < 1:
		return false

	var target_card_battle = BattleManagerScript.new()
	target_card_battle.start_run("sword")
	if not target_card_battle.debug_add_enemy():
		return false
	target_card_battle.deck.hand.clear()
	var poison_card := CardDatabaseScript.make_card("poison")
	target_card_battle.deck.hand.append(poison_card)
	var poison_uid := str(poison_card.get("uid", ""))
	if not _submit_request_accepted(target_card_battle, {
		"type": "play_card",
		"side": BattleUnitScript.TEAM_PLAYER,
		"card_uid": poison_uid
	}):
		return false
	if target_card_battle.phase != "target_select":
		return false
	var target_uid := str(target_card_battle.formation.living_units(BattleUnitScript.TEAM_ENEMY)[0].uid)
	target_card_battle.confirm_target_selection(target_uid)
	if not target_card_battle.deck.find_hand_card(poison_uid).is_empty():
		return false

	var attack_battle = BattleManagerScript.new()
	attack_battle.start_run("sword")
	var attack_target = attack_battle.selected_enemy_unit()
	if attack_target == null:
		return false
	attack_target.defense = 0
	var enemy_hp_before: int = attack_target.hp
	if not _submit_request_accepted(attack_battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_PLAYER,
		"source_uid": str(attack_battle.player.uid),
		"target_uid": str(attack_target.uid)
	}):
		return false
	if attack_target.hp >= enemy_hp_before:
		return false

	var defend_battle = BattleManagerScript.new()
	defend_battle.start_run("sword")
	var defense_before: int = defend_battle.player.temp_defense_delta
	if not _submit_request_accepted(defend_battle, {
		"type": "unit_defend",
		"side": BattleUnitScript.TEAM_PLAYER,
		"source_uid": str(defend_battle.player.uid)
	}):
		return false
	if defend_battle.player.temp_defense_delta <= defense_before:
		return false

	var end_battle = BattleManagerScript.new()
	end_battle.start_run("sword")
	_isolate_enemy_unit_actions(end_battle)
	end_battle.enemy.attack = 0
	var end_phase_before := str(end_battle.phase)
	var end_turn_before: int = end_battle.turn_number
	if not _submit_request_accepted(end_battle, {
		"type": "end_turn",
		"side": BattleUnitScript.TEAM_PLAYER
	}):
		return false
	if str(end_battle.phase) == end_phase_before and end_battle.turn_number <= end_turn_before:
		return false

	var invalid_side_battle = BattleManagerScript.new()
	invalid_side_battle.start_run("sword")
	var invalid_side_before := _battle_request_state_signature(invalid_side_battle)
	if _submit_request_accepted(invalid_side_battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(invalid_side_battle.player.uid)
	}):
		return false
	if not _battle_request_state_unchanged(invalid_side_before, invalid_side_battle):
		return false

	var invalid_phase_battle = BattleManagerScript.new()
	invalid_phase_battle.start_run("sword")
	invalid_phase_battle.phase = "enemy"
	var invalid_phase_before := _battle_request_state_signature(invalid_phase_battle)
	if _submit_request_accepted(invalid_phase_battle, {
		"type": "end_turn",
		"side": BattleUnitScript.TEAM_PLAYER
	}):
		return false
	if not _battle_request_state_unchanged(invalid_phase_before, invalid_phase_battle):
		return false

	var invalid_source_battle = BattleManagerScript.new()
	invalid_source_battle.start_run("sword")
	var invalid_source_before := _battle_request_state_signature(invalid_source_battle)
	if _submit_request_accepted(invalid_source_battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_PLAYER,
		"source_uid": "missing_unit"
	}):
		return false
	if not _battle_request_state_unchanged(invalid_source_before, invalid_source_battle):
		return false

	var invalid_card_battle = BattleManagerScript.new()
	invalid_card_battle.start_run("sword")
	var invalid_card_before := _battle_request_state_signature(invalid_card_battle)
	if _submit_request_accepted(invalid_card_battle, {
		"type": "play_card",
		"side": BattleUnitScript.TEAM_PLAYER,
		"card_uid": "missing_card"
	}):
		return false
	if not _battle_request_state_unchanged(invalid_card_before, invalid_card_battle):
		return false

	var invalid_target_battle = BattleManagerScript.new()
	invalid_target_battle.start_run("sword")
	invalid_target_battle.deck.hand.clear()
	var heal_card := CardDatabaseScript.make_card("heal_wound")
	invalid_target_battle.deck.hand.append(heal_card)
	var invalid_target_before := _battle_request_state_signature(invalid_target_battle)
	if _submit_request_accepted(invalid_target_battle, {
		"type": "play_card",
		"side": BattleUnitScript.TEAM_PLAYER,
		"card_uid": str(heal_card.get("uid", "")),
		"target_uid": "missing_target"
	}):
		return false
	return _battle_request_state_unchanged(invalid_target_before, invalid_target_battle)

func _test_enemy_battle_request_entrypoints() -> bool:
	var missing_side_battle = BattleManagerScript.new()
	missing_side_battle.start_run("sword")
	var missing_side_before := _battle_request_state_signature(missing_side_battle)
	if _submit_request_accepted(missing_side_battle, {
		"type": "end_turn"
	}):
		return false
	if not _battle_request_state_unchanged(missing_side_before, missing_side_battle):
		return false

	var unknown_side_battle = BattleManagerScript.new()
	unknown_side_battle.start_run("sword")
	var unknown_side_before := _battle_request_state_signature(unknown_side_battle)
	if _submit_request_accepted(unknown_side_battle, {
		"type": "play_card",
		"side": "unknown",
		"card_uid": "missing"
	}):
		return false
	if not _battle_request_state_unchanged(unknown_side_before, unknown_side_battle):
		return false

	var enemy_request_battle = BattleManagerScript.new()
	enemy_request_battle.start_run("sword")
	enemy_request_battle.phase = "enemy"
	enemy_request_battle.enemy_action_queue.clear()
	enemy_request_battle.enemy_side.deck_manager.hand.clear()
	var poison_card := CardDatabaseScript.make_card("poison")
	enemy_request_battle.enemy_side.deck_manager.hand.append(poison_card)
	var enemy_source = enemy_request_battle.formation.primary_enemy()
	if enemy_source == null:
		return false
	if not _submit_request_accepted(enemy_request_battle, {
		"type": "play_card",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(enemy_source.uid),
		"card_uid": str(poison_card.get("uid", "")),
		"target_uid": str(enemy_request_battle.player.uid)
	}):
		return false
	if enemy_request_battle.player.get_status("poison") != 1:
		return false
	if not enemy_request_battle.enemy_side.deck_manager.hand.is_empty():
		return false
	if enemy_request_battle.enemy_side.deck_manager.graveyard.size() != 1:
		return false
	if str(enemy_request_battle.enemy_side.deck_manager.graveyard[0].get("id", "")) != "poison":
		return false

	var fallback_battle = BattleManagerScript.new()
	fallback_battle.start_run("sword")
	fallback_battle.phase = "enemy"
	fallback_battle.enemy_action_queue.clear()
	fallback_battle.enemy_side.deck_manager.hand.clear()
	var invalid_enemy_card := CardDatabaseScript.make_card("blank_card")
	invalid_enemy_card.erase("uid")
	fallback_battle.enemy_side.deck_manager.hand.append(invalid_enemy_card)
	var fallback_turn_before: int = fallback_battle.turn_number
	fallback_battle.call("_finish_enemy_side_card")
	if fallback_battle.phase != "player":
		return false
	if fallback_battle.turn_number <= fallback_turn_before:
		return false
	if fallback_battle.enemy_side.deck_manager.hand.size() != 1:
		return false
	return str(fallback_battle.enemy_side.deck_manager.hand[0].get("id", "")) == "blank_card"

func _test_enemy_unit_action_request_entrypoints() -> bool:
	var normal_battle = BattleManagerScript.new()
	normal_battle.start_run("sword")
	normal_battle.phase = "enemy"
	normal_battle.enemy_action_queue.clear()
	normal_battle.player.spell_zone.clear()
	var normal_source = normal_battle.formation.primary_enemy()
	if normal_source == null:
		return false
	var normal_hp_before: int = normal_battle.player.hp
	var normal_power: int = int(normal_source.current_attack())
	if not _submit_request_accepted(normal_battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(normal_source.uid),
		"target_uid": str(normal_battle.player.uid),
		"power": normal_power,
		"normal_attack": true
	}):
		return false
	if normal_battle.player.hp != normal_hp_before - max(0, normal_power - normal_battle.player.current_defense()):
		return false

	var strong_battle = BattleManagerScript.new()
	strong_battle.start_run("sword")
	strong_battle.phase = "enemy"
	strong_battle.enemy_action_queue.clear()
	strong_battle.player.spell_zone.clear()
	var strong_source = strong_battle.formation.primary_enemy()
	if strong_source == null:
		return false
	var strong_hp_before: int = strong_battle.player.hp
	var strong_power: int = int(strong_source.current_attack()) + 3
	if not _submit_request_accepted(strong_battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(strong_source.uid),
		"target_uid": str(strong_battle.player.uid),
		"power": strong_power,
		"normal_attack": false
	}):
		return false
	if strong_battle.player.hp != strong_hp_before - max(0, strong_power - strong_battle.player.current_defense()):
		return false

	var defend_battle = BattleManagerScript.new()
	defend_battle.start_run("sword")
	defend_battle.phase = "enemy"
	defend_battle.enemy_action_queue.clear()
	var defend_source = defend_battle.formation.primary_enemy()
	if defend_source == null:
		return false
	var defense_delta: int = 4
	if not _submit_request_accepted(defend_battle, {
		"type": "unit_defend",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(defend_source.uid),
		"defense_delta": defense_delta,
		"action_kind": "defense_stance"
	}):
		return false
	if defend_source.temp_defense_delta != defense_delta or defend_battle.phase != "player":
		return false

	var weakness_battle = BattleManagerScript.new()
	weakness_battle.start_run("sword")
	weakness_battle.phase = "enemy"
	weakness_battle.enemy_action_queue.clear()
	var weakness_source = weakness_battle.formation.primary_enemy()
	if weakness_source == null:
		return false
	var weakness_delta: int = -2
	if not _submit_request_accepted(weakness_battle, {
		"type": "unit_defend",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(weakness_source.uid),
		"defense_delta": weakness_delta,
		"action_kind": "weakness"
	}):
		return false
	if weakness_source.temp_defense_delta != weakness_delta or weakness_battle.phase != "player":
		return false

	var invalid_side_battle = BattleManagerScript.new()
	invalid_side_battle.start_run("sword")
	invalid_side_battle.phase = "enemy"
	var invalid_side_before := _battle_request_state_signature(invalid_side_battle)
	if _submit_request_accepted(invalid_side_battle, {
		"type": "unit_attack",
		"side": "unknown",
		"source_uid": str(invalid_side_battle.enemy.uid),
		"target_uid": str(invalid_side_battle.player.uid)
	}):
		return false
	if not _battle_request_state_unchanged(invalid_side_before, invalid_side_battle):
		return false

	var invalid_phase_battle = BattleManagerScript.new()
	invalid_phase_battle.start_run("sword")
	var invalid_phase_before := _battle_request_state_signature(invalid_phase_battle)
	if _submit_request_accepted(invalid_phase_battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(invalid_phase_battle.enemy.uid),
		"target_uid": str(invalid_phase_battle.player.uid)
	}):
		return false
	if not _battle_request_state_unchanged(invalid_phase_before, invalid_phase_battle):
		return false

	var invalid_target_battle = BattleManagerScript.new()
	invalid_target_battle.start_run("sword")
	invalid_target_battle.phase = "enemy"
	var invalid_target_before := _battle_request_state_signature(invalid_target_battle)
	if _submit_request_accepted(invalid_target_battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(invalid_target_battle.enemy.uid),
		"target_uid": "missing_target"
	}):
		return false
	if not _battle_request_state_unchanged(invalid_target_before, invalid_target_battle):
		return false

	var fallback_battle = BattleManagerScript.new()
	fallback_battle.start_run("sword")
	fallback_battle.phase = "player"
	fallback_battle.enemy_action_queue.clear()
	var fallback_source = fallback_battle.formation.primary_enemy()
	if fallback_source == null:
		return false
	var fallback_turn_before: int = fallback_battle.turn_number
	if bool(fallback_battle.call("_enemy_attack", fallback_source, fallback_source.current_attack())):
		return false
	return fallback_battle.phase == "player" and fallback_battle.turn_number > fallback_turn_before

func _test_enemy_spell_attack_request_entrypoint() -> bool:
	var spell_battle = BattleManagerScript.new()
	spell_battle.start_run("sword")
	spell_battle.phase = "enemy"
	spell_battle.enemy_action_queue.clear()
	spell_battle.player.spell_zone.clear()
	var spell_source = spell_battle.formation.primary_enemy()
	if spell_source == null:
		return false
	var spell_power: int = int(spell_source.current_attack())
	var spell_hp_before: int = spell_battle.player.hp
	if not _submit_request_accepted(spell_battle, {
		"type": "spell_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(spell_source.uid),
		"target_uid": str(spell_battle.player.uid),
		"power": spell_power
	}):
		return false
	if spell_battle.player.hp != spell_hp_before - max(0, spell_power - spell_battle.player.current_defense()):
		return false

	var delay_battle = BattleManagerScript.new()
	delay_battle.start_run("sword")
	delay_battle.phase = "enemy"
	delay_battle.enemy_action_queue.clear()
	delay_battle.player.spell_zone.clear()
	var delay_source = delay_battle.formation.primary_enemy()
	if delay_source == null:
		return false
	delay_source.add_status("迟滞", 2)
	var delay_power: int = int(delay_source.current_attack())
	var delay_hp_before: int = delay_battle.player.hp
	if not _submit_request_accepted(delay_battle, {
		"type": "spell_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(delay_source.uid),
		"target_uid": str(delay_battle.player.uid),
		"power": delay_power
	}):
		return false
	if delay_source.get_status("迟滞") != 0:
		return false
	if delay_battle.player.hp != delay_hp_before - max(0, delay_power - 2 - delay_battle.player.current_defense()):
		return false

	var response_battle = BattleManagerScript.new()
	response_battle.start_run("sword")
	response_battle.phase = "enemy"
	response_battle.enemy_action_queue.clear()
	response_battle.player.spell_zone.append(_ready_defense("破法符"))
	var response_source = response_battle.formation.primary_enemy()
	if response_source == null:
		return false
	var response_hp_before: int = response_battle.player.hp
	if not _submit_request_accepted(response_battle, {
		"type": "spell_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(response_source.uid),
		"target_uid": str(response_battle.player.uid),
		"power": int(response_source.current_attack())
	}):
		return false
	if response_battle.phase != "response" or response_battle.current_event.get("event_type", "") != "enemy_spell_declared":
		return false
	_play_response(response_battle, str(response_battle.player.spell_zone[0].get("uid", "")))
	if response_battle.phase != "player" or response_battle.player.hp != response_hp_before:
		return false

	var missing_side_battle = BattleManagerScript.new()
	missing_side_battle.start_run("sword")
	missing_side_battle.phase = "enemy"
	var missing_side_before := _battle_request_state_signature(missing_side_battle)
	if _submit_request_accepted(missing_side_battle, {
		"type": "spell_attack",
		"source_uid": str(missing_side_battle.enemy.uid),
		"target_uid": str(missing_side_battle.player.uid)
	}):
		return false
	if not _battle_request_state_unchanged(missing_side_before, missing_side_battle):
		return false

	var unknown_side_battle = BattleManagerScript.new()
	unknown_side_battle.start_run("sword")
	unknown_side_battle.phase = "enemy"
	var unknown_side_before := _battle_request_state_signature(unknown_side_battle)
	if _submit_request_accepted(unknown_side_battle, {
		"type": "spell_attack",
		"side": "unknown",
		"source_uid": str(unknown_side_battle.enemy.uid),
		"target_uid": str(unknown_side_battle.player.uid)
	}):
		return false
	if not _battle_request_state_unchanged(unknown_side_before, unknown_side_battle):
		return false

	var invalid_phase_battle = BattleManagerScript.new()
	invalid_phase_battle.start_run("sword")
	var invalid_phase_before := _battle_request_state_signature(invalid_phase_battle)
	if _submit_request_accepted(invalid_phase_battle, {
		"type": "spell_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(invalid_phase_battle.enemy.uid),
		"target_uid": str(invalid_phase_battle.player.uid)
	}):
		return false
	if not _battle_request_state_unchanged(invalid_phase_before, invalid_phase_battle):
		return false

	var invalid_source_battle = BattleManagerScript.new()
	invalid_source_battle.start_run("sword")
	invalid_source_battle.phase = "enemy"
	var invalid_source_before := _battle_request_state_signature(invalid_source_battle)
	if _submit_request_accepted(invalid_source_battle, {
		"type": "spell_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": "missing_source",
		"target_uid": str(invalid_source_battle.player.uid)
	}):
		return false
	if not _battle_request_state_unchanged(invalid_source_before, invalid_source_battle):
		return false

	var invalid_target_battle = BattleManagerScript.new()
	invalid_target_battle.start_run("sword")
	invalid_target_battle.phase = "enemy"
	var invalid_target_before := _battle_request_state_signature(invalid_target_battle)
	if _submit_request_accepted(invalid_target_battle, {
		"type": "spell_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(invalid_target_battle.enemy.uid),
		"target_uid": "missing_target"
	}):
		return false
	if not _battle_request_state_unchanged(invalid_target_before, invalid_target_battle):
		return false

	var fallback_battle = BattleManagerScript.new()
	fallback_battle.start_run("sword")
	fallback_battle.phase = "player"
	fallback_battle.enemy_action_queue.clear()
	var fallback_source = fallback_battle.formation.primary_enemy()
	if fallback_source == null:
		return false
	var fallback_turn_before: int = fallback_battle.turn_number
	if bool(fallback_battle.call("_enemy_spell_attack", fallback_source)):
		return false
	return fallback_battle.phase == "player" and fallback_battle.turn_number > fallback_turn_before

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
	battle.enemy.defense = 0
	for i in range(1, battle.formation.enemy_units.size()):
		var extra_enemy = battle.formation.enemy_units[i]
		if extra_enemy != null:
			extra_enemy.hp = 0
	if not _submit_request_accepted(battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_PLAYER,
		"source_uid": str(battle.player.uid),
		"target_uid": str(battle.enemy.uid)
	}):
		return false
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
	_play_response(battle, str(available[0].get("uid", "")))
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
	var first_response: bool = _play_response(battle, str(guard.get("uid", "")))
	if battle.phase != "response":
		return false
	var second_response: bool = _play_response(battle, str(hide_blade.get("uid", "")))
	var passed: bool = battle.phase == "player" and battle.player.hp == hp_before - expected_damage and battle.enemy.hp < enemy_hp_before and battle.deck.graveyard.size() >= 2
	if not passed:
		push_error("response chain diagnostics first=%s second=%s phase=%s hp=%d expected=%d enemy_hp=%d grave=%d" % [first_response, second_response, battle.phase, battle.player.hp, hp_before - expected_damage, battle.enemy.hp, battle.deck.graveyard.size()])
	return passed

func _test_battle_event_field_normalization() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var event: Dictionary = battle.create_event("player_damage_before", "enemy_attack", battle.player, 5)
	if battle.battle_event_type(event) != "player_damage_before":
		return false
	if battle.battle_event_source_key(event) != "enemy_attack" or battle.battle_event_target_key(event) != "player":
		return false
	if battle.battle_event_value(event) != 5 or battle.battle_event_cancelled(event):
		return false
	if not (battle.battle_event_modifiers(event) is Array) or not (battle.battle_event_protected_targets(event) is Array):
		return false
	event["modifiers"] = "invalid"
	event["protected_targets"] = "invalid"
	var guard := _ready_defense("护身符")
	battle.player.spell_zone.append(guard)
	var available := battle.get_available_responses(event)
	if available.size() != 1 or str(available[0].get("uid", "")) != str(guard.get("uid", "")):
		return false
	if not (battle.battle_event_modifiers(event) is Array) or not (battle.battle_event_protected_targets(event) is Array):
		return false
	battle.set_battle_event_value(event, 3)
	battle.set_battle_event_cancelled(event, true)
	return battle.battle_event_value(event) == 3 and battle.battle_event_cancelled(event)

func _test_response_chain_link_lifecycle() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var guard := _ready_defense("护身符")
	var hide_blade := _ready_defense("藏锋")
	battle.player.spell_zone.append(guard)
	battle.player.spell_zone.append(hide_blade)
	var event: Dictionary = battle.create_event("player_damage_before", "enemy_attack", battle.player, 6)
	battle.open_timing_window(event)
	if battle.phase != "response" or not battle.response_chain_can_append():
		return false
	if battle.response_chain_link_count() != 0:
		return false
	_play_response(battle, str(guard.get("uid", "")))
	if battle.response_chain_link_count() != 1:
		return false
	if not battle.response_chain_can_append():
		return false
	var link_value = battle.chain_stack[0]
	if not (link_value is Dictionary):
		return false
	var link: Dictionary = link_value
	if battle.chain_link_card_uid(link) != str(guard.get("uid", "")):
		return false
	if battle.chain_link_card_id(link) != "护身符":
		return false
	if battle.chain_link_event_type(link) != "player_damage_before":
		return false
	if str(link.get("source_zone", "")) != "spell_zone" or str(link.get("controller_side", "")) != "player":
		return false
	if int(link.get("chain_index", -1)) != 0:
		return false
	if battle.chain_link_locked(link) or battle.chain_link_resolved(link):
		return false
	_play_response(battle, str(guard.get("uid", "")))
	if battle.response_chain_link_count() != 1:
		return false
	_skip_response(battle)
	if not battle.response_chain_was_skipped() or not battle.response_chain_is_resolved():
		return false
	if battle.response_chain_link_count() != 0:
		return false
	var hp_after: int = battle.player.hp
	var graveyard_after: int = battle.deck.graveyard.size()
	_play_response(battle, str(hide_blade.get("uid", "")))
	if battle.response_chain_link_count() != 0 or battle.deck.graveyard.size() != graveyard_after:
		return false
	battle.resolve_chain(event)
	return battle.player.hp == hp_after and battle.deck.graveyard.size() == graveyard_after

func _test_response_window_owner_pass_state() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var guard := _ready_defense("护身符")
	var hide_blade := _ready_defense("藏锋")
	battle.player.spell_zone.append(guard)
	battle.player.spell_zone.append(hide_blade)
	var event: Dictionary = battle.create_event("player_damage_before", "enemy_attack", battle.player, 6)
	battle.open_timing_window(event)
	if battle.phase != "response" or not battle.response_chain_can_append():
		return false
	if battle.response_window_owner() != BattleUnitScript.TEAM_PLAYER or battle.response_active_side() != BattleUnitScript.TEAM_PLAYER:
		return false
	if not battle.response_window_is_player_only():
		return false
	var pass_state: Dictionary = battle.response_pass_state_snapshot()
	if not pass_state.has(BattleUnitScript.TEAM_PLAYER) or bool(pass_state.get(BattleUnitScript.TEAM_PLAYER, true)):
		return false
	if pass_state.has(BattleUnitScript.TEAM_ENEMY):
		return false
	if _skip_response_for_side(battle, BattleUnitScript.TEAM_ENEMY):
		return false
	if _skip_response_for_side(battle, "unknown"):
		return false
	if battle.phase != "response" or not battle.response_chain_can_append():
		return false
	_play_response(battle, str(guard.get("uid", "")))
	if battle.response_chain_link_count() != 1:
		return false
	var link_value = battle.chain_stack[0]
	if not (link_value is Dictionary):
		return false
	var link: Dictionary = link_value
	if str(link.get("controller_side", "")) != BattleUnitScript.TEAM_PLAYER:
		return false
	if battle.response_side_passed(BattleUnitScript.TEAM_PLAYER):
		return false
	_skip_response(battle)
	if not battle.response_chain_was_skipped() or not battle.response_side_passed(BattleUnitScript.TEAM_PLAYER):
		return false
	var closed_pass_state: Dictionary = battle.response_pass_state_snapshot()
	if closed_pass_state.has(BattleUnitScript.TEAM_ENEMY):
		return false
	if not battle.response_chain_is_resolved() or battle.response_chain_link_count() != 0:
		return false
	var hp_after: int = battle.player.hp
	var graveyard_after: int = battle.deck.graveyard.size()
	_play_response(battle, str(guard.get("uid", "")))
	battle.resolve_chain(event)
	return battle.player.hp == hp_after and battle.deck.graveyard.size() == graveyard_after

func _test_response_window_rules_shell() -> bool:
	var pass_state: Dictionary = ResponseWindowRulesScript.default_pass_state()
	if not ResponseWindowRulesScript.is_player_only(ResponseWindowRulesScript.default_owner_side(), ResponseWindowRulesScript.default_active_side(), pass_state):
		return false
	if ResponseWindowRulesScript.side_passed(pass_state, BattleUnitScript.TEAM_PLAYER):
		return false
	if pass_state.has(BattleUnitScript.TEAM_ENEMY):
		return false
	if ResponseWindowRulesScript.set_side_passed(pass_state, BattleUnitScript.TEAM_ENEMY, true):
		return false
	if not ResponseWindowRulesScript.set_side_passed(pass_state, BattleUnitScript.TEAM_PLAYER, true):
		return false
	if not ResponseWindowRulesScript.skipped_from_pass_state(pass_state):
		return false
	if ResponseWindowRulesScript.can_append("response", "open", {"event_type": "player_damage_before"}, BattleUnitScript.TEAM_PLAYER, pass_state, "open"):
		return false
	var fresh_pass_state: Dictionary = ResponseWindowRulesScript.default_pass_state()
	if not ResponseWindowRulesScript.can_append("response", "open", {"event_type": "player_damage_before"}, BattleUnitScript.TEAM_PLAYER, fresh_pass_state, "open"):
		return false
	var card := {"uid": "card_uid_1", "id": "test_card", "name": "测试牌"}
	var link: Dictionary = ResponseWindowRulesScript.make_chain_link(card, "player_damage_before", 3)
	if ResponseWindowRulesScript.chain_link_card_uid(link) != "card_uid_1":
		return false
	if ResponseWindowRulesScript.chain_link_card_id(link) != "test_card":
		return false
	if ResponseWindowRulesScript.chain_link_controller_side(link) != BattleUnitScript.TEAM_PLAYER:
		return false
	if ResponseWindowRulesScript.chain_link_event_type(link) != "player_damage_before":
		return false
	if ResponseWindowRulesScript.chain_link_chain_index(link) != 3:
		return false
	if ResponseWindowRulesScript.chain_link_locked(link) or ResponseWindowRulesScript.chain_link_resolved(link):
		return false
	var stack: Array = [link]
	ResponseWindowRulesScript.lock_chain_links(stack)
	var locked_link: Dictionary = stack[0]
	if not ResponseWindowRulesScript.chain_link_locked(locked_link):
		return false
	ResponseWindowRulesScript.mark_chain_link_resolved(locked_link)
	return ResponseWindowRulesScript.chain_link_resolved(locked_link)

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
	_play_response(battle, str(hide_blade.get("uid", "")))
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
	_skip_response(battle)
	return battle.phase == "player" and battle.player.hp < hp_before

func _test_counter_spell_response() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	battle.player.spell_zone.append(_ready_defense("破法符"))
	var hp_before: int = battle.player.hp
	battle.open_timing_window(battle.create_event("enemy_spell_declared", "enemy", "player", 8))
	if battle.phase != "response":
		return false
	_play_response(battle, str(battle.player.spell_zone[0].get("uid", "")))
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
	_play_response(battle, str(battle.player.spell_zone[1].get("uid", "")))
	return battle.phase == "player" and battle.player.spell_zone.size() == 1 and battle.player.spell_zone[0].get("id", "") == "封存秘卷"

func _test_lethal_response() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	battle.player.hp = 3
	battle.player.spell_zone.append(_ready_defense("替身纸人"))
	battle.open_timing_window(battle.create_event("player_damage_before", "enemy_attack", "player", 10))
	if battle.phase != "response" or battle.current_event.get("event_type", "") != "player_lethal_damage_before":
		return false
	_play_response(battle, str(battle.player.spell_zone[0].get("uid", "")))
	return battle.phase == "player" and battle.player.hp == 1 and battle.deck.exile.size() == 1

func _test_event_window_continues_without_responses() -> bool:
	var attack_battle = BattleManagerScript.new()
	attack_battle.start_run("sword")
	_isolate_enemy_unit_actions(attack_battle)
	attack_battle.player.spell_zone.clear()
	var attack_hp_before: int = attack_battle.player.hp
	var expected_attack_damage: int = max(0, attack_battle.enemy.current_attack() - attack_battle.player.current_defense())
	attack_battle.end_player_turn()
	if attack_battle.phase == "response":
		return false
	if attack_battle.phase != "player" or attack_battle.player.hp != attack_hp_before - expected_attack_damage:
		return false

	var spell_battle = BattleManagerScript.new()
	spell_battle.start_run("sword")
	_isolate_enemy_unit_actions(spell_battle)
	spell_battle.player.spell_zone.clear()
	var spell_hp_before: int = spell_battle.player.hp
	var expected_spell_damage: int = max(0, 8 - spell_battle.player.current_defense())
	spell_battle.open_timing_window(spell_battle.create_event("enemy_spell_declared", "enemy", spell_battle.player, 8))
	if spell_battle.phase == "response":
		return false
	if spell_battle.player.hp != spell_hp_before - expected_spell_damage:
		return false

	var mirror_battle = BattleManagerScript.new()
	mirror_battle.start_run("sword")
	mirror_battle.player.spell_zone.clear()
	var mirror := CardDatabaseScript.make_card("护心镜")
	mirror_battle.deck.hand.append(mirror)
	mirror_battle.play_hand_card(str(mirror.get("uid", "")))
	mirror_battle.player.hp = 3
	mirror_battle.open_timing_window(mirror_battle.create_event("player_damage_before", "test", mirror_battle.player, 10))
	if mirror_battle.phase == "response":
		return false
	return mirror_battle.player.hp == 1 and mirror_battle.player.equipment.is_empty() and mirror_battle.phase != "defeat"

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

func _test_equipment_helper_snapshots() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var sword_card := CardDatabaseScript.make_card("青锋剑")
	var armor_card := CardDatabaseScript.make_card("铁木甲")
	battle.deck.hand.append(sword_card)
	battle.deck.hand.append(armor_card)
	var attack_before: int = battle.player.current_attack()
	var defense_before: int = battle.player.current_defense()
	battle.play_hand_card(str(sword_card.get("uid", "")))
	battle.play_hand_card(str(armor_card.get("uid", "")))
	if battle.player.equipment_count() != 2:
		return false
	var bonus_snapshot: Dictionary = battle.player.equipment_stat_bonus_snapshot()
	if int(bonus_snapshot.get("attack_bonus", -1)) != 2 or int(bonus_snapshot.get("defense_bonus", -1)) != 1:
		return false
	var records: Array = battle.player.equipment_records_snapshot()
	if records.size() != 2:
		return false
	var sword_uid := str(sword_card.get("uid", ""))
	var snapshot: Dictionary = battle.player.equipment_snapshot()
	var sword_record: Dictionary = snapshot.get(sword_uid, {})
	if sword_record.is_empty():
		return false
	if str(sword_record.get("card_uid", "")) != sword_uid or str(sword_record.get("uid", "")) != sword_uid:
		return false
	if str(sword_record.get("card_id", "")) != "青锋剑" or str(sword_record.get("id", "")) != "青锋剑":
		return false
	if str(sword_record.get("equipped_to_uid", "")) != str(battle.player.uid):
		return false
	if str(sword_record.get("host_uid", "")) != str(battle.player.uid) or str(sword_record.get("host_side", "")) != "player":
		return false
	if str(sword_record.get("owner_side", "")) != "player" or str(sword_record.get("controller_side", "")) != "player":
		return false
	if str(sword_record.get("source_zone", "")) != "equipment":
		return false
	if int(sword_record.get("attack_bonus", 0)) != 2 or int(sword_record.get("defense_bonus", 0)) != 0:
		return false
	var effect_kinds: Array = sword_record.get("effect_kinds", [])
	if not effect_kinds.has("equipment_attack_bonus"):
		return false
	if str(sword_record.get("cleanup_scope", "")) != "battle" or str(sword_record.get("leave_scope", "")) != "battle":
		return false
	if str(battle.player.find_equipment_by_uid(sword_uid).get("id", "")) != "青锋剑":
		return false
	if str(battle.player.find_equipment_by_card_id("铁木甲").get("id", "")) != "铁木甲":
		return false
	var removed: Dictionary = battle.player.remove_equipment_by_uid(sword_uid)
	if str(removed.get("id", "")) != "青锋剑":
		return false
	battle.player.remove_equipment_effects(removed)
	if battle.player.equipment_count() != 1:
		return false
	return battle.player.current_attack() == attack_before and battle.player.current_defense() == defense_before + 1

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
	var deck_ids := ["poison", "poison", "poison"]
	if not DeckBuildRulesScript.can_add_card_to_deck("poison", deck_ids, 0):
		return false
	if not DeckBuildRulesScript.can_add_card_to_deck("quick_draw", deck_ids, 20):
		return false
	if DeckBuildRulesScript.can_add_card_to_deck("quick_draw", deck_ids, DeckBuildRulesScript.deck_score(deck_ids) + DeckBuildRulesScript.card_score("quick_draw") - 1):
		return false
	var full_deck: Array = []
	for i in range(DeckBuildRulesScript.max_deck_size()):
		full_deck.append("poison")
	if DeckBuildRulesScript.can_add_card_to_deck("quick_draw", full_deck, 0):
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
		over_deck.append("poison")
	if run_state.apply_deck_build(over_deck, []) == "":
		return false
	var full_deck: Array = []
	for i in range(DeckBuildRulesScript.max_deck_size()):
		full_deck.append("poison")
	var battle = BattleManagerScript.new()
	battle.start_run_with_deck("sword", full_deck, 1, "normal", false, {"deck_score_limit": 999})
	battle.phase = "reward"
	battle.reward_options = ["quick_draw"]
	battle.choose_reward("quick_draw")
	return battle.phase == "map_complete" and battle.master_reserve_ids.has("quick_draw")

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
	var ally_targeted_card := {
		"type": CardDefinitionDatabaseScript.TYPE_SPELL,
		"after_use": "graveyard",
		"target_scope": "ally_unit",
		"effect": {"kind": "add_status", "target": "context_target", "status": "next_damage_reduce", "value": 1}
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
	if CardInteractionRulesScript.card_drag_rule(ally_targeted_card) != "ally_unit":
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
				"points_total": 5,
				"points_spent": 3,
				"upgrades": {"attack": 2, "max_hp": 1}
			}
		}
	})
	if int(migrated_progression.get("version", 0)) != SaveMigrationServiceScript.CURRENT_META_PROGRESSION_VERSION:
		return false
	var migrated_sword: Dictionary = ((migrated_progression.get("jobs", {}) as Dictionary).get("sword", {}) as Dictionary)
	var migrated_upgrades: Dictionary = (migrated_sword.get("upgrades", {}) as Dictionary)
	if int(migrated_sword.get("points_total", -1)) != 5 or int(migrated_upgrades.get("attack", -1)) != 2 or int(migrated_upgrades.get("max_hp", -1)) != 1:
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
	return true

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
	if normal_pool.has("blank_card") or locked_boss_pool.has("blank_card"):
		return false
	if normal_pool.has("火球符") or locked_boss_pool.has("一剑开天"):
		return false
	if not unlocked_boss_pool.has("quick_draw"):
		return false
	var pack_slots: Array = CardPoolDatabaseScript.pack_ids_for_job("sword")
	var pack_counts: Dictionary = CardPoolDatabaseScript.pack_card_counts_for_job("sword")
	if not pack_slots.has("common_5") or not pack_slots.has("sword_5"):
		return false
	if int(pack_counts.get("common_4", -1)) != 0 or int(pack_counts.get("sword_4", -1)) != 0:
		return false
	return CardPoolDatabaseScript.card_unlock_tier("quick_draw") == 0 \
		and CardPoolDatabaseScript.card_unlock_pack("急抽") == "common_1" \
		and CardPoolDatabaseScript.card_unlock_pack("break_defense_setup") == "common_1" \
		and CardPoolDatabaseScript.card_unlock_pack("火球符") == "" \
		and CardDatabaseScript.get_card("破防准备").get("id", "") == "break_defense_setup" \
		and CardDatabaseScript.get_card("break_defense_setup").get("default_unlocked", false) \
		and not bool(CardDatabaseScript.get_card("火球符").get("default_unlocked", false))

func _test_reward_pool_scopes() -> bool:
	var talisman_pool := CardPoolDatabaseScript.reward_pool_for_job("talisman", "boss", 2)
	if talisman_pool.has("养剑匣") or talisman_pool.has("火球符"):
		return false
	var sword_job_pool := CardPoolDatabaseScript.job_pool("sword")
	var talisman_job_pool := CardPoolDatabaseScript.job_pool("talisman")
	return sword_job_pool.has("break_defense_setup") \
		and sword_job_pool.has("weaken_attack_setup") \
		and talisman_job_pool.has("heal_wound") \
		and talisman_job_pool.has("defense_setup") \
		and not sword_job_pool.has("养剑匣") \
		and not talisman_job_pool.has("养剑匣")

func _test_active_entry_sources_use_first_edition_cards() -> bool:
	var active_ids: Array = CardPoolDatabaseScript.active_card_ids()
	var legacy_ids: Array = CardPoolDatabaseScript.legacy_card_ids()
	for required_id in ["break_defense_setup", "weaken_attack_setup", "heal_wound", "clear_buff", "poison", "quick_draw", "defense_setup", "blank_card"]:
		if not active_ids.has(str(required_id)):
			return false
	for job_id in ["sword", "talisman"]:
		var job: Dictionary = JobDatabaseScript.get_job(str(job_id))
		for card_id_variant in job.get("start_deck", []):
			var raw_card_id := str(card_id_variant)
			var card_id := CardDefinitionDatabaseScript.normalize_card_id(raw_card_id)
			if raw_card_id != card_id:
				return false
			if legacy_ids.has(card_id) or not active_ids.has(card_id):
				return false
		for encounter_type in ["normal", "elite", "boss"]:
			for card_id_variant in CardPoolDatabaseScript.reward_pool_for_job(str(job_id), encounter_type, 2):
				var reward_id := str(card_id_variant)
				if reward_id == "blank_card" or legacy_ids.has(reward_id) or not active_ids.has(reward_id):
					return false
		var rng := RandomNumberGenerator.new()
		rng.seed = 90427
		var shop_stock: Array = CardPoolDatabaseScript.shop_stock(str(job_id), 0, rng, 6, 2)
		for item_variant in shop_stock:
			var item: Dictionary = item_variant
			var shop_id := str(item.get("card_id", ""))
			if shop_id == "blank_card" or legacy_ids.has(shop_id) or not active_ids.has(shop_id):
				return false
		var run_state = RunStateScript.new()
		run_state.start(str(job_id))
		for card_id_variant in run_state.treasure_card_rewards():
			var treasure_id := str(card_id_variant)
			if treasure_id == "blank_card" or legacy_ids.has(treasure_id) or not active_ids.has(treasure_id):
				return false
		var minor_offer: Dictionary = run_state.minor_event_offer()
		if str(minor_offer.get("kind", "")) == "card":
			var event_id := str(minor_offer.get("card_id", ""))
			if event_id == "blank_card" or legacy_ids.has(event_id) or not active_ids.has(event_id):
				return false
	for template_variant in EnemyDeckTemplateDatabaseScript.deck_templates():
		var template: Dictionary = template_variant
		if not bool(template.get("enabled", true)):
			continue
		for card_id_variant in template.get("deck", []):
			var raw_enemy_card_id := str(card_id_variant)
			var enemy_card_id := CardDefinitionDatabaseScript.normalize_card_id(raw_enemy_card_id)
			if raw_enemy_card_id != enemy_card_id:
				return false
			if legacy_ids.has(enemy_card_id) or not active_ids.has(enemy_card_id):
				return false
	return true

func _test_active_card_effect_step_schema() -> bool:
	var expected_steps := {
		"break_defense_setup": ["add_next_attack_modifier", "add_status_on_hit"],
		"weaken_attack_setup": ["add_next_attack_modifier", "add_status_on_hit"],
		"heal_wound": ["heal", "set_unit_action_lock"],
		"clear_buff": ["remove_status_by_tag"],
		"poison": ["add_status"],
		"defense_setup": ["add_status"],
		"quick_draw": ["draw_cards", "create_card_to_zone", "move_source_card"],
		"blank_card": ["no_effect"]
	}
	var active_ids: Array = CardDefinitionDatabaseScript.active_card_ids()
	if active_ids.size() != expected_steps.size():
		return false
	for card_id_variant in expected_steps.keys():
		var card_id := str(card_id_variant)
		if not active_ids.has(card_id):
			return false
		var definition: Dictionary = CardDefinitionDatabaseScript.get_card(card_id)
		if definition.is_empty() or definition.has("effect") or not definition.has("effect_steps"):
			return false
		var steps: Array = definition.get("effect_steps", [])
		var expected: Array = expected_steps.get(card_id, [])
		if steps.size() != expected.size():
			return false
		for i in range(steps.size()):
			var step: Dictionary = steps[i]
			if step.has("kind") or str(step.get("effect_type", "")) != str(expected[i]):
				return false
	var poisoned_copy: Dictionary = CardDefinitionDatabaseScript.get_card("poison")
	var poisoned_steps: Array = poisoned_copy.get("effect_steps", [])
	var poisoned_step: Dictionary = poisoned_steps[0]
	poisoned_step["status"] = "中毒"
	poisoned_steps[0] = poisoned_step
	var poison_again: Dictionary = CardDefinitionDatabaseScript.get_card("poison")
	var poison_again_steps: Array = poison_again.get("effect_steps", [])
	var poison_again_step: Dictionary = poison_again_steps[0]
	if str(poison_again_step.get("status", "")) != "poison":
		return false
	var resolver_battle = BattleManagerScript.new()
	resolver_battle.start_run("sword")
	var supported: Array = resolver_battle.effect_resolver.supported_effect_types()
	for effect_type in [
		"add_next_attack_modifier",
		"add_status_on_hit",
		"heal",
		"set_unit_action_lock",
		"remove_status_by_tag",
		"add_status",
		"draw_cards",
		"create_card_to_zone",
		"move_source_card",
		"no_effect"
	]:
		if not supported.has(str(effect_type)):
			return false
	var missing_result: Array = resolver_battle.effect_resolver.apply_step(resolver_battle, resolver_battle.player, {}, {})
	var empty_result: Array = resolver_battle.effect_resolver.apply_step(resolver_battle, resolver_battle.player, {"effect_type": ""}, {})
	var unknown_result: Array = resolver_battle.effect_resolver.apply_step(resolver_battle, resolver_battle.player, {"effect_type": "unknown_effect_type"}, {})
	if str((missing_result[0] as Dictionary).get("error", "")) != "missing_effect_type":
		return false
	if str((empty_result[0] as Dictionary).get("error", "")) != "missing_effect_type":
		return false
	if str((unknown_result[0] as Dictionary).get("error", "")) != "unknown_effect_type":
		return false
	var fallback_battle = BattleManagerScript.new()
	fallback_battle.start_run("sword")
	fallback_battle.deck.hand.clear()
	var active_like_old: Dictionary = CardDatabaseScript.make_card("poison")
	active_like_old.erase("effect_steps")
	active_like_old["effect"] = {"kind": "add_status", "target": "enemy", "status": "poison", "value": 2}
	fallback_battle.deck.hand.append(active_like_old)
	fallback_battle.play_hand_card_on_enemy_target(str(active_like_old.get("uid", "")), str(fallback_battle.enemy.uid))
	if fallback_battle.enemy.get_status("poison") != 0:
		return false
	return not fallback_battle.deck.find_hand_card(str(active_like_old.get("uid", ""))).is_empty()

func _test_run_card_id_canonical_boundaries() -> bool:
	var old_active_ids := ["破防准备", "削攻准备", "疗伤", "清除增益", "中毒", "防御准备", "急抽", "空卡"]
	var starter_from_old_ids := [
		"破防准备", "破防准备",
		"削攻准备", "削攻准备",
		"防御准备", "防御准备",
		"疗伤",
		"清除增益",
		"中毒", "中毒"
	]
	var run_state = RunStateScript.new()
	run_state.start("sword", starter_from_old_ids, ["中毒", "急抽"])
	for old_id in old_active_ids:
		if run_state.deck_ids.has(str(old_id)) or run_state.reserve_ids.has(str(old_id)):
			return false
	if not run_state.deck_ids.has("break_defense_setup") or not run_state.reserve_ids.has("poison"):
		return false
	var available := run_state.available_nodes()
	if available.is_empty():
		return false
	var payload: Dictionary = run_state.battle_start_payload(str((available[0] as Dictionary).get("id", "")))
	if not bool(payload.get("success", false)):
		return false
	for card_id_variant in payload.get("deck_ids", []):
		if old_active_ids.has(str(card_id_variant)):
			return false
	var context: Dictionary = payload.get("run_context", {})
	for card_id_variant in context.get("reserve_ids", []):
		if old_active_ids.has(str(card_id_variant)):
			return false
	if not str(run_state.gain_reward_card("急抽")).contains("quick_draw"):
		return false
	if not (run_state.deck_ids.has("quick_draw") or run_state.reserve_ids.has("quick_draw")) or run_state.deck_ids.has("急抽") or run_state.reserve_ids.has("急抽"):
		return false
	var event_card_result: Dictionary = run_state.apply_event_card_reward("疗伤", "事件")
	if not bool(event_card_result.get("success", false)) or str(event_card_result.get("card_id", "")) != "heal_wound":
		return false
	var treasure_result: Dictionary = run_state.apply_treasure_card_reward("防御准备")
	if not bool(treasure_result.get("success", false)) or str(treasure_result.get("card_id", "")) != "defense_setup":
		return false
	run_state.add_spirit_stones(999)
	var buy_result: Dictionary = run_state.buy_shop_card("清除增益", 0)
	if not bool(buy_result.get("success", false)) or str(buy_result.get("card_id", "")) != "clear_buff":
		return false
	var hp_result: Dictionary = run_state.apply_trade_hp_reward(1, "削攻准备")
	if not bool(hp_result.get("success", false)) or str(hp_result.get("card_id", "")) != "weaken_attack_setup":
		return false
	for old_id in old_active_ids:
		if run_state.deck_ids.has(str(old_id)) or run_state.reserve_ids.has(str(old_id)):
			return false
	var stock: Array = run_state.generate_shop_stock()
	for item_variant in stock:
		var item: Dictionary = item_variant
		var stock_id := str(item.get("card_id", ""))
		if old_active_ids.has(stock_id) or stock_id == "blank_card":
			return false
	var minor_offer: Dictionary = run_state.minor_event_offer()
	if str(minor_offer.get("kind", "")) == "card":
		var event_id := str(minor_offer.get("card_id", ""))
		if old_active_ids.has(event_id) or event_id == "blank_card":
			return false
	return true

func _test_card_acquisition_rules_boundary() -> bool:
	var deck_ids := ["break_defense_setup", "weaken_attack_setup", "heal_wound", "clear_buff", "poison", "defense_setup", "quick_draw", "blank_card", "poison"]
	var deck_result: Dictionary = CardAcquisitionRulesScript.card_gain_result("poison", deck_ids, 20)
	if str(deck_result.get("destination", "")) != "deck":
		return false
	var full_deck := ["poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison", "poison"]
	var reserve_result: Dictionary = CardAcquisitionRulesScript.card_gain_result("quick_draw", full_deck, 20)
	if str(reserve_result.get("destination", "")) != "reserve":
		return false
	var compatibility_result: Dictionary = RewardServiceScript.card_gain_result("quick_draw", full_deck, 20)
	return str(compatibility_result.get("destination", "")) == str(reserve_result.get("destination", ""))

func _test_event_database_boundary() -> bool:
	var expected_ids := [
		EventDatabaseScript.EVENT_ID_WINDFALL,
		EventDatabaseScript.EVENT_ID_TRADE,
		EventDatabaseScript.EVENT_ID_MINOR
	]
	var definitions: Array = EventDatabaseScript.event_definitions()
	if definitions.size() != 3 or EventDatabaseScript.active_event_ids() != expected_ids:
		return false
	var expected_weights := {
		EventDatabaseScript.EVENT_ID_WINDFALL: 8,
		EventDatabaseScript.EVENT_ID_TRADE: 30,
		EventDatabaseScript.EVENT_ID_MINOR: 62
	}
	var total_weight := 0
	for definition_variant in definitions:
		var definition: Dictionary = definition_variant
		var event_id := str(definition.get("event_id", ""))
		if not expected_weights.has(event_id):
			return false
		if str(definition.get("event_type", "")) == "" or str(definition.get("content_state", "")) != EventDatabaseScript.CONTENT_STATE_ACTIVE:
			return false
		if definition.has("active_flag") or definition.has("prototype") or definition.has("legacy"):
			return false
		var options: Array = definition.get("options", [])
		if options.is_empty():
			return false
		for option_variant in options:
			var option: Dictionary = option_variant
			if str(option.get("option_id", "")) == "":
				return false
		var weight := int(definition.get("weight", 0))
		if weight != int(expected_weights.get(event_id, -1)):
			return false
		total_weight += weight
	if total_weight != 100:
		return false
	var old_event_ids := [
		"event_basic_" + "reward_01",
		"event_trade_hp_" + "for_card_01",
		"event_trade_stone_" + "for_card_01",
		"event_rare_" + "reward_01"
	]
	for old_event_id in old_event_ids:
		if not EventDatabaseScript.event_definition(str(old_event_id)).is_empty():
			return false
	definitions[0]["weight"] = 999
	if int(EventDatabaseScript.event_definition(EventDatabaseScript.EVENT_ID_WINDFALL).get("weight", 0)) != 8:
		return false
	var synthetic_definitions := [
		{"event_id": "test_active", "content_state": "active", "weight": 1},
		{"event_id": "test_prototype", "content_state": "prototype", "weight": 1},
		{"event_id": "test_disabled", "content_state": "disabled", "weight": 1}
	]
	var filtered: Array = EventDatabaseScript.filter_active_definitions(synthetic_definitions)
	if filtered.size() != 1 or str((filtered[0] as Dictionary).get("event_id", "")) != "test_active":
		return false
	var filtered_definition: Dictionary = filtered[0]
	filtered_definition["event_id"] = "mutated"
	if str((synthetic_definitions[0] as Dictionary).get("event_id", "")) != "test_active":
		return false
	var boundary_cases := [
		{"roll": 0.0, "event_id": EventDatabaseScript.EVENT_ID_WINDFALL},
		{"roll": 0.079999, "event_id": EventDatabaseScript.EVENT_ID_WINDFALL},
		{"roll": 0.08, "event_id": EventDatabaseScript.EVENT_ID_TRADE},
		{"roll": 0.379999, "event_id": EventDatabaseScript.EVENT_ID_TRADE},
		{"roll": 0.38, "event_id": EventDatabaseScript.EVENT_ID_MINOR}
	]
	for boundary_variant in boundary_cases:
		var boundary: Dictionary = boundary_variant
		var selected_id := EventServiceScript.roll_event_id(FixedEventRng.new(float(boundary.get("roll", 0.0))))
		if selected_id != str(boundary.get("event_id", "")):
			return false
	if EventServiceScript.event_id_from_definitions(FixedEventRng.new(0.0), []) != "":
		return false
	if EventServiceScript.event_id_from_definitions(FixedEventRng.new(0.0), [{"event_id": "zero", "weight": 0, "content_state": "active"}]) != "":
		return false
	return EventServiceScript.event_id_from_definitions(FixedEventRng.new(0.0), [{"weight": 100, "content_state": "active"}]) == ""

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
	var gain_result: Dictionary = RewardServiceScript.card_gain_result("quick_draw", run_state.deck_ids, run_state.deck_score_limit)
	if not ["deck", "reserve"].has(str(gain_result.get("destination", ""))):
		return false
	var minor_offer: Dictionary = run_state.minor_event_offer()
	if not ["stone", "card"].has(str(minor_offer.get("kind", ""))):
		return false
	run_state.reserve_ids.append("quick_draw")
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
	var event_card_result: Dictionary = run_state.apply_event_card_reward("poison", "事件")
	if not bool(event_card_result.get("success", false)) or run_state.deck_ids.size() + run_state.reserve_ids.size() != total_cards_before_event + 1:
		return false
	var hp_before_trade: int = run_state.current_hp
	var hp_trade_result: Dictionary = run_state.apply_trade_hp_reward(1, "poison")
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
	run_state.reserve_ids.append("poison")
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
	var expected_ids := {
		"sword": ["max_hp", "attack", "deck_score", "card_unlock", "draw", "defense", "starting_sword"],
		"talisman": ["max_hp", "attack", "deck_score", "card_unlock", "draw", "defense"]
	}
	var expected_values := {
		"sword:max_hp": {"max_level": 5, "costs": [12, 18, 26, 36, 48], "bonus_per_level": {"max_hp": 3}},
		"sword:attack": {"max_level": 3, "costs": [28, 45, 70], "bonus_per_level": {"attack": 1}},
		"sword:deck_score": {"max_level": 4, "costs": [18, 28, 42, 60], "bonus_per_level": {"deck_score_limit": 2}},
		"sword:card_unlock": {"max_level": 2, "costs": [40, 80], "bonus_per_level": {"card_unlock_tier": 1}},
		"sword:draw": {"max_level": 1, "costs": [160], "bonus_per_level": {"draw_per_turn": 1}},
		"sword:defense": {"max_level": 1, "costs": [65], "bonus_per_level": {"defense": 1}},
		"sword:starting_sword": {"max_level": 2, "costs": [35, 70], "bonus_per_level": {"starting_sword": 1}},
		"talisman:max_hp": {"max_level": 5, "costs": [12, 18, 26, 36, 48], "bonus_per_level": {"max_hp": 3}},
		"talisman:attack": {"max_level": 3, "costs": [28, 45, 70], "bonus_per_level": {"attack": 1}},
		"talisman:deck_score": {"max_level": 4, "costs": [18, 28, 42, 60], "bonus_per_level": {"deck_score_limit": 2}},
		"talisman:card_unlock": {"max_level": 2, "costs": [40, 80], "bonus_per_level": {"card_unlock_tier": 1}},
		"talisman:draw": {"max_level": 1, "costs": [160], "bonus_per_level": {"draw_per_turn": 1}},
		"talisman:defense": {"max_level": 2, "costs": [55, 85], "bonus_per_level": {"defense": 1}}
	}
	var required_fields := ["progression_id", "job_id", "name", "category", "description", "max_level", "costs", "bonus_per_level", "content_state"]
	var definitions: Array = ProgressionDatabaseScript.progression_definitions()
	var active_definitions: Array = ProgressionDatabaseScript.active_progression_definitions()
	if definitions.size() != 13 or active_definitions.size() != 13:
		return false
	var composite_keys: Array = []
	for definition_variant in definitions:
		var definition: Dictionary = definition_variant
		if definition.keys().size() != required_fields.size():
			return false
		for field in required_fields:
			if not definition.has(str(field)):
				return false
		if definition.has("id") or str(definition.get("content_state", "")) != ProgressionDatabaseScript.CONTENT_STATE_ACTIVE:
			return false
		if str(definition.get("name", "")) == "" or str(definition.get("category", "")) == "" or str(definition.get("description", "")) == "":
			return false
		var job_id := str(definition.get("job_id", ""))
		var progression_id := str(definition.get("progression_id", ""))
		var composite_key := "%s:%s" % [job_id, progression_id]
		if composite_keys.has(composite_key) or not expected_values.has(composite_key):
			return false
		composite_keys.append(composite_key)
		var expected: Dictionary = expected_values.get(composite_key, {})
		if int(definition.get("max_level", 0)) != int(expected.get("max_level", -1)):
			return false
		if definition.get("costs", []) != expected.get("costs", []):
			return false
		if definition.get("bonus_per_level", {}) != expected.get("bonus_per_level", {}):
			return false
	if composite_keys.size() != expected_values.size():
		return false
	for job_id_variant in expected_ids.keys():
		var job_id := str(job_id_variant)
		var actual_ids: Array = []
		for definition_variant in ProgressionDatabaseScript.upgrades_for_job(job_id):
			var definition: Dictionary = definition_variant
			actual_ids.append(str(definition.get("progression_id", "")))
		if actual_ids != expected_ids.get(job_id, []):
			return false
	if not ProgressionDatabaseScript.upgrades_for_job("unknown").is_empty() or not ProgressionDatabaseScript.upgrade_definition("sword", "unknown").is_empty():
		return false
	var sword_defense: Dictionary = ProgressionDatabaseScript.upgrade_definition("sword", "defense")
	var talisman_defense: Dictionary = ProgressionDatabaseScript.upgrade_definition("talisman", "defense")
	if sword_defense.get("costs", []) != [65] or talisman_defense.get("costs", []) != [55, 85]:
		return false
	var mutable_definition: Dictionary = ProgressionDatabaseScript.upgrade_definition("sword", "max_hp")
	var mutable_costs: Array = mutable_definition.get("costs", [])
	mutable_costs[0] = 999
	var mutable_bonus: Dictionary = mutable_definition.get("bonus_per_level", {})
	mutable_bonus["max_hp"] = 999
	var fresh_definition: Dictionary = ProgressionDatabaseScript.upgrade_definition("sword", "max_hp")
	if fresh_definition.get("costs", []) != [12, 18, 26, 36, 48] or fresh_definition.get("bonus_per_level", {}) != {"max_hp": 3}:
		return false
	var synthetic_definitions := [
		{"progression_id": "active_test", "job_id": "sword", "content_state": "active", "costs": [1], "bonus_per_level": {"attack": 1}},
		{"progression_id": "prototype_test", "job_id": "sword", "content_state": "prototype", "costs": [1], "bonus_per_level": {"attack": 1}},
		{"progression_id": "disabled_test", "job_id": "sword", "content_state": "disabled", "costs": [1], "bonus_per_level": {"attack": 1}},
		{"progression_id": "pending_test", "job_id": "sword", "content_state": "pending_fill", "costs": [1], "bonus_per_level": {"attack": 1}}
	]
	var filtered: Array = ProgressionDatabaseScript.filter_active_definitions(synthetic_definitions)
	if filtered.size() != 1 or str((filtered[0] as Dictionary).get("progression_id", "")) != "active_test":
		return false
	var filtered_definition: Dictionary = filtered[0]
	var filtered_costs: Array = filtered_definition.get("costs", [])
	var filtered_bonus: Dictionary = filtered_definition.get("bonus_per_level", {})
	filtered_costs[0] = 9
	filtered_bonus["attack"] = 9
	if (synthetic_definitions[0] as Dictionary).get("costs", []) != [1] or (synthetic_definitions[0] as Dictionary).get("bonus_per_level", {}) != {"attack": 1}:
		return false
	var old_prefixed_ids := [
		"sword_" + "hp_01", "sword_" + "attack_01", "sword_" + "defense_01", "sword_" + "build_score_01", "sword_" + "pack_unlock_02", "sword_" + "draw_01", "sword_" + "card_ban_01",
		"talisman_" + "hp_01", "talisman_" + "attack_01", "talisman_" + "defense_01", "talisman_" + "build_score_01", "talisman_" + "pack_unlock_02", "talisman_" + "draw_01", "talisman_" + "card_ban_01",
		"common_" + "pack_unlock_02", "common_" + "pack_unlock_03"
	]
	for old_progression_id in old_prefixed_ids:
		if not ProgressionDatabaseScript.upgrade_definition("sword", str(old_progression_id)).is_empty() or not ProgressionDatabaseScript.upgrade_definition("talisman", str(old_progression_id)).is_empty():
			return false
	var progression = MetaProgressionScript.new()
	progression.reset_to_defaults()
	progression.add_points("sword", 600, false)
	for progression_id in ["max_hp", "attack", "defense", "deck_score", "draw", "starting_sword", "card_unlock"]:
		if progression.buy_upgrade("sword", str(progression_id), false).contains("无效"):
			return false
	if progression.points_spent("sword") != 358 or progression.points_available("sword") != 242:
		return false
	var bonuses: Dictionary = progression.bonuses_for_job("sword")
	var expected_bonuses := {"max_hp": 3, "attack": 1, "defense": 1, "deck_score_limit": 2, "draw_per_turn": 1, "starting_sword": 1, "card_unlock_tier": 1}
	if bonuses != expected_bonuses:
		return false
	if CardPoolDatabaseScript.unlocked_packs_for_job("sword", 0) != ["common_1", "sword_1"]:
		return false
	if CardPoolDatabaseScript.unlocked_packs_for_job("sword", 1) != ["common_1", "sword_1", "common_2", "sword_2"]:
		return false
	if CardPoolDatabaseScript.unlocked_packs_for_job("sword", 2) != ["common_1", "sword_1", "common_2", "sword_2", "common_3", "sword_3"]:
		return false
	if CardPoolDatabaseScript.unlocked_packs_for_job("talisman", 0) != ["common_1", "talisman_1"]:
		return false
	if CardPoolDatabaseScript.unlocked_packs_for_job("talisman", 1) != ["common_1", "talisman_1", "common_2", "talisman_2"]:
		return false
	if CardPoolDatabaseScript.unlocked_packs_for_job("talisman", 2) != ["common_1", "talisman_1", "common_2", "talisman_2", "common_3", "talisman_3"]:
		return false
	var sword_job: Dictionary = JobDatabaseScript.get_job("sword")
	var run_state = RunStateScript.new()
	run_state.start("sword")
	run_state.meta_bonuses = bonuses.duplicate(true)
	run_state.base_max_hp = int(sword_job.get("max_hp", 0)) + int(bonuses.get("max_hp", 0))
	run_state.call("_apply_realm_stats", true)
	if run_state.max_hp != int(sword_job.get("max_hp", 0)) + 3 or run_state.draw_per_turn != 2 or run_state.deck_score_limit != 22:
		return false
	var battle = BattleManagerScript.new()
	battle.start_run_with_deck("sword", (sword_job.get("start_deck", []) as Array), 1, "normal", false, {
		"draw_per_turn": 2,
		"deck_score_limit": 22,
		"meta_bonuses": bonuses
	})
	if battle.player.max_hp != int(sword_job.get("max_hp", 0)) + 3:
		return false
	if battle.player.attack != int(sword_job.get("attack", 0)) + 1 or battle.player.defense != int(sword_job.get("defense", 0)) + 1:
		return false
	if battle.player.sword_momentum != 1 or battle.draw_per_turn != 2 or battle.deck_score_limit != 22:
		return false
	var compatibility: Dictionary = MetaProgressionScript.upgrade_definition("sword", "starting_sword")
	return str(compatibility.get("progression_id", "")) == "starting_sword"

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
	battle.enemy.defense = 0
	if not _submit_request_accepted(battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_PLAYER,
		"source_uid": str(battle.player.uid),
		"target_uid": str(battle.enemy.uid)
	}):
		return false
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

func _test_status_field_helpers() -> bool:
	var definitions: Array = StatusDatabaseScript.active_definitions()
	if definitions.size() != 4:
		return false
	var active_ids := StatusDatabaseScript.active_status_ids()
	for expected_id in ["poison", "armor_break", "weak", "next_damage_reduce"]:
		if not active_ids.has(expected_id):
			return false
	for old_status_id in ["中毒", "破甲", "虚弱", "下次减伤", "missing_status"]:
		if StatusDatabaseScript.is_active_status(old_status_id):
			return false
	var synthetic_definitions: Array = definitions.duplicate(true)
	synthetic_definitions.append({"status_id": "burn", "content_state": "prototype"})
	if StatusDatabaseScript.filter_active_definitions(synthetic_definitions).size() != 4:
		return false
	var copied_definition: Dictionary = StatusDatabaseScript.active_definition("poison")
	(copied_definition.get("tags", []) as Array).append("mutated")
	if (StatusDatabaseScript.active_definition("poison").get("tags", []) as Array).has("mutated"):
		return false

	var unit = BattleUnitScript.new()
	unit.setup_unit({"id": "status_helper_unit", "name": "状态字段测试", "max_hp": 20, "attack": 5, "defense": 3})
	if unit.add_status("poison", 2, "测试状态") != 2:
		return false
	if unit.get_status("poison") != 2 or unit.status_value("poison") != 2 or not unit.has_status("poison"):
		return false
	var snapshot: Dictionary = unit.status_snapshot()
	if snapshot.size() != 1:
		return false
	var poison_record: Dictionary = unit.status_records_snapshot()[0]
	var poison_instance_id := str(poison_record.get("instance_id", ""))
	if poison_instance_id == "" or not snapshot.has(poison_instance_id):
		return false
	if str(poison_record.get("status_id", "")) != "poison" or str(poison_record.get("name", "")) != "中毒":
		return false
	if int(poison_record.get("value", 0)) != 1 or int(poison_record.get("counter", 0)) != 2:
		return false
	if not poison_record.has("source") or str(poison_record.get("cleanup_scope", "")) != "battle":
		return false
	var poison_tags: Array = poison_record.get("tags", [])
	if not poison_tags.has("negative") or not poison_tags.has("poison"):
		return false
	var copied_snapshot: Dictionary = unit.status_snapshot()
	copied_snapshot[poison_instance_id]["counter"] = 99
	if int(unit.status_snapshot()[poison_instance_id].get("counter", 0)) == 99:
		return false
	if unit.add_status("poison", 1) != 3 or unit.get_status("poison") != 3:
		return false
	if unit.status_records_snapshot().size() != 2:
		return false
	if unit.remove_status("poison", 1, "测试移除") != 1 or unit.get_status("poison") != 1:
		return false
	if unit.clear_status("poison", "测试清除") != 1 or unit.has_status("poison"):
		return false
	unit.add_status("armor_break", 2)
	unit.add_status("weak", 1)
	if unit.status_records_snapshot().size() != 3:
		return false
	unit.clear_statuses()
	if not unit.status_snapshot().is_empty() or not unit.status_instances.is_empty():
		return false

	var record_unit = BattleUnitScript.new()
	record_unit.setup_unit({
		"id": "status_record_unit",
		"name": "状态记录测试",
		"max_hp": 20,
		"attack": 1,
		"defense": 0,
		"status_instances": [
			{"status_id": "armor_break", "value": 1, "counter": 1, "source": "测试"},
			{"status_id": "armor_break", "value": 1, "counter": 1, "source": "测试"},
			{"status_id": "weak", "value": 1, "counter": 1, "source": "测试"},
			{"status_id": "zero", "value": 1, "counter": 0, "source": "测试"}
		]
	})
	if record_unit.get_status("armor_break") != 2 or record_unit.get_status("weak") != 1 or record_unit.has_status("zero"):
		return false
	if record_unit.current_attack() != 0 or record_unit.current_defense() != -2:
		return false

	var formal_battle = BattleManagerScript.new()
	formal_battle.start_run("sword")
	if formal_battle.add_unit_status(formal_battle.enemy, "中毒", 2, "中文状态测试") != 0:
		return false
	if formal_battle.enemy.has_status("中毒") or formal_battle.enemy.has_status("poison"):
		return false
	if formal_battle.add_unit_status(formal_battle.enemy, "poison", 2, "英文状态测试") != 2:
		return false
	if formal_battle.enemy.status_records_snapshot().size() != 1:
		return false

	var poison_battle = BattleManagerScript.new()
	poison_battle.start_run("sword")
	var poison_hp_before: int = poison_battle.enemy.hp
	poison_battle.enemy.add_status("poison", 2)
	poison_battle.call("_tick_turn_end_statuses_for_unit", poison_battle.enemy)
	if poison_battle.enemy.hp != poison_hp_before or poison_battle.enemy.get_status("poison") != 2:
		return false
	poison_battle.call("_apply_after_draw_poison_for_unit", poison_battle.enemy)
	if poison_battle.enemy.hp != poison_hp_before - 1 or poison_battle.enemy.get_status("poison") != 1:
		return false
	var poison_death_battle = BattleManagerScript.new()
	poison_death_battle.start_run("sword")
	poison_death_battle.enemy.hp = 1
	poison_death_battle.enemy.add_status("poison", 2)
	poison_death_battle.enemy.add_status("poison", 2)
	poison_death_battle.call("_apply_after_draw_poison_for_unit", poison_death_battle.enemy)
	if poison_death_battle.enemy.hp != 0 or poison_death_battle.enemy.get_status("poison") != 3:
		return false

	var burn_battle = BattleManagerScript.new()
	burn_battle.start_run("sword")
	var burn_hp_before: int = burn_battle.enemy.hp
	burn_battle.enemy.add_status("灼伤", 3)
	burn_battle.call("_tick_turn_end_statuses_for_unit", burn_battle.enemy)
	if burn_battle.enemy.hp != burn_hp_before - 3 or burn_battle.enemy.get_status("灼伤") != 2:
		return false

	var reduction_battle = BattleManagerScript.new()
	reduction_battle.start_run("sword")
	reduction_battle.player.add_status("next_damage_reduce", 3)
	reduction_battle.player.add_status("next_damage_reduce", 3)
	var reduction_hp_before: int = reduction_battle.player.hp
	reduction_battle.open_timing_window(reduction_battle.create_event("player_damage_before", "test", reduction_battle.player, 5))
	if reduction_battle.player.hp != reduction_hp_before or reduction_battle.player.get_status("next_damage_reduce") != 0:
		return false
	reduction_battle.player.add_status("next_damage_reduce", 3)
	var zero_damage_hp_before: int = reduction_battle.player.hp
	reduction_battle.apply_damage_to_unit(reduction_battle.player, 0, "零伤害测试")
	if reduction_battle.player.hp != zero_damage_hp_before or reduction_battle.player.get_status("next_damage_reduce") != 3:
		return false
	var enemy_reduction_battle = BattleManagerScript.new()
	enemy_reduction_battle.start_run("sword")
	enemy_reduction_battle.enemy.add_status("next_damage_reduce", 3)
	var enemy_reduction_hp_before: int = enemy_reduction_battle.enemy.hp
	enemy_reduction_battle.apply_damage_to_unit(enemy_reduction_battle.enemy, 5, "敌方减伤测试")
	if enemy_reduction_battle.enemy.hp != enemy_reduction_hp_before - 2 or enemy_reduction_battle.enemy.get_status("next_damage_reduce") != 0:
		return false
	var enemy_card_reduction_battle = BattleManagerScript.new()
	enemy_card_reduction_battle.start_run("sword")
	enemy_card_reduction_battle.phase = "enemy"
	enemy_card_reduction_battle.enemy_action_queue.clear()
	enemy_card_reduction_battle.enemy_side.deck_manager.hand.clear()
	var enemy_guard_card := CardDatabaseScript.make_card("defense_setup")
	enemy_card_reduction_battle.enemy_side.deck_manager.hand.append(enemy_guard_card)
	var enemy_guard_source = enemy_card_reduction_battle.formation.primary_enemy()
	if enemy_guard_source == null:
		return false
	if not _submit_request_accepted(enemy_card_reduction_battle, {
		"type": "play_card",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(enemy_guard_source.uid),
		"card_uid": str(enemy_guard_card.get("uid", "")),
		"target_uid": str(enemy_guard_source.uid)
	}):
		return false
	if enemy_guard_source.get_status("next_damage_reduce") != 3:
		return false
	var enemy_guard_hp_before: int = enemy_guard_source.hp
	enemy_card_reduction_battle.apply_damage_to_unit(enemy_guard_source, 5, "敌方出牌减伤测试")
	if enemy_guard_source.hp != enemy_guard_hp_before - 2 or enemy_guard_source.get_status("next_damage_reduce") != 0:
		return false

	var delay_battle = BattleManagerScript.new()
	delay_battle.start_run("sword")
	delay_battle.enemy.add_status("迟滞", 2)
	if int(delay_battle.call("_consume_delay_status_for_power", delay_battle.enemy, 5)) != 3:
		return false
	if delay_battle.enemy.get_status("迟滞") != 0:
		return false

	var cleanse_battle = BattleManagerScript.new()
	cleanse_battle.start_run("sword")
	cleanse_battle.enemy.add_status("next_damage_reduce", 3)
	cleanse_battle.enemy.add_status("next_damage_reduce", 3)
	if cleanse_battle.remove_positive_status_from_unit(cleanse_battle.enemy, 1, "测试清除") != 1:
		return false
	if cleanse_battle.enemy.get_status("next_damage_reduce") != 3:
		return false

	var reset_battle = BattleManagerScript.new()
	reset_battle.start_run("sword")
	reset_battle.player.add_status("poison", 1)
	reset_battle.player.reset_for_battle()
	return reset_battle.player.status_snapshot().is_empty() and reset_battle.player.get_status("poison") == 0

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
	ok = ok and battle.enemy_side.deck_manager.deck.size() >= 3
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
	ok = ok and elite_battle.enemy_side.draw_per_turn == 1
	ok = ok and elite_battle.enemy_side.deck_manager.deck.size() >= 4
	var boss_battle = BattleManagerScript.new()
	boss_battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "boss", false, {})
	ok = ok and boss_battle.enemy_side.draw_per_turn == 2
	ok = ok and boss_battle.enemy_side.deck_manager.deck.size() == 6
	ok = ok and boss_battle.enemy.has_unit_tag("首领")
	var layer_two_elite = BattleManagerScript.new()
	layer_two_elite.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "elite", false, {"realm_index": 1})
	ok = ok and layer_two_elite.enemy_side.draw_per_turn == 1
	ok = ok and layer_two_elite.enemy_side.deck_manager.deck.size() >= 3
	ok = ok and layer_two_elite.enemy.has_unit_tag("精英")
	return ok

func _test_hand_limit_and_turn_end_reshuffle() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	battle.deck.hand.clear()
	battle.deck.deck.clear()
	for i in range(8):
		battle.deck.deck.append(CardDatabaseScript.make_card("火球符"))
	var player_drawn: Array = battle.call("_draw_player_cards", 8, "test")
	if player_drawn.size() != DeckManagerScript.DEFAULT_HAND_LIMIT:
		return false
	if battle.deck.hand.size() != DeckManagerScript.DEFAULT_HAND_LIMIT:
		return false
	var player_deck_size_before: int = battle.deck.deck.size()
	var full_player_draw: Array = battle.call("_draw_player_cards", 1, "test")
	if not full_player_draw.is_empty() or battle.deck.deck.size() != player_deck_size_before:
		return false

	battle.enemy_side.deck_manager.hand.clear()
	battle.enemy_side.deck_manager.deck.clear()
	for i in range(8):
		battle.enemy_side.deck_manager.deck.append(CardDatabaseScript.make_card("金刃符"))
	var enemy_drawn: Array = battle.enemy_side.draw_cards(8)
	if enemy_drawn.size() != DeckManagerScript.DEFAULT_HAND_LIMIT:
		return false
	if battle.enemy_side.deck_manager.hand.size() != DeckManagerScript.DEFAULT_HAND_LIMIT:
		return false
	var enemy_deck_size_before: int = battle.enemy_side.deck_manager.deck.size()
	var full_enemy_draw: Array = battle.enemy_side.draw_cards(1)
	if not full_enemy_draw.is_empty() or battle.enemy_side.deck_manager.deck.size() != enemy_deck_size_before:
		return false

	var manager = DeckManagerScript.new()
	manager.deck.append(CardDatabaseScript.make_card("火球符"))
	manager.deck.append(CardDatabaseScript.make_card("雷击符"))
	manager.graveyard.append(CardDatabaseScript.make_card("护身符"))
	var drawn: Array = manager.draw(2)
	if drawn.size() != 2 or not manager.deck.is_empty() or not manager.reshuffle_pending:
		return false
	if manager.graveyard.size() != 1:
		return false
	var used_card: Dictionary = manager.remove_from_hand(str((drawn[0] as Dictionary).get("uid", "")))
	manager.add_to_graveyard(used_card)
	if not manager.process_pending_reshuffle():
		return false
	if manager.reshuffle_pending or not manager.graveyard.is_empty():
		return false
	if manager.deck.size() != 2 or manager.hand.size() != 1:
		return false
	for card_variant in manager.deck:
		var deck_card: Dictionary = card_variant
		if str(deck_card.get("uid", "")) == str((drawn[1] as Dictionary).get("uid", "")):
			return false

	manager.deck.clear()
	manager.hand.clear()
	manager.graveyard.clear()
	manager.graveyard.append(CardDatabaseScript.make_card("火球符"))
	var empty_draw: Array = manager.draw(1)
	if not empty_draw.is_empty() or not manager.reshuffle_pending or manager.graveyard.size() != 1:
		return false
	return manager.process_pending_reshuffle() and manager.deck.size() == 1 and manager.graveyard.is_empty()

func _test_enemy_card_packages() -> bool:
	var boss_battle = BattleManagerScript.new()
	boss_battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "boss", false, {})
	if boss_battle.enemy_side.draw_per_turn != 2 or boss_battle.enemy_side.deck_ids.size() != 6:
		return false
	if not boss_battle.enemy_side.deck_manager.hand.is_empty():
		return false
	var status_battle = BattleManagerScript.new()
	status_battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "boss", false, {})
	status_battle.enemy_side.draw_per_turn = 0
	status_battle.enemy_side.deck_manager.hand.clear()
	status_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("中毒"))
	status_battle.end_player_turn()
	if status_battle.phase == "response":
		_skip_response(status_battle)
	if status_battle.player.get_status("poison") != 1 or status_battle.phase != "player":
		return false
	var blank_battle = BattleManagerScript.new()
	blank_battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "normal", false, {})
	blank_battle.phase = "enemy"
	blank_battle.enemy_action_queue.clear()
	blank_battle.enemy_side.deck_manager.hand.clear()
	blank_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("空卡"))
	var blank_player_hp_before: int = blank_battle.player.hp
	var blank_enemy_hp_before: int = blank_battle.enemy.hp
	var blank_player_status_before: Array = blank_battle.player.status_instances.duplicate(true)
	var blank_enemy_status_before: Array = blank_battle.enemy.status_instances.duplicate(true)
	if not bool(blank_battle.call("_try_enemy_play_next_side_card")):
		return false
	if blank_battle.player.hp != blank_player_hp_before or blank_battle.enemy.hp != blank_enemy_hp_before:
		return false
	if blank_battle.player.status_instances != blank_player_status_before or blank_battle.enemy.status_instances != blank_enemy_status_before:
		return false
	if not blank_battle.enemy_side.deck_manager.hand.is_empty() or blank_battle.enemy_side.deck_manager.graveyard.size() != 1:
		return false
	if str(blank_battle.enemy_side.deck_manager.graveyard[0].get("id", "")) != "blank_card":
		return false
	var side_limit_battle = BattleManagerScript.new()
	side_limit_battle.start_run_with_deck("sword", ["青锋剑", "起剑诀", "藏锋", "小无相剑", "铁木甲", "护身符", "雷击符", "破法符", "养剑匣", "火球符"], 1, "normal", false, {})
	side_limit_battle.debug_add_enemy()
	side_limit_battle.enemy_side.draw_per_turn = 0
	side_limit_battle.enemy_side.deck_manager.hand.clear()
	side_limit_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("中毒"))
	side_limit_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("削攻准备"))
	side_limit_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("空卡"))
	side_limit_battle.end_player_turn()
	while side_limit_battle.phase == "response":
		_skip_response(side_limit_battle)
	return side_limit_battle.player.get_status("weak") == 1 \
		and side_limit_battle.player.get_status("poison") == 1 \
		and side_limit_battle.enemy_side.deck_manager.hand.is_empty() \
		and side_limit_battle.enemy_side.deck_manager.graveyard.size() >= 3

func _test_enemy_encounter_architecture() -> bool:
	var sword_character: Dictionary = CharacterDatabaseScript.character_template("sword")
	if sword_character.is_empty() or not (sword_character.get("unit_tags", []) as Array).has("剑修"):
		return false
	for layer in [1, 2, 3]:
		var boss_deck_templates: Array = EnemyDeckTemplateDatabaseScript.deck_templates_for(layer, "boss", 0)
		if boss_deck_templates.size() < 3:
			return false
		var first_template: Dictionary = (boss_deck_templates[0] as Dictionary)
		if str(first_template.get("template_kind", "")) != "enemy_deck_template":
			return false
		if not first_template.has("deck") or not first_template.has("character_refs"):
			return false
	var layer_three_normal: Dictionary = EncounterFactoryScript.get_encounter_for_battle(3, "normal", 2, 0, null)
	if str(layer_three_normal.get("encounter_type", "")) != "normal":
		return false
	if str(layer_three_normal.get("deck_template_id", "")) == "":
		return false
	if (layer_three_normal.get("character_refs", []) as Array).is_empty():
		return false
	if (layer_three_normal.get("enemy_units", []) as Array).is_empty():
		return false
	var inactive_world: Dictionary = EncounterFactoryScript.get_encounter_for_battle(3, "normal", 2, 2, null)
	if not inactive_world.is_empty():
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
	if draw_count != 1:
		return false
	var legacy_play_limit_key := "card" + "_play" + "_limit"
	if encounter.has(legacy_play_limit_key):
		return false
	for template_variant in EnemyDeckTemplateDatabaseScript.deck_templates():
		var template: Dictionary = template_variant
		if template.has(legacy_play_limit_key):
			return false
	for candidate_variant in EnemyDeckTemplateDatabaseScript.candidate_deck_templates():
		var candidate: Dictionary = candidate_variant
		if candidate.has(legacy_play_limit_key):
			return false
	var boss_encounter: Dictionary = BattleEncounterRuntimeScript.select_encounter(7, "boss", 0, 0, null)
	if BattleEncounterRuntimeScript.draw_per_turn(boss_encounter, "boss") != 2:
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
		{"effect_type": "damage", "target": "enemy", "value": 4, "ignore_defense": true, "source": "测试伤害"}
	])
	if battle.enemy.hp != enemy_hp_before - 4:
		return false
	battle.enemy.defense = 2
	var enemy_hp_before_defense: int = battle.enemy.hp
	battle.effect_resolver.apply_steps(battle, battle.player, [
		{"effect_type": "damage", "target": "enemy", "value": 4, "source": "测试防御减伤"}
	])
	if battle.enemy.hp != enemy_hp_before_defense - 2:
		return false
	battle.player.hp = max(1, battle.player.hp - 5)
	var player_hp_before: int = battle.player.hp
	battle.effect_resolver.apply_steps(battle, battle.player, [
		{"effect_type": "heal", "target": "player", "value": 3, "source": "测试治疗"},
		{"effect_type": "add_status", "target": "enemy", "status": "poison", "value": 2, "source": "测试状态"}
	])
	if battle.player.hp != player_hp_before + 3 or battle.enemy.get_status("poison") != 2:
		return false
	_isolate_enemy_unit_actions(battle)
	battle.enemy.skills = {
		"test_skill": {
			"name": "测试妖术",
			"cooldown": 2,
			"effect_steps": [
				{"effect_type": "damage", "target": "player", "value": 2, "ignore_defense": true, "source": "测试妖术"}
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
	if not _select_target(battle, "training_dummy"):
		return false
	var second_enemy = battle.formation.living_unit_by_uid("enemy", "training_dummy")
	if second_enemy == null:
		return false
	var primary_hp_before: int = battle.enemy.hp
	var second_hp_before: int = second_enemy.hp
	battle.effect_resolver.apply_steps(battle, battle.player, [
		{"effect_type": "damage", "target": "enemy", "value": 5, "ignore_defense": true, "source": "测试选中目标"}
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
	_isolate_enemy_unit_actions(defend_battle)
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
	battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("空卡"))
	battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("中毒"))
	battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("疗伤"))
	var source_unit = battle.enemy_controller.side_card_source_unit(battle)
	var selected_card: Dictionary = battle.enemy_controller.select_next_side_card(battle, source_unit)
	if str(selected_card.get("id", "")) != "poison":
		return false
	battle.enemy.hp = max(1, battle.enemy.hp - 4)
	selected_card = battle.enemy_controller.select_next_side_card(battle, source_unit)
	if str(selected_card.get("id", "")) != "heal_wound":
		return false
	var clear_battle = BattleManagerScript.new()
	clear_battle.start_run("sword")
	clear_battle.player.add_status("next_damage_reduce", 3)
	clear_battle.enemy_side.deck_manager.hand.clear()
	clear_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("清除增益"))
	var clear_source = clear_battle.enemy_controller.side_card_source_unit(clear_battle)
	var clear_card: Dictionary = clear_battle.enemy_controller.select_next_side_card(clear_battle, clear_source)
	return str(clear_card.get("id", "")) == "clear_buff" and clear_battle.enemy_controller.side_card_profile("裂石符").is_empty()

func _test_enemy_side_action_sequence() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	_isolate_enemy_unit_actions(battle)
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
	_play_response(battle, str(guard.get("uid", "")))
	var expected_damage: int = max(0, battle.enemy.current_attack() - ally.current_defense() - 4)
	return battle.phase == "player" and int(ally.hp) == ally_hp_before - expected_damage and battle.deck.graveyard.size() >= 1

func _test_common_status_and_zone_cards() -> bool:
	var status_battle = BattleManagerScript.new()
	status_battle.start_run("sword")
	status_battle.enemy.defense = 2
	var armor_break := CardDatabaseScript.make_card("破甲符")
	status_battle.deck.hand.append(armor_break)
	status_battle.play_hand_card(str(armor_break.get("uid", "")))
	if status_battle.enemy.get_status("armor_break") != 2 or status_battle.enemy.current_defense() != 0:
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
	zone_battle.play_hand_card(str(incense.get("uid", "")))
	var hand_after_zone_play: int = zone_battle.deck.hand.size()
	if zone_battle.player.spell_zone.size() != 1 or int(zone_battle.player.spell_zone[0].get("zone_countdown", -1)) != 2:
		return false
	zone_battle.resolver.apply_player_turn_start(zone_battle)
	if int(zone_battle.player.spell_zone[0].get("zone_countdown", -1)) != 1:
		return false
	zone_battle.resolver.apply_player_turn_start(zone_battle)
	var expected_zone_hand_floor: int = min(hand_after_zone_play + 1, DeckManagerScript.DEFAULT_HAND_LIMIT)
	if not zone_battle.player.spell_zone.is_empty() or zone_battle.deck.hand.size() < expected_zone_hand_floor:
		return false

	var cancel_battle = BattleManagerScript.new()
	cancel_battle.start_run("sword")
	_isolate_enemy_unit_actions(cancel_battle)
	cancel_battle.player.spell_zone.append(_ready_defense("攻击无效符"))
	var hp_before_cancel: int = cancel_battle.player.hp
	cancel_battle.end_player_turn()
	if cancel_battle.phase != "response":
		return false
	_play_response(cancel_battle, str(cancel_battle.player.spell_zone[0].get("uid", "")))
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

func _test_first_edition_interaction_cards() -> bool:
	var prep_battle = BattleManagerScript.new()
	prep_battle.start_run("sword")
	prep_battle.enemy.defense = 0
	prep_battle.deck.hand.clear()
	var break_prep := CardDatabaseScript.make_card("破防准备")
	prep_battle.deck.hand.append(break_prep)
	var enemy_hp_before: int = prep_battle.enemy.hp
	prep_battle.play_hand_card_on_unit_target(str(break_prep.get("uid", "")), str(prep_battle.player.uid))
	if prep_battle.player.attack_attach_statuses.size() != 1:
		return false
	if not _submit_request_accepted(prep_battle, {
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_PLAYER,
		"source_uid": str(prep_battle.player.uid),
		"target_uid": str(prep_battle.enemy.uid)
	}):
		return false
	if prep_battle.enemy.get_status("armor_break") != 1:
		return false
	if prep_battle.enemy.hp != enemy_hp_before - 4:
		return false

	var blocked_heal_battle = BattleManagerScript.new()
	blocked_heal_battle.start_run("sword")
	blocked_heal_battle.player.hp = max(1, blocked_heal_battle.player.hp - 10)
	var blocked_heal := CardDatabaseScript.make_card("疗伤")
	blocked_heal_battle.deck.hand.append(blocked_heal)
	blocked_heal_battle.player_unit_attack(blocked_heal_battle.player.uid)
	var blocked_hp_before: int = blocked_heal_battle.player.hp
	blocked_heal_battle.play_hand_card_on_unit_target(str(blocked_heal.get("uid", "")), str(blocked_heal_battle.player.uid))
	if blocked_heal_battle.player.hp != blocked_hp_before:
		return false
	if blocked_heal_battle.deck.find_hand_card(str(blocked_heal.get("uid", ""))).is_empty():
		return false

	var heal_battle = BattleManagerScript.new()
	heal_battle.start_run("sword")
	heal_battle.player.hp = max(1, heal_battle.player.hp - 10)
	var heal_card := CardDatabaseScript.make_card("疗伤")
	heal_battle.deck.hand.append(heal_card)
	var heal_hp_before: int = heal_battle.player.hp
	heal_battle.play_hand_card_on_unit_target(str(heal_card.get("uid", "")), str(heal_battle.player.uid))
	if heal_battle.player.hp != min(heal_battle.player.max_hp, heal_hp_before + 8):
		return false
	if not heal_battle.player_unit_action_used(heal_battle.player):
		return false
	if not heal_battle.deck.find_hand_card(str(heal_card.get("uid", ""))).is_empty():
		return false

	var cleanse_battle = BattleManagerScript.new()
	cleanse_battle.start_run("sword")
	cleanse_battle.enemy.add_status("next_damage_reduce", 3)
	var cleanse_card := CardDatabaseScript.make_card("清除增益")
	cleanse_battle.deck.hand.append(cleanse_card)
	cleanse_battle.play_hand_card_on_enemy_target(str(cleanse_card.get("uid", "")), str(cleanse_battle.enemy.uid))
	if cleanse_battle.enemy.get_status("next_damage_reduce") != 0:
		return false

	var draw_battle = BattleManagerScript.new()
	draw_battle.start_run("sword")
	draw_battle.deck.hand.clear()
	draw_battle.deck.deck.clear()
	draw_battle.deck.deck.append(CardDatabaseScript.make_card("防御准备"))
	draw_battle.deck.deck.append(CardDatabaseScript.make_card("中毒"))
	var draw_card := CardDatabaseScript.make_card("急抽")
	draw_battle.deck.hand.append(draw_card)
	draw_battle.play_hand_card(str(draw_card.get("uid", "")))
	if draw_battle.deck.hand.size() != 2 or draw_battle.deck.exile.size() != 1:
		return false
	var found_blank := false
	for card_variant in draw_battle.deck.graveyard:
		var grave_card: Dictionary = card_variant
		if str(grave_card.get("id", "")) == "blank_card":
			found_blank = true
			break
	if not found_blank:
		return false

	var ai_battle = BattleManagerScript.new()
	ai_battle.start_run("sword")
	ai_battle.enemy_side.deck_manager.hand.clear()
	ai_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("疗伤"))
	ai_battle.enemy_side.deck_manager.hand.append(CardDatabaseScript.make_card("空卡"))
	var ai_source = ai_battle.enemy_controller.side_card_source_unit(ai_battle)
	var ai_card: Dictionary = ai_battle.enemy_controller.select_next_side_card(ai_battle, ai_source)
	if str(ai_card.get("id", "")) != "blank_card":
		return false
	ai_battle.enemy.hp = max(1, ai_battle.enemy.hp - 5)
	ai_card = ai_battle.enemy_controller.select_next_side_card(ai_battle, ai_source)
	return str(ai_card.get("id", "")) == "heal_wound"

func _test_noop_card_and_negative_defense() -> bool:
	var blank_definition: Dictionary = CardDefinitionDatabaseScript.get_card("空卡")
	var blank_steps: Array = blank_definition.get("effect_steps", [])
	if blank_definition.is_empty() or str(blank_definition.get("id", "")) != "blank_card" or blank_definition.has("effect") or blank_steps.size() != 1:
		return false
	var blank_step: Dictionary = blank_steps[0]
	if str(blank_step.get("effect_type", "")) != "no_effect" or blank_step.has("kind"):
		return false
	if CardPoolDatabaseScript.common_pool().has("blank_card") or CardPoolDatabaseScript.reward_pool_for_job("sword", "normal", 0).has("blank_card"):
		return false
	if CardPoolDatabaseScript.card_unlocked_for_job("空卡", "sword", 0) or CardPoolDatabaseScript.card_unlocked_for_job("blank_card", "sword", 0):
		return false
	var blank_compatible: Dictionary = CardDatabaseScript.get_card("空卡")
	if str(blank_compatible.get("id", "")) != "blank_card" or bool(blank_compatible.get("default_unlocked", true)) or not (blank_compatible.get("unlock_packs", []) as Array).is_empty():
		return false

	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var blank_card := CardDatabaseScript.make_card("空卡")
	battle.deck.hand.append(blank_card)
	var player_hp_before: int = battle.player.hp
	var enemy_hp_before: int = battle.enemy.hp
	var player_status_before: Array = battle.player.status_instances.duplicate(true)
	var enemy_status_before: Array = battle.enemy.status_instances.duplicate(true)
	var player_resources_before: Dictionary = battle.player.resource_counters.duplicate(true)
	var unit_actions_before: Dictionary = battle.player_unit_actions_used.duplicate(true)
	var deck_size_before: int = battle.deck.deck.size()
	var hand_size_before: int = battle.deck.hand.size()
	var graveyard_size_before: int = battle.deck.graveyard.size()
	var exile_size_before: int = battle.deck.exile.size()
	battle.play_hand_card(str(blank_card.get("uid", "")))
	if battle.player.hp != player_hp_before or battle.enemy.hp != enemy_hp_before:
		return false
	if battle.player.status_instances != player_status_before or battle.enemy.status_instances != enemy_status_before:
		return false
	if battle.player.resource_counters != player_resources_before:
		return false
	if battle.player_unit_actions_used != unit_actions_before:
		return false
	if battle.deck.deck.size() != deck_size_before or battle.deck.hand.size() != hand_size_before - 1:
		return false
	if battle.deck.graveyard.size() != graveyard_size_before + 1 or battle.deck.exile.size() != exile_size_before:
		return false
	if str(battle.deck.graveyard.back().get("id", "")) != "blank_card":
		return false

	var unit = BattleUnitScript.new()
	unit.setup_unit({"id": "negative_defense_unit", "name": "负防测试", "max_hp": 20, "attack": 0, "defense": 0})
	unit.add_status("armor_break", 2)
	if unit.current_defense() != -2:
		return false
	var player_state_battle = BattleManagerScript.new()
	var player_unit = player_state_battle.player
	player_unit.setup_unit({"id": "negative_defense_player", "name": "负防玩家测试", "max_hp": 20, "attack": 0, "defense": 0})
	player_unit.add_status("armor_break", 2)
	if player_unit.current_defense() != -2:
		return false

	var damage_battle = BattleManagerScript.new()
	damage_battle.start_run("sword")
	damage_battle.enemy.defense = 0
	damage_battle.enemy.temp_defense_delta = 0
	damage_battle.enemy.equipment_defense_bonus = 0
	damage_battle.enemy.status_instances.clear()
	damage_battle.enemy.add_status("armor_break", 2)
	var damage_hp_before: int = damage_battle.enemy.hp
	damage_battle.effect_resolver.apply_steps(damage_battle, damage_battle.player, [
		{"effect_type": "damage", "target": "enemy", "value": 5, "source": "负防测试"}
	])
	if damage_battle.enemy.hp != damage_hp_before - 7:
		return false

	var ignore_battle = BattleManagerScript.new()
	ignore_battle.start_run("sword")
	ignore_battle.enemy.defense = 0
	ignore_battle.enemy.temp_defense_delta = 0
	ignore_battle.enemy.equipment_defense_bonus = 0
	ignore_battle.enemy.status_instances.clear()
	ignore_battle.enemy.add_status("armor_break", 2)
	var ignore_hp_before: int = ignore_battle.enemy.hp
	ignore_battle.effect_resolver.apply_steps(ignore_battle, ignore_battle.player, [
		{"effect_type": "damage", "target": "enemy", "value": 5, "ignore_defense": true, "source": "无视防御测试"}
	])
	return ignore_battle.enemy.hp == ignore_hp_before - 5

func _test_inactive_enemy_deck_candidates() -> bool:
	var candidates: Array = EnemyDeckTemplateDatabaseScript.candidate_deck_templates()
	var active_ids: Array = CardPoolDatabaseScript.active_card_ids()
	var legacy_ids: Array = CardPoolDatabaseScript.legacy_card_ids()
	var expected_ids := ["l1_candidate_normal_weaken", "l1_candidate_elite_heal", "l1_candidate_boss_mix"]
	for expected_id in expected_ids:
		var found := false
		for candidate_variant in candidates:
			var candidate: Dictionary = candidate_variant
			if str(candidate.get("id", "")) != expected_id:
				continue
			found = true
			if bool(candidate.get("enabled", true)) or not bool(candidate.get("candidate", false)):
				return false
			if (candidate.get("character_refs", []) as Array).is_empty():
				return false
			for card_id_variant in candidate.get("deck", []):
				var raw_card_id := str(card_id_variant)
				var card_id := CardDefinitionDatabaseScript.normalize_card_id(raw_card_id)
				if raw_card_id != card_id:
					return false
				if CardDefinitionDatabaseScript.get_card(card_id).is_empty():
					return false
				if legacy_ids.has(card_id):
					return false
				if not active_ids.has(card_id):
					return false
			break
		if not found:
			return false
	for encounter_type in ["normal", "elite", "boss"]:
		var active_templates: Array = EnemyDeckTemplateDatabaseScript.deck_templates_for(1, encounter_type, 0)
		for template_variant in active_templates:
			var template: Dictionary = template_variant
			if expected_ids.has(str(template.get("id", ""))):
				return false
	return true
