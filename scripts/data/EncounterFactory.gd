extends RefCounted
class_name EncounterFactory

const CharacterDatabaseScript = preload("res://scripts/data/CharacterDatabase.gd")
const EnemyDeckTemplateDatabaseScript = preload("res://scripts/data/EnemyDeckTemplateDatabase.gd")
const DifficultyCurveDatabaseScript = preload("res://scripts/data/DifficultyCurveDatabase.gd")
const WorldDifficultyDatabaseScript = preload("res://scripts/data/WorldDifficultyDatabase.gd")

const RANK_NORMAL := "normal"
const RANK_ELITE := "elite"
const RANK_BOSS := "boss"


static func get_encounter_for_battle(battle_number: int, encounter_type := "normal", story_layer_index := 0, world_difficulty := 0, rng: RandomNumberGenerator = null) -> Dictionary:
	if not WorldDifficultyDatabaseScript.is_active_value(world_difficulty):
		return {}
	var layer_number: int = max(1, int(story_layer_index) + 1)
	var templates: Array = EnemyDeckTemplateDatabaseScript.deck_templates_for(layer_number, encounter_type, world_difficulty)
	if templates.is_empty():
		templates = EnemyDeckTemplateDatabaseScript.deck_templates_for(1, encounter_type, world_difficulty)
	if templates.is_empty():
		templates = EnemyDeckTemplateDatabaseScript.deck_templates_for(1, "normal", world_difficulty)
	var selected: Dictionary = {}
	if templates.is_empty():
		return {}
	elif rng == null:
		selected = (templates[0] as Dictionary).duplicate(true)
	else:
		selected = (templates[rng.randi_range(0, templates.size() - 1)] as Dictionary).duplicate(true)
	return build_encounter(selected, max(1, battle_number), layer_number, encounter_type, max(0, world_difficulty))


static func build_encounter(template: Dictionary, battle_number: int, layer_number: int, encounter_type: String, world_difficulty: int) -> Dictionary:
	var rank: String = _rank_for_encounter(encounter_type)
	var units: Array = []
	var unit_refs: Array = template.get("character_refs", template.get("units", []))
	for i in range(unit_refs.size()):
		var unit_ref: Dictionary = unit_refs[i]
		var character_id: String = str(unit_ref.get("character_id", "mountain_demon"))
		var unit_data: Dictionary = _build_unit_from_character(character_id, unit_ref, rank, i, battle_number, layer_number, encounter_type, world_difficulty)
		if not unit_data.is_empty():
			units.append(unit_data)
	if units.is_empty():
		units.append(_build_unit_from_character("mountain_demon", {"slot_index": 2}, rank, 0, battle_number, layer_number, encounter_type, world_difficulty))
	var deck: Array = EnemyDeckTemplateDatabaseScript.deck_for_world(template, world_difficulty)
	var base_draw_count: int = int(template.get("draw_per_turn", EnemyDeckTemplateDatabaseScript.default_draw_for_encounter(encounter_type)))
	var draw_count: int = max(0, base_draw_count + DifficultyCurveDatabaseScript.draw_bonus(layer_number, encounter_type, world_difficulty))
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
		"enemy_units": units,
		"primary_enemy": (units[0] as Dictionary).duplicate(true)
	}


static func _build_unit_from_character(character_id: String, unit_ref: Dictionary, rank: String, unit_index: int, battle_number: int, layer_number: int, encounter_type: String, world_difficulty: int) -> Dictionary:
	var unit_data: Dictionary = CharacterDatabaseScript.character_template(character_id)
	if unit_data.is_empty():
		return {}
	var bonus: Dictionary = DifficultyCurveDatabaseScript.difficulty_bonus(layer_number, battle_number, encounter_type, world_difficulty)
	unit_data["uid"] = "%s_%d_%d" % [str(unit_data.get("id", character_id)), battle_number, unit_index]
	unit_data["unit_rank"] = rank
	unit_data["slot_index"] = int(unit_ref.get("slot_index", 2))
	unit_data["max_hp"] = int(unit_data.get("max_hp", 0)) + int(bonus.get("hp", 0)) + int(unit_ref.get("hp_bonus", 0))
	unit_data["attack"] = int(unit_data.get("attack", 0)) + int(bonus.get("attack", 0)) + int(unit_ref.get("attack_bonus", 0))
	unit_data["defense"] = int(unit_data.get("defense", 0)) + int(bonus.get("defense", 0)) + int(unit_ref.get("defense_bonus", 0))
	unit_data["equipment_limit"] = _equipment_limit_for_rank(rank)
	unit_data["action_sequence"] = CharacterDatabaseScript.action_sequence_for_character(character_id)
	return unit_data


static func _rank_for_encounter(encounter_type: String) -> String:
	match encounter_type:
		"elite":
			return RANK_ELITE
		"boss":
			return RANK_BOSS
	return RANK_NORMAL


static func _equipment_limit_for_rank(rank: String) -> int:
	match rank:
		RANK_ELITE:
			return 2
		RANK_BOSS:
			return 3
	return 1
