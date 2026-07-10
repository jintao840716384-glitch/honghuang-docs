extends RefCounted
class_name DifficultyCurveDatabase

const CONTENT_STATE_ACTIVE := "active"

const CURVE_DEFINITIONS := [
	{
		"curve_id": "curve_normal_01",
		"encounter_type": "normal",
		"world_difficulty_id": "wd0",
		"content_state": CONTENT_STATE_ACTIVE,
		"hp_by_layer": [0, 6, 10, 28, 44, 64, 88],
		"attack_by_layer": [0, 1, 1, 2, 3, 4, 5],
		"defense_by_layer": [0, 0, 0, 1, 1, 2, 2],
		"draw_bonus_by_layer": [0, 0, 0, 0, 0, 0, 0],
		"hp_per_node": 0.5,
		"attack_node_step": 7,
		"world_hp": 5,
		"world_attack": 0.25,
		"world_defense": 0.08,
		"world_draw_step": 0
	},
	{
		"curve_id": "curve_elite_01",
		"encounter_type": "elite",
		"world_difficulty_id": "wd0",
		"content_state": CONTENT_STATE_ACTIVE,
		"hp_by_layer": [8, 15, 22, 38, 58, 84, 114],
		"attack_by_layer": [1, 1, 2, 3, 4, 5, 6],
		"defense_by_layer": [0, 0, 0, 1, 1, 2, 2],
		"draw_bonus_by_layer": [0, 0, 0, 0, 0, 0, 0],
		"hp_per_node": 0.6,
		"attack_node_step": 6,
		"world_hp": 8,
		"world_attack": 0.35,
		"world_defense": 0.12,
		"world_draw_step": 0
	},
	{
		"curve_id": "curve_boss_01",
		"encounter_type": "boss",
		"world_difficulty_id": "wd0",
		"content_state": CONTENT_STATE_ACTIVE,
		"hp_by_layer": [10, 18, 24, 46, 70, 100, 136],
		"attack_by_layer": [1, 1, 2, 3, 4, 5, 6],
		"defense_by_layer": [0, 0, 0, 1, 1, 2, 2],
		"draw_bonus_by_layer": [1, 1, 1, 1, 1, 1, 1],
		"hp_per_node": 0.8,
		"attack_node_step": 6,
		"world_hp": 12,
		"world_attack": 0.45,
		"world_defense": 0.15,
		"world_draw_step": 0
	}
]


static func definitions() -> Array:
	return CURVE_DEFINITIONS.duplicate(true)


static func active_definitions() -> Array:
	return filter_active(CURVE_DEFINITIONS)


static func filter_active(definitions: Array) -> Array:
	var result: Array = []
	for definition_variant in definitions:
		var definition: Dictionary = definition_variant
		if str(definition.get("content_state", "")) == CONTENT_STATE_ACTIVE:
			result.append(definition.duplicate(true))
	return result


static func active_curve_for_encounter(encounter_type: String) -> Dictionary:
	for definition_variant in active_definitions():
		var definition: Dictionary = definition_variant
		if str(definition.get("encounter_type", "")) == encounter_type:
			return definition.duplicate(true)
	return {}


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


static func draw_bonus(layer_number: int, encounter_type: String, world_difficulty: int) -> int:
	var curve: Dictionary = curve_for_encounter(encounter_type)
	var layer_index: int = max(0, layer_number - 1)
	var bonus: int = curve_value(curve.get("draw_bonus_by_layer", []), layer_index)
	var world_step: int = int(curve.get("world_draw_step", 0))
	if world_step > 0 and world_difficulty > 0:
		bonus += int(world_difficulty / world_step)
	return max(0, bonus)


static func curve_for_encounter(encounter_type: String) -> Dictionary:
	return active_curve_for_encounter(encounter_type)


static func curve_value(values: Array, layer_index: int) -> int:
	if values.is_empty():
		return 0
	var index: int = clampi(layer_index, 0, values.size() - 1)
	var result: int = int(values[index])
	if layer_index >= values.size():
		var tail_step: int = max(1, int(values[values.size() - 1]) - int(values[max(0, values.size() - 2)]))
		result += (layer_index - values.size() + 1) * tail_step
	return result
