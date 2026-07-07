extends "res://scripts/battle/BattleUnit.gd"
class_name EnemyState

const BattleUnitScript = preload("res://scripts/battle/BattleUnit.gd")

var enemy_id := ""
var actions: Array = []
var action_index := 0
var current_intent := ""
var skills: Dictionary = {}
var skill_cooldowns: Dictionary = {}

func setup(data: Dictionary) -> void:
	enemy_id = data.get("id", "")
	var unit_data: Dictionary = {
		"id": enemy_id,
		"uid": data.get("uid", enemy_id),
		"name": data.get("name", ""),
		"team": BattleUnitScript.TEAM_ENEMY,
		"unit_type": BattleUnitScript.TYPE_ENEMY,
		"unit_rank": data.get("unit_rank", BattleUnitScript.RANK_NORMAL),
		"unit_tags": _unit_tags_from_data(data),
		"slot_index": int(data.get("slot_index", 2)),
		"max_hp": int(data.get("max_hp", 0)),
		"attack": int(data.get("attack", 0)),
		"defense": int(data.get("defense", 0)),
		"equipment": data.get("equipment", [])
	}
	if data.has("equipment_limit"):
		unit_data["equipment_limit"] = int(data.get("equipment_limit", 1))
	setup_unit(unit_data, BattleUnitScript.TEAM_ENEMY, BattleUnitScript.TYPE_ENEMY)
	actions = data.get("action_sequence", []).duplicate(true)
	skills = data.get("skills", {}).duplicate(true)
	skill_cooldowns.clear()
	action_index = 0
	current_intent = peek_action().get("intent", "")

func _unit_tags_from_data(data: Dictionary) -> Array:
	var result: Array = data.get("unit_tags", []).duplicate()
	for tag in ["敌人", "enemy", str(data.get("unit_rank", BattleUnitScript.RANK_NORMAL))]:
		if tag != "" and not result.has(tag):
			result.append(tag)
	if bool(data.get("unit_rank", BattleUnitScript.RANK_NORMAL) == BattleUnitScript.RANK_BOSS) and not result.has("首领"):
		result.append("首领")
	if bool(data.get("unit_rank", BattleUnitScript.RANK_NORMAL) == BattleUnitScript.RANK_ELITE) and not result.has("精英"):
		result.append("精英")
	return result

func peek_action() -> Dictionary:
	if actions.is_empty():
		return {}
	return actions[action_index % actions.size()]

func next_action() -> Dictionary:
	var action: Dictionary = peek_action()
	action_index += 1
	current_intent = peek_action().get("intent", "")
	return action

func skill_for_action(action: Dictionary) -> Dictionary:
	var skill_id := str(action.get("skill_id", ""))
	if skill_id == "":
		return {}
	return skills.get(skill_id, {})

func skill_ready(skill_id: String) -> bool:
	return int(skill_cooldowns.get(skill_id, 0)) <= 0

func put_skill_on_cooldown(skill_id: String) -> void:
	var skill: Dictionary = skills.get(skill_id, {})
	var cooldown: int = int(skill.get("cooldown", 0))
	if cooldown > 0:
		skill_cooldowns[skill_id] = cooldown

func tick_skill_cooldowns() -> void:
	for skill_id in skill_cooldowns.keys():
		var next_value: int = max(0, int(skill_cooldowns.get(skill_id, 0)) - 1)
		if next_value <= 0:
			skill_cooldowns.erase(skill_id)
		else:
			skill_cooldowns[skill_id] = next_value

func clear_temporary_defense() -> void:
	temp_defense_delta = 0
