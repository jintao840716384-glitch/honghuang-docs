extends RefCounted
class_name JobDatabase

static func get_job(job_id: String) -> Dictionary:
	match job_id:
		"sword":
			return {
				"id": "sword",
				"name": "剑修",
				"max_hp": 35,
				"attack": 8,
				"defense": 0,
				"unit_tags": ["主单位", "剑修", "sword"],
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
				"name": "符修",
				"max_hp": 30,
				"attack": 4,
				"defense": 0,
				"unit_tags": ["主单位", "符修", "talisman"],
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

static func all_jobs() -> Array:
	return [get_job("sword"), get_job("talisman")]
