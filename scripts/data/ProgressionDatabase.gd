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


static func upgrades_for_job(job_id: String) -> Array:
	var upgrades: Array = [
		{
			"id": "max_hp",
			"name": "体魄",
			"category": "基础属性",
			"description": "最大生命 +3。",
			"max_level": 5,
			"costs": [12, 18, 26, 36, 48],
			"bonus_per_level": {"max_hp": 3}
		},
		{
			"id": "attack",
			"name": "攻法",
			"category": "基础属性",
			"description": "基础攻击 +1。",
			"max_level": 3,
			"costs": [28, 45, 70],
			"bonus_per_level": {"attack": 1}
		},
		{
			"id": "deck_score",
			"name": "纳法",
			"category": "卡组与卡包",
			"description": "卡组总分上限 +2。",
			"max_level": 4,
			"costs": [18, 28, 42, 60],
			"bonus_per_level": {"deck_score_limit": 2}
		},
		{
			"id": "card_unlock",
			"name": "识藏",
			"category": "卡组与卡包",
			"description": "奖励和坊市开放下一批编号卡包。",
			"max_level": 2,
			"costs": [40, 80],
			"bonus_per_level": {"card_unlock_tier": 1}
		},
		{
			"id": "draw",
			"name": "灵识",
			"category": "强力规则",
			"description": "每回合基础抽牌 +1。",
			"max_level": 1,
			"costs": [160],
			"bonus_per_level": {"draw_per_turn": 1}
		}
	]
	if job_id == "sword":
		upgrades.append_array([
			{
				"id": "defense",
				"name": "护体",
				"category": "基础属性",
				"description": "基础防御 +1。剑修只能提升 1 次。",
				"max_level": 1,
				"costs": [65],
				"bonus_per_level": {"defense": 1}
			},
			{
				"id": "starting_sword",
				"name": "剑意",
				"category": "角色特性",
				"description": "每场战斗开始获得 1 点剑势。",
				"max_level": 2,
				"costs": [35, 70],
				"bonus_per_level": {"starting_sword": 1}
			}
		])
	elif job_id == "talisman":
		upgrades.append_array([
			{
				"id": "defense",
				"name": "护体",
				"category": "基础属性",
				"description": "基础防御 +1。符修可提升 2 次。",
				"max_level": 2,
				"costs": [55, 85],
				"bonus_per_level": {"defense": 1}
			}
		])
	return upgrades


static func upgrade_definition(job_id: String, upgrade_id: String) -> Dictionary:
	for definition_variant in upgrades_for_job(job_id):
		var definition: Dictionary = definition_variant
		if str(definition.get("id", "")) == upgrade_id:
			return definition.duplicate(true)
	return {}
