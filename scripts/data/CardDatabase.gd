extends RefCounted
class_name CardDatabase

const TYPE_SPELL := "spell"
const TYPE_DEFENSE := "defense"
const MIN_DECK_SIZE := 10
const MAX_DECK_SIZE := 20
const COMMON_PACK_PREFIX := "common"
const CARD_PACK_SLOT_COUNT := 5

const CARD_UNLOCK_TIERS := {
	"雷击符": 1,
	"裂石符": 1,
	"炽火符": 2,
	"天雷符": 2,
	"灭灵符": 2,
	"甘露符": 1,
	"玉露丹": 2,
	"引路符": 1,
	"清囊术": 1,
	"封存秘卷": 1,
	"缚身符": 1,
	"攻击无效符": 2,
	"折光符": 1,
	"护阵符": 1,
	"反震符": 1,
	"替身纸人": 2,
	"破法符": 1,
	"落雷阵": 2,
	"封藏符": 1,
	"凝神香": 1,
	"护法灯": 1,
	"伏雷符": 2,
	"锁妖符": 1,
	"幻象术": 1,
	"木偶侍": 1,
	"纸甲兵": 1,
	"玄铁剑": 2,
	"护心镜": 2,
	"养剑匣": 1,
	"剑气横扫": 1,
	"万剑回风": 2,
	"小无相剑": 2,
	"召剑诀": 1,
	"万剑诀": 2,
	"一剑开天": 2,
	"复符诀": 1,
	"灵墨重描": 1,
	"符匣": 1
}

const CARD_UNLOCK_PACKS := {
	"火球符": ["common_1"],
	"金刃符": ["common_1"],
	"回春符": ["common_1"],
	"小还丹": ["common_1"],
	"固元符": ["common_1"],
	"血墨符": ["common_1"],
	"换气符": ["common_1"],
	"破甲符": ["common_1"],
	"护身符": ["common_1"],
	"幻象术": ["common_1"],
	"青锋剑": ["common_1"],
	"铁木甲": ["common_1"],
	"雷击符": ["common_2"],
	"裂石符": ["common_2"],
	"甘露符": ["common_2"],
	"引路符": ["common_2"],
	"清囊术": ["common_2"],
	"封存秘卷": ["common_2"],
	"缚身符": ["common_2"],
	"折光符": ["common_2"],
	"护阵符": ["common_2"],
	"反震符": ["common_2"],
	"破法符": ["common_2"],
	"护心符": ["common_2"],
	"封藏符": ["common_2"],
	"凝神香": ["common_2"],
	"护法灯": ["common_2"],
	"锁妖符": ["common_2"],
	"木偶侍": ["common_2"],
	"纸甲兵": ["common_2"],
	"炽火符": ["common_3"],
	"天雷符": ["common_3"],
	"灭灵符": ["common_3"],
	"玉露丹": ["common_3"],
	"攻击无效符": ["common_3"],
	"替身纸人": ["common_3"],
	"落雷阵": ["common_3"],
	"伏雷符": ["common_3"],
	"玄铁剑": ["common_3"],
	"护心镜": ["common_3"],
	"起剑诀": ["sword_1"],
	"引剑入体": ["sword_1"],
	"藏锋": ["sword_1"],
	"疾剑诀": ["sword_1"],
	"养剑匣": ["sword_2"],
	"剑气横扫": ["sword_2"],
	"召剑诀": ["sword_2"],
	"万剑回风": ["sword_3"],
	"小无相剑": ["sword_3"],
	"万剑诀": ["sword_3"],
	"一剑开天": ["sword_3"],
	"拾符诀": ["talisman_1"],
	"复符诀": ["talisman_2"],
	"灵墨重描": ["talisman_2"],
	"符匣": ["talisman_2"]
}

static func get_cards() -> Dictionary:
	return {
		"火球符": {
			"id": "火球符",
			"name": "火球符",
			"type": TYPE_SPELL,
			"build_cost": 0,
			"tags": ["通用", "符", "伤害"],
			"description": "对敌方单位造成 4 点伤害。",
			"effect": {"kind": "direct_damage", "value": 4},
			"after_use": "graveyard"
		},
		"金刃符": {
			"id": "金刃符",
			"name": "金刃符",
			"type": TYPE_SPELL,
			"build_cost": 0,
			"tags": ["通用", "符", "伤害"],
			"description": "对敌方单位造成 3 点伤害。",
			"effect": {"kind": "direct_damage", "value": 3},
			"after_use": "graveyard"
		},
		"雷击符": {
			"id": "雷击符",
			"name": "雷击符",
			"type": TYPE_SPELL,
			"build_cost": 3,
			"tags": ["通用", "符", "伤害"],
			"description": "对敌方单位造成 8 点伤害。",
			"effect": {"kind": "direct_damage", "value": 8},
			"after_use": "graveyard"
		},
		"裂石符": {
			"id": "裂石符",
			"name": "裂石符",
			"type": TYPE_SPELL,
			"build_cost": 4,
			"tags": ["通用", "符", "伤害", "削弱"],
			"description": "对敌方单位造成 7 点伤害，并使目标防御力 -1。",
			"effect": {
				"kind": "multi",
				"effects": [
					{"kind": "direct_damage", "value": 7},
					{"kind": "reduce_enemy_defense", "value": 1}
				]
			},
			"after_use": "graveyard"
		},
		"炽火符": {
			"id": "炽火符",
			"name": "炽火符",
			"type": TYPE_SPELL,
			"build_cost": 5,
			"tags": ["通用", "符", "伤害"],
			"description": "对敌方单位造成 12 点伤害。",
			"effect": {"kind": "direct_damage", "value": 12},
			"after_use": "graveyard"
		},
		"天雷符": {
			"id": "天雷符",
			"name": "天雷符",
			"type": TYPE_SPELL,
			"build_cost": 10,
			"tags": ["通用", "符", "伤害"],
			"description": "对敌方单位造成 22 点伤害。",
			"effect": {"kind": "direct_damage", "value": 22},
			"after_use": "graveyard"
		},
		"灭灵符": {
			"id": "灭灵符",
			"name": "灭灵符",
			"type": TYPE_SPELL,
			"build_cost": 15,
			"tags": ["通用", "符", "伤害"],
			"description": "对敌方单位造成 32 点伤害。",
			"effect": {"kind": "direct_damage", "value": 32},
			"after_use": "graveyard"
		},
		"回春符": {
			"id": "回春符",
			"name": "回春符",
			"type": TYPE_SPELL,
			"build_cost": 0,
			"tags": ["通用", "符", "回复"],
			"description": "玩家回复 4 点生命。",
			"effect": {"kind": "heal", "value": 4},
			"after_use": "graveyard"
		},
		"甘露符": {
			"id": "甘露符",
			"name": "甘露符",
			"type": TYPE_SPELL,
			"build_cost": 2,
			"tags": ["通用", "符", "回复"],
			"description": "玩家回复 8 点生命。",
			"effect": {"kind": "heal", "value": 8},
			"after_use": "graveyard"
		},
		"玉露丹": {
			"id": "玉露丹",
			"name": "玉露丹",
			"type": TYPE_SPELL,
			"build_cost": 5,
			"tags": ["通用", "回复"],
			"description": "玩家回复 15 点生命。",
			"effect": {"kind": "heal", "value": 15},
			"after_use": "graveyard"
		},
		"小还丹": {
			"id": "小还丹",
			"name": "小还丹",
			"type": TYPE_SPELL,
			"build_cost": 1,
			"tags": ["通用", "回复"],
			"description": "玩家回复 6 点生命。",
			"effect": {"kind": "heal", "value": 6},
			"after_use": "graveyard"
		},
		"固元符": {
			"id": "固元符",
			"name": "固元符",
			"type": TYPE_SPELL,
			"build_cost": 0,
			"tags": ["通用", "防御", "符"],
			"description": "我方单位获得 3 点下次减伤。",
			"effect": {"kind": "add_status", "target": "all_players", "status": "下次减伤", "value": 3},
			"after_use": "graveyard"
		},
		"血墨符": {
			"id": "血墨符",
			"name": "血墨符",
			"type": TYPE_SPELL,
			"build_cost": 1,
			"tags": ["通用", "符", "抽牌"],
			"description": "玩家失去 4 点生命，抽 2 张牌。",
			"effect": {"kind": "pay_life_draw", "life_cost": 4, "draw": 2},
			"after_use": "graveyard"
		},
		"封存秘卷": {
			"id": "封存秘卷",
			"name": "封存秘卷",
			"type": TYPE_SPELL,
			"build_cost": 3,
			"tags": ["通用", "抽牌"],
			"description": "抽 2 张牌。使用后进入除外区。",
			"effect": {"kind": "draw_cards", "value": 2},
			"after_use": "exile"
		},
		"换气符": {
			"id": "换气符",
			"name": "换气符",
			"type": TYPE_SPELL,
			"build_cost": 0,
			"tags": ["通用", "循环", "符"],
			"description": "弃置 1 张手牌，抽 1 张牌。",
			"effect": {"kind": "discard_draw", "draw": 1},
			"after_use": "graveyard"
		},
		"引路符": {
			"id": "引路符",
			"name": "引路符",
			"type": TYPE_SPELL,
			"build_cost": 1,
			"tags": ["通用", "检索", "符"],
			"description": "从卡组选择 1 张 0 分通用牌加入手牌。使用后进入除外区。",
			"effect": {
				"kind": "search_deck_filter_to_hand",
				"filter": {"tag": "通用", "max_cost": 0},
				"prompt": "选择 1 张 0 分通用牌加入手牌"
			},
			"after_use": "exile"
		},
		"清囊术": {
			"id": "清囊术",
			"name": "清囊术",
			"type": TYPE_SPELL,
			"build_cost": 3,
			"tags": ["通用", "循环"],
			"description": "抽 2 张牌，然后弃置 1 张手牌。",
			"effect": {"kind": "draw_then_discard", "draw": 2},
			"after_use": "graveyard"
		},
		"破甲符": {
			"id": "破甲符",
			"name": "破甲符",
			"type": TYPE_SPELL,
			"build_cost": 1,
			"tags": ["通用", "削弱", "符"],
			"description": "给予敌方单位 2 层破甲。破甲会降低防御力，并在其回合结束时衰减。",
			"effect": {"kind": "add_status", "target": "enemy", "status": "破甲", "value": 2},
			"after_use": "graveyard"
		},
		"缚身符": {
			"id": "缚身符",
			"name": "缚身符",
			"type": TYPE_SPELL,
			"build_cost": 2,
			"tags": ["通用", "削弱", "符"],
			"description": "给予敌方单位 2 层虚弱。虚弱会降低攻击力，并在其回合结束时衰减。",
			"effect": {"kind": "add_status", "target": "enemy", "status": "虚弱", "value": 2},
			"after_use": "graveyard"
		},
		"护身符": {
			"id": "护身符",
			"name": "护身符",
			"type": TYPE_DEFENSE,
			"build_cost": 0,
			"tags": ["通用", "防御"],
			"description": "我方单位受到攻击时，本次受到伤害 -4。",
			"trigger_timing": ["player_damage_before"],
			"response_target": "ally_unit",
			"effect": {"kind": "modify_damage", "value": -4},
			"after_use": "graveyard"
		},
		"攻击无效符": {
			"id": "攻击无效符",
			"name": "攻击无效符",
			"type": TYPE_DEFENSE,
			"build_cost": 4,
			"tags": ["通用", "反制", "符"],
			"description": "敌方单位发动攻击前，取消本次攻击。对首领改为本次攻击伤害 -8。",
			"trigger_timing": ["enemy_attack_declared"],
			"effect": {"kind": "cancel_or_reduce_event", "boss_reduce": 8},
			"after_use": "graveyard"
		},
		"折光符": {
			"id": "折光符",
			"name": "折光符",
			"type": TYPE_DEFENSE,
			"build_cost": 2,
			"tags": ["通用", "防御", "符"],
			"description": "我方单位受到施法伤害前，本次伤害 -6。",
			"trigger_timing": ["player_damage_before"],
			"response_target": "ally_unit",
			"event_sources": ["enemy_spell"],
			"effect": {"kind": "modify_damage", "value": -6},
			"after_use": "graveyard"
		},
		"护阵符": {
			"id": "护阵符",
			"name": "护阵符",
			"type": TYPE_DEFENSE,
			"build_cost": 1,
			"tags": ["通用", "保护", "符"],
			"description": "我方放置区卡牌将被破坏前，取消本次破坏。",
			"trigger_timing": ["enemy_destroy_zone_card_declared"],
			"effect": {"kind": "protect_destroy_target"},
			"after_use": "graveyard"
		},
		"反震符": {
			"id": "反震符",
			"name": "反震符",
			"type": TYPE_DEFENSE,
			"build_cost": 3,
			"tags": ["通用", "反击", "符"],
			"description": "我方单位受到攻击时，本次伤害 -3，并对攻击者造成 3 点伤害。",
			"trigger_timing": ["player_damage_before"],
			"response_target": "ally_unit",
			"effect": {
				"kind": "multi",
				"effects": [
					{"kind": "modify_damage", "value": -3},
					{"kind": "damage_event_source", "value": 3}
				]
			},
			"after_use": "graveyard"
		},
		"替身纸人": {
			"id": "替身纸人",
			"name": "替身纸人",
			"type": TYPE_DEFENSE,
			"build_cost": 6,
			"tags": ["通用", "保命"],
			"description": "玩家将受到致命伤害时，本次伤害改为使玩家生命值降到 1。使用后进入除外区。",
			"trigger_timing": ["player_lethal_damage_before"],
			"response_target": "player",
			"effect": {"kind": "set_player_hp_to_one_if_lethal"},
			"after_use": "exile"
		},
		"破法符": {
			"id": "破法符",
			"name": "破法符",
			"type": TYPE_DEFENSE,
			"build_cost": 3,
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
			"build_cost": 1,
			"tags": ["通用", "保护"],
			"description": "我方法防区卡牌将被破坏前可发动，保护本次被破坏目标。",
			"trigger_timing": ["enemy_destroy_zone_card_declared"],
			"effect": {"kind": "protect_destroy_target"},
			"after_use": "graveyard"
		},
		"落雷阵": {
			"id": "落雷阵",
			"name": "落雷阵",
			"type": TYPE_DEFENSE,
			"build_cost": 5,
			"tags": ["通用", "反击"],
			"description": "敌方单位发动攻击前，对攻击者造成 8 点伤害。",
			"trigger_timing": ["enemy_attack_declared"],
			"effect": {"kind": "damage_event_source", "value": 8},
			"after_use": "graveyard"
		},
		"幻象术": {
			"id": "幻象术",
			"name": "幻象术",
			"type": TYPE_SPELL,
			"build_cost": 0,
			"tags": ["通用", "召唤"],
			"description": "召唤 2 个幻象。幻象没有攻击能力，也没有嘲讽。",
			"effect": {
				"kind": "summon",
				"count": 2,
				"unit": {
					"id": "illusion",
					"name": "幻象",
					"unit_type": "summon",
					"max_hp": 1,
					"attack": 0,
					"defense": 0
				}
			},
			"after_use": "graveyard"
		},
		"封藏符": {
			"id": "封藏符",
			"name": "封藏符",
			"type": TYPE_SPELL,
			"build_cost": 2,
			"tags": ["通用", "延迟", "检索", "符"],
			"description": "从卡组选择 1 张牌压在此牌下。2 个玩家回合后，将被压牌加入手牌。若此牌被破坏，被压牌进入墓地。",
			"effect": {
				"kind": "zone_attach_search",
				"countdown": 2,
				"filter": {},
				"prompt": "选择 1 张卡组中的牌压在封藏符下"
			},
			"after_use": "spell_zone"
		},
		"凝神香": {
			"id": "凝神香",
			"name": "凝神香",
			"type": TYPE_SPELL,
			"build_cost": 2,
			"tags": ["通用", "延迟", "抽牌"],
			"description": "明牌放置，倒计时 2。结算时抽 2 张牌，然后此牌进入墓地。",
			"effect": {"kind": "zone_delayed_effect", "countdown": 2, "delayed_effect": {"kind": "draw_cards", "value": 2}},
			"after_use": "spell_zone"
		},
		"护法灯": {
			"id": "护法灯",
			"name": "护法灯",
			"type": TYPE_SPELL,
			"build_cost": 3,
			"tags": ["通用", "持续", "防御"],
			"description": "明牌放置。我方每回合第一次受到伤害 -2。触发 3 次后进入墓地。",
			"effect": {"kind": "zone_damage_reduction", "value": 2, "uses": 3},
			"after_use": "spell_zone"
		},
		"伏雷符": {
			"id": "伏雷符",
			"name": "伏雷符",
			"type": TYPE_SPELL,
			"build_cost": 4,
			"tags": ["通用", "延迟", "伤害", "符"],
			"description": "明牌放置，倒计时 1。结算时对随机敌方单位造成 10 点伤害。",
			"effect": {"kind": "zone_delayed_effect", "countdown": 1, "delayed_effect": {"kind": "random_enemy_damage", "value": 10}},
			"after_use": "spell_zone"
		},
		"锁妖符": {
			"id": "锁妖符",
			"name": "锁妖符",
			"type": TYPE_SPELL,
			"build_cost": 3,
			"tags": ["通用", "延迟", "削弱", "符"],
			"description": "明牌放置。下个敌方回合第一名行动的敌方单位获得 4 层迟滞。",
			"effect": {"kind": "zone_next_enemy_action_status", "status": "迟滞", "value": 4},
			"after_use": "spell_zone"
		},
		"青锋剑": {
			"id": "青锋剑",
			"name": "青锋剑",
			"type": TYPE_SPELL,
			"build_cost": 1,
			"tags": ["通用", "装备", "武器"],
			"description": "装备后，目标单位攻击力 +2。使用后进入装备区。",
			"effect": {"kind": "equipment_attack_bonus", "value": 2},
			"after_use": "equipment"
		},
		"铁木甲": {
			"id": "铁木甲",
			"name": "铁木甲",
			"type": TYPE_SPELL,
			"build_cost": 0,
			"tags": ["通用", "装备", "防具"],
			"description": "装备后，目标单位防御力 +1。使用后进入装备区。",
			"effect": {"kind": "equipment_defense_bonus", "value": 1},
			"after_use": "equipment"
		},
		"木偶侍": {
			"id": "木偶侍",
			"name": "木偶侍",
			"type": TYPE_SPELL,
			"build_cost": 2,
			"tags": ["通用", "召唤"],
			"description": "召唤 1 个木偶侍。木偶侍为 6 生命、0 攻击、0 防御，带嘲讽。",
			"effect": {
				"kind": "summon",
				"count": 1,
				"unit": {
					"id": "wooden_attendant",
					"name": "木偶侍",
					"unit_type": "summon",
					"max_hp": 6,
					"attack": 0,
					"defense": 0,
					"status_counters": {"taunt": 1}
				}
			},
			"after_use": "graveyard"
		},
		"纸甲兵": {
			"id": "纸甲兵",
			"name": "纸甲兵",
			"type": TYPE_SPELL,
			"build_cost": 3,
			"tags": ["通用", "召唤"],
			"description": "召唤 1 个纸甲兵。纸甲兵为 5 生命、3 攻击、0 防御。",
			"effect": {
				"kind": "summon",
				"count": 1,
				"unit": {
					"id": "paper_soldier",
					"name": "纸甲兵",
					"unit_type": "summon",
					"max_hp": 5,
					"attack": 3,
					"defense": 0
				}
			},
			"after_use": "graveyard"
		},
		"玄铁剑": {
			"id": "玄铁剑",
			"name": "玄铁剑",
			"type": TYPE_SPELL,
			"build_cost": 6,
			"tags": ["通用", "装备", "武器"],
			"description": "装备后，目标单位攻击力 +4。使用后进入装备区。",
			"effect": {"kind": "equipment_attack_bonus", "value": 4},
			"after_use": "equipment"
		},
		"护心镜": {
			"id": "护心镜",
			"name": "护心镜",
			"type": TYPE_SPELL,
			"build_cost": 4,
			"tags": ["通用", "装备", "防具", "保命"],
			"description": "装备后，目标单位防御力 +1。每场战斗首次受到致命伤害时，破坏此装备并使该单位生命变为 1。",
			"effect": {
				"kind": "multi",
				"effects": [
					{"kind": "equipment_defense_bonus", "value": 1},
					{"kind": "equipment_lethal_save"}
				]
			},
			"after_use": "equipment"
		},
		"起剑诀": {
			"id": "起剑诀",
			"name": "起剑诀",
			"type": TYPE_SPELL,
			"build_cost": 0,
			"tags": ["剑修", "剑势"],
			"description": "获得 2 点剑势。",
			"effect": {"kind": "gain_sword_power", "value": 2},
			"after_use": "graveyard"
		},
		"引剑入体": {
			"id": "引剑入体",
			"name": "引剑入体",
			"type": TYPE_SPELL,
			"build_cost": 2,
			"tags": ["剑修", "成长"],
			"description": "消耗 2 点剑势。本场战斗玩家攻击力 +2。",
			"effect": {"kind": "modify_player_attack", "value": 2, "sword_cost": 2},
			"after_use": "graveyard"
		},
		"养剑匣": {
			"id": "养剑匣",
			"name": "养剑匣",
			"type": TYPE_SPELL,
			"build_cost": 3,
			"tags": ["剑修", "装备", "剑势"],
			"description": "装备后，每个玩家回合开始时获得 1 点剑势。",
			"effect": {"kind": "equipment_sword_per_turn", "value": 1, "job": "sword"},
			"after_use": "equipment"
		},
		"疾剑诀": {
			"id": "疾剑诀",
			"name": "疾剑诀",
			"type": TYPE_SPELL,
			"build_cost": 3,
			"tags": ["剑修", "多动"],
			"description": "消耗 3 点剑势。本回合玩家可额外进行 1 次基础攻击。",
			"effect": {"kind": "extra_player_attack_this_turn", "value": 1, "sword_cost": 3},
			"after_use": "graveyard"
		},
		"剑气横扫": {
			"id": "剑气横扫",
			"name": "剑气横扫",
			"type": TYPE_SPELL,
			"build_cost": 4,
			"tags": ["剑修", "群体"],
			"description": "消耗 4 点剑势。玩家下一次基础攻击改为攻击敌方全体。",
			"effect": {"kind": "next_attack_all_enemies", "sword_cost": 4},
			"after_use": "graveyard"
		},
		"藏锋": {
			"id": "藏锋",
			"name": "藏锋",
			"type": TYPE_DEFENSE,
			"build_cost": 2,
			"tags": ["剑修", "反击"],
			"description": "玩家受到攻击时，对攻击者造成 1 次玩家普通攻击伤害。",
			"trigger_timing": ["player_damage_before"],
			"response_target": "player",
			"effect": {"kind": "counter_attack_source"},
			"after_use": "graveyard"
		},
		"万剑回风": {
			"id": "万剑回风",
			"name": "万剑回风",
			"type": TYPE_DEFENSE,
			"build_cost": 7,
			"tags": ["剑修", "反击", "多段"],
			"description": "消耗 3 点剑势。玩家受到攻击时，随机攻击敌方单位 2-4 次，每次造成 1 次玩家普通攻击伤害。",
			"trigger_timing": ["player_damage_before"],
			"response_target": "player",
			"effect": {"kind": "random_counter_attacks", "min_hits": 2, "max_hits": 4, "sword_cost": 3},
			"after_use": "graveyard"
		},
		"小无相剑": {
			"id": "小无相剑",
			"name": "小无相剑",
			"type": TYPE_SPELL,
			"build_cost": 8,
			"tags": ["剑修", "成长"],
			"description": "消耗 5 点剑势。本场战斗玩家每回合基础攻击次数 +1。使用后进入除外区。",
			"effect": {"kind": "increase_player_attack_actions", "value": 1, "sword_cost": 5},
			"after_use": "exile"
		},
		"召剑诀": {
			"id": "召剑诀",
			"name": "召剑诀",
			"type": TYPE_SPELL,
			"build_cost": 5,
			"tags": ["剑修", "检索"],
			"description": "从卡组选择 1 张剑修卡加入手牌。",
			"effect": {"kind": "search_deck_tag", "tag": "剑修"},
			"after_use": "graveyard"
		},
		"万剑诀": {
			"id": "万剑诀",
			"name": "万剑诀",
			"type": TYPE_SPELL,
			"build_cost": 10,
			"tags": ["剑修", "多段"],
			"description": "消耗 6 点剑势。玩家下一次基础攻击改为随机攻击敌方单位 4-6 次。",
			"effect": {"kind": "next_attack_random_multi", "min_hits": 4, "max_hits": 6, "sword_cost": 6},
			"after_use": "graveyard"
		},
		"一剑开天": {
			"id": "一剑开天",
			"name": "一剑开天",
			"type": TYPE_SPELL,
			"build_cost": 10,
			"tags": ["剑修", "终端"],
			"description": "消耗 8 点剑势。玩家下一次基础攻击最终伤害 x2。",
			"effect": {"kind": "next_attack_damage_multiplier", "multiplier": 2.0, "sword_cost": 8},
			"after_use": "graveyard"
		},
		"拾符诀": {
			"id": "拾符诀",
			"name": "拾符诀",
			"type": TYPE_SPELL,
			"build_cost": 1,
			"tags": ["符修", "回收"],
			"description": "从墓地选择 1 张带有“符”标签的卡牌加入手牌。",
			"effect": {"kind": "recover_graveyard_tag", "tag": "符"},
			"after_use": "graveyard"
		},
		"复符诀": {
			"id": "复符诀",
			"name": "复符诀",
			"type": TYPE_SPELL,
			"build_cost": 3,
			"tags": ["符修", "复制"],
			"description": "本回合下一张使用的“符”牌发动 2 次。第二次效果为原效果的 50%。",
			"effect": {"kind": "copy_next_tag", "tag": "符", "second_multiplier": 0.5},
			"after_use": "graveyard"
		},
		"灵墨重描": {
			"id": "灵墨重描",
			"name": "灵墨重描",
			"type": TYPE_SPELL,
			"build_cost": 3,
			"tags": ["符修", "检索"],
			"description": "弃置 1 张手牌。从卡组选择 1 张带有“符”标签的卡牌加入手牌。",
			"effect": {"kind": "discard_search_deck_tag", "tag": "符"},
			"after_use": "graveyard"
		},
		"符匣": {
			"id": "符匣",
			"name": "符匣",
			"type": TYPE_SPELL,
			"build_cost": 4,
			"tags": ["符修", "装备"],
			"description": "装备后，每场战斗第一次使用“符”牌时，该符牌使用后放回卡组顶。",
			"effect": {"kind": "equipment_recycle_first_tag", "tag": "符"},
			"after_use": "equipment"
		}
	}

static func make_card(card_id: String) -> Dictionary:
	var card: Dictionary = get_card(card_id)
	if card.is_empty():
		return {}
	card["uid"] = "%s_%d_%d" % [card_id, Time.get_ticks_usec(), randi()]
	return card

static func get_card(card_id: String) -> Dictionary:
	var cards := get_cards()
	if not cards.has(card_id):
		return {}
	var card: Dictionary = cards[card_id].duplicate(true)
	return _with_unlock_metadata(card)

static func card_unlock_tier(card_id: String) -> int:
	var card := get_card(card_id)
	return int(card.get("unlock_tier", 0))

static func card_unlock_pack(card_id: String) -> String:
	var card := get_card(card_id)
	return str(card.get("unlock_pack", "common_1"))

static func card_unlock_packs(card_id: String) -> Array:
	var card := get_card(card_id)
	var packs: Array = card.get("unlock_packs", [])
	if packs.is_empty():
		var single_pack := str(card.get("unlock_pack", "common_1"))
		return [] if single_pack == "" else [single_pack]
	return packs.duplicate()

static func unlocked_packs_for_job(job_id: String, unlock_tier := 0) -> Array:
	var result: Array = []
	var max_tier: int = max(0, int(unlock_tier))
	for tier_index in range(max_tier + 1):
		result.append("%s_%d" % [COMMON_PACK_PREFIX, tier_index + 1])
		var job_prefix := _pack_prefix_for_job(job_id)
		if job_prefix != "":
			result.append("%s_%d" % [job_prefix, tier_index + 1])
	return _deduplicate_strings(result)

static func pack_ids_for_job(job_id: String, pack_count := CARD_PACK_SLOT_COUNT) -> Array:
	var result: Array = []
	var count: int = max(1, int(pack_count))
	var job_prefix := _pack_prefix_for_job(job_id)
	for tier_index in range(count):
		result.append("%s_%d" % [COMMON_PACK_PREFIX, tier_index + 1])
		if job_prefix != "":
			result.append("%s_%d" % [job_prefix, tier_index + 1])
	return _deduplicate_strings(result)

static func pack_card_counts_for_job(job_id: String, pack_count := CARD_PACK_SLOT_COUNT) -> Dictionary:
	var result: Dictionary = {}
	for pack_id_variant in pack_ids_for_job(job_id, pack_count):
		result[str(pack_id_variant)] = 0
	var pool := common_pool()
	pool.append_array(job_pool(job_id))
	for card_id_variant in pool:
		for pack_variant in card_unlock_packs(str(card_id_variant)):
			var pack_id := str(pack_variant)
			if result.has(pack_id):
				result[pack_id] = int(result.get(pack_id, 0)) + 1
	return result

static func card_unlocked_for_job(card_id: String, job_id: String, unlock_tier := 0, unlocked_packs: Array = []) -> bool:
	var packs: Array = unlocked_packs.duplicate() if not unlocked_packs.is_empty() else unlocked_packs_for_job(job_id, unlock_tier)
	for pack_variant in card_unlock_packs(card_id):
		if packs.has(str(pack_variant)):
			return true
	return false

static func pack_display_name(pack_id: String) -> String:
	var parts := pack_id.split("_")
	if parts.size() < 2:
		return pack_id
	var prefix := str(parts[0])
	var number := str(parts[1])
	match prefix:
		"common":
			return "通用%s" % number
		"sword":
			return "剑修%s" % number
		"talisman":
			return "符修%s" % number
	return pack_id

static func card_score(card_id: String) -> int:
	var card := get_card(card_id)
	return int(card.get("build_cost", card.get("score", 0)))

static func deck_score(deck_ids: Array) -> int:
	var total := 0
	for card_id_variant in deck_ids:
		total += card_score(str(card_id_variant))
	return total

static func card_count(deck_ids: Array, card_id: String) -> int:
	var total := 0
	for existing_id_variant in deck_ids:
		if str(existing_id_variant) == card_id:
			total += 1
	return total

static func can_add_card_to_deck(card_id: String, deck_ids: Array, score_limit := 0) -> bool:
	if card_id == "" or get_card(card_id).is_empty():
		return false
	if deck_ids.size() >= MAX_DECK_SIZE:
		return false
	if score_limit > 0 and deck_score(deck_ids) + card_score(card_id) > score_limit:
		return false
	return true

static func deck_add_block_reason(card_id: String, deck_ids: Array, score_limit := 0) -> String:
	if card_id == "" or get_card(card_id).is_empty():
		return "未知卡牌"
	if deck_ids.size() >= MAX_DECK_SIZE:
		return "卡组已达到 %d 张上限" % MAX_DECK_SIZE
	if score_limit > 0 and deck_score(deck_ids) + card_score(card_id) > score_limit:
		return "分数超过上限 %d" % score_limit
	return ""

static func shop_price(card_id: String) -> int:
	var card := get_card(card_id)
	if card.is_empty():
		return 0
	if card.has("shop_price"):
		return int(card.get("shop_price", 0))
	return 12 + card_score(card_id) * 8

static func sell_price(card_id: String) -> int:
	var price := shop_price(card_id)
	if price <= 0:
		return 0
	return max(4, int(round(float(price) * 0.45)))

static func has_tag(card: Dictionary, tag: String) -> bool:
	return tag in card.get("tags", [])

static func type_label(card_type: String) -> String:
	if card_type == TYPE_SPELL:
		return "法术牌"
	if card_type == TYPE_DEFENSE:
		return "防御牌"
	return card_type

static func common_pool() -> Array:
	return [
		"火球符", "金刃符", "雷击符", "裂石符", "炽火符", "天雷符", "灭灵符",
		"回春符", "小还丹", "甘露符", "玉露丹", "固元符",
		"血墨符", "换气符", "引路符", "清囊术", "封存秘卷",
		"破甲符", "缚身符",
		"护身符", "攻击无效符", "折光符", "护阵符", "反震符", "替身纸人", "破法符", "护心符", "落雷阵",
		"封藏符", "凝神香", "护法灯", "伏雷符", "锁妖符",
		"幻象术", "木偶侍", "纸甲兵",
		"青锋剑", "铁木甲", "玄铁剑", "护心镜"
	]

static func job_pool(job_id: String) -> Array:
	match job_id:
		"sword":
			return ["起剑诀", "引剑入体", "养剑匣", "疾剑诀", "剑气横扫", "藏锋", "万剑回风", "小无相剑", "召剑诀", "万剑诀", "一剑开天"]
		"talisman":
			return ["拾符诀", "复符诀", "灵墨重描", "符匣"]
	return []

static func sword_pool() -> Array:
	return job_pool("sword")

static func talisman_pool() -> Array:
	return job_pool("talisman")

static func reward_pool_for_job(job_id: String, encounter_type := "normal", unlock_tier := 0, unlocked_packs: Array = []) -> Array:
	var pool := common_pool()
	pool.append_array(job_pool(job_id))
	return _filter_reward_pool_by_encounter(_filter_pool_by_unlock(pool, job_id, unlock_tier, unlocked_packs), encounter_type)

static func reward_pool_for_cost(job_id: String, min_cost: int, max_cost: int, scope := "all", unlock_tier := 0, unlocked_packs: Array = []) -> Array:
	var pool: Array = []
	if scope == "all" or scope == "common":
		pool.append_array(common_pool())
	if scope == "all" or scope == "job":
		pool.append_array(job_pool(job_id))
	return _filter_pool_by_cost(_filter_pool_by_unlock(pool, job_id, unlock_tier, unlocked_packs), min_cost, max_cost)

static func random_reward_card(job_id: String, rng: RandomNumberGenerator, min_cost: int, max_cost: int, unlock_tier := 0, unlocked_packs: Array = []) -> String:
	var scopes := ["common", "job"]
	if rng.randf() < 0.5:
		scopes.reverse()
	for scope in scopes:
		var scoped_pool: Array = reward_pool_for_cost(job_id, min_cost, max_cost, scope, unlock_tier, unlocked_packs)
		if not scoped_pool.is_empty():
			return str(scoped_pool[rng.randi_range(0, scoped_pool.size() - 1)])
	var fallback: Array = reward_pool_for_cost(job_id, 0, 99, "all", unlock_tier, unlocked_packs)
	if fallback.is_empty():
		return ""
	return str(fallback[rng.randi_range(0, fallback.size() - 1)])

static func shop_stock(job_id: String, realm_index: int, rng: RandomNumberGenerator, count := 6, unlock_tier := 0, unlocked_packs: Array = []) -> Array:
	var stock: Array = []
	var attempts := 0
	var max_cost: int = min(10 + realm_index * 3, 24)
	while stock.size() < count and attempts < 100:
		attempts += 1
		var card_id := random_reward_card(job_id, rng, 0, max_cost, unlock_tier, unlocked_packs)
		if card_id == "":
			break
		var already_has := false
		for item in stock:
			if str(item.get("card_id", "")) == card_id:
				already_has = true
				break
		if already_has:
			continue
		stock.append({"card_id": card_id, "price": shop_price(card_id)})
	return stock

static func _filter_reward_pool_by_encounter(pool: Array, encounter_type: String) -> Array:
	var result: Array = []
	var min_cost := 0
	var max_cost := 6
	match encounter_type:
		"elite":
			min_cost = 1
			max_cost = 12
		"boss":
			min_cost = 3
			max_cost = 99
	for card_id_variant in pool:
		var card_id := str(card_id_variant)
		var cost := card_score(card_id)
		if cost >= min_cost and cost <= max_cost:
			result.append(card_id)
	if result.size() >= 3:
		return result
	if encounter_type == "boss":
		var relaxed_boss: Array = _filter_pool_by_cost(pool, 1, 99)
		if relaxed_boss.size() >= 3:
			return relaxed_boss
	elif encounter_type == "elite":
		var relaxed_elite: Array = _filter_pool_by_cost(pool, 0, 12)
		if relaxed_elite.size() >= 3:
			return relaxed_elite
	if result.is_empty():
		return pool
	return result

static func _filter_pool_by_cost(pool: Array, min_cost: int, max_cost: int) -> Array:
	var result: Array = []
	for card_id_variant in pool:
		var card_id := str(card_id_variant)
		var cost := card_score(card_id)
		if cost >= min_cost and cost <= max_cost:
			result.append(card_id)
	return result

static func _filter_pool_by_unlock(pool: Array, job_id: String, unlock_tier: int, unlocked_packs: Array = []) -> Array:
	var result: Array = []
	var packs: Array = unlocked_packs.duplicate() if not unlocked_packs.is_empty() else unlocked_packs_for_job(job_id, unlock_tier)
	for card_id_variant in pool:
		var card_id := str(card_id_variant)
		if card_unlocked_for_job(card_id, job_id, unlock_tier, packs):
			result.append(card_id)
	return result

static func _with_unlock_metadata(card: Dictionary) -> Dictionary:
	var card_id := str(card.get("id", ""))
	var explicit_packs: Array = _explicit_unlock_packs(card_id)
	var unlock_tier: int = _tier_from_pack(str(explicit_packs[0])) if not explicit_packs.is_empty() else int(CARD_UNLOCK_TIERS.get(card_id, 0))
	if not card.has("unlock_tier"):
		card["unlock_tier"] = unlock_tier
	if not card.has("unlock_pack"):
		card["unlock_pack"] = str(explicit_packs[0]) if not explicit_packs.is_empty() else _pack_for_card(card_id, int(card.get("unlock_tier", 0)))
	if not card.has("unlock_packs"):
		card["unlock_packs"] = explicit_packs.duplicate() if not explicit_packs.is_empty() else [str(card.get("unlock_pack", ""))]
	if not card.has("default_unlocked"):
		card["default_unlocked"] = int(card.get("unlock_tier", 0)) <= 0
	return card

static func _explicit_unlock_packs(card_id: String) -> Array:
	var packs: Array = CARD_UNLOCK_PACKS.get(card_id, [])
	var result: Array = []
	for pack_variant in packs:
		var pack_id := str(pack_variant)
		if pack_id != "" and not result.has(pack_id):
			result.append(pack_id)
	return result

static func _tier_from_pack(pack_id: String) -> int:
	var parts := pack_id.split("_")
	if parts.size() < 2:
		return 0
	var number := str(parts[1])
	if not number.is_valid_int():
		return 0
	return max(0, int(number) - 1)

static func _pack_for_card(card_id: String, unlock_tier: int) -> String:
	var prefix := COMMON_PACK_PREFIX
	for job_id in ["sword", "talisman"]:
		if job_pool(job_id).has(card_id):
			prefix = _pack_prefix_for_job(job_id)
			break
	return "%s_%d" % [prefix, max(0, unlock_tier) + 1]

static func _pack_prefix_for_job(job_id: String) -> String:
	match job_id:
		"sword":
			return "sword"
		"talisman":
			return "talisman"
	return ""

static func _deduplicate_strings(values: Array) -> Array:
	var result: Array = []
	for value_variant in values:
		var value := str(value_variant)
		if value != "" and not result.has(value):
			result.append(value)
	return result
