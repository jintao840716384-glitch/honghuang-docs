extends RefCounted
class_name MetaProgression

const ProgressionDatabaseScript = preload("res://scripts/data/ProgressionDatabase.gd")
const SaveMigrationServiceScript = preload("res://scripts/save/SaveMigrationService.gd")
const SaveStoreScript = preload("res://scripts/save/SaveStore.gd")

const SAVE_PATH := SaveStoreScript.PROGRESSION_PATH

var data: Dictionary = {}

func _init() -> void:
	reset_to_defaults()

func reset_to_defaults() -> void:
	data = SaveMigrationServiceScript.default_meta_progression_data()

func load(path := SAVE_PATH) -> void:
	data = SaveStoreScript.load_progression(path)

func save(path := SAVE_PATH) -> bool:
	data = SaveMigrationServiceScript.migrate_meta_progression(data)
	return SaveStoreScript.save_progression(data, path)

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

func upgrade_level(job_id: String, progression_id: String) -> int:
	var state: Dictionary = _job_state(job_id)
	var upgrades: Dictionary = state.get("upgrades", {})
	return int(upgrades.get(progression_id, 0))

func next_upgrade_cost(job_id: String, progression_id: String) -> int:
	var definition: Dictionary = upgrade_definition(job_id, progression_id)
	if definition.is_empty():
		return -1
	var level: int = upgrade_level(job_id, progression_id)
	var max_level: int = int(definition.get("max_level", 0))
	if level >= max_level:
		return -1
	var costs: Array = definition.get("costs", [])
	if level >= 0 and level < costs.size():
		return int(costs[level])
	return int(definition.get("cost", 0))

func can_buy_upgrade(job_id: String, progression_id: String) -> bool:
	var cost: int = next_upgrade_cost(job_id, progression_id)
	return cost > 0 and points_available(job_id) >= cost

func buy_upgrade(job_id: String, progression_id: String, save_after := true) -> String:
	var definition: Dictionary = upgrade_definition(job_id, progression_id)
	if definition.is_empty():
		return "无效成长项。"
	var cost: int = next_upgrade_cost(job_id, progression_id)
	if cost <= 0:
		return "该成长已达上限。"
	if points_available(job_id) < cost:
		return "修为点不足。"
	var state: Dictionary = _job_state(job_id)
	var upgrades: Dictionary = state.get("upgrades", {})
	upgrades[progression_id] = int(upgrades.get(progression_id, 0)) + 1
	state["upgrades"] = upgrades
	state["points_spent"] = int(state.get("points_spent", 0)) + cost
	_set_job_state(job_id, state)
	if save_after:
		save()
	return "%s 提升到 %d 级。" % [str(definition.get("name", progression_id)), int(upgrades.get(progression_id, 0))]

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
		var progression_id := str(definition.get("progression_id", ""))
		var level: int = upgrade_level(job_id, progression_id)
		if level <= 0:
			continue
		var bonus: Dictionary = definition.get("bonus_per_level", {})
		for key_variant in bonus.keys():
			var key := str(key_variant)
			result[key] = int(result.get(key, 0)) + int(bonus.get(key, 0)) * level
	return result

func title_for_job(job_id: String) -> String:
	var total: int = points_total(job_id)
	return ProgressionDatabaseScript.title_for_points(total)

func title_with_job(job_id: String, job_name: String) -> String:
	var title := title_for_job(job_id)
	if job_name == "":
		return title
	return "%s%s" % [title, job_name]

static func layer_multiplier(layer_index: int) -> float:
	return ProgressionDatabaseScript.layer_multiplier(layer_index)

static func upgrades_for_job(job_id: String) -> Array:
	return ProgressionDatabaseScript.upgrades_for_job(job_id)

static func upgrade_definition(job_id: String, progression_id: String) -> Dictionary:
	return ProgressionDatabaseScript.upgrade_definition(job_id, progression_id)

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
	return SaveMigrationServiceScript.migrate_meta_progression(source)
