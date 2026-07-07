extends RefCounted
class_name MetaProgression

const SAVE_PATH := "user://progression.json"
const POINT_NAME := "修为点"

const TITLE_THRESHOLDS := [
	{"points": 0, "title": "练气"},
	{"points": 30, "title": "筑基"},
	{"points": 90, "title": "金丹"},
	{"points": 180, "title": "元婴"},
	{"points": 320, "title": "化神"},
	{"points": 520, "title": "渡劫"}
]

var data: Dictionary = {}

func _init() -> void:
	reset_to_defaults()

func reset_to_defaults() -> void:
	data = {
		"version": 1,
		"jobs": {}
	}

func load() -> void:
	reset_to_defaults()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		data = _merge_data(parsed as Dictionary)

func save() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true

func add_points(job_id: String, amount: int, save_after := true) -> int:
	if amount <= 0:
		return 0
	var state: Dictionary = _job_state(job_id)
	state["points_total"] = int(state.get("points_total", 0)) + amount
	_set_job_state(job_id, state)
	if save_after:
		save()
	return amount

func points_total(job_id: String) -> int:
	return int(_job_state(job_id).get("points_total", 0))

func points_spent(job_id: String) -> int:
	return int(_job_state(job_id).get("points_spent", 0))

func points_available(job_id: String) -> int:
	return max(0, points_total(job_id) - points_spent(job_id))

func upgrade_level(job_id: String, upgrade_id: String) -> int:
	var state: Dictionary = _job_state(job_id)
	var upgrades: Dictionary = state.get("upgrades", {})
	return int(upgrades.get(upgrade_id, 0))

func next_upgrade_cost(job_id: String, upgrade_id: String) -> int:
	var definition: Dictionary = upgrade_definition(job_id, upgrade_id)
	if definition.is_empty():
		return -1
	var level: int = upgrade_level(job_id, upgrade_id)
	var max_level: int = int(definition.get("max_level", 0))
	if level >= max_level:
		return -1
	var costs: Array = definition.get("costs", [])
	if level >= 0 and level < costs.size():
		return int(costs[level])
	return int(definition.get("cost", 0))

func can_buy_upgrade(job_id: String, upgrade_id: String) -> bool:
	var cost: int = next_upgrade_cost(job_id, upgrade_id)
	return cost > 0 and points_available(job_id) >= cost

func buy_upgrade(job_id: String, upgrade_id: String, save_after := true) -> String:
	var definition: Dictionary = upgrade_definition(job_id, upgrade_id)
	if definition.is_empty():
		return "无效成长项。"
	var cost: int = next_upgrade_cost(job_id, upgrade_id)
	if cost <= 0:
		return "该成长已达上限。"
	if points_available(job_id) < cost:
		return "修为点不足。"
	var state: Dictionary = _job_state(job_id)
	var upgrades: Dictionary = state.get("upgrades", {})
	upgrades[upgrade_id] = int(upgrades.get(upgrade_id, 0)) + 1
	state["upgrades"] = upgrades
	state["points_spent"] = int(state.get("points_spent", 0)) + cost
	_set_job_state(job_id, state)
	if save_after:
		save()
	return "%s 提升到 %d 级。" % [str(definition.get("name", upgrade_id)), int(upgrades.get(upgrade_id, 0))]

func bonuses_for_job(job_id: String) -> Dictionary:
	var result := {
		"max_hp": 0,
		"attack": 0,
		"defense": 0,
		"deck_score_limit": 0,
		"draw_per_turn": 0,
		"starting_sword": 0,
		"card_unlock_tier": 0
	}
	for definition_variant in upgrades_for_job(job_id):
		var definition: Dictionary = definition_variant
		var level: int = upgrade_level(job_id, str(definition.get("id", "")))
		if level <= 0:
			continue
		var bonus: Dictionary = definition.get("bonus_per_level", {})
		for key_variant in bonus.keys():
			var key := str(key_variant)
			result[key] = int(result.get(key, 0)) + int(bonus.get(key, 0)) * level
	return result

func title_for_job(job_id: String) -> String:
	var total: int = points_total(job_id)
	var title := "练气"
	for item_variant in TITLE_THRESHOLDS:
		var item: Dictionary = item_variant
		if total >= int(item.get("points", 0)):
			title = str(item.get("title", title))
	return title

func title_with_job(job_id: String, job_name: String) -> String:
	var title := title_for_job(job_id)
	if job_name == "":
		return title
	return "%s%s" % [title, job_name]

static func layer_multiplier(layer_index: int) -> float:
	var multipliers := [1.0, 1.25, 1.5, 3.0, 4.5, 6.0, 8.0]
	var index: int = clampi(layer_index, 0, multipliers.size() - 1)
	return float(multipliers[index])

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
			return definition
	return {}

func _job_state(job_id: String) -> Dictionary:
	var jobs: Dictionary = data.get("jobs", {})
	if not jobs.has(job_id):
		jobs[job_id] = {
			"points_total": 0,
			"points_spent": 0,
			"upgrades": {}
		}
		data["jobs"] = jobs
	return (jobs.get(job_id, {}) as Dictionary).duplicate(true)

func _set_job_state(job_id: String, state: Dictionary) -> void:
	var jobs: Dictionary = data.get("jobs", {})
	jobs[job_id] = state.duplicate(true)
	data["jobs"] = jobs

func _merge_data(source: Dictionary) -> Dictionary:
	var result := {
		"version": int(source.get("version", 1)),
		"jobs": {}
	}
	var jobs_source: Dictionary = source.get("jobs", {})
	var jobs_result: Dictionary = {}
	for job_id_variant in jobs_source.keys():
		var job_id := str(job_id_variant)
		var job_source: Dictionary = jobs_source.get(job_id, {})
		jobs_result[job_id] = {
			"points_total": max(0, int(job_source.get("points_total", 0))),
			"points_spent": max(0, int(job_source.get("points_spent", 0))),
			"upgrades": (job_source.get("upgrades", {}) as Dictionary).duplicate(true)
		}
	result["jobs"] = jobs_result
	return result
