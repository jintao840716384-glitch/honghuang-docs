extends RefCounted
class_name CharacterPrepViewModel

const MetaProgressionScript = preload("res://scripts/data/MetaProgression.gd")

var _progression
var _data_snapshot: Dictionary = {}


func _init() -> void:
	_progression = MetaProgressionScript.new()
	_refresh()


func load() -> void:
	_progression.load()
	_refresh()


func points_total(job_id: String) -> int:
	return _points(job_id, "points_total")


func points_spent(job_id: String) -> int:
	return _points(job_id, "points_spent")


func points_available(job_id: String) -> int:
	return max(0, points_total(job_id) - points_spent(job_id))


func upgrade_level(job_id: String, progression_id: String) -> int:
	var job: Dictionary = (_data_snapshot.get("jobs", {}) as Dictionary).get(job_id, {})
	return int((job.get("upgrades", {}) as Dictionary).get(progression_id, 0))


func next_upgrade_cost(job_id: String, progression_id: String) -> int:
	return int(_progression.next_upgrade_cost(job_id, progression_id))


func bonuses_for_job(job_id: String) -> Dictionary:
	return _progression.bonuses_for_job(job_id).duplicate(true)


func title_with_job(job_id: String, job_name: String) -> String:
	return str(_progression.title_with_job(job_id, job_name))


func buy_upgrade(job_id: String, progression_id: String) -> String:
	var result := str(_progression.buy_upgrade(job_id, progression_id))
	_refresh()
	return result


func snapshot() -> Dictionary:
	return _data_snapshot.duplicate(true)


func _points(job_id: String, field: String) -> int:
	var jobs: Dictionary = _data_snapshot.get("jobs", {})
	var job: Dictionary = jobs.get(job_id, {})
	return int(job.get(field, 0))


func _refresh() -> void:
	_data_snapshot = _progression.data.duplicate(true)
