extends RefCounted
class_name EffectResolver

const EFFECT_TYPE_NO_EFFECT := "no_effect"
const EFFECT_TYPE_DAMAGE := "damage"
const EFFECT_TYPE_HEAL := "heal"
const EFFECT_TYPE_MODIFY_STAT := "modify_stat"
const EFFECT_TYPE_ADD_RESOURCE := "add_resource"
const EFFECT_TYPE_ADD_STATUS := "add_status"
const EFFECT_TYPE_ADD_NEXT_ATTACK_MODIFIER := "add_next_attack_modifier"
const EFFECT_TYPE_ADD_STATUS_ON_HIT := "add_status_on_hit"
const EFFECT_TYPE_SET_UNIT_ACTION_LOCK := "set_unit_action_lock"
const EFFECT_TYPE_REMOVE_STATUS_BY_TAG := "remove_status_by_tag"
const EFFECT_TYPE_DRAW_CARDS := "draw_cards"
const EFFECT_TYPE_CREATE_CARD_TO_ZONE := "create_card_to_zone"
const EFFECT_TYPE_MOVE_SOURCE_CARD := "move_source_card"
const EFFECT_TYPE_SUMMON := "summon"
const EFFECT_TYPE_MULTI := "multi"

const SUPPORTED_EFFECT_TYPES := [
	EFFECT_TYPE_ADD_NEXT_ATTACK_MODIFIER,
	EFFECT_TYPE_ADD_STATUS_ON_HIT,
	EFFECT_TYPE_HEAL,
	EFFECT_TYPE_SET_UNIT_ACTION_LOCK,
	EFFECT_TYPE_REMOVE_STATUS_BY_TAG,
	EFFECT_TYPE_ADD_STATUS,
	EFFECT_TYPE_DRAW_CARDS,
	EFFECT_TYPE_CREATE_CARD_TO_ZONE,
	EFFECT_TYPE_MOVE_SOURCE_CARD,
	EFFECT_TYPE_NO_EFFECT,
	EFFECT_TYPE_DAMAGE,
	EFFECT_TYPE_MODIFY_STAT,
	EFFECT_TYPE_ADD_RESOURCE,
	EFFECT_TYPE_SUMMON,
	EFFECT_TYPE_MULTI
]
const SUPPORTED_TARGET_MODES := [
	"",
	"self",
	"player",
	"primary_player",
	"ally",
	"single_ally",
	"enemy",
	"primary_enemy",
	"all_players",
	"all_enemies",
	"opponent",
	"context_target",
	"random_enemy"
]

func supported_effect_types() -> Array:
	return SUPPORTED_EFFECT_TYPES.duplicate()

func apply_steps(battle, source_unit, steps: Array, context := {}) -> Array:
	var results: Array = []
	for step_variant in steps:
		var step: Dictionary = step_variant
		results.append_array(apply_step(battle, source_unit, step, context))
	return results

func apply_step(battle, source_unit, step: Dictionary, context := {}) -> Array:
	return _apply_step(battle, source_unit, step, context)

func _apply_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var effect_type := str(step.get("effect_type", ""))
	if effect_type == "":
		return _effect_step_failure(battle, step, "missing_effect_type")
	match effect_type:
		EFFECT_TYPE_NO_EFFECT:
			return []
		EFFECT_TYPE_DAMAGE:
			return _apply_damage_step(battle, source_unit, step, context)
		EFFECT_TYPE_HEAL:
			return _apply_heal_step(battle, source_unit, step, context)
		EFFECT_TYPE_MODIFY_STAT:
			return _apply_modify_stat_step(battle, source_unit, step, context)
		EFFECT_TYPE_ADD_RESOURCE:
			return _apply_resource_step(battle, source_unit, step, context)
		EFFECT_TYPE_ADD_STATUS:
			return _apply_status_step(battle, source_unit, step, context)
		EFFECT_TYPE_ADD_NEXT_ATTACK_MODIFIER:
			return _apply_add_next_attack_modifier_step(battle, source_unit, step, context)
		EFFECT_TYPE_ADD_STATUS_ON_HIT:
			return _apply_add_status_on_hit_step(battle, source_unit, step, context)
		EFFECT_TYPE_SET_UNIT_ACTION_LOCK:
			return _apply_set_unit_action_lock_step(battle, source_unit, step, context)
		EFFECT_TYPE_REMOVE_STATUS_BY_TAG:
			return _apply_remove_status_by_tag_step(battle, source_unit, step, context)
		EFFECT_TYPE_DRAW_CARDS:
			return _apply_draw_cards_step(battle, source_unit, step, context)
		EFFECT_TYPE_CREATE_CARD_TO_ZONE:
			return _apply_create_card_to_zone_step(battle, source_unit, step, context)
		EFFECT_TYPE_MOVE_SOURCE_CARD:
			return _apply_move_source_card_step(battle, source_unit, step, context)
		"prepare_attack_status":
			return _apply_prepare_attack_status_step(battle, source_unit, step, context)
		"heal_and_exhaust":
			return _apply_heal_and_exhaust_step(battle, source_unit, step, context)
		"remove_positive_status":
			return _apply_remove_positive_status_step(battle, source_unit, step, context)
		"draw_and_pollute":
			return _apply_draw_and_pollute_step(battle, source_unit, step, context)
		EFFECT_TYPE_SUMMON:
			return _apply_summon_step(battle, source_unit, step, context)
		EFFECT_TYPE_MULTI:
			var results: Array = []
			var sub_steps: Array = step.get("effect_steps", step.get("effects", []))
			for sub_step_variant in sub_steps:
				var sub_step: Dictionary = sub_step_variant
				results.append_array(apply_step(battle, source_unit, sub_step, context))
			return results
	return _effect_step_failure(battle, step, "unknown_effect_type")

func _effect_step_failure(battle, step: Dictionary, reason: String) -> Array:
	if battle != null and battle.has_method("add_log"):
		battle.add_log("无效效果步骤：%s。" % reason)
	return [{
		"effect_type": str(step.get("effect_type", "")),
		"success": false,
		"error": reason
	}]

func _apply_damage_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var value: int = _step_value(source_unit, step, context)
	var results: Array = []
	for target_unit in _target_units_for_step(battle, source_unit, step, context):
		var final_damage: int = value
		if not bool(step.get("ignore_defense", false)):
			final_damage = max(0, value - target_unit.current_defense())
		var applied: int = battle.apply_damage_to_unit(target_unit, final_damage, str(step.get("source", _source_name(source_unit))))
		results.append({
			"kind": "damage",
			"target": target_unit,
			"target_name": str(target_unit.name),
			"value": applied,
			"raw_value": value
		})
	return results

func _apply_heal_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var value: int = _step_value(source_unit, step, context)
	var results: Array = []
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		var healed: int = battle.heal_unit(target_unit, value, str(step.get("source", _source_name(source_unit))))
		results.append({
			"kind": "heal",
			"target": target_unit,
			"target_name": str(target_unit.name),
			"value": healed,
			"raw_value": value
		})
	return results

func _apply_modify_stat_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var value: int = _step_value(source_unit, step, context)
	var stat: String = str(step.get("stat", ""))
	var temporary: bool = bool(step.get("temporary", false))
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		battle.modify_unit_stat(target_unit, stat, value, temporary, str(step.get("source", _source_name(source_unit))))
	return []

func _apply_resource_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var value: int = _step_value(source_unit, step, context)
	var resource_id: String = str(step.get("resource", ""))
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		battle.add_unit_resource(target_unit, resource_id, value, str(step.get("source", _source_name(source_unit))))
	return []

func _apply_status_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var value: int = _step_value(source_unit, step, context)
	var status_id: String = str(step.get("status", ""))
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		battle.add_unit_status(target_unit, status_id, value, str(step.get("source", _source_name(source_unit))))
	return []

func _apply_add_next_attack_modifier_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var pending: Array = context.get("pending_attack_modifiers", [])
	var source_name: String = str(step.get("source", _source_name(source_unit)))
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		if target_unit == null:
			continue
		pending.append({
			"target_uid": str(target_unit.uid),
			"damage_multiplier": float(step.get("damage_multiplier", 1.0)),
			"source": source_name
		})
	context["pending_attack_modifiers"] = pending
	return []

func _apply_add_status_on_hit_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var value: int = _step_value(source_unit, step, context)
	var status_id := str(step.get("status", ""))
	var source_name: String = str(step.get("source", _source_name(source_unit)))
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		if target_unit == null or status_id == "" or value == 0:
			continue
		var damage_multiplier := _pending_attack_damage_multiplier(context, target_unit)
		target_unit.attack_attach_statuses.append({
			"status": status_id,
			"value": value,
			"damage_multiplier": damage_multiplier,
			"source": source_name
		})
		battle.add_log("%s：%s 下一次普通攻击命中时给予目标 %d 层%s。" % [source_name, str(target_unit.name), value, status_id])
	return []

func _apply_set_unit_action_lock_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var results: Array = []
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		if target_unit == null:
			continue
		battle.suppress_unit_action_this_turn(target_unit)
		results.append({
			"effect_type": EFFECT_TYPE_SET_UNIT_ACTION_LOCK,
			"target": target_unit,
			"target_name": str(target_unit.name),
			"success": true
		})
	return results

func _apply_remove_status_by_tag_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var value: int = max(1, _step_value(source_unit, step, context))
	var tag := str(step.get("tag", ""))
	var results: Array = []
	for target_unit in battle.resolve_target_units(str(step.get("target", "enemy")), source_unit, context):
		if target_unit == null:
			continue
		var removed := 0
		if tag == "positive":
			removed = battle.remove_positive_status_from_unit(target_unit, value, str(step.get("source", _source_name(source_unit))))
		else:
			var removed_instances: Array = target_unit.remove_first_status_instances_by_tag(tag, value)
			removed = removed_instances.size()
		results.append({
			"effect_type": EFFECT_TYPE_REMOVE_STATUS_BY_TAG,
			"target": target_unit,
			"target_name": str(target_unit.name),
			"value": removed,
			"tag": tag
		})
	return results

func _apply_draw_cards_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var draw_count: int = max(0, _step_value(source_unit, step, context))
	var drawn: Array = battle.draw_cards_for_unit(source_unit, draw_count, "card")
	return [{
		"effect_type": EFFECT_TYPE_DRAW_CARDS,
		"value": drawn.size()
	}]

func _apply_create_card_to_zone_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var zone := str(step.get("zone", ""))
	var card_id := str(step.get("card_id", ""))
	var count: int = max(0, _step_value(source_unit, step, context))
	if count == 0:
		count = max(0, int(step.get("count", 0)))
	if zone != "graveyard" or card_id == "":
		return _effect_step_failure(battle, step, "unsupported_create_card_to_zone")
	var created := 0
	for _i in range(count):
		if battle.add_card_to_unit_graveyard(source_unit, card_id):
			created += 1
	if created > 0:
		battle.add_log("%s：%s 进入墓地，等待后续重整。" % [str(step.get("source", _source_name(source_unit))), card_id])
	return [{
		"effect_type": EFFECT_TYPE_CREATE_CARD_TO_ZONE,
		"card_id": card_id,
		"zone": zone,
		"value": created
	}]

func _apply_move_source_card_step(_battle, _source_unit, step: Dictionary, context: Dictionary) -> Array:
	var zone := str(step.get("zone", ""))
	if zone == "":
		return [{
			"effect_type": EFFECT_TYPE_MOVE_SOURCE_CARD,
			"success": false,
			"error": "missing_zone"
		}]
	context["source_card_destination"] = zone
	return [{
		"effect_type": EFFECT_TYPE_MOVE_SOURCE_CARD,
		"zone": zone,
		"success": true
	}]

func _apply_prepare_attack_status_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var value: int = _step_value(source_unit, step, context)
	var status_id: String = str(step.get("status", ""))
	var source_name: String = str(step.get("source", _source_name(source_unit)))
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		if target_unit == null or status_id == "" or value == 0:
			continue
		target_unit.attack_attach_statuses.append({
			"status": status_id,
			"value": value,
			"damage_multiplier": float(step.get("damage_multiplier", 1.0)),
			"source": source_name
		})
		battle.add_log("%s：%s 下一次普通攻击命中时给予目标 %d 层%s。" % [source_name, str(target_unit.name), value, status_id])
	return []

func _apply_heal_and_exhaust_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var value: int = _step_value(source_unit, step, context)
	var results: Array = []
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		if target_unit == null:
			continue
		var healed: int = battle.heal_unit(target_unit, value, str(step.get("source", _source_name(source_unit))))
		battle.suppress_unit_action_this_turn(target_unit)
		results.append({
			"kind": "heal",
			"target": target_unit,
			"target_name": str(target_unit.name),
			"value": healed,
			"raw_value": value
		})
	return results

func _apply_remove_positive_status_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var value: int = max(1, _step_value(source_unit, step, context))
	var results: Array = []
	for target_unit in battle.resolve_target_units(str(step.get("target", "enemy")), source_unit, context):
		if target_unit == null:
			continue
		var removed: int = battle.remove_positive_status_from_unit(target_unit, value, str(step.get("source", _source_name(source_unit))))
		results.append({
			"kind": "remove_positive_status",
			"target": target_unit,
			"target_name": str(target_unit.name),
			"value": removed
		})
	return results

func _apply_draw_and_pollute_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var draw_count: int = max(0, int(step.get("draw", step.get("value", 0))))
	var drawn: Array = battle.draw_cards_for_unit(source_unit, draw_count, "card")
	var pollute_card := str(step.get("pollute_card", ""))
	if pollute_card != "":
		battle.add_card_to_unit_graveyard(source_unit, pollute_card)
		battle.add_log("%s：%s 进入墓地，等待后续重整。" % [str(step.get("source", _source_name(source_unit))), pollute_card])
	return [{
		"kind": "draw_and_pollute",
		"value": drawn.size(),
		"pollute_card": pollute_card
	}]

func _apply_summon_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var unit_team := ""
	if source_unit != null:
		unit_team = str(source_unit.team)
	if unit_team == "":
		unit_team = str(step.get("team", "player"))
	var count: int = max(0, int(step.get("count", 1)))
	var unit_data: Dictionary = step.get("unit", {}).duplicate(true)
	var added: int = battle.summon_units(unit_team, unit_data, count)
	battle.add_log("%s：召唤 %d / %d 个 %s。" % [
		str(step.get("source", _source_name(source_unit))),
		added,
		count,
		str(unit_data.get("name", "单位"))
	])
	return []

func _step_value(source_unit, step: Dictionary, context: Dictionary) -> int:
	match str(step.get("value_from", "")):
		"source_attack":
			if source_unit != null:
				return source_unit.current_attack()
		"context_value":
			return int(context.get("value", 0))
	return int(step.get("value", 0))

func _target_units_for_step(battle, source_unit, step: Dictionary, context: Dictionary) -> Array:
	var target_rule := str(step.get("target", "enemy"))
	if target_rule == "random_enemy":
		var enemies: Array = battle.formation.living_units("enemy")
		if enemies.is_empty():
			return []
		return [enemies[battle.rng.randi_range(0, enemies.size() - 1)]]
	return battle.resolve_target_units(target_rule, source_unit, context)

func _source_name(source_unit) -> String:
	if source_unit == null:
		return "效果"
	return str(source_unit.name)

func _pending_attack_damage_multiplier(context: Dictionary, target_unit) -> float:
	var result := 1.0
	var target_uid := "" if target_unit == null else str(target_unit.uid)
	for pending_variant in context.get("pending_attack_modifiers", []):
		var pending: Dictionary = pending_variant
		if str(pending.get("target_uid", "")) == target_uid:
			result = min(result, max(0.0, float(pending.get("damage_multiplier", 1.0))))
	return result
