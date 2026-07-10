extends RefCounted
class_name EventDatabase

const CONTENT_STATE_ACTIVE := "active"

const EVENT_ID_MINOR := "event_minor_01"
const EVENT_ID_WINDFALL := "event_windfall_01"
const EVENT_ID_TRADE := "event_trade_01"

const EVENT_DEFINITIONS := [
	{
		"event_id": EVENT_ID_WINDFALL,
		"name": "奇遇",
		"name_key": "event.%s.name" % EVENT_ID_WINDFALL,
		"event_type": "windfall",
		"weight": 8,
		"content_state": CONTENT_STATE_ACTIVE,
		"options": [
			{"option_id": "opt_take_windfall_reward"}
		]
	},
	{
		"event_id": EVENT_ID_TRADE,
		"name": "交易",
		"name_key": "event.%s.name" % EVENT_ID_TRADE,
		"event_type": "trade",
		"weight": 30,
		"content_state": CONTENT_STATE_ACTIVE,
		"options": [
			{"option_id": "opt_pay_stone"},
			{"option_id": "opt_pay_hp"},
			{"option_id": "opt_exchange_reserve"},
			{"option_id": "opt_take_fallback"}
		]
	},
	{
		"event_id": EVENT_ID_MINOR,
		"name": "小事件",
		"name_key": "event.%s.name" % EVENT_ID_MINOR,
		"event_type": "minor",
		"weight": 62,
		"content_state": CONTENT_STATE_ACTIVE,
		"options": [
			{"option_id": "opt_take_minor_reward"}
		]
	}
]


static func event_definitions() -> Array:
	return EVENT_DEFINITIONS.duplicate(true)


static func event_definition(event_id: String) -> Dictionary:
	for definition_variant in EVENT_DEFINITIONS:
		var definition: Dictionary = definition_variant
		if str(definition.get("event_id", "")) == event_id:
			return definition.duplicate(true)
	return {}


static func active_event_definitions() -> Array:
	return filter_active_definitions(EVENT_DEFINITIONS)


static func active_event_ids() -> Array:
	var result: Array = []
	for definition_variant in active_event_definitions():
		var definition: Dictionary = definition_variant
		result.append(str(definition.get("event_id", "")))
	return result


static func is_active_event_id(event_id: String) -> bool:
	return active_event_ids().has(event_id)


static func filter_active_definitions(definitions: Array) -> Array:
	var result: Array = []
	for definition_variant in definitions:
		if not (definition_variant is Dictionary):
			continue
		var definition: Dictionary = definition_variant
		if str(definition.get("content_state", "")) == CONTENT_STATE_ACTIVE:
			result.append(definition.duplicate(true))
	return result
