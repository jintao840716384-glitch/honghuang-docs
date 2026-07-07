extends RefCounted
class_name LocalizationDatabase

const DEFAULT_LANGUAGE_ID := "zh_cn"

static func language_definitions() -> Dictionary:
	return {
		"zh_cn": {
			"id": "zh_cn",
			"name": "简体中文",
			"native_name": "简体中文"
		},
		"en_us": {
			"id": "en_us",
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
	return {
		"app.title": _entry("太玄宗", "Taixuanzong"),
		"app.subtitle": _entry("卡牌战斗原型", "Card Battle Prototype"),
		"menu.start_game": _entry("开始游戏", "Start Game"),
		"menu.settings": _entry("设置", "Settings"),
		"menu.quit": _entry("离开游戏", "Quit"),
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
		"settings.rebind": _entry("改键", "Rebind"),
		"settings.reset_binding": _entry("默认", "Default"),
		"settings.waiting_key": _entry("按下新的按键", "Press a new key"),
		"settings.input_menu": _entry("菜单", "Menu"),
		"settings.input_battle": _entry("战斗", "Battle"),
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

static func has_text(text_id: String) -> bool:
	return text_entries().has(text_id)

static func text_entry(text_id: String) -> Dictionary:
	var entries: Dictionary = text_entries()
	if entries.has(text_id):
		return (entries[text_id] as Dictionary).duplicate(true)
	return {}

static func text(text_id: String, language_id: String) -> String:
	var entry: Dictionary = text_entry(text_id)
	if entry.is_empty():
		return text_id
	var normalized_language := normalized_language_id(language_id)
	if entry.has(normalized_language):
		return str(entry.get(normalized_language, text_id))
	return str(entry.get(DEFAULT_LANGUAGE_ID, text_id))

static func _entry(zh_cn: String, en_us: String) -> Dictionary:
	return {
		"zh_cn": zh_cn,
		"en_us": en_us
	}
