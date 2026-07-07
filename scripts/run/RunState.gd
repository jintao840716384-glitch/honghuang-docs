extends RefCounted
class_name RunState

const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const CardPoolDatabaseScript = preload("res://scripts/data/CardPoolDatabase.gd")
const MetaProgressionScript = preload("res://scripts/data/MetaProgression.gd")
const ProgressionDatabaseScript = preload("res://scripts/data/ProgressionDatabase.gd")
const MapGeneratorScript = preload("res://scripts/run/MapGenerator.gd")
const DeckBuildRulesScript = preload("res://scripts/run/DeckBuildRules.gd")
const CardAcquisitionRulesScript = preload("res://scripts/run/CardAcquisitionRules.gd")
const RewardServiceScript = preload("res://scripts/run/RewardService.gd")
const ShopServiceScript = preload("res://scripts/run/ShopService.gd")
const EventServiceScript = preload("res://scripts/run/EventService.gd")
const ExplorationRulesScript = preload("res://scripts/run/ExplorationRules.gd")

const MAIN_STORY_LAYER_COUNT := 3
const LAYER_RULES := [
	{"name": "第一层", "max_hp_bonus": 0, "draw_per_turn": 1, "deck_score_limit": 20},
	{"name": "第二层", "max_hp_bonus": 0, "draw_per_turn": 1, "deck_score_limit": 20},
	{"name": "第三层", "max_hp_bonus": 0, "draw_per_turn": 1, "deck_score_limit": 20}
]

var job_id := ""
var job_name := ""
var player_name := "无名修士"
var realm_index := 0
var base_max_hp := 0
var max_hp := 0
var current_hp := 0
var draw_per_turn := 1
var deck_score_limit := 0
var spirit_stones := 0
var run_cultivation_base := 0
var run_cultivation_awarded := 0
var run_cultivation_completed := false
var run_cultivation_settled := false
var world_difficulty := 0
var deck_ids: Array = []
var reserve_ids: Array = []
var map_nodes: Array = []
var completed_node_ids: Dictionary = {}
var current_node_id := ""
var pending_node_id := ""
var campaign_complete := false
var status_message := ""
var rng := RandomNumberGenerator.new()
var meta_progression
var meta_bonuses: Dictionary = {}

func start(selected_job_id: String, starting_deck_ids: Array = [], starting_reserve_ids: Array = []) -> void:
	rng.randomize()
	job_id = selected_job_id
	meta_progression = MetaProgressionScript.new()
	meta_progression.load()
	meta_bonuses = meta_progression.bonuses_for_job(job_id)
	var job := JobDatabaseScript.get_job(job_id)
	job_name = str(job.get("name", job_id))
	realm_index = 0
	spirit_stones = 0
	run_cultivation_base = 0
	run_cultivation_awarded = 0
	run_cultivation_completed = false
	run_cultivation_settled = false
	world_difficulty = 0
	base_max_hp = int(job.get("max_hp", 0)) + int(meta_bonuses.get("max_hp", 0))
	deck_ids = starting_deck_ids.duplicate() if not starting_deck_ids.is_empty() else job.get("start_deck", []).duplicate()
	reserve_ids = starting_reserve_ids.duplicate()
	map_nodes = MapGeneratorScript.generate()
	completed_node_ids.clear()
	current_node_id = ""
	pending_node_id = ""
	campaign_complete = false
	status_message = "以%s开始第 1 / %d 层探索。" % [realm_name(), MAIN_STORY_LAYER_COUNT]
	_apply_realm_stats(true)
	if deck_build_block_reason(deck_ids) != "":
		deck_ids = job.get("start_deck", []).duplicate()
		reserve_ids.clear()

func available_nodes() -> Array:
	var ids := available_node_ids()
	var result: Array = []
	for node in map_nodes:
		if ids.has(str(node.get("id", ""))):
			result.append(node)
	return result

func available_node_ids() -> Dictionary:
	var result: Dictionary = {}
	if current_hp <= 0:
		return result
	if campaign_complete or is_complete():
		return result
	if current_node_id == "":
		for node in map_nodes:
			if int(node.get("floor", 0)) == 0:
				result[str(node.get("id", ""))] = true
		return result

	var current_node := get_node_data(current_node_id)
	for next_id in current_node.get("next", []):
		var id := str(next_id)
		if not completed_node_ids.has(id):
			result[id] = true
	return result

func begin_node(node_id: String) -> void:
	if current_hp <= 0:
		status_message = "生命为 0，本轮探索已失败。"
		return
	if is_node_available(node_id):
		pending_node_id = node_id
		status_message = ""

func complete_node(node_id: String) -> void:
	if node_id == "":
		return
	var completion_result: Dictionary = ExplorationRulesScript.node_completion_result(
		get_node_data(node_id),
		completed_node_ids.has(node_id),
		run_cultivation_base
	)
	run_cultivation_base = int(completion_result.get("cultivation_base", run_cultivation_base))
	completed_node_ids[node_id] = true
	current_node_id = node_id
	pending_node_id = ""

func update_deck(new_deck_ids: Array) -> void:
	deck_ids = new_deck_ids.duplicate()

func update_reserve(new_reserve_ids: Array) -> void:
	reserve_ids = new_reserve_ids.duplicate()

func add_spirit_stones(amount: int) -> void:
	if amount <= 0:
		return
	spirit_stones += amount

func spend_spirit_stones(amount: int) -> bool:
	if amount <= 0:
		return true
	if spirit_stones < amount:
		return false
	spirit_stones -= amount
	return true

func battle_spirit_reward(node: Dictionary) -> int:
	return RewardServiceScript.battle_spirit_reward(realm_index, node)

func cultivation_reward_for_node(node: Dictionary) -> int:
	return ExplorationRulesScript.cultivation_reward_for_node(node)

func gain_reward_card(card_id: String) -> String:
	var result: Dictionary = CardAcquisitionRulesScript.card_gain_result(card_id, deck_ids, deck_score_limit)
	match str(result.get("destination", "none")):
		"deck":
			deck_ids.append(card_id)
		"reserve":
			reserve_ids.append(card_id)
		_:
			return str(result.get("message", "未获得卡牌。"))
	return str(result.get("message", "未获得卡牌。"))

func apply_treasure_card_reward(card_id: String) -> Dictionary:
	var result: Dictionary = CardAcquisitionRulesScript.reward_card_result(card_id, deck_ids, deck_score_limit, "宝箱")
	_apply_card_reward_result(result)
	return result

func generate_shop_stock(count := 6) -> Array:
	return ShopServiceScript.generate_stock(job_id, realm_index, rng, count, card_unlock_tier())

func shop_start_refresh_cost() -> int:
	return ShopServiceScript.start_refresh_cost()

func refresh_shop_stock(current_refresh_cost: int, count := 6) -> Dictionary:
	var result: Dictionary = ShopServiceScript.refresh_result(spirit_stones, current_refresh_cost, job_id, realm_index, rng, count, card_unlock_tier())
	if bool(result.get("success", false)):
		spirit_stones = int(result.get("spirit_stones", spirit_stones))
	return result

func buy_shop_card(card_id: String, price: int) -> Dictionary:
	var result: Dictionary = ShopServiceScript.buy_card_result(card_id, price, spirit_stones, deck_ids, deck_score_limit)
	if not bool(result.get("success", false)):
		return result
	spirit_stones = int(result.get("spirit_stones", spirit_stones))
	match str(result.get("destination", "none")):
		"deck":
			deck_ids.append(card_id)
		"reserve":
			reserve_ids.append(card_id)
	return result

func shop_sell_price(card_id: String) -> int:
	return ShopServiceScript.sell_price(card_id)

func sell_reserve_card(index: int) -> Dictionary:
	if index < 0 or index >= reserve_ids.size():
		return {
			"success": false,
			"message": "无效卡牌",
			"spirit_stones": spirit_stones,
			"card_id": "",
			"price": 0
		}
	var card_id: String = str(reserve_ids[index])
	var result: Dictionary = ShopServiceScript.sell_card_result(card_id, spirit_stones)
	if bool(result.get("success", false)):
		reserve_ids.remove_at(index)
		spirit_stones = int(result.get("spirit_stones", spirit_stones))
	return result

func random_card_by_cost(min_cost: int, max_cost: int) -> String:
	return RewardServiceScript.random_card_by_cost(job_id, rng, min_cost, max_cost, card_unlock_tier())

func low_event_stone_reward() -> int:
	return RewardServiceScript.low_event_stone_reward(realm_index, rng)

func high_event_stone_reward() -> int:
	return RewardServiceScript.high_event_stone_reward(realm_index, rng)

func treasure_card_reward() -> String:
	return RewardServiceScript.treasure_card_reward(job_id, realm_index, rng, card_unlock_tier())

func treasure_card_rewards(count := 3) -> Array:
	return RewardServiceScript.treasure_card_rewards(job_id, realm_index, rng, card_unlock_tier(), count)

func event_card_for_tier(tier: String) -> String:
	return RewardServiceScript.event_card_for_tier(tier, job_id, realm_index, rng, card_unlock_tier())

func roll_event_kind() -> String:
	return EventServiceScript.roll_event_kind(rng)

func minor_event_offer() -> Dictionary:
	return EventServiceScript.minor_event_offer(job_id, realm_index, rng, card_unlock_tier())

func windfall_event_offer() -> Dictionary:
	return EventServiceScript.windfall_event_offer(job_id, realm_index, rng, card_unlock_tier())

func trade_event_offer() -> Dictionary:
	return EventServiceScript.trade_event_offer(job_id, realm_index, current_hp, reserve_ids, rng, card_unlock_tier())

func apply_event_stone_reward(amount: int, message_template: String) -> Dictionary:
	var result: Dictionary = EventServiceScript.stone_reward_result(amount, spirit_stones, message_template)
	if bool(result.get("success", false)):
		spirit_stones = int(result.get("spirit_stones", spirit_stones))
	return result

func apply_event_card_reward(card_id: String, message_prefix: String) -> Dictionary:
	var result: Dictionary = EventServiceScript.card_reward_result(card_id, deck_ids, deck_score_limit, message_prefix)
	_apply_card_reward_result(result)
	return result

func apply_trade_stone_reward(cost: int, card_id: String) -> Dictionary:
	var result: Dictionary = EventServiceScript.trade_stone_result(cost, card_id, spirit_stones, deck_ids, deck_score_limit)
	if bool(result.get("success", false)):
		spirit_stones = int(result.get("spirit_stones", spirit_stones))
		_apply_card_reward_result(result)
	return result

func apply_trade_hp_reward(cost: int, card_id: String) -> Dictionary:
	var result: Dictionary = EventServiceScript.trade_hp_result(cost, card_id, current_hp, deck_ids, deck_score_limit)
	if bool(result.get("success", false)):
		current_hp = clampi(int(result.get("current_hp", current_hp)), 0, max_hp)
		_apply_card_reward_result(result)
	return result

func apply_trade_reserve_reward(reserve_index: int, offered_id: String, card_id: String) -> Dictionary:
	var result: Dictionary = EventServiceScript.trade_reserve_result(reserve_index, offered_id, card_id, reserve_ids, deck_ids, deck_score_limit)
	if bool(result.get("success", false)):
		var remove_index: int = int(result.get("remove_reserve_index", -1))
		if remove_index >= 0 and remove_index < reserve_ids.size():
			reserve_ids.remove_at(remove_index)
		_apply_card_reward_result(result)
	return result

func apply_rest() -> Dictionary:
	var result: Dictionary = ExplorationRulesScript.rest_result(max_hp)
	if bool(result.get("success", false)):
		current_hp = clampi(int(result.get("current_hp", current_hp)), 0, max_hp)
	return result

func full_heal() -> void:
	current_hp = max_hp

func move_deck_card_to_reserve(index: int) -> String:
	if index < 0 or index >= deck_ids.size():
		return "无效卡牌"
	var card_id := str(deck_ids[index])
	deck_ids.remove_at(index)
	reserve_ids.append(card_id)
	return ""

func move_reserve_card_to_deck(index: int) -> String:
	if index < 0 or index >= reserve_ids.size():
		return "无效卡牌"
	var card_id := str(reserve_ids[index])
	if not DeckBuildRulesScript.can_add_card_to_deck(card_id, deck_ids, deck_score_limit):
		return DeckBuildRulesScript.deck_add_block_reason(card_id, deck_ids, deck_score_limit)
	reserve_ids.remove_at(index)
	deck_ids.append(card_id)
	return ""

func apply_deck_build(new_deck_ids: Array, new_reserve_ids: Array) -> String:
	var reason := deck_build_block_reason(new_deck_ids)
	if reason != "":
		return reason
	deck_ids = new_deck_ids.duplicate()
	reserve_ids = new_reserve_ids.duplicate()
	status_message = "卡组已保存。"
	return ""

func deck_build_block_reason(candidate_deck_ids: Array) -> String:
	return DeckBuildRulesScript.deck_build_block_reason(candidate_deck_ids, deck_score_limit)

func battle_start_block_reason() -> String:
	if current_hp <= 0:
		return "生命为 0，不能进入战斗。"
	var reason := deck_build_block_reason(deck_ids)
	if reason != "":
		return "%s不能进入战斗。" % reason
	return ""

func battle_start_payload(node_id: String) -> Dictionary:
	if not is_node_available(node_id):
		return {
			"success": false,
			"message": "节点不可用。"
		}
	var block_reason: String = battle_start_block_reason()
	if block_reason != "":
		status_message = block_reason
		return {
			"success": false,
			"message": block_reason
		}
	begin_node(node_id)
	var node: Dictionary = get_node_data(node_id)
	return {
		"success": true,
		"node_id": node_id,
		"job_id": job_id,
		"deck_ids": deck_ids.duplicate(),
		"battle_number": battle_number_for_node(node),
		"encounter_type": str(node.get("type", "normal")),
		"run_context": run_context(),
		"spirit_reward": battle_spirit_reward(node)
	}

func apply_battle_completion(node_id: String, new_deck_ids: Array, new_reserve_ids: Array, player_hp: int, player_max_hp: int, save_settlement_after: bool = true) -> Dictionary:
	if node_id == "":
		return {
			"success": false,
			"flow": "map",
			"message": "无效节点。"
		}
	var completed_node: Dictionary = get_node_data(node_id)
	if completed_node.is_empty():
		return {
			"success": false,
			"flow": "map",
			"message": "节点不存在。"
		}
	update_deck(new_deck_ids)
	update_reserve(new_reserve_ids)
	update_life(player_hp, player_max_hp)
	var stone_reward: int = battle_spirit_reward(completed_node)
	add_spirit_stones(stone_reward)
	complete_node(node_id)
	var result: Dictionary = {
		"success": true,
		"flow": "map",
		"node_id": node_id,
		"node_type": str(completed_node.get("type", "normal")),
		"spirit_stones": stone_reward,
		"message": "",
		"settlement": {}
	}
	if str(completed_node.get("type", "")) == "boss":
		if advance_to_next_story_layer():
			result["advanced_layer"] = true
			result["message"] = status_message
			return result
		var settlement: Dictionary = finish_run_and_save_progression(save_settlement_after)
		result["flow"] = "settlement"
		result["settlement"] = settlement
		result["message"] = status_message
		return result
	status_message = "战斗胜利，继续选择下一个节点。"
	result["message"] = status_message
	return result

func abandon_run(save_after: bool = true) -> Dictionary:
	return finish_run_and_save_progression(save_after, false)

func update_life(new_current_hp: int, new_max_hp := -1) -> void:
	if new_max_hp > 0:
		max_hp = new_max_hp
	current_hp = clampi(new_current_hp, 0, max_hp)

func advance_realm() -> bool:
	return advance_to_next_story_layer()

func advance_to_next_story_layer() -> bool:
	if is_final_story_layer():
		return false
	realm_index += 1
	map_nodes = MapGeneratorScript.generate()
	completed_node_ids.clear()
	current_node_id = ""
	pending_node_id = ""
	active_layer_full_heal()
	status_message = "进入第 %d / %d 层。击败本层首领后继续推进主线。" % [current_story_layer_number(), MAIN_STORY_LAYER_COUNT]
	return true

func active_layer_full_heal() -> void:
	_apply_realm_stats(true)

func finish_run_and_save_progression(save_after: bool = true, completed: bool = true) -> Dictionary:
	if meta_progression == null:
		meta_progression = MetaProgressionScript.new()
		meta_progression.load()
	if run_cultivation_settled:
		return {
			"base": run_cultivation_base,
			"multiplier": ProgressionDatabaseScript.layer_multiplier(realm_index),
			"awarded": run_cultivation_awarded,
			"completed": run_cultivation_completed
		}
	var result: Dictionary = ExplorationRulesScript.run_settlement_result(run_cultivation_base, realm_index, completed)
	var awarded: int = int(result.get("awarded", 0))
	run_cultivation_awarded = awarded
	run_cultivation_completed = completed
	run_cultivation_settled = true
	meta_progression.add_points(job_id, awarded, save_after)
	campaign_complete = true
	status_message = str(result.get("message", ""))
	return result

func is_node_completed(node_id: String) -> bool:
	return completed_node_ids.has(node_id)

func is_node_available(node_id: String) -> bool:
	return available_node_ids().has(node_id)

func is_complete() -> bool:
	if campaign_complete:
		return true
	if current_node_id == "" or not completed_node_ids.has(current_node_id):
		return false
	var node := get_node_data(current_node_id)
	return str(node.get("type", "")) == "boss" and is_final_story_layer()

func is_final_story_layer() -> bool:
	return realm_index >= MAIN_STORY_LAYER_COUNT - 1

func current_story_layer_number() -> int:
	return clampi(realm_index + 1, 1, MAIN_STORY_LAYER_COUNT)

func main_story_layer_count() -> int:
	return MAIN_STORY_LAYER_COUNT

func realm_name() -> String:
	if meta_progression != null:
		return meta_progression.title_with_job(job_id, job_name)
	return "%s%s" % [str(_realm_data().get("name", "练气")), job_name]

func current_deck_score() -> int:
	return DeckBuildRulesScript.deck_score(deck_ids)

func run_context() -> Dictionary:
	return {
		"current_hp": current_hp,
		"max_hp": max_hp,
		"draw_per_turn": draw_per_turn,
		"deck_score_limit": deck_score_limit,
		"spirit_stones": spirit_stones,
		"reserve_ids": reserve_ids.duplicate(),
		"realm_index": realm_index,
		"realm_name": realm_name(),
		"world_difficulty": world_difficulty,
		"meta_bonuses": meta_bonuses.duplicate(true)
	}

func realm_bonus_summary() -> String:
	var parts: Array = []
	var hp_bonus := int(meta_bonuses.get("max_hp", 0))
	if hp_bonus > 0:
		parts.append("最大生命 +%d" % hp_bonus)
	var attack_bonus := int(meta_bonuses.get("attack", 0))
	if attack_bonus > 0:
		parts.append("攻击 +%d" % attack_bonus)
	var defense_bonus := int(meta_bonuses.get("defense", 0))
	if defense_bonus > 0:
		parts.append("防御 +%d" % defense_bonus)
	parts.append("基础抽牌 %d" % draw_per_turn)
	parts.append("分数上限 %d" % deck_score_limit)
	var starting_sword := int(meta_bonuses.get("starting_sword", 0))
	if starting_sword > 0:
		parts.append("开局剑势 +%d" % starting_sword)
	parts.append("卡包：%s" % card_pack_summary())
	return "；".join(parts)

func card_unlock_tier() -> int:
	return int(meta_bonuses.get("card_unlock_tier", 0))

func unlocked_card_packs() -> Array:
	return CardPoolDatabaseScript.unlocked_packs_for_job(job_id, card_unlock_tier())

func card_pack_summary() -> String:
	var names: Array = []
	for pack_id_variant in unlocked_card_packs():
		names.append(CardPoolDatabaseScript.pack_display_name(str(pack_id_variant)))
	return "、".join(names)

func battle_number_for_node(node: Dictionary) -> int:
	return int(node.get("floor", 0)) + 1

func get_node_data(node_id: String) -> Dictionary:
	for node in map_nodes:
		if str(node.get("id", "")) == node_id:
			return node
	return {}

func _apply_realm_stats(full_heal: bool) -> void:
	var realm := _realm_data()
	max_hp = base_max_hp + int(realm.get("max_hp_bonus", 0))
	draw_per_turn = max(1, int(realm.get("draw_per_turn", 1)) + int(meta_bonuses.get("draw_per_turn", 0)))
	deck_score_limit = int(realm.get("deck_score_limit", 0)) + int(meta_bonuses.get("deck_score_limit", 0))
	if full_heal:
		current_hp = max_hp
	else:
		current_hp = clampi(current_hp, 1, max_hp)

func _format_multiplier(value: float) -> String:
	if is_equal_approx(value, floor(value)):
		return "%d" % int(value)
	return "%.2f" % value

func _realm_data() -> Dictionary:
	if LAYER_RULES.is_empty():
		return {}
	var index := clampi(realm_index, 0, LAYER_RULES.size() - 1)
	return LAYER_RULES[index]

func _apply_card_reward_result(result: Dictionary) -> void:
	if not bool(result.get("success", false)):
		return
	var card_id: String = str(result.get("card_id", ""))
	match str(result.get("destination", "none")):
		"deck":
			deck_ids.append(card_id)
		"reserve":
			reserve_ids.append(card_id)
