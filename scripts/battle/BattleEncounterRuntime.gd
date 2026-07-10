extends RefCounted
class_name BattleEncounterRuntime

const EncounterFactoryScript = preload("res://scripts/data/EncounterFactory.gd")


static func select_encounter(battle_number: int, encounter_type: String, story_layer_index: int, world_difficulty: int, rng: RandomNumberGenerator = null) -> Dictionary:
	return EncounterFactoryScript.get_encounter_for_battle(
		battle_number,
		encounter_type,
		story_layer_index,
		world_difficulty,
		rng
	)


static func primary_enemy_data(encounter_profile: Dictionary, battle_number: int) -> Dictionary:
	var data: Dictionary = encounter_profile.get("primary_enemy", {})
	if data.is_empty():
		var fallback: Dictionary = select_encounter(battle_number, "normal", 0, 0, null)
		data = fallback.get("primary_enemy", {})
	return data.duplicate(true)


static func deck_profile(encounter_profile: Dictionary) -> Dictionary:
	return {
		"id": str(encounter_profile.get("deck_template_id", encounter_profile.get("id", "empty"))),
		"deck_template_id": str(encounter_profile.get("deck_template_id", encounter_profile.get("id", "empty"))),
		"deck": encounter_profile.get("deck", []).duplicate(),
		"theme_tags": encounter_profile.get("theme_tags", []).duplicate()
	}


static func enemy_deck(encounter_profile: Dictionary) -> Array:
	var profile: Dictionary = deck_profile(encounter_profile)
	return profile.get("deck", []).duplicate()


static func draw_per_turn(encounter_profile: Dictionary, encounter_type: String) -> int:
	if not encounter_profile.is_empty():
		return max(0, int(encounter_profile.get("draw_per_turn", 1)))
	match encounter_type:
		"boss":
			return 2
	return 1
