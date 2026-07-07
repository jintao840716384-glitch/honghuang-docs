extends RefCounted
class_name SettingsStore

const GameSettingsScript = preload("res://scripts/settings/GameSettings.gd")
const SaveMigrationServiceScript = preload("res://scripts/save/SaveMigrationService.gd")
const InputSettingsScript = preload("res://scripts/settings/InputSettings.gd")

const SETTINGS_PATH := "user://settings.cfg"

static func default_settings() -> Dictionary:
	return GameSettingsScript.default_data()

static func load_settings(path := SETTINGS_PATH) -> Dictionary:
	var settings: Dictionary = default_settings()
	var config := ConfigFile.new()
	if not FileAccess.file_exists(path):
		return settings
	var err := config.load(path)
	if err != OK:
		return settings
	var source_version: int = SaveMigrationServiceScript.config_schema_version(config, SaveMigrationServiceScript.SAVE_KIND_SETTINGS)
	for section in settings.keys():
		var section_data: Dictionary = settings[section]
		for key in section_data.keys():
			if config.has_section_key(str(section), str(key)):
				section_data[key] = config.get_value(str(section), str(key), section_data[key])
		settings[section] = section_data
	return SaveMigrationServiceScript.migrate_settings(settings, source_version)

static func save_settings(settings: Dictionary, path := SETTINGS_PATH) -> int:
	var sanitized: Dictionary = GameSettingsScript.sanitize(settings)
	var config := ConfigFile.new()
	SaveMigrationServiceScript.apply_config_metadata(config, SaveMigrationServiceScript.SAVE_KIND_SETTINGS)
	for section in sanitized.keys():
		var section_data: Dictionary = sanitized[section]
		for key in section_data.keys():
			config.set_value(str(section), str(key), section_data[key])
	return config.save(path)

static func set_audio_volume(settings: Dictionary, volume_key: String, value: float) -> Dictionary:
	var result: Dictionary = GameSettingsScript.sanitize(settings)
	var audio: Dictionary = result.get("audio", {})
	if audio.has(volume_key):
		audio[volume_key] = clamp(value, 0.0, 1.0)
	result["audio"] = audio
	return result

static func set_display_mode(settings: Dictionary, resolution_id: String, window_mode: String) -> Dictionary:
	var result: Dictionary = GameSettingsScript.sanitize(settings)
	var display: Dictionary = result.get("display", {})
	display["resolution_id"] = resolution_id
	display["window_mode"] = window_mode
	result["display"] = display
	return GameSettingsScript.sanitize(result)

static func set_language_id(settings: Dictionary, language_id: String) -> Dictionary:
	var result: Dictionary = GameSettingsScript.sanitize(settings)
	var localization: Dictionary = result.get("localization", {})
	localization["language_id"] = language_id
	result["localization"] = localization
	return GameSettingsScript.sanitize(result)

static func set_action_binding(settings: Dictionary, action_id: String, event_spec: Dictionary) -> Dictionary:
	return GameSettingsScript.sanitize(InputSettingsScript.with_primary_binding(settings, action_id, event_spec))

static func reset_action_binding(settings: Dictionary, action_id: String) -> Dictionary:
	return GameSettingsScript.sanitize(InputSettingsScript.with_default_binding(settings, action_id))
