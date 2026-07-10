extends RefCounted
class_name DataRegistry

const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")
const CardPoolDatabaseScript = preload("res://scripts/data/CardPoolDatabase.gd")
const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const CharacterDatabaseScript = preload("res://scripts/data/CharacterDatabase.gd")
const EnemyDeckTemplateDatabaseScript = preload("res://scripts/data/EnemyDeckTemplateDatabase.gd")
const EventDatabaseScript = preload("res://scripts/data/EventDatabase.gd")
const ProgressionDatabaseScript = preload("res://scripts/data/ProgressionDatabase.gd")
const StatusDatabaseScript = preload("res://scripts/data/StatusDatabase.gd")
const DifficultyCurveDatabaseScript = preload("res://scripts/data/DifficultyCurveDatabase.gd")
const MapContentDatabaseScript = preload("res://scripts/data/MapContentDatabase.gd")
const WorldDifficultyDatabaseScript = preload("res://scripts/data/WorldDifficultyDatabase.gd")
const VisualAssetDatabaseScript = preload("res://scripts/assets/VisualAssetDatabase.gd")
const CharacterVisualDatabaseScript = preload("res://scripts/assets/CharacterVisualDatabase.gd")
const AudioEventDatabaseScript = preload("res://scripts/audio/AudioEventDatabase.gd")
const LocalizationDatabaseScript = preload("res://scripts/localization/LocalizationDatabase.gd")
const BattleAudioRouterScript = preload("res://scripts/ui/BattleAudioRouter.gd")


static func snapshot() -> Dictionary:
	return {
		"cards": _dictionary_values(CardDefinitionDatabaseScript.get_cards()),
		"active_card_ids": CardDefinitionDatabaseScript.active_card_ids(),
		"card_unlock_packs": CardPoolDatabaseScript.CARD_UNLOCK_PACKS.duplicate(true),
		"jobs": JobDatabaseScript.job_definitions(),
		"characters": _dictionary_values(CharacterDatabaseScript.character_templates()),
		"enemy_deck_templates": EnemyDeckTemplateDatabaseScript.deck_templates() + EnemyDeckTemplateDatabaseScript.candidate_deck_templates(),
		"events": EventDatabaseScript.event_definitions(),
		"progressions": ProgressionDatabaseScript.progression_definitions(),
		"statuses": StatusDatabaseScript.all_definitions(),
		"difficulty_curves": DifficultyCurveDatabaseScript.definitions(),
		"map_layouts": MapContentDatabaseScript.layout_definitions(),
		"treasures": MapContentDatabaseScript.treasure_definitions(),
		"world_difficulties": WorldDifficultyDatabaseScript.definitions(),
		"visual_assets": _dictionary_values(VisualAssetDatabaseScript.asset_definitions()),
		"character_visual_profiles": _dictionary_values(CharacterVisualDatabaseScript.visual_profiles()),
		"audio_events": _dictionary_values(AudioEventDatabaseScript.event_definitions()),
		"battle_audio_event_ids": BattleAudioRouterScript.routed_audio_event_ids(),
		"visual_fallback_ids": VisualAssetDatabaseScript.fallback_asset_ids(),
		"character_visual_default_profile_id": CharacterVisualDatabaseScript.DEFAULT_PROFILE_ID,
		"languages": _dictionary_values(LocalizationDatabaseScript.language_definitions()),
		"localization_entries": LocalizationDatabaseScript.text_entries().duplicate(true),
		"required_localization_keys": LocalizationDatabaseScript.REQUIRED_SCREEN_TEXT_IDS.duplicate()
	}


static func source_names() -> Array:
	return snapshot().keys()


static func _dictionary_values(values: Dictionary) -> Array:
	var result: Array = []
	for value_variant in values.values():
		if value_variant is Dictionary:
			result.append((value_variant as Dictionary).duplicate(true))
	return result
