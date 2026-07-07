extends RefCounted
class_name EffectResolver

func apply_steps(battle, source_unit, steps: Array, context := {}) -> void:
	for step_variant in steps:
		var step: Dictionary = step_variant
		_apply_step(battle, source_unit, step, context)

func _apply_step(battle, source_unit, step: Dictionary, context: Dictionary) -> void:
	match str(step.get("kind", "")):
		"damage":
			_apply_damage_step(battle, source_unit, step, context)
		"heal":
			_apply_heal_step(battle, source_unit, step, context)
		"modify_stat":
			_apply_modify_stat_step(battle, source_unit, step, context)
		"add_resource":
			_apply_resource_step(battle, source_unit, step, context)
		"add_status":
			_apply_status_step(battle, source_unit, step, context)
		"summon":
			_apply_summon_step(battle, source_unit, step, context)
		"multi":
			apply_steps(battle, source_unit, step.get("effects", []), context)
		_:
			battle.add_log("未知效果步骤：%s。" % str(step.get("kind", "")))

func _apply_damage_step(battle, source_unit, step: Dictionary, context: Dictionary) -> void:
	var value: int = _step_value(source_unit, step, context)
	for target_unit in battle.resolve_target_units(str(step.get("target", "enemy")), source_unit, context):
		var final_damage: int = value
		if not bool(step.get("ignore_defense", false)):
			final_damage = max(0, value - target_unit.current_defense())
		battle.apply_damage_to_unit(target_unit, final_damage, str(step.get("source", _source_name(source_unit))))

func _apply_heal_step(battle, source_unit, step: Dictionary, context: Dictionary) -> void:
	var value: int = _step_value(source_unit, step, context)
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		battle.heal_unit(target_unit, value, str(step.get("source", _source_name(source_unit))))

func _apply_modify_stat_step(battle, source_unit, step: Dictionary, context: Dictionary) -> void:
	var value: int = _step_value(source_unit, step, context)
	var stat: String = str(step.get("stat", ""))
	var temporary: bool = bool(step.get("temporary", false))
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		battle.modify_unit_stat(target_unit, stat, value, temporary, str(step.get("source", _source_name(source_unit))))

func _apply_resource_step(battle, source_unit, step: Dictionary, context: Dictionary) -> void:
	var value: int = _step_value(source_unit, step, context)
	var resource_id: String = str(step.get("resource", ""))
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		battle.add_unit_resource(target_unit, resource_id, value, str(step.get("source", _source_name(source_unit))))

func _apply_status_step(battle, source_unit, step: Dictionary, context: Dictionary) -> void:
	var value: int = _step_value(source_unit, step, context)
	var status_id: String = str(step.get("status", ""))
	for target_unit in battle.resolve_target_units(str(step.get("target", "self")), source_unit, context):
		battle.add_unit_status(target_unit, status_id, value, str(step.get("source", _source_name(source_unit))))

func _apply_summon_step(battle, source_unit, step: Dictionary, context: Dictionary) -> void:
	var unit_team := ""
	if source_unit != null:
		unit_team = str(source_unit.team)
	if unit_team == "":
		unit_team = str(step.get("team", "player"))
	var count: int = max(0, int(step.get("count", 1)))
	var unit_data: Dictionary = step.get("unit", {}).duplicate(true)
	var added: int = battle.summon_units(unit_team, unit_data, count)
	battle.add_log("%s：召唤 %d / %d 个%s。" % [
		str(step.get("source", _source_name(source_unit))),
		added,
		count,
		str(unit_data.get("name", "单位"))
	])

func _step_value(source_unit, step: Dictionary, context: Dictionary) -> int:
	match str(step.get("value_from", "")):
		"source_attack":
			if source_unit != null:
				return source_unit.current_attack()
		"context_value":
			return int(context.get("value", 0))
	return int(step.get("value", 0))

func _source_name(source_unit) -> String:
	if source_unit == null:
		return "效果"
	return str(source_unit.name)
