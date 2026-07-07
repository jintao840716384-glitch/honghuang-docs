extends "res://scripts/battle/SideController.gd"
class_name EnemyAIController

const BattleUnitScript = preload("res://scripts/battle/BattleUnit.gd")

const CARD_PRIORITY := ["雷击符", "裂石符", "火球符", "金刃符", "缚身符", "破甲符", "铁木甲"]


func action_queue_for_units(units: Array) -> Array:
	var result: Array = units.duplicate()
	result.sort_custom(func(a, b) -> bool:
		return _unit_action_order(a) < _unit_action_order(b)
	)
	return result


func prepare_unit_turn(_battle, source_unit) -> void:
	_clear_temporary_defense(source_unit)
	if source_unit != null and source_unit.has_method("tick_skill_cooldowns"):
		source_unit.call("tick_skill_cooldowns")


func next_unit_action(_battle, source_unit) -> Dictionary:
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
	for card_id in CARD_PRIORITY:
		for card_variant in battle.enemy_side.deck_manager.hand:
			var card: Dictionary = card_variant
			if str(card.get("id", "")) == card_id and _side_card_playable(battle, source_unit, card):
				return card
	return {}


func side_card_profile(card_id: String) -> Dictionary:
	match card_id:
		"火球符":
			return {"damage": 4}
		"金刃符":
			return {"damage": 3}
		"雷击符":
			return {"damage": 8}
		"裂石符":
			return {
				"damage": 7,
				"post_steps": [
					{"kind": "add_status", "target": "context_target", "status": "破甲", "value": 1, "source": "裂石符"}
				]
			}
		"破甲符":
			return {
				"post_steps": [
					{"kind": "add_status", "target": "context_target", "status": "破甲", "value": 2, "source": "破甲符"}
				]
			}
		"缚身符":
			return {
				"post_steps": [
					{"kind": "add_status", "target": "context_target", "status": "虚弱", "value": 2, "source": "缚身符"}
				]
			}
	return {}


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


func _clear_temporary_defense(source_unit) -> void:
	if source_unit != null and source_unit.has_method("clear_temporary_defense"):
		source_unit.call("clear_temporary_defense")
	elif source_unit != null:
		source_unit.temp_defense_delta = 0


func _side_card_playable(battle, source_unit, card: Dictionary) -> bool:
	if battle == null or source_unit == null or card.is_empty():
		return false
	match str(card.get("id", "")):
		"铁木甲":
			return source_unit.equipment.size() < int(source_unit.equipment_limit) and not source_unit.has_equipment("铁木甲")
		"火球符", "金刃符", "雷击符", "裂石符", "破甲符", "缚身符":
			return not battle.formation.living_units(BattleUnitScript.TEAM_PLAYER).is_empty()
	return false
