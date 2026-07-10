extends RefCounted
class_name StatusRules

const StatusDatabaseScript = preload("res://scripts/data/StatusDatabase.gd")

static func sorted_instances(instances: Array) -> Array:
	var result: Array = instances.duplicate(true)
	result.sort_custom(func(a, b) -> bool:
		return int((a as Dictionary).get("created_order", 0)) < int((b as Dictionary).get("created_order", 0))
	)
	return result

static func status_total(instances: Array, status_id: String) -> int:
	var total := 0
	for instance_variant in instances:
		var instance: Dictionary = instance_variant
		if str(instance.get("status_id", "")) != status_id:
			continue
		if _counter_based_total(status_id):
			total += int(instance.get("counter", instance.get("value", 0)))
		else:
			total += int(instance.get("value", 0))
	return total

static func status_instances(instances: Array, status_id: String) -> Array:
	var result: Array = []
	for instance_variant in sorted_instances(instances):
		var instance: Dictionary = instance_variant
		if str(instance.get("status_id", "")) == status_id:
			result.append(instance.duplicate(true))
	return result

static func instances_with_tag(instances: Array, tag: String) -> Array:
	var result: Array = []
	for instance_variant in sorted_instances(instances):
		var instance: Dictionary = instance_variant
		var tags: Array = instance.get("tags", [])
		if tags.has(tag):
			result.append(instance.duplicate(true))
	return result

static func action_end_decay_status_ids() -> Array:
	return [StatusDatabaseScript.STATUS_ARMOR_BREAK, StatusDatabaseScript.STATUS_WEAK]

static func next_damage_reduce_result(instances: Array, incoming_damage: int) -> Dictionary:
	if incoming_damage <= 0:
		return {"damage": max(0, incoming_damage), "reduction": 0, "instance_ids": []}
	var reducers: Array = status_instances(instances, StatusDatabaseScript.STATUS_NEXT_DAMAGE_REDUCE)
	var reduction := 0
	var instance_ids: Array = []
	for instance_variant in reducers:
		var instance: Dictionary = instance_variant
		reduction += int(instance.get("value", 0))
		instance_ids.append(str(instance.get("instance_id", "")))
	return {
		"damage": max(0, incoming_damage - reduction),
		"reduction": min(incoming_damage, reduction),
		"raw_reduction": reduction,
		"instance_ids": instance_ids
	}

static func poison_instances(instances: Array) -> Array:
	return status_instances(instances, StatusDatabaseScript.STATUS_POISON)

static func active_status_modifier_total(instances: Array, status_id: String) -> int:
	match status_id:
		StatusDatabaseScript.STATUS_ARMOR_BREAK, StatusDatabaseScript.STATUS_WEAK:
			return status_total(instances, status_id)
	return 0

static func should_decay_on_action_end(status_id: String) -> bool:
	return action_end_decay_status_ids().has(status_id)

static func _counter_based_total(status_id: String) -> bool:
	if status_id == StatusDatabaseScript.STATUS_POISON:
		return true
	return not StatusDatabaseScript.is_active_status(status_id)
