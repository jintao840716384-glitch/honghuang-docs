extends RefCounted
class_name SaveStore

const SaveMigrationServiceScript = preload("res://scripts/save/SaveMigrationService.gd")

const SETTINGS_PATH := "user://settings.cfg"
const PROGRESSION_PATH := "user://progression.json"


static func load_settings(defaults: Dictionary, path := SETTINGS_PATH) -> Dictionary:
	var config := ConfigFile.new()
	if not FileAccess.file_exists(path):
		return defaults.duplicate(true)
	var err := config.load(path)
	if err != OK:
		return defaults.duplicate(true)
	var result := defaults.duplicate(true)
	for section_variant in result.keys():
		var section := str(section_variant)
		var section_data: Dictionary = result.get(section, {})
		for key_variant in section_data.keys():
			var key := str(key_variant)
			if config.has_section_key(section, key):
				section_data[key] = config.get_value(section, key, section_data[key])
		result[section] = section_data
	var source_version := SaveMigrationServiceScript.config_schema_version(config, SaveMigrationServiceScript.SAVE_KIND_SETTINGS)
	return SaveMigrationServiceScript.migrate_settings(result, source_version)


static func save_settings(settings: Dictionary, path := SETTINGS_PATH) -> int:
	var config := ConfigFile.new()
	SaveMigrationServiceScript.apply_config_metadata(config, SaveMigrationServiceScript.SAVE_KIND_SETTINGS)
	for section_variant in settings.keys():
		var section := str(section_variant)
		var section_data: Dictionary = settings.get(section, {})
		for key_variant in section_data.keys():
			var key := str(key_variant)
			config.set_value(section, key, section_data[key])
	return config.save(path)


static func load_progression(path := PROGRESSION_PATH) -> Dictionary:
	var defaults := SaveMigrationServiceScript.default_meta_progression_data()
	if not FileAccess.file_exists(path):
		return defaults
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return defaults
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return defaults
	return SaveMigrationServiceScript.migrate_meta_progression(parsed as Dictionary)


static func save_progression(data: Dictionary, path := PROGRESSION_PATH) -> bool:
	var migrated := SaveMigrationServiceScript.migrate_meta_progression(data)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(migrated, "\t"))
	return true
