extends RefCounted
class_name JobDatabase

const CharacterDatabaseScript = preload("res://scripts/data/CharacterDatabase.gd")
const CONTENT_STATE_ACTIVE := "active"


static func get_job(job_id: String) -> Dictionary:
	var definition: Dictionary = _job_definition(job_id)
	if definition.is_empty() or str(definition.get("content_state", "")) != CONTENT_STATE_ACTIVE:
		return {}
	var character_id: String = str(definition.get("character_id", job_id))
	var character: Dictionary = CharacterDatabaseScript.character_template(character_id)
	if character.is_empty():
		return {}
	var job: Dictionary = character.duplicate(true)
	job["id"] = job_id
	job["character_id"] = character_id
	job["name"] = str(definition.get("name", character.get("name", job_id)))
	job["name_key"] = str(definition.get("name_key", "job.%s.name" % job_id))
	job["description_key"] = str(definition.get("description_key", "job.%s.description" % job_id))
	job["show_sword_power"] = bool(definition.get("show_sword_power", false))
	job["description"] = str(definition.get("description", ""))
	job["start_deck"] = (definition.get("start_deck", []) as Array).duplicate()
	return job


static func all_jobs() -> Array:
	return [get_job("sword"), get_job("talisman")]


static func job_definitions() -> Array:
	return [_job_definition("sword"), _job_definition("talisman")]


static func _job_definition(job_id: String) -> Dictionary:
	match job_id:
		"sword":
			return {
				"id": "sword",
				"content_state": CONTENT_STATE_ACTIVE,
				"name_key": "job.sword.name",
				"description_key": "job.sword.description",
				"character_id": "sword",
				"name": "剑修",
				"show_sword_power": true,
				"description": "偏向普通攻击联动，利用攻击附加和低层对策卡建立节奏。",
				"start_deck": [
					"break_defense_setup", "break_defense_setup",
					"weaken_attack_setup", "weaken_attack_setup",
					"defense_setup", "defense_setup",
					"heal_wound",
					"clear_buff",
					"poison", "poison"
				]
			}
		"talisman":
			return {
				"id": "talisman",
				"content_state": CONTENT_STATE_ACTIVE,
				"name_key": "job.talisman.name",
				"description_key": "job.talisman.description",
				"character_id": "talisman",
				"name": "符修",
				"show_sword_power": false,
				"description": "偏向防御、恢复与解除增益，使用同一批低层互动卡。",
				"start_deck": [
					"defense_setup", "defense_setup",
					"heal_wound", "heal_wound",
					"clear_buff", "clear_buff",
					"poison",
					"weaken_attack_setup",
					"break_defense_setup",
					"defense_setup"
				]
			}
	return {}
