extends PanelContainer
class_name CardPileViewer

const CardButtonScene = preload("res://scenes/ui/CardButton.tscn")

signal viewer_closed

@onready var title_label: Label = get_node("ViewerLayout/HeaderRow/TitleLabel") as Label
@onready var close_button: Button = get_node("ViewerLayout/HeaderRow/CloseButton") as Button
@onready var card_container: GridContainer = get_node("ViewerLayout/CardScroll/CardContainer") as GridContainer

func _ready() -> void:
	close_button.pressed.connect(close)
	_apply_style()

func open(title: String, cards: Array) -> void:
	title_label.text = "%s（%d 张）" % [title, cards.size()]
	_clear_children(card_container)
	if cards.is_empty():
		var label := Label.new()
		label.text = "空"
		label.add_theme_color_override("font_color", Color(0.90, 0.88, 0.80, 1.0))
		card_container.add_child(label)
	else:
		for card in cards:
			if not (card is Dictionary):
				continue
			var button: CardButton = CardButtonScene.instantiate()
			button.setup(card)
			button.hover_details_enabled = false
			button.hover_motion_enabled = false
			card_container.add_child(button)
	visible = true
	await get_tree().process_frame
	_center_on_screen()

func close() -> void:
	visible = false
	viewer_closed.emit()

func _center_on_screen() -> void:
	var viewport_size := get_viewport_rect().size
	global_position = (viewport_size - size) * 0.5

func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.045, 0.05, 0.058, 0.97)
	style.border_color = Color(0.50, 0.55, 0.64, 1.0)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 14
	add_theme_stylebox_override("panel", style)
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82, 1.0))

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
