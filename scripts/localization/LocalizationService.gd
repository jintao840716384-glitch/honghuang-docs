extends RefCounted
class_name LocalizationService

const LocalizationDatabaseScript = preload("res://scripts/localization/LocalizationDatabase.gd")

static func language_from_settings(settings: Dictionary) -> String:
	var localization: Dictionary = (settings.get("localization", {}) as Dictionary)
	return LocalizationDatabaseScript.normalized_language_id(str(localization.get("language_id", LocalizationDatabaseScript.DEFAULT_LANGUAGE_ID)))

static func text(text_id: String, language_id: String, params: Dictionary = {}) -> String:
	var value := LocalizationDatabaseScript.text(text_id, language_id)
	return format_text(value, params)

static func text_for_settings(text_id: String, settings: Dictionary, params: Dictionary = {}) -> String:
	return text(text_id, language_from_settings(settings), params)

static func format_text(value: String, params: Dictionary) -> String:
	var result := value
	for key_variant in params.keys():
		var key := str(key_variant)
		result = result.replace("{%s}" % key, str(params[key_variant]))
	return result
