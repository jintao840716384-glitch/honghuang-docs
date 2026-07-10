extends RefCounted
class_name CardInteractionRules

const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")

static func hand_button_prefix_for_card(card: Dictionary) -> String:
	if card.is_empty():
		return ""
	if card.get("type", "") == CardDefinitionDatabaseScript.TYPE_DEFENSE:
		return "盖伏"
	if str(card.get("after_use", "")) == "equipment":
		return "装备"
	if str(card.get("after_use", "")) == "spell_zone":
		return "放置"
	return "使用"

static func played_card_fx_prefix_for_card(card: Dictionary) -> String:
	if card.is_empty():
		return ""
	if card.get("type", "") == CardDefinitionDatabaseScript.TYPE_DEFENSE:
		return "盖伏"
	if str(card.get("after_use", "")) == "equipment":
		return "装备"
	return "使用"

static func card_drag_rule(card: Dictionary) -> String:
	if card.get("type", "") == CardDefinitionDatabaseScript.TYPE_DEFENSE:
		return "spell_zone"
	var after_use := str(card.get("after_use", ""))
	if after_use == "spell_zone":
		return "spell_zone"
	if after_use == "equipment":
		return "unit_equipment"
	match str(card.get("target_scope", "")):
		"ally_unit":
			return "ally_unit"
		"enemy_unit":
			return "enemy_unit"
	if card_needs_enemy_target(card):
		return "enemy_unit"
	return "direct"

static func card_needs_enemy_target(card: Dictionary) -> bool:
	if str(card.get("target_scope", "")) == "enemy_unit":
		return true
	var effect: Dictionary = card.get("effect", {})
	return effect_needs_enemy_target(effect)

static func effect_needs_enemy_target(effect: Dictionary) -> bool:
	match str(effect.get("kind", "")):
		"direct_damage", "reduce_enemy_defense":
			return true
		"multi":
			for sub_effect in effect.get("effects", []):
				var sub_effect_dict: Dictionary = sub_effect
				if effect_needs_enemy_target(sub_effect_dict):
					return true
	return false
