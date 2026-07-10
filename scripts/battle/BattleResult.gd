extends RefCounted
class_name BattleResult


static func accepted(request: Dictionary, success := true, events: Array = [], state_changes: Dictionary = {}) -> Dictionary:
	return _result(request, true, success, "", events, state_changes)


static func rejected(request: Dictionary, error: String, events: Array = [], state_changes: Dictionary = {}) -> Dictionary:
	return _result(request, false, false, error, events, state_changes)


static func _result(request: Dictionary, accepted_value: bool, success_value: bool, error: String, events: Array, state_changes: Dictionary) -> Dictionary:
	var error_code := error
	return {
		"accepted": accepted_value,
		"success": success_value,
		"request_id": str(request.get("request_id", "")),
		"request_type": str(request.get("request_type", request.get("type", ""))),
		"side": str(request.get("side", "")),
		"error": error_code,
		"error_code": error_code,
		"error_key": "" if error_code == "" else "battle.error.%s" % error_code,
		"events": events.duplicate(true),
		"state_changes": state_changes.duplicate(true)
	}
