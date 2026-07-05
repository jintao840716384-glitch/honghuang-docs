extends RefCounted
class_name EnemyDatabase

static func _templates() -> Array:
	return [
		{
			"id": "mountain_demon",
			"name": "山妖",
			"max_hp": 30,
			"attack": 7,
			"defense": 1,
			"action_sequence": [
				{"kind": "normal_attack", "intent": "攻击"},
				{"kind": "normal_attack", "intent": "攻击"},
				{"kind": "charge", "intent": "蓄力"},
				{"kind": "strong_attack", "intent": "强攻击", "attack_bonus": 4}
			]
		},
		{
			"id": "iron_armor_demon",
			"name": "铁甲妖",
			"max_hp": 40,
			"attack": 7,
			"defense": 4,
			"action_sequence": [
				{"kind": "normal_attack", "intent": "攻击"},
				{"kind": "defense_stance", "intent": "防御姿态", "defense_delta": 3},
				{"kind": "normal_attack", "intent": "攻击"},
				{"kind": "weakness", "intent": "虚弱", "defense_delta": -4}
			]
		},
		{
			"id": "spell_breaking_demon",
			"name": "破法妖",
			"max_hp": 36,
			"attack": 6,
			"defense": 2,
			"action_sequence": [
				{"kind": "normal_attack", "intent": "攻击"},
				{"kind": "destroy_spell_zone", "intent": "破坏法防区"},
				{"kind": "spell_attack", "intent": "施法"},
				{"kind": "normal_attack", "intent": "攻击"}
			]
		}
	]

static func get_enemy_for_battle(battle_number: int) -> Dictionary:
	var templates := _templates()
	var template: Dictionary = templates[(battle_number - 1) % templates.size()].duplicate(true)
	var step := battle_number - 1
	template["battle_number"] = battle_number
	template["max_hp"] = int(template["max_hp"]) + step * 5
	template["attack"] = int(template["attack"]) + step
	template["defense"] = int(template["defense"]) + int(step / 2)
	return template
