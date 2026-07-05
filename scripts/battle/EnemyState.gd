extends RefCounted
class_name EnemyState

var name := ""
var enemy_id := ""
var max_hp := 0
var hp := 0
var attack := 0
var defense := 0
var temp_defense_delta := 0
var actions: Array = []
var action_index := 0
var current_intent := ""

func setup(data: Dictionary) -> void:
	enemy_id = data.get("id", "")
	name = data.get("name", "")
	max_hp = int(data.get("max_hp", 0))
	hp = max_hp
	attack = int(data.get("attack", 0))
	defense = int(data.get("defense", 0))
	temp_defense_delta = 0
	actions = data.get("action_sequence", []).duplicate(true)
	action_index = 0
	current_intent = peek_action().get("intent", "")

func current_defense() -> int:
	return defense + temp_defense_delta

func peek_action() -> Dictionary:
	if actions.is_empty():
		return {}
	return actions[action_index % actions.size()]

func next_action() -> Dictionary:
	var action := peek_action()
	action_index += 1
	current_intent = peek_action().get("intent", "")
	return action

func clear_temporary_defense() -> void:
	temp_defense_delta = 0
