extends RefCounted
class_name CardAcquisitionRules

const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")
const DeckBuildRulesScript = preload("res://scripts/run/DeckBuildRules.gd")


static func card_gain_result(card_id: String, deck_ids: Array, score_limit := 0) -> Dictionary:
	if card_id == "" or not CardDefinitionDatabaseScript.is_active_card_id(card_id):
		return {
			"valid": false,
			"destination": "none",
			"reason": "未知卡牌",
			"message": "未获得卡牌。"
		}
	var block_reason: String = DeckBuildRulesScript.deck_add_block_reason(card_id, deck_ids, score_limit)
	if block_reason == "":
		return {
			"valid": true,
			"destination": "deck",
			"reason": "",
			"message": "%s 加入当前卡组。" % card_id
		}
	return {
		"valid": true,
		"destination": "reserve",
		"reason": block_reason,
		"message": "%s 加入备牌区。" % card_id
	}


static func reward_card_result(card_id: String, deck_ids: Array, score_limit: int, message_prefix: String) -> Dictionary:
	var gain_result: Dictionary = card_gain_result(card_id, deck_ids, score_limit)
	if not bool(gain_result.get("valid", false)):
		return {
			"success": false,
			"message": str(gain_result.get("message", "未获得卡牌。")),
			"destination": "none",
			"card_id": card_id
		}
	return {
		"success": true,
		"message": "%s：%s" % [message_prefix, str(gain_result.get("message", ""))],
		"destination": str(gain_result.get("destination", "reserve")),
		"reason": str(gain_result.get("reason", "")),
		"card_id": card_id
	}
