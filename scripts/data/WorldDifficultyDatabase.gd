extends RefCounted
class_name WorldDifficultyDatabase

const CONTENT_STATE_ACTIVE := "active"
const CONTENT_STATE_PROTOTYPE := "prototype"
const CONTENT_STATE_DISABLED := "disabled"

const DEFINITIONS := [
	{
		"world_difficulty_id": "wd0",
		"value": 0,
		"name": "默认难度",
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"world_difficulty_id": "wd1",
		"value": 1,
		"name": "难度一",
		"content_state": CONTENT_STATE_PROTOTYPE
	},
	{
		"world_difficulty_id": "wd2",
		"value": 2,
		"name": "难度二",
		"content_state": CONTENT_STATE_DISABLED
	},
	{
		"world_difficulty_id": "wd3",
		"value": 3,
		"name": "难度三",
		"content_state": CONTENT_STATE_DISABLED
	}
]


static func definitions() -> Array:
	return DEFINITIONS.duplicate(true)


static func active_definitions() -> Array:
	var result: Array = []
	for definition_variant in DEFINITIONS:
		var definition: Dictionary = definition_variant
		if str(definition.get("content_state", "")) == CONTENT_STATE_ACTIVE:
			result.append(definition.duplicate(true))
	return result


static func active_definition(world_difficulty_id: String) -> Dictionary:
	for definition_variant in active_definitions():
		var definition: Dictionary = definition_variant
		if str(definition.get("world_difficulty_id", "")) == world_difficulty_id:
			return definition.duplicate(true)
	return {}


static func active_definition_for_value(value: int) -> Dictionary:
	for definition_variant in active_definitions():
		var definition: Dictionary = definition_variant
		if int(definition.get("value", -1)) == value:
			return definition.duplicate(true)
	return {}


static func is_active_value(value: int) -> bool:
	return not active_definition_for_value(value).is_empty()
