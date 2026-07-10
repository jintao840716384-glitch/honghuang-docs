extends RefCounted
class_name AudioEventDatabase

const CONTENT_STATE_ACTIVE := "active"

const CATEGORY_UI_SFX := "ui_sfx"
const CATEGORY_BATTLE_SFX := "battle_sfx"
const CATEGORY_MUSIC := "music"
const CATEGORY_AMBIENCE := "ambience"
const CATEGORY_VOICE := "voice"

static func event_definitions() -> Dictionary:
	return {
		"card_hover": _event("card_hover", CATEGORY_UI_SFX, -24.0, 28, "res://assets/audio/ui/card_hover.ogg", "card_hover"),
		"card_play": _event("card_play", CATEGORY_BATTLE_SFX, -14.0, 20, "res://assets/audio/sfx/card_play.ogg", "card_play"),
		"card_set": _event("card_set", CATEGORY_BATTLE_SFX, -13.0, 30, "res://assets/audio/sfx/card_set.ogg", "card_set"),
		"card_place": _event("card_place", CATEGORY_BATTLE_SFX, -13.0, 30, "res://assets/audio/sfx/card_place.ogg", "card_place"),
		"card_equip": _event("card_equip", CATEGORY_BATTLE_SFX, -12.0, 30, "res://assets/audio/sfx/card_equip.ogg", "card_equip"),
		"card_break": _event("card_break", CATEGORY_BATTLE_SFX, -11.0, 50, "res://assets/audio/sfx/card_break.ogg", "card_break"),
		"attack": _event("attack", CATEGORY_BATTLE_SFX, -14.0, 60, "res://assets/audio/sfx/attack.ogg", "attack"),
		"hit": _event("hit", CATEGORY_BATTLE_SFX, -10.0, 35, "res://assets/audio/sfx/hit.ogg", "hit"),
		"heal": _event("heal", CATEGORY_BATTLE_SFX, -13.0, 40, "res://assets/audio/sfx/heal.ogg", "heal"),
		"victory": _event("victory", CATEGORY_BATTLE_SFX, -13.0, 100, "res://assets/audio/sfx/victory.ogg", "victory"),
		"ui_click": _event("ui_click", CATEGORY_UI_SFX, -22.0, 20, "res://assets/audio/ui/ui_click.ogg", "ui_click"),
		"ui_confirm": _event("ui_confirm", CATEGORY_UI_SFX, -18.0, 20, "res://assets/audio/ui/ui_confirm.ogg", "ui_confirm"),
		"music.main_menu": _event("music.main_menu", CATEGORY_MUSIC, -12.0, 0, "res://assets/audio/music/main_menu.ogg", ""),
		"music.battle": _event("music.battle", CATEGORY_MUSIC, -12.0, 0, "res://assets/audio/music/battle.ogg", ""),
		"ambience.map": _event("ambience.map", CATEGORY_AMBIENCE, -18.0, 0, "res://assets/audio/ambience/map.ogg", "")
	}

static func event_ids() -> Array:
	return event_definitions().keys()

static func event_ids_for_category(category_id: String) -> Array:
	var result: Array = []
	for event_id_variant in event_definitions().keys():
		var event_id := str(event_id_variant)
		if str(event_definition(event_id).get("category", "")) == category_id:
			result.append(event_id)
	return result

static func has_event(event_id: String) -> bool:
	return event_definitions().has(event_id)

static func event_definition(event_id: String) -> Dictionary:
	var definitions: Dictionary = event_definitions()
	if definitions.has(event_id):
		return (definitions[event_id] as Dictionary).duplicate(true)
	return {}

static func volume_db(event_id: String) -> float:
	return float(event_definition(event_id).get("volume", -16.0))

static func cooldown_ms(event_id: String) -> int:
	return int(event_definition(event_id).get("cooldown_ms", 0))

static func stream_path(event_id: String) -> String:
	return str(event_definition(event_id).get("path", ""))

static func placeholder_id(event_id: String) -> String:
	return str(event_definition(event_id).get("placeholder_id", ""))

static func one_shot_event_ids() -> Array:
	var result: Array = []
	for event_id_variant in event_ids():
		var event_id := str(event_id_variant)
		var category := str(event_definition(event_id).get("category", ""))
		if category == CATEGORY_UI_SFX or category == CATEGORY_BATTLE_SFX or category == CATEGORY_VOICE:
			result.append(event_id)
	return result

static func _event(event_id: String, category_id: String, volume: float, cooldown: int, path: String, placeholder_id: String) -> Dictionary:
	return {
		"id": event_id,
		"content_state": CONTENT_STATE_ACTIVE,
		"category": category_id,
		"volume": volume,
		"cooldown_ms": cooldown,
		"path": path,
		"placeholder_id": placeholder_id
	}
