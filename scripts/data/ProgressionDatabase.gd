extends RefCounted
class_name ProgressionDatabase

const POINT_NAME := "修为点"

const TITLE_THRESHOLDS := [
	{"points": 0, "title": "练气"},
	{"points": 30, "title": "筑基"},
	{"points": 90, "title": "金丹"},
	{"points": 180, "title": "元婴"},
	{"points": 320, "title": "化神"},
	{"points": 520, "title": "渡劫"}
]

const LAYER_MULTIPLIERS := [1.0, 1.25, 1.5, 3.0, 4.5, 6.0, 8.0]

const CONTENT_STATE_ACTIVE := "active"

const PROGRESSION_DEFINITIONS := [
	{
		"progression_id": "max_hp",
		"job_id": "sword",
		"name": "体魄",
		"category": "基础属性",
		"description": "最大生命 +3。",
		"max_level": 5,
		"costs": [12, 18, 26, 36, 48],
		"bonus_per_level": {"max_hp": 3},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "attack",
		"job_id": "sword",
		"name": "攻法",
		"category": "基础属性",
		"description": "基础攻击 +1。",
		"max_level": 3,
		"costs": [28, 45, 70],
		"bonus_per_level": {"attack": 1},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "deck_score",
		"job_id": "sword",
		"name": "纳法",
		"category": "卡组与卡包",
		"description": "卡组总分上限 +2。",
		"max_level": 4,
		"costs": [18, 28, 42, 60],
		"bonus_per_level": {"deck_score_limit": 2},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "card_unlock",
		"job_id": "sword",
		"name": "识藏",
		"category": "卡组与卡包",
		"description": "奖励和坊市开放下一批编号卡包。",
		"max_level": 2,
		"costs": [40, 80],
		"bonus_per_level": {"card_unlock_tier": 1},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "draw",
		"job_id": "sword",
		"name": "灵识",
		"category": "强力规则",
		"description": "每回合基础抽牌 +1。",
		"max_level": 1,
		"costs": [160],
		"bonus_per_level": {"draw_per_turn": 1},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "defense",
		"job_id": "sword",
		"name": "护体",
		"category": "基础属性",
		"description": "基础防御 +1。剑修只能提升 1 次。",
		"max_level": 1,
		"costs": [65],
		"bonus_per_level": {"defense": 1},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "starting_sword",
		"job_id": "sword",
		"name": "剑意",
		"category": "角色特性",
		"description": "每场战斗开始获得 1 点剑势。",
		"max_level": 2,
		"costs": [35, 70],
		"bonus_per_level": {"starting_sword": 1},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "max_hp",
		"job_id": "talisman",
		"name": "体魄",
		"category": "基础属性",
		"description": "最大生命 +3。",
		"max_level": 5,
		"costs": [12, 18, 26, 36, 48],
		"bonus_per_level": {"max_hp": 3},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "attack",
		"job_id": "talisman",
		"name": "攻法",
		"category": "基础属性",
		"description": "基础攻击 +1。",
		"max_level": 3,
		"costs": [28, 45, 70],
		"bonus_per_level": {"attack": 1},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "deck_score",
		"job_id": "talisman",
		"name": "纳法",
		"category": "卡组与卡包",
		"description": "卡组总分上限 +2。",
		"max_level": 4,
		"costs": [18, 28, 42, 60],
		"bonus_per_level": {"deck_score_limit": 2},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "card_unlock",
		"job_id": "talisman",
		"name": "识藏",
		"category": "卡组与卡包",
		"description": "奖励和坊市开放下一批编号卡包。",
		"max_level": 2,
		"costs": [40, 80],
		"bonus_per_level": {"card_unlock_tier": 1},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "draw",
		"job_id": "talisman",
		"name": "灵识",
		"category": "强力规则",
		"description": "每回合基础抽牌 +1。",
		"max_level": 1,
		"costs": [160],
		"bonus_per_level": {"draw_per_turn": 1},
		"content_state": CONTENT_STATE_ACTIVE
	},
	{
		"progression_id": "defense",
		"job_id": "talisman",
		"name": "护体",
		"category": "基础属性",
		"description": "基础防御 +1。符修可提升 2 次。",
		"max_level": 2,
		"costs": [55, 85],
		"bonus_per_level": {"defense": 1},
		"content_state": CONTENT_STATE_ACTIVE
	}
]


static func title_for_points(points_total: int) -> String:
	var title := "练气"
	for item_variant in TITLE_THRESHOLDS:
		var item: Dictionary = item_variant
		if points_total >= int(item.get("points", 0)):
			title = str(item.get("title", title))
	return title


static func layer_multiplier(layer_index: int) -> float:
	var index: int = clampi(layer_index, 0, LAYER_MULTIPLIERS.size() - 1)
	return float(LAYER_MULTIPLIERS[index])


static func progression_definitions() -> Array:
	return PROGRESSION_DEFINITIONS.duplicate(true)


static func active_progression_definitions() -> Array:
	return filter_active_definitions(PROGRESSION_DEFINITIONS)


static func filter_active_definitions(definitions: Array) -> Array:
	var result: Array = []
	for definition_variant in definitions:
		if not (definition_variant is Dictionary):
			continue
		var definition: Dictionary = definition_variant
		if str(definition.get("content_state", "")) == CONTENT_STATE_ACTIVE:
			result.append(definition.duplicate(true))
	return result


static func upgrades_for_job(job_id: String) -> Array:
	var result: Array = []
	for definition_variant in active_progression_definitions():
		var definition: Dictionary = definition_variant
		if str(definition.get("job_id", "")) == job_id:
			result.append(definition)
	return result


static func upgrade_definition(job_id: String, progression_id: String) -> Dictionary:
	for definition_variant in upgrades_for_job(job_id):
		var definition: Dictionary = definition_variant
		if str(definition.get("progression_id", "")) == progression_id:
			return definition.duplicate(true)
	return {}
