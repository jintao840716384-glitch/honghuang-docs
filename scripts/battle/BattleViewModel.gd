extends RefCounted
class_name BattleViewModel

signal combat_event(payload: Dictionary)

const BattleSnapshotScript = preload("res://scripts/battle/BattleSnapshot.gd")

var _manager
var _snapshot
var battle_number:
	get: return _snapshot.battle_number
var phase:
	get: return _snapshot.phase
var player:
	get: return _snapshot.player
var enemy:
	get: return _snapshot.enemy
var formation:
	get: return _snapshot.formation
var player_side:
	get: return _snapshot.player_side
var enemy_side:
	get: return _snapshot.enemy_side
var deck:
	get: return _snapshot.deck
var master_deck_ids:
	get: return _snapshot.master_deck_ids.duplicate(true)
var master_reserve_ids:
	get: return _snapshot.master_reserve_ids.duplicate(true)
var reward_options:
	get: return _snapshot.reward_options.duplicate(true)
var pending_choice:
	get: return _snapshot.pending_choice.duplicate(true)
var pending_equipment_replace:
	get: return _snapshot.pending_equipment_replace.duplicate(true)
var pending_target_action:
	get: return _snapshot.pending_target_action.duplicate(true)
var messages:
	get: return _snapshot.messages.duplicate(true)
var selected_enemy_uid:
	get: return _snapshot.selected_enemy_uid
var selected_player_uid:
	get: return _snapshot.selected_player_uid
var selected_debug_uid:
	get: return _snapshot.selected_debug_uid
var auto_advance_after_reward:
	get: return _snapshot.auto_advance_after_reward
var last_result:
	get: return _snapshot.last_result.duplicate(true)


func _init(manager) -> void:
	_manager = manager
	_manager.combat_event.connect(_on_combat_event)
	refresh()


func _get(property: StringName):
	if _snapshot == null:
		return null
	return _snapshot.get(property)


func refresh() -> void:
	var next_snapshot = BattleSnapshotScript.new()
	_snapshot = next_snapshot.from_context(_manager.context)
	_snapshot.pending_options = _manager.get_pending_options().duplicate(true) if _manager.resolver != null else []


func snapshot():
	refresh()
	return _snapshot


func submit(request: Dictionary) -> Dictionary:
	var result: Dictionary = _manager.submit_request(request)
	refresh()
	return result


func start_run(job_id: String) -> void:
	_manager.start_run(job_id)
	refresh()


func start_run_with_deck(job_id: String, deck_ids: Array, battle_number := 1, encounter_type := "normal", auto_advance := false, run_context := {}) -> void:
	_manager.start_run_with_deck(job_id, deck_ids, battle_number, encounter_type, auto_advance, run_context)
	refresh()


func get_pending_options() -> Array:
	return _snapshot.pending_options.duplicate(true)


func available_responses() -> Array:
	return _manager.get_available_responses_for_current_event().duplicate(true)


func player_unit_action_used(unit) -> bool:
	return unit != null and bool(_snapshot.player_unit_actions_used.get(str(unit.uid), false))


func enemy_target_count() -> int:
	return _snapshot.formation.living_units("enemy").size()


func player_target_count() -> int:
	return _snapshot.formation.living_units("player").size()


func selected_enemy_unit():
	return _snapshot.formation.unit_by_uid(_snapshot.selected_enemy_uid)


func selected_player_unit():
	return _snapshot.formation.unit_by_uid(_snapshot.selected_player_uid)


func selected_debug_unit():
	return _snapshot.formation.unit_by_uid(_snapshot.selected_debug_uid)


func select_enemy_target(uid: String) -> Dictionary:
	return submit({"request_type": "select_target", "side": "player", "target_uid": uid, "target_side": "enemy"})


func select_player_target(uid: String) -> Dictionary:
	return submit({"request_type": "select_target", "side": "player", "target_uid": uid, "target_side": "player"})


func select_debug_target(uid: String) -> bool:
	var accepted: bool = _manager.select_debug_target(uid)
	refresh()
	return accepted


func confirm_target_selection(uid: String) -> Dictionary:
	return submit({"request_type": "confirm_target", "side": "player", "target_uid": uid})


func play_hand_card(uid: String) -> Dictionary:
	return submit({"request_type": "play_card", "side": "player", "card_uid": uid})


func play_hand_card_on_enemy_target(uid: String, target_uid: String) -> Dictionary:
	return submit({"request_type": "play_card", "side": "player", "card_uid": uid, "target_uid": target_uid})


func play_hand_card_on_unit_target(uid: String, target_uid: String) -> Dictionary:
	return submit({"request_type": "play_card", "side": "player", "card_uid": uid, "target_uid": target_uid})


func player_unit_attack(unit_uid: String) -> Dictionary:
	return submit({"request_type": "unit_attack", "side": "player", "source_uid": unit_uid})


func player_normal_attack() -> Dictionary:
	return player_unit_attack(str(_snapshot.player.uid))


func player_unit_defend(unit_uid: String) -> Dictionary:
	return submit({"request_type": "unit_defend", "side": "player", "source_uid": unit_uid})


func end_player_turn() -> Dictionary:
	return submit({"request_type": "end_turn", "side": "player"})


func play_response_card(uid: String) -> Dictionary:
	return submit({"request_type": "play_response", "side": "player", "card_uid": uid})


func skip_response() -> Dictionary:
	return submit({"request_type": "skip_response", "side": "player"})


func choose_pending(uid: String) -> void:
	_manager.choose_pending(uid)
	refresh()


func choose_reward(card_id: String) -> void:
	_manager.choose_reward(card_id)
	refresh()


func choose_equipment_replacement(uid: String) -> Dictionary:
	return submit({"request_type": "choose_equipment_replacement", "side": "player", "equipment_uid": uid})


func cancel_equipment_replacement() -> Dictionary:
	return submit({"request_type": "cancel_equipment_replacement", "side": "player"})


func restart_run() -> void:
	_manager.restart_run()
	refresh()


func debug_add_enemy() -> bool:
	var accepted: bool = _manager.debug_add_enemy()
	refresh()
	return accepted


func debug_add_ally() -> bool:
	var accepted: bool = _manager.debug_add_ally()
	refresh()
	return accepted


func clear_extra_enemy_units() -> void:
	_manager.clear_extra_enemy_units()
	refresh()


func clear_extra_player_units() -> void:
	_manager.clear_extra_player_units()
	refresh()


func apply_damage_to_unit(unit, amount: int, source_name := "") -> int:
	var target = _manager.formation.unit_by_uid(str(unit.uid)) if unit != null else null
	var value: int = _manager.apply_damage_to_unit(target, amount, source_name)
	refresh()
	return value


func heal_unit(unit, amount: int, source_name := "") -> int:
	var target = _manager.formation.unit_by_uid(str(unit.uid)) if unit != null else null
	var value: int = _manager.heal_unit(target, amount, source_name)
	refresh()
	return value


func modify_unit_stat(unit, stat_name: String, amount: int, temporary := false, source_name := "") -> bool:
	var target = _manager.formation.unit_by_uid(str(unit.uid)) if unit != null else null
	var accepted: bool = _manager.modify_unit_stat(target, stat_name, amount, temporary, source_name)
	refresh()
	return accepted


func check_victory_or_defeat() -> bool:
	var complete: bool = _manager.check_victory_or_defeat()
	refresh()
	return complete


func _on_combat_event(payload: Dictionary) -> void:
	refresh()
	combat_event.emit(payload.duplicate(true))
