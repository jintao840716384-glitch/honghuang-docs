extends RefCounted
class_name BattleManager

signal combat_event(payload: Dictionary)

const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const CardAcquisitionRulesScript = preload("res://scripts/run/CardAcquisitionRules.gd")
const RewardServiceScript = preload("res://scripts/run/RewardService.gd")
const PlayerStateScript = preload("res://scripts/battle/PlayerState.gd")
const EnemyStateScript = preload("res://scripts/battle/EnemyState.gd")
const DeckManagerScript = preload("res://scripts/battle/DeckManager.gd")
const CardResolverScript = preload("res://scripts/battle/CardResolver.gd")
const EffectResolverScript = preload("res://scripts/battle/EffectResolver.gd")
const BattleEncounterRuntimeScript = preload("res://scripts/battle/BattleEncounterRuntime.gd")
const BattleFormationScript = preload("res://scripts/battle/BattleFormation.gd")
const BattleUnitScript = preload("res://scripts/battle/BattleUnit.gd")
const BattleSideScript = preload("res://scripts/battle/BattleSide.gd")
const EnemyAIControllerScript = preload("res://scripts/battle/EnemyAIController.gd")
const BattleActionRulesScript = preload("res://scripts/battle/BattleActionRules.gd")
const ResponseWindowRulesScript = preload("res://scripts/battle/ResponseWindowRules.gd")
const StatusDatabaseScript = preload("res://scripts/data/StatusDatabase.gd")
const StatusRulesScript = preload("res://scripts/battle/StatusRules.gd")
const BattleContextScript = preload("res://scripts/battle/BattleContext.gd")
const BattleRequestScript = preload("res://scripts/battle/BattleRequest.gd")
const BattleResultScript = preload("res://scripts/battle/BattleResult.gd")
const BattleSnapshotScript = preload("res://scripts/battle/BattleSnapshot.gd")
const WorldDifficultyDatabaseScript = preload("res://scripts/data/WorldDifficultyDatabase.gd")

var context
var player:
	get: return context.player
	set(value): context.player = value
var enemy:
	get: return context.enemy
	set(value): context.enemy = value
var formation:
	get: return context.formation
	set(value): context.formation = value
var player_side:
	get: return context.player_side
	set(value): context.player_side = value
var enemy_side:
	get: return context.enemy_side
	set(value): context.enemy_side = value
var deck:
	get: return context.deck
	set(value): context.deck = value
var resolver
var effect_resolver
var enemy_controller
var job_id:
	get: return context.job_id
	set(value): context.job_id = value
var battle_number:
	get: return context.battle_number
	set(value): context.battle_number = value
var turn_number:
	get: return context.turn_number
	set(value): context.turn_number = value
var phase:
	get: return context.phase
	set(value): context.phase = value
var master_deck_ids:
	get: return context.master_deck_ids
	set(value): context.master_deck_ids = value
var master_reserve_ids:
	get: return context.master_reserve_ids
	set(value): context.master_reserve_ids = value
var reward_options:
	get: return context.reward_options
	set(value): context.reward_options = value
var pending_choice:
	get: return context.pending_choice
	set(value): context.pending_choice = value
var pending_equipment_replace:
	get: return context.pending_equipment_replace
	set(value): context.pending_equipment_replace = value
var messages:
	get: return context.messages
	set(value): context.messages = value
var rng:
	get: return context.rng
	set(value): context.rng = value
var current_event:
	get: return context.current_event
	set(value): context.current_event = value
var chain_stack:
	get: return context.chain_stack
	set(value): context.chain_stack = value
var response_loop_guard:
	get: return context.response_loop_guard
	set(value): context.response_loop_guard = value
var response_chain_state:
	get: return context.response_chain_state
	set(value): context.response_chain_state = value
var response_skipped:
	get: return context.response_skipped
	set(value): context.response_skipped = value
var response_window_owner_side:
	get: return context.response_window_owner_side
	set(value): context.response_window_owner_side = value
var active_response_side:
	get: return context.active_response_side
	set(value): context.active_response_side = value
var response_pass_state:
	get: return context.response_pass_state
	set(value): context.response_pass_state = value
var auto_advance_after_reward:
	get: return context.auto_advance_after_reward
	set(value): context.auto_advance_after_reward = value
var current_encounter_type:
	get: return context.current_encounter_type
	set(value): context.current_encounter_type = value
var current_realm_index:
	get: return context.current_realm_index
	set(value): context.current_realm_index = value
var current_realm_name:
	get: return context.current_realm_name
	set(value): context.current_realm_name = value
var draw_per_turn:
	get: return context.draw_per_turn
	set(value): context.draw_per_turn = value
var deck_score_limit:
	get: return context.deck_score_limit
	set(value): context.deck_score_limit = value
var meta_bonuses:
	get: return context.meta_bonuses
	set(value): context.meta_bonuses = value
var selected_enemy_uid:
	get: return context.selected_enemy_uid
	set(value): context.selected_enemy_uid = value
var selected_player_uid:
	get: return context.selected_player_uid
	set(value): context.selected_player_uid = value
var selected_debug_uid:
	get: return context.selected_debug_uid
	set(value): context.selected_debug_uid = value
var pending_target_action:
	get: return context.pending_target_action
	set(value): context.pending_target_action = value
var enemy_action_queue:
	get: return context.enemy_action_queue
	set(value): context.enemy_action_queue = value
var player_unit_actions_used:
	get: return context.player_unit_actions_used
	set(value): context.player_unit_actions_used = value
var active_enemy_unit:
	get: return context.active_enemy_unit
	set(value): context.active_enemy_unit = value
var current_enemy_deck_profile:
	get: return context.current_enemy_deck_profile
	set(value): context.current_enemy_deck_profile = value
var current_encounter_profile:
	get: return context.current_encounter_profile
	set(value): context.current_encounter_profile = value
var enemy_cards_played_this_turn:
	get: return context.enemy_cards_played_this_turn
	set(value): context.enemy_cards_played_this_turn = value
var current_world_difficulty:
	get: return context.current_world_difficulty
	set(value): context.current_world_difficulty = value

const MAX_CHAIN_ACTIONS := 32
const EVENT_FIELD_TYPE := "event_type"
const EVENT_FIELD_SOURCE := "source"
const EVENT_FIELD_SOURCE_KEY := "source_key"
const EVENT_FIELD_TARGET := "target"
const EVENT_FIELD_TARGET_KEY := "target_key"
const EVENT_FIELD_VALUE := "value"
const EVENT_FIELD_CANCELLED := "cancelled"
const EVENT_FIELD_MODIFIERS := "modifiers"
const EVENT_FIELD_PROTECTED_TARGETS := "protected_targets"
const EVENT_FIELD_NORMAL_ATTACK := "normal_attack"
const EVENT_FIELD_ATTACK_SOURCE_KEY := "attack_source_key"
const EVENT_FIELD_ATTACK_SOURCE_UNIT := "attack_source_unit"
const EVENT_FIELD_POST_STEPS := "post_steps"
const EVENT_FIELD_POST_SOURCE_UNIT := "post_source_unit"
const EVENT_FIELD_ENEMY_SIDE_CARD := "enemy_side_card"
const RESPONSE_CHAIN_STATE_OPEN := "open"
const RESPONSE_CHAIN_STATE_LOCKED := "locked"
const RESPONSE_CHAIN_STATE_RESOLVING := "resolving"
const RESPONSE_CHAIN_STATE_RESOLVED := "resolved"
const STATUS_BURN := "灼伤"
const STATUS_DELAY := "迟滞"
const STATUS_POISON := StatusDatabaseScript.STATUS_POISON
const STATUS_ARMOR_BREAK := StatusDatabaseScript.STATUS_ARMOR_BREAK
const STATUS_WEAK := StatusDatabaseScript.STATUS_WEAK
const STATUS_NEXT_DAMAGE_REDUCTION := StatusDatabaseScript.STATUS_NEXT_DAMAGE_REDUCE

func _init() -> void:
	context = BattleContextScript.new()
	player = PlayerStateScript.new()
	enemy = EnemyStateScript.new()
	formation = BattleFormationScript.new()
	player_side = BattleSideScript.new()
	enemy_side = BattleSideScript.new()
	deck = DeckManagerScript.new()
	resolver = CardResolverScript.new()
	effect_resolver = EffectResolverScript.new()
	enemy_controller = EnemyAIControllerScript.new()
	rng.randomize()

func start_run(selected_job_id: String) -> void:
	job_id = selected_job_id
	auto_advance_after_reward = true
	current_encounter_type = "normal"
	current_realm_index = 0
	current_realm_name = "练气"
	current_world_difficulty = 0
	draw_per_turn = 1
	deck_score_limit = 0
	meta_bonuses.clear()
	var job := JobDatabaseScript.get_job(job_id)
	player.setup_from_job(job)
	master_deck_ids = player.start_deck_from_job(job)
	master_reserve_ids.clear()
	battle_number = 1
	messages.clear()
	start_battle()

func start_run_with_deck(selected_job_id: String, deck_ids: Array, selected_battle_number := 1, encounter_type := "normal", auto_advance := false, run_context := {}) -> void:
	job_id = selected_job_id
	auto_advance_after_reward = auto_advance
	current_encounter_type = encounter_type
	current_realm_index = int(run_context.get("realm_index", 0))
	current_realm_name = str(run_context.get("realm_name", "练气"))
	var requested_world_difficulty: int = max(0, int(run_context.get("world_difficulty", 0)))
	current_world_difficulty = requested_world_difficulty if WorldDifficultyDatabaseScript.is_active_value(requested_world_difficulty) else 0
	draw_per_turn = max(1, int(run_context.get("draw_per_turn", 1)))
	deck_score_limit = int(run_context.get("deck_score_limit", 0))
	meta_bonuses = (run_context.get("meta_bonuses", {}) as Dictionary).duplicate(true)
	var job := JobDatabaseScript.get_job(job_id)
	player.setup_from_job(job)
	_apply_meta_bonuses()
	var context_max_hp := int(run_context.get("max_hp", -1))
	if context_max_hp > 0:
		player.max_hp = context_max_hp
	var context_current_hp := int(run_context.get("current_hp", -1))
	if context_current_hp >= 0:
		player.hp = clampi(context_current_hp, 0, player.max_hp)
	master_deck_ids = deck_ids.duplicate()
	master_reserve_ids = run_context.get("reserve_ids", []).duplicate()
	battle_number = max(1, int(selected_battle_number))
	messages.clear()
	start_battle()

func restart_run() -> void:
	if auto_advance_after_reward:
		start_run(job_id)
	else:
		start_run_with_deck(job_id, master_deck_ids, battle_number, current_encounter_type, false, {
			"current_hp": player.hp,
			"max_hp": player.max_hp,
			"draw_per_turn": draw_per_turn,
			"deck_score_limit": deck_score_limit,
			"reserve_ids": master_reserve_ids.duplicate(),
			"realm_index": current_realm_index,
			"realm_name": current_realm_name,
			"world_difficulty": current_world_difficulty,
			"meta_bonuses": meta_bonuses.duplicate(true)
		})

func _apply_meta_bonuses() -> void:
	if meta_bonuses.is_empty():
		return
	player.max_hp += int(meta_bonuses.get("max_hp", 0))
	player.hp = player.max_hp
	player.attack += int(meta_bonuses.get("attack", 0))
	player.defense += int(meta_bonuses.get("defense", 0))

func start_battle() -> void:
	context.begin_battle_identity(battle_number)
	pending_choice.clear()
	pending_equipment_replace.clear()
	pending_target_action.clear()
	enemy_action_queue.clear()
	player_unit_actions_used.clear()
	reward_options.clear()
	_clear_response_window_context()
	active_enemy_unit = null
	current_enemy_deck_profile.clear()
	current_encounter_profile = _select_encounter_profile()
	enemy_cards_played_this_turn = 0
	phase = "player"
	turn_number = 0
	player.reset_for_battle()
	enemy = EnemyStateScript.new()
	enemy.setup(_enemy_data_for_current_battle())
	current_enemy_deck_profile = _enemy_deck_profile_from_encounter()
	formation.setup_primary(player, enemy)
	_add_extra_enemy_units_from_encounter()
	_setup_battle_sides()
	selected_enemy_uid = enemy.uid
	selected_player_uid = player.uid
	selected_debug_uid = enemy.uid
	player_side.setup_deck(master_deck_ids)
	enemy_side.setup_deck(_enemy_deck_for_current_encounter())
	add_log("%s，第 %d 场战斗：%s。" % [current_realm_name, battle_number, enemy.name])
	if player.hp <= 0:
		player.hp = 0
		phase = "defeat"
		add_log("玩家生命为 0，无法进入战斗。")
		return
	_draw_player_cards(5, "opening")
	_flush_deck_messages()
	start_player_turn()

func _add_extra_enemy_units_from_encounter() -> void:
	var units: Array = current_encounter_profile.get("enemy_units", [])
	for i in range(1, units.size()):
		var data: Dictionary = units[i]
		var unit = EnemyStateScript.new()
		unit.setup(data)
		formation.add_unit(unit, BattleUnitScript.TEAM_ENEMY, int(data.get("slot_index", -1)))

func _setup_battle_sides() -> void:
	player_side.setup("player", BattleUnitScript.TEAM_PLAYER, player, formation.player_units, deck)
	player_side.bind_player_state(player)
	player_side.draw_per_turn = draw_per_turn
	player_side.visible_zones = {
		"spell_zone": true,
		"hand": true,
		"deck": true,
		"graveyard": true,
		"exile": true
	}
	enemy_side.setup("enemy", BattleUnitScript.TEAM_ENEMY, enemy, formation.enemy_units)
	enemy_side.reset_visible_zones()
	enemy_side.draw_per_turn = _enemy_draw_for_current_encounter()
	enemy_side.visible_zones = {
		"spell_zone": true,
		"hand": false,
		"deck": false,
		"graveyard": false,
		"exile": false
	}
	var starting_sword: int = int(meta_bonuses.get("starting_sword", 0))
	if starting_sword > 0 and player.job_id == "sword":
		player.add_sword(starting_sword)
		add_log("局外成长：开局获得 %d 点剑势。" % starting_sword)

func _refresh_side_unit_refs() -> void:
	if player_side != null:
		player_side.set_units(formation.player_units)
	if enemy_side != null:
		enemy_side.set_units(formation.enemy_units)

func _cleanup_defeated_units() -> void:
	var removed_units: Array = formation.remove_defeated_units()
	if removed_units.is_empty():
		return
	var removed_uids: Dictionary = {}
	for unit in removed_units:
		if unit == null:
			continue
		var uid := str(unit.uid)
		removed_uids[uid] = true
		player_unit_actions_used.erase(uid)
		add_log("%s 阵亡退场。" % _unit_display_name(unit))
	if removed_uids.has(selected_enemy_uid):
		selected_enemy_uid = ""
	if removed_uids.has(selected_player_uid):
		selected_player_uid = ""
	if removed_uids.has(selected_debug_uid):
		selected_debug_uid = ""
	if not pending_target_action.is_empty() and removed_uids.has(str(pending_target_action.get("source_uid", ""))):
		pending_target_action.clear()
		if phase == "target_select":
			phase = "player"
	for i in range(enemy_action_queue.size() - 1, -1, -1):
		var queued_unit = enemy_action_queue[i]
		if queued_unit == null or removed_uids.has(str(queued_unit.uid)):
			enemy_action_queue.remove_at(i)
	_refresh_side_unit_refs()

func _enemy_draw_for_current_encounter() -> int:
	return BattleEncounterRuntimeScript.draw_per_turn(current_encounter_profile, current_encounter_type)

func _enemy_deck_for_current_encounter() -> Array:
	var profile: Dictionary = _enemy_deck_profile()
	return profile.get("deck", []).duplicate()

func _current_layer_index() -> int:
	return max(1, current_realm_index + 1)

func _enemy_deck_profile() -> Dictionary:
	if current_enemy_deck_profile.is_empty():
		current_enemy_deck_profile = _enemy_deck_profile_from_encounter()
	return current_enemy_deck_profile

func _enemy_deck_profile_from_encounter() -> Dictionary:
	if current_encounter_profile.is_empty():
		current_encounter_profile = _select_encounter_profile()
	return BattleEncounterRuntimeScript.deck_profile(current_encounter_profile)

func _select_encounter_profile() -> Dictionary:
	return BattleEncounterRuntimeScript.select_encounter(
		battle_number,
		current_encounter_type,
		current_realm_index,
		current_world_difficulty,
		rng
	)

func start_player_turn() -> void:
	if phase == "defeat":
		return
	phase = "player"
	turn_number += 1
	emit_combat_event({"type": "turn_started", "side": "player", "label": "我方回合"})
	_clear_player_temporary_defense()
	_reset_player_unit_actions()
	player.start_turn()
	add_log("玩家第 %d 回合开始。" % turn_number)
	resolver.apply_player_turn_start(self)
	if check_victory_or_defeat():
		return
	_draw_player_cards(draw_per_turn, "turn")
	_flush_deck_messages()
	_apply_after_draw_poison_for_team(BattleUnitScript.TEAM_PLAYER)
	if check_victory_or_defeat():
		return
	enemy.current_intent = enemy.peek_action().get("intent", "")

func submit_request(request: Dictionary) -> Dictionary:
	return handle_battle_request(request)

func handle_battle_request(request: Dictionary) -> Dictionary:
	var canonical_request: Dictionary = BattleRequestScript.normalize(context, request)
	var validation_error: String = BattleRequestScript.validation_error(canonical_request)
	if validation_error != "":
		var invalid_result: Dictionary = BattleResultScript.rejected(canonical_request, validation_error)
		context.last_result = invalid_result.duplicate(true)
		return invalid_result
	var previous_phase: String = str(phase)
	var previous_message_count: int = messages.size()
	context.request_events.clear()
	context.collecting_result_events = true
	var accepted := _handle_battle_request_bool(canonical_request)
	context.collecting_result_events = false
	var state_changes := {
		"phase_before": previous_phase,
		"phase_after": phase,
		"messages_added": max(0, messages.size() - previous_message_count)
	}
	var result: Dictionary
	if accepted:
		result = BattleResultScript.accepted(canonical_request, true, context.request_events, state_changes)
	else:
		result = BattleResultScript.rejected(canonical_request, "request_rejected", context.request_events, state_changes)
	context.last_result = result.duplicate(true)
	return result

# Compatibility for existing test helpers; production UI and AI submit BattleRequest and consume BattleResult.
func _submit_request_accepted(request: Dictionary) -> bool:
	return bool(submit_request(request).get("accepted", false))

func _handle_battle_request_bool(request: Dictionary) -> bool:
	var side_id := _request_side(request)
	if side_id == "":
		return false
	match str(_request_value(request, "request_type", "")):
		"play_card":
			if side_id == BattleUnitScript.TEAM_PLAYER:
				return _handle_player_play_card_request(request)
			return _handle_enemy_play_card_request(request)
		"unit_attack":
			if side_id == BattleUnitScript.TEAM_PLAYER:
				return _handle_player_unit_attack_request(request)
			return _handle_enemy_unit_attack_request(request)
		"unit_defend":
			if side_id == BattleUnitScript.TEAM_PLAYER:
				return _handle_player_unit_defend_request(request)
			return _handle_enemy_unit_defend_request(request)
		"spell_attack":
			if side_id != BattleUnitScript.TEAM_ENEMY:
				return false
			return _handle_enemy_spell_attack_request(request)
		"select_target":
			if side_id != BattleUnitScript.TEAM_PLAYER:
				return false
			return _handle_player_select_target_request(request)
		"confirm_target":
			if side_id != BattleUnitScript.TEAM_PLAYER:
				return false
			return _handle_player_confirm_target_request(request)
		"end_turn":
			if side_id != BattleUnitScript.TEAM_PLAYER:
				return false
			return _handle_player_end_turn_request(request)
		"play_response":
			if side_id != BattleUnitScript.TEAM_PLAYER:
				return false
			return _handle_player_response_request(request)
		"skip_response":
			return _handle_skip_response_request(request)
		"choose_equipment_replacement":
			if side_id != BattleUnitScript.TEAM_PLAYER:
				return false
			return _handle_choose_equipment_replacement_request(request)
		"cancel_equipment_replacement":
			if side_id != BattleUnitScript.TEAM_PLAYER:
				return false
			return _handle_cancel_equipment_replacement_request()
		_:
			return false


func _request_value(request: Dictionary, key: String, default_value = null):
	return BattleRequestScript.value(request, key, default_value)

func _request_side(request: Dictionary) -> String:
	if not request.has("side"):
		return ""
	var side_id := str(_request_value(request, "side", ""))
	if side_id == BattleUnitScript.TEAM_PLAYER or side_id == BattleUnitScript.TEAM_ENEMY:
		return side_id
	return ""

func _request_side_is_player(request: Dictionary) -> bool:
	return _request_side(request) == BattleUnitScript.TEAM_PLAYER

func _request_side_is_enemy(request: Dictionary) -> bool:
	return _request_side(request) == BattleUnitScript.TEAM_ENEMY

func play_hand_card(uid: String) -> void:
	_submit_request_accepted({
		"type": "play_card",
		"side": BattleUnitScript.TEAM_PLAYER,
		"card_uid": uid
	})

func play_hand_card_on_enemy_target(uid: String, target_uid: String) -> void:
	_submit_request_accepted({
		"type": "play_card",
		"side": BattleUnitScript.TEAM_PLAYER,
		"card_uid": uid,
		"target_uid": target_uid
	})

func play_hand_card_on_unit_target(uid: String, target_uid: String) -> void:
	_submit_request_accepted({
		"type": "play_card",
		"side": BattleUnitScript.TEAM_PLAYER,
		"card_uid": uid,
		"target_uid": target_uid
	})

func activate_spell_zone_card(uid: String) -> void:
	resolver.activate_spell_zone_card(self, uid)

func _handle_player_play_card_request(request: Dictionary) -> bool:
	if not _request_side_is_player(request):
		return false
	if phase != "player":
		add_log("Cannot play a card outside the player phase.")
		return false
	if not pending_choice.is_empty():
		add_log("Resolve the current choice first.")
		return false
	if not pending_equipment_replace.is_empty():
		add_log("Resolve equipment replacement first.")
		return false
	var uid := str(_request_value(request, "card_uid", ""))
	if uid == "":
		return false
	var hand_card: Dictionary = deck.find_hand_card(uid)
	if hand_card.is_empty():
		add_log("No playable hand card was found.")
		return false
	var target_uid := str(_request_value(request, "target_uid", ""))
	if target_uid == "":
		resolver.play_hand_card(self, uid)
		return true
	var target_unit = formation.unit_by_uid(target_uid)
	if target_unit == null or int(target_unit.hp) <= 0:
		add_log("No valid target was found.")
		return false
	if str(target_unit.team) == BattleUnitScript.TEAM_PLAYER:
		selected_player_uid = str(target_unit.uid)
	elif str(target_unit.team) == BattleUnitScript.TEAM_ENEMY:
		if not _select_enemy_target(str(target_unit.uid)):
			add_log("No selectable enemy target was found.")
			return false
		selected_enemy_uid = str(target_unit.uid)
	selected_debug_uid = str(target_unit.uid)
	var context := {"target_unit": target_unit}
	if str(hand_card.get("after_use", "")) == "equipment":
		context["equipment_target_uid"] = str(target_unit.uid)
	resolver.play_spell_card(self, uid, true, context)
	return true

func _handle_enemy_play_card_request(request: Dictionary) -> bool:
	if not _request_side_is_enemy(request):
		return false
	if phase != "enemy":
		add_log("Cannot play an enemy card outside the enemy phase.")
		return false
	if enemy_side == null or enemy_side.deck_manager == null:
		return false
	var uid := str(_request_value(request, "card_uid", ""))
	if uid == "":
		return false
	var source_uid := str(_request_value(request, "source_uid", _request_value(request, "actor_uid", "")))
	var source_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_ENEMY, source_uid)
	if source_unit == null:
		add_log("No enemy source unit was found for card play.")
		return false
	var target_uid := str(_request_value(request, "target_uid", ""))
	var context := {}
	if target_uid != "":
		var target_unit = formation.unit_by_uid(target_uid)
		if target_unit == null or int(target_unit.hp) <= 0:
			add_log("No valid enemy card target was found.")
			return false
		context["target_unit"] = target_unit
		context["target_uid"] = target_uid
	return resolver.play_side_hand_card(self, BattleUnitScript.TEAM_ENEMY, source_unit, uid, context)

func get_pending_options() -> Array:
	return resolver.get_pending_options(self)

func choose_pending(uid: String) -> void:
	resolver.choose_pending(self, uid)

func _handle_choose_equipment_replacement_request(request: Dictionary) -> bool:
	if pending_equipment_replace.is_empty():
		return false
	resolver.choose_equipment_replacement(self, str(_request_value(request, "equipment_uid", "")))
	return pending_equipment_replace.is_empty()

func _handle_cancel_equipment_replacement_request() -> bool:
	if pending_equipment_replace.is_empty():
		return false
	pending_equipment_replace.clear()
	add_log("取消装备替换。")
	return true


func choose_equipment_replacement(uid: String) -> Dictionary:
	return submit_request({"request_type": "choose_equipment_replacement", "side": BattleUnitScript.TEAM_PLAYER, "equipment_uid": uid})


func cancel_equipment_replacement() -> Dictionary:
	return submit_request({"request_type": "cancel_equipment_replacement", "side": BattleUnitScript.TEAM_PLAYER})

func _handle_player_unit_attack_request(request: Dictionary) -> bool:
	if not _request_side_is_player(request):
		return false
	if phase != "player":
		add_log("Cannot attack outside the player phase.")
		return false
	if not pending_choice.is_empty():
		add_log("Resolve the current choice first.")
		return false
	if not pending_equipment_replace.is_empty():
		add_log("Resolve equipment replacement first.")
		return false
	var unit_uid := str(_request_value(request, "source_uid", _request_value(request, "actor_uid", "")))
	if unit_uid == "":
		return false
	var source_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, unit_uid)
	if source_unit == null:
		add_log("No actionable player unit was found.")
		return false
	if player_unit_action_used(source_unit):
		add_log("%s has already acted this turn." % _unit_display_name(source_unit))
		return false
	var target_uid := str(_request_value(request, "target_uid", ""))
	if target_uid != "" and not _select_enemy_target(target_uid):
		add_log("No selectable enemy target was found.")
		return false
	if enemy_target_count() > 1 and target_uid == "" and not BattleActionRulesScript.player_attack_uses_auto_targets(player, source_unit):
		begin_enemy_target_selection({"type": "unit_attack", "source_uid": str(source_unit.uid)}, "閫夋嫨鏀诲嚮鐩爣")
		return true
	_perform_player_unit_attack(source_unit)
	return true

func _handle_enemy_unit_attack_request(request: Dictionary) -> bool:
	if not _request_side_is_enemy(request):
		return false
	if phase != "enemy":
		return false
	var source_uid := str(_request_value(request, "source_uid", _request_value(request, "actor_uid", "")))
	var source_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_ENEMY, source_uid)
	if source_unit == null:
		return false
	var target_uid := str(_request_value(request, "target_uid", ""))
	var target_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, target_uid)
	if target_unit == null:
		return false
	var power: int = int(_request_value(request, "power", source_unit.current_attack()))
	var final_power: int = _consume_delay_status_for_power(source_unit, power)
	add_log("%s 准备攻击 %s。" % [_unit_display_name(source_unit), _unit_display_name(target_unit)])
	emit_combat_event({"type": "enemy_intent_started", "intent": "攻击"})
	var event := create_event("enemy_attack_declared", source_unit, target_unit, final_power)
	event["normal_attack"] = bool(_request_value(request, "normal_attack", int(power) == int(source_unit.current_attack())))
	open_timing_window(event)
	return true

func _handle_enemy_spell_attack_request(request: Dictionary) -> bool:
	if not _request_side_is_enemy(request):
		return false
	if phase != "enemy":
		return false
	var source_uid := str(_request_value(request, "source_uid", _request_value(request, "actor_uid", "")))
	var source_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_ENEMY, source_uid)
	if source_unit == null:
		return false
	var target_uid := str(_request_value(request, "target_uid", ""))
	var target_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, target_uid)
	if target_unit == null:
		return false
	var power: int = int(_request_value(request, "power", source_unit.current_attack()))
	var final_power: int = _consume_delay_status_for_power(source_unit, power)
	add_log("%s 准备对 %s 施法。" % [_unit_display_name(source_unit), _unit_display_name(target_unit)])
	emit_combat_event({"type": "enemy_intent_started", "intent": "施法"})
	open_timing_window(create_event("enemy_spell_declared", source_unit, target_unit, final_power))
	return true

func player_normal_attack() -> void:
	_submit_request_accepted({
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_PLAYER,
		"source_uid": str(player.uid)
	})

func player_unit_attack(unit_uid: String) -> void:
	_submit_request_accepted({
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_PLAYER,
		"source_uid": unit_uid
	})

func _perform_player_normal_attack() -> void:
	_perform_player_unit_attack(player)

func _perform_player_unit_attack(source_unit) -> void:
	if source_unit == null or str(source_unit.team) != BattleUnitScript.TEAM_PLAYER:
		add_log("没有可行动的我方单位。")
		return
	if player_unit_action_used(source_unit):
		add_log("%s 本回合已经行动过。" % _unit_display_name(source_unit))
		return
	_mark_player_unit_action_used(source_unit)
	var hit_count: int = _perform_basic_attack_hits(source_unit)
	if hit_count > 0 and source_unit == player and player.job_id == "sword":
		var sword_gain: int = 1 + player.extra_sword_on_attack_hit
		add_unit_resource(player, "sword_momentum", sword_gain, "普通攻击")
		add_log("剑修普通攻击命中：获得 %d 点剑势。" % sword_gain)
	check_victory_or_defeat()

func _perform_basic_attack_hits(source_unit) -> int:
	var targets: Array = BattleActionRulesScript.basic_attack_targets(self, source_unit)
	if targets.is_empty():
		add_log("没有可攻击的敌方目标。")
		BattleActionRulesScript.clear_consumed_attack_modifiers(player, source_unit)
		return 0
	var hits := 0
	for target in targets:
		if target == null or int(target.hp) <= 0:
			continue
		emit_combat_event({"type": "attack_started", "source": _unit_event_key(source_unit), "target": _unit_event_key(target)})
		var damage: int = BattleActionRulesScript.basic_attack_damage(player, source_unit, target)
		if damage <= 0:
			add_log("%s 攻击 %s 未造成伤害。" % [_unit_display_name(source_unit), _unit_display_name(target)])
			emit_combat_event({"type": "attack_finished", "source": _unit_event_key(source_unit), "target": _unit_event_key(target)})
			continue
		var applied_damage: int = apply_damage_to_unit(target, damage, "normal_attack")
		if applied_damage > 0:
			hits += 1
			_apply_basic_attack_on_hit_effects(source_unit, target)
			add_log("%s 攻击 %s，造成 %d 点伤害。" % [_unit_display_name(source_unit), _unit_display_name(target), applied_damage])
		emit_combat_event({"type": "attack_finished", "source": _unit_event_key(source_unit), "target": _unit_event_key(target)})
		_cleanup_defeated_units()
		if formation.all_enemies_defeated():
			break
	BattleActionRulesScript.clear_consumed_attack_modifiers(player, source_unit)
	return hits

func _apply_basic_attack_on_hit_effects(source_unit, target_unit) -> void:
	if source_unit == null or target_unit == null:
		return
	for attach_variant in source_unit.attack_attach_statuses:
		var attach: Dictionary = attach_variant
		var status_id := str(attach.get("status", ""))
		if status_id == "":
			continue
		var value: int = int(attach.get("value", 0))
		if value == 0:
			continue
		add_unit_status(target_unit, status_id, value, str(attach.get("source", "攻击附加")))

func _handle_player_unit_defend_request(request: Dictionary) -> bool:
	if not _request_side_is_player(request):
		return false
	if phase != "player":
		add_log("Cannot defend outside the player phase.")
		return false
	if not pending_choice.is_empty():
		add_log("Resolve the current choice first.")
		return false
	if not pending_equipment_replace.is_empty():
		add_log("Resolve equipment replacement first.")
		return false
	var unit_uid := str(_request_value(request, "source_uid", _request_value(request, "actor_uid", "")))
	if unit_uid == "":
		return false
	var source_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, unit_uid)
	if source_unit == null:
		add_log("No defending player unit was found.")
		return false
	if player_unit_action_used(source_unit):
		add_log("%s has already acted this turn." % _unit_display_name(source_unit))
		return false
	var defense_bonus: int = BattleActionRulesScript.defense_bonus_for_unit(source_unit)
	source_unit.temp_defense_delta += defense_bonus
	_mark_player_unit_action_used(source_unit)
	add_log("%s enters defense and gains +%d defense until the next player turn." % [_unit_display_name(source_unit), defense_bonus])
	emit_combat_event({"type": "unit_defended", "target": _unit_event_key(source_unit), "value": defense_bonus})
	return true

func _handle_enemy_unit_defend_request(request: Dictionary) -> bool:
	if not _request_side_is_enemy(request):
		return false
	if phase != "enemy":
		return false
	var source_uid := str(_request_value(request, "source_uid", _request_value(request, "actor_uid", "")))
	var source_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_ENEMY, source_uid)
	if source_unit == null:
		return false
	var defense_delta: int = int(_request_value(request, "defense_delta", 0))
	source_unit.temp_defense_delta = defense_delta
	var action_kind := str(_request_value(request, "action_kind", "defense_stance"))
	if action_kind == "weakness":
		add_log("%s 防御力 %d，持续 1 回合。" % [_unit_display_name(source_unit), source_unit.temp_defense_delta])
	else:
		add_log("%s 防御力 +%d，持续 1 回合。" % [_unit_display_name(source_unit), source_unit.temp_defense_delta])
	emit_combat_event({"type": "unit_defended", "target": _unit_event_key(source_unit), "value": defense_delta})
	_finish_enemy_action()
	return true

func player_unit_defend(unit_uid: String) -> void:
	_submit_request_accepted({
		"type": "unit_defend",
		"side": BattleUnitScript.TEAM_PLAYER,
		"source_uid": unit_uid
	})

func begin_enemy_target_selection(action: Dictionary, prompt := "选择敌方目标") -> void:
	if enemy_target_count() <= 1:
		return
	pending_target_action = action.duplicate(true)
	pending_target_action["prompt"] = prompt
	phase = "target_select"
	var current_target = selected_enemy_unit()
	if current_target != null:
		selected_enemy_uid = str(current_target.uid)
	add_log(prompt)

func _handle_player_confirm_target_request(request: Dictionary) -> bool:
	if not _request_side_is_player(request):
		return false
	if phase != "target_select":
		return false
	var uid := str(_request_value(request, "target_uid", ""))
	if uid == "":
		return false
	if not _select_enemy_target(uid):
		return false
	var action: Dictionary = pending_target_action.duplicate(true)
	pending_target_action.clear()
	phase = "player"
	match str(action.get("type", "")):
		"normal_attack":
			return _handle_player_unit_attack_request({
				"type": "unit_attack",
				"side": BattleUnitScript.TEAM_PLAYER,
				"source_uid": str(player.uid),
				"target_uid": uid
			})
		"unit_attack":
			return _handle_player_unit_attack_request({
				"type": "unit_attack",
				"side": BattleUnitScript.TEAM_PLAYER,
				"source_uid": str(action.get("source_uid", "")),
				"target_uid": uid
			})
		"hand_card":
			return _handle_player_play_card_request({
				"type": "play_card",
				"side": BattleUnitScript.TEAM_PLAYER,
				"card_uid": str(action.get("uid", "")),
				"target_uid": uid
			})
		_:
			add_log("Unknown target-selection action.")
			return false

func confirm_target_selection(uid: String) -> Dictionary:
	return submit_request({
		"type": "confirm_target",
		"side": BattleUnitScript.TEAM_PLAYER,
		"target_uid": uid
	})

func player_unit_action_used(unit) -> bool:
	if unit == null:
		return true
	return int(player_unit_actions_used.get(str(unit.uid), 0)) >= _player_unit_action_limit(unit)

func unit_action_used(unit) -> bool:
	if unit == null:
		return true
	if str(unit.team) == BattleUnitScript.TEAM_PLAYER:
		return player_unit_action_used(unit)
	if str(unit.team) == BattleUnitScript.TEAM_ENEMY:
		for queued_unit in enemy_action_queue:
			if queued_unit == unit:
				return false
		return phase == "enemy"
	return true

func suppress_unit_action_this_turn(unit) -> void:
	if unit == null:
		return
	if str(unit.team) == BattleUnitScript.TEAM_PLAYER:
		_mark_player_unit_action_used(unit)
		return
	if str(unit.team) == BattleUnitScript.TEAM_ENEMY:
		for i in range(enemy_action_queue.size() - 1, -1, -1):
			if enemy_action_queue[i] == unit:
				enemy_action_queue.remove_at(i)

func unit_has_positive_status(unit) -> bool:
	if unit == null:
		return false
	return not StatusRulesScript.instances_with_tag(unit.status_instances, StatusDatabaseScript.TAG_POSITIVE).is_empty()

func remove_positive_status_from_unit(unit, amount := 1, source_name := "清除增益") -> int:
	if unit == null:
		return 0
	var removed_instances: Array = unit.remove_first_status_instances_by_tag(StatusDatabaseScript.TAG_POSITIVE, amount)
	for instance_variant in removed_instances:
		var instance: Dictionary = instance_variant
		_emit_status_removed(unit, instance, source_name)
	return removed_instances.size()

func draw_cards_for_unit(unit, amount: int, reason := "card") -> Array:
	if unit != null and str(unit.team) == BattleUnitScript.TEAM_ENEMY:
		return _draw_enemy_cards(amount)
	var drawn: Array = _draw_player_cards(amount, reason)
	_flush_deck_messages()
	return drawn

func add_card_to_unit_graveyard(unit, card_id: String) -> bool:
	var card: Dictionary = CardDatabaseScript.make_card(card_id)
	if card.is_empty():
		return false
	if unit != null and str(unit.team) == BattleUnitScript.TEAM_ENEMY:
		if enemy_side == null or enemy_side.deck_manager == null:
			return false
		enemy_side.deck_manager.add_to_graveyard(card)
		return true
	deck.add_to_graveyard(card)
	return true

func _mark_player_unit_action_used(unit) -> void:
	if unit == null:
		return
	var uid := str(unit.uid)
	player_unit_actions_used[uid] = int(player_unit_actions_used.get(uid, 0)) + 1
	if unit == player:
		player.normal_attack_used = player_unit_action_used(unit)

func _player_unit_action_limit(unit) -> int:
	if unit == player:
		return player.basic_attack_limit()
	return 1

func _reset_player_unit_actions() -> void:
	player_unit_actions_used.clear()
	player.normal_attack_used = false

func _clear_player_temporary_defense() -> void:
	for unit in formation.living_units(BattleUnitScript.TEAM_PLAYER):
		if unit != null:
			unit.temp_defense_delta = 0

func cancel_target_selection() -> void:
	if phase != "target_select":
		return
	pending_target_action.clear()
	phase = "player"
	add_log("取消目标选择。")

func enemy_target_count() -> int:
	return formation.living_units(BattleUnitScript.TEAM_ENEMY).size()

func player_target_count() -> int:
	return formation.living_units(BattleUnitScript.TEAM_PLAYER).size()

func add_enemy_unit(data: Dictionary, preferred_slot := -1) -> bool:
	var unit = EnemyStateScript.new()
	unit.setup(data)
	var added: bool = formation.add_unit(unit, BattleUnitScript.TEAM_ENEMY, preferred_slot)
	if added and selected_enemy_unit() == null:
		selected_enemy_uid = unit.uid
	if added:
		selected_debug_uid = unit.uid
		_refresh_side_unit_refs()
	return added

func add_player_summon(data: Dictionary, preferred_slot := -1) -> bool:
	var unit = BattleUnitScript.new()
	var uid := str(data.get("uid", "summon_%d_%d" % [Time.get_ticks_usec(), rng.randi()]))
	var unit_data: Dictionary = {
		"id": data.get("id", "summon"),
		"uid": uid,
		"name": data.get("name", "召唤物"),
		"team": BattleUnitScript.TEAM_PLAYER,
		"unit_type": data.get("unit_type", BattleUnitScript.TYPE_SUMMON),
		"unit_rank": data.get("unit_rank", BattleUnitScript.RANK_NORMAL),
		"slot_index": int(data.get("slot_index", 2)),
		"max_hp": int(data.get("max_hp", 1)),
		"hp": int(data.get("hp", data.get("max_hp", 1))),
		"attack": int(data.get("attack", 0)),
		"defense": int(data.get("defense", 0)),
		"equipment": data.get("equipment", []),
			"status_instances": data.get("status_instances", []),
		"resource_counters": data.get("resource_counters", {})
	}
	if data.has("equipment_limit"):
		unit_data["equipment_limit"] = int(data.get("equipment_limit", 1))
	unit.setup_unit(unit_data, BattleUnitScript.TEAM_PLAYER, BattleUnitScript.TYPE_SUMMON)
	var added: bool = formation.add_unit(unit, BattleUnitScript.TEAM_PLAYER, preferred_slot)
	if added:
		selected_player_uid = unit.uid
		selected_debug_uid = unit.uid
		_refresh_side_unit_refs()
	return added

func summon_units(unit_team: String, data: Dictionary, count: int) -> int:
	var added_count := 0
	for i in range(max(0, count)):
		var unit_data: Dictionary = data.duplicate(true)
		unit_data["uid"] = "%s_%d_%d" % [str(unit_data.get("id", "summon")), Time.get_ticks_usec(), i]
		if unit_team == BattleUnitScript.TEAM_PLAYER:
			if add_player_summon(unit_data):
				added_count += 1
	return added_count

func _handle_player_select_target_request(request: Dictionary) -> bool:
	if not _request_side_is_player(request):
		return false
	var target_side := str(_request_value(request, "target_side", _request_value(request, "payload", {}).get("target_side", "enemy")))
	var target_uid := str(_request_value(request, "target_uid", ""))
	if target_side == BattleUnitScript.TEAM_ENEMY:
		return _select_enemy_target(target_uid)
	if target_side == BattleUnitScript.TEAM_PLAYER:
		return _select_player_target(target_uid)
	return false


func _select_enemy_target(uid: String) -> bool:
	var unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_ENEMY, uid)
	if unit == null:
		return false
	selected_enemy_uid = str(unit.uid)
	selected_debug_uid = str(unit.uid)
	return true

func _select_player_target(uid: String) -> bool:
	var unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, uid)
	if unit == null:
		return false
	selected_player_uid = str(unit.uid)
	selected_debug_uid = str(unit.uid)
	return true

func select_debug_target(uid: String) -> bool:
	var unit = formation.unit_by_uid(uid)
	if unit == null or int(unit.hp) <= 0:
		return false
	selected_debug_uid = str(unit.uid)
	return true

func selected_enemy_unit():
	var unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_ENEMY, selected_enemy_uid)
	if unit != null:
		return unit
	unit = formation.primary_enemy()
	selected_enemy_uid = "" if unit == null else str(unit.uid)
	return unit

func selected_player_unit():
	var unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, selected_player_uid)
	if unit != null:
		return unit
	unit = formation.primary_player()
	selected_player_uid = "" if unit == null else str(unit.uid)
	return unit

func selected_debug_unit():
	var unit = formation.unit_by_uid(selected_debug_uid)
	if unit != null and int(unit.hp) > 0:
		return unit
	unit = selected_enemy_unit()
	if unit != null:
		selected_debug_uid = str(unit.uid)
		return unit
	unit = selected_player_unit()
	if unit != null:
		selected_debug_uid = str(unit.uid)
	return unit

func clear_extra_enemy_units() -> void:
	formation.enemy_units.clear()
	formation.add_unit(enemy, BattleUnitScript.TEAM_ENEMY, 2)
	selected_enemy_uid = enemy.uid
	selected_debug_uid = enemy.uid
	_refresh_side_unit_refs()

func clear_extra_player_units() -> void:
	formation.player_units.clear()
	formation.add_unit(player, BattleUnitScript.TEAM_PLAYER, 2)
	selected_player_uid = player.uid
	selected_debug_uid = player.uid
	_refresh_side_unit_refs()

func debug_add_enemy() -> bool:
	var index: int = formation.enemy_units.size()
	return add_enemy_unit({
		"id": "debug_enemy_%d" % index,
		"name": "测试妖 %d" % index,
		"max_hp": 18,
		"attack": 5,
		"defense": 1,
		"action_sequence": [
			{"kind": "normal_attack", "intent": "攻击"}
		]
	}, -1)

func debug_add_ally() -> bool:
	var index: int = formation.player_units.size()
	return add_player_summon({
		"id": "debug_ally_%d" % index,
		"name": "测试幻象 %d" % index,
		"max_hp": 6,
		"attack": 0,
		"defense": 0
	}, -1)

func _handle_player_end_turn_request(request: Dictionary) -> bool:
	if not _request_side_is_player(request):
		return false
	if phase != "player":
		return false
	if not pending_choice.is_empty():
		add_log("Resolve the current choice first.")
		return false
	if not pending_equipment_replace.is_empty():
		add_log("Resolve equipment replacement first.")
		return false
	resolver.ready_defenses_after_player_turn(self)
	player.end_turn()
	_tick_turn_end_statuses_for_team(BattleUnitScript.TEAM_PLAYER)
	_process_side_deck_reshuffle(player_side)
	if check_victory_or_defeat():
		return true
	_start_enemy_turn()
	return true

func end_player_turn() -> void:
	_submit_request_accepted({
		"type": "end_turn",
		"side": BattleUnitScript.TEAM_PLAYER
	})

func _start_enemy_turn() -> void:
	phase = "enemy"
	emit_combat_event({"type": "turn_started", "side": "enemy", "label": "敌方回合"})
	enemy_cards_played_this_turn = 0
	_draw_enemy_cards(enemy_side.draw_per_turn)
	_apply_after_draw_poison_for_team(BattleUnitScript.TEAM_ENEMY)
	if check_victory_or_defeat():
		return
	enemy_action_queue.clear()
	var ai_snapshot = _ai_snapshot()
	for unit_view in enemy_controller.action_queue_for_units(ai_snapshot.formation.living_units(BattleUnitScript.TEAM_ENEMY)):
		var runtime_unit = formation.unit_by_uid(str(unit_view.uid))
		if runtime_unit != null:
			enemy_action_queue.append(runtime_unit)
	if _try_enemy_play_next_side_card():
		return
	_continue_enemy_turn()

func _continue_enemy_turn() -> void:
	if phase == "reward" or phase == "defeat":
		return
	while not enemy_action_queue.is_empty():
		var acting_unit = enemy_action_queue.pop_front()
		if acting_unit == null or int(acting_unit.hp) <= 0:
			continue
		_take_enemy_unit_turn(acting_unit)
		return
	_finish_enemy_turn()

func _finish_enemy_turn() -> void:
	_process_side_deck_reshuffle(enemy_side)
	start_player_turn()

func _take_enemy_unit_turn(source_unit) -> void:
	active_enemy_unit = source_unit
	if source_unit.has_method("clear_temporary_defense"):
		source_unit.call("clear_temporary_defense")
	else:
		source_unit.temp_defense_delta = 0
	if source_unit.has_method("tick_skill_cooldowns"):
		source_unit.call("tick_skill_cooldowns")
	_apply_zone_enemy_action_start_effects(source_unit)
	if check_victory_or_defeat():
		return
	var ai_snapshot = _ai_snapshot()
	var source_view = ai_snapshot.formation.unit_by_uid(str(source_unit.uid))
	var action: Dictionary = enemy_controller.next_unit_action(ai_snapshot, source_view)
	if source_unit.has_method("next_action"):
		source_unit.call("next_action")
	var intent := str(action.get("intent", ""))
	add_log("%s 行动：%s。" % [_unit_display_name(source_unit), intent])
	match action.get("kind", ""):
		"normal_attack":
			_enemy_attack(source_unit, source_unit.current_attack())
		"charge":
			add_log("%s 正在蓄力。" % _unit_display_name(source_unit))
			_finish_enemy_action()
		"strong_attack":
			_enemy_attack(source_unit, source_unit.current_attack() + int(action.get("attack_bonus", 0)))
		"defense_stance":
			var defense_bonus: int = int(action.get("defense_delta", 0))
			if defense_bonus <= 0:
				defense_bonus = BattleActionRulesScript.defense_bonus_for_unit(source_unit)
			if not _enemy_defense_action(source_unit, defense_bonus, "defense_stance"):
				_finish_enemy_action()
		"weakness":
			if not _enemy_defense_action(source_unit, int(action.get("defense_delta", 0)), "weakness"):
				_finish_enemy_action()
		"destroy_spell_zone":
			_enemy_destroy_spell_zone(source_unit)
		"spell_attack":
			_enemy_spell_attack(source_unit)
		"skill":
			_enemy_use_skill(source_unit, action)
		_:
			_finish_enemy_action()

func _enemy_attack(source_unit, power: int) -> bool:
	var target = choose_single_target(BattleUnitScript.TEAM_PLAYER)
	if target == null:
		add_log("敌人没有可攻击的目标。")
		_finish_enemy_action()
		return false
	var submitted: bool = _submit_request_accepted({
		"type": "unit_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(source_unit.uid),
		"target_uid": str(target.uid),
		"power": int(power),
		"normal_attack": int(power) == int(source_unit.current_attack())
	})
	if not submitted:
		_finish_enemy_action()
	return submitted

func _enemy_defense_action(source_unit, defense_delta: int, action_kind: String) -> bool:
	if source_unit == null:
		return false
	return _submit_request_accepted({
		"type": "unit_defend",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(source_unit.uid),
		"defense_delta": int(defense_delta),
		"action_kind": action_kind
	})

func _enemy_spell_attack(source_unit) -> bool:
	if source_unit == null:
		_finish_enemy_action()
		return false
	var target = choose_single_target(BattleUnitScript.TEAM_PLAYER)
	if target == null:
		add_log("敌人没有可施法目标。")
		_finish_enemy_action()
		return false
	var submitted: bool = _submit_request_accepted({
		"type": "spell_attack",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(source_unit.uid),
		"target_uid": str(target.uid),
		"power": int(source_unit.current_attack())
	})
	if not submitted:
		_finish_enemy_action()
	return submitted

func _enemy_destroy_spell_zone(source_unit) -> void:
	if player.spell_zone.is_empty():
		add_log("法防区为空，敌人没有破坏目标。")
		_finish_enemy_action()
		return
	var card: Dictionary = player.spell_zone[0]
	add_log("%s 准备破坏法防区的 %s。" % [_unit_display_name(source_unit), card.get("name", "")])
	emit_combat_event({"type": "enemy_intent_started", "intent": "破坏法防区"})
	open_timing_window(create_event("enemy_destroy_zone_card_declared", source_unit, card, 1))

func _enemy_use_skill(source_unit, action: Dictionary) -> void:
	var skill_id := str(action.get("skill_id", ""))
	if source_unit == null:
		_finish_enemy_action()
		return
	if not source_unit.has_method("skill_for_action") or not source_unit.has_method("skill_ready"):
		add_log("%s 没有可用技能，改为普通攻击。" % _unit_display_name(source_unit))
		_enemy_attack(source_unit, source_unit.current_attack())
		return
	var skill: Dictionary = source_unit.call("skill_for_action", action)
	if skill.is_empty() or not bool(source_unit.call("skill_ready", skill_id)):
		add_log("%s 技能未就绪，改为普通攻击。" % _unit_display_name(source_unit))
		_enemy_attack(source_unit, source_unit.current_attack())
		return
	var skill_name := str(skill.get("name", action.get("intent", "技能")))
	add_log("%s 发动技能：%s。" % [_unit_display_name(source_unit), skill_name])
	effect_resolver.apply_steps(self, source_unit, skill.get("effect_steps", []), {"action": action})
	if source_unit.has_method("put_skill_on_cooldown"):
		source_unit.call("put_skill_on_cooldown", skill_id)
	_finish_enemy_action()

func _try_enemy_play_next_side_card() -> bool:
	if enemy_side == null or enemy_side.deck_manager == null:
		return false
	var ai_snapshot = _ai_snapshot()
	var source_view = enemy_controller.side_card_source_unit(ai_snapshot)
	if source_view == null:
		return false
	var source_unit = formation.unit_by_uid(str(source_view.uid))
	if source_unit == null:
		return false
	var card: Dictionary = enemy_controller.select_next_side_card(ai_snapshot, source_view)
	if card.is_empty():
		return false
	var hand_size_before: int = enemy_side.deck_manager.hand.size()
	var played: bool = _play_enemy_card(source_unit, card)
	if played and enemy_side.deck_manager.hand.size() < hand_size_before:
		enemy_cards_played_this_turn += 1
		return true
	return false

func _play_enemy_card(source_unit, card: Dictionary) -> bool:
	return _submit_enemy_card_request(source_unit, card)

func _submit_enemy_card_request(source_unit, card: Dictionary) -> bool:
	if source_unit == null or card.is_empty():
		return false
	var request := {
		"type": "play_card",
		"side": BattleUnitScript.TEAM_ENEMY,
		"source_uid": str(source_unit.uid),
		"card_uid": str(card.get("uid", ""))
	}
	var ai_snapshot = _ai_snapshot()
	var source_view = ai_snapshot.formation.unit_by_uid(str(source_unit.uid))
	var target = enemy_controller.side_card_target(ai_snapshot, source_view, card)
	if target != null:
		request["target_uid"] = str(target.uid)
	return _submit_request_accepted(request)


func _ai_snapshot():
	var snapshot = BattleSnapshotScript.new()
	return snapshot.from_context(context, "ai")

func _play_enemy_equipment_card(source_unit, card: Dictionary) -> bool:
	return _submit_enemy_card_request(source_unit, card)

func _play_enemy_spell_card(source_unit, card: Dictionary) -> bool:
	return _submit_enemy_card_request(source_unit, card)

func create_event(event_type: String, source, target, value := 0) -> Dictionary:
	return _normalize_battle_event({
		EVENT_FIELD_TYPE: event_type,
		EVENT_FIELD_SOURCE: source,
		EVENT_FIELD_TARGET: target,
		EVENT_FIELD_VALUE: int(value)
	})

func battle_event_type(event: Dictionary) -> String:
	return str(_normalize_battle_event(event).get(EVENT_FIELD_TYPE, ""))

func battle_event_source(event: Dictionary):
	return _normalize_battle_event(event).get(EVENT_FIELD_SOURCE, null)

func battle_event_target(event: Dictionary):
	return _normalize_battle_event(event).get(EVENT_FIELD_TARGET, null)

func battle_event_source_key(event: Dictionary) -> String:
	return str(_normalize_battle_event(event).get(EVENT_FIELD_SOURCE_KEY, ""))

func battle_event_target_key(event: Dictionary) -> String:
	return str(_normalize_battle_event(event).get(EVENT_FIELD_TARGET_KEY, ""))

func battle_event_value(event: Dictionary) -> int:
	return int(_normalize_battle_event(event).get(EVENT_FIELD_VALUE, 0))

func set_battle_event_value(event: Dictionary, value: int) -> void:
	_normalize_battle_event(event)[EVENT_FIELD_VALUE] = int(value)

func battle_event_cancelled(event: Dictionary) -> bool:
	return bool(_normalize_battle_event(event).get(EVENT_FIELD_CANCELLED, false))

func set_battle_event_cancelled(event: Dictionary, cancelled: bool) -> void:
	_normalize_battle_event(event)[EVENT_FIELD_CANCELLED] = bool(cancelled)

func battle_event_modifiers(event: Dictionary) -> Array:
	return _normalize_battle_event(event).get(EVENT_FIELD_MODIFIERS, [])

func battle_event_protected_targets(event: Dictionary) -> Array:
	return _normalize_battle_event(event).get(EVENT_FIELD_PROTECTED_TARGETS, [])

func battle_event_normal_attack(event: Dictionary) -> bool:
	return bool(_normalize_battle_event(event).get(EVENT_FIELD_NORMAL_ATTACK, false))

func battle_event_attack_source_key(event: Dictionary) -> String:
	var normalized_event := _normalize_battle_event(event)
	return str(normalized_event.get(EVENT_FIELD_ATTACK_SOURCE_KEY, normalized_event.get(EVENT_FIELD_SOURCE_KEY, "enemy")))

func battle_event_attack_source_unit(event: Dictionary):
	var normalized_event := _normalize_battle_event(event)
	return normalized_event.get(EVENT_FIELD_ATTACK_SOURCE_UNIT, normalized_event.get(EVENT_FIELD_SOURCE, null))

func battle_event_post_steps(event: Dictionary) -> Array:
	var normalized_event := _normalize_battle_event(event)
	return normalized_event.get(EVENT_FIELD_POST_STEPS, [])

func battle_event_post_source_unit(event: Dictionary):
	var normalized_event := _normalize_battle_event(event)
	return normalized_event.get(EVENT_FIELD_POST_SOURCE_UNIT, active_enemy_unit)

func battle_event_enemy_side_card(event: Dictionary) -> bool:
	return bool(_normalize_battle_event(event).get(EVENT_FIELD_ENEMY_SIDE_CARD, false))

func _normalize_battle_event(event: Dictionary) -> Dictionary:
	if not event.has(EVENT_FIELD_TYPE):
		event[EVENT_FIELD_TYPE] = ""
	if not event.has(EVENT_FIELD_SOURCE):
		event[EVENT_FIELD_SOURCE] = null
	if not event.has(EVENT_FIELD_TARGET):
		event[EVENT_FIELD_TARGET] = null
	if not event.has(EVENT_FIELD_SOURCE_KEY):
		event[EVENT_FIELD_SOURCE_KEY] = _event_object_key(event.get(EVENT_FIELD_SOURCE, null))
	if not event.has(EVENT_FIELD_TARGET_KEY):
		event[EVENT_FIELD_TARGET_KEY] = _event_object_key(event.get(EVENT_FIELD_TARGET, null))
	event[EVENT_FIELD_VALUE] = int(event.get(EVENT_FIELD_VALUE, 0))
	event[EVENT_FIELD_CANCELLED] = bool(event.get(EVENT_FIELD_CANCELLED, false))
	var modifiers_value: Variant = event.get(EVENT_FIELD_MODIFIERS, [])
	event[EVENT_FIELD_MODIFIERS] = modifiers_value if modifiers_value is Array else []
	var protected_targets_value: Variant = event.get(EVENT_FIELD_PROTECTED_TARGETS, [])
	event[EVENT_FIELD_PROTECTED_TARGETS] = protected_targets_value if protected_targets_value is Array else []
	if event.has(EVENT_FIELD_POST_STEPS):
		var post_steps_value: Variant = event.get(EVENT_FIELD_POST_STEPS, [])
		event[EVENT_FIELD_POST_STEPS] = post_steps_value if post_steps_value is Array else []
	return event

func _event_object_key(value) -> String:
	if _is_battle_unit(value):
		return _unit_event_key(value)
	return str(value)

func resolve_target_units(target_rule: String, source_unit = null, context := {}) -> Array:
	match target_rule:
		"self":
			return [] if source_unit == null else [source_unit]
		"player":
			if source_unit != null and source_unit.team == BattleUnitScript.TEAM_ENEMY:
				var ai_player_target = choose_single_target(BattleUnitScript.TEAM_PLAYER)
				return [] if ai_player_target == null else [ai_player_target]
			var player_unit = formation.primary_player()
			return [] if player_unit == null else [player_unit]
		"primary_player":
			var player_unit = formation.primary_player()
			return [] if player_unit == null else [player_unit]
		"ally", "single_ally":
			if source_unit == null:
				return []
			var ally_target = choose_single_target(str(source_unit.team))
			return [] if ally_target == null else [ally_target]
		"enemy", "primary_enemy":
			if source_unit != null and source_unit.team == BattleUnitScript.TEAM_ENEMY:
				var enemy_player_target = choose_single_target(BattleUnitScript.TEAM_PLAYER)
				return [] if enemy_player_target == null else [enemy_player_target]
			var enemy_unit = selected_enemy_unit()
			return [] if enemy_unit == null else [enemy_unit]
		"all_players":
			return formation.living_units(BattleUnitScript.TEAM_PLAYER)
		"all_enemies":
			return formation.living_units(BattleUnitScript.TEAM_ENEMY)
		"opponent":
			if source_unit != null and source_unit.team == BattleUnitScript.TEAM_ENEMY:
				var target_player = choose_single_target(BattleUnitScript.TEAM_PLAYER)
				return [] if target_player == null else [target_player]
			var target_enemy = formation.primary_enemy()
			return [] if target_enemy == null else [target_enemy]
		"context_target":
			var context_target = context.get("target_unit", null)
			return [] if context_target == null else [context_target]
	return []

func choose_single_target(unit_team: String):
	var candidates: Array = formation.living_units(unit_team)
	if candidates.is_empty():
		return null
	var taunt_candidates: Array = []
	for unit in candidates:
		if unit != null and unit.get_status("taunt") > 0:
			taunt_candidates.append(unit)
	if not taunt_candidates.is_empty():
		candidates = taunt_candidates
	if candidates.size() == 1:
		return candidates[0]
	return candidates[rng.randi_range(0, candidates.size() - 1)]

func apply_damage_to_unit(unit, amount: int, source_name := "伤害") -> int:
	if unit == null:
		return 0
	var final_amount: int = _apply_next_damage_reduction_to_amount(unit, max(0, amount), source_name)
	var applied: int = unit.apply_damage(final_amount)
	emit_combat_event({"type": "damage_applied", "target": _unit_event_key(unit), "value": applied, "source": source_name})
	return applied

func apply_life_loss_to_unit(unit, amount: int, source_name := "生命损失") -> int:
	if unit == null:
		return 0
	var applied: int = unit.apply_damage(max(0, amount))
	add_log("%s：%s 失去 %d 点生命。" % [source_name, _unit_display_name(unit), applied])
	emit_combat_event({"type": "life_loss_applied", "target": _unit_event_key(unit), "value": applied, "source": source_name})
	return applied

func heal_unit(unit, amount: int, source_name := "治疗") -> int:
	if unit == null:
		return 0
	var healed: int = unit.heal(amount)
	add_log("%s：%s 回复 %d 点生命。" % [source_name, _unit_display_name(unit), healed])
	emit_combat_event({"type": "heal_applied", "target": _unit_event_key(unit), "value": healed, "source": source_name})
	return healed

func modify_unit_stat(unit, stat: String, amount: int, temporary := false, source_name := "效果") -> void:
	if unit == null:
		return
	match stat:
		"attack":
			if temporary:
				unit.temp_attack_delta += amount
			else:
				unit.attack += amount
		"defense":
			if temporary:
				unit.temp_defense_delta += amount
			else:
				unit.defense += amount
		_:
			return
	add_log("%s：%s %s %+d。" % [source_name, _unit_display_name(unit), _stat_display_name(stat), amount])

func add_unit_resource(unit, resource_id: String, amount: int, source_name := "效果") -> int:
	if unit == null:
		return 0
	var next_value: int = 0
	if unit == player and resource_id in ["sword", "sword_momentum"]:
		player.add_sword(amount)
		next_value = player.sword_momentum
		emit_combat_event({"type": "sword_power_changed", "target": "player", "value": amount, "source": source_name})
	else:
		next_value = unit.add_resource(resource_id, amount)
		emit_combat_event({"type": "resource_changed", "target": _unit_event_key(unit), "resource": resource_id, "value": amount, "source": source_name})
	return next_value

func add_unit_status(unit, status_id: String, amount: int, source_name := "效果") -> int:
	if unit == null:
		return 0
	if not StatusDatabaseScript.is_active_status(status_id):
		add_log("%s：%s 不是 active 状态，未创建实例。" % [source_name, status_id])
		return int(unit.get_status(status_id))
	var before_ids: Array = unit.status_instance_ids(status_id)
	var next_value: int = unit.add_status(status_id, amount, source_name)
	var after_ids: Array = unit.status_instance_ids(status_id)
	var created_ids: Array = []
	for instance_id_variant in after_ids:
		var instance_id := str(instance_id_variant)
		if not before_ids.has(instance_id):
			created_ids.append(instance_id)
	add_log("%s：%s 获得 %s %+d。" % [source_name, _unit_display_name(unit), StatusDatabaseScript.display_name(status_id), amount])
	emit_combat_event({
		"type": "status_changed",
		"target": _unit_event_key(unit),
		"status": status_id,
		"display_name": StatusDatabaseScript.display_name(status_id),
		"value": amount,
		"source": source_name,
		"instance_ids": created_ids
	})
	return next_value

func _tick_turn_end_statuses_for_team(unit_team: String) -> void:
	for unit in formation.living_units(unit_team):
		_tick_turn_end_statuses_for_unit(unit)

func _tick_turn_end_statuses_for_unit(unit) -> void:
	if unit == null or int(unit.hp) <= 0:
		return
	var burn: int = int(unit.get_status(STATUS_BURN))
	if burn > 0:
		apply_damage_to_unit(unit, burn, STATUS_BURN)
		add_log("%s：%s 受到 %d 点伤害。" % [STATUS_BURN, _unit_display_name(unit), burn])
		unit.decay_status_instance(str(unit.status_instance_ids(STATUS_BURN).front()), 1)
	for status_id in StatusRulesScript.action_end_decay_status_ids():
		_decay_status_instances(unit, status_id, "行动结束")

func _consume_delay_status_for_power(unit, power: int) -> int:
	if unit == null:
		return max(0, power)
	var delay: int = int(unit.get_status(STATUS_DELAY))
	if delay <= 0:
		return max(0, power)
	var final_power: int = max(0, power - delay)
	var removed: int = unit.remove_status(STATUS_DELAY, delay, STATUS_DELAY)
	add_log("%s：%s 本次行动威力 %d -> %d。" % [STATUS_DELAY, _unit_display_name(unit), power, final_power])
	emit_combat_event({"type": "status_changed", "target": _unit_event_key(unit), "status": STATUS_DELAY, "value": -removed, "source": STATUS_DELAY})
	return final_power

func _apply_after_draw_poison_for_team(unit_team: String) -> void:
	for unit in formation.living_units(unit_team):
		if unit == null or int(unit.hp) <= 0:
			continue
		_apply_after_draw_poison_for_unit(unit)
		if check_victory_or_defeat():
			return

func _apply_after_draw_poison_for_unit(unit) -> void:
	for instance_variant in StatusRulesScript.poison_instances(unit.status_instances):
		if unit == null or int(unit.hp) <= 0:
			return
		var instance: Dictionary = instance_variant
		var instance_id := str(instance.get(BattleUnitScript.STATUS_FIELD_INSTANCE_ID, ""))
		apply_life_loss_to_unit(unit, 1, StatusDatabaseScript.display_name(STATUS_POISON))
		var decayed: Dictionary = unit.decay_status_instance(instance_id, 1)
		emit_combat_event({
			"type": "status_triggered",
			"target": _unit_event_key(unit),
			"status": STATUS_POISON,
			"display_name": StatusDatabaseScript.display_name(STATUS_POISON),
			"instance_id": instance_id,
			"value": 1,
			"counter": int(decayed.get(BattleUnitScript.STATUS_FIELD_COUNTER, 0))
		})
		if int(decayed.get(BattleUnitScript.STATUS_FIELD_COUNTER, 0)) <= 0:
			_emit_status_removed(unit, instance, "状态结算")
		if check_victory_or_defeat():
			return

func _decay_status_instances(unit, status_id: String, source_name := "状态结算") -> void:
	if unit == null:
		return
	for instance_variant in StatusRulesScript.status_instances(unit.status_instances, status_id):
		var instance: Dictionary = instance_variant
		var instance_id := str(instance.get(BattleUnitScript.STATUS_FIELD_INSTANCE_ID, ""))
		var decayed: Dictionary = unit.decay_status_instance(instance_id, 1)
		emit_combat_event({
			"type": "status_changed",
			"target": _unit_event_key(unit),
			"status": status_id,
			"display_name": StatusDatabaseScript.display_name(status_id),
			"value": -1,
			"source": source_name,
			"instance_id": instance_id,
			"counter": int(decayed.get(BattleUnitScript.STATUS_FIELD_COUNTER, 0))
		})
		if int(decayed.get(BattleUnitScript.STATUS_FIELD_COUNTER, 0)) <= 0:
			_emit_status_removed(unit, instance, source_name)

func _apply_next_damage_reduction_to_amount(target_unit, amount: int, source_name := "伤害") -> int:
	if target_unit == null or amount <= 0:
		return max(0, amount)
	var result: Dictionary = StatusRulesScript.next_damage_reduce_result(target_unit.status_instances, amount)
	var instance_ids: Array = result.get("instance_ids", [])
	if instance_ids.is_empty():
		return max(0, amount)
	var removed_instances: Array = target_unit.clear_status_instances_by_ids(instance_ids)
	for instance_variant in removed_instances:
		var instance: Dictionary = instance_variant
		_emit_status_removed(target_unit, instance, STATUS_NEXT_DAMAGE_REDUCTION)
	var after: int = int(result.get("damage", amount))
	add_log("%s：%s 本次伤害 %d -> %d。" % [StatusDatabaseScript.display_name(STATUS_NEXT_DAMAGE_REDUCTION), _unit_display_name(target_unit), amount, after])
	emit_combat_event({
		"type": "damage_reduced",
		"target": _unit_event_key(target_unit),
		"value": int(result.get("reduction", 0)),
		"raw_value": int(result.get("raw_reduction", 0)),
		"source": STATUS_NEXT_DAMAGE_REDUCTION,
		"instance_ids": instance_ids,
		"damage_source": source_name
	})
	return after

func _emit_status_removed(unit, instance: Dictionary, source_name := "状态移除") -> void:
	if unit == null or instance.is_empty():
		return
	emit_combat_event({
		"type": "status_removed",
		"target": _unit_event_key(unit),
		"status": str(instance.get(BattleUnitScript.STATUS_FIELD_ID, "")),
		"display_name": str(instance.get(BattleUnitScript.STATUS_FIELD_NAME, "")),
		"instance_id": str(instance.get(BattleUnitScript.STATUS_FIELD_INSTANCE_ID, "")),
		"source": source_name
	})

func _apply_next_damage_reduction_status(event: Dictionary, target_unit) -> void:
	if target_unit == null:
		return
	var before: int = battle_event_value(event)
	var after: int = _apply_next_damage_reduction_to_amount(target_unit, before, STATUS_NEXT_DAMAGE_REDUCTION)
	if after == before:
		return
	set_battle_event_value(event, after)

func _apply_zone_damage_reduction(event: Dictionary, target_unit) -> void:
	if target_unit == null:
		return
	for card_variant in player.spell_zone.duplicate():
		var card: Dictionary = card_variant
		var effect: Dictionary = card.get("effect", {})
		if str(effect.get("kind", "")) != "zone_damage_reduction":
			continue
		if int(card.get("last_zone_trigger_turn", -1)) == turn_number:
			continue
		var before: int = battle_event_value(event)
		var reduction: int = int(effect.get("value", 0))
		var after: int = max(0, before - reduction)
		set_battle_event_value(event, after)
		card["last_zone_trigger_turn"] = turn_number
		add_log("%s：%s 本次伤害 %d -> %d。" % [card.get("name", "放置牌"), _unit_display_name(target_unit), before, after])
		emit_combat_event({"type": "damage_reduced", "target": _unit_event_key(target_unit), "value": before - after, "source": card.get("name", "")})
		if card.has("zone_uses_remaining"):
			card["zone_uses_remaining"] = max(0, int(card.get("zone_uses_remaining", 0)) - 1)
			if int(card.get("zone_uses_remaining", 0)) <= 0:
				resolver.move_spell_zone_card_to_destination(self, card)

func _apply_zone_enemy_action_start_effects(source_unit) -> void:
	if source_unit == null:
		return
	for card_variant in player.spell_zone.duplicate():
		var card: Dictionary = card_variant
		var effect: Dictionary = card.get("effect", {})
		if str(effect.get("kind", "")) != "zone_next_enemy_action_status":
			continue
		var status_id := str(effect.get("status", ""))
		var amount: int = int(effect.get("value", 0))
		if status_id != "" and amount != 0:
			add_unit_status(source_unit, status_id, amount, str(card.get("name", "放置牌")))
		resolver.move_spell_zone_card_to_destination(self, card)
		break

func _apply_lethal_equipment_save(event: Dictionary, target_unit) -> void:
	if target_unit == null:
		return
	var damage: int = battle_event_value(event)
	if damage < int(target_unit.hp):
		return
	for i in range(target_unit.equipment_count()):
		var card: Dictionary = target_unit.equipment_slot(i)
		if not _equipment_has_lethal_save(card, target_unit):
			continue
		target_unit.remove_equipment_effects(card)
		target_unit.remove_equipment_at(i)
		deck.add_to_graveyard(card)
		set_battle_event_value(event, max(0, int(target_unit.hp) - 1))
		add_log("%s：破坏装备，%s 本次致命伤害改为保留 1 点生命。" % [card.get("name", "装备"), _unit_display_name(target_unit)])
		emit_combat_event({"type": "card_moved_to_graveyard", "card": card})
		return

func _equipment_has_lethal_save(card: Dictionary, target_unit = null) -> bool:
	if target_unit != null and target_unit.has_method("equipment_has_effect_kind"):
		return target_unit.equipment_has_effect_kind(card, "equipment_lethal_save")
	return _effect_has_kind(card.get("effect", {}), "equipment_lethal_save")

func _effect_has_kind(effect: Dictionary, expected_kind: String) -> bool:
	if str(effect.get("kind", "")) == expected_kind:
		return true
	if str(effect.get("kind", "")) == "multi":
		for sub_effect_variant in effect.get("effects", []):
			var sub_effect: Dictionary = sub_effect_variant
			if _effect_has_kind(sub_effect, expected_kind):
				return true
	return false

func _remove_equipment_effect_recursive(unit, effect: Dictionary) -> void:
	if unit == null:
		return
	unit.remove_equipment_effects({"effect": effect})

func _is_battle_unit(value) -> bool:
	return value is Object and value.has_method("current_defense") and value.has_method("apply_damage")

func _event_target_unit(event: Dictionary):
	var target = battle_event_target(event)
	if _is_battle_unit(target):
		return target
	var target_key := battle_event_target_key(event)
	if target_key == "player":
		return player
	if target_key == "enemy":
		return enemy
	return formation.unit_by_uid(target_key)

func _unit_event_key(unit) -> String:
	if unit == player:
		return "player"
	if unit == enemy:
		return "enemy"
	return str(unit.uid)

func _unit_display_name(unit) -> String:
	if unit == player:
		return "玩家"
	if unit == enemy:
		return "敌人"
	return str(unit.name)

func _clear_response_window_context(reset_skip := true) -> void:
	current_event.clear()
	chain_stack.clear()
	response_loop_guard = 0
	response_chain_state = RESPONSE_CHAIN_STATE_RESOLVED
	_reset_response_window_sides()
	if reset_skip:
		_reset_response_pass_state()
	else:
		_sync_response_skipped_from_pass_state()

func response_chain_can_append() -> bool:
	return ResponseWindowRulesScript.can_append(phase, response_chain_state, current_event, response_active_side(), response_pass_state, RESPONSE_CHAIN_STATE_OPEN)

func response_chain_is_locked() -> bool:
	return response_chain_state == RESPONSE_CHAIN_STATE_LOCKED or response_chain_state == RESPONSE_CHAIN_STATE_RESOLVING or response_chain_state == RESPONSE_CHAIN_STATE_RESOLVED

func response_chain_is_resolved() -> bool:
	return response_chain_state == RESPONSE_CHAIN_STATE_RESOLVED

func response_chain_was_skipped() -> bool:
	return response_skipped

func response_window_owner() -> String:
	return ResponseWindowRulesScript.owner_side(response_window_owner_side)

func response_active_side() -> String:
	return ResponseWindowRulesScript.active_side(active_response_side)

func response_pass_state_snapshot() -> Dictionary:
	return ResponseWindowRulesScript.pass_state_snapshot(response_pass_state)

func response_side_passed(side: String) -> bool:
	return ResponseWindowRulesScript.side_passed(response_pass_state, side)

func response_window_is_player_only() -> bool:
	return ResponseWindowRulesScript.is_player_only(response_window_owner_side, active_response_side, response_pass_state)

func response_chain_link_count() -> int:
	return chain_stack.size()

func chain_link_card(link: Dictionary) -> Dictionary:
	return ResponseWindowRulesScript.chain_link_card(link)

func chain_link_card_uid(link: Dictionary) -> String:
	return ResponseWindowRulesScript.chain_link_card_uid(link)

func chain_link_card_id(link: Dictionary) -> String:
	return ResponseWindowRulesScript.chain_link_card_id(link)

func chain_link_event_type(link: Dictionary) -> String:
	return ResponseWindowRulesScript.chain_link_event_type(link)

func chain_link_locked(link: Dictionary) -> bool:
	return ResponseWindowRulesScript.chain_link_locked(link)

func chain_link_resolved(link: Dictionary) -> bool:
	return ResponseWindowRulesScript.chain_link_resolved(link)

func _make_chain_link(card: Dictionary, event: Dictionary) -> Dictionary:
	return ResponseWindowRulesScript.make_chain_link(card, battle_event_type(event), chain_stack.size())

func _reset_response_window_sides() -> void:
	response_window_owner_side = ResponseWindowRulesScript.default_owner_side()
	active_response_side = ResponseWindowRulesScript.default_active_side()

func _reset_response_pass_state() -> void:
	response_pass_state = ResponseWindowRulesScript.default_pass_state()
	response_skipped = ResponseWindowRulesScript.skipped_from_pass_state(response_pass_state)

func _set_response_side_passed(side: String, passed: bool) -> bool:
	var accepted := ResponseWindowRulesScript.set_side_passed(response_pass_state, side, passed)
	if accepted:
		response_skipped = ResponseWindowRulesScript.skipped_from_pass_state(response_pass_state)
	return accepted

func _sync_response_skipped_from_pass_state() -> void:
	response_skipped = ResponseWindowRulesScript.skipped_from_pass_state(response_pass_state)

func _lock_response_chain(skipped := false) -> void:
	if response_chain_state == RESPONSE_CHAIN_STATE_RESOLVED or response_chain_state == RESPONSE_CHAIN_STATE_RESOLVING:
		return
	if skipped:
		_set_response_side_passed(BattleUnitScript.TEAM_PLAYER, true)
	else:
		_sync_response_skipped_from_pass_state()
	response_chain_state = RESPONSE_CHAIN_STATE_LOCKED
	ResponseWindowRulesScript.lock_chain_links(chain_stack)

func _mark_chain_link_resolved(link: Dictionary) -> void:
	ResponseWindowRulesScript.mark_chain_link_resolved(link)

func _stat_display_name(stat: String) -> String:
	match stat:
		"attack":
			return "攻击"
		"defense":
			return "防御"
	return stat

func open_timing_window(event: Dictionary) -> void:
	var battle_event := _normalize_battle_event(event)
	current_event = battle_event
	chain_stack.clear()
	response_loop_guard = 0
	response_chain_state = RESPONSE_CHAIN_STATE_OPEN
	_reset_response_window_sides()
	_reset_response_pass_state()
	add_log("进入时点：%s。" % get_event_description(battle_event))
	var responses := get_available_responses(battle_event)
	if responses.is_empty():
		add_log("没有可响应防御牌。")
		resolve_chain(battle_event)
		return
	add_log("发现可响应防御牌：%s。" % _response_names(responses))
	phase = "response"

func get_available_responses(event: Dictionary) -> Array:
	return resolver.get_available_responses(self, event)

func get_available_responses_for_current_event() -> Array:
	if current_event.is_empty():
		return []
	return get_available_responses(current_event)

func _handle_player_response_request(request: Dictionary) -> bool:
	if not _request_side_is_player(request):
		return false
	return _add_card_to_chain(str(_request_value(request, "card_uid", "")))


func _add_card_to_chain(uid: String) -> bool:
	if not response_chain_can_append():
		return false
	response_loop_guard += 1
	if response_loop_guard > MAX_CHAIN_ACTIONS:
		add_log("响应循环超过安全上限，强制结算当前连锁。")
		resolve_chain(current_event)
		return false
	var available := get_available_responses(current_event)
	var can_use := false
	for card in available:
		if str(card.get("uid", "")) == uid:
			can_use = true
			break
	if not can_use:
		add_log("该防御牌当前不能响应。")
		return false
	var chain_card: Dictionary = resolver.mark_card_in_chain(self, uid)
	if chain_card.is_empty():
		return false
	chain_stack.append(_make_chain_link(chain_card, current_event))
	add_log("玩家发动：%s。" % chain_card.get("name", ""))
	emit_combat_event({"type": "defense_card_activated", "card": chain_card})
	if get_available_responses(current_event).is_empty():
		resolve_chain(current_event)
	return true


func _handle_skip_response_request(request: Dictionary) -> bool:
	return _skip_response_for_side(_request_side(request))


func _skip_response_for_side(side: String) -> bool:
	if side != BattleUnitScript.TEAM_PLAYER:
		return false
	if not response_chain_can_append():
		return false
	_set_response_side_passed(BattleUnitScript.TEAM_PLAYER, true)
	add_log("玩家跳过响应。")
	resolve_chain(current_event)
	return true

func resolve_chain(event: Dictionary) -> void:
	if response_chain_state == RESPONSE_CHAIN_STATE_RESOLVED or response_chain_state == RESPONSE_CHAIN_STATE_RESOLVING:
		return
	var battle_event := _normalize_battle_event(event)
	if response_chain_state == RESPONSE_CHAIN_STATE_OPEN:
		_lock_response_chain(response_skipped)
	response_chain_state = RESPONSE_CHAIN_STATE_RESOLVING
	if not chain_stack.is_empty():
		add_log("连锁开始结算。")
		emit_combat_event({"type": "chain_started"})
	var order := 1
	while not chain_stack.is_empty():
		var link: Dictionary = chain_stack.pop_back()
		if chain_link_resolved(link):
			continue
		var card: Dictionary = chain_link_card(link)
		add_log("连锁结算 %d：%s。" % [order, card.get("name", "")])
		emit_combat_event({"type": "chain_card_resolved", "card": card, "order": order})
		resolver.resolve_chain_card(self, card, battle_event)
		_mark_chain_link_resolved(link)
		order += 1
	if order > 1:
		add_log("连锁结束。")
		emit_combat_event({"type": "chain_finished"})
	response_chain_state = RESPONSE_CHAIN_STATE_RESOLVED
	resolve_original_event(battle_event)

func resolve_original_event(event: Dictionary) -> void:
	var battle_event := _normalize_battle_event(event)
	if battle_event_cancelled(battle_event):
		add_log("原始事件被打断，不再结算。")
		_finish_enemy_resolution(battle_event)
		return
	match battle_event_type(battle_event):
		"enemy_attack_declared":
			add_log("敌人攻击继续结算。")
			var attack_target = _event_target_unit(battle_event)
			if attack_target == null:
				_finish_enemy_action()
				return
			var attack_source_key := battle_event_source_key(battle_event)
			emit_combat_event({"type": "attack_started", "source": attack_source_key, "target": _unit_event_key(attack_target)})
			var damage: int = max(0, battle_event_value(battle_event) - attack_target.current_defense())
			if battle_event_normal_attack(battle_event):
				damage = _normal_attack_event_damage(battle_event, attack_target)
			if str(attack_target.team) == BattleUnitScript.TEAM_PLAYER:
				var attack_damage_event := create_event("player_damage_before", "enemy_attack", attack_target, damage)
				attack_damage_event["attack_source_key"] = attack_source_key
				attack_damage_event["attack_source_unit"] = battle_event_source(battle_event)
				attack_damage_event["normal_attack"] = battle_event_normal_attack(battle_event)
				open_timing_window(attack_damage_event)
			else:
				_apply_final_damage_to_unit(attack_target, damage, "enemy_attack", attack_source_key)
		"enemy_spell_declared":
			add_log("敌人施法继续结算。")
			var spell_target = _event_target_unit(battle_event)
			if spell_target == null:
				_finish_enemy_resolution(battle_event)
				return
			var spell_source_key := battle_event_source_key(battle_event)
			var damage: int = max(0, battle_event_value(battle_event) - spell_target.current_defense())
			if damage <= 0:
				_apply_enemy_spell_post_steps(battle_event)
				_finish_enemy_resolution(battle_event)
			elif str(spell_target.team) == BattleUnitScript.TEAM_PLAYER:
				var spell_damage_event := create_event("player_damage_before", "enemy_spell", spell_target, damage)
				spell_damage_event["attack_source_key"] = spell_source_key
				_copy_enemy_spell_post_context(battle_event, spell_damage_event)
				open_timing_window(spell_damage_event)
			else:
				_apply_final_damage_to_unit(spell_target, damage, "enemy_spell", spell_source_key, battle_event)
		"enemy_destroy_zone_card_declared":
			_resolve_destroy_zone_event(battle_event)
			_finish_enemy_action()
		"player_damage_before":
			var damage := battle_event_value(battle_event)
			var damage_target = _event_target_unit(battle_event)
			if damage_target == null:
				damage_target = player
			_apply_zone_damage_reduction(battle_event, damage_target)
			_apply_next_damage_reduction_status(battle_event, damage_target)
			damage = battle_event_value(battle_event)
			if damage_target == player and damage >= player.hp and damage > 0:
				var lethal_event := create_event("player_lethal_damage_before", battle_event_source(battle_event), damage_target, damage)
				lethal_event["attack_source_key"] = battle_event_attack_source_key(battle_event)
				_copy_enemy_spell_post_context(battle_event, lethal_event)
				open_timing_window(lethal_event)
			else:
				_apply_final_damage_to_unit(damage_target, damage, str(battle_event_source(battle_event)), battle_event_attack_source_key(battle_event), battle_event)
		"player_lethal_damage_before":
			var lethal_target = _event_target_unit(battle_event)
			var final_target = player if lethal_target == null else lethal_target
			_apply_lethal_equipment_save(battle_event, final_target)
			_apply_final_damage_to_unit(final_target, battle_event_value(battle_event), str(battle_event_source(battle_event)), battle_event_attack_source_key(battle_event), battle_event)

func _resolve_destroy_zone_event(event: Dictionary) -> void:
	var target: Dictionary = battle_event_target(event)
	var target_key := _target_key(target)
	if target_key in battle_event_protected_targets(event):
		add_log("%s 被保护，本次破坏无效。" % target.get("name", "目标"))
		return
	_destroy_spell_zone_card(target)

func _destroy_spell_zone_card(card: Dictionary) -> void:
	for i in range(player.spell_zone.size()):
		if str(player.spell_zone[i].get("uid", "")) == str(card.get("uid", "")):
			player.spell_zone.remove_at(i)
			break
	_release_attached_cards_to_graveyard(card)
	deck.add_to_graveyard(card)
	add_log("%s 被破坏并进入墓地。" % card.get("name", "卡牌"))
	emit_combat_event({"type": "card_destroyed", "card": card})

func _release_attached_cards_to_graveyard(card: Dictionary) -> void:
	var attached_cards: Array = card.get("attached_cards", [])
	if attached_cards.is_empty():
		return
	for attached_card_variant in attached_cards:
		var attached_card: Dictionary = attached_card_variant
		deck.add_to_graveyard(attached_card)
		add_log("%s 下方的 %s 进入墓地。" % [card.get("name", "放置牌"), attached_card.get("name", "卡牌")])
	card["attached_cards"] = []

func _apply_final_damage_to_unit(target_unit, damage: int, source_name: String, attack_source_key := "enemy", post_context := {}) -> void:
	if target_unit == null:
		_finish_enemy_resolution(post_context)
		return
	var applied_damage: int = apply_damage_to_unit(target_unit, max(0, damage), source_name)
	add_log("%s 对 %s 造成 %d 点伤害。" % [source_name, _unit_display_name(target_unit), applied_damage])
	if source_name == "enemy_attack" and post_context is Dictionary:
		var post_event: Dictionary = post_context
		var attack_source_unit = battle_event_attack_source_unit(post_event)
		if _is_battle_unit(attack_source_unit):
			if battle_event_normal_attack(post_event) and applied_damage > 0:
				_apply_basic_attack_on_hit_effects(attack_source_unit, target_unit)
			if battle_event_normal_attack(post_event):
				BattleActionRulesScript.clear_consumed_attack_modifiers(player, attack_source_unit)
	_apply_enemy_spell_post_steps(post_context)
	if source_name == "enemy_attack":
		emit_combat_event({"type": "attack_finished", "source": attack_source_key, "target": _unit_event_key(target_unit)})
	_finish_enemy_resolution(post_context)

func _normal_attack_event_damage(event: Dictionary, target_unit) -> int:
	if target_unit == null:
		return 0
	var raw_power: int = battle_event_value(event)
	var damage: int = max(0, raw_power - target_unit.current_defense())
	var source_unit = battle_event_source(event)
	if not _is_battle_unit(source_unit):
		return damage
	var multiplier := 1.0
	for attach_variant in source_unit.attack_attach_statuses:
		var attach: Dictionary = attach_variant
		multiplier = min(multiplier, max(0.0, float(attach.get("damage_multiplier", 1.0))))
	if multiplier < 1.0:
		damage = max(1, int(floor(float(damage) * multiplier))) if damage > 0 else 0
	return damage

func _copy_enemy_spell_post_context(source_event: Dictionary, target_event: Dictionary) -> void:
	var post_steps: Array = battle_event_post_steps(source_event)
	if not post_steps.is_empty():
		target_event["post_steps"] = post_steps.duplicate(true)
	if source_event.has(EVENT_FIELD_POST_SOURCE_UNIT):
		target_event["post_source_unit"] = battle_event_post_source_unit(source_event)
	if battle_event_enemy_side_card(source_event):
		target_event["enemy_side_card"] = true
	_normalize_battle_event(target_event)

func _apply_enemy_spell_post_steps(event_context) -> void:
	if not (event_context is Dictionary):
		return
	var context_dict: Dictionary = event_context
	var post_steps: Array = battle_event_post_steps(context_dict)
	if post_steps.is_empty():
		return
	var source_unit = battle_event_post_source_unit(context_dict)
	var target_unit = _event_target_unit(context_dict)
	effect_resolver.apply_steps(self, source_unit, post_steps, {"target_unit": target_unit})

func _finish_enemy_resolution(context = {}) -> void:
	if context is Dictionary:
		var event_context: Dictionary = context
		if battle_event_enemy_side_card(event_context):
			_finish_enemy_side_card()
			return
	_finish_enemy_action()

func _finish_enemy_side_card() -> void:
	_clear_response_window_context(false)
	if check_victory_or_defeat():
		return
	if phase != "reward" and phase != "defeat":
		phase = "enemy"
		if _try_enemy_play_next_side_card():
			return
		_continue_enemy_turn()

func _finish_enemy_action() -> void:
	_clear_response_window_context(false)
	if active_enemy_unit != null:
		_tick_turn_end_statuses_for_unit(active_enemy_unit)
		active_enemy_unit = null
	if check_victory_or_defeat():
		return
	if phase != "reward" and phase != "defeat":
		phase = "enemy"
		_continue_enemy_turn()

func get_event_description(event: Dictionary) -> String:
	match battle_event_type(event):
		"enemy_attack_declared":
			return "敌人攻击前"
		"enemy_spell_declared":
			return "敌人施法前"
		"enemy_destroy_zone_card_declared":
			return "敌人破坏法防区前"
		"player_damage_before":
			return "我方单位受到伤害前"
		"player_lethal_damage_before":
			return "玩家受到致命伤害前"
	return battle_event_type(event) if battle_event_type(event) != "" else "未知时点"

func _response_names(responses: Array) -> String:
	var names: Array = []
	for card in responses:
		names.append(card.get("name", "卡牌"))
	return "、".join(names)

func _target_key(target) -> String:
	if target is Dictionary:
		return str(target.get("uid", target.get("id", target.get("name", ""))))
	return str(target)

func choose_reward(card_id: String) -> void:
	if phase != "reward":
		return
	if not reward_options.has(card_id):
		return
	var result: Dictionary = CardAcquisitionRulesScript.card_gain_result(card_id, master_deck_ids, deck_score_limit)
	match str(result.get("destination", "none")):
		"deck":
			master_deck_ids.append(card_id)
			add_log("选择奖励：%s 加入卡组。" % card_id)
		"reserve":
			master_reserve_ids.append(card_id)
			add_log("选择奖励：%s 加入备牌区（%s）。" % [card_id, str(result.get("reason", ""))])
		_:
			add_log(str(result.get("message", "未获得卡牌。")))
			return
	if not auto_advance_after_reward:
		phase = "map_complete"
		return
	battle_number += 1
	if battle_number > 5:
		battle_number = 1
		add_log("第 5 场胜利后回到第 1 场循环。")
	start_battle()

func _enemy_data_for_current_battle() -> Dictionary:
	if current_encounter_profile.is_empty():
		current_encounter_profile = _select_encounter_profile()
	return BattleEncounterRuntimeScript.primary_enemy_data(current_encounter_profile, battle_number)

func check_victory_or_defeat() -> bool:
	_cleanup_defeated_units()
	if player.hp <= 0 or formation.all_players_defeated():
		player.hp = 0
		phase = "defeat"
		add_log("玩家生命降为 0，战斗失败。")
		return true
	if formation.all_enemies_defeated() and phase != "reward":
		enemy.hp = 0
		player.sword_momentum = 0
		player.set_resource("sword_momentum", 0)
		phase = "reward"
		reward_options = _generate_rewards()
		add_log("战斗胜利。请选择 1 张奖励卡。")
		return true
	return false

func _generate_rewards() -> Array:
	var unlock_tier: int = int(meta_bonuses.get("card_unlock_tier", 0))
	return RewardServiceScript.battle_card_rewards(job_id, current_encounter_type, unlock_tier, rng, 3)

func _draw_player_cards(amount: int, reason := "") -> Array:
	var drawn: Array = deck.draw(max(0, amount))
	if not drawn.is_empty():
		emit_combat_event({"type": "cards_drawn", "cards": drawn.duplicate(true), "reason": reason})
	return drawn

func _draw_enemy_cards(amount: int) -> Array:
	if enemy_side == null or amount <= 0:
		return []
	var drawn: Array = enemy_side.draw_cards(amount)
	enemy_side.take_deck_messages()
	if not drawn.is_empty():
		add_log("敌方抽取 %d 张牌。" % drawn.size())
		emit_combat_event({"type": "enemy_cards_drawn", "count": drawn.size()})
	return drawn

func _process_side_deck_reshuffle(side) -> bool:
	if side == null or side.deck_manager == null:
		return false
	var reshuffled: bool = side.deck_manager.process_pending_reshuffle()
	if side == player_side:
		_flush_deck_messages()
	else:
		side.take_deck_messages()
	return reshuffled

func _flush_deck_messages() -> void:
	for message in deck.take_messages():
		add_log(message)

func add_log(message: String) -> void:
	messages.append(message)
	while messages.size() > 12:
		messages.pop_front()

func emit_combat_event(payload: Dictionary) -> void:
	if context != null and context.collecting_result_events:
		context.request_events.append(payload.duplicate(true))
	combat_event.emit(payload)
