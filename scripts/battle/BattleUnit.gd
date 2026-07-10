extends RefCounted
class_name BattleUnit

const StatusDatabaseScript = preload("res://scripts/data/StatusDatabase.gd")
const StatusRulesScript = preload("res://scripts/battle/StatusRules.gd")

const TEAM_PLAYER := "player"
const TEAM_ENEMY := "enemy"
const TYPE_PLAYER := "player"
const TYPE_ENEMY := "enemy"
const TYPE_SUMMON := "summon"
const TYPE_ARTIFACT := "artifact"
const RANK_MAIN := "main"
const RANK_NORMAL := "normal"
const RANK_ELITE := "elite"
const RANK_BOSS := "boss"
const STATUS_CLEANUP_SCOPE_BATTLE := "battle"
const STATUS_FIELD_ID := "status_id"
const STATUS_FIELD_INSTANCE_ID := "instance_id"
const STATUS_FIELD_NAME := "name"
const STATUS_FIELD_VALUE := "value"
const STATUS_FIELD_COUNTER := "counter"
const STATUS_FIELD_SOURCE := "source"
const STATUS_FIELD_TAGS := "tags"
const STATUS_FIELD_CLEANUP_SCOPE := "cleanup_scope"
const STATUS_FIELD_CREATED_ORDER := "created_order"
const EQUIPMENT_CLEANUP_SCOPE_BATTLE := "battle"
const EQUIPMENT_FIELD_CARD_UID := "card_uid"
const EQUIPMENT_FIELD_UID := "uid"
const EQUIPMENT_FIELD_CARD_ID := "card_id"
const EQUIPMENT_FIELD_ID := "id"
const EQUIPMENT_FIELD_NAME := "name"
const EQUIPMENT_FIELD_EQUIPPED_TO_UID := "equipped_to_uid"
const EQUIPMENT_FIELD_HOST_UID := "host_uid"
const EQUIPMENT_FIELD_HOST_SIDE := "host_side"
const EQUIPMENT_FIELD_OWNER_SIDE := "owner_side"
const EQUIPMENT_FIELD_CONTROLLER_SIDE := "controller_side"
const EQUIPMENT_FIELD_SOURCE_ZONE := "source_zone"
const EQUIPMENT_FIELD_ATTACK_BONUS := "attack_bonus"
const EQUIPMENT_FIELD_DEFENSE_BONUS := "defense_bonus"
const EQUIPMENT_FIELD_EFFECT_KINDS := "effect_kinds"
const EQUIPMENT_FIELD_CLEANUP_SCOPE := "cleanup_scope"
const EQUIPMENT_FIELD_LEAVE_SCOPE := "leave_scope"
const NON_ACTIVE_STATUS_TAGS_BY_ID := {
	"灼伤": ["negative", "burn"],
	"迟滞": ["negative", "delay"],
	"taunt": ["neutral", "special"]
}

var uid := ""
var unit_id := ""
var name := ""
var team := ""
var unit_type := ""
var unit_rank := RANK_NORMAL
var unit_tags: Array = []
var visual_profile_id := ""
var portrait_asset_id := ""
var battle_sprite_asset_id := ""
var battle_animation_profile_id := ""
var icon_asset_id := ""
var slot_index := 0
var max_hp := 0
var hp := 0
var attack := 0
var defense := 0
var equipment: Array = []
var equipment_limit := 1
var equipment_attack_bonus := 0
var equipment_defense_bonus := 0
var temp_attack_delta := 0
var temp_defense_delta := 0
var status_instances: Array = []
var _next_status_created_order := 1
var resource_counters: Dictionary = {}
var attack_attach_statuses: Array = []
var selectable := true
var alive := true

func setup_unit(data: Dictionary, default_team := "", default_type := "") -> void:
	unit_id = str(data.get("id", data.get("unit_id", "")))
	uid = str(data.get("uid", unit_id))
	name = str(data.get("name", data.get("display_name", unit_id)))
	team = str(data.get("team", default_team))
	unit_type = str(data.get("unit_type", default_type))
	unit_rank = str(data.get("unit_rank", data.get("rank", _default_rank_for_type(unit_type))))
	unit_tags = data.get("unit_tags", []).duplicate()
	visual_profile_id = str(data.get("visual_profile_id", data.get("visual_id", data.get("animation_profile", ""))))
	portrait_asset_id = str(data.get("portrait_asset_id", ""))
	battle_sprite_asset_id = str(data.get("battle_sprite_asset_id", ""))
	battle_animation_profile_id = str(data.get("battle_animation_profile_id", data.get("animation_profile", visual_profile_id)))
	icon_asset_id = str(data.get("icon_asset_id", ""))
	slot_index = int(data.get("slot_index", 0))
	max_hp = int(data.get("max_hp", 0))
	hp = int(data.get("hp", max_hp))
	attack = int(data.get("attack", 0))
	defense = int(data.get("defense", 0))
	equipment = data.get("equipment", []).duplicate(true)
	equipment_limit = int(data.get("equipment_limit", _default_equipment_limit(unit_rank)))
	equipment_attack_bonus = int(data.get("equipment_attack_bonus", 0))
	equipment_defense_bonus = int(data.get("equipment_defense_bonus", 0))
	temp_attack_delta = int(data.get("temp_attack_delta", 0))
	temp_defense_delta = int(data.get("temp_defense_delta", 0))
	status_instances = _normalized_status_instances(data.get("status_instances", []))
	resource_counters = data.get("resource_counters", {}).duplicate(true)
	attack_attach_statuses = data.get("attack_attach_statuses", []).duplicate(true)
	selectable = bool(data.get("selectable", true))
	alive = hp > 0

func current_attack() -> int:
	return max(0, attack + temp_attack_delta + equipment_attack_bonus - get_status(StatusDatabaseScript.STATUS_WEAK))

func current_defense() -> int:
	return defense + temp_defense_delta + equipment_defense_bonus - get_status(StatusDatabaseScript.STATUS_ARMOR_BREAK)

func has_equipment(card_id: String) -> bool:
	return not find_equipment_by_card_id(card_id).is_empty()

func equipment_count() -> int:
	return equipment.size()

func equipment_cards() -> Array:
	return equipment

func equipment_slot(index: int) -> Dictionary:
	if index < 0 or index >= equipment.size():
		return {}
	var card: Dictionary = equipment[index]
	return card

func find_equipment_index_by_uid(equipment_uid: String) -> int:
	for index in range(equipment.size()):
		var card: Dictionary = equipment[index]
		if str(card.get(EQUIPMENT_FIELD_UID, "")) == equipment_uid:
			return index
	return -1

func find_equipment_by_uid(equipment_uid: String) -> Dictionary:
	var index: int = find_equipment_index_by_uid(equipment_uid)
	return equipment_slot(index)

func find_equipment_by_card_id(card_id: String) -> Dictionary:
	for card_variant in equipment:
		var card: Dictionary = card_variant
		if str(card.get(EQUIPMENT_FIELD_ID, "")) == card_id:
			return card
	return {}

func attach_equipment_card(card: Dictionary) -> void:
	if card.is_empty():
		return
	card[EQUIPMENT_FIELD_EQUIPPED_TO_UID] = str(uid)
	equipment.append(card)

func remove_equipment_at(index: int) -> Dictionary:
	if index < 0 or index >= equipment.size():
		return {}
	var card: Dictionary = equipment[index]
	equipment.remove_at(index)
	return card

func remove_equipment_by_uid(equipment_uid: String) -> Dictionary:
	return remove_equipment_at(find_equipment_index_by_uid(equipment_uid))

func apply_equipment_stat_bonus(stat: String, amount: int) -> void:
	match stat:
		"attack":
			equipment_attack_bonus += amount
		"defense":
			equipment_defense_bonus += amount

func remove_equipment_effects(card: Dictionary) -> void:
	if card.is_empty():
		return
	equipment_attack_bonus -= equipment_card_attack_bonus(card)
	equipment_defense_bonus -= equipment_card_defense_bonus(card)

func equipment_has_effect_kind(card: Dictionary, expected_kind: String) -> bool:
	return equipment_effect_kinds(card).has(expected_kind)

func equipment_effect_kinds(card: Dictionary) -> Array:
	var kinds: Array = []
	_collect_equipment_effect_kinds(card.get("effect", {}), kinds)
	return kinds

func equipment_card_attack_bonus(card: Dictionary) -> int:
	return _equipment_bonus_from_effect(card.get("effect", {}), "equipment_attack_bonus")

func equipment_card_defense_bonus(card: Dictionary) -> int:
	return _equipment_bonus_from_effect(card.get("effect", {}), "equipment_defense_bonus")

func equipment_stat_bonus_snapshot() -> Dictionary:
	return {
		EQUIPMENT_FIELD_ATTACK_BONUS: equipment_attack_bonus,
		EQUIPMENT_FIELD_DEFENSE_BONUS: equipment_defense_bonus
	}

func equipment_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	for record_variant in equipment_records_snapshot():
		var record: Dictionary = record_variant
		snapshot[str(record.get(EQUIPMENT_FIELD_CARD_UID, ""))] = record
	return snapshot

func equipment_records_snapshot() -> Array:
	var records: Array = []
	for index in range(equipment.size()):
		var card: Dictionary = equipment[index]
		records.append(_equipment_record(card, index))
	return records

func has_unit_tag(tag: String) -> bool:
	return unit_tags.has(tag)

func add_unit_tag(tag: String) -> void:
	if tag != "" and not unit_tags.has(tag):
		unit_tags.append(tag)

func apply_damage(amount: int) -> int:
	var value: int = max(0, amount)
	hp = max(0, hp - value)
	alive = hp > 0
	return value

func heal(amount: int) -> int:
	var before: int = hp
	hp = min(max_hp, hp + max(0, amount))
	alive = hp > 0
	return hp - before

func add_resource(resource_id: String, amount: int, min_value := 0) -> int:
	var current := int(resource_counters.get(resource_id, 0))
	var next_value: int = max(min_value, current + amount)
	resource_counters[resource_id] = next_value
	return next_value

func set_resource(resource_id: String, value: int) -> void:
	resource_counters[resource_id] = value

func get_resource(resource_id: String) -> int:
	return int(resource_counters.get(resource_id, 0))

func add_status(status_id: String, amount: int, source = "", min_value := 0) -> int:
	var actual_source := str(source)
	if typeof(source) == TYPE_INT or typeof(source) == TYPE_FLOAT:
		actual_source = ""
	if amount < 0:
		remove_status(status_id, abs(amount), actual_source)
		return get_status(status_id)
	if amount == 0:
		return get_status(status_id)
	for instance in _status_instances_for_add(status_id, amount, actual_source):
		status_instances.append(instance)
	return max(min_value, get_status(status_id))

func get_status(status_id: String) -> int:
	return StatusRulesScript.status_total(status_instances, status_id)

func status_value(status_id: String) -> int:
	return get_status(status_id)

func has_status(status_id: String) -> bool:
	return get_status(status_id) > 0

func remove_status(status_id: String, amount := -1, source = "") -> int:
	var matching: Array = StatusRulesScript.status_instances(status_instances, status_id)
	if matching.is_empty():
		return 0
	var remove_count: int = matching.size() if amount < 0 else min(matching.size(), amount)
	var removed := 0
	for instance_variant in matching:
		if removed >= remove_count:
			break
		var instance: Dictionary = instance_variant
		if _remove_status_instance(str(instance.get(STATUS_FIELD_INSTANCE_ID, ""))):
			removed += 1
	return removed

func clear_status(status_id: String, source = "") -> int:
	return remove_status(status_id, -1, source)

func clear_statuses() -> void:
	status_instances.clear()

func status_snapshot() -> Dictionary:
	var snapshot := {}
	for record_variant in status_records_snapshot():
		var record: Dictionary = record_variant
		snapshot[str(record.get(STATUS_FIELD_INSTANCE_ID, ""))] = record
	return snapshot

func status_records_snapshot() -> Array:
	var records: Array = []
	for instance_variant in StatusRulesScript.sorted_instances(status_instances):
		var instance: Dictionary = instance_variant
		if int(instance.get(STATUS_FIELD_COUNTER, 0)) <= 0:
			continue
		records.append(_status_record_from_instance(instance))
	return records

func status_tags(status_id: String) -> Array:
	return _status_tags_for(status_id)

func status_instance_ids(status_id: String) -> Array:
	var result: Array = []
	for instance_variant in StatusRulesScript.status_instances(status_instances, status_id):
		var instance: Dictionary = instance_variant
		result.append(str(instance.get(STATUS_FIELD_INSTANCE_ID, "")))
	return result

func remove_status_instance(instance_id: String) -> Dictionary:
	for index in range(status_instances.size()):
		var instance: Dictionary = status_instances[index]
		if str(instance.get(STATUS_FIELD_INSTANCE_ID, "")) == instance_id:
			status_instances.remove_at(index)
			return instance
	return {}

func decay_status_instance(instance_id: String, amount := 1) -> Dictionary:
	for index in range(status_instances.size()):
		var instance: Dictionary = status_instances[index]
		if str(instance.get(STATUS_FIELD_INSTANCE_ID, "")) != instance_id:
			continue
		instance[STATUS_FIELD_COUNTER] = int(instance.get(STATUS_FIELD_COUNTER, 0)) - max(1, amount)
		if int(instance.get(STATUS_FIELD_COUNTER, 0)) <= 0:
			status_instances.remove_at(index)
		else:
			status_instances[index] = instance
		return instance
	return {}

func clear_status_instances_by_ids(instance_ids: Array) -> Array:
	var removed: Array = []
	for instance_id_variant in instance_ids:
		var removed_instance: Dictionary = remove_status_instance(str(instance_id_variant))
		if not removed_instance.is_empty():
			removed.append(removed_instance)
	return removed

func remove_first_status_instances_by_tag(tag: String, amount := 1) -> Array:
	var removed: Array = []
	var remaining: int = max(0, amount)
	for instance_variant in StatusRulesScript.instances_with_tag(status_instances, tag):
		if remaining <= 0:
			break
		var instance: Dictionary = instance_variant
		var removed_instance: Dictionary = remove_status_instance(str(instance.get(STATUS_FIELD_INSTANCE_ID, "")))
		if not removed_instance.is_empty():
			removed.append(removed_instance)
			remaining -= 1
	return removed

func clear_temporary_stats() -> void:
	temp_attack_delta = 0
	temp_defense_delta = 0

func _status_tags_for(status_id: String) -> Array:
	if StatusDatabaseScript.is_active_status(status_id):
		return StatusDatabaseScript.tags_for_status(status_id)
	if NON_ACTIVE_STATUS_TAGS_BY_ID.has(status_id):
		return (NON_ACTIVE_STATUS_TAGS_BY_ID[status_id] as Array).duplicate()
	return ["neutral"]

func _status_instances_for_add(status_id: String, amount: int, source: String) -> Array:
	var result: Array = []
	match status_id:
		StatusDatabaseScript.STATUS_POISON:
			result.append(_make_status_instance(status_id, 1, max(1, amount), source))
		StatusDatabaseScript.STATUS_ARMOR_BREAK, StatusDatabaseScript.STATUS_WEAK:
			for _i in range(max(1, amount)):
				result.append(_make_status_instance(status_id, 1, 1, source))
		StatusDatabaseScript.STATUS_NEXT_DAMAGE_REDUCE:
			result.append(_make_status_instance(status_id, max(1, amount), 1, source))
		_:
			result.append(_make_status_instance(status_id, max(1, amount), max(1, amount), source))
	return result

func _make_status_instance(status_id: String, value: int, counter: int, source: String) -> Dictionary:
	var created_order: int = _next_status_created_order
	_next_status_created_order += 1
	var instance_id := "%s_%s_%04d" % [str(uid), status_id, created_order]
	return {
		STATUS_FIELD_INSTANCE_ID: instance_id,
		STATUS_FIELD_ID: status_id,
		STATUS_FIELD_NAME: _status_display_name(status_id),
		STATUS_FIELD_VALUE: max(0, value),
		STATUS_FIELD_COUNTER: max(0, counter),
		STATUS_FIELD_SOURCE: source,
		STATUS_FIELD_TAGS: _status_tags_for(status_id),
		STATUS_FIELD_CLEANUP_SCOPE: STATUS_CLEANUP_SCOPE_BATTLE,
		STATUS_FIELD_CREATED_ORDER: created_order
	}

func _normalized_status_instances(raw_statuses) -> Array:
	var normalized: Array = []
	if typeof(raw_statuses) != TYPE_ARRAY:
		return normalized
	var max_order := 0
	for raw_variant in raw_statuses:
		if typeof(raw_variant) != TYPE_DICTIONARY:
			continue
		var raw: Dictionary = raw_variant
		var status_id := str(raw.get(STATUS_FIELD_ID, ""))
		if status_id == "":
			continue
		var created_order := int(raw.get(STATUS_FIELD_CREATED_ORDER, 0))
		if created_order <= 0:
			created_order = max_order + 1
		max_order = max(max_order, created_order)
		var instance: Dictionary = raw.duplicate(true)
		instance[STATUS_FIELD_CREATED_ORDER] = created_order
		instance[STATUS_FIELD_INSTANCE_ID] = str(raw.get(STATUS_FIELD_INSTANCE_ID, "%s_%s_%04d" % [str(uid), status_id, created_order]))
		instance[STATUS_FIELD_NAME] = str(raw.get(STATUS_FIELD_NAME, _status_display_name(status_id)))
		instance[STATUS_FIELD_VALUE] = max(0, int(raw.get(STATUS_FIELD_VALUE, 1)))
		instance[STATUS_FIELD_COUNTER] = max(0, int(raw.get(STATUS_FIELD_COUNTER, instance.get(STATUS_FIELD_VALUE, 1))))
		instance[STATUS_FIELD_TAGS] = raw.get(STATUS_FIELD_TAGS, _status_tags_for(status_id)).duplicate()
		instance[STATUS_FIELD_CLEANUP_SCOPE] = str(raw.get(STATUS_FIELD_CLEANUP_SCOPE, STATUS_CLEANUP_SCOPE_BATTLE))
		if int(instance.get(STATUS_FIELD_COUNTER, 0)) > 0:
			normalized.append(instance)
	_next_status_created_order = max_order + 1
	return StatusRulesScript.sorted_instances(normalized)

func _status_record_from_instance(instance: Dictionary) -> Dictionary:
	return instance.duplicate(true)

func _remove_status_instance(instance_id: String) -> bool:
	return not remove_status_instance(instance_id).is_empty()

func _status_display_name(status_id: String) -> String:
	if StatusDatabaseScript.is_active_status(status_id):
		return StatusDatabaseScript.display_name(status_id)
	return status_id

func _equipment_record(card: Dictionary, slot_index_value: int) -> Dictionary:
	var card_uid := str(card.get(EQUIPMENT_FIELD_UID, ""))
	var card_id := str(card.get(EQUIPMENT_FIELD_ID, ""))
	return {
		EQUIPMENT_FIELD_CARD_UID: card_uid,
		EQUIPMENT_FIELD_UID: card_uid,
		EQUIPMENT_FIELD_CARD_ID: card_id,
		EQUIPMENT_FIELD_ID: card_id,
		EQUIPMENT_FIELD_NAME: str(card.get(EQUIPMENT_FIELD_NAME, card_id)),
		EQUIPMENT_FIELD_EQUIPPED_TO_UID: str(card.get(EQUIPMENT_FIELD_EQUIPPED_TO_UID, uid)),
		EQUIPMENT_FIELD_HOST_UID: str(uid),
		EQUIPMENT_FIELD_HOST_SIDE: str(team),
		EQUIPMENT_FIELD_OWNER_SIDE: str(card.get(EQUIPMENT_FIELD_OWNER_SIDE, team)),
		EQUIPMENT_FIELD_CONTROLLER_SIDE: str(card.get(EQUIPMENT_FIELD_CONTROLLER_SIDE, team)),
		EQUIPMENT_FIELD_SOURCE_ZONE: str(card.get(EQUIPMENT_FIELD_SOURCE_ZONE, "equipment")),
		"slot_index": slot_index_value,
		EQUIPMENT_FIELD_ATTACK_BONUS: equipment_card_attack_bonus(card),
		EQUIPMENT_FIELD_DEFENSE_BONUS: equipment_card_defense_bonus(card),
		EQUIPMENT_FIELD_EFFECT_KINDS: equipment_effect_kinds(card),
		EQUIPMENT_FIELD_CLEANUP_SCOPE: str(card.get(EQUIPMENT_FIELD_CLEANUP_SCOPE, EQUIPMENT_CLEANUP_SCOPE_BATTLE)),
		EQUIPMENT_FIELD_LEAVE_SCOPE: str(card.get(EQUIPMENT_FIELD_LEAVE_SCOPE, EQUIPMENT_CLEANUP_SCOPE_BATTLE))
	}

func _collect_equipment_effect_kinds(effect_variant, kinds: Array) -> void:
	if typeof(effect_variant) != TYPE_DICTIONARY:
		return
	var effect: Dictionary = effect_variant
	var kind := str(effect.get("kind", ""))
	if kind == "":
		return
	if kind == "multi":
		for sub_effect_variant in effect.get("effects", []):
			_collect_equipment_effect_kinds(sub_effect_variant, kinds)
		return
	if not kinds.has(kind):
		kinds.append(kind)

func _equipment_bonus_from_effect(effect_variant, expected_kind: String) -> int:
	if typeof(effect_variant) != TYPE_DICTIONARY:
		return 0
	var effect: Dictionary = effect_variant
	var kind := str(effect.get("kind", ""))
	if kind == expected_kind:
		return int(effect.get("value", 0))
	if kind == "multi":
		var total := 0
		for sub_effect_variant in effect.get("effects", []):
			total += _equipment_bonus_from_effect(sub_effect_variant, expected_kind)
		return total
	return 0

func _default_rank_for_type(type_id: String) -> String:
	if type_id == TYPE_PLAYER:
		return RANK_MAIN
	return RANK_NORMAL

func _default_equipment_limit(rank_id: String) -> int:
	match rank_id:
		RANK_MAIN:
			return 2
		RANK_ELITE:
			return 2
		RANK_BOSS:
			return 3
	return 1
