extends RefCounted
class_name InputActionDatabase

const CATEGORY_MENU := "menu"
const CATEGORY_BATTLE := "battle"
const CATEGORY_CARD_SHORTCUT := "card_shortcut"
const CATEGORY_DEBUG := "debug"

static func action_definitions() -> Dictionary:
	var actions := {
		"ui_confirm": _action("ui_confirm", CATEGORY_MENU, "input.ui_confirm", [_key(KEY_ENTER), _key(KEY_SPACE)]),
		"ui_cancel": _action("ui_cancel", CATEGORY_MENU, "input.ui_cancel", [_key(KEY_ESCAPE)]),
		"end_turn": _action("end_turn", CATEGORY_BATTLE, "input.end_turn", [_key(KEY_E)]),
		"toggle_log": _action("toggle_log", CATEGORY_BATTLE, "input.toggle_log", [_key(KEY_L)]),
		"open_deck": _action("open_deck", CATEGORY_BATTLE, "input.open_deck", [_key(KEY_D)]),
		"open_graveyard": _action("open_graveyard", CATEGORY_BATTLE, "input.open_graveyard", [_key(KEY_G)]),
		"open_exile": _action("open_exile", CATEGORY_BATTLE, "input.open_exile", [_key(KEY_X)]),
		"target_next": _action("target_next", CATEGORY_BATTLE, "input.target_next", [_key(KEY_TAB)]),
		"debug_toggle": _action("debug_toggle", CATEGORY_DEBUG, "input.debug_toggle", [_key(KEY_F3)])
	}
	for i in range(10):
		var action_id := "hand_%d" % i
		var keycode := KEY_0 if i == 0 else KEY_1 + i - 1
		actions[action_id] = _action(action_id, CATEGORY_CARD_SHORTCUT, "input.%s" % action_id, [_key(keycode)])
	return actions

static func action_ids() -> Array:
	return action_definitions().keys()

static func actions_for_category(category_id: String) -> Array:
	var result: Array = []
	for action_id_variant in action_ids():
		var action_id := str(action_id_variant)
		var definition: Dictionary = action_definition(action_id)
		if str(definition.get("category", "")) == category_id:
			result.append(definition)
	return result

static func action_definition(action_id: String) -> Dictionary:
	var definitions: Dictionary = action_definitions()
	if definitions.has(action_id):
		return (definitions[action_id] as Dictionary).duplicate(true)
	return {}

static func default_binding_specs(action_id: String) -> Array:
	return action_definition(action_id).get("default_bindings", []).duplicate(true)

static func action_text_id(action_id: String) -> String:
	return str(action_definition(action_id).get("text_id", action_id))

static func categories_for_settings() -> Array:
	return [CATEGORY_MENU, CATEGORY_BATTLE, CATEGORY_CARD_SHORTCUT]

static func ensure_default_actions() -> void:
	for action_id_variant in action_ids():
		var action_id := str(action_id_variant)
		if not InputMap.has_action(action_id):
			InputMap.add_action(action_id)
		if InputMap.action_get_events(action_id).is_empty():
			for event_spec_variant in default_binding_specs(action_id):
				var event_spec: Dictionary = event_spec_variant
				var event := event_from_spec(event_spec)
				if event != null:
					InputMap.action_add_event(action_id, event)

static func event_from_spec(event_spec: Dictionary) -> InputEvent:
	match str(event_spec.get("type", "")):
		"key":
			var event := InputEventKey.new()
			event.keycode = int(event_spec.get("keycode", 0))
			return event
		"mouse_button":
			var mouse_event := InputEventMouseButton.new()
			mouse_event.button_index = int(event_spec.get("button_index", 0))
			return mouse_event
	return null

static func spec_from_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.keycode <= 0:
			return {}
		return _key(key_event.keycode)
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return {
			"type": "mouse_button",
			"button_index": mouse_event.button_index
		}
	return {}

static func binding_label(event_spec: Dictionary) -> String:
	match str(event_spec.get("type", "")):
		"key":
			var keycode := int(event_spec.get("keycode", 0))
			if keycode <= 0:
				return ""
			return OS.get_keycode_string(keycode)
		"mouse_button":
			return "Mouse %d" % int(event_spec.get("button_index", 0))
	return ""

static func bindings_label(event_specs: Array) -> String:
	var labels := PackedStringArray()
	for event_spec_variant in event_specs:
		var event_spec: Dictionary = event_spec_variant
		var label := binding_label(event_spec)
		if label != "":
			labels.append(label)
	if labels.is_empty():
		return "-"
	return " / ".join(labels)

static func _action(action_id: String, category_id: String, text_id: String, default_bindings: Array) -> Dictionary:
	return {
		"id": action_id,
		"category": category_id,
		"text_id": text_id,
		"default_bindings": default_bindings.duplicate(true)
	}

static func _key(keycode: int) -> Dictionary:
	return {
		"type": "key",
		"keycode": keycode
	}
