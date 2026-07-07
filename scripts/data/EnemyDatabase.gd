extends RefCounted
class_name EnemyDatabase

const RANK_NORMAL := "normal"
const RANK_ELITE := "elite"
const RANK_BOSS := "boss"

const WORLD_DECK_KEY := "world_deck_overrides"

static func character_templates() -> Dictionary:
	return {
		"sword": {
			"id": "sword",
			"name": "剑修",
			"max_hp": 35,
			"attack": 8,
			"defense": 0,
			"unit_tags": ["主单位", "剑修", "sword"],
			"animation_profile": "sword"
		},
		"talisman": {
			"id": "talisman",
			"name": "符修",
			"max_hp": 30,
			"attack": 4,
			"defense": 0,
			"unit_tags": ["主单位", "符修", "talisman"],
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
		return (templates.get(character_id, {}) as Dictionary).duplicate(true)
	return {}

static func deck_templates_for(layer_number: int, encounter_type := "normal", world_difficulty := 0) -> Array:
	var templates: Array = []
	for template_variant in _deck_templates():
		var template: Dictionary = template_variant
		if int(template.get("layer", 1)) != max(1, layer_number):
			continue
		if str(template.get("encounter_type", "normal")) != encounter_type:
			continue
		if int(template.get("min_world", 0)) > world_difficulty:
			continue
		templates.append(template.duplicate(true))
	return templates

static func get_encounter_for_battle(battle_number: int, encounter_type := "normal", story_layer_index := 0, world_difficulty := 0, rng: RandomNumberGenerator = null) -> Dictionary:
	var layer_number: int = max(1, int(story_layer_index) + 1)
	var templates: Array = deck_templates_for(layer_number, encounter_type, world_difficulty)
	if templates.is_empty():
		templates = deck_templates_for(1, encounter_type, world_difficulty)
	if templates.is_empty():
		templates = deck_templates_for(1, "normal", world_difficulty)
	var selected: Dictionary = {}
	if templates.is_empty():
		selected = _fallback_deck_template(encounter_type)
	elif rng == null:
		selected = (templates[0] as Dictionary).duplicate(true)
	else:
		selected = (templates[rng.randi_range(0, templates.size() - 1)] as Dictionary).duplicate(true)
	return _build_encounter(selected, max(1, battle_number), layer_number, encounter_type, max(0, world_difficulty))

static func get_enemy_for_battle(battle_number: int) -> Dictionary:
	var encounter: Dictionary = get_encounter_for_battle(battle_number, "normal", 0, 0, null)
	return (encounter.get("primary_enemy", {}) as Dictionary).duplicate(true)

static func _character(character_id: String, display_name: String, max_hp: int, attack: int, defense: int, tags: Array, animation_profile: String) -> Dictionary:
	return {
		"id": character_id,
		"name": display_name,
		"max_hp": max_hp,
		"attack": attack,
		"defense": defense,
		"unit_tags": tags.duplicate(),
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

static func _deck_templates() -> Array:
	return [
		_deck_template("l1_normal_beast", 1, "normal", [], ["mountain_demon"], ["教学", "基础攻击"]),
		_deck_template("l1_normal_guard", 1, "normal", [], ["iron_armor_demon"], ["教学", "防守"]),
		_deck_template("l1_normal_spellbreak", 1, "normal", [], ["spell_breaking_demon"], ["教学", "破法"]),
		_deck_template("l1_elite_guard", 1, "elite", [], ["iron_armor_demon"], ["精英", "防守"]),
		_deck_template("l1_elite_breaker", 1, "elite", [], ["spell_breaking_demon"], ["精英", "破法"]),
		_deck_template("l1_elite_pack", 1, "elite", [], ["cliff_bandit"], ["精英", "攻击"]),
		_deck_template("l1_boss_stone_guardian", 1, "boss", ["铁木甲", "破甲符", "缚身符", "金刃符", "铁木甲"], ["stone_guardian"], ["首领", "装备防守"]),
		_deck_template("l1_boss_hexing_talismanist", 1, "boss", ["破甲符", "缚身符", "铁木甲", "破甲符", "金刃符"], ["hexing_talismanist"], ["首领", "削弱"]),
		_deck_template("l1_boss_ember_adept", 1, "boss", ["金刃符", "铁木甲", "破甲符", "金刃符", "缚身符"], ["ember_adept"], ["首领", "轻直伤"]),
		_deck_template("l2_normal_beast_pair", 2, "normal", [], ["mountain_demon"], ["基础", "野兽"]),
		_deck_template("l2_normal_guard", 2, "normal", [], ["iron_armor_demon"], ["基础", "护甲"]),
		_deck_template("l2_normal_bandit", 2, "normal", [], ["cliff_bandit"], ["基础", "攻击"]),
		_deck_template("l2_elite_break", 2, "elite", ["铁木甲", "破甲符", "铁木甲"], ["spell_breaking_demon"], ["精英", "破甲"]),
		_deck_template("l2_elite_guard", 2, "elite", ["破甲符", "铁木甲", "破甲符", "金刃符"], ["iron_armor_demon"], ["精英", "防守"]),
		_deck_template("l2_elite_bind", 2, "elite", ["缚身符", "破甲符", "铁木甲"], ["cliff_bandit"], ["精英", "虚弱"]),
		_deck_template("l2_boss_armor_captain", 2, "boss", ["铁木甲", "破甲符", "铁木甲", "破甲符", "金刃符", "铁木甲"], ["armor_captain"], ["首领", "装备"]),
		_deck_template("l2_boss_draining_shaman", 2, "boss", ["缚身符", "破甲符", "铁木甲", "缚身符", "金刃符", "破甲符"], ["draining_shaman"], ["首领", "削弱"]),
		_deck_template("l2_boss_thunder_apprentice", 2, "boss", ["金刃符", "破甲符", "铁木甲", "金刃符", "缚身符", "铁木甲"], ["thunder_apprentice"], ["首领", "轻爆发"]),
		_deck_template("l3_normal_break", 3, "normal", ["破甲符", "缚身符", "铁木甲"], ["spell_breaking_demon"], ["基础", "破甲"]),
		_deck_template("l3_normal_armor", 3, "normal", ["铁木甲", "破甲符", "金刃符"], ["iron_armor_demon"], ["基础", "防守"]),
		_deck_template("l3_normal_pair", 3, "normal", ["破甲符", "铁木甲", "缚身符"], ["cliff_bandit"], ["基础", "攻击"]),
		_deck_template("l3_elite_damage", 3, "elite", ["金刃符", "破甲符", "缚身符", "铁木甲"], ["cliff_bandit"], ["精英", "压迫"]),
		_deck_template("l3_elite_control", 3, "elite", ["缚身符", "破甲符", "铁木甲", "金刃符"], ["spell_breaking_demon"], ["精英", "削弱"]),
		_deck_template("l3_elite_guard", 3, "elite", ["铁木甲", "破甲符", "铁木甲", "缚身符"], ["iron_armor_demon"], ["精英", "防守"]),
		_deck_template("l3_boss_mountain_warlord", 3, "boss", ["破甲符", "缚身符", "铁木甲", "破甲符", "金刃符", "铁木甲", "缚身符"], ["mountain_warlord"], ["首领", "破甲爆发"]),
		_deck_template("l3_boss_mirror_guardian", 3, "boss", ["铁木甲", "破甲符", "铁木甲", "缚身符", "金刃符", "铁木甲", "破甲符"], ["mirror_guardian"], ["首领", "装备压制"]),
		_deck_template("l3_boss_chain_cultivator", 3, "boss", ["缚身符", "破甲符", "铁木甲", "缚身符", "金刃符", "破甲符", "铁木甲"], ["chain_cultivator"], ["首领", "控制"])
	]

static func _deck_template(template_id: String, layer_number: int, encounter_type: String, deck: Array, character_ids: Array, tags: Array) -> Dictionary:
	var character_refs: Array = []
	var slots := [2, 1, 3]
	for i in range(character_ids.size()):
		character_refs.append({
			"character_id": str(character_ids[i]),
			"slot_index": int(slots[i % slots.size()])
		})
	return {
		"id": template_id,
		"deck_template_id": template_id,
		"template_kind": "enemy_deck_template",
		"layer": layer_number,
		"encounter_type": encounter_type,
		"deck": deck.duplicate(),
		"character_refs": character_refs,
		"draw_per_turn": _default_draw_for_encounter(encounter_type),
		"card_play_limit": _default_draw_for_encounter(encounter_type),
		"theme_tags": tags.duplicate(),
		WORLD_DECK_KEY: []
	}

static func _fallback_deck_template(encounter_type: String) -> Dictionary:
	return _deck_template("fallback_%s" % encounter_type, 1, encounter_type, [], ["mountain_demon"], ["fallback"])

static func _build_encounter(template: Dictionary, battle_number: int, layer_number: int, encounter_type: String, world_difficulty: int) -> Dictionary:
	var rank := _rank_for_encounter(encounter_type)
	var units: Array = []
	var unit_refs: Array = template.get("character_refs", template.get("units", []))
	for i in range(unit_refs.size()):
		var unit_ref: Dictionary = unit_refs[i]
		var character_id := str(unit_ref.get("character_id", "mountain_demon"))
		var unit_data: Dictionary = _build_unit_from_character(character_id, unit_ref, rank, i, battle_number, layer_number, encounter_type, world_difficulty)
		if not unit_data.is_empty():
			units.append(unit_data)
	if units.is_empty():
		units.append(_build_unit_from_character("mountain_demon", {"slot_index": 2}, rank, 0, battle_number, layer_number, encounter_type, world_difficulty))
	var deck: Array = _deck_for_world(template, world_difficulty)
	var draw_count: int = int(template.get("draw_per_turn", _default_draw_for_encounter(encounter_type)))
	return {
		"id": str(template.get("id", "")),
		"deck_template_id": str(template.get("deck_template_id", template.get("id", ""))),
		"layer": layer_number,
		"encounter_type": encounter_type,
		"world_difficulty": world_difficulty,
		"node_position": battle_number,
		"theme_tags": template.get("theme_tags", []).duplicate(),
		"deck": deck,
		"character_refs": unit_refs.duplicate(true),
		"draw_per_turn": draw_count,
		"card_play_limit": int(template.get("card_play_limit", draw_count)),
		"enemy_units": units,
		"primary_enemy": (units[0] as Dictionary).duplicate(true)
	}

static func _build_unit_from_character(character_id: String, unit_ref: Dictionary, rank: String, unit_index: int, battle_number: int, layer_number: int, encounter_type: String, world_difficulty: int) -> Dictionary:
	var unit_data: Dictionary = character_template(character_id)
	if unit_data.is_empty():
		return {}
	var bonus: Dictionary = _difficulty_bonus(layer_number, battle_number, encounter_type, world_difficulty)
	unit_data["uid"] = "%s_%d_%d" % [str(unit_data.get("id", character_id)), battle_number, unit_index]
	unit_data["unit_rank"] = rank
	unit_data["slot_index"] = int(unit_ref.get("slot_index", 2))
	unit_data["max_hp"] = int(unit_data.get("max_hp", 0)) + int(bonus.get("hp", 0)) + int(unit_ref.get("hp_bonus", 0))
	unit_data["attack"] = int(unit_data.get("attack", 0)) + int(bonus.get("attack", 0)) + int(unit_ref.get("attack_bonus", 0))
	unit_data["defense"] = int(unit_data.get("defense", 0)) + int(bonus.get("defense", 0)) + int(unit_ref.get("defense_bonus", 0))
	unit_data["equipment_limit"] = _equipment_limit_for_rank(rank)
	if character_id == "iron_armor_demon" or character_id == "armor_captain" or character_id == "mirror_guardian":
		unit_data["action_sequence"] = _guard_action_sequence()
	elif character_id == "spell_breaking_demon" or character_id == "hexing_talismanist" or character_id == "chain_cultivator":
		unit_data["action_sequence"] = _spell_action_sequence()
	return unit_data

static func _difficulty_bonus(layer_number: int, battle_number: int, encounter_type: String, world_difficulty: int) -> Dictionary:
	var curve: Dictionary = _curve_for_encounter(encounter_type)
	var layer_index: int = max(0, layer_number - 1)
	var node_step: int = max(0, battle_number - 1)
	var hp: int = _curve_value(curve.get("hp_by_layer", []), layer_index) + int(floor(float(node_step) * float(curve.get("hp_per_node", 0.0))))
	var attack: int = _curve_value(curve.get("attack_by_layer", []), layer_index)
	var attack_step: int = int(curve.get("attack_node_step", 0))
	if attack_step > 0:
		attack += int(node_step / attack_step)
	var defense: int = _curve_value(curve.get("defense_by_layer", []), layer_index)
	if world_difficulty > 0:
		hp += int(world_difficulty * int(curve.get("world_hp", 0)))
		attack += int(floor(float(world_difficulty) * float(curve.get("world_attack", 0.0))))
		defense += int(floor(float(world_difficulty) * float(curve.get("world_defense", 0.0))))
	return {"hp": hp, "attack": attack, "defense": defense}

static func _curve_for_encounter(encounter_type: String) -> Dictionary:
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

static func _curve_value(values: Array, layer_index: int) -> int:
	if values.is_empty():
		return 0
	var index: int = clampi(layer_index, 0, values.size() - 1)
	var result: int = int(values[index])
	if layer_index >= values.size():
		var tail_step: int = max(1, int(values[values.size() - 1]) - int(values[max(0, values.size() - 2)]))
		result += (layer_index - values.size() + 1) * tail_step
	return result

static func _deck_for_world(template: Dictionary, world_difficulty: int) -> Array:
	var result: Array = template.get("deck", []).duplicate()
	for override_variant in template.get(WORLD_DECK_KEY, []):
		var override: Dictionary = override_variant
		if world_difficulty >= int(override.get("min_world", 0)):
			result = override.get("deck", []).duplicate()
	return result

static func _rank_for_encounter(encounter_type: String) -> String:
	match encounter_type:
		"elite":
			return RANK_ELITE
		"boss":
			return RANK_BOSS
	return RANK_NORMAL

static func _default_draw_for_encounter(encounter_type: String) -> int:
	match encounter_type:
		"elite":
			return 2
		"boss":
			return 3
	return 1

static func _equipment_limit_for_rank(rank: String) -> int:
	match rank:
		RANK_ELITE:
			return 2
		RANK_BOSS:
			return 3
	return 1
