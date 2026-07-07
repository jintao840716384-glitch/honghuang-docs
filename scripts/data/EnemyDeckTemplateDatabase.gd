extends RefCounted
class_name EnemyDeckTemplateDatabase

const WORLD_DECK_KEY := "world_deck_overrides"


static func deck_templates() -> Array:
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


static func deck_templates_for(layer_number: int, encounter_type := "normal", world_difficulty := 0) -> Array:
	var result: Array = []
	for template_variant in deck_templates():
		var template: Dictionary = template_variant
		if int(template.get("layer", 1)) != max(1, layer_number):
			continue
		if str(template.get("encounter_type", "normal")) != encounter_type:
			continue
		if int(template.get("min_world", 0)) > world_difficulty:
			continue
		result.append(template.duplicate(true))
	return result


static func fallback_deck_template(encounter_type: String) -> Dictionary:
	return _deck_template("fallback_%s" % encounter_type, 1, encounter_type, [], ["mountain_demon"], ["fallback"])


static func deck_for_world(template: Dictionary, world_difficulty: int) -> Array:
	var result: Array = template.get("deck", []).duplicate()
	for override_variant in template.get(WORLD_DECK_KEY, []):
		var override: Dictionary = override_variant
		if world_difficulty >= int(override.get("min_world", 0)):
			result = override.get("deck", []).duplicate()
	return result


static func default_draw_for_encounter(encounter_type: String) -> int:
	match encounter_type:
		"elite":
			return 2
		"boss":
			return 3
	return 1


static func _deck_template(template_id: String, layer_number: int, encounter_type: String, deck: Array, character_ids: Array, tags: Array) -> Dictionary:
	var character_refs: Array = []
	var slots: Array = [2, 1, 3]
	for i in range(character_ids.size()):
		character_refs.append({
			"character_id": str(character_ids[i]),
			"slot_index": int(slots[i % slots.size()])
		})
	var draw_count: int = default_draw_for_encounter(encounter_type)
	return {
		"id": template_id,
		"deck_template_id": template_id,
		"template_kind": "enemy_deck_template",
		"layer": layer_number,
		"encounter_type": encounter_type,
		"deck": deck.duplicate(),
		"character_refs": character_refs,
		"draw_per_turn": draw_count,
		"card_play_limit": draw_count,
		"theme_tags": tags.duplicate(),
		WORLD_DECK_KEY: []
	}
