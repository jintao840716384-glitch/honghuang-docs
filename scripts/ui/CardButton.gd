extends Button
class_name CardButton

const CardDisplayRulesScript = preload("res://scripts/ui/CardDisplayRules.gd")
const CARD_SIZE := Vector2(225, 315)

signal card_pressed(uid: String)
signal card_hovered(card: Dictionary, anchor_position: Vector2)
signal card_unhovered
signal card_motion_started(card: Dictionary)

var card_uid := ""
var card_data: Dictionary = {}
var hover_tween: Tween
var base_position := Vector2.ZERO
var base_scale := Vector2.ONE
var base_z_index := 0
var is_hovered := false
var hover_offset := 82.0
var hover_details_enabled := true
var hover_motion_enabled := true
var build_cost_display_enabled := false
var ownership_text := ""

@onready var card_layout: VBoxContainer = get_node("CardLayout") as VBoxContainer
@onready var name_label: Label = get_node("CardLayout/NameLabel") as Label
@onready var type_label: Label = get_node("CardLayout/TypeLabel") as Label
@onready var divider: ColorRect = get_node("CardLayout/Divider") as ColorRect
@onready var body_label: Label = get_node("CardLayout/BodyLabel") as Label
@onready var ownership_label: Label = get_node("CardLayout/OwnershipLabel") as Label
@onready var score_divider: ColorRect = get_node("CardLayout/ScoreDivider") as ColorRect
@onready var score_row: HBoxContainer = get_node("CardLayout/ScoreRow") as HBoxContainer
@onready var score_title_label: Label = get_node("CardLayout/ScoreRow/ScoreTitleLabel") as Label
@onready var score_value_label: Label = get_node("CardLayout/ScoreRow/ScoreValueLabel") as Label

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	call_deferred("cache_base_position")

func setup(card: Dictionary, prefix := "") -> void:
	_ensure_nodes()
	card_data = card
	card_uid = str(card.get("uid", card.get("id", "")))
	is_hovered = false
	scale = Vector2.ONE
	z_index = 0
	text = ""
	custom_minimum_size = CARD_SIZE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tooltip_text = ""

	var center_text := str(card.get("center_text", ""))
	var type_text := _type_text(card)
	if center_text != "" and prefix != "":
		type_text = prefix
	elif prefix != "":
		type_text = "%s / %s" % [prefix, type_text]
	var body_text := _body_text(card)

	name_label.text = str(card.get("name", ""))
	type_label.text = type_text
	if center_text != "":
		body_label.text = center_text
		body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	else:
		body_label.text = body_text
		body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		body_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	ownership_label.text = ownership_text
	ownership_label.visible = ownership_text != ""
	divider.visible = true
	score_divider.visible = build_cost_display_enabled
	score_row.visible = build_cost_display_enabled
	score_value_label.text = str(int(card.get("build_cost", card.get("score", 0))))
	name_label.add_theme_font_size_override("font_size", _name_font_size(name_label.text))
	type_label.add_theme_font_size_override("font_size", _type_font_size(type_text))
	if center_text != "":
		body_label.add_theme_font_size_override("font_size", _center_font_size(center_text))
	else:
		body_label.add_theme_font_size_override("font_size", _body_font_size(body_text))
	ownership_label.add_theme_font_size_override("font_size", 12)
	score_title_label.add_theme_font_size_override("font_size", 12)
	score_value_label.add_theme_font_size_override("font_size", 30)
	_apply_card_style(card)
	_update_pivot()
	call_deferred("cache_base_position")

func _ensure_nodes() -> void:
	if card_layout == null and has_node("CardLayout"):
		card_layout = get_node("CardLayout") as VBoxContainer
	if name_label == null and has_node("CardLayout/NameLabel"):
		name_label = get_node("CardLayout/NameLabel") as Label
	if type_label == null and has_node("CardLayout/TypeLabel"):
		type_label = get_node("CardLayout/TypeLabel") as Label
	if divider == null and has_node("CardLayout/Divider"):
		divider = get_node("CardLayout/Divider") as ColorRect
	if body_label == null and has_node("CardLayout/BodyLabel"):
		body_label = get_node("CardLayout/BodyLabel") as Label
	if ownership_label == null and has_node("CardLayout/OwnershipLabel"):
		ownership_label = get_node("CardLayout/OwnershipLabel") as Label
	if score_divider == null and has_node("CardLayout/ScoreDivider"):
		score_divider = get_node("CardLayout/ScoreDivider") as ColorRect
	if score_row == null and has_node("CardLayout/ScoreRow"):
		score_row = get_node("CardLayout/ScoreRow") as HBoxContainer
	if score_title_label == null and has_node("CardLayout/ScoreRow/ScoreTitleLabel"):
		score_title_label = get_node("CardLayout/ScoreRow/ScoreTitleLabel") as Label
	if score_value_label == null and has_node("CardLayout/ScoreRow/ScoreValueLabel"):
		score_value_label = get_node("CardLayout/ScoreRow/ScoreValueLabel") as Label

func _on_pressed() -> void:
	z_index = max(base_z_index + 1000, 1000)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.10)
	tween.finished.connect(func() -> void:
		z_index = base_z_index
	)
	card_pressed.emit(card_uid)

func _on_mouse_entered() -> void:
	if hover_details_enabled and not card_data.is_empty():
		card_hovered.emit(card_data, global_position + Vector2(size.x * 0.55, 0.0))
	if is_hovered or disabled or not hover_motion_enabled:
		return
	is_hovered = true
	card_motion_started.emit(card_data)
	if hover_tween != null and hover_tween.is_running():
		hover_tween.kill()
	z_index = max(base_z_index + 1000, 1000)
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.tween_property(self, "scale", Vector2(1.045, 1.045), 0.10)
	hover_tween.tween_property(self, "position", base_position + Vector2(0.0, -hover_offset), 0.10)

func _on_mouse_exited() -> void:
	card_unhovered.emit()
	if not is_hovered:
		return
	is_hovered = false
	if hover_tween != null and hover_tween.is_running():
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.tween_property(self, "scale", base_scale, 0.10)
	hover_tween.tween_property(self, "position", base_position, 0.10)
	hover_tween.finished.connect(func() -> void:
		z_index = base_z_index
	)

func cache_base_position() -> void:
	if is_hovered:
		return
	base_position = position
	base_scale = scale
	base_z_index = z_index
	_update_pivot()

func _update_pivot() -> void:
	pivot_offset = size * 0.5

func _type_text(card: Dictionary) -> String:
	return CardDisplayRulesScript.card_type_text(card, 2)

func _body_text(card: Dictionary) -> String:
	var lines: Array = []
	var description := str(card.get("description", ""))
	for line in _description_lines(description):
		if line != "":
			lines.append(line)
	var footer := _footer_text(card)
	if footer != "":
		lines.append("")
		lines.append(footer)
	return "\n".join(lines)

func _description_lines(description: String) -> Array:
	var result: Array = []
	var current := ""
	for i in range(description.length()):
		var character := description.substr(i, 1)
		current += character
		if character in ["。", "；", ";"]:
			result.append(current)
			current = ""
	if current != "":
		result.append(current)
	return result

func _footer_text(card: Dictionary) -> String:
	return CardDisplayRulesScript.footer_text(card)

func _name_font_size(display_text: String) -> int:
	if display_text.length() >= 6:
		return 18
	return 20

func _type_font_size(display_text: String) -> int:
	if display_text.length() > 18:
		return 11
	return 12

func _body_font_size(display_text: String) -> int:
	if display_text.length() > 95:
		return 10
	if display_text.length() > 70:
		return 11
	return 12

func _center_font_size(display_text: String) -> int:
	if display_text.length() <= 2:
		return 58
	if display_text.length() <= 4:
		return 48
	return 40

func _apply_card_style(card: Dictionary) -> void:
	var palette: Dictionary = CardDisplayRulesScript.card_palette(card)
	var bg: Color = palette.get("bg", Color(0.28, 0.16, 0.10, 1.0))
	var border: Color = palette.get("border", Color(0.95, 0.60, 0.30, 1.0))
	var name_color: Color = palette.get("name_color", Color(1.0, 0.88, 0.68, 1.0))
	add_theme_stylebox_override("normal", _make_style(bg, border, 2))
	add_theme_stylebox_override("hover", _make_style(bg.lightened(0.08), border.lightened(0.15), 3))
	add_theme_stylebox_override("pressed", _make_style(bg.darkened(0.05), border.lightened(0.25), 3))
	add_theme_stylebox_override("disabled", _make_style(bg.darkened(0.18), Color(0.30, 0.32, 0.35, 1.0), 2))
	add_theme_color_override("font_color", Color(0, 0, 0, 0))
	add_theme_color_override("font_hover_color", Color(0, 0, 0, 0))
	add_theme_color_override("font_pressed_color", Color(0, 0, 0, 0))
	add_theme_color_override("font_disabled_color", Color(0, 0, 0, 0))
	name_label.add_theme_color_override("font_color", name_color)
	type_label.add_theme_color_override("font_color", Color(0.84, 0.84, 0.78, 1.0))
	if str(card.get("center_text", "")) != "":
		body_label.add_theme_color_override("font_color", name_color)
	else:
		body_label.add_theme_color_override("font_color", Color(0.94, 0.92, 0.84, 1.0))
	ownership_label.add_theme_color_override("font_color", Color(0.84, 0.86, 0.78, 1.0))
	divider.color = border.darkened(0.10)
	score_divider.color = border.darkened(0.10)
	score_title_label.add_theme_color_override("font_color", Color(0.86, 0.84, 0.76, 1.0))
	score_value_label.add_theme_color_override("font_color", name_color)

func _make_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 4
	return style
