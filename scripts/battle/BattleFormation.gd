extends RefCounted
class_name BattleFormation

const BattleUnitScript = preload("res://scripts/battle/BattleUnit.gd")

const MAX_UNITS_PER_SIDE := 3

var player_units: Array = []
var enemy_units: Array = []

func setup_primary(player, enemy) -> void:
	player_units.clear()
	enemy_units.clear()
	add_unit(player, BattleUnitScript.TEAM_PLAYER, 2)
	add_unit(enemy, BattleUnitScript.TEAM_ENEMY, 2)

func add_unit(unit, unit_team: String, preferred_slot := -1) -> bool:
	var units: Array = _units_for_team(unit_team)
	if units.size() >= MAX_UNITS_PER_SIDE:
		return false
	unit.team = unit_team
	unit.slot_index = _next_slot(unit_team) if preferred_slot < 0 else preferred_slot
	units.append(unit)
	return true

func living_units(unit_team: String) -> Array:
	var result: Array = []
	for unit in _units_for_team(unit_team):
		if unit != null and unit.hp > 0:
			result.append(unit)
	return result

func remove_defeated_units() -> Array:
	var removed: Array = []
	removed.append_array(_remove_defeated_from(player_units))
	removed.append_array(_remove_defeated_from(enemy_units))
	return removed

func unit_by_uid(uid: String):
	if uid == "":
		return null
	for unit in player_units:
		if unit != null and str(unit.uid) == uid:
			return unit
	for unit in enemy_units:
		if unit != null and str(unit.uid) == uid:
			return unit
	return null

func living_unit_by_uid(unit_team: String, uid: String):
	var unit = unit_by_uid(uid)
	if unit == null:
		return null
	if str(unit.team) != unit_team:
		return null
	if int(unit.hp) <= 0:
		return null
	return unit

func primary_player():
	return _first_living(player_units)

func primary_enemy():
	return _first_living(enemy_units)

func all_enemies_defeated() -> bool:
	return living_units(BattleUnitScript.TEAM_ENEMY).is_empty()

func all_players_defeated() -> bool:
	return living_units(BattleUnitScript.TEAM_PLAYER).is_empty()

func _units_for_team(unit_team: String) -> Array:
	if unit_team == BattleUnitScript.TEAM_ENEMY:
		return enemy_units
	return player_units

func _next_slot(unit_team: String) -> int:
	var used_slots: Dictionary = {}
	for unit in _units_for_team(unit_team):
		used_slots[int(unit.slot_index)] = true
	for slot in [2, 1, 3]:
		if not used_slots.has(slot):
			return slot
	return _units_for_team(unit_team).size()

func _first_living(units: Array):
	for unit in units:
		if unit != null and unit.hp > 0:
			return unit
	return null

func _remove_defeated_from(units: Array) -> Array:
	var removed: Array = []
	for i in range(units.size() - 1, -1, -1):
		var unit = units[i]
		if unit == null or int(unit.hp) <= 0:
			if unit != null:
				unit.alive = false
				removed.append(unit)
			units.remove_at(i)
	return removed
