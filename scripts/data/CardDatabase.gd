extends RefCounted
class_name CardDatabase

const TYPE_SPELL := "spell"
const TYPE_DEFENSE := "defense"

static func get_cards() -> Dictionary:
	return {
		"起剑诀": {
			"id": "起剑诀",
			"name": "起剑诀",
			"type": TYPE_SPELL,
			"tags": ["剑修", "强化"],
			"description": "本回合玩家普通攻击攻击力 +3。如果本回合普通攻击命中，额外获得 1 点剑势。",
			"effect": {"kind": "attack_boost", "attack_bonus": 3, "extra_sword_on_hit": 1},
			"after_use": "graveyard"
		},
		"剑心通明": {
			"id": "剑心通明",
			"name": "剑心通明",
			"type": TYPE_SPELL,
			"tags": ["剑修", "永续"],
			"description": "放置到法防区。每个玩家回合开始时，获得 1 点剑势。",
			"effect": {"kind": "persistent_sword_per_turn", "value": 1},
			"after_use": "spell_zone"
		},
		"藏锋": {
			"id": "藏锋",
			"name": "藏锋",
			"type": TYPE_DEFENSE,
			"tags": ["剑修", "反击"],
			"description": "玩家受到攻击时，本次受到伤害 -3，获得 1 点剑势。",
			"trigger_timing": ["player_damage_before"],
			"effect": {
				"kind": "multi",
				"effects": [
					{"kind": "modify_damage", "value": -3},
					{"kind": "gain_sword_power", "value": 1}
				]
			},
			"after_use": "graveyard"
		},
		"小无相剑": {
			"id": "小无相剑",
			"name": "小无相剑",
			"type": TYPE_SPELL,
			"tags": ["剑修", "小必杀"],
			"description": "消耗 3 点剑势。对敌人造成 10 点直接伤害。",
			"effect": {"kind": "direct_damage", "value": 10, "sword_cost": 3},
			"after_use": "graveyard"
		},
		"一剑开天": {
			"id": "一剑开天",
			"name": "一剑开天",
			"type": TYPE_SPELL,
			"tags": ["剑修", "终端"],
			"description": "消耗 8 点剑势。对敌人造成 25 点直接伤害。使用后进入除外区。",
			"effect": {"kind": "direct_damage", "value": 25, "sword_cost": 8},
			"after_use": "exile"
		},
		"火球符": {
			"id": "火球符",
			"name": "火球符",
			"type": TYPE_SPELL,
			"tags": ["通用", "符", "伤害"],
			"description": "对敌人造成 6 点直接伤害。",
			"effect": {"kind": "direct_damage", "value": 6},
			"after_use": "graveyard"
		},
		"雷击符": {
			"id": "雷击符",
			"name": "雷击符",
			"type": TYPE_SPELL,
			"tags": ["通用", "符", "伤害"],
			"description": "对敌人造成 9 点直接伤害。",
			"effect": {"kind": "direct_damage", "value": 9},
			"after_use": "graveyard"
		},
		"回春符": {
			"id": "回春符",
			"name": "回春符",
			"type": TYPE_SPELL,
			"tags": ["通用", "符", "回复"],
			"description": "玩家回复 6 点生命。",
			"effect": {"kind": "heal", "value": 6},
			"after_use": "graveyard"
		},
		"破甲符": {
			"id": "破甲符",
			"name": "破甲符",
			"type": TYPE_SPELL,
			"tags": ["通用", "符", "削弱"],
			"description": "敌人防御力 -2，持续到本场战斗结束。",
			"effect": {"kind": "reduce_enemy_defense", "value": 2},
			"after_use": "graveyard"
		},
		"拾符诀": {
			"id": "拾符诀",
			"name": "拾符诀",
			"type": TYPE_SPELL,
			"tags": ["符修", "回收"],
			"description": "从墓地选择 1 张带有“符”标签的卡牌加入手牌。",
			"effect": {"kind": "recover_graveyard_tag", "tag": "符"},
			"after_use": "graveyard"
		},
		"复符诀": {
			"id": "复符诀",
			"name": "复符诀",
			"type": TYPE_SPELL,
			"tags": ["符修", "复制"],
			"description": "本回合下一张使用的“符”牌发动 2 次。第二次效果为原效果的 50%。",
			"effect": {"kind": "copy_next_tag", "tag": "符", "second_multiplier": 0.5},
			"after_use": "graveyard"
		},
		"灵墨重描": {
			"id": "灵墨重描",
			"name": "灵墨重描",
			"type": TYPE_SPELL,
			"tags": ["符修", "检索"],
			"description": "弃置 1 张手牌。从卡组选择 1 张带有“符”标签的卡牌加入手牌。",
			"effect": {"kind": "discard_search_deck_tag", "tag": "符"},
			"after_use": "graveyard"
		},
		"符匣": {
			"id": "符匣",
			"name": "符匣",
			"type": TYPE_SPELL,
			"tags": ["符修", "装备"],
			"description": "装备到装备区。每场战斗第一次使用“符”牌时，该符牌使用后放回卡组顶。",
			"effect": {"kind": "equipment_recycle_first_tag", "tag": "符"},
			"after_use": "equipment"
		},
		"护身符": {
			"id": "护身符",
			"name": "护身符",
			"type": TYPE_DEFENSE,
			"tags": ["通用", "防御"],
			"description": "玩家受到攻击时，本次受到伤害 -5。",
			"trigger_timing": ["player_damage_before"],
			"effect": {"kind": "modify_damage", "value": -5},
			"after_use": "graveyard"
		},
		"替身纸人": {
			"id": "替身纸人",
			"name": "替身纸人",
			"type": TYPE_DEFENSE,
			"tags": ["通用", "保命"],
			"description": "玩家将受到致命伤害时，本次伤害改为使玩家生命值降到 1。",
			"trigger_timing": ["player_lethal_damage_before"],
			"effect": {"kind": "set_player_hp_to_one_if_lethal"},
			"after_use": "exile"
		},
		"破法符": {
			"id": "破法符",
			"name": "破法符",
			"type": TYPE_DEFENSE,
			"tags": ["通用", "反制"],
			"description": "敌人施法时，取消敌人本次施法。",
			"trigger_timing": ["enemy_spell_declared"],
			"effect": {"kind": "interrupt_event"},
			"after_use": "graveyard"
		},
		"护心符": {
			"id": "护心符",
			"name": "护心符",
			"type": TYPE_DEFENSE,
			"tags": ["通用", "保护"],
			"description": "我方法防区卡牌将被破坏前可发动，保护本次被破坏目标。",
			"trigger_timing": ["enemy_destroy_zone_card_declared"],
			"effect": {"kind": "protect_destroy_target"},
			"after_use": "graveyard"
		},
		"青锋剑": {
			"id": "青锋剑",
			"name": "青锋剑",
			"type": TYPE_SPELL,
			"tags": ["通用", "装备", "武器"],
			"description": "装备后，玩家攻击力 +2。使用后进入装备区。",
			"effect": {"kind": "equipment_attack_bonus", "value": 2},
			"after_use": "equipment"
		},
		"铁木甲": {
			"id": "铁木甲",
			"name": "铁木甲",
			"type": TYPE_SPELL,
			"tags": ["通用", "装备", "防具"],
			"description": "装备后，玩家防御力 +1。使用后进入装备区。",
			"effect": {"kind": "equipment_defense_bonus", "value": 1},
			"after_use": "equipment"
		},
		"聚灵佩": {
			"id": "聚灵佩",
			"name": "聚灵佩",
			"type": TYPE_SPELL,
			"tags": ["通用", "装备", "饰品"],
			"description": "装备后，每个玩家回合开始时，如果玩家职业是剑修，获得 1 点剑势。使用后进入装备区。",
			"effect": {"kind": "equipment_sword_per_turn", "value": 1, "job": "sword"},
			"after_use": "equipment"
		}
	}

static func make_card(card_id: String) -> Dictionary:
	var cards := get_cards()
	if not cards.has(card_id):
		return {}
	var card: Dictionary = cards[card_id].duplicate(true)
	card["uid"] = "%s_%d_%d" % [card_id, Time.get_ticks_usec(), randi()]
	return card

static func get_card(card_id: String) -> Dictionary:
	var cards := get_cards()
	if not cards.has(card_id):
		return {}
	return cards[card_id].duplicate(true)

static func has_tag(card: Dictionary, tag: String) -> bool:
	return tag in card.get("tags", [])

static func type_label(card_type: String) -> String:
	if card_type == TYPE_SPELL:
		return "法术牌"
	if card_type == TYPE_DEFENSE:
		return "防御牌"
	return card_type

static func common_pool() -> Array:
	return ["火球符", "雷击符", "回春符", "破甲符", "护身符", "替身纸人", "破法符", "护心符"]

static func sword_pool() -> Array:
	return ["起剑诀", "藏锋", "小无相剑", "剑心通明", "一剑开天", "青锋剑", "铁木甲", "聚灵佩"]

static func talisman_pool() -> Array:
	return ["拾符诀", "复符诀", "灵墨重描", "符匣"]

static func equipment_pool() -> Array:
	return ["青锋剑", "铁木甲", "聚灵佩"]

static func reward_pool_for_job(job_id: String) -> Array:
	var pool := common_pool()
	pool.append_array(equipment_pool())
	if job_id == "sword":
		pool.append_array(sword_pool())
		pool.append_array(sword_pool())
	elif job_id == "talisman":
		pool.append_array(talisman_pool())
		pool.append_array(talisman_pool())
		for card_id in common_pool():
			var card := get_card(card_id)
			if "符" in card.get("tags", []):
				pool.append(card_id)
				pool.append(card_id)
	return pool
