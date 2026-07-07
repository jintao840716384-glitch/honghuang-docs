extends RefCounted
class_name DeckBuilderViewFactory

const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const CardButtonScene = preload("res://scenes/CardButton.tscn")

static func create_column(column_title: String, container_name: String, panel_style: StyleBox, with_scroll := true) -> Dictionary:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", panel_style)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	panel.add_child(layout)

	var title := Label.new()
	title.text = column_title
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.94, 0.90, 0.78, 1.0))
	layout.add_child(title)

	var container := GridContainer.new()
	if container_name != "":
		container.name = container_name
	container.columns = 3
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("h_separation", 10)
	container.add_theme_constant_override("v_separation", 10)
	if with_scroll:
		var scroll := ScrollContainer.new()
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		layout.add_child(scroll)
		scroll.add_child(container)
	else:
		layout.add_child(container)

	return {"panel": panel, "title": title, "container": container}

static func add_builder_card(parent: GridContainer, card_id: String, prefix: String, pressed_callback: Callable) -> bool:
	var card: Dictionary = CardDatabaseScript.get_card(card_id)
	if card.is_empty():
		return false
	var button: CardButton = CardButtonScene.instantiate()
	button.build_cost_display_enabled = true
	button.setup(card, prefix)
	button.hover_details_enabled = false
	button.hover_motion_enabled = false
	button.card_pressed.connect(pressed_callback)
	parent.add_child(button)
	return true
