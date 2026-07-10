extends RefCounted
class_name BattleActionRules

static func player_attack_uses_auto_targets(player, source_unit) -> bool:
	return source_unit == player and (player.next_attack_all_enemies or player.next_attack_random_max > 0)

static func basic_attack_targets(battle, source_unit) -> Array:
	if source_unit == battle.player and battle.player.next_attack_all_enemies:
		return battle.formation.living_units("enemy")
	if source_unit == battle.player and battle.player.next_attack_random_max > 0:
		var candidates: Array = battle.formation.living_units("enemy")
		if candidates.is_empty():
			return []
		var min_hits: int = max(1, battle.player.next_attack_random_min)
		var max_hits: int = max(min_hits, battle.player.next_attack_random_max)
		var hit_count: int = battle.rng.randi_range(min_hits, max_hits)
		var result: Array = []
		for _i in range(hit_count):
			var living: Array = battle.formation.living_units("enemy")
			if living.is_empty():
				break
			result.append(living[battle.rng.randi_range(0, living.size() - 1)])
		return result
	var target = battle.selected_enemy_unit()
	return [] if target == null else [target]

static func basic_attack_damage(player, source_unit, target_unit) -> int:
	var base_damage: int = max(0, source_unit.current_attack() - target_unit.current_defense())
	if source_unit == player and player.next_attack_damage_multiplier > 1.0:
		base_damage = int(floor(float(base_damage) * player.next_attack_damage_multiplier))
	var attach_multiplier := _attack_attach_damage_multiplier(source_unit)
	if attach_multiplier < 1.0:
		base_damage = max(1, int(floor(float(base_damage) * attach_multiplier))) if base_damage > 0 else 0
	return base_damage

static func defense_bonus_for_unit(unit) -> int:
	if unit == null:
		return 0
	var current_defense: int = unit.current_defense()
	return 1 if current_defense <= 0 else current_defense

static func clear_consumed_attack_modifiers(player, source_unit) -> void:
	if source_unit == player:
		player.clear_next_attack_modifiers()
	if source_unit != null:
		source_unit.attack_attach_statuses.clear()

static func _attack_attach_damage_multiplier(source_unit) -> float:
	if source_unit == null:
		return 1.0
	var result := 1.0
	for attach_variant in source_unit.attack_attach_statuses:
		var attach: Dictionary = attach_variant
		result = min(result, max(0.0, float(attach.get("damage_multiplier", 1.0))))
	return result
