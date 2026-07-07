extends RefCounted
class_name SaveMigrationService

const GameSettingsScript = preload("res://scripts/settings/GameSettings.gd")

const SAVE_KIND_SETTINGS := "settings"
const SAVE_KIND_META_PROGRESSION := "meta_progression"
const META_SECTION := "_meta"
const KEY_SAVE_KIND := "save_kind"
const KEY_SCHEMA_VERSION := "schema_version"

const CURRENT_SETTINGS_VERSION := 1
const CURRENT_META_PROGRESSION_VERSION := 2

static func current_version(save_kind: String) -> int:
	match save_kind:
		SAVE_KIND_SETTINGS:
			return CURRENT_SETTINGS_VERSION
		SAVE_KIND_META_PROGRESSION:
			return CURRENT_META_PROGRESSION_VERSION
	return 1

static func metadata_for(save_kind: String) -> Dictionary:
	return {
		KEY_SAVE_KIND: save_kind,
		KEY_SCHEMA_VERSION: current_version(save_kind)
	}

static func apply_config_metadata(config: ConfigFile, save_kind: String) -> void:
	var metadata: Dictionary = metadata_for(save_kind)
	for key_variant in metadata.keys():
		var key := str(key_variant)
		config.set_value(META_SECTION, key, metadata.get(key))

static func config_schema_version(config: ConfigFile, save_kind: String) -> int:
	var kind := str(config.get_value(META_SECTION, KEY_SAVE_KIND, save_kind))
	if kind != save_kind:
		return 0
	return int(config.get_value(META_SECTION, KEY_SCHEMA_VERSION, 0))

static func migrate_settings(settings: Dictionary, _source_version := 0) -> Dictionary:
	return GameSettingsScript.sanitize(settings)

static func default_meta_progression_data() -> Dictionary:
	return {
		"version": CURRENT_META_PROGRESSION_VERSION,
		"jobs": {}
	}

static func migrate_meta_progression(source: Dictionary) -> Dictionary:
	var result: Dictionary = default_meta_progression_data()
	var jobs_source: Dictionary = (source.get("jobs", {}) as Dictionary)
	var jobs_result: Dictionary = {}
	for job_id_variant in jobs_source.keys():
		var job_id := str(job_id_variant)
		var job_source: Dictionary = (jobs_source.get(job_id, {}) as Dictionary)
		jobs_result[job_id] = _migrate_job_progression(job_source)
	result["jobs"] = jobs_result
	return result

static func _migrate_job_progression(job_source: Dictionary) -> Dictionary:
	var upgrades: Dictionary = {}
	var upgrades_source: Dictionary = (job_source.get("upgrades", {}) as Dictionary)
	for upgrade_id_variant in upgrades_source.keys():
		var upgrade_id := str(upgrade_id_variant)
		upgrades[upgrade_id] = max(0, int(upgrades_source.get(upgrade_id, 0)))
	return {
		"points_total": max(0, int(job_source.get("points_total", 0))),
		"points_spent": max(0, int(job_source.get("points_spent", 0))),
		"upgrades": upgrades
	}
