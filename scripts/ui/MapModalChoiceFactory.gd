extends RefCounted
class_name MapModalChoiceFactory

const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const UIStyleFactoryScript = preload("res://scripts/ui/UIStyleFactory.gd")
const CardButtonScene = preload("res://scenes/ui/CardButton.tscn")

static func create_card_grid(parent: Control, columns := 3) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	parent.add_child(grid)
	return grid

static func add_card_choice(parent: Control, card_id: String, prefix: String, callback: Callable, disabled := false, action_text := "选择此卡") -> bool:
	var card: Dictionary = CardDatabaseScript.get_card(card_id)
	if card.is_empty():
		return false
	var card_callback: Callable = Callable()
	if callback.is_valid():
		card_callback = func() -> void:
			callback.call(card_id)
	return add_card_data_choice(parent, card, prefix, card_callback, disabled, action_text, true)

static func add_card_data_choice(parent: Control, card: Dictionary, prefix: String, callback: Callable, disabled := false, action_text := "选择此卡", show_score := true) -> bool:
	var slot := VBoxContainer.new()
	slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	slot.add_theme_constant_override("separation", 8)
	parent.add_child(slot)

	var button: CardButton = CardButtonScene.instantiate()
	button.build_cost_display_enabled = show_score
	button.hover_details_enabled = false
	button.hover_motion_enabled = false
	button.disabled = disabled
	button.setup(card, prefix)
	if callback.is_valid():
		button.card_pressed.connect(func(_uid: String) -> void:
			callback.call()
		)
	slot.add_child(button)
	slot.add_child(make_modal_button(action_text, callback, disabled))
	return true

static func add_reward_choice(parent: Control, title: String, category: String, description: String, prefix: String, callback: Callable, disabled := false, action_text := "收下", center_text := "") -> bool:
	var reward_card := reward_card_data(title, category, description, center_text)
	return add_card_data_choice(parent, reward_card, prefix, callback, disabled, action_text, false)

static func reward_card_data(title: String, category: String, description: String, center_text := "") -> Dictionary:
	return {
		"id": title,
		"name": title,
		"type": "奖励",
		"tags": [category],
		"description": description,
		"center_text": center_text,
		"build_cost": 0
	}

static func make_modal_button(label_text: String, callback: Callable, disabled := false) -> Button:
	var button := Button.new()
	button.text = label_text
	button.focus_mode = Control.FOCUS_NONE
	button.disabled = disabled
	button.custom_minimum_size = Vector2(0.0, 38.0)
	if callback.is_valid():
		button.pressed.connect(callback)
	UIStyleFactoryScript.apply_button_style(
		button,
		Color(0.10, 0.12, 0.12, 1.0),
		Color(0.62, 0.70, 0.58, 1.0),
		6,
		1,
		2,
		2,
		Vector4(10, 10, 8, 8),
		0,
		0.12,
		0.06,
		0.18
	)
	return button
