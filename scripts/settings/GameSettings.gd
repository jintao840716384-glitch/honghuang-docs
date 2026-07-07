extends RefCounted
class_name GameSettings

const LocalizationDatabaseScript = preload("res://scripts/localization/LocalizationDatabase.gd")

const WINDOW_MODE_WINDOWED := "windowed"
const WINDOW_MODE_FULLSCREEN := "fullscreen"
const WINDOW_MODE_BORDERLESS_FULLSCREEN := "borderless_fullscreen"

const DEFAULT_RESOLUTION_ID := "1920x1080"
const DEFAULT_WINDOW_MODE := WINDOW_MODE_WINDOWED
const DEFAULT_MASTER_VOLUME := 0.85
const DEFAULT_MUSIC_VOLUME := 0.75
const DEFAULT_SFX_VOLUME := 0.85
const DEFAULT_VSYNC_ENABLED := true
const DEFAULT_ANIMATION_SPEED := 1.0
const DEFAULT_REDUCE_MOTION := false
const DEFAULT_REDUCE_FLASH := false
const DEFAULT_TEXT_SCALE := 1.0
const DEFAULT_LANGUAGE_ID := LocalizationDatabaseScript.DEFAULT_LANGUAGE_ID

static func default_data() -> Dictionary:
	return {
		"display": {
			"resolution_id": DEFAULT_RESOLUTION_ID,
			"window_mode": DEFAULT_WINDOW_MODE,
			"vsync_enabled": DEFAULT_VSYNC_ENABLED
		},
		"audio": {
			"master_volume": DEFAULT_MASTER_VOLUME,
			"music_volume": DEFAULT_MUSIC_VOLUME,
			"sfx_volume": DEFAULT_SFX_VOLUME
		},
		"gameplay": {
			"animation_speed": DEFAULT_ANIMATION_SPEED
		},
		"accessibility": {
			"reduce_motion": DEFAULT_REDUCE_MOTION,
			"reduce_flash": DEFAULT_REDUCE_FLASH,
			"text_scale": DEFAULT_TEXT_SCALE
		},
		"localization": {
			"language_id": DEFAULT_LANGUAGE_ID
		},
		"input": {
			"bindings": {}
		}
	}

static func sanitize(settings: Dictionary) -> Dictionary:
	var result: Dictionary = default_data()
	var display: Dictionary = (settings.get("display", {}) as Dictionary)
	var audio: Dictionary = (settings.get("audio", {}) as Dictionary)
	var gameplay: Dictionary = (settings.get("gameplay", {}) as Dictionary)
	var accessibility: Dictionary = (settings.get("accessibility", {}) as Dictionary)
	var localization: Dictionary = (settings.get("localization", {}) as Dictionary)
	var input: Dictionary = (settings.get("input", {}) as Dictionary)
	result["display"] = {
		"resolution_id": str(display.get("resolution_id", DEFAULT_RESOLUTION_ID)),
		"window_mode": _valid_window_mode(str(display.get("window_mode", DEFAULT_WINDOW_MODE))),
		"vsync_enabled": bool(display.get("vsync_enabled", DEFAULT_VSYNC_ENABLED))
	}
	result["audio"] = {
		"master_volume": _volume(audio.get("master_volume", DEFAULT_MASTER_VOLUME)),
		"music_volume": _volume(audio.get("music_volume", DEFAULT_MUSIC_VOLUME)),
		"sfx_volume": _volume(audio.get("sfx_volume", DEFAULT_SFX_VOLUME))
	}
	result["gameplay"] = {
		"animation_speed": clamp(float(gameplay.get("animation_speed", DEFAULT_ANIMATION_SPEED)), 0.25, 3.0)
	}
	result["accessibility"] = {
		"reduce_motion": bool(accessibility.get("reduce_motion", DEFAULT_REDUCE_MOTION)),
		"reduce_flash": bool(accessibility.get("reduce_flash", DEFAULT_REDUCE_FLASH)),
		"text_scale": clamp(float(accessibility.get("text_scale", DEFAULT_TEXT_SCALE)), 0.85, 1.35)
	}
	result["localization"] = {
		"language_id": LocalizationDatabaseScript.normalized_language_id(str(localization.get("language_id", DEFAULT_LANGUAGE_ID)))
	}
	result["input"] = {
		"bindings": (input.get("bindings", {}) as Dictionary).duplicate(true)
	}
	return result

static func display_settings(settings: Dictionary) -> Dictionary:
	return (sanitize(settings).get("display", {}) as Dictionary).duplicate(true)

static func audio_settings(settings: Dictionary) -> Dictionary:
	return (sanitize(settings).get("audio", {}) as Dictionary).duplicate(true)

static func gameplay_settings(settings: Dictionary) -> Dictionary:
	return (sanitize(settings).get("gameplay", {}) as Dictionary).duplicate(true)

static func accessibility_settings(settings: Dictionary) -> Dictionary:
	return (sanitize(settings).get("accessibility", {}) as Dictionary).duplicate(true)

static func localization_settings(settings: Dictionary) -> Dictionary:
	return (sanitize(settings).get("localization", {}) as Dictionary).duplicate(true)

static func _volume(value) -> float:
	return clamp(float(value), 0.0, 1.0)

static func _valid_window_mode(value: String) -> String:
	if value == WINDOW_MODE_FULLSCREEN or value == WINDOW_MODE_BORDERLESS_FULLSCREEN:
		return value
	return WINDOW_MODE_WINDOWED
