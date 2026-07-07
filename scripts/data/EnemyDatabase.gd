extends RefCounted
class_name EnemyDatabase

const CharacterDatabaseScript = preload("res://scripts/data/CharacterDatabase.gd")
const EnemyDeckTemplateDatabaseScript = preload("res://scripts/data/EnemyDeckTemplateDatabase.gd")
const EncounterFactoryScript = preload("res://scripts/data/EncounterFactory.gd")

const RANK_NORMAL := "normal"
const RANK_ELITE := "elite"
const RANK_BOSS := "boss"
const WORLD_DECK_KEY := "world_deck_overrides"


static func character_templates() -> Dictionary:
	return CharacterDatabaseScript.character_templates()


static func character_template(character_id: String) -> Dictionary:
	return CharacterDatabaseScript.character_template(character_id)


static func deck_templates_for(layer_number: int, encounter_type := "normal", world_difficulty := 0) -> Array:
	return EnemyDeckTemplateDatabaseScript.deck_templates_for(layer_number, encounter_type, world_difficulty)


static func get_encounter_for_battle(battle_number: int, encounter_type := "normal", story_layer_index := 0, world_difficulty := 0, rng: RandomNumberGenerator = null) -> Dictionary:
	return EncounterFactoryScript.get_encounter_for_battle(battle_number, encounter_type, story_layer_index, world_difficulty, rng)


static func get_enemy_for_battle(battle_number: int) -> Dictionary:
	var encounter: Dictionary = get_encounter_for_battle(battle_number, "normal", 0, 0, null)
	return (encounter.get("primary_enemy", {}) as Dictionary).duplicate(true)
