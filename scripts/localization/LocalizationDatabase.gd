extends RefCounted
class_name LocalizationDatabase

const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")
const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const CharacterDatabaseScript = preload("res://scripts/data/CharacterDatabase.gd")
const StatusDatabaseScript = preload("res://scripts/data/StatusDatabase.gd")
const EventDatabaseScript = preload("res://scripts/data/EventDatabase.gd")
const MapContentDatabaseScript = preload("res://scripts/data/MapContentDatabase.gd")

const DEFAULT_LANGUAGE_ID := "zh_cn"
const CONTENT_STATE_ACTIVE := "active"

const REQUIRED_SCREEN_TEXT_IDS := [
	"common.accept", "common.cancel", "common.choose", "common.choose_card", "common.close", "common.collapse", "common.spirit_stones",
	"deck.action.add", "deck.action.remove",
	"job_select.back", "job_select.confirm", "job_select.progress", "job_select.progress_empty", "job_select.stats", "job_select.title",
	"prep.action.back", "prep.action.growth", "prep.action.packs", "prep.action.start",
	"prep.stats", "prep.points", "prep.open_packs",
	"prep.growth.title", "prep.growth.max_level", "prep.growth.need", "prep.growth.upgrade", "prep.growth.summary", "prep.growth.cost_max", "prep.growth.cost_insufficient", "prep.growth.cost",
	"prep.packs.title", "prep.packs.summary", "prep.packs.open", "prep.packs.closed", "prep.packs.count", "prep.packs.next", "prep.packs.no_next", "prep.packs.insufficient", "prep.packs.unlock_next", "prep.packs.method", "prep.packs.cost", "prep.packs.progress", "prep.packs.all_open_desc", "prep.packs.all_open",
	"prep.starter.title", "prep.starter.fixed_rule", "prep.starter.summary",
	"prep.deck.invalid", "prep.deck.valid", "prep.deck.summary", "prep.deck.reset", "prep.deck.current_count", "prep.deck.reserve_count", "prep.deck.moved_to_reserve", "prep.deck.add_failed", "prep.deck.added", "prep.deck.reset_done",
	"map.title", "map.title.progress", "map.floor_count", "map.node.completed",
	"map.status.title", "map.status.choose_node", "map.status.run_complete", "map.status.layer_complete", "map.status.name", "map.status.job", "map.status.realm", "map.status.hp", "map.status.draw", "map.status.stones", "map.status.cultivation", "map.status.deck_score", "map.status.bonus",
	"map.event.complete", "map.event.minor.title", "map.event.minor.body", "map.event.minor.prefix", "map.event.windfall.title", "map.event.windfall.body", "map.event.windfall.prefix", "map.event.windfall.complete",
	"map.event.trade.title", "map.event.trade.body", "map.event.trade.prefix", "map.event.trade.pay_stones", "map.event.trade.pay_hp", "map.event.trade.exchange", "map.event.trade.free", "map.event.trade.stones_insufficient", "map.event.trade.hp_insufficient", "map.event.trade.target_changed", "map.event.trade.complete",
	"map.treasure.title", "map.treasure.body", "map.treasure.prefix", "map.treasure.complete",
	"map.shop.title", "map.shop.body", "map.shop.intro", "map.shop.refresh", "map.shop.sell_reserve", "map.shop.choose_sell", "map.shop.leave", "map.shop.left", "map.shop.empty", "map.shop.prefix", "map.shop.buy", "map.shop.refresh_insufficient", "map.shop.refreshed", "map.shop.buy_insufficient", "map.shop.bought", "map.shop.sell_title", "map.shop.sell_body", "map.shop.back_buy", "map.shop.continue", "map.shop.no_sell_cards", "map.shop.sell_prefix", "map.shop.sell", "map.shop.sell_failed", "map.shop.sold", "map.shop.owned",
	"map.rest.title", "map.rest.body", "map.rest.action", "map.rest.restore", "map.rest.complete",
	"map.deck.open", "map.deck.title", "map.deck.save", "map.deck.close", "map.deck.current", "map.deck.reserve", "map.deck.unsaved_prompt", "map.deck.save_exit", "map.deck.discard_exit", "map.deck.summary", "map.deck.current_count", "map.deck.reserve_count", "map.deck.hint", "map.deck.instructions", "map.deck.save_failed", "map.deck.moved_to_reserve", "map.deck.added",
	"battle.number", "battle.pile.deck", "battle.pile.graveyard", "battle.pile.exile", "battle.action.attack", "battle.action.defend", "battle.action.end_turn", "battle.action.skip_response", "battle.action.return_menu", "battle.action.restart", "battle.action.continue", "battle.reward.title", "battle.reward.stones", "battle.equipment.choose_replace", "battle.equipment.replace", "battle.equipment.name", "battle.equipment.confirm", "battle.equipment.replace_action", "battle.debug.open", "battle.log",
	"battle.error.missing_request_id", "battle.error.missing_request_type", "battle.error.unknown_request_type", "battle.error.invalid_request_side", "battle.error.request_rejected",
	"settlement.return", "settlement.retry", "settlement.complete", "settlement.failed", "settlement.complete_desc", "settlement.failed_desc", "settlement.job_title", "settlement.layer", "settlement.nodes", "settlement.base", "settlement.multiplier", "settlement.awarded", "settlement.total"
]

static func language_definitions() -> Dictionary:
	return {
		"zh_cn": {
			"id": "zh_cn",
			"content_state": CONTENT_STATE_ACTIVE,
			"name": "简体中文",
			"native_name": "简体中文"
		},
		"en_us": {
			"id": "en_us",
			"content_state": CONTENT_STATE_ACTIVE,
			"name": "English",
			"native_name": "English"
		}
	}

static func language_ids() -> Array:
	return language_definitions().keys()

static func language_definition(language_id: String) -> Dictionary:
	var definitions: Dictionary = language_definitions()
	if definitions.has(language_id):
		return (definitions[language_id] as Dictionary).duplicate(true)
	return (definitions[DEFAULT_LANGUAGE_ID] as Dictionary).duplicate(true)

static func normalized_language_id(language_id: String) -> String:
	if language_definitions().has(language_id):
		return language_id
	return DEFAULT_LANGUAGE_ID

static func text_entries() -> Dictionary:
	var entries := {
		"app.title": _entry("太玄宗", "Taixuanzong"),
		"app.subtitle": _entry("卡牌战斗原型", "Card Battle Prototype"),
		"menu.start_game": _entry("开始游戏", "Start Game"),
		"menu.settings": _entry("设置", "Settings"),
		"menu.quit": _entry("离开游戏", "Quit"),
		"settings.tab_game": _entry("游戏", "Game"),
		"settings.tab_keys": _entry("按键", "Keys"),
		"settings.general": _entry("通用", "General"),
		"settings.audio": _entry("音频", "Audio"),
		"settings.display": _entry("显示", "Display"),
		"settings.language": _entry("语言", "Language"),
		"settings.master_volume": _entry("主音量  {percent}%", "Master Volume  {percent}%"),
		"settings.music_volume": _entry("音乐音量  {percent}%", "Music Volume  {percent}%"),
		"settings.sfx_volume": _entry("音效音量  {percent}%", "SFX Volume  {percent}%"),
		"settings.resolution": _entry("分辨率", "Resolution"),
		"settings.window_mode": _entry("窗口模式", "Window Mode"),
		"settings.windowed": _entry("窗口", "Windowed"),
		"settings.fullscreen": _entry("全屏", "Fullscreen"),
		"settings.borderless_fullscreen": _entry("无边框全屏", "Borderless Fullscreen"),
		"settings.vsync": _entry("垂直同步", "VSync"),
		"settings.controls": _entry("操作", "Controls"),
		"settings.confirm": _entry("确定", "Confirm"),
		"settings.cancel": _entry("取消", "Cancel"),
		"settings.default": _entry("默认", "Default"),
		"settings.rebind": _entry("改键", "Rebind"),
		"settings.reset_binding": _entry("默认", "Default"),
		"settings.waiting_key": _entry("按下新的按键", "Press a new key"),
		"settings.input_menu": _entry("菜单按键", "Menu Keys"),
		"settings.input_battle": _entry("战斗按键", "Battle Keys"),
		"settings.input_card_shortcut": _entry("手牌快捷键", "Hand Shortcuts"),
		"input.ui_confirm": _entry("确认", "Confirm"),
		"input.ui_cancel": _entry("取消 / 返回", "Cancel / Back"),
		"input.end_turn": _entry("结束回合", "End Turn"),
		"input.toggle_log": _entry("打开 / 关闭战斗日志", "Toggle Battle Log"),
		"input.open_deck": _entry("查看牌库", "View Deck"),
		"input.open_graveyard": _entry("查看墓地", "View Graveyard"),
		"input.open_exile": _entry("查看除外区", "View Exile"),
		"input.target_next": _entry("切换目标", "Next Target"),
		"input.debug_toggle": _entry("调试面板", "Debug Panel"),
		"input.hand_0": _entry("使用手牌 10", "Use Hand Card 10"),
		"input.hand_1": _entry("使用手牌 1", "Use Hand Card 1"),
		"input.hand_2": _entry("使用手牌 2", "Use Hand Card 2"),
		"input.hand_3": _entry("使用手牌 3", "Use Hand Card 3"),
		"input.hand_4": _entry("使用手牌 4", "Use Hand Card 4"),
		"input.hand_5": _entry("使用手牌 5", "Use Hand Card 5"),
		"input.hand_6": _entry("使用手牌 6", "Use Hand Card 6"),
		"input.hand_7": _entry("使用手牌 7", "Use Hand Card 7"),
		"input.hand_8": _entry("使用手牌 8", "Use Hand Card 8"),
		"input.hand_9": _entry("使用手牌 9", "Use Hand Card 9")
	}
	for text_id_variant in REQUIRED_SCREEN_TEXT_IDS:
		var text_id := str(text_id_variant)
		if not entries.has(text_id):
			entries[text_id] = _source_entry("")
	for card_id_variant in CardDefinitionDatabaseScript.active_card_ids():
		var card_id := str(card_id_variant)
		var card: Dictionary = CardDefinitionDatabaseScript.get_card(card_id)
		entries["card.%s.name" % card_id] = _source_entry(str(card.get("name", card_id)))
		entries["card.%s.description" % card_id] = _source_entry(str(card.get("description", "")))
	for job_variant in JobDatabaseScript.job_definitions():
		var job: Dictionary = job_variant
		var job_id := str(job.get("id", ""))
		entries["job.%s.name" % job_id] = _source_entry(str(job.get("name", job_id)))
		entries["job.%s.description" % job_id] = _source_entry(str(job.get("description", "")))
	for character_id_variant in CharacterDatabaseScript.active_character_ids():
		var character_id := str(character_id_variant)
		var character: Dictionary = CharacterDatabaseScript.character_template(character_id)
		entries["character.%s.name" % character_id] = _source_entry(str(character.get("name", character_id)))
	for status_variant in StatusDatabaseScript.active_definitions():
		var status: Dictionary = status_variant
		var status_id := str(status.get("status_id", ""))
		entries["status.%s.name" % status_id] = _source_entry(str(status.get("name", status_id)))
	for event_variant in EventDatabaseScript.active_event_definitions():
		var event_definition: Dictionary = event_variant
		var event_id := str(event_definition.get("event_id", ""))
		entries["event.%s.name" % event_id] = _source_entry(str(event_definition.get("name", event_id)))
	for node_type_variant in MapContentDatabaseScript.NODE_TITLES.keys():
		var node_type := str(node_type_variant)
		entries[MapContentDatabaseScript.node_title_key(node_type)] = _source_entry(MapContentDatabaseScript.node_title(node_type))
	return entries

static func has_text(text_id: String) -> bool:
	return text_entries().has(text_id)

static func text_entry(text_id: String) -> Dictionary:
	var entries: Dictionary = text_entries()
	if entries.has(text_id):
		return (entries[text_id] as Dictionary).duplicate(true)
	return {}

static func text(text_id: String, language_id: String, source_fallback := "") -> String:
	var entry: Dictionary = text_entry(text_id)
	if entry.is_empty():
		return source_fallback if source_fallback != "" else text_id
	var normalized_language := normalized_language_id(language_id)
	if entry.has(normalized_language):
		var localized := str(entry.get(normalized_language, ""))
		if localized != "":
			return localized
	var default_value := str(entry.get(DEFAULT_LANGUAGE_ID, ""))
	if default_value != "":
		return default_value
	return source_fallback if source_fallback != "" else text_id


static func _source_entry(source_fallback: String) -> Dictionary:
	return {
		"zh_cn": source_fallback,
		"en_us": source_fallback
	}

static func _entry(zh_cn: String, en_us: String) -> Dictionary:
	return {
		"zh_cn": zh_cn,
		"en_us": en_us
	}
