extends RefCounted
class_name ExplorationRules

const ProgressionDatabaseScript = preload("res://scripts/data/ProgressionDatabase.gd")


static func cultivation_reward_for_node(node: Dictionary) -> int:
	match str(node.get("type", "normal")):
		"elite":
			return 5
		"boss":
			return 10
		"treasure":
			return 4
		"event", "shop", "rest":
			return 2
	return 3


static func node_completion_result(node: Dictionary, already_completed: bool, current_base: int) -> Dictionary:
	var gain := 0
	if not already_completed:
		gain = cultivation_reward_for_node(node)
	return {
		"cultivation_gain": gain,
		"cultivation_base": max(0, current_base) + gain
	}


static func rest_result(max_hp: int) -> Dictionary:
	return {
		"success": true,
		"current_hp": max(0, max_hp),
		"message": "休息：生命已恢复。"
	}


static func run_settlement_result(cultivation_base: int, realm_index: int, completed: bool) -> Dictionary:
	var safe_base: int = max(0, cultivation_base)
	var multiplier: float = ProgressionDatabaseScript.layer_multiplier(realm_index)
	var awarded: int = int(ceil(float(safe_base) * multiplier))
	var settlement_label := "本轮探索完成" if completed else "本轮探索结束"
	return {
		"base": safe_base,
		"multiplier": multiplier,
		"awarded": awarded,
		"completed": completed,
		"message": "%s：基础修为 %d，倍率 x%s，获得 %d 修为点。" % [
			settlement_label,
			safe_base,
			_format_multiplier(multiplier),
			awarded
		]
	}


static func _format_multiplier(value: float) -> String:
	if is_equal_approx(value, floor(value)):
		return "%d" % int(value)
	return "%.2f" % value
