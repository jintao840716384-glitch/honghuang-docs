extends RefCounted
class_name SettingsStore

const GameSettingsScript = preload("res://scripts/settings/GameSettings.gd")
const SaveStoreScript = preload("res://scripts/save/SaveStore.gd")
const InputSettingsScript = preload("res://scripts/settings/InputSettings.gd")

const SETTINGS_PATH := SaveStoreScript.SETTINGS_PATH

static func default_settings() -> Dictionary:
	return GameSettingsScript.default_data()

static func load_settings(path := SETTINGS_PATH) -> Dictionary:
	return SaveStoreScript.load_settings(default_settings(), path)

static func save_settings(settings: Dictionary, path := SETTINGS_PATH) -> int:
	var sanitized: Dictionary = GameSettingsScript.sanitize(settings)
	return SaveStoreScript.save_settings(sanitized, path)

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
