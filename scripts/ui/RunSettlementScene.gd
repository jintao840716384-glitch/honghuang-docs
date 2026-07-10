extends Control

signal return_requested
signal retry_requested

const UIStyleFactoryScript = preload("res://scripts/ui/UIStyleFactory.gd")
const LocalizationServiceScript = preload("res://scripts/localization/LocalizationService.gd")

var title_label: Label
var subtitle_label: Label
var job_label: Label
var layer_label: Label
var nodes_label: Label
var base_label: Label
var multiplier_label: Label
var awarded_label: Label
var total_label: Label
var return_button: Button
var retry_button: Button

func _ready() -> void:
	_build_scene()

func setup(run_state, settlement: Dictionary) -> void:
	if title_label == null:
		await ready
	_apply_settlement(run_state, settlement)

func _build_scene() -> void:
	var background := ColorRect.new()
	background.color = Color(0.035, 0.040, 0.045, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	root.name = "SettlementRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 160.0
	root.offset_top = 86.0
	root.offset_right = -160.0
	root.offset_bottom = -86.0
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 18)
	add_child(root)

	title_label = Label.new()
	title_label.name = "SettlementTitleLabel"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 40)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	root.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.name = "SettlementSubtitleLabel"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 17)
	subtitle_label.add_theme_color_override("font_color", Color(0.74, 0.78, 0.82, 1.0))
	root.add_child(subtitle_label)

	var panel := PanelContainer.new()
	panel.name = "SettlementPanel"
	panel.custom_minimum_size = Vector2(760.0, 430.0)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.062, 0.068, 0.98), Color(0.44, 0.52, 0.58, 1.0), 8, 1))
	root.add_child(panel)

	var panel_layout := VBoxContainer.new()
	panel_layout.name = "SettlementStatsLayout"
	panel_layout.add_theme_constant_override("separation", 12)
	panel.add_child(panel_layout)

	job_label = _make_row_label("SettlementJobLabel")
	panel_layout.add_child(job_label)
	layer_label = _make_row_label("SettlementLayerLabel")
	panel_layout.add_child(layer_label)
	nodes_label = _make_row_label("SettlementNodesLabel")
	panel_layout.add_child(nodes_label)

	var divider := HSeparator.new()
	panel_layout.add_child(divider)

	base_label = _make_row_label("SettlementBaseLabel")
	panel_layout.add_child(base_label)
	multiplier_label = _make_row_label("SettlementMultiplierLabel")
	panel_layout.add_child(multiplier_label)
	awarded_label = _make_row_label("SettlementAwardedLabel")
	awarded_label.add_theme_font_size_override("font_size", 22)
	awarded_label.add_theme_color_override("font_color", Color(0.92, 0.82, 0.54, 1.0))
	panel_layout.add_child(awarded_label)
	total_label = _make_row_label("SettlementTotalLabel")
	panel_layout.add_child(total_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 14)
	root.add_child(button_row)

	return_button = _make_button(_text("settlement.return", {}, "返回角色界面"))
	return_button.name = "SettlementReturnButton"
	return_button.pressed.connect(_on_return_pressed)
	button_row.add_child(return_button)

	retry_button = _make_button(_text("settlement.retry", {}, "再次挑战"))
	retry_button.name = "SettlementRetryButton"
	retry_button.pressed.connect(_on_retry_pressed)
	button_row.add_child(retry_button)

func _apply_settlement(run_state, settlement: Dictionary) -> void:
	var completed: bool = bool(settlement.get("completed", false))
	title_label.text = _text("settlement.complete", {}, "探索完成") if completed else _text("settlement.failed", {}, "探索失败")
	subtitle_label.text = _text("settlement.complete_desc", {}, "本轮探索已结算，修为点已写入当前角色。") if completed else _text("settlement.failed_desc", {}, "本轮探索到此结束，已完成节点的修为点照常结算。")

	var job_name := "未知角色"
	var title_name := ""
	var layer_number := 1
	var layer_count := 1
	var completed_nodes := 0
	var points_total := 0
	var points_available := 0
	if run_state != null:
		job_name = str(run_state.job_name)
		if run_state.has_method("realm_name"):
			title_name = str(run_state.realm_name())
		if run_state.has_method("current_story_layer_number"):
			layer_number = int(run_state.current_story_layer_number())
		if run_state.has_method("main_story_layer_count"):
			layer_count = int(run_state.main_story_layer_count())
		completed_nodes = int(run_state.completed_node_ids.size())
		if run_state.meta_progression != null:
			points_total = int(run_state.meta_progression.points_total(run_state.job_id))
			points_available = int(run_state.meta_progression.points_available(run_state.job_id))

	var base: int = int(settlement.get("base", 0))
	var multiplier: float = float(settlement.get("multiplier", 1.0))
	var awarded: int = int(settlement.get("awarded", 0))

	job_label.text = _text("settlement.job_title", {"job": job_name, "title": title_name}, "角色：{job}    称号：{title}")
	layer_label.text = _text("settlement.layer", {"current": layer_number, "total": layer_count}, "到达层数：第 {current} / {total} 层")
	nodes_label.text = _text("settlement.nodes", {"count": completed_nodes}, "完成节点：{count}")
	base_label.text = _text("settlement.base", {"value": base}, "基础修为：{value}")
	multiplier_label.text = _text("settlement.multiplier", {"value": _format_multiplier(multiplier)}, "层数倍率：x{value}")
	awarded_label.text = _text("settlement.awarded", {"value": awarded}, "本次获得修为点：{value}")
	total_label.text = _text("settlement.total", {"available": points_available, "total": points_total}, "当前修为点：可用 {available}    累计 {total}")

func _make_row_label(node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.84, 1.0))
	return label

func _make_button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(190.0, 46.0)
	button.add_theme_font_size_override("font_size", 17)
	_style_button(button, Color(0.09, 0.10, 0.11, 0.96), Color(0.50, 0.55, 0.62, 1.0))
	return button

func _on_return_pressed() -> void:
	return_requested.emit()

func _on_retry_pressed() -> void:
	retry_requested.emit()

func _format_multiplier(value: float) -> String:
	if is_equal_approx(value, floor(value)):
		return "%d" % int(value)
	return "%.2f" % value

func _text(text_id: String, params: Dictionary = {}, source_fallback := "") -> String:
	return LocalizationServiceScript.text(text_id, "zh_cn", params, source_fallback)

func _style_button(button: Button, bg: Color, border: Color) -> void:
	UIStyleFactoryScript.apply_button_style(button, bg, border, 7, 1, 2, 2, Vector4(24, 24, 22, 22), 0, 0.14, 0.06, 0.18)

func _panel_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	return UIStyleFactoryScript.panel_style(bg, border, radius, border_width, Vector4(24, 24, 22, 22))
