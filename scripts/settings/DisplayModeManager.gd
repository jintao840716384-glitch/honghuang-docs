extends RefCounted
class_name DisplayModeManager

const GameSettingsScript = preload("res://scripts/settings/GameSettings.gd")

const ASPECT_POLICY := "keep_aspect_letterbox"
const BASE_RESOLUTION_ID := "1920x1080"
const BASE_SIZE := Vector2i(1920, 1080)

static func supported_resolutions() -> Array:
	return [
		_resolution("1280x720", 1280, 720, "720p"),
		_resolution("1600x900", 1600, 900, "900p"),
		_resolution("1920x1080", 1920, 1080, "1080p"),
		_resolution("2560x1440", 2560, 1440, "1440p"),
		_resolution("3840x2160", 3840, 2160, "2160p")
	]

static func resolution_ids() -> Array:
	var result: Array = []
	for definition_variant in supported_resolutions():
		var definition: Dictionary = definition_variant
		result.append(str(definition.get("id", "")))
	return result

static func resolution_for_id(resolution_id: String) -> Dictionary:
	for definition_variant in supported_resolutions():
		var definition: Dictionary = definition_variant
		if str(definition.get("id", "")) == resolution_id:
			return definition.duplicate(true)
	return _resolution(BASE_RESOLUTION_ID, BASE_SIZE.x, BASE_SIZE.y, "1080p")

static func resolution_size(resolution_id: String) -> Vector2i:
	var definition: Dictionary = resolution_for_id(resolution_id)
	return Vector2i(int(definition.get("width", BASE_SIZE.x)), int(definition.get("height", BASE_SIZE.y)))

static func normalized_display_settings(settings: Dictionary) -> Dictionary:
	var display: Dictionary = GameSettingsScript.display_settings(settings)
	var resolution_id := str(display.get("resolution_id", BASE_RESOLUTION_ID))
	if not resolution_ids().has(resolution_id):
		resolution_id = BASE_RESOLUTION_ID
	display["resolution_id"] = resolution_id
	display["aspect_policy"] = ASPECT_POLICY
	display["base_resolution_id"] = BASE_RESOLUTION_ID
	return display

static func scale_for_resolution(resolution_id: String) -> float:
	var size := resolution_size(resolution_id)
	return min(float(size.x) / float(BASE_SIZE.x), float(size.y) / float(BASE_SIZE.y))

static func apply_display_settings(settings: Dictionary) -> void:
	var display: Dictionary = normalized_display_settings(settings)
	var resolution_id := str(display.get("resolution_id", BASE_RESOLUTION_ID))
	var size := resolution_size(resolution_id)
	var mode := str(display.get("window_mode", GameSettingsScript.WINDOW_MODE_WINDOWED))
	_apply_vsync(bool(display.get("vsync_enabled", true)))
	if mode == GameSettingsScript.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		return
	if mode == GameSettingsScript.WINDOW_MODE_BORDERLESS_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(size)
	_center_window(size)

static func _apply_vsync(enabled: bool) -> void:
	var mode := DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(mode)

static func _center_window(size: Vector2i) -> void:
	var screen := DisplayServer.window_get_current_screen()
	var screen_size := DisplayServer.screen_get_size(screen)
	var position := Vector2i(max(0, (screen_size.x - size.x) / 2), max(0, (screen_size.y - size.y) / 2))
	DisplayServer.window_set_position(position)

static func _resolution(resolution_id: String, width: int, height: int, label: String) -> Dictionary:
	return {
		"id": resolution_id,
		"width": width,
		"height": height,
		"label": label,
		"aspect": "16:9"
	}
