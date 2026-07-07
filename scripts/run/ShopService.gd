extends RefCounted
class_name ShopService

const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const CardPoolDatabaseScript = preload("res://scripts/data/CardPoolDatabase.gd")
const CardAcquisitionRulesScript = preload("res://scripts/run/CardAcquisitionRules.gd")

const START_REFRESH_COST := 8


static func start_refresh_cost() -> int:
	return START_REFRESH_COST


static func next_refresh_cost(current_cost: int) -> int:
	return max(1, current_cost) * 2


static func generate_stock(job_id: String, realm_index: int, rng, count := 6, unlock_tier := 0) -> Array:
	return CardPoolDatabaseScript.shop_stock(job_id, realm_index, rng, count, unlock_tier)


static func refresh_result(spirit_stones: int, refresh_cost: int, job_id: String, realm_index: int, rng, count := 6, unlock_tier := 0) -> Dictionary:
	if spirit_stones < refresh_cost:
		return {
			"success": false,
			"message": "灵石不足，无法刷新。",
			"spirit_stones": spirit_stones,
			"next_refresh_cost": refresh_cost,
			"stock": []
		}
	return {
		"success": true,
		"message": "货架已刷新。",
		"spirit_stones": spirit_stones - refresh_cost,
		"next_refresh_cost": next_refresh_cost(refresh_cost),
		"stock": generate_stock(job_id, realm_index, rng, count, unlock_tier)
	}


static func buy_card_result(card_id: String, price: int, spirit_stones: int, deck_ids: Array, score_limit := 0) -> Dictionary:
	var gain_result: Dictionary = CardAcquisitionRulesScript.card_gain_result(card_id, deck_ids, score_limit)
	if not bool(gain_result.get("valid", false)):
		return {
			"success": false,
			"message": str(gain_result.get("message", "无法购买。")),
			"spirit_stones": spirit_stones,
			"destination": "none",
			"card_id": card_id
		}
	if spirit_stones < price:
		return {
			"success": false,
			"message": "灵石不足，无法购买。",
			"spirit_stones": spirit_stones,
			"destination": "none",
			"card_id": card_id
		}
	return {
		"success": true,
		"message": "买下 %s，%s" % [card_id, str(gain_result.get("message", ""))],
		"spirit_stones": spirit_stones - max(0, price),
		"destination": str(gain_result.get("destination", "reserve")),
		"reason": str(gain_result.get("reason", "")),
		"card_id": card_id,
		"price": price
	}


static func sell_price(card_id: String) -> int:
	return CardPoolDatabaseScript.sell_price(card_id)


static func sell_card_result(card_id: String, spirit_stones: int) -> Dictionary:
	var price: int = sell_price(card_id)
	if card_id == "" or CardDatabaseScript.get_card(card_id).is_empty() or price <= 0:
		return {
			"success": false,
			"message": "该卡不能出售。",
			"spirit_stones": spirit_stones,
			"card_id": card_id,
			"price": 0
		}
	return {
		"success": true,
		"message": "售出 %s，获得 %d 灵石。" % [card_id, price],
		"spirit_stones": spirit_stones + price,
		"card_id": card_id,
		"price": price
	}
