extends Control

signal start_requested
signal quit_requested

const AudioManagerScript = preload("res://scripts/audio/AudioManager.gd")

var audio_manager: Node
var settings_panel: PanelContainer
var volume_label: Label
var volume_slider: HSlider

func _ready() -> void:
	_build_scene()
	audio_manager = AudioManagerScript.new()
	add_child(audio_manager)

func _build_scene() -> void:
	var background := ColorRect.new()
	background.color = Color(0.035, 0.040, 0.045, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 92.0
	root.offset_top = 72.0
	root.offset_right = -92.0
	root.offset_bottom = -72.0
	root.add_theme_constant_override("separation", 18)
	add_child(root)

	var title := Label.new()
	title.text = "太玄宗"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	root.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "卡牌战斗原型"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.72, 0.76, 0.80, 1.0))
	root.add_child(subtitle)

	var spacer_top := Control.new()
	spacer_top.custom_minimum_size = Vector2(1.0, 70.0)
	root.add_child(spacer_top)

	var button_column := VBoxContainer.new()
	button_column.alignment = BoxContainer.ALIGNMENT_CENTER
	button_column.add_theme_constant_override("separation", 12)
	root.add_child(button_column)

	var start_button := _make_menu_button("开始游戏")
	start_button.pressed.connect(_on_start_pressed)
	button_column.add_child(start_button)

	var settings_button := _make_menu_button("设置")
	settings_button.pressed.connect(_on_settings_pressed)
	button_column.add_child(settings_button)

	var quit_button := _make_menu_button("离开游戏")
	quit_button.pressed.connect(_on_quit_pressed)
	button_column.add_child(quit_button)

	settings_panel = PanelContainer.new()
	settings_panel.visible = false
	settings_panel.custom_minimum_size = Vector2(420.0, 96.0)
	settings_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	settings_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.07, 0.075, 0.98), Color(0.42, 0.46, 0.52, 1.0), 8, 1))
	root.add_child(settings_panel)

	var settings_layout := VBoxContainer.new()
	settings_layout.add_theme_constant_override("separation", 8)
	settings_panel.add_child(settings_layout)

	volume_label = Label.new()
	volume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	volume_label.add_theme_color_override("font_color", Color(0.90, 0.91, 0.86, 1.0))
	settings_layout.add_child(volume_label)

	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.value = _current_master_volume()
	volume_slider.custom_minimum_size = Vector2(360.0, 28.0)
	volume_slider.value_changed.connect(_on_volume_changed)
	settings_layout.add_child(volume_slider)
	_update_volume_label()

	var tail := Control.new()
	tail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tail)

func _make_menu_button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(220.0, 48.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 18)
	_style_button(button, Color(0.09, 0.10, 0.11, 0.96), Color(0.50, 0.55, 0.62, 1.0))
	return button

func _on_start_pressed() -> void:
	_play_audio("ui_confirm")
	start_requested.emit()

func _on_settings_pressed() -> void:
	_play_audio("ui_click")
	settings_panel.visible = not settings_panel.visible

func _on_quit_pressed() -> void:
	_play_audio("ui_click")
	quit_requested.emit()

func _on_volume_changed(value: float) -> void:
	_apply_master_volume(float(value))
	_update_volume_label()

func _current_master_volume() -> float:
	var bus: int = AudioServer.get_bus_index("Master")
	if bus < 0 or AudioServer.is_bus_mute(bus):
		return 0.0
	return clamp(db_to_linear(AudioServer.get_bus_volume_db(bus)), 0.0, 1.0)

func _apply_master_volume(value: float) -> void:
	var bus: int = AudioServer.get_bus_index("Master")
	if bus < 0:
		return
	var normalized: float = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_mute(bus, normalized <= 0.001)
	if normalized > 0.001:
		AudioServer.set_bus_volume_db(bus, linear_to_db(normalized))

func _update_volume_label() -> void:
	if volume_label != null and volume_slider != null:
		volume_label.text = "音效音量  %d%%" % int(round(volume_slider.value * 100.0))

func _play_audio(event_name: String) -> void:
	if audio_manager != null and audio_manager.has_method("play_event"):
		audio_manager.call("play_event", event_name)

func _style_button(button: Button, bg: Color, border: Color) -> void:
	button.add_theme_stylebox_override("normal", _panel_style(bg, border, 7, 1))
	button.add_theme_stylebox_override("hover", _panel_style(bg.lightened(0.08), border.lightened(0.14), 7, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(bg.darkened(0.06), border.lightened(0.18), 7, 2))
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
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style
