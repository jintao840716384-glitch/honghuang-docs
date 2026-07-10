extends RefCounted
class_name ResponseWindowRules

const TEAM_PLAYER := "player"
const TEAM_ENEMY := "enemy"

const CHAIN_FIELD_CARD := "card"
const CHAIN_FIELD_CARD_UID := "card_uid"
const CHAIN_FIELD_CARD_ID := "card_id"
const CHAIN_FIELD_SOURCE_ZONE := "source_zone"
const CHAIN_FIELD_CONTROLLER_SIDE := "controller_side"
const CHAIN_FIELD_EVENT_TYPE := "event_type"
const CHAIN_FIELD_CHAIN_INDEX := "chain_index"
const CHAIN_FIELD_LOCKED := "locked"
const CHAIN_FIELD_RESOLVED := "resolved"

static func default_owner_side() -> String:
	return TEAM_PLAYER

static func default_active_side() -> String:
	return TEAM_PLAYER

static func default_pass_state() -> Dictionary:
	var pass_state: Dictionary = {}
	pass_state[TEAM_PLAYER] = false
	return pass_state

static func owner_side(owner_side_value: String) -> String:
	return owner_side_value

static func active_side(active_side_value: String) -> String:
	return active_side_value

static func pass_state_snapshot(pass_state: Dictionary) -> Dictionary:
	return pass_state.duplicate(true)

static func side_passed(pass_state: Dictionary, side: String) -> bool:
	return bool(pass_state.get(side, false))

static func is_player_only(owner_side_value: String, active_side_value: String, pass_state: Dictionary) -> bool:
	return owner_side_value == TEAM_PLAYER and active_side_value == TEAM_PLAYER and pass_state.has(TEAM_PLAYER) and not pass_state.has(TEAM_ENEMY)

static func set_side_passed(pass_state: Dictionary, side: String, passed: bool) -> bool:
	if side != TEAM_PLAYER:
		return false
	pass_state[TEAM_PLAYER] = passed
	return true

static func skipped_from_pass_state(pass_state: Dictionary) -> bool:
	return side_passed(pass_state, TEAM_PLAYER)

static func can_append(phase: String, chain_state: String, current_event: Dictionary, active_side_value: String, pass_state: Dictionary, open_state: String) -> bool:
	return phase == "response" and chain_state == open_state and not current_event.is_empty() and active_side_value == TEAM_PLAYER and not side_passed(pass_state, TEAM_PLAYER)

static func make_chain_link(card: Dictionary, event_type: String, chain_index: int) -> Dictionary:
	return {
		CHAIN_FIELD_CARD: card.duplicate(true),
		CHAIN_FIELD_CARD_UID: str(card.get("uid", "")),
		CHAIN_FIELD_CARD_ID: str(card.get("id", "")),
		CHAIN_FIELD_SOURCE_ZONE: "spell_zone",
		CHAIN_FIELD_CONTROLLER_SIDE: TEAM_PLAYER,
		CHAIN_FIELD_EVENT_TYPE: event_type,
		CHAIN_FIELD_CHAIN_INDEX: chain_index,
		CHAIN_FIELD_LOCKED: false,
		CHAIN_FIELD_RESOLVED: false
	}

static func chain_link_card(link: Dictionary) -> Dictionary:
	var card_value = link.get(CHAIN_FIELD_CARD, {})
	if card_value is Dictionary:
		var card_dict: Dictionary = card_value
		return card_dict
	return link

static func chain_link_card_uid(link: Dictionary) -> String:
	return str(link.get(CHAIN_FIELD_CARD_UID, chain_link_card(link).get("uid", "")))

static func chain_link_card_id(link: Dictionary) -> String:
	return str(link.get(CHAIN_FIELD_CARD_ID, chain_link_card(link).get("id", "")))

static func chain_link_controller_side(link: Dictionary) -> String:
	return str(link.get(CHAIN_FIELD_CONTROLLER_SIDE, ""))

static func chain_link_event_type(link: Dictionary) -> String:
	return str(link.get(CHAIN_FIELD_EVENT_TYPE, ""))

static func chain_link_chain_index(link: Dictionary) -> int:
	return int(link.get(CHAIN_FIELD_CHAIN_INDEX, -1))

static func chain_link_locked(link: Dictionary) -> bool:
	return bool(link.get(CHAIN_FIELD_LOCKED, false))

static func chain_link_resolved(link: Dictionary) -> bool:
	return bool(link.get(CHAIN_FIELD_RESOLVED, false))

static func lock_chain_links(chain_stack: Array) -> void:
	for i in range(chain_stack.size()):
		var link_value = chain_stack[i]
		if link_value is Dictionary:
			var link: Dictionary = link_value
			link[CHAIN_FIELD_LOCKED] = true
			chain_stack[i] = link

static func mark_chain_link_resolved(link: Dictionary) -> void:
	link[CHAIN_FIELD_RESOLVED] = true
