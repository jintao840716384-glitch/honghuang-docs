extends RefCounted
class_name EnemyDeckTemplateDatabase

const WORLD_DECK_KEY := "world_deck_overrides"
const CONTENT_STATE_ACTIVE := "active"
const CONTENT_STATE_PROTOTYPE := "prototype"


static func deck_templates() -> Array:
	return [
		_deck_template("l1_normal_break_prep", 1, "normal", ["blank_card", "blank_card", "break_defense_setup"], ["mountain_demon"], ["第一版", "削弱教学"]),
		_deck_template("l1_normal_weaken_prep", 1, "normal", ["blank_card", "blank_card", "weaken_attack_setup"], ["spell_breaking_demon"], ["第一版", "削攻教学"]),
		_deck_template("l1_normal_poison", 1, "normal", ["blank_card", "blank_card", "poison"], ["cliff_bandit"], ["第一版", "中毒教学"]),
		_deck_template("l1_elite_heal_break", 1, "elite", ["blank_card", "blank_card", "heal_wound", "break_defense_setup"], ["iron_armor_demon"], ["第一版", "治疗", "破防"]),
		_deck_template("l1_elite_poison_weaken", 1, "elite", ["blank_card", "blank_card", "poison", "weaken_attack_setup"], ["spell_breaking_demon"], ["第一版", "中毒", "削攻"]),
		_deck_template("l1_elite_guard_cleanse", 1, "elite", ["blank_card", "blank_card", "defense_setup", "clear_buff"], ["cliff_bandit"], ["第一版", "防御", "解除"]),
		_deck_template("l1_boss_stone_guardian", 1, "boss", ["blank_card", "blank_card", "break_defense_setup", "weaken_attack_setup", "poison", "heal_wound"], ["stone_guardian"], ["第一版", "首领", "组合"]),
		_deck_template("l1_boss_hexing_talismanist", 1, "boss", ["blank_card", "blank_card", "weaken_attack_setup", "poison", "heal_wound", "clear_buff"], ["hexing_talismanist"], ["第一版", "首领", "削弱"]),
		_deck_template("l1_boss_ember_adept", 1, "boss", ["blank_card", "blank_card", "break_defense_setup", "poison", "defense_setup", "heal_wound"], ["ember_adept"], ["第一版", "首领", "持续"]),
		_deck_template("l2_normal_break_prep", 2, "normal", ["blank_card", "break_defense_setup", "weaken_attack_setup"], ["mountain_demon"], ["第一版", "第二层", "削弱"]),
		_deck_template("l2_normal_heal_guard", 2, "normal", ["blank_card", "heal_wound", "defense_setup"], ["iron_armor_demon"], ["第一版", "第二层", "防御"]),
		_deck_template("l2_normal_poison_weaken", 2, "normal", ["blank_card", "poison", "weaken_attack_setup"], ["cliff_bandit"], ["第一版", "第二层", "中毒"]),
		_deck_template("l2_elite_break_heal", 2, "elite", ["blank_card", "break_defense_setup", "weaken_attack_setup", "heal_wound"], ["spell_breaking_demon"], ["第一版", "精英", "削弱"]),
		_deck_template("l2_elite_guard_cleanse", 2, "elite", ["blank_card", "defense_setup", "clear_buff", "heal_wound"], ["iron_armor_demon"], ["第一版", "精英", "对策"]),
		_deck_template("l2_elite_poison_break", 2, "elite", ["blank_card", "poison", "break_defense_setup", "weaken_attack_setup"], ["cliff_bandit"], ["第一版", "精英", "持续"]),
		_deck_template("l2_boss_armor_captain", 2, "boss", ["blank_card", "break_defense_setup", "weaken_attack_setup", "defense_setup", "heal_wound", "clear_buff"], ["armor_captain"], ["第一版", "首领", "防御"]),
		_deck_template("l2_boss_draining_shaman", 2, "boss", ["blank_card", "weaken_attack_setup", "poison", "heal_wound", "clear_buff", "break_defense_setup"], ["draining_shaman"], ["第一版", "首领", "削弱"]),
		_deck_template("l2_boss_thunder_apprentice", 2, "boss", ["blank_card", "poison", "break_defense_setup", "weaken_attack_setup", "heal_wound", "defense_setup"], ["thunder_apprentice"], ["第一版", "首领", "压迫"]),
		_deck_template("l3_normal_break_chain", 3, "normal", ["break_defense_setup", "weaken_attack_setup", "defense_setup"], ["spell_breaking_demon"], ["第一版", "第三层", "削弱"]),
		_deck_template("l3_normal_poison_chain", 3, "normal", ["poison", "weaken_attack_setup", "blank_card"], ["cliff_bandit"], ["第一版", "第三层", "中毒"]),
		_deck_template("l3_normal_guard_chain", 3, "normal", ["defense_setup", "heal_wound", "break_defense_setup"], ["iron_armor_demon"], ["第一版", "第三层", "防御"]),
		_deck_template("l3_elite_control", 3, "elite", ["break_defense_setup", "weaken_attack_setup", "poison", "heal_wound"], ["spell_breaking_demon"], ["第一版", "精英", "控制"]),
		_deck_template("l3_elite_guard", 3, "elite", ["defense_setup", "clear_buff", "heal_wound", "weaken_attack_setup"], ["iron_armor_demon"], ["第一版", "精英", "防御"]),
		_deck_template("l3_elite_pressure", 3, "elite", ["poison", "break_defense_setup", "weaken_attack_setup", "clear_buff"], ["cliff_bandit"], ["第一版", "精英", "压迫"]),
		_deck_template("l3_boss_mountain_warlord", 3, "boss", ["break_defense_setup", "weaken_attack_setup", "poison", "heal_wound", "defense_setup", "clear_buff"], ["mountain_warlord"], ["第一版", "首领", "综合"]),
		_deck_template("l3_boss_mirror_guardian", 3, "boss", ["defense_setup", "clear_buff", "heal_wound", "break_defense_setup", "weaken_attack_setup", "poison"], ["mirror_guardian"], ["第一版", "首领", "防御"]),
		_deck_template("l3_boss_chain_cultivator", 3, "boss", ["weaken_attack_setup", "break_defense_setup", "poison", "clear_buff", "heal_wound", "defense_setup"], ["chain_cultivator"], ["第一版", "首领", "控制"])
	]


static func candidate_deck_templates() -> Array:
	return [
		_inactive_deck_template("l1_candidate_normal_weaken", 1, "normal", ["blank_card", "blank_card", "blank_card", "blank_card", "break_defense_setup", "weaken_attack_setup"], ["mountain_demon"], ["候选", "第一层", "削弱教学"]),
		_inactive_deck_template("l1_candidate_elite_heal", 1, "elite", ["blank_card", "blank_card", "blank_card", "heal_wound", "defense_setup", "break_defense_setup"], ["cliff_bandit"], ["候选", "第一层", "回血教学"]),
		_inactive_deck_template("l1_candidate_boss_mix", 1, "boss", ["blank_card", "blank_card", "break_defense_setup", "weaken_attack_setup", "heal_wound", "poison", "clear_buff"], ["hexing_talismanist"], ["候选", "第一层", "组合教学"])
	]


static func deck_templates_for(layer_number: int, encounter_type := "normal", world_difficulty := 0) -> Array:
	var result: Array = []
	for template_variant in deck_templates():
		var template: Dictionary = template_variant
		if str(template.get("content_state", "")) != CONTENT_STATE_ACTIVE:
			continue
		if int(template.get("layer", 1)) != max(1, layer_number):
			continue
		if str(template.get("encounter_type", "normal")) != encounter_type:
			continue
		if int(template.get("min_world", 0)) > world_difficulty:
			continue
		result.append(template.duplicate(true))
	return result


static func _inactive_deck_template(template_id: String, layer_number: int, encounter_type: String, deck: Array, character_ids: Array, tags: Array) -> Dictionary:
	var template := _deck_template(template_id, layer_number, encounter_type, deck, character_ids, tags)
	template["content_state"] = CONTENT_STATE_PROTOTYPE
	template["enabled"] = false
	template["candidate"] = true
	return template


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
		"content_state": CONTENT_STATE_ACTIVE,
		"template_kind": "enemy_deck_template",
		"layer": layer_number,
		"encounter_type": encounter_type,
		"deck": deck.duplicate(),
		"character_refs": character_refs,
		"draw_per_turn": draw_count,
		"theme_tags": tags.duplicate(),
		"enabled": true,
		WORLD_DECK_KEY: []
	}
