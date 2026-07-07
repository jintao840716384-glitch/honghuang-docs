extends RefCounted
class_name JobDatabase

const CharacterDatabaseScript = preload("res://scripts/data/CharacterDatabase.gd")


static func get_job(job_id: String) -> Dictionary:
	var definition: Dictionary = _job_definition(job_id)
	if definition.is_empty():
		return {}
	var character_id: String = str(definition.get("character_id", job_id))
	var character: Dictionary = CharacterDatabaseScript.character_template(character_id)
	if character.is_empty():
		return {}
	var job: Dictionary = character.duplicate(true)
	job["id"] = job_id
	job["character_id"] = character_id
	job["name"] = str(definition.get("name", character.get("name", job_id)))
	job["show_sword_power"] = bool(definition.get("show_sword_power", false))
	job["description"] = str(definition.get("description", ""))
	job["start_deck"] = (definition.get("start_deck", []) as Array).duplicate()
	return job


static func all_jobs() -> Array:
	return [get_job("sword"), get_job("talisman")]


static func _job_definition(job_id: String) -> Dictionary:
	match job_id:
		"sword":
			return {
				"id": "sword",
				"character_id": "sword",
				"name": "剑修",
				"show_sword_power": true,
				"description": "依赖普通攻击积累剑势，并消耗剑势发动剑修终端。",
				"start_deck": [
					"青锋剑",
					"起剑诀", "起剑诀",
					"引剑入体",
					"藏锋",
					"小无相剑",
					"护身符",
					"回春符",
					"疾剑诀",
					"金刃符"
				]
			}
		"talisman":
			return {
				"id": "talisman",
				"character_id": "talisman",
				"name": "符修",
				"show_sword_power": false,
				"description": "依赖符牌、回收符牌和复制符牌进行战斗。",
				"start_deck": [
					"火球符",
					"金刃符",
					"雷击符",
					"回春符",
					"血墨符",
					"护身符",
					"拾符诀",
					"复符诀",
					"灵墨重描",
					"符匣"
				]
			}
	return {}
