extends PanelContainer
class_name ResponsePanel

const CardButtonScene = preload("res://scenes/CardButton.tscn")

signal response_selected(uid: String)
signal skipped
signal card_hovered(card: Dictionary, anchor_position: Vector2)
signal card_unhovered

@onready var event_label: Label = get_node("ResponseLayout/EventLabel") as Label
@onready var chain_label: Label = get_node("ResponseLayout/ChainLabel") as Label
@onready var response_container: HBoxContainer = get_node("ResponseLayout/ResponseScroll/ResponseContainer") as HBoxContainer
@onready var skip_button: Button = get_node("ResponseLayout/SkipButton") as Button

func _ready() -> void:
	skip_button.pressed.connect(func() -> void: skipped.emit())
	_apply_style()

func setup(event_text: String, chain_stack: Array, responses: Array) -> void:
	event_label.text = "当前事件：%s" % event_text
	chain_label.text = _chain_text(chain_stack)
	_clear_children(response_container)
	for card in responses:
		var button: CardButton = CardButtonScene.instantiate()
		button.setup(card, "发动")
		button.card_pressed.connect(func(uid := str(card.get("uid", ""))) -> void:
			response_selected.emit(uid)
		)
		button.card_hovered.connect(func(hover_card: Dictionary, anchor_position: Vector2) -> void:
			card_hovered.emit(hover_card, anchor_position)
		)
		button.card_unhovered.connect(func() -> void:
			card_unhovered.emit()
		)
		response_container.add_child(button)

func _chain_text(chain_stack: Array) -> String:
	if chain_stack.is_empty():
		return "当前连锁：无"
	var lines := ["当前连锁："]
	for i in range(chain_stack.size()):
		lines.append("%d. %s" % [i + 1, chain_stack[i].get("name", "")])
	lines.append("结算时从最后发动的牌开始。")
	return "\n".join(lines)

func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.045, 0.05, 0.06, 0.96)
	style.border_color = Color(0.54, 0.62, 0.82, 1.0)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	add_theme_stylebox_override("panel", style)
	event_label.add_theme_font_size_override("font_size", 16)
	event_label.add_theme_color_override("font_color", Color(0.92, 0.94, 1.0, 1.0))
	chain_label.add_theme_color_override("font_color", Color(0.84, 0.86, 0.90, 1.0))

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
