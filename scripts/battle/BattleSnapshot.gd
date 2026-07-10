extends RefCounted
class_name BattleSnapshot

class UnitView:
	extends RefCounted
	var uid := ""
	var unit_id := ""
	var name := ""
	var team := ""
	var slot_index := -1
	var hp := 0
	var max_hp := 0
	var attack := 0
	var defense := 0
	var temp_defense_delta := 0
	var equipment_limit := 0
	var equipment: Array = []
	var spell_zone: Array = []
	var status_instances: Array = []
	var visual_profile_id := "default"
	var battle_animation_profile_id := "default"
	var job_id := ""
	var job_name := ""
	var sword_momentum := 0
	var current_intent := ""
	var action_preview: Dictionary = {}
	var effective_attack := 0
	var effective_defense := 0

	func current_attack() -> int:
		return effective_attack

	func current_defense() -> int:
		return effective_defense

	func get_status(status_id: String) -> int:
		var total := 0
		for status_variant in status_instances:
			var status: Dictionary = status_variant
			if str(status.get("status_id", "")) == status_id:
				total += int(status.get("value", 0))
		return total

	func has_status(status_id: String) -> bool:
		return get_status(status_id) > 0

	func next_action() -> Dictionary:
		return action_preview.duplicate(true)


class DeckView:
	extends RefCounted
	var deck: Array = []
	var hand: Array = []
	var graveyard: Array = []
	var exile: Array = []

	func find_hand_card(uid: String) -> Dictionary:
		for card_variant in hand:
			var card: Dictionary = card_variant
			if str(card.get("uid", "")) == uid:
				return card.duplicate(true)
		return {}


class FormationView:
	extends RefCounted
	var player_units: Array = []
	var enemy_units: Array = []

	func living_units(team: String) -> Array:
		var source := player_units if team == "player" else enemy_units
		var result: Array = []
		for unit in source:
			if unit != null and int(unit.hp) > 0:
				result.append(unit)
		return result

	func living_unit_by_uid(team: String, uid: String):
		for unit in living_units(team):
			if str(unit.uid) == uid:
				return unit
		return null

	func unit_by_uid(uid: String):
		for unit in player_units + enemy_units:
			if unit != null and str(unit.uid) == uid:
				return unit
		return null

	func primary_enemy():
		return enemy_units[0] if not enemy_units.is_empty() else null


class SideView:
	extends RefCounted
	var side_id := ""
	var units: Array = []
	var main_unit
	var deck_manager
	var spell_zone: Array = []
	var draw_per_turn := 0


var context_id := ""
var battle_number := 0
var turn_number := 0
var phase := ""
var player
var enemy
var formation
var player_side
var enemy_side
var deck
var master_deck_ids: Array = []
var master_reserve_ids: Array = []
var reward_options: Array = []
var pending_choice: Dictionary = {}
var pending_equipment_replace: Dictionary = {}
var pending_target_action: Dictionary = {}
var messages: Array = []
var selected_enemy_uid := ""
var selected_player_uid := ""
var selected_debug_uid := ""
var auto_advance_after_reward := true
var player_unit_actions_used: Dictionary = {}
var enemy_action_queue_uids: Array = []
var response_chain_state := "resolved"
var pending_options: Array = []
var last_result: Dictionary = {}


func from_context(context, scope := "ui"):
	var result = self
	if context == null:
		return result
	result.context_id = str(context.context_id)
	result.battle_number = int(context.battle_number)
	result.turn_number = int(context.turn_number)
	result.phase = str(context.phase)
	result.selected_enemy_uid = str(context.selected_enemy_uid)
	result.selected_player_uid = str(context.selected_player_uid)
	result.selected_debug_uid = str(context.selected_debug_uid)
	result.auto_advance_after_reward = bool(context.auto_advance_after_reward)
	result.player_unit_actions_used = context.player_unit_actions_used.duplicate(true)
	for queued_unit in context.enemy_action_queue:
		if queued_unit != null:
			result.enemy_action_queue_uids.append(str(queued_unit.uid))
	result.response_chain_state = str(context.response_chain_state)
	var views: Dictionary = {}
	result.formation = _formation_view(context.formation, views)
	result.player = _view_for_unit(context.player, views)
	result.enemy = _view_for_unit(context.enemy, views)
	if scope == "ai":
		result.enemy_side = _side_view(context.enemy_side, result.formation.enemy_units, result.enemy, null)
		if result.enemy_side.deck_manager != null:
			result.enemy_side.deck_manager.deck.clear()
			result.enemy_side.deck_manager.graveyard.clear()
			result.enemy_side.deck_manager.exile.clear()
		return result
	result.master_deck_ids = context.master_deck_ids.duplicate(true)
	result.master_reserve_ids = context.master_reserve_ids.duplicate(true)
	result.reward_options = context.reward_options.duplicate(true)
	result.pending_choice = context.pending_choice.duplicate(true)
	result.pending_equipment_replace = context.pending_equipment_replace.duplicate(true)
	result.pending_target_action = context.pending_target_action.duplicate(true)
	result.messages = context.messages.duplicate(true)
	result.last_result = context.last_result.duplicate(true)
	result.deck = _deck_view(context.deck)
	result.player_side = _side_view(context.player_side, result.formation.player_units, result.player, result.deck)
	result.enemy_side = _side_view(context.enemy_side, result.formation.enemy_units, result.enemy, null)
	return result


func unit_action_used(unit) -> bool:
	if unit == null:
		return true
	if str(unit.team) == "player":
		return bool(player_unit_actions_used.get(str(unit.uid), false))
	if str(unit.team) == "enemy":
		return phase == "enemy" and not enemy_action_queue_uids.has(str(unit.uid))
	return true


func unit_has_positive_status(unit) -> bool:
	if unit == null:
		return false
	for status_variant in unit.status_instances:
		var status: Dictionary = status_variant
		if (status.get("tags", []) as Array).has("positive"):
			return true
	return false


static func _formation_view(source, views: Dictionary):
	var result := FormationView.new()
	if source == null:
		return result
	for unit in source.player_units:
		result.player_units.append(_view_for_unit(unit, views))
	for unit in source.enemy_units:
		result.enemy_units.append(_view_for_unit(unit, views))
	return result


static func _view_for_unit(source, views: Dictionary):
	if source == null:
		return null
	var uid := str(source.uid)
	if views.has(uid):
		return views[uid]
	var result := UnitView.new()
	result.uid = uid
	result.unit_id = str(source.unit_id)
	result.name = str(source.name)
	result.team = str(source.team)
	result.slot_index = int(source.slot_index)
	result.hp = int(source.hp)
	result.max_hp = int(source.max_hp)
	result.attack = int(source.attack)
	result.defense = int(source.defense)
	result.temp_defense_delta = int(source.temp_defense_delta)
	result.equipment_limit = int(source.equipment_limit)
	result.equipment = source.equipment.duplicate(true)
	if _has_property(source, "spell_zone"):
		result.spell_zone = (source.get("spell_zone") as Array).duplicate(true)
	result.status_instances = source.status_records_snapshot()
	result.visual_profile_id = str(source.visual_profile_id)
	result.battle_animation_profile_id = str(source.battle_animation_profile_id)
	result.job_id = str(source.get("job_id")) if _has_property(source, "job_id") else ""
	result.job_name = str(source.get("job_name")) if _has_property(source, "job_name") else ""
	result.sword_momentum = int(source.get("sword_momentum")) if _has_property(source, "sword_momentum") else 0
	result.current_intent = str(source.get("current_intent")) if _has_property(source, "current_intent") else ""
	if source.has_method("peek_action"):
		result.action_preview = (source.call("peek_action") as Dictionary).duplicate(true)
	result.effective_attack = int(source.current_attack())
	result.effective_defense = int(source.current_defense())
	views[uid] = result
	return result


static func _has_property(source, property_name: String) -> bool:
	if source == null:
		return false
	for property_variant in source.get_property_list():
		var property: Dictionary = property_variant
		if str(property.get("name", "")) == property_name:
			return true
	return false


static func _deck_view(source):
	var result := DeckView.new()
	if source == null:
		return result
	result.deck = source.deck.duplicate(true)
	result.hand = source.hand.duplicate(true)
	result.graveyard = source.graveyard.duplicate(true)
	result.exile = source.exile.duplicate(true)
	return result


static func _side_view(source, units: Array, main_unit, fallback_deck):
	var result := SideView.new()
	if source == null:
		return result
	result.side_id = str(source.side_id)
	result.units = units.duplicate()
	result.main_unit = main_unit
	result.draw_per_turn = int(source.draw_per_turn)
	result.spell_zone = source.spell_zone.duplicate(true)
	result.deck_manager = _deck_view(source.deck_manager) if source.deck_manager != null else fallback_deck
	return result
