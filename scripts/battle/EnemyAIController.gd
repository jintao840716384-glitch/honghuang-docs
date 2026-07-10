extends "res://scripts/battle/SideController.gd"
class_name EnemyAIController

const BattleUnitScript = preload("res://scripts/battle/BattleUnit.gd")


func action_queue_for_units(units: Array) -> Array:
	var result: Array = units.duplicate()
	result.sort_custom(func(a, b) -> bool:
		return _unit_action_order(a) < _unit_action_order(b)
	)
	return result


func next_unit_action(_snapshot, source_unit) -> Dictionary:
	if source_unit != null and source_unit.has_method("next_action"):
		var action: Dictionary = source_unit.call("next_action")
		if not action.is_empty():
			return action
	if source_unit != null and source_unit.current_attack() > 0:
		return {"kind": "normal_attack", "intent": "攻击"}
	return {"kind": "wait", "intent": "待机"}


func side_card_source_unit(battle):
	if battle == null or battle.formation == null:
		return null
	return battle.formation.primary_enemy()


func select_next_side_card(battle, source_unit) -> Dictionary:
	if battle == null or battle.enemy_side == null or battle.enemy_side.deck_manager == null:
		return {}
	var candidates: Array = battle.enemy_side.deck_manager.hand.duplicate()
	candidates.sort_custom(func(a, b) -> bool:
		return _side_card_priority(a) > _side_card_priority(b)
	)
	for card_variant in candidates:
		var card: Dictionary = card_variant
		if _side_card_playable(battle, source_unit, card):
			return card
	return {}


func side_card_profile(card_id: String) -> Dictionary:
	return {}


func side_card_target(battle, source_unit, card: Dictionary):
	if battle == null or source_unit == null or card.is_empty():
		return null
	var effect: Dictionary = card.get("effect", {})
	match str(card.get("target_scope", "")):
		"ally_unit":
			if _card_has_effect_type(card, "heal") and _card_has_effect_type(card, "set_unit_action_lock"):
				return _injured_ally_target(battle)
			if _card_has_effect_type(card, "add_next_attack_modifier") and _card_has_effect_type(card, "add_status_on_hit"):
				return _ally_attack_target(battle)
			match str(effect.get("kind", "")):
				"heal_and_exhaust":
					return _injured_ally_target(battle)
				"prepare_attack_status":
					return _ally_attack_target(battle)
				_:
					return _first_living_unit(battle, BattleUnitScript.TEAM_ENEMY)
		"enemy_unit":
			if _card_has_effect_type(card, "remove_status_by_tag") or str(effect.get("kind", "")) == "remove_positive_status":
				return _positive_status_enemy_target(battle)
			return _first_living_unit(battle, BattleUnitScript.TEAM_PLAYER)
	return null


func _unit_action_order(unit) -> int:
	if unit == null:
		return 99
	match int(unit.slot_index):
		2:
			return 0
		1:
			return 1
		3:
			return 2
	return 10 + int(unit.slot_index)


func _side_card_playable(battle, source_unit, card: Dictionary) -> bool:
	if battle == null or source_unit == null or card.is_empty():
		return false
	var effect: Dictionary = card.get("effect", {})
	if _card_has_effect_type(card, "no_effect") or ["noop", "no_effect"].has(str(effect.get("kind", ""))):
		return true
	var target_scope := str(card.get("target_scope", ""))
	if target_scope in ["ally_unit", "enemy_unit"] and side_card_target(battle, source_unit, card) == null:
		return false
	for effect_type_variant in _effect_step_types(card):
		if str(effect_type_variant) in [
			"add_next_attack_modifier",
			"add_status_on_hit",
			"heal",
			"set_unit_action_lock",
			"remove_status_by_tag",
			"add_status",
			"draw_cards",
			"create_card_to_zone",
			"move_source_card"
		]:
			return true
	match str(effect.get("kind", "")):
		"prepare_attack_status", "heal_and_exhaust", "remove_positive_status", "add_status", "draw_and_pollute":
			return true
	return false


func _side_card_priority(card: Dictionary) -> int:
	if card.is_empty():
		return -999
	var effect: Dictionary = card.get("effect", {})
	if _card_has_effect_type(card, "no_effect") or ["noop", "no_effect"].has(str(effect.get("kind", ""))):
		return -100
	return int(card.get("ai_priority", 10))


func _effect_step_types(card: Dictionary) -> Array:
	var result: Array = []
	for step_variant in card.get("effect_steps", []):
		if step_variant is Dictionary:
			var step: Dictionary = step_variant
			result.append(str(step.get("effect_type", "")))
	return result


func _card_has_effect_type(card: Dictionary, effect_type: String) -> bool:
	return _effect_step_types(card).has(effect_type)


func _injured_ally_target(battle):
	var result = null
	var missing_hp := 0
	for unit in battle.formation.living_units(BattleUnitScript.TEAM_ENEMY):
		if unit == null or battle.unit_action_used(unit):
			continue
		var current_missing: int = int(unit.max_hp) - int(unit.hp)
		if current_missing > missing_hp:
			missing_hp = current_missing
			result = unit
	return result


func _ally_attack_target(battle):
	for unit in battle.formation.living_units(BattleUnitScript.TEAM_ENEMY):
		if unit == null:
			continue
		if battle.unit_action_used(unit):
			continue
		if unit.current_attack() <= 0:
			continue
		return unit
	return null


func _positive_status_enemy_target(battle):
	for unit in battle.formation.living_units(BattleUnitScript.TEAM_PLAYER):
		if unit != null and battle.unit_has_positive_status(unit):
			return unit
	return null


func _first_living_unit(battle, unit_team: String):
	var units: Array = battle.formation.living_units(unit_team)
	if units.is_empty():
		return null
	return units[0]
