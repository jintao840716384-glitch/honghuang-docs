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
				"defense": 2,
				"show_sword_power": true,
				"description": "依赖普通攻击积累剑势，并消耗剑势发动剑修终端。",
				"start_deck": [
					"青锋剑", "铁木甲", "聚灵佩",
					"起剑诀", "起剑诀",
					"藏锋", "藏锋",
					"小无相剑", "小无相剑",
					"剑心通明",
					"一剑开天",
					"火球符", "火球符",
					"回春符",
					"护身符"
				]
			}
		"talisman":
			return {
				"id": "talisman",
				"name": "符修",
				"max_hp": 30,
				"attack": 4,
				"defense": 2,
				"show_sword_power": false,
				"description": "依赖符牌、回收符牌和复制符牌进行战斗。",
				"start_deck": [
					"火球符", "火球符", "火球符",
					"雷击符", "雷击符",
					"回春符",
					"破甲符",
					"拾符诀", "拾符诀",
					"复符诀",
					"灵墨重描",
					"符匣",
					"护身符"
				]
			}
	return {}

static func all_jobs() -> Array:
	return [get_job("sword"), get_job("talisman")]
