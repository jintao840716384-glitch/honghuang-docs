extends RefCounted
class_name PlayerState

var job_id := ""
var job_name := ""
var max_hp := 0
var hp := 0
var attack := 0
var defense := 0
var sword_momentum := 0
var spell_zone: Array = []
var equipment: Array = []
var equipment_limit := 2
var normal_attack_used := false
var attack_bonus_this_turn := 0
var extra_sword_on_attack_hit := 0
var equipment_attack_bonus := 0
var equipment_defense_bonus := 0
var copy_next_talisman := false
var first_talisman_recycled := false

func setup_from_job(job: Dictionary) -> void:
	job_id = job.get("id", "")
	job_name = job.get("name", "")
	max_hp = int(job.get("max_hp", 0))
	hp = max_hp
	attack = int(job.get("attack", 0))
	defense = int(job.get("defense", 0))
	sword_momentum = 0
	spell_zone.clear()
	equipment.clear()
	equipment_limit = 2
	equipment_attack_bonus = 0
	equipment_defense_bonus = 0
	reset_turn_state()

func start_deck_from_job(job: Dictionary) -> Array:
	return job.get("start_deck", []).duplicate()

func reset_for_battle() -> void:
	sword_momentum = 0
	spell_zone.clear()
	equipment.clear()
	equipment_limit = 2
	equipment_attack_bonus = 0
	equipment_defense_bonus = 0
	copy_next_talisman = false
	first_talisman_recycled = false
	reset_turn_state()

func start_turn() -> void:
	normal_attack_used = false
	attack_bonus_this_turn = 0
	extra_sword_on_attack_hit = 0
	copy_next_talisman = false

func end_turn() -> void:
	attack_bonus_this_turn = 0
	extra_sword_on_attack_hit = 0
	copy_next_talisman = false

func reset_turn_state() -> void:
	normal_attack_used = false
	attack_bonus_this_turn = 0
	extra_sword_on_attack_hit = 0

func current_attack() -> int:
	return attack + equipment_attack_bonus + attack_bonus_this_turn

func current_defense() -> int:
	return defense + equipment_defense_bonus

func has_equipment(card_id: String) -> bool:
	for card in equipment:
		if card.get("id", "") == card_id:
			return true
	return false

func add_sword(amount: int) -> void:
	if job_id == "sword":
		sword_momentum += amount
		if sword_momentum < 0:
			sword_momentum = 0
