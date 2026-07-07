extends RefCounted
class_name InputSettings

const InputActionDatabaseScript = preload("res://scripts/settings/InputActionDatabase.gd")

static func apply_default_bindings() -> void:
	InputActionDatabaseScript.ensure_default_actions()

static func apply_bindings(bindings: Dictionary) -> void:
	apply_default_bindings()
	for action_id_variant in bindings.keys():
		var action_id := str(action_id_variant)
		if InputActionDatabaseScript.action_definition(action_id).is_empty():
			continue
		if not InputMap.has_action(action_id):
			InputMap.add_action(action_id)
		InputMap.action_erase_events(action_id)
		var event_specs: Array = bindings.get(action_id, [])
		for event_spec_variant in event_specs:
			var event_spec: Dictionary = event_spec_variant
			var event := InputActionDatabaseScript.event_from_spec(event_spec)
			if event != null:
				InputMap.action_add_event(action_id, event)
		if InputMap.action_get_events(action_id).is_empty():
			for default_spec_variant in InputActionDatabaseScript.default_binding_specs(action_id):
				var default_event := InputActionDatabaseScript.event_from_spec(default_spec_variant)
				if default_event != null:
					InputMap.action_add_event(action_id, default_event)

static func binding_count(action_id: String) -> int:
	if not InputMap.has_action(action_id):
		return 0
	return InputMap.action_get_events(action_id).size()

static func settings_bindings(settings: Dictionary) -> Dictionary:
	var input: Dictionary = (settings.get("input", {}) as Dictionary)
	return (input.get("bindings", {}) as Dictionary).duplicate(true)

static func binding_specs_for_action(settings: Dictionary, action_id: String) -> Array:
	var bindings: Dictionary = settings_bindings(settings)
	if bindings.has(action_id):
		var custom_specs: Array = (bindings.get(action_id, []) as Array).duplicate(true)
		if not custom_specs.is_empty():
			return custom_specs
	return InputActionDatabaseScript.default_binding_specs(action_id)

static func binding_label_for_action(settings: Dictionary, action_id: String) -> String:
	return InputActionDatabaseScript.bindings_label(binding_specs_for_action(settings, action_id))

static func with_primary_binding(settings: Dictionary, action_id: String, event_spec: Dictionary) -> Dictionary:
	var result: Dictionary = settings.duplicate(true)
	if InputActionDatabaseScript.action_definition(action_id).is_empty():
		return result
	if event_spec.is_empty():
		return result
	var input: Dictionary = (result.get("input", {}) as Dictionary).duplicate(true)
	var bindings: Dictionary = (input.get("bindings", {}) as Dictionary).duplicate(true)
	bindings[action_id] = [event_spec.duplicate(true)]
	input["bindings"] = bindings
	result["input"] = input
	return result

static func with_default_binding(settings: Dictionary, action_id: String) -> Dictionary:
	var result: Dictionary = settings.duplicate(true)
	var input: Dictionary = (result.get("input", {}) as Dictionary).duplicate(true)
	var bindings: Dictionary = (input.get("bindings", {}) as Dictionary).duplicate(true)
	bindings.erase(action_id)
	input["bindings"] = bindings
	result["input"] = input
	return result
