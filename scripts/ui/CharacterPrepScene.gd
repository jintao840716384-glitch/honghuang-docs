extends Control

signal start_requested(job_id: String, deck_ids: Array, reserve_ids: Array)
signal back_requested

const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const MetaProgressionScript = preload("res://scripts/data/MetaProgression.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const CardButtonScene = preload("res://scenes/CardButton.tscn")
const CARD_UNLOCK_UPGRADE_ID := "card_unlock"
const BASE_DECK_SCORE_LIMIT := 20
const GROWTH_CATEGORY_ORDER := ["基础属性", "卡组与卡包", "角色特性", "强力规则"]

var selected_job_id := "sword"
var progression
var title_label: Label
var subtitle_label: Label
var portrait_label: Label
var stat_label: Label
var points_label: Label
var pack_label: Label
var message_label: Label
var overlay: ColorRect
var overlay_title_label: Label
var overlay_message_label: Label
var overlay_content: VBoxContainer
var prep_deck_ids: Array = []
var prep_reserve_ids: Array = []
var prep_builder_deck_container: GridContainer
var prep_builder_reserve_container: GridContainer

func _ready() -> void:
	progression = MetaProgressionScript.new()
	progression.load()
	_build_scene()
	_reset_starting_build()
	_refresh()

func setup(job_id: String) -> void:
	selected_job_id = job_id if job_id != "" else "sword"
	if title_label == null:
		await ready
	_reset_starting_build()
	_refresh()

func _build_scene() -> void:
	var background := ColorRect.new()
	background.color = Color(0.035, 0.040, 0.045, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := HBoxContainer.new()
	root.name = "CharacterPrepRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 78.0
	root.offset_top = 56.0
	root.offset_right = -78.0
	root.offset_bottom = -56.0
	root.add_theme_constant_override("separation", 28)
	add_child(root)

	var left := VBoxContainer.new()
	left.name = "CharacterPanel"
	left.custom_minimum_size = Vector2(560.0, 1.0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 14)
	root.add_child(left)

	title_label = Label.new()
	title_label.name = "CharacterTitleLabel"
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	left.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.name = "CharacterSubtitleLabel"
	subtitle_label.add_theme_font_size_override("font_size", 17)
	subtitle_label.add_theme_color_override("font_color", Color(0.74, 0.80, 0.82, 1.0))
	left.add_child(subtitle_label)

	var portrait := Panel.new()
	portrait.name = "CharacterPortrait"
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait.add_theme_stylebox_override("panel", _panel_style(Color(0.10, 0.12, 0.15, 1.0), Color(0.48, 0.54, 0.60, 1.0), 8, 1))
	left.add_child(portrait)

	portrait_label = Label.new()
	portrait_label.name = "CharacterPortraitLabel"
	portrait_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	portrait_label.add_theme_font_size_override("font_size", 34)
	portrait_label.add_theme_color_override("font_color", Color(0.88, 0.91, 0.94, 1.0))
	portrait.add_child(portrait_label)

	var info_panel := PanelContainer.new()
	info_panel.name = "CharacterInfoPanel"
	info_panel.custom_minimum_size = Vector2(1.0, 150.0)
	info_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.062, 0.068, 0.98), Color(0.36, 0.42, 0.48, 1.0), 8, 1))
	left.add_child(info_panel)

	var info_layout := VBoxContainer.new()
	info_layout.add_theme_constant_override("separation", 8)
	info_panel.add_child(info_layout)

	stat_label = _make_info_label("CharacterStatLabel")
	info_layout.add_child(stat_label)
	points_label = _make_info_label("CharacterPointsLabel")
	info_layout.add_child(points_label)
	pack_label = _make_info_label("CharacterPackLabel")
	info_layout.add_child(pack_label)

	var right := VBoxContainer.new()
	right.name = "CharacterActionPanel"
	right.custom_minimum_size = Vector2(380.0, 1.0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	right.add_theme_constant_override("separation", 12)
	root.add_child(right)

	var start_button := _make_action_button("开始挑战", Color(0.18, 0.12, 0.06, 0.96), Color(0.88, 0.62, 0.30, 1.0))
	start_button.name = "StartChallengeButton"
	start_button.pressed.connect(_on_start_pressed)
	right.add_child(start_button)

	var growth_button := _make_action_button("角色成长", Color(0.08, 0.11, 0.10, 0.96), Color(0.48, 0.70, 0.52, 1.0))
	growth_button.name = "GrowthButton"
	growth_button.pressed.connect(_on_growth_pressed)
	right.add_child(growth_button)

	var pack_button := _make_action_button("卡包解锁", Color(0.08, 0.10, 0.12, 0.96), Color(0.50, 0.62, 0.76, 1.0))
	pack_button.name = "PackButton"
	pack_button.pressed.connect(_on_pack_pressed)
	right.add_child(pack_button)

	var deck_button := _make_action_button("开局构筑", Color(0.10, 0.09, 0.12, 0.96), Color(0.62, 0.54, 0.78, 1.0))
	deck_button.name = "DeckButton"
	deck_button.pressed.connect(_on_deck_pressed)
	right.add_child(deck_button)

	var back_button := _make_action_button("返回角色选择", Color(0.08, 0.09, 0.10, 0.96), Color(0.40, 0.44, 0.50, 1.0))
	back_button.name = "BackButton"
	back_button.pressed.connect(_on_back_pressed)
	right.add_child(back_button)

	message_label = Label.new()
	message_label.name = "CharacterMessageLabel"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_font_size_override("font_size", 14)
	message_label.add_theme_color_override("font_color", Color(0.78, 0.82, 0.80, 1.0))
	right.add_child(message_label)

	_create_overlay()

func _refresh(message: String = "") -> void:
	if progression == null:
		return
	var job := JobDatabaseScript.get_job(selected_job_id)
	if job.is_empty():
		return
	var job_name := str(job.get("name", selected_job_id))
	var bonuses: Dictionary = progression.bonuses_for_job(selected_job_id)
	var max_hp: int = int(job.get("max_hp", 0)) + int(bonuses.get("max_hp", 0))
	var attack: int = int(job.get("attack", 0)) + int(bonuses.get("attack", 0))
	var defense: int = int(job.get("defense", 0)) + int(bonuses.get("defense", 0))
	var draw_count: int = 1 + int(bonuses.get("draw_per_turn", 0))
	var deck_score_limit: int = 20 + int(bonuses.get("deck_score_limit", 0))
	var title_text: String = progression.title_with_job(selected_job_id, job_name)
	title_label.text = job_name
	subtitle_label.text = title_text
	portrait_label.text = job_name
	stat_label.text = "生命 %d    攻 %d / 防 %d    基础抽牌 %d    卡组总分上限 %d" % [max_hp, attack, defense, draw_count, deck_score_limit]
	points_label.text = "修为点：可用 %d    累计 %d" % [
		progression.points_available(selected_job_id),
		progression.points_total(selected_job_id)
	]
	pack_label.text = "已开放卡包：%s" % _pack_summary()
	message_label.text = message

func _create_overlay() -> void:
	overlay = ColorRect.new()
	overlay.name = "CharacterPrepOverlay"
	overlay.color = Color(0.0, 0.0, 0.0, 0.62)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	overlay.z_index = 100
	add_child(overlay)

	var panel := PanelContainer.new()
	panel.name = "OverlayPanel"
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 160.0
	panel.offset_top = 78.0
	panel.offset_right = -160.0
	panel.offset_bottom = -78.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.052, 0.056, 0.99), Color(0.48, 0.62, 0.52, 1.0), 8, 2))
	overlay.add_child(panel)

	var layout := VBoxContainer.new()
	layout.name = "OverlayLayout"
	layout.add_theme_constant_override("separation", 12)
	panel.add_child(layout)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	layout.add_child(header)

	overlay_title_label = Label.new()
	overlay_title_label.name = "OverlayTitleLabel"
	overlay_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	overlay_title_label.add_theme_font_size_override("font_size", 24)
	overlay_title_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	header.add_child(overlay_title_label)

	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(92.0, 38.0)
	close_button.pressed.connect(_on_overlay_close_pressed)
	_style_button(close_button, Color(0.10, 0.10, 0.11, 0.96), Color(0.54, 0.56, 0.62, 1.0))
	header.add_child(close_button)

	overlay_message_label = Label.new()
	overlay_message_label.name = "OverlayMessageLabel"
	overlay_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_message_label.add_theme_font_size_override("font_size", 14)
	overlay_message_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.82, 1.0))
	layout.add_child(overlay_message_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	layout.add_child(scroll)

	overlay_content = VBoxContainer.new()
	overlay_content.name = "OverlayContent"
	overlay_content.add_theme_constant_override("separation", 8)
	scroll.add_child(overlay_content)

func _on_growth_pressed() -> void:
	overlay_title_label.text = "角色成长"
	overlay_message_label.text = _growth_summary_text()
	_clear_children(overlay_content)
	var grouped: Dictionary = _group_growth_upgrades()
	for category_variant in _growth_category_order(grouped):
		var category := str(category_variant)
		_add_section_header(category)
		for definition_variant in grouped.get(category, []):
			var definition: Dictionary = definition_variant
			_add_growth_upgrade_row(definition)
	overlay.visible = true

func _add_growth_upgrade_row(definition: Dictionary) -> void:
	var upgrade_id := str(definition.get("id", ""))
	var level: int = progression.upgrade_level(selected_job_id, upgrade_id)
	var max_level: int = int(definition.get("max_level", 0))
	var cost: int = progression.next_upgrade_cost(selected_job_id, upgrade_id)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	overlay_content.add_child(row)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)

	var title := Label.new()
	title.text = "%s  %d/%d" % [str(definition.get("name", upgrade_id)), level, max_level]
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", Color(0.94, 0.90, 0.78, 1.0))
	text_box.add_child(title)

	var desc := Label.new()
	desc.text = "%s  %s" % [str(definition.get("description", "")), _upgrade_cost_text(cost)]
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", Color(0.78, 0.84, 0.82, 1.0))
	text_box.add_child(desc)

	var button := Button.new()
	button.custom_minimum_size = Vector2(150.0, 42.0)
	button.focus_mode = Control.FOCUS_NONE
	if cost <= 0:
		button.text = "已满级"
		button.disabled = true
	elif progression.points_available(selected_job_id) < cost:
		button.text = "需要 %d" % cost
		button.disabled = true
	else:
		button.text = "提升 %d" % cost
		button.pressed.connect(_on_buy_upgrade_pressed.bind(upgrade_id))
	_style_button(button, Color(0.10, 0.13, 0.11, 0.96), Color(0.58, 0.82, 0.46, 1.0))
	row.add_child(button)

func _on_buy_upgrade_pressed(upgrade_id: String) -> void:
	var message: String = progression.buy_upgrade(selected_job_id, upgrade_id)
	if upgrade_id == CARD_UNLOCK_UPGRADE_ID:
		_refresh_starting_card_pool()
	_refresh(message)
	_on_growth_pressed()
	overlay_message_label.text = message

func _growth_summary_text() -> String:
	var job: Dictionary = JobDatabaseScript.get_job(selected_job_id)
	var job_name := str(job.get("name", selected_job_id))
	var bonuses: Dictionary = progression.bonuses_for_job(selected_job_id)
	var max_hp: int = int(job.get("max_hp", 0)) + int(bonuses.get("max_hp", 0))
	var attack: int = int(job.get("attack", 0)) + int(bonuses.get("attack", 0))
	var defense: int = int(job.get("defense", 0)) + int(bonuses.get("defense", 0))
	var draw_count: int = 1 + int(bonuses.get("draw_per_turn", 0))
	var deck_score_limit: int = BASE_DECK_SCORE_LIMIT + int(bonuses.get("deck_score_limit", 0))
	return "%s    可用修为点 %d / 累计 %d\n生命 %d    攻 %d / 防 %d    基础抽牌 %d    卡组总分上限 %d" % [
		progression.title_with_job(selected_job_id, job_name),
		progression.points_available(selected_job_id),
		progression.points_total(selected_job_id),
		max_hp,
		attack,
		defense,
		draw_count,
		deck_score_limit
	]

func _group_growth_upgrades() -> Dictionary:
	var grouped: Dictionary = {}
	for definition_variant in MetaProgressionScript.upgrades_for_job(selected_job_id):
		var definition: Dictionary = definition_variant
		var category := str(definition.get("category", "其他"))
		if not grouped.has(category):
			grouped[category] = []
		var items: Array = grouped.get(category, [])
		items.append(definition)
		grouped[category] = items
	return grouped

func _growth_category_order(grouped: Dictionary) -> Array:
	var result: Array = []
	for category_variant in GROWTH_CATEGORY_ORDER:
		var category := str(category_variant)
		if grouped.has(category):
			result.append(category)
	for category_variant in grouped.keys():
		var category := str(category_variant)
		if not result.has(category):
			result.append(category)
	return result

func _add_section_header(title_text: String) -> void:
	var label := Label.new()
	label.text = title_text
	label.name = "GrowthSection_%s" % title_text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.64, 0.76, 0.68, 1.0))
	overlay_content.add_child(label)

func _upgrade_cost_text(cost: int) -> String:
	if cost <= 0:
		return "已满级。"
	var available: int = progression.points_available(selected_job_id)
	if available < cost:
		return "下级消耗 %d 修为点，当前不足。" % cost
	return "下级消耗 %d 修为点。" % cost

func _on_pack_pressed() -> void:
	overlay_title_label.text = "卡包解锁"
	var unlock_level: int = progression.upgrade_level(selected_job_id, CARD_UNLOCK_UPGRADE_ID)
	var unlock_definition: Dictionary = MetaProgressionScript.upgrade_definition(selected_job_id, CARD_UNLOCK_UPGRADE_ID)
	var unlock_max_level: int = int(unlock_definition.get("max_level", 0))
	var available_points: int = progression.points_available(selected_job_id)
	overlay_message_label.text = "识藏 %d/%d    可用修为点 %d\n当前奖励、事件、宝箱和坊市只会从已开放卡包中抽取。" % [
		unlock_level,
		unlock_max_level,
		available_points
	]
	_clear_children(overlay_content)
	var unlocked_packs: Array = CardDatabaseScript.unlocked_packs_for_job(selected_job_id, _unlock_tier())
	var pack_counts: Dictionary = CardDatabaseScript.pack_card_counts_for_job(selected_job_id)
	for pack_id_variant in CardDatabaseScript.pack_ids_for_job(selected_job_id):
		var pack_id := str(pack_id_variant)
		var state := "已开放" if unlocked_packs.has(pack_id) else "未开放"
		_add_text_row(CardDatabaseScript.pack_display_name(pack_id), "%s    %d 张" % [state, int(pack_counts.get(pack_id, 0))])
	var next_summary := _next_pack_summary()
	_add_text_row("下一批", next_summary)
	var unlock_cost: int = progression.next_upgrade_cost(selected_job_id, CARD_UNLOCK_UPGRADE_ID)
	if unlock_cost > 0:
		var disabled := available_points < unlock_cost
		var button_text := "修为点不足" if disabled else "开放下一批"
		_add_button_row("开放方式", "消耗 %d 修为点" % unlock_cost, button_text, _on_buy_pack_unlock_pressed, disabled, "PackUnlockButton")
	else:
		_add_button_row("开放进度", "已开放当前全部批次", "已全部开放", Callable(), true, "PackUnlockButton")
	overlay.visible = true

func _on_deck_pressed() -> void:
	overlay_title_label.text = "开局构筑"
	_refresh_prep_deck_builder("点击当前卡组内的卡可移入备选池；点击备选池的卡可加入当前卡组。")
	overlay.visible = true

func _refresh_prep_deck_builder(message := "") -> void:
	_clear_children(overlay_content)
	var score: int = CardDatabaseScript.deck_score(prep_deck_ids)
	var reason: String = _deck_build_block_reason(prep_deck_ids)
	var parts: Array = []
	if message != "":
		parts.append(message)
	if reason != "":
		parts.append("当前不能开始挑战：%s" % reason)
	else:
		parts.append("当前构筑可用于开始挑战。")
	overlay_message_label.text = "卡组 %d/%d-%d    卡组总分 %d/%d\n%s" % [
		prep_deck_ids.size(),
		CardDatabaseScript.MIN_DECK_SIZE,
		CardDatabaseScript.MAX_DECK_SIZE,
		score,
		_deck_score_limit(),
		"  ".join(parts)
	]

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	action_row.add_theme_constant_override("separation", 10)
	overlay_content.add_child(action_row)

	var reset_button := Button.new()
	reset_button.name = "PrepDeckResetButton"
	reset_button.text = "恢复默认"
	reset_button.custom_minimum_size = Vector2(128.0, 38.0)
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.pressed.connect(_on_reset_prep_deck_pressed)
	_style_button(reset_button, Color(0.10, 0.10, 0.11, 0.96), Color(0.54, 0.56, 0.62, 1.0))
	action_row.add_child(reset_button)

	var columns := HBoxContainer.new()
	columns.name = "PrepDeckBuilderColumns"
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 14)
	overlay_content.add_child(columns)

	var deck_column: Dictionary = _create_prep_deck_column("当前卡组（%d）" % prep_deck_ids.size(), "PrepDeckContainer")
	prep_builder_deck_container = deck_column["container"] as GridContainer
	columns.add_child(deck_column["panel"] as Control)

	var reserve_column: Dictionary = _create_prep_deck_column("备选池（%d）" % prep_reserve_ids.size(), "PrepReserveContainer")
	prep_builder_reserve_container = reserve_column["container"] as GridContainer
	columns.add_child(reserve_column["panel"] as Control)

	for i in range(prep_deck_ids.size()):
		_add_prep_builder_card(prep_builder_deck_container, str(prep_deck_ids[i]), "移出", "deck", i)
	for i in range(prep_reserve_ids.size()):
		_add_prep_builder_card(prep_builder_reserve_container, str(prep_reserve_ids[i]), "加入", "reserve", i)

func _create_prep_deck_column(column_title: String, container_name: String) -> Dictionary:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.060, 0.066, 0.072, 0.95), Color(0.30, 0.35, 0.40, 1.0), 8, 1))

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	panel.add_child(layout)

	var title := Label.new()
	title.text = column_title
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.94, 0.90, 0.78, 1.0))
	layout.add_child(title)

	var container := GridContainer.new()
	container.name = container_name
	container.columns = 3
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("h_separation", 10)
	container.add_theme_constant_override("v_separation", 10)
	layout.add_child(container)

	return {"panel": panel, "container": container}

func _add_prep_builder_card(parent: GridContainer, card_id: String, prefix: String, source: String, index: int) -> void:
	var card: Dictionary = CardDatabaseScript.get_card(card_id)
	if card.is_empty():
		return
	var button: CardButton = CardButtonScene.instantiate()
	button.build_cost_display_enabled = true
	button.setup(card, prefix)
	button.hover_details_enabled = false
	button.hover_motion_enabled = false
	button.card_pressed.connect(_on_prep_builder_card_pressed.bind(source, index))
	parent.add_child(button)

func _on_prep_builder_card_pressed(_uid: String, source: String, index: int) -> void:
	if source == "deck":
		if index >= 0 and index < prep_deck_ids.size():
			var card_id := str(prep_deck_ids[index])
			prep_deck_ids.remove_at(index)
			prep_reserve_ids.append(card_id)
			_refresh()
			_refresh_prep_deck_builder("已移入备选池。")
		return
	if index < 0 or index >= prep_reserve_ids.size():
		return
	var reserve_card_id := str(prep_reserve_ids[index])
	if not CardDatabaseScript.can_add_card_to_deck(reserve_card_id, prep_deck_ids, _deck_score_limit()):
		_refresh_prep_deck_builder("无法加入：%s。" % CardDatabaseScript.deck_add_block_reason(reserve_card_id, prep_deck_ids, _deck_score_limit()))
		return
	prep_reserve_ids.remove_at(index)
	prep_deck_ids.append(reserve_card_id)
	_refresh()
	_refresh_prep_deck_builder("已加入当前卡组。")

func _on_reset_prep_deck_pressed() -> void:
	_reset_starting_build()
	_refresh()
	_refresh_prep_deck_builder("已恢复默认开局构筑。")

func _add_text_row(left_text: String, right_text: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	overlay_content.add_child(row)
	var left_label := Label.new()
	left_label.custom_minimum_size = Vector2(150.0, 1.0)
	left_label.add_theme_font_size_override("font_size", 16)
	left_label.add_theme_color_override("font_color", Color(0.94, 0.90, 0.78, 1.0))
	left_label.text = left_text
	row.add_child(left_label)
	var right_label := Label.new()
	right_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right_label.add_theme_font_size_override("font_size", 15)
	right_label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.84, 1.0))
	right_label.text = right_text
	row.add_child(right_label)

func _add_button_row(left_text: String, right_text: String, button_text: String, callback: Callable, disabled := false, button_name := "") -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	overlay_content.add_child(row)
	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)
	var left_label := Label.new()
	left_label.add_theme_font_size_override("font_size", 16)
	left_label.add_theme_color_override("font_color", Color(0.94, 0.90, 0.78, 1.0))
	left_label.text = left_text
	text_box.add_child(left_label)
	var right_label := Label.new()
	right_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right_label.add_theme_font_size_override("font_size", 15)
	right_label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.84, 1.0))
	right_label.text = right_text
	text_box.add_child(right_label)
	var button := Button.new()
	button.name = button_name
	button.custom_minimum_size = Vector2(150.0, 42.0)
	button.focus_mode = Control.FOCUS_NONE
	button.text = button_text
	button.disabled = disabled
	if not disabled:
		button.pressed.connect(callback)
	_style_button(button, Color(0.10, 0.13, 0.11, 0.96), Color(0.58, 0.82, 0.46, 1.0))
	row.add_child(button)

func _on_buy_pack_unlock_pressed() -> void:
	var message: String = progression.buy_upgrade(selected_job_id, CARD_UNLOCK_UPGRADE_ID)
	_refresh_starting_card_pool()
	_refresh(message)
	_on_pack_pressed()
	overlay_message_label.text = message

func _on_overlay_close_pressed() -> void:
	overlay.visible = false
	_refresh()

func _on_start_pressed() -> void:
	var reason: String = _deck_build_block_reason(prep_deck_ids)
	if reason != "":
		message_label.text = reason
		_on_deck_pressed()
		return
	start_requested.emit(selected_job_id, prep_deck_ids.duplicate(), [])

func _on_back_pressed() -> void:
	back_requested.emit()

func _pack_summary() -> String:
	var names: Array = []
	for pack_variant in CardDatabaseScript.unlocked_packs_for_job(selected_job_id, _unlock_tier()):
		names.append(CardDatabaseScript.pack_display_name(str(pack_variant)))
	return "、".join(names)

func _next_pack_summary() -> String:
	var current_packs: Array = CardDatabaseScript.unlocked_packs_for_job(selected_job_id, _unlock_tier())
	var next_packs: Array = CardDatabaseScript.unlocked_packs_for_job(selected_job_id, _unlock_tier() + 1)
	var names: Array = []
	for pack_variant in next_packs:
		var pack_id := str(pack_variant)
		if not current_packs.has(pack_id):
			names.append(CardDatabaseScript.pack_display_name(pack_id))
	if names.is_empty():
		return "暂无下一批"
	return "、".join(names)

func _unlock_tier() -> int:
	var bonuses: Dictionary = progression.bonuses_for_job(selected_job_id) if progression != null else {}
	return int(bonuses.get("card_unlock_tier", 0))

func _default_start_deck() -> Array:
	var job: Dictionary = JobDatabaseScript.get_job(selected_job_id)
	return (job.get("start_deck", []) as Array).duplicate()

func _reset_starting_build() -> void:
	prep_deck_ids = _default_start_deck()
	prep_reserve_ids = _initial_starting_reserve(prep_deck_ids)

func _refresh_starting_card_pool() -> void:
	var required_counts: Dictionary = _starting_pool_counts(_default_start_deck())
	var current_counts: Dictionary = _card_counts(prep_deck_ids)
	var reserve_counts: Dictionary = _card_counts(prep_reserve_ids)
	for card_id_variant in reserve_counts.keys():
		var card_id := str(card_id_variant)
		current_counts[card_id] = int(current_counts.get(card_id, 0)) + int(reserve_counts.get(card_id, 0))
	for card_id_variant in _starting_pool_order(_default_start_deck()):
		var card_id := str(card_id_variant)
		var missing: int = int(required_counts.get(card_id, 0)) - int(current_counts.get(card_id, 0))
		for _i in range(max(0, missing)):
			prep_reserve_ids.append(card_id)

func _initial_starting_reserve(deck_ids: Array) -> Array:
	var result: Array = []
	var counts: Dictionary = _starting_pool_counts(deck_ids)
	for card_id_variant in deck_ids:
		var deck_card_id := str(card_id_variant)
		counts[deck_card_id] = int(counts.get(deck_card_id, 0)) - 1
	for card_id_variant in _starting_pool_order(deck_ids):
		var card_id := str(card_id_variant)
		for _i in range(max(0, int(counts.get(card_id, 0)))):
			result.append(card_id)
	return result

func _starting_pool_counts(default_deck: Array) -> Dictionary:
	var result: Dictionary = {}
	for card_id_variant in _unlocked_starting_pool():
		var card_id := str(card_id_variant)
		result[card_id] = max(1, int(result.get(card_id, 0)))
	var deck_counts: Dictionary = _card_counts(default_deck)
	for card_id_variant in deck_counts.keys():
		var card_id := str(card_id_variant)
		result[card_id] = max(int(result.get(card_id, 0)), int(deck_counts.get(card_id, 0)))
	return result

func _starting_pool_order(default_deck: Array) -> Array:
	var result: Array = []
	for card_id_variant in _unlocked_starting_pool():
		var card_id := str(card_id_variant)
		if not result.has(card_id):
			result.append(card_id)
	for card_id_variant in default_deck:
		var card_id := str(card_id_variant)
		if not result.has(card_id):
			result.append(card_id)
	return result

func _unlocked_starting_pool() -> Array:
	var result: Array = []
	var pool: Array = CardDatabaseScript.common_pool()
	pool.append_array(CardDatabaseScript.job_pool(selected_job_id))
	for card_id_variant in pool:
		var card_id := str(card_id_variant)
		if CardDatabaseScript.card_unlocked_for_job(card_id, selected_job_id, _unlock_tier()) and not result.has(card_id):
			result.append(card_id)
	return result

func _card_counts(card_ids: Array) -> Dictionary:
	var result: Dictionary = {}
	for card_id_variant in card_ids:
		var card_id := str(card_id_variant)
		result[card_id] = int(result.get(card_id, 0)) + 1
	return result

func _deck_score_limit() -> int:
	var bonuses: Dictionary = progression.bonuses_for_job(selected_job_id) if progression != null else {}
	return BASE_DECK_SCORE_LIMIT + int(bonuses.get("deck_score_limit", 0))

func _deck_build_block_reason(candidate_deck_ids: Array) -> String:
	if candidate_deck_ids.size() < CardDatabaseScript.MIN_DECK_SIZE:
		return "当前卡组至少需要 %d 张。" % CardDatabaseScript.MIN_DECK_SIZE
	if candidate_deck_ids.size() > CardDatabaseScript.MAX_DECK_SIZE:
		return "当前卡组不能超过 %d 张。" % CardDatabaseScript.MAX_DECK_SIZE
	if _deck_score_limit() > 0 and CardDatabaseScript.deck_score(candidate_deck_ids) > _deck_score_limit():
		return "当前卡组总分超过上限。"
	return ""

func _make_info_label(node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.84, 1.0))
	return label

func _make_action_button(label: String, bg: Color, border: Color) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(240.0, 48.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 18)
	_style_button(button, bg, border)
	return button

func _style_button(button: Button, bg: Color, border: Color) -> void:
	button.add_theme_stylebox_override("normal", _panel_style(bg, border, 8, 2))
	button.add_theme_stylebox_override("hover", _panel_style(bg.lightened(0.08), border.lightened(0.14), 8, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(bg.darkened(0.05), border.lightened(0.18), 8, 2))
	button.add_theme_color_override("font_color", Color(0.94, 0.92, 0.86, 1.0))

func _panel_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
