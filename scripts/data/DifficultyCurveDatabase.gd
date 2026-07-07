extends RefCounted
class_name DifficultyCurveDatabase


static func difficulty_bonus(layer_number: int, battle_number: int, encounter_type: String, world_difficulty: int) -> Dictionary:
	var curve: Dictionary = curve_for_encounter(encounter_type)
	var layer_index: int = max(0, layer_number - 1)
	var node_step: int = max(0, battle_number - 1)
	var hp: int = curve_value(curve.get("hp_by_layer", []), layer_index) + int(floor(float(node_step) * float(curve.get("hp_per_node", 0.0))))
	var attack: int = curve_value(curve.get("attack_by_layer", []), layer_index)
	var attack_step: int = int(curve.get("attack_node_step", 0))
	if attack_step > 0:
		attack += int(node_step / attack_step)
	var defense: int = curve_value(curve.get("defense_by_layer", []), layer_index)
	if world_difficulty > 0:
		hp += int(world_difficulty * int(curve.get("world_hp", 0)))
		attack += int(floor(float(world_difficulty) * float(curve.get("world_attack", 0.0))))
		defense += int(floor(float(world_difficulty) * float(curve.get("world_defense", 0.0))))
	return {"hp": hp, "attack": attack, "defense": defense}


static func curve_for_encounter(encounter_type: String) -> Dictionary:
	match encounter_type:
		"elite":
			return {
				"hp_by_layer": [8, 15, 22, 38, 58, 84, 114],
				"attack_by_layer": [1, 1, 2, 3, 4, 5, 6],
				"defense_by_layer": [0, 0, 0, 1, 1, 2, 2],
				"hp_per_node": 0.6,
				"attack_node_step": 6,
				"world_hp": 8,
				"world_attack": 0.35,
				"world_defense": 0.12
			}
		"boss":
			return {
				"hp_by_layer": [10, 18, 24, 46, 70, 100, 136],
				"attack_by_layer": [1, 1, 2, 3, 4, 5, 6],
				"defense_by_layer": [0, 0, 0, 1, 1, 2, 2],
				"hp_per_node": 0.8,
				"attack_node_step": 6,
				"world_hp": 12,
				"world_attack": 0.45,
				"world_defense": 0.15
			}
	return {
		"hp_by_layer": [0, 6, 10, 28, 44, 64, 88],
		"attack_by_layer": [0, 1, 1, 2, 3, 4, 5],
		"defense_by_layer": [0, 0, 0, 1, 1, 2, 2],
		"hp_per_node": 0.5,
		"attack_node_step": 7,
		"world_hp": 5,
		"world_attack": 0.25,
		"world_defense": 0.08
	}


static func curve_value(values: Array, layer_index: int) -> int:
	if values.is_empty():
		return 0
	var index: int = clampi(layer_index, 0, values.size() - 1)
	var result: int = int(values[index])
	if layer_index >= values.size():
		var tail_step: int = max(1, int(values[values.size() - 1]) - int(values[max(0, values.size() - 2)]))
		result += (layer_index - values.size() + 1) * tail_step
	return result
