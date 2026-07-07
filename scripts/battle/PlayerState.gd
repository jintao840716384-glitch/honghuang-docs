extends "res://scripts/battle/BattleUnit.gd"
class_name PlayerState

const BattleUnitScript = preload("res://scripts/battle/BattleUnit.gd")

var job_id := ""
var job_name := ""
var sword_momentum := 0
var spell_zone: Array = []
var normal_attack_used := false
var attack_bonus_this_turn := 0
var extra_sword_on_attack_hit := 0
var copy_next_talisman := false
var first_talisman_recycled := false
var attack_actions_bonus := 0
var extra_attack_actions_this_turn := 0
var next_attack_all_enemies := false
var next_attack_random_min := 0
var next_attack_random_max := 0
var next_attack_damage_multiplier := 1.0

func setup_from_job(job: Dictionary) -> void:
	job_id = job.get("id", "")
	job_name = job.get("name", "")
	setup_unit({
		"id": job_id,
		"uid": "player",
		"name": job_name,
		"team": BattleUnitScript.TEAM_PLAYER,
		"unit_type": BattleUnitScript.TYPE_PLAYER,
		"unit_rank": BattleUnitScript.RANK_MAIN,
		"unit_tags": job.get("unit_tags", ["主单位", job_name, job_id]).duplicate(),
		"slot_index": 2,
		"max_hp": int(job.get("max_hp", 0)),
		"attack": int(job.get("attack", 0)),
		"defense": int(job.get("defense", 0)),
		"equipment_limit": 2
	}, BattleUnitScript.TEAM_PLAYER, BattleUnitScript.TYPE_PLAYER)
	sword_momentum = 0
	set_resource("sword_momentum", 0)
	spell_zone.clear()
	equipment.clear()
	equipment_limit = 2
	equipment_attack_bonus = 0
	equipment_defense_bonus = 0
	attack_actions_bonus = 0
	extra_attack_actions_this_turn = 0
	clear_next_attack_modifiers()
	reset_turn_state()

func start_deck_from_job(job: Dictionary) -> Array:
	return job.get("start_deck", []).duplicate()

func reset_for_battle() -> void:
	sword_momentum = 0
	set_resource("sword_momentum", 0)
	status_counters.clear()
	temp_attack_delta = 0
	temp_defense_delta = 0
	spell_zone.clear()
	equipment.clear()
	equipment_limit = 2
	equipment_attack_bonus = 0
	equipment_defense_bonus = 0
	copy_next_talisman = false
	first_talisman_recycled = false
	attack_actions_bonus = 0
	extra_attack_actions_this_turn = 0
	clear_next_attack_modifiers()
	reset_turn_state()

func start_turn() -> void:
	normal_attack_used = false
	attack_bonus_this_turn = 0
	extra_sword_on_attack_hit = 0
	copy_next_talisman = false
	extra_attack_actions_this_turn = 0

func end_turn() -> void:
	attack_bonus_this_turn = 0
	extra_sword_on_attack_hit = 0
	copy_next_talisman = false
	extra_attack_actions_this_turn = 0

func reset_turn_state() -> void:
	normal_attack_used = false
	attack_bonus_this_turn = 0
	extra_sword_on_attack_hit = 0
	extra_attack_actions_this_turn = 0

func current_attack() -> int:
	return max(0, attack + temp_attack_delta + equipment_attack_bonus + attack_bonus_this_turn - get_status("虚弱"))

func current_defense() -> int:
	return max(0, defense + temp_defense_delta + equipment_defense_bonus - get_status("破甲"))

func has_equipment(card_id: String) -> bool:
	for card in equipment:
		if card.get("id", "") == card_id:
			return true
	return false

func add_sword(amount: int) -> void:
	if job_id == "sword":
		sword_momentum = add_resource("sword_momentum", amount)

func basic_attack_limit() -> int:
	return max(1, 1 + attack_actions_bonus + extra_attack_actions_this_turn)

func has_next_attack_modifier() -> bool:
	return next_attack_all_enemies or next_attack_random_max > 0 or next_attack_damage_multiplier > 1.0

func clear_next_attack_modifiers() -> void:
	next_attack_all_enemies = false
	next_attack_random_min = 0
	next_attack_random_max = 0
	next_attack_damage_multiplier = 1.0
