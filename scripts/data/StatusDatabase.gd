extends RefCounted
class_name StatusDatabase

const CONTENT_STATE_ACTIVE := "active"

const STATUS_POISON := "poison"
const STATUS_ARMOR_BREAK := "armor_break"
const STATUS_WEAK := "weak"
const STATUS_NEXT_DAMAGE_REDUCE := "next_damage_reduce"

const TAG_NEGATIVE := "negative"
const TAG_POSITIVE := "positive"
const TAG_POISON := "poison"
const TAG_ARMOR_BREAK := "armor_break"
const TAG_WEAK := "weak"
const TAG_DAMAGE_REDUCE := "damage_reduce"

const DEFINITIONS := [
	{
		"status_id": STATUS_POISON,
		"name": "中毒",
		"name_key": "status.poison.name",
		"tags": [TAG_NEGATIVE, TAG_POISON],
		"stack_mode": "independent",
		"counter_type": "turn_start_after_draw",
		"trigger_event": "holder_turn_start_after_draw",
		"effect_steps": [{"kind": "life_loss", "value": 1}],
		"decay_rule": {"kind": "after_trigger", "counter_delta": -1},
		"remove_condition": "counter_zero",
		"dispel_rule": "negative_status",
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"status_id": STATUS_ARMOR_BREAK,
		"name": "破甲",
		"name_key": "status.armor_break.name",
		"tags": [TAG_NEGATIVE, TAG_ARMOR_BREAK],
		"stack_mode": "independent",
		"counter_type": "action_end",
		"trigger_event": "continuous_defense_modifier",
		"effect_steps": [{"kind": "defense_delta", "value": -1}],
		"decay_rule": {"kind": "holder_action_end", "counter_delta": -1},
		"remove_condition": "counter_zero",
		"dispel_rule": "negative_status",
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"status_id": STATUS_WEAK,
		"name": "虚弱",
		"name_key": "status.weak.name",
		"tags": [TAG_NEGATIVE, TAG_WEAK],
		"stack_mode": "independent",
		"counter_type": "action_end",
		"trigger_event": "continuous_attack_modifier",
		"effect_steps": [{"kind": "attack_delta", "value": -1, "min_attack": 0}],
		"decay_rule": {"kind": "holder_action_end", "counter_delta": -1},
		"remove_condition": "counter_zero",
		"dispel_rule": "negative_status",
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"status_id": STATUS_NEXT_DAMAGE_REDUCE,
		"name": "下次减伤",
		"name_key": "status.next_damage_reduce.name",
		"tags": [TAG_POSITIVE, TAG_DAMAGE_REDUCE],
		"stack_mode": "independent",
		"counter_type": "next_damage",
		"trigger_event": "before_positive_damage",
		"effect_steps": [{"kind": "damage_reduce", "value_from": "instance_value"}],
		"decay_rule": {"kind": "consume_all_on_trigger"},
		"remove_condition": "after_trigger",
		"dispel_rule": "positive_status",
		"content_state": CONTENT_STATE_ACTIVE
	}
]

static func all_definitions() -> Array:
	return DEFINITIONS.duplicate(true)

static func active_definitions() -> Array:
	return _filter_active(DEFINITIONS)

static func active_status_ids() -> Array:
	var result: Array = []
	for definition_variant in active_definitions():
		var definition: Dictionary = definition_variant
		result.append(str(definition.get("status_id", "")))
	return result

static func get_definition(status_id: String) -> Dictionary:
	for definition_variant in DEFINITIONS:
		var definition: Dictionary = definition_variant
		if str(definition.get("status_id", "")) == status_id:
			return definition.duplicate(true)
	return {}

static func active_definition(status_id: String) -> Dictionary:
	var definition: Dictionary = get_definition(status_id)
	if str(definition.get("content_state", "")) != CONTENT_STATE_ACTIVE:
		return {}
	return definition

static func is_active_status(status_id: String) -> bool:
	return not active_definition(status_id).is_empty()

static func display_name(status_id: String) -> String:
	var definition: Dictionary = get_definition(status_id)
	if definition.is_empty():
		return status_id
	return str(definition.get("name", status_id))

static func tags_for_status(status_id: String) -> Array:
	var definition: Dictionary = get_definition(status_id)
	if definition.is_empty():
		return []
	return (definition.get("tags", []) as Array).duplicate()

static func filter_active_definitions(definitions: Array) -> Array:
	return _filter_active(definitions)

static func _filter_active(definitions: Array) -> Array:
	var result: Array = []
	for definition_variant in definitions:
		var definition: Dictionary = definition_variant
		if str(definition.get("content_state", "")) == CONTENT_STATE_ACTIVE:
			result.append(definition.duplicate(true))
	return result
