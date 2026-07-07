extends PanelContainer
class_name BattleDebugTools

signal add_enemy_requested
signal add_ally_requested
signal clear_extra_enemies_requested
signal damage_target_requested(amount: int)
signal heal_target_requested(amount: int)
signal modify_target_attack_requested(amount: int)
signal modify_target_defense_requested(amount: int)

func _ready() -> void:
	name = "BattleDebugTools"
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(176, 0)
	_build_layout()
	_apply_style()

func _build_layout() -> void:
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	add_child(layout)

	var title := Label.new()
	title.text = "测试工具"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)

	var enemy_row := HBoxContainer.new()
	enemy_row.add_theme_constant_override("separation", 6)
	layout.add_child(enemy_row)
	enemy_row.add_child(_make_button("+敌人", add_enemy_requested.emit))
	enemy_row.add_child(_make_button("+友军", add_ally_requested.emit))

	var clear_row := HBoxContainer.new()
	clear_row.add_theme_constant_override("separation", 6)
	layout.add_child(clear_row)
	clear_row.add_child(_make_button("清多余", clear_extra_enemies_requested.emit))

	var hp_row := HBoxContainer.new()
	hp_row.add_theme_constant_override("separation", 6)
	layout.add_child(hp_row)
	hp_row.add_child(_make_button("目标-5", func() -> void:
		damage_target_requested.emit(5)
	))
	hp_row.add_child(_make_button("目标+5", func() -> void:
		heal_target_requested.emit(5)
	))

	var stat_row := HBoxContainer.new()
	stat_row.add_theme_constant_override("separation", 6)
	layout.add_child(stat_row)
	stat_row.add_child(_make_button("攻-1", func() -> void:
		modify_target_attack_requested.emit(-1)
	))
	stat_row.add_child(_make_button("攻+1", func() -> void:
		modify_target_attack_requested.emit(1)
	))

	var defense_row := HBoxContainer.new()
	defense_row.add_theme_constant_override("separation", 6)
	layout.add_child(defense_row)
	defense_row.add_child(_make_button("防-1", func() -> void:
		modify_target_defense_requested.emit(-1)
	))
	defense_row.add_child(_make_button("防+1", func() -> void:
		modify_target_defense_requested.emit(1)
	))

func _make_button(label_text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label_text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(76, 30)
	button.pressed.connect(callback)
	return button

func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.045, 0.052, 0.056, 0.92)
	style.border_color = Color(0.62, 0.52, 0.28, 0.92)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	add_theme_stylebox_override("panel", style)
