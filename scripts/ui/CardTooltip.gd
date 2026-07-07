extends PanelContainer
class_name CardTooltip

const CardDisplayRulesScript = preload("res://scripts/ui/CardDisplayRules.gd")
const TOOLTIP_SIZE := Vector2(280, 190)

var show_request_id := 0

@onready var name_label: Label = get_node("TooltipLayout/NameLabel") as Label
@onready var type_label: Label = get_node("TooltipLayout/TypeLabel") as Label
@onready var tags_label: Label = get_node("TooltipLayout/TagsLabel") as Label
@onready var trigger_label: Label = get_node("TooltipLayout/TriggerLabel") as Label
@onready var description_label: Label = get_node("TooltipLayout/DescriptionLabel") as Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = TOOLTIP_SIZE
	size = TOOLTIP_SIZE
	_apply_style()

func show_card(card: Dictionary, anchor_position: Vector2) -> void:
	show_request_id += 1
	var request_id := show_request_id
	if card.is_empty():
		hide_tooltip()
		return
	visible = false
	custom_minimum_size = TOOLTIP_SIZE
	size = TOOLTIP_SIZE
	name_label.text = "卡名：%s" % card.get("name", "卡牌")
	type_label.text = "类型：%s" % _type_text(card)
	tags_label.text = "标签：%s" % _tags_text(card)
	trigger_label.text = "分数：%d / 触发：%s" % [CardDisplayRulesScript.card_score(card), _trigger_text(card)]
	description_label.text = "效果：%s" % _short_description(card)
	size = TOOLTIP_SIZE
	await get_tree().process_frame
	if request_id != show_request_id:
		return
	size = TOOLTIP_SIZE
	var target := anchor_position + Vector2(14, 10)
	var viewport_size := get_viewport_rect().size
	target.x = clamp(target.x, 12.0, max(12.0, viewport_size.x - TOOLTIP_SIZE.x - 12.0))
	target.y = clamp(target.y, 12.0, max(12.0, viewport_size.y - TOOLTIP_SIZE.y - 12.0))
	global_position = target
	visible = true

func hide_tooltip() -> void:
	show_request_id += 1
	visible = false

func _type_text(card: Dictionary) -> String:
	return CardDisplayRulesScript.card_type_label(card)

func _tags_text(card: Dictionary) -> String:
	return CardDisplayRulesScript.tags_text(card)

func _trigger_text(card: Dictionary) -> String:
	return CardDisplayRulesScript.trigger_text(card)

func _trigger_label(trigger: String) -> String:
	return CardDisplayRulesScript.trigger_label(trigger)

func _short_description(card: Dictionary) -> String:
	var description := str(card.get("description", ""))
	if description.length() <= 70:
		return description
	return description.substr(0, 70) + "..."

func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.06, 0.07, 0.96)
	style.border_color = Color(0.78, 0.70, 0.46, 1.0)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	add_theme_stylebox_override("panel", style)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.64, 1.0))
	for label in [type_label, tags_label, trigger_label, description_label]:
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.92, 0.90, 0.82, 1.0))
