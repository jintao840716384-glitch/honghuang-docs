extends RefCounted
class_name BattleContext

var context_id := "battle_0"
var request_sequence := 0
var player
var enemy
var formation
var player_side
var enemy_side
var deck
var job_id := ""
var battle_number := 1
var turn_number := 0
var phase := "player"
var master_deck_ids: Array = []
var master_reserve_ids: Array = []
var reward_options: Array = []
var pending_choice: Dictionary = {}
var pending_equipment_replace: Dictionary = {}
var messages: Array = []
var rng := RandomNumberGenerator.new()
var current_event: Dictionary = {}
var chain_stack: Array = []
var response_loop_guard := 0
var response_chain_state := "resolved"
var response_skipped := false
var response_window_owner_side := "player"
var active_response_side := "player"
var response_pass_state: Dictionary = {}
var auto_advance_after_reward := true
var current_encounter_type := "normal"
var current_realm_index := 0
var current_realm_name := "练气"
var draw_per_turn := 1
var deck_score_limit := 0
var meta_bonuses: Dictionary = {}
var selected_enemy_uid := ""
var selected_player_uid := ""
var selected_debug_uid := ""
var pending_target_action: Dictionary = {}
var enemy_action_queue: Array = []
var player_unit_actions_used: Dictionary = {}
var active_enemy_unit
var current_enemy_deck_profile: Dictionary = {}
var current_encounter_profile: Dictionary = {}
var enemy_cards_played_this_turn := 0
var current_world_difficulty := 0
var last_result: Dictionary = {}
var collecting_result_events := false
var request_events: Array = []


func begin_battle_identity(next_battle_number: int) -> void:
	context_id = "battle_%d" % max(1, next_battle_number)
	request_sequence = 0
	last_result.clear()
	request_events.clear()
	collecting_result_events = false


func next_request_id() -> String:
	request_sequence += 1
	return "%s_request_%d" % [context_id, request_sequence]
