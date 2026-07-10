extends RefCounted
class_name BattleRequest

const VALID_SIDES := ["player", "enemy", "system"]
const VALID_REQUEST_TYPES := [
	"play_card",
	"unit_attack",
	"unit_defend",
	"spell_attack",
	"select_target",
	"confirm_target",
	"end_turn",
	"play_response",
	"skip_response",
	"choose_equipment_replacement",
	"cancel_equipment_replacement"
]


static func normalize(context, request: Dictionary) -> Dictionary:
	var raw := request.duplicate(true)
	var request_type := str(raw.get("request_type", raw.get("type", "")))
	var side := str(raw.get("side", raw.get("request_side", "")))
	var source_uid := str(raw.get("source_uid", ""))
	var target_uid := str(raw.get("target_uid", ""))
	var payload: Dictionary = (raw.get("payload", {}) as Dictionary).duplicate(true)
	for key_variant in raw.keys():
		var key := str(key_variant)
		if not ["request_id", "request_type", "type", "side", "request_side", "source", "source_uid", "target_uid", "refs", "payload", "context_id"].has(key):
			payload[key] = raw[key]
	return {
		"request_id": str(raw.get("request_id", context.next_request_id() if context != null else "request_0")),
		"request_type": request_type,
		"side": side,
		"source": str(raw.get("source", side)),
		"source_uid": source_uid,
		"target_uid": target_uid,
		"refs": {
			"source_uid": source_uid,
			"target_uid": target_uid,
			"card_uid": str(raw.get("card_uid", payload.get("card_uid", "")))
		},
		"payload": payload.duplicate(true),
		"context_id": str(context.context_id) if context != null else ""
	}


static func value(request: Dictionary, key: String, default_value = null):
	if request.has(key):
		return request.get(key, default_value)
	var refs: Dictionary = request.get("refs", {})
	if refs.has(key):
		return refs.get(key, default_value)
	var payload: Dictionary = request.get("payload", {})
	return payload.get(key, default_value)


static func validation_error(request: Dictionary) -> String:
	if str(request.get("request_id", "")) == "":
		return "missing_request_id"
	if str(request.get("request_type", "")) == "":
		return "missing_request_type"
	if not VALID_REQUEST_TYPES.has(str(request.get("request_type", ""))):
		return "unknown_request_type"
	if not VALID_SIDES.has(str(request.get("side", ""))):
		return "invalid_request_side"
	return ""
