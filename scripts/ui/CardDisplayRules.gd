extends RefCounted
class_name CardDisplayRules

const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")

static func card_score(card: Dictionary) -> int:
	return int(card.get("build_cost", card.get("score", 0)))

static func card_type_label(card: Dictionary) -> String:
	var card_type := str(card.get("type", ""))
	if card_type == CardDefinitionDatabaseScript.TYPE_DEFENSE:
		return "防御牌"
	if str(card.get("after_use", "")) == "equipment":
		return "装备牌"
	if str(card.get("after_use", "")) == "spell_zone":
		return "放置牌"
	if card_type == CardDefinitionDatabaseScript.TYPE_SPELL:
		return "法术牌"
	return card_type

static func card_type_text(card: Dictionary, max_tags := 2) -> String:
	var base := card_type_label(card)
	var display_tags: Array = []
	for tag in card.get("tags", []):
		if display_tags.size() >= max_tags:
			break
		display_tags.append(str(tag))
	if display_tags.is_empty():
		return base
	return "%s / %s" % [base, " / ".join(display_tags)]

static func tags_text(card: Dictionary) -> String:
	var tags: Array = card.get("tags", [])
	if tags.is_empty():
		return "无"
	var parts: Array = []
	for tag in tags:
		parts.append(str(tag))
	return " / ".join(parts)

static func trigger_text(card: Dictionary) -> String:
	var triggers: Array = card.get("trigger_timing", [])
	if triggers.is_empty():
		return "无"
	var parts: Array = []
	for trigger in triggers:
		parts.append(trigger_label(str(trigger)))
	return " / ".join(parts)

static func trigger_label(trigger: String) -> String:
	match trigger:
		"enemy_attack_declared":
			return "敌人攻击前"
		"enemy_spell_declared":
			return "敌人施法前"
		"enemy_destroy_zone_card_declared":
			return "我方法防区卡牌将被破坏前"
		"player_damage_before":
			return "我方单位受到伤害前"
		"player_lethal_damage_before":
			return "玩家受到致命伤害前"
	return trigger

static func footer_text(card: Dictionary) -> String:
	var parts: Array = []
	var effect: Dictionary = card.get("effect", {})
	var sword_cost := int(effect.get("sword_cost", 0))
	if sword_cost > 0:
		parts.append("消耗：剑势 %d" % sword_cost)
	match str(card.get("after_use", "")):
		"graveyard":
			parts.append("去向：墓地")
		"exile":
			parts.append("去向：除外")
		"spell_zone":
			parts.append("放置：法防区")
		"equipment":
			parts.append("放置：装备区")
	return " / ".join(parts)

static func card_palette(card: Dictionary) -> Dictionary:
	var card_type := str(card.get("type", ""))
	var after_use := str(card.get("after_use", ""))
	var bg := Color(0.28, 0.16, 0.10, 1.0)
	var border := Color(0.95, 0.60, 0.30, 1.0)
	var name_color := Color(1.0, 0.88, 0.68, 1.0)
	if card_type == CardDefinitionDatabaseScript.TYPE_DEFENSE:
		bg = Color(0.08, 0.12, 0.24, 1.0)
		border = Color(0.36, 0.58, 1.0, 1.0)
		name_color = Color(0.78, 0.88, 1.0, 1.0)
	elif after_use == "equipment":
		bg = Color(0.09, 0.22, 0.16, 1.0)
		border = Color(0.40, 0.82, 0.52, 1.0)
		name_color = Color(0.76, 1.0, 0.82, 1.0)
	elif after_use == "spell_zone":
		bg = Color(0.18, 0.17, 0.13, 1.0)
		border = Color(0.84, 0.72, 0.42, 1.0)
		name_color = Color(1.0, 0.90, 0.64, 1.0)
	elif card_type == "奖励":
		bg = Color(0.23, 0.17, 0.11, 1.0)
		border = Color(0.92, 0.66, 0.36, 1.0)
		name_color = Color(1.0, 0.90, 0.70, 1.0)
	return {"bg": bg, "border": border, "name_color": name_color}

static func card_outline_border_color(card: Dictionary) -> Color:
	var card_type := str(card.get("type", ""))
	var after_use := str(card.get("after_use", ""))
	if card_type == CardDefinitionDatabaseScript.TYPE_DEFENSE:
		return Color(0.58, 0.75, 1.0, 1.0)
	if after_use == "equipment":
		return Color(0.50, 0.92, 0.62, 1.0)
	return Color(0.96, 0.68, 0.34, 1.0)

static func zone_slot_palette(card: Dictionary, occupied: bool, face_down: bool) -> Dictionary:
	if not occupied:
		return {
			"bg": Color(0.08, 0.09, 0.10, 0.26),
			"border": Color(0.64, 0.69, 0.78, 0.46)
		}
	if face_down:
		return {
			"bg": Color(0.06, 0.10, 0.22, 1.0),
			"border": Color(0.42, 0.62, 1.0, 1.0)
		}
	if str(card.get("after_use", "")) == "equipment":
		return {
			"bg": Color(0.09, 0.22, 0.16, 1.0),
			"border": Color(0.40, 0.82, 0.52, 1.0)
		}
	return {
		"bg": Color(0.18, 0.17, 0.13, 1.0),
		"border": Color(0.84, 0.72, 0.42, 1.0)
	}
