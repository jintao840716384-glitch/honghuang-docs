extends RefCounted
class_name RunSnapshot

var job_id := ""
var job_name := ""
var player_name := ""
var current_hp := 0
var max_hp := 0
var draw_per_turn := 1
var spirit_stones := 0
var run_cultivation_base := 0
var deck_score_limit := 0
var deck_ids: Array = []
var reserve_ids: Array = []
var map_nodes: Array = []
var status_message := ""
var campaign_complete := false
var realm_name := ""
var realm_bonus_summary := ""
var current_deck_score := 0
var current_story_layer_number := 1
var main_story_layer_count := 3
var complete := false
var available_node_ids: Dictionary = {}
var completed_node_ids: Dictionary = {}


func capture(state):
	if state == null:
		return self
	job_id = str(state.job_id)
	job_name = str(state.job_name)
	player_name = str(state.player_name)
	current_hp = int(state.current_hp)
	max_hp = int(state.max_hp)
	draw_per_turn = int(state.draw_per_turn)
	spirit_stones = int(state.spirit_stones)
	run_cultivation_base = int(state.run_cultivation_base)
	deck_score_limit = int(state.deck_score_limit)
	deck_ids = state.deck_ids.duplicate(true)
	reserve_ids = state.reserve_ids.duplicate(true)
	map_nodes = state.map_nodes.duplicate(true)
	status_message = str(state.status_message)
	campaign_complete = bool(state.campaign_complete)
	realm_name = str(state.realm_name())
	realm_bonus_summary = str(state.realm_bonus_summary())
	current_deck_score = int(state.current_deck_score())
	current_story_layer_number = int(state.current_story_layer_number())
	main_story_layer_count = int(state.main_story_layer_count())
	complete = bool(state.is_complete())
	available_node_ids = state.available_node_ids().duplicate(true)
	completed_node_ids = state.completed_node_ids.duplicate(true)
	return self
