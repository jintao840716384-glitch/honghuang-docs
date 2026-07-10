extends RefCounted
class_name RunViewModel

const RunSnapshotScript = preload("res://scripts/run/RunSnapshot.gd")

var _state
var _snapshot
var job_id:
	get: return _snapshot.job_id
var job_name:
	get: return _snapshot.job_name
var player_name:
	get: return _snapshot.player_name
var current_hp:
	get: return _snapshot.current_hp
var max_hp:
	get: return _snapshot.max_hp
var draw_per_turn:
	get: return _snapshot.draw_per_turn
var spirit_stones:
	get: return _snapshot.spirit_stones
var run_cultivation_base:
	get: return _snapshot.run_cultivation_base
var deck_score_limit:
	get: return _snapshot.deck_score_limit
var deck_ids:
	get: return _snapshot.deck_ids.duplicate(true)
var reserve_ids:
	get: return _snapshot.reserve_ids.duplicate(true)
var map_nodes:
	get: return _snapshot.map_nodes.duplicate(true)
var status_message:
	get: return _snapshot.status_message
var campaign_complete:
	get: return _snapshot.campaign_complete


func _init(state) -> void:
	_state = state
	refresh()


func refresh() -> void:
	_snapshot = RunSnapshotScript.new().capture(_state)


func snapshot():
	refresh()
	return _snapshot


func current_story_layer_number() -> int: return _snapshot.current_story_layer_number
func main_story_layer_count() -> int: return _snapshot.main_story_layer_count
func realm_name() -> String: return _snapshot.realm_name
func realm_bonus_summary() -> String: return _snapshot.realm_bonus_summary
func current_deck_score() -> int: return _snapshot.current_deck_score
func is_complete() -> bool: return _snapshot.complete
func available_node_ids() -> Dictionary: return _snapshot.available_node_ids.duplicate(true)
func is_node_completed(node_id: String) -> bool: return _snapshot.completed_node_ids.has(node_id)
func is_node_available(node_id: String) -> bool: return _snapshot.available_node_ids.has(node_id)


func get_node_data(node_id: String) -> Dictionary:
	for node_variant in _snapshot.map_nodes:
		var node: Dictionary = node_variant
		if str(node.get("id", "")) == node_id:
			return node.duplicate(true)
	return {}


func set_status_message(message: String) -> void:
	_state.status_message = message
	refresh()


func complete_node(node_id: String) -> void:
	_state.complete_node(node_id)
	refresh()


func roll_event_id() -> String: return str(_state.roll_event_id())
func minor_event_offer() -> Dictionary: return (_state.minor_event_offer() as Dictionary).duplicate(true)
func windfall_event_offer() -> Dictionary: return (_state.windfall_event_offer() as Dictionary).duplicate(true)
func trade_event_offer() -> Dictionary: return (_state.trade_event_offer() as Dictionary).duplicate(true)
func treasure_card_rewards(count := -1) -> Array: return _state.treasure_card_rewards(count).duplicate(true)
func shop_start_refresh_cost() -> int: return int(_state.shop_start_refresh_cost())
func generate_shop_stock(count := 6) -> Array: return _state.generate_shop_stock(count).duplicate(true)
func shop_sell_price(card_id: String) -> int: return int(_state.shop_sell_price(card_id))


func apply_event_stone_reward(amount: int, message_template: String) -> Dictionary:
	var result: Dictionary = _state.apply_event_stone_reward(amount, message_template)
	refresh()
	return result.duplicate(true)


func apply_event_card_reward(card_id: String, message_prefix: String) -> Dictionary:
	var result: Dictionary = _state.apply_event_card_reward(card_id, message_prefix)
	refresh()
	return result.duplicate(true)


func apply_trade_stone_reward(cost: int, card_id: String) -> Dictionary:
	var result: Dictionary = _state.apply_trade_stone_reward(cost, card_id)
	refresh()
	return result.duplicate(true)


func apply_trade_hp_reward(cost: int, card_id: String) -> Dictionary:
	var result: Dictionary = _state.apply_trade_hp_reward(cost, card_id)
	refresh()
	return result.duplicate(true)


func apply_trade_reserve_reward(reserve_index: int, offered_id: String, card_id: String) -> Dictionary:
	var result: Dictionary = _state.apply_trade_reserve_reward(reserve_index, offered_id, card_id)
	refresh()
	return result.duplicate(true)


func apply_treasure_card_reward(card_id: String) -> Dictionary:
	var result: Dictionary = _state.apply_treasure_card_reward(card_id)
	refresh()
	return result.duplicate(true)


func refresh_shop_stock(current_refresh_cost: int, count := 6) -> Dictionary:
	var result: Dictionary = _state.refresh_shop_stock(current_refresh_cost, count)
	refresh()
	return result.duplicate(true)


func buy_shop_card(card_id: String, price: int) -> Dictionary:
	var result: Dictionary = _state.buy_shop_card(card_id, price)
	refresh()
	return result.duplicate(true)


func sell_reserve_card(index: int) -> Dictionary:
	var result: Dictionary = _state.sell_reserve_card(index)
	refresh()
	return result.duplicate(true)


func apply_rest() -> Dictionary:
	var result: Dictionary = _state.apply_rest()
	refresh()
	return result.duplicate(true)


func apply_deck_build(new_deck_ids: Array, new_reserve_ids: Array) -> String:
	var result := str(_state.apply_deck_build(new_deck_ids, new_reserve_ids))
	refresh()
	return result
