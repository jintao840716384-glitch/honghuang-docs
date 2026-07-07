extends RefCounted
class_name DeckBuildRules

const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")


static func min_deck_size() -> int:
	return CardDatabaseScript.MIN_DECK_SIZE


static func max_deck_size() -> int:
	return CardDatabaseScript.MAX_DECK_SIZE


static func card_score(card_id: String) -> int:
	return CardDatabaseScript.card_score(card_id)


static func deck_score(deck_ids: Array) -> int:
	return CardDatabaseScript.deck_score(deck_ids)


static func can_add_card_to_deck(card_id: String, deck_ids: Array, score_limit := 0) -> bool:
	return deck_add_block_reason(card_id, deck_ids, score_limit) == ""


static func deck_add_block_reason(card_id: String, deck_ids: Array, score_limit := 0) -> String:
	if card_id == "" or CardDatabaseScript.get_card(card_id).is_empty():
		return "未知卡牌"
	if deck_ids.size() >= max_deck_size():
		return "卡组已达到 %d 张上限" % max_deck_size()
	if score_limit > 0 and deck_score(deck_ids) + card_score(card_id) > score_limit:
		return "分数超过上限 %d" % score_limit
	return ""


static func deck_build_block_reason(candidate_deck_ids: Array, score_limit := 0) -> String:
	if candidate_deck_ids.size() < min_deck_size():
		return "当前卡组至少需要 %d 张。" % min_deck_size()
	if candidate_deck_ids.size() > max_deck_size():
		return "当前卡组不能超过 %d 张。" % max_deck_size()
	if score_limit > 0 and deck_score(candidate_deck_ids) > score_limit:
		return "当前卡组总分超过上限。"
	return ""
