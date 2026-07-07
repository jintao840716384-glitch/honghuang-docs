extends RefCounted
class_name EventService

const DeckBuildRulesScript = preload("res://scripts/run/DeckBuildRules.gd")
const CardAcquisitionRulesScript = preload("res://scripts/run/CardAcquisitionRules.gd")
const RewardServiceScript = preload("res://scripts/run/RewardService.gd")


static func roll_event_kind(rng) -> String:
	var roll: float = _rng_float(rng)
	if roll < 0.08:
		return "windfall"
	if roll < 0.38:
		return "trade"
	return "minor"


static func minor_event_offer(job_id: String, realm_index: int, rng, unlock_tier: int) -> Dictionary:
	if _rng_float(rng) < 0.5:
		return {
			"kind": "stone",
			"amount": RewardServiceScript.low_event_stone_reward(realm_index, rng)
		}
	return {
		"kind": "card",
		"card_id": RewardServiceScript.event_card_for_tier("low", job_id, realm_index, rng, unlock_tier)
	}


static func windfall_event_offer(job_id: String, realm_index: int, rng, unlock_tier: int) -> Dictionary:
	if _rng_float(rng) < 0.35:
		return {
			"kind": "stone",
			"amount": RewardServiceScript.high_event_stone_reward(realm_index, rng)
		}
	return {
		"kind": "card",
		"card_id": RewardServiceScript.event_card_for_tier("high", job_id, realm_index, rng, unlock_tier)
	}


static func trade_event_offer(job_id: String, realm_index: int, current_hp: int, reserve_ids: Array, rng, unlock_tier: int) -> Dictionary:
	var result: Dictionary = {
		"stone_option": {
			"cost": 18 + realm_index * 6,
			"card_id": RewardServiceScript.event_card_for_tier("trade", job_id, realm_index, rng, unlock_tier)
		},
		"hp_option": {
			"cost": min(8 + realm_index * 2, max(0, current_hp - 1)),
			"card_id": RewardServiceScript.event_card_for_tier("high", job_id, realm_index, rng, unlock_tier)
		},
		"exchange_option": {},
		"fallback_option": {
			"amount": RewardServiceScript.low_event_stone_reward(realm_index, rng)
		}
	}
	var reserve_index: int = highest_reserve_card_index(reserve_ids)
	if reserve_index >= 0:
		var offered_id: String = str(reserve_ids[reserve_index])
		var offered_cost: int = DeckBuildRulesScript.card_score(offered_id)
		result["exchange_option"] = {
			"reserve_index": reserve_index,
			"offered_id": offered_id,
			"card_id": RewardServiceScript.random_card_by_cost(job_id, rng, offered_cost, offered_cost + 5 + realm_index * 2, unlock_tier)
		}
	return result


static func stone_reward_result(amount: int, spirit_stones: int, message_template: String) -> Dictionary:
	var safe_amount: int = max(0, amount)
	return {
		"success": true,
		"message": message_template % safe_amount,
		"spirit_stones": spirit_stones + safe_amount
	}


static func card_reward_result(card_id: String, deck_ids: Array, score_limit: int, message_prefix: String) -> Dictionary:
	return CardAcquisitionRulesScript.reward_card_result(card_id, deck_ids, score_limit, message_prefix)


static func trade_stone_result(cost: int, card_id: String, spirit_stones: int, deck_ids: Array, score_limit: int) -> Dictionary:
	if spirit_stones < cost:
		return {
			"success": false,
			"message": "灵石不足。可以选择其他代价，或领取保底。",
			"spirit_stones": spirit_stones,
			"destination": "none",
			"card_id": card_id
		}
	var gain_result: Dictionary = CardAcquisitionRulesScript.card_gain_result(card_id, deck_ids, score_limit)
	if not bool(gain_result.get("valid", false)):
		return {
			"success": false,
			"message": str(gain_result.get("message", "未获得卡牌。")),
			"spirit_stones": spirit_stones,
			"destination": "none",
			"card_id": card_id
		}
	return {
		"success": true,
		"message": "试炼交易：支付 %d 灵石，%s" % [cost, str(gain_result.get("message", ""))],
		"spirit_stones": spirit_stones - max(0, cost),
		"destination": str(gain_result.get("destination", "reserve")),
		"reason": str(gain_result.get("reason", "")),
		"card_id": card_id
	}


static func trade_hp_result(cost: int, card_id: String, current_hp: int, deck_ids: Array, score_limit: int) -> Dictionary:
	if cost <= 0 or current_hp - cost <= 0:
		return {
			"success": false,
			"message": "生命不足，无法支付该代价。",
			"current_hp": current_hp,
			"destination": "none",
			"card_id": card_id
		}
	var gain_result: Dictionary = CardAcquisitionRulesScript.card_gain_result(card_id, deck_ids, score_limit)
	if not bool(gain_result.get("valid", false)):
		return {
			"success": false,
			"message": str(gain_result.get("message", "未获得卡牌。")),
			"current_hp": current_hp,
			"destination": "none",
			"card_id": card_id
		}
	return {
		"success": true,
		"message": "试炼交易：损失 %d 生命，%s" % [cost, str(gain_result.get("message", ""))],
		"current_hp": current_hp - cost,
		"destination": str(gain_result.get("destination", "reserve")),
		"reason": str(gain_result.get("reason", "")),
		"card_id": card_id
	}


static func trade_reserve_result(reserve_index: int, offered_id: String, card_id: String, reserve_ids: Array, deck_ids: Array, score_limit: int) -> Dictionary:
	if reserve_index < 0 or reserve_index >= reserve_ids.size():
		return {
			"success": false,
			"message": "备牌区没有可交易的卡。",
			"destination": "none",
			"card_id": card_id,
			"remove_reserve_index": -1
		}
	var actual_offered_id: String = str(reserve_ids[reserve_index])
	if offered_id != "" and offered_id != actual_offered_id:
		return {
			"success": false,
			"message": "交易目标已变化，请重新选择。",
			"destination": "none",
			"card_id": card_id,
			"remove_reserve_index": -1
		}
	var gain_result: Dictionary = CardAcquisitionRulesScript.card_gain_result(card_id, deck_ids, score_limit)
	if not bool(gain_result.get("valid", false)):
		return {
			"success": false,
			"message": str(gain_result.get("message", "未获得卡牌。")),
			"destination": "none",
			"card_id": card_id,
			"remove_reserve_index": -1
		}
	return {
		"success": true,
		"message": "试炼交易：交出 %s，%s" % [actual_offered_id, str(gain_result.get("message", ""))],
		"destination": str(gain_result.get("destination", "reserve")),
		"reason": str(gain_result.get("reason", "")),
		"card_id": card_id,
		"remove_reserve_index": reserve_index
	}


static func highest_reserve_card_index(reserve_ids: Array) -> int:
	var best_index := -1
	var best_score := -1
	for i in range(reserve_ids.size()):
		var card_id: String = str(reserve_ids[i])
		var score: int = DeckBuildRulesScript.card_score(card_id)
		if score > best_score:
			best_score = score
			best_index = i
	return best_index


static func _rng_float(rng) -> float:
	if rng != null and rng.has_method("randf"):
		return float(rng.call("randf"))
	return randf()
