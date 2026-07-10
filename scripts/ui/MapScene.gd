extends Control

signal battle_node_selected(node_data: Dictionary)

const AudioManagerScript = preload("res://scripts/audio/AudioManager.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const EventDatabaseScript = preload("res://scripts/data/EventDatabase.gd")
const DeckBuildRulesScript = preload("res://scripts/run/DeckBuildRules.gd")
const UIStyleFactoryScript = preload("res://scripts/ui/UIStyleFactory.gd")
const DeckBuilderViewFactoryScript = preload("res://scripts/ui/DeckBuilderViewFactory.gd")
const MapModalChoiceFactoryScript = preload("res://scripts/ui/MapModalChoiceFactory.gd")
const RunViewModelScript = preload("res://scripts/run/RunViewModel.gd")
const CardButtonScene = preload("res://scenes/ui/CardButton.tscn")
const LocalizationServiceScript = preload("res://scripts/localization/LocalizationService.gd")

var run_state
var audio_manager: Node
var map_area: Control
var connection_layer: Control
var node_layer: Control
var title_label: Label
var status_label: Label
var deck_label: Label
var player_name_label: Label
var job_label: Label
var realm_label: Label
var hp_label: Label
var draw_label: Label
var spirit_stone_label: Label
var cultivation_label: Label
var deck_score_label: Label
var bonus_label: Label
var deck_view_button: Button
var deck_builder_overlay: ColorRect
var deck_builder_panel: PanelContainer
var builder_summary_label: Label
var builder_hint_label: Label
var builder_deck_title_label: Label
var builder_reserve_title_label: Label
var builder_deck_container: GridContainer
var builder_reserve_container: GridContainer
var builder_save_button: Button
var builder_close_button: Button
var builder_confirm_panel: PanelContainer
var builder_confirm_save_button: Button
var builder_confirm_discard_button: Button
var builder_deck_ids: Array = []
var builder_reserve_ids: Array = []
var builder_dirty := false
var map_modal_overlay: ColorRect
var map_modal_panel: PanelContainer
var map_modal_layout: VBoxContainer
var map_modal_title_label: Label
var map_modal_body_label: Label
var map_modal_options_container: VBoxContainer
var active_map_node_id := ""
var current_shop_stock: Array = []
var current_shop_refresh_cost := 8
var node_positions: Dictionary = {}

func _ready() -> void:
	_build_scene()
	audio_manager = AudioManagerScript.new()
	add_child(audio_manager)
	if run_state != null:
		call_deferred("_render_map")

func setup(state) -> void:
	run_state = RunViewModelScript.new(state)
	if is_inside_tree():
		call_deferred("_render_map")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_inside_tree():
		call_deferred("_render_map")

func _build_scene() -> void:
	var background := ColorRect.new()
	background.color = Color(0.035, 0.040, 0.045, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var header := HBoxContainer.new()
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 42.0
	header.offset_top = 24.0
	header.offset_right = -42.0
	header.offset_bottom = 72.0
	header.add_theme_constant_override("separation", 18)
	add_child(header)

	title_label = Label.new()
	title_label.text = _text("map.title", {}, "探索地图")
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	header.add_child(title_label)

	deck_label = Label.new()
	deck_label.custom_minimum_size = Vector2(160.0, 34.0)
	deck_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	deck_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	deck_label.add_theme_font_size_override("font_size", 16)
	deck_label.add_theme_color_override("font_color", Color(0.80, 0.84, 0.88, 1.0))
	header.add_child(deck_label)

	_build_status_panel()

	status_label = Label.new()
	status_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	status_label.offset_left = 330.0
	status_label.offset_top = -72.0
	status_label.offset_right = -42.0
	status_label.offset_bottom = -24.0
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color(0.78, 0.82, 0.86, 1.0))
	add_child(status_label)

	map_area = Control.new()
	map_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_area.offset_left = 330.0
	map_area.offset_top = 92.0
	map_area.offset_right = -100.0
	map_area.offset_bottom = -96.0
	map_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(map_area)

	connection_layer = Control.new()
	connection_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	connection_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_area.add_child(connection_layer)

	node_layer = Control.new()
	node_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	node_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_area.add_child(node_layer)

	_create_deck_builder()
	_create_map_modal()

func _build_status_panel() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	panel.offset_left = 36.0
	panel.offset_top = 92.0
	panel.offset_right = 292.0
	panel.offset_bottom = -96.0
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.050, 0.058, 0.062, 0.96), Color(0.38, 0.44, 0.48, 1.0), 8, 2))
	add_child(panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	panel.add_child(layout)

	var title := Label.new()
	title.text = _text("map.status.title", {}, "修行状态")
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	layout.add_child(title)

	player_name_label = _make_status_label()
	job_label = _make_status_label()
	realm_label = _make_status_label()
	hp_label = _make_status_label()
	draw_label = _make_status_label()
	spirit_stone_label = _make_status_label()
	cultivation_label = _make_status_label()
	deck_score_label = _make_status_label()
	bonus_label = _make_status_label(true)
	layout.add_child(player_name_label)
	layout.add_child(job_label)
	layout.add_child(realm_label)
	layout.add_child(hp_label)
	layout.add_child(draw_label)
	layout.add_child(spirit_stone_label)
	layout.add_child(cultivation_label)
	layout.add_child(deck_score_label)
	layout.add_child(bonus_label)

	deck_view_button = Button.new()
	deck_view_button.text = _text("map.deck.open", {}, "调整卡组")
	deck_view_button.custom_minimum_size = Vector2(0.0, 38.0)
	deck_view_button.focus_mode = Control.FOCUS_NONE
	deck_view_button.pressed.connect(_on_deck_builder_pressed)
	_style_button(deck_view_button, Color(0.10, 0.12, 0.12, 1.0), Color(0.62, 0.70, 0.58, 1.0))
	layout.add_child(deck_view_button)

func _render_map() -> void:
	if run_state == null or map_area == null:
		return
	if map_area.size.x <= 1.0 or map_area.size.y <= 1.0:
		call_deferred("_render_map")
		return

	_clear_children(connection_layer)
	_clear_children(node_layer)
	node_positions.clear()

	var max_floor: int = _max_floor()
	title_label.text = _text("map.title.progress", {"current": run_state.current_story_layer_number(), "total": run_state.main_story_layer_count(), "job": run_state.job_name, "realm": run_state.realm_name()}, "探索地图  /  第 {current} / {total} 层  /  {job}  /  {realm}")
	deck_label.text = _text("map.floor_count", {"count": max_floor + 1}, "节点排数 {count}")
	_refresh_status_panel()
	status_label.text = _text("map.status.choose_node", {}, "选择一个发亮节点继续探索。")
	if str(run_state.status_message) != "":
		status_label.text = str(run_state.status_message)
	if run_state.campaign_complete:
		status_label.text = _text("map.status.run_complete", {}, "本轮探索完成")
	elif run_state.is_complete():
		status_label.text = _text("map.status.layer_complete", {}, "本层探索完成")

	var lane_spacing: float = min(240.0, map_area.size.x / 5.4)
	for node in run_state.map_nodes:
		var floor := int(node.get("floor", 0))
		var lane := float(node.get("lane", 0.0))
		var progress: float = 0.0 if max_floor <= 0 else float(floor) / float(max_floor)
		var x: float = map_area.size.x * 0.5 + lane * lane_spacing
		var y: float = lerpf(map_area.size.y - 70.0, 60.0, progress)
		node_positions[str(node.get("id", ""))] = Vector2(x, y)

	_draw_connections()
	_create_node_buttons()

func _draw_connections() -> void:
	for node in run_state.map_nodes:
		var from_id := str(node.get("id", ""))
		var from_position: Vector2 = node_positions.get(from_id, Vector2.ZERO)
		for next_id_variant in node.get("next", []):
			var next_id := str(next_id_variant)
			if not node_positions.has(next_id):
				continue
			var line := Line2D.new()
			line.width = 4.0
			line.default_color = _connection_color(from_id, next_id)
			line.points = PackedVector2Array([from_position, node_positions[next_id]])
			connection_layer.add_child(line)

func _create_node_buttons() -> void:
	var available_ids: Dictionary = run_state.available_node_ids()
	for node in run_state.map_nodes:
		var id := str(node.get("id", ""))
		var completed: bool = run_state.is_node_completed(id)
		var available: bool = available_ids.has(id)
		var button := Button.new()
		button.custom_minimum_size = Vector2(78.0, 58.0)
		button.size = button.custom_minimum_size
		var position: Vector2 = node_positions.get(id, Vector2.ZERO)
		button.position = Vector2(position.x - button.size.x * 0.5, position.y - button.size.y * 0.5)
		button.text = _text("map.node.completed", {}, "已胜") if completed else str(node.get("title", _text("map.node.normal", {}, "战斗")))
		button.disabled = not available
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 15)
		_style_node_button(button, str(node.get("type", "normal")), available, completed)
		if available:
			button.pressed.connect(_on_node_pressed.bind(node))
		node_layer.add_child(button)

func _on_node_pressed(node: Dictionary) -> void:
	if run_state == null:
		return
	var node_id: String = str(node.get("id", ""))
	if not run_state.is_node_available(node_id):
		return
	_play_audio("ui_confirm")
	match str(node.get("type", "normal")):
		"event":
			_open_event_node(node)
		"treasure":
			_open_treasure_node(node)
		"shop":
			_open_shop_node(node)
		"rest":
			_open_rest_node(node)
		_:
			battle_node_selected.emit(node.duplicate(true))

func _connection_color(from_id: String, next_id: String) -> Color:
	if run_state.is_node_completed(from_id):
		return Color(0.78, 0.64, 0.34, 0.82)
	if run_state.is_node_available(next_id):
		return Color(0.46, 0.62, 0.86, 0.70)
	return Color(0.22, 0.25, 0.30, 0.62)

func _style_node_button(button: Button, node_type: String, available: bool, completed: bool) -> void:
	var bg := Color(0.09, 0.105, 0.12, 0.96)
	var border := Color(0.42, 0.48, 0.56, 1.0)
	if node_type == "elite":
		bg = Color(0.15, 0.10, 0.17, 0.96)
		border = Color(0.78, 0.45, 0.86, 1.0)
	elif node_type == "boss":
		bg = Color(0.18, 0.08, 0.06, 0.96)
		border = Color(0.92, 0.55, 0.30, 1.0)
	elif node_type == "event":
		bg = Color(0.11, 0.13, 0.09, 0.96)
		border = Color(0.74, 0.78, 0.42, 1.0)
	elif node_type == "treasure":
		bg = Color(0.15, 0.12, 0.07, 0.96)
		border = Color(0.92, 0.74, 0.36, 1.0)
	elif node_type == "shop":
		bg = Color(0.09, 0.12, 0.13, 0.96)
		border = Color(0.42, 0.80, 0.78, 1.0)
	elif node_type == "rest":
		bg = Color(0.08, 0.13, 0.10, 0.96)
		border = Color(0.48, 0.78, 0.52, 1.0)
	elif available:
		bg = Color(0.08, 0.13, 0.16, 0.96)
		border = Color(0.46, 0.72, 0.92, 1.0)
	if completed:
		bg = Color(0.12, 0.12, 0.09, 0.96)
		border = Color(0.76, 0.62, 0.32, 1.0)
	button.add_theme_stylebox_override("normal", _panel_style(bg, border, 8, 2))
	button.add_theme_stylebox_override("hover", _panel_style(bg.lightened(0.10), border.lightened(0.16), 8, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(bg.darkened(0.05), border.lightened(0.22), 8, 2))
	button.add_theme_stylebox_override("disabled", _panel_style(bg.darkened(0.25), border.darkened(0.35), 8, 1))
	button.add_theme_color_override("font_color", Color(0.94, 0.92, 0.86, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.54, 0.57, 0.60, 1.0))

func _max_floor() -> int:
	var result := 0
	for node in run_state.map_nodes:
		result = max(result, int(node.get("floor", 0)))
	return result

func _play_audio(event_name: String) -> void:
	if audio_manager != null and audio_manager.has_method("play_event"):
		audio_manager.call("play_event", event_name)

func _refresh_status_panel() -> void:
	if run_state == null:
		return
	player_name_label.text = _text("map.status.name", {"name": run_state.player_name}, "名称：{name}")
	job_label.text = _text("map.status.job", {"job": run_state.job_name}, "角色：{job}")
	realm_label.text = _text("map.status.realm", {"realm": run_state.realm_name()}, "称号：{realm}")
	hp_label.text = _text("map.status.hp", {"current": run_state.current_hp, "max": run_state.max_hp}, "生命：{current} / {max}")
	draw_label.text = _text("map.status.draw", {"draw": run_state.draw_per_turn}, "基础抽牌：{draw}")
	spirit_stone_label.text = _text("map.status.stones", {"stones": run_state.spirit_stones}, "灵石：{stones}")
	cultivation_label.text = _text("map.status.cultivation", {"value": run_state.run_cultivation_base}, "本轮修为：{value}")
	deck_score_label.text = _text("map.status.deck_score", {"score": run_state.current_deck_score(), "limit": run_state.deck_score_limit}, "卡组总分：{score} / {limit}")
	bonus_label.text = _text("map.status.bonus", {"bonus": run_state.realm_bonus_summary()}, "加成：{bonus}")

func _make_status_label(multiline := false) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if multiline else TextServer.AUTOWRAP_OFF
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(0.84, 0.88, 0.86, 1.0))
	return label

func _style_button(button: Button, bg: Color, border: Color) -> void:
	UIStyleFactoryScript.apply_button_style(button, bg, border, 6, 1, 2, 2, Vector4(10, 10, 8, 8), 0, 0.12, 0.06, 0.18)

func _create_map_modal() -> void:
	map_modal_overlay = ColorRect.new()
	map_modal_overlay.name = "MapModalOverlay"
	map_modal_overlay.color = Color(0.0, 0.0, 0.0, 0.56)
	map_modal_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	map_modal_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_modal_overlay.visible = false
	map_modal_overlay.z_index = 100
	add_child(map_modal_overlay)

	map_modal_panel = PanelContainer.new()
	map_modal_panel.name = "MapModalPanel"
	map_modal_panel.anchor_left = 0.5
	map_modal_panel.anchor_top = 0.5
	map_modal_panel.anchor_right = 0.5
	map_modal_panel.anchor_bottom = 0.5
	map_modal_panel.offset_left = -300.0
	map_modal_panel.offset_top = -250.0
	map_modal_panel.offset_right = 300.0
	map_modal_panel.offset_bottom = 250.0
	map_modal_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	map_modal_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.052, 0.056, 0.99), Color(0.54, 0.60, 0.62, 1.0), 8, 2))
	map_modal_overlay.add_child(map_modal_panel)

	map_modal_layout = VBoxContainer.new()
	map_modal_layout.alignment = BoxContainer.ALIGNMENT_CENTER
	map_modal_layout.add_theme_constant_override("separation", 12)
	map_modal_panel.add_child(map_modal_layout)

	map_modal_title_label = Label.new()
	map_modal_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_modal_title_label.add_theme_font_size_override("font_size", 24)
	map_modal_title_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	map_modal_layout.add_child(map_modal_title_label)

	map_modal_body_label = Label.new()
	map_modal_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_modal_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_modal_body_label.add_theme_font_size_override("font_size", 15)
	map_modal_body_label.add_theme_color_override("font_color", Color(0.86, 0.90, 0.88, 1.0))
	map_modal_layout.add_child(map_modal_body_label)

	map_modal_options_container = VBoxContainer.new()
	map_modal_options_container.alignment = BoxContainer.ALIGNMENT_CENTER
	map_modal_options_container.add_theme_constant_override("separation", 10)
	map_modal_layout.add_child(map_modal_options_container)

func _open_event_node(node: Dictionary) -> void:
	active_map_node_id = str(node.get("id", ""))
	_open_event_by_id(run_state.roll_event_id())

func _open_event_by_id(event_id: String) -> bool:
	if event_id == EventDatabaseScript.EVENT_ID_WINDFALL:
		_open_windfall_event()
		return true
	if event_id == EventDatabaseScript.EVENT_ID_TRADE:
		_open_trade_event()
		return true
	if event_id == EventDatabaseScript.EVENT_ID_MINOR:
		_open_minor_event()
		return true
	return false

func _open_minor_event() -> void:
	_open_map_modal(_text("map.event.minor.title", {}, "山间机缘"), _text("map.event.minor.body", {}, "不经战斗的小收获。"), true, Vector2(600.0, 500.0))
	var offer: Dictionary = run_state.minor_event_offer()
	if str(offer.get("kind", "")) == "stone":
		var amount: int = int(offer.get("amount", 0))
		_add_modal_reward_choice(_text("common.spirit_stones", {}, "灵石"), _text("common.spirit_stones", {}, "灵石"), "", _text("map.event.minor.prefix", {}, "机缘"), func() -> void:
			var result: Dictionary = run_state.apply_event_stone_reward(amount, "事件：获得 %d 灵石。")
			_complete_map_node(str(result.get("message", _text("map.event.complete", {}, "事件完成。"))))
		, false, _text("common.accept", {}, "收下"), str(amount))
	else:
		var card_id: String = str(offer.get("card_id", ""))
		_add_modal_card_choice(map_modal_options_container, card_id, _text("map.event.minor.prefix", {}, "机缘"), func(selected_card_id: String) -> void:
			var result: Dictionary = run_state.apply_event_card_reward(selected_card_id, "事件")
			_complete_map_node(str(result.get("message", _text("map.event.complete", {}, "事件完成。"))))
		, false, _text("common.accept", {}, "收下"))

func _open_windfall_event() -> void:
	_open_map_modal(_text("map.event.windfall.title", {}, "罕见机缘"), _text("map.event.windfall.body", {}, "极低概率出现的高收益事件。"), true, Vector2(600.0, 500.0))
	var offer: Dictionary = run_state.windfall_event_offer()
	if str(offer.get("kind", "")) == "stone":
		var amount: int = int(offer.get("amount", 0))
		_add_modal_reward_choice(_text("common.spirit_stones", {}, "灵石"), _text("common.spirit_stones", {}, "灵石"), "", _text("map.event.windfall.prefix", {}, "奇遇"), func() -> void:
			var result: Dictionary = run_state.apply_event_stone_reward(amount, "罕见机缘：获得 %d 灵石。")
			_complete_map_node(str(result.get("message", _text("map.event.windfall.complete", {}, "罕见机缘完成。"))))
		, false, _text("common.accept", {}, "收下"), str(amount))
		return
	var card_id: String = str(offer.get("card_id", ""))
	_add_modal_card_choice(map_modal_options_container, card_id, _text("map.event.windfall.prefix", {}, "奇遇"), func(selected_card_id: String) -> void:
		var result: Dictionary = run_state.apply_event_card_reward(selected_card_id, "罕见机缘")
		_complete_map_node(str(result.get("message", _text("map.event.windfall.complete", {}, "罕见机缘完成。"))))
	, false, _text("common.accept", {}, "收下"))

func _open_trade_event() -> void:
	_open_map_modal(_text("map.event.trade.title", {}, "试炼交易"), _text("map.event.trade.body", {}, "可以付出代价换取更高收益；不付代价也能拿到保底。"), true, Vector2(820.0, 560.0))
	var grid := _make_modal_card_grid(3)
	var offer: Dictionary = run_state.trade_event_offer()
	var stone_option: Dictionary = (offer.get("stone_option", {}) as Dictionary)
	var stone_cost: int = int(stone_option.get("cost", 0))
	var stone_card: String = str(stone_option.get("card_id", ""))
	_add_modal_card_choice(grid, stone_card, _text("map.event.trade.prefix", {}, "交易"), func(selected_card_id: String) -> void:
		var result: Dictionary = run_state.apply_trade_stone_reward(stone_cost, selected_card_id)
		if not bool(result.get("success", false)):
			_open_trade_event()
			map_modal_body_label.text = str(result.get("message", _text("map.event.trade.stones_insufficient", {}, "灵石不足。可以选择其他代价，或领取保底。")))
			return
		_complete_map_node(str(result.get("message", _text("map.event.trade.complete", {}, "试炼交易完成。"))))
	, run_state.spirit_stones < stone_cost, _text("map.event.trade.pay_stones", {"cost": stone_cost}, "支付 {cost} 灵石"))

	var hp_option: Dictionary = (offer.get("hp_option", {}) as Dictionary)
	var hp_cost: int = int(hp_option.get("cost", 0))
	var hp_card: String = str(hp_option.get("card_id", ""))
	_add_modal_card_choice(grid, hp_card, _text("map.event.trade.prefix", {}, "交易"), func(selected_card_id: String) -> void:
		var result: Dictionary = run_state.apply_trade_hp_reward(hp_cost, selected_card_id)
		if not bool(result.get("success", false)):
			_open_trade_event()
			map_modal_body_label.text = str(result.get("message", _text("map.event.trade.hp_insufficient", {}, "生命不足，无法支付该代价。")))
			return
		_complete_map_node(str(result.get("message", _text("map.event.trade.complete", {}, "试炼交易完成。"))))
	, hp_cost <= 0, _text("map.event.trade.pay_hp", {"cost": hp_cost}, "支付 {cost} 生命"))

	var exchange_option: Dictionary = (offer.get("exchange_option", {}) as Dictionary)
	if not exchange_option.is_empty():
		var reserve_index: int = int(exchange_option.get("reserve_index", -1))
		var offered_id: String = str(exchange_option.get("offered_id", ""))
		var exchange_card: String = str(exchange_option.get("card_id", ""))
		_add_modal_card_choice(grid, exchange_card, _text("map.event.trade.prefix", {}, "交易"), func(selected_card_id: String) -> void:
			var result: Dictionary = run_state.apply_trade_reserve_reward(reserve_index, offered_id, selected_card_id)
			if not bool(result.get("success", false)):
				_open_trade_event()
				map_modal_body_label.text = str(result.get("message", _text("map.event.trade.target_changed", {}, "交易目标已变化，请重新选择。")))
				return
			_complete_map_node(str(result.get("message", _text("map.event.trade.complete", {}, "试炼交易完成。"))))
		, false, _text("map.event.trade.exchange", {"card": offered_id}, "交出 {card}"))

	var fallback_option: Dictionary = (offer.get("fallback_option", {}) as Dictionary)
	var fallback_amount: int = int(fallback_option.get("amount", 0))
	_add_modal_reward_choice_to(grid, _text("common.spirit_stones", {}, "灵石"), _text("common.spirit_stones", {}, "灵石"), "", _text("map.event.trade.prefix", {}, "交易"), func() -> void:
		var result: Dictionary = run_state.apply_event_stone_reward(fallback_amount, "事件：领取保底 %d 灵石。")
		_complete_map_node(str(result.get("message", _text("map.event.complete", {}, "事件完成。"))))
	, false, _text("map.event.trade.free", {}, "无代价取得"), str(fallback_amount))

func _open_treasure_node(node: Dictionary) -> void:
	active_map_node_id = str(node.get("id", ""))
	_open_map_modal(_text("map.treasure.title", {}, "遗落宝箱"), _text("map.treasure.body", {}, "选择一张卡带走；不想编入当前卡组时，可先进入备牌区，之后在坊市出售。"), true, Vector2(820.0, 520.0))
	var grid := _make_modal_card_grid(3)
	for card_id_variant in run_state.treasure_card_rewards():
		var card_id := str(card_id_variant)
		_add_modal_card_choice(grid, card_id, _text("map.treasure.prefix", {}, "宝箱"), func(selected_card_id: String) -> void:
			var result: Dictionary = run_state.apply_treasure_card_reward(selected_card_id)
			_complete_map_node(str(result.get("message", _text("map.treasure.complete", {}, "宝箱完成。"))))
		)

func _open_shop_node(node: Dictionary) -> void:
	active_map_node_id = str(node.get("id", ""))
	current_shop_refresh_cost = run_state.shop_start_refresh_cost()
	current_shop_stock = run_state.generate_shop_stock()
	_refresh_shop_modal(_text("map.shop.intro", {}, "坊市出售通用卡和当前角色卡池。"))

func _refresh_shop_modal(message: String) -> void:
	_open_map_modal(_text("map.shop.title", {}, "坊市"), _text("map.shop.body", {"message": message, "stones": run_state.spirit_stones}, "{message}\n当前灵石：{stones}"), false, Vector2(860.0, 760.0))
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 10)
	map_modal_options_container.add_child(action_row)
	action_row.add_child(_make_modal_button(_text("map.shop.refresh", {"cost": current_shop_refresh_cost}, "刷新 {cost} 灵石"), func() -> void:
		_refresh_shop_stock()
	, run_state.spirit_stones < current_shop_refresh_cost))
	action_row.add_child(_make_modal_button(_text("map.shop.sell_reserve", {}, "出售备牌"), func() -> void:
		_open_shop_sell_view(_text("map.shop.choose_sell", {}, "选择备牌区中的卡出售。"))
	))
	action_row.add_child(_make_modal_button(_text("map.shop.leave", {}, "离开坊市"), func() -> void:
		_complete_map_node(_text("map.shop.left", {}, "离开坊市。"))
	))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	map_modal_options_container.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)

	if current_shop_stock.is_empty():
		var empty_label := Label.new()
		empty_label.text = _text("map.shop.empty", {}, "货架已空。")
		empty_label.add_theme_color_override("font_color", Color(0.86, 0.90, 0.88, 1.0))
		grid.add_child(empty_label)
		return

	for i in range(current_shop_stock.size()):
		var item_index := i
		var item: Dictionary = current_shop_stock[i]
		var card_id: String = str(item.get("card_id", ""))
		var price: int = int(item.get("price", 0))
		var card: Dictionary = CardDatabaseScript.get_card(card_id)
		if card.is_empty():
			continue
		var slot := VBoxContainer.new()
		slot.add_theme_constant_override("separation", 6)
		grid.add_child(slot)
		var card_button: CardButton = CardButtonScene.instantiate()
		card_button.build_cost_display_enabled = true
		card_button.ownership_text = _card_ownership_text(card_id)
		card_button.hover_details_enabled = false
		card_button.hover_motion_enabled = false
		card_button.setup(card, _text("map.shop.prefix", {}, "坊市"))
		card_button.disabled = run_state.spirit_stones < price
		card_button.card_pressed.connect(_on_shop_card_pressed.bind(item_index))
		slot.add_child(card_button)
		slot.add_child(_make_modal_button(_text("map.shop.buy", {"price": price}, "购买 {price} 灵石"), func() -> void:
			_buy_shop_item(item_index)
		, run_state.spirit_stones < price))

func _refresh_shop_stock() -> void:
	var result: Dictionary = run_state.refresh_shop_stock(current_shop_refresh_cost)
	if not bool(result.get("success", false)):
		_refresh_shop_modal(str(result.get("message", _text("map.shop.refresh_insufficient", {}, "灵石不足，无法刷新。"))))
		return
	current_shop_refresh_cost = int(result.get("next_refresh_cost", current_shop_refresh_cost))
	current_shop_stock = (result.get("stock", []) as Array).duplicate(true)
	_refresh_shop_modal(str(result.get("message", _text("map.shop.refreshed", {}, "货架已刷新。"))))

func _on_shop_card_pressed(_uid: String, index: int) -> void:
	_buy_shop_item(index)

func _buy_shop_item(index: int) -> void:
	if index < 0 or index >= current_shop_stock.size():
		return
	var item: Dictionary = current_shop_stock[index]
	var card_id: String = str(item.get("card_id", ""))
	var price: int = int(item.get("price", 0))
	var result: Dictionary = run_state.buy_shop_card(card_id, price)
	if not bool(result.get("success", false)):
		_refresh_shop_modal(str(result.get("message", _text("map.shop.buy_insufficient", {}, "灵石不足，无法购买。"))))
		return
	current_shop_stock.remove_at(index)
	_refresh_shop_modal(str(result.get("message", _text("map.shop.bought", {}, "购买完成。"))))

func _open_shop_sell_view(message: String) -> void:
	_open_map_modal(_text("map.shop.sell_title", {}, "坊市 - 出售"), _text("map.shop.sell_body", {"message": message, "stones": run_state.spirit_stones}, "{message}\n当前灵石：{stones}\n当前只出售备牌区，不影响当前战斗卡组。"), false, Vector2(860.0, 760.0))
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 10)
	map_modal_options_container.add_child(action_row)
	action_row.add_child(_make_modal_button(_text("map.shop.back_buy", {}, "返回购买"), func() -> void:
		_refresh_shop_modal(_text("map.shop.continue", {}, "继续选购。"))
	))
	action_row.add_child(_make_modal_button(_text("map.shop.leave", {}, "离开坊市"), func() -> void:
		_complete_map_node(_text("map.shop.left", {}, "离开坊市。"))
	))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	map_modal_options_container.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)

	if run_state.reserve_ids.is_empty():
		var empty_label := Label.new()
		empty_label.text = _text("map.shop.no_sell_cards", {}, "备牌区没有可出售的卡。")
		empty_label.add_theme_color_override("font_color", Color(0.86, 0.90, 0.88, 1.0))
		grid.add_child(empty_label)
		return

	for i in range(run_state.reserve_ids.size()):
		var reserve_index := i
		var card_id: String = str(run_state.reserve_ids[i])
		var price: int = run_state.shop_sell_price(card_id)
		var card: Dictionary = CardDatabaseScript.get_card(card_id)
		if card.is_empty():
			continue
		var slot := VBoxContainer.new()
		slot.add_theme_constant_override("separation", 6)
		grid.add_child(slot)
		var card_button: CardButton = CardButtonScene.instantiate()
		card_button.build_cost_display_enabled = true
		card_button.ownership_text = _card_ownership_text(card_id)
		card_button.hover_details_enabled = false
		card_button.hover_motion_enabled = false
		card_button.setup(card, _text("map.shop.sell_prefix", {}, "出售"))
		card_button.card_pressed.connect(_on_sell_card_pressed.bind(reserve_index))
		slot.add_child(card_button)
		slot.add_child(_make_modal_button(_text("map.shop.sell", {"price": price}, "出售 {price} 灵石"), func() -> void:
			_sell_reserve_card(reserve_index)
		))

func _on_sell_card_pressed(_uid: String, index: int) -> void:
	_sell_reserve_card(index)

func _sell_reserve_card(index: int) -> void:
	var result: Dictionary = run_state.sell_reserve_card(index)
	if not bool(result.get("success", false)):
		_open_shop_sell_view(str(result.get("message", _text("map.shop.sell_failed", {}, "无法出售。"))))
		return
	_open_shop_sell_view(str(result.get("message", _text("map.shop.sold", {}, "出售完成。"))))

func _card_ownership_text(card_id: String) -> String:
	return _text("map.shop.owned", {"deck": _card_count_in(run_state.deck_ids, card_id), "reserve": _card_count_in(run_state.reserve_ids, card_id)}, "已有：卡组 {deck}  ·  备牌 {reserve}")

func _card_count_in(card_ids: Array, card_id: String) -> int:
	var result := 0
	for existing_id_variant in card_ids:
		if str(existing_id_variant) == card_id:
			result += 1
	return result

func _open_rest_node(node: Dictionary) -> void:
	active_map_node_id = str(node.get("id", ""))
	_open_map_modal(_text("map.rest.title", {}, "休息"), _text("map.rest.body", {}, "调息恢复全部生命。"), true, Vector2(520.0, 500.0))
	_add_modal_reward_choice(_text("map.rest.action", {}, "调息"), _text("map.rest.title", {}, "休息"), _text("map.rest.restore", {}, "恢复全部生命。"), _text("map.rest.title", {}, "休息"), func() -> void:
		var result: Dictionary = run_state.apply_rest()
		_complete_map_node(str(result.get("message", _text("map.rest.complete", {}, "休息：生命已恢复。"))))
	, false, _text("map.rest.title", {}, "休息"))

func _open_map_modal(title: String, body: String, caption_below := false, panel_size := Vector2(600.0, 500.0)) -> void:
	map_modal_overlay.visible = true
	_set_map_modal_size(panel_size)
	map_modal_layout.alignment = BoxContainer.ALIGNMENT_CENTER if caption_below else BoxContainer.ALIGNMENT_BEGIN
	map_modal_options_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER if caption_below else Control.SIZE_EXPAND_FILL
	map_modal_layout.move_child(map_modal_title_label, 0)
	map_modal_layout.move_child(map_modal_body_label, 1)
	map_modal_layout.move_child(map_modal_options_container, 2)
	map_modal_title_label.text = title
	map_modal_body_label.text = body
	_clear_children(map_modal_options_container)

func _set_map_modal_size(panel_size: Vector2) -> void:
	var width: float = max(360.0, panel_size.x)
	var height: float = max(320.0, panel_size.y)
	map_modal_panel.offset_left = -width * 0.5
	map_modal_panel.offset_right = width * 0.5
	map_modal_panel.offset_top = -height * 0.5
	map_modal_panel.offset_bottom = height * 0.5

func _make_modal_card_grid(columns := 3) -> GridContainer:
	return MapModalChoiceFactoryScript.create_card_grid(map_modal_options_container, columns)

func _add_modal_card_choice(parent: Control, card_id: String, prefix: String, callback: Callable, disabled := false, action_text := "") -> void:
	MapModalChoiceFactoryScript.add_card_choice(parent, card_id, prefix, callback, disabled, _text("common.choose_card", {}, "选择此卡") if action_text == "" else action_text)

func _add_modal_card_data_choice(parent: Control, card: Dictionary, prefix: String, callback: Callable, disabled := false, action_text := "", show_score := true) -> void:
	MapModalChoiceFactoryScript.add_card_data_choice(parent, card, prefix, callback, disabled, _text("common.choose_card", {}, "选择此卡") if action_text == "" else action_text, show_score)

func _add_modal_reward_choice(title: String, category: String, description: String, prefix: String, callback: Callable, disabled := false, action_text := "", center_text := "") -> void:
	_add_modal_reward_choice_to(map_modal_options_container, title, category, description, prefix, callback, disabled, _text("common.accept", {}, "收下") if action_text == "" else action_text, center_text)

func _add_modal_reward_choice_to(parent: Control, title: String, category: String, description: String, prefix: String, callback: Callable, disabled := false, action_text := "", center_text := "") -> void:
	MapModalChoiceFactoryScript.add_reward_choice(parent, title, category, description, prefix, callback, disabled, _text("common.accept", {}, "收下") if action_text == "" else action_text, center_text)

func _add_modal_button(label_text: String, callback: Callable, disabled := false) -> void:
	map_modal_options_container.add_child(_make_modal_button(label_text, callback, disabled))

func _make_modal_button(label_text: String, callback: Callable, disabled := false) -> Button:
	return MapModalChoiceFactoryScript.make_modal_button(label_text, callback, disabled)

func _complete_map_node(message: String) -> void:
	if active_map_node_id != "":
		run_state.complete_node(active_map_node_id)
	run_state.set_status_message(message)
	active_map_node_id = ""
	map_modal_overlay.visible = false
	_render_map()

func _create_deck_builder() -> void:
	deck_builder_overlay = ColorRect.new()
	deck_builder_overlay.name = "DeckBuilderOverlay"
	deck_builder_overlay.color = Color(0.0, 0.0, 0.0, 0.64)
	deck_builder_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	deck_builder_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	deck_builder_overlay.visible = false
	deck_builder_overlay.z_index = 110
	add_child(deck_builder_overlay)

	deck_builder_panel = PanelContainer.new()
	deck_builder_panel.name = "DeckBuilderPanel"
	deck_builder_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	deck_builder_panel.offset_left = 36.0
	deck_builder_panel.offset_top = 36.0
	deck_builder_panel.offset_right = -36.0
	deck_builder_panel.offset_bottom = -36.0
	deck_builder_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	deck_builder_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.050, 0.055, 0.98), Color(0.52, 0.58, 0.64, 1.0), 8, 2))
	deck_builder_overlay.add_child(deck_builder_panel)

	var root_layout := VBoxContainer.new()
	root_layout.add_theme_constant_override("separation", 12)
	deck_builder_panel.add_child(root_layout)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	root_layout.add_child(header)

	var title := Label.new()
	title.text = _text("map.deck.title", {}, "卡组调整")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	header.add_child(title)

	builder_summary_label = Label.new()
	builder_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	builder_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	builder_summary_label.add_theme_font_size_override("font_size", 16)
	builder_summary_label.add_theme_color_override("font_color", Color(0.86, 0.90, 0.88, 1.0))
	header.add_child(builder_summary_label)

	builder_save_button = Button.new()
	builder_save_button.text = _text("map.deck.save", {}, "保存卡组")
	builder_save_button.focus_mode = Control.FOCUS_NONE
	builder_save_button.pressed.connect(_on_save_builder_pressed)
	_style_button(builder_save_button, Color(0.14, 0.20, 0.12, 0.96), Color(0.52, 0.86, 0.48, 1.0))
	header.add_child(builder_save_button)

	builder_close_button = Button.new()
	builder_close_button.text = _text("map.deck.close", {}, "退出调整")
	builder_close_button.focus_mode = Control.FOCUS_NONE
	builder_close_button.pressed.connect(_on_cancel_builder_pressed)
	_style_button(builder_close_button, Color(0.10, 0.10, 0.11, 0.96), Color(0.54, 0.56, 0.62, 1.0))
	header.add_child(builder_close_button)

	builder_hint_label = Label.new()
	builder_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	builder_hint_label.add_theme_font_size_override("font_size", 14)
	builder_hint_label.add_theme_color_override("font_color", Color(0.84, 0.88, 0.82, 1.0))
	root_layout.add_child(builder_hint_label)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 14)
	root_layout.add_child(columns)

	var deck_column := _create_builder_column(_text("map.deck.current", {}, "当前卡组"))
	builder_deck_title_label = deck_column["title"] as Label
	builder_deck_container = deck_column["container"] as GridContainer
	columns.add_child(deck_column["panel"] as Control)

	var reserve_column := _create_builder_column(_text("map.deck.reserve", {}, "备牌区"))
	builder_reserve_title_label = reserve_column["title"] as Label
	builder_reserve_container = reserve_column["container"] as GridContainer
	columns.add_child(reserve_column["panel"] as Control)

	_create_builder_confirm_panel()

func _create_builder_confirm_panel() -> void:
	builder_confirm_panel = PanelContainer.new()
	builder_confirm_panel.visible = false
	builder_confirm_panel.z_index = 130
	builder_confirm_panel.anchor_left = 0.5
	builder_confirm_panel.anchor_top = 0.5
	builder_confirm_panel.anchor_right = 0.5
	builder_confirm_panel.anchor_bottom = 0.5
	builder_confirm_panel.offset_left = -260.0
	builder_confirm_panel.offset_top = -86.0
	builder_confirm_panel.offset_right = 260.0
	builder_confirm_panel.offset_bottom = 86.0
	builder_confirm_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	builder_confirm_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.060, 0.066, 0.99), Color(0.86, 0.76, 0.44, 1.0), 8, 2))
	deck_builder_overlay.add_child(builder_confirm_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	builder_confirm_panel.add_child(layout)

	var label := Label.new()
	label.text = _text("map.deck.unsaved_prompt", {}, "当前卡组调整尚未保存，是否保存后退出？")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.78, 1.0))
	layout.add_child(label)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 12)
	layout.add_child(buttons)

	builder_confirm_save_button = Button.new()
	builder_confirm_save_button.text = _text("map.deck.save_exit", {}, "保存并退出")
	builder_confirm_save_button.focus_mode = Control.FOCUS_NONE
	builder_confirm_save_button.pressed.connect(_on_confirm_save_builder)
	_style_button(builder_confirm_save_button, Color(0.14, 0.20, 0.12, 0.96), Color(0.52, 0.86, 0.48, 1.0))
	buttons.add_child(builder_confirm_save_button)

	builder_confirm_discard_button = Button.new()
	builder_confirm_discard_button.text = _text("map.deck.discard_exit", {}, "放弃退出")
	builder_confirm_discard_button.focus_mode = Control.FOCUS_NONE
	builder_confirm_discard_button.pressed.connect(_discard_builder_and_close)
	_style_button(builder_confirm_discard_button, Color(0.18, 0.10, 0.10, 0.96), Color(0.82, 0.46, 0.42, 1.0))
	buttons.add_child(builder_confirm_discard_button)

func _create_builder_column(column_title: String) -> Dictionary:
	return DeckBuilderViewFactoryScript.create_column(
		column_title,
		"",
		_panel_style(Color(0.060, 0.066, 0.072, 0.95), Color(0.30, 0.35, 0.40, 1.0), 8, 1),
		true
	)

func _on_deck_builder_pressed() -> void:
	if run_state == null:
		return
	_play_audio("ui_click")
	builder_deck_ids = run_state.deck_ids.duplicate()
	builder_reserve_ids = run_state.reserve_ids.duplicate()
	builder_dirty = false
	builder_confirm_panel.visible = false
	deck_builder_overlay.visible = true
	_refresh_deck_builder(_text("map.deck.instructions", {}, "点击当前卡组内的卡可移入备牌区；点击备牌区的卡可加入当前卡组。"))

func _close_deck_builder(saved := false) -> void:
	_play_audio("ui_click")
	deck_builder_overlay.visible = false
	builder_confirm_panel.visible = false
	builder_dirty = false
	if saved:
		_render_map()
	else:
		_refresh_status_panel()

func _on_save_builder_pressed() -> void:
	if run_state == null:
		return
	var reason: String = run_state.apply_deck_build(builder_deck_ids, builder_reserve_ids)
	if reason != "":
		_refresh_deck_builder(_text("map.deck.save_failed", {"reason": reason}, "无法保存：{reason}"))
		return
	builder_dirty = false
	_close_deck_builder(true)

func _on_cancel_builder_pressed() -> void:
	if builder_dirty:
		builder_confirm_panel.visible = true
		return
	_discard_builder_and_close()

func _on_confirm_save_builder() -> void:
	builder_confirm_panel.visible = false
	_on_save_builder_pressed()

func _discard_builder_and_close() -> void:
	builder_deck_ids.clear()
	builder_reserve_ids.clear()
	builder_dirty = false
	_refresh_status_panel()
	_close_deck_builder(false)

func _refresh_deck_builder(message := "") -> void:
	if run_state == null or builder_deck_container == null:
		return
	_clear_children(builder_deck_container)
	_clear_children(builder_reserve_container)
	var score: int = DeckBuildRulesScript.deck_score(builder_deck_ids)
	builder_summary_label.text = _text("map.deck.summary", {"count": builder_deck_ids.size(), "min": DeckBuildRulesScript.min_deck_size(), "max": DeckBuildRulesScript.max_deck_size(), "score": score, "limit": run_state.deck_score_limit}, "卡组 {count}/{min}-{max}  ·  卡组总分 {score}/{limit}")
	builder_deck_title_label.text = _text("map.deck.current_count", {"count": builder_deck_ids.size()}, "当前卡组（{count}）")
	builder_reserve_title_label.text = _text("map.deck.reserve_count", {"count": builder_reserve_ids.size()}, "备牌区（{count}）")
	builder_hint_label.text = _builder_hint_text(message)
	for i in range(builder_deck_ids.size()):
		_add_builder_card(builder_deck_container, str(builder_deck_ids[i]), _text("deck.action.remove", {}, "移出"), "deck", i)
	for i in range(builder_reserve_ids.size()):
		_add_builder_card(builder_reserve_container, str(builder_reserve_ids[i]), _text("deck.action.add", {}, "加入"), "reserve", i)

func _builder_hint_text(message: String) -> String:
	var parts: Array = []
	if message != "":
		parts.append(message)
	parts.append(_text("map.deck.hint", {"min": DeckBuildRulesScript.min_deck_size(), "max": DeckBuildRulesScript.max_deck_size()}, "保存卡组时会检查 {min}-{max} 张和分数上限；编辑过程中可以临时不满足。"))
	return "  ".join(parts)

func _add_builder_card(parent: GridContainer, card_id: String, prefix: String, source: String, index: int) -> void:
	DeckBuilderViewFactoryScript.add_builder_card(parent, card_id, prefix, _on_builder_card_pressed.bind(source, index))

func _on_builder_card_pressed(_uid: String, source: String, index: int) -> void:
	if run_state == null:
		return
	_play_audio("ui_confirm")
	if source == "deck":
		if index >= 0 and index < builder_deck_ids.size():
			var card_id := str(builder_deck_ids[index])
			builder_deck_ids.remove_at(index)
			builder_reserve_ids.append(card_id)
			builder_dirty = true
			_refresh_deck_builder(_text("map.deck.moved_to_reserve", {}, "已移入备牌区。"))
		return
	if index >= 0 and index < builder_reserve_ids.size():
		var card_id := str(builder_reserve_ids[index])
		builder_reserve_ids.remove_at(index)
		builder_deck_ids.append(card_id)
		builder_dirty = true
		_refresh_deck_builder(_text("map.deck.added", {}, "已加入当前卡组。"))

func _text(text_id: String, params: Dictionary = {}, source_fallback := "") -> String:
	return LocalizationServiceScript.text(text_id, "zh_cn", params, source_fallback)

func _panel_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	return UIStyleFactoryScript.panel_style(bg, border, radius, border_width, Vector4(10, 10, 8, 8))

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
