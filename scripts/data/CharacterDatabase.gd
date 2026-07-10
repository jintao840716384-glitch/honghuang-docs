extends RefCounted
class_name CharacterDatabase

const CONTENT_STATE_ACTIVE := "active"


static func character_templates() -> Dictionary:
	return {
		"sword": {
			"id": "sword",
			"content_state": CONTENT_STATE_ACTIVE,
			"name_key": "character.sword.name",
			"name": "剑修",
			"max_hp": 35,
			"attack": 8,
			"defense": 0,
			"unit_tags": ["主单位", "剑修", "sword"],
			"visual_profile_id": "sword",
			"animation_profile": "sword"
		},
		"talisman": {
			"id": "talisman",
			"content_state": CONTENT_STATE_ACTIVE,
			"name_key": "character.talisman.name",
			"name": "符修",
			"max_hp": 30,
			"attack": 4,
			"defense": 0,
			"unit_tags": ["主单位", "符修", "talisman"],
			"visual_profile_id": "talisman",
			"animation_profile": "talisman"
		},
		"mountain_demon": _character("mountain_demon", "山妖", 18, 4, 0, ["妖", "野兽"], "beast"),
		"iron_armor_demon": _character("iron_armor_demon", "铁甲妖", 22, 4, 0, ["妖", "甲壳"], "armored"),
		"spell_breaking_demon": _character("spell_breaking_demon", "破法妖", 20, 3, 0, ["妖", "破法"], "caster"),
		"cliff_bandit": _character("cliff_bandit", "崖道散修", 19, 5, 0, ["修士"], "bandit"),
		"stone_guardian": _character("stone_guardian", "石岭守将", 20, 4, 0, ["妖", "首领候选", "护甲"], "stone_boss"),
		"hexing_talismanist": _character("hexing_talismanist", "咒符客", 18, 4, 0, ["修士", "符"], "hex_boss"),
		"ember_adept": _character("ember_adept", "赤焰客", 17, 5, 0, ["修士", "火"], "ember_boss"),
		"armor_captain": _character("armor_captain", "披甲校尉", 21, 5, 0, ["修士", "护甲"], "guard_boss"),
		"draining_shaman": _character("draining_shaman", "蚀气巫", 20, 4, 0, ["妖", "削弱"], "drain_boss"),
		"thunder_apprentice": _character("thunder_apprentice", "引雷童子", 19, 5, 0, ["修士", "雷"], "thunder_boss"),
		"mountain_warlord": _character("mountain_warlord", "盘山妖将", 22, 5, 0, ["妖", "首领候选"], "warlord_boss"),
		"mirror_guardian": _character("mirror_guardian", "玄镜护法", 21, 5, 0, ["修士", "护甲"], "mirror_boss"),
		"chain_cultivator": _character("chain_cultivator", "缚灵客", 20, 5, 0, ["修士", "控制"], "chain_boss")
	}


static func character_template(character_id: String) -> Dictionary:
	var templates: Dictionary = character_templates()
	if templates.has(character_id):
		var definition: Dictionary = templates.get(character_id, {})
		if str(definition.get("content_state", "")) == CONTENT_STATE_ACTIVE:
			return definition.duplicate(true)
	return {}


static func active_character_ids() -> Array:
	var result: Array = []
	for character_id_variant in character_templates().keys():
		var character_id := str(character_id_variant)
		var definition: Dictionary = character_templates().get(character_id, {})
		if str(definition.get("content_state", "")) == CONTENT_STATE_ACTIVE:
			result.append(character_id)
	return result


static func action_sequence_for_character(character_id: String) -> Array:
	if character_id == "iron_armor_demon" or character_id == "armor_captain" or character_id == "mirror_guardian":
		return _guard_action_sequence()
	if character_id == "spell_breaking_demon" or character_id == "hexing_talismanist" or character_id == "chain_cultivator":
		return _spell_action_sequence()
	return _default_action_sequence()


static func _character(character_id: String, display_name: String, max_hp: int, attack: int, defense: int, tags: Array, animation_profile: String) -> Dictionary:
	return {
		"id": character_id,
		"content_state": CONTENT_STATE_ACTIVE,
		"name_key": "character.%s.name" % character_id,
		"name": display_name,
		"max_hp": max_hp,
		"attack": attack,
		"defense": defense,
		"unit_tags": tags.duplicate(),
		"visual_profile_id": animation_profile,
		"animation_profile": animation_profile,
		"action_sequence": _default_action_sequence(),
		"skills": {}
	}


static func _default_action_sequence() -> Array:
	return [
		{"kind": "normal_attack", "intent": "攻击"},
		{"kind": "normal_attack", "intent": "攻击"},
		{"kind": "charge", "intent": "蓄力"},
		{"kind": "strong_attack", "intent": "强攻击", "attack_bonus": 2}
	]


static func _guard_action_sequence() -> Array:
	return [
		{"kind": "normal_attack", "intent": "攻击"},
		{"kind": "defense_stance", "intent": "防御姿态", "defense_delta": 1},
		{"kind": "normal_attack", "intent": "攻击"},
		{"kind": "normal_attack", "intent": "攻击"}
	]


static func _spell_action_sequence() -> Array:
	return [
		{"kind": "normal_attack", "intent": "攻击"},
		{"kind": "destroy_spell_zone", "intent": "破坏法防区"},
		{"kind": "spell_attack", "intent": "施法"},
		{"kind": "normal_attack", "intent": "攻击"}
	]
