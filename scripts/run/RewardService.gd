extends RefCounted
class_name RewardService

const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const CardPoolDatabaseScript = preload("res://scripts/data/CardPoolDatabase.gd")
const CardAcquisitionRulesScript = preload("res://scripts/run/CardAcquisitionRules.gd")
const ExplorationRulesScript = preload("res://scripts/run/ExplorationRules.gd")
const MapContentDatabaseScript = preload("res://scripts/data/MapContentDatabase.gd")


static func battle_spirit_reward(realm_index: int, node: Dictionary) -> int:
	var base: int = 10 + realm_index * 3
	match str(node.get("type", "normal")):
		"elite":
			return base + 8
		"boss":
			return base + 20
	return base


static func cultivation_reward_for_node(node: Dictionary) -> int:
	return ExplorationRulesScript.cultivation_reward_for_node(node)


static func card_gain_result(card_id: String, deck_ids: Array, score_limit := 0) -> Dictionary:
	return CardAcquisitionRulesScript.card_gain_result(CardDatabaseScript.normalize_card_id(card_id), deck_ids, score_limit)


static func reward_card_result(card_id: String, deck_ids: Array, score_limit: int, message_prefix: String) -> Dictionary:
	return CardAcquisitionRulesScript.reward_card_result(CardDatabaseScript.normalize_card_id(card_id), deck_ids, score_limit, message_prefix)


static func battle_card_rewards(job_id: String, encounter_type: String, unlock_tier: int, rng, count := 3) -> Array:
	var pool: Array = CardPoolDatabaseScript.reward_pool_for_job(job_id, encounter_type, unlock_tier)
	var rewards: Array = []
	var attempts := 0
	while rewards.size() < count and attempts < 100 and not pool.is_empty():
		attempts += 1
		var card_id: String = str(pool[_rng_range(rng, 0, pool.size() - 1)])
		if not rewards.has(card_id):
			rewards.append(card_id)
	return rewards


static func random_card_by_cost(job_id: String, rng, min_cost: int, max_cost: int, unlock_tier: int) -> String:
	return CardPoolDatabaseScript.random_reward_card(job_id, rng, min_cost, max_cost, unlock_tier)


static func low_event_stone_reward(realm_index: int, rng) -> int:
	return 8 + realm_index * 3 + _rng_range(rng, 0, 6)


static func high_event_stone_reward(realm_index: int, rng) -> int:
	return 24 + realm_index * 8 + _rng_range(rng, 0, 12)


static func treasure_card_reward(job_id: String, realm_index: int, rng, unlock_tier: int) -> String:
	return random_card_by_cost(job_id, rng, 1 + realm_index, 8 + realm_index * 3, unlock_tier)


static func treasure_card_rewards(job_id: String, realm_index: int, rng, unlock_tier: int, count := -1) -> Array:
	var result: Array = []
	var target_count := count
	if target_count < 0:
		target_count = int(MapContentDatabaseScript.active_treasure().get("choice_count", 3))
	var attempts := 0
	while result.size() < target_count and attempts < 60:
		attempts += 1
		var card_id: String = treasure_card_reward(job_id, realm_index, rng, unlock_tier)
		if card_id != "" and not result.has(card_id):
			result.append(card_id)
	return result


static func event_card_for_tier(tier: String, job_id: String, realm_index: int, rng, unlock_tier: int) -> String:
	match tier:
		"high":
			return random_card_by_cost(job_id, rng, 8 + realm_index * 2, 15 + realm_index * 4, unlock_tier)
		"trade":
			return random_card_by_cost(job_id, rng, 5 + realm_index * 2, 12 + realm_index * 4, unlock_tier)
	return random_card_by_cost(job_id, rng, 0, 5 + realm_index * 2, unlock_tier)


static func _rng_range(rng, from_value: int, to_value: int) -> int:
	if to_value <= from_value:
		return from_value
	if rng != null and rng.has_method("randi_range"):
		return int(rng.call("randi_range", from_value, to_value))
	return randi_range(from_value, to_value)
