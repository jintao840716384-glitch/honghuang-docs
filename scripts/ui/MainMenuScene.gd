extends Control

signal start_requested
signal quit_requested
signal settings_changed(settings)

const AudioManagerScript = preload("res://scripts/audio/AudioManager.gd")
const UIStyleFactoryScript = preload("res://scripts/ui/UIStyleFactory.gd")
const GameSettingsScript = preload("res://scripts/settings/GameSettings.gd")
const SettingsStoreScript = preload("res://scripts/settings/SettingsStore.gd")
const DisplayModeManagerScript = preload("res://scripts/settings/DisplayModeManager.gd")
const InputActionDatabaseScript = preload("res://scripts/settings/InputActionDatabase.gd")
const InputSettingsScript = preload("res://scripts/settings/InputSettings.gd")
const LocalizationDatabaseScript = preload("res://scripts/localization/LocalizationDatabase.gd")
const LocalizationServiceScript = preload("res://scripts/localization/LocalizationService.gd")

var audio_manager: Node
var title_label: Label
var subtitle_label: Label
var start_button: Button
var settings_button: Button
var quit_button: Button
var settings_panel: PanelContainer
var game_tab_button: Button
var keys_tab_button: Button
var game_page_scroll: ScrollContainer
var keys_page_scroll: ScrollContainer
var general_section_label: Label
var audio_section_label: Label
var display_section_label: Label
var controls_section_label: Label
var language_setting_label: Label
var resolution_setting_label: Label
var window_mode_setting_label: Label
var master_volume_label: Label
var music_volume_label: Label
var sfx_volume_label: Label
var master_volume_slider: HSlider
var music_volume_slider: HSlider
var sfx_volume_slider: HSlider
var resolution_option: OptionButton
var window_mode_option: OptionButton
var vsync_checkbox: CheckBox
var language_option: OptionButton
var input_category_labels: Dictionary = {}
var input_action_labels: Dictionary = {}
var input_binding_buttons: Dictionary = {}
var input_reset_buttons: Dictionary = {}
var settings_confirm_button: Button
var settings_cancel_button: Button
var settings_default_button: Button
var current_settings: Dictionary = {}
var settings_open_snapshot: Dictionary = {}
var active_settings_tab := "game"
var rebinding_action_id := ""
var suppress_setting_signals := false

const SETTINGS_TAB_GAME := "game"
const SETTINGS_TAB_KEYS := "keys"

func _ready() -> void:
	current_settings = SettingsStoreScript.load_settings()
	_build_scene()
	audio_manager = AudioManagerScript.new()
	add_child(audio_manager)
	_apply_audio_settings(current_settings)

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

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 44)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	root.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 18)
	subtitle_label.add_theme_color_override("font_color", Color(0.72, 0.76, 0.80, 1.0))
	root.add_child(subtitle_label)

	var spacer_top := Control.new()
	spacer_top.custom_minimum_size = Vector2(1.0, 66.0)
	root.add_child(spacer_top)

	var button_column := VBoxContainer.new()
	button_column.alignment = BoxContainer.ALIGNMENT_CENTER
	button_column.add_theme_constant_override("separation", 12)
	root.add_child(button_column)

	start_button = _make_menu_button("")
	start_button.pressed.connect(_on_start_pressed)
	button_column.add_child(start_button)

	settings_button = _make_menu_button("")
	settings_button.pressed.connect(_on_settings_pressed)
	button_column.add_child(settings_button)

	quit_button = _make_menu_button("")
	quit_button.pressed.connect(_on_quit_pressed)
	button_column.add_child(quit_button)

	_build_settings_panel(root)
	_refresh_localized_text()

	var tail := Control.new()
	tail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tail)

func _build_settings_panel(root: VBoxContainer) -> void:
	settings_panel = PanelContainer.new()
	settings_panel.visible = false
	settings_panel.custom_minimum_size = Vector2(700.0, 500.0)
	settings_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	settings_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.07, 0.075, 0.98), Color(0.42, 0.46, 0.52, 1.0), 8, 1))
	root.add_child(settings_panel)

	var panel_layout := VBoxContainer.new()
	panel_layout.add_theme_constant_override("separation", 10)
	panel_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_panel.add_child(panel_layout)

	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 8)
	panel_layout.add_child(tab_row)

	game_tab_button = _make_tab_button("")
	game_tab_button.pressed.connect(_set_settings_tab.bind(SETTINGS_TAB_GAME))
	tab_row.add_child(game_tab_button)

	keys_tab_button = _make_tab_button("")
	keys_tab_button.pressed.connect(_set_settings_tab.bind(SETTINGS_TAB_KEYS))
	tab_row.add_child(keys_tab_button)

	game_page_scroll = _make_settings_scroll()
	panel_layout.add_child(game_page_scroll)

	keys_page_scroll = _make_settings_scroll()
	keys_page_scroll.visible = false
	panel_layout.add_child(keys_page_scroll)

	var game_settings_layout := VBoxContainer.new()
	game_settings_layout.add_theme_constant_override("separation", 8)
	game_settings_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	game_page_scroll.add_child(game_settings_layout)

	var key_settings_layout := VBoxContainer.new()
	key_settings_layout.add_theme_constant_override("separation", 8)
	key_settings_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	keys_page_scroll.add_child(key_settings_layout)

	general_section_label = _add_section_label(game_settings_layout, "")
	language_option = OptionButton.new()
	_populate_language_options()
	language_setting_label = _make_setting_label("")
	_add_setting_row(game_settings_layout, language_setting_label, language_option)
	language_option.item_selected.connect(_on_language_selected)

	audio_section_label = _add_section_label(game_settings_layout, "")
	master_volume_label = _make_setting_label("")
	master_volume_slider = _make_volume_slider(_current_audio_volume("master_volume", GameSettingsScript.DEFAULT_MASTER_VOLUME))
	_add_setting_row(game_settings_layout, master_volume_label, master_volume_slider)
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	master_volume_slider.drag_ended.connect(_on_volume_drag_ended.bind("master_volume"))

	music_volume_label = _make_setting_label("")
	music_volume_slider = _make_volume_slider(_current_audio_volume("music_volume", GameSettingsScript.DEFAULT_MUSIC_VOLUME))
	_add_setting_row(game_settings_layout, music_volume_label, music_volume_slider)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	music_volume_slider.drag_ended.connect(_on_volume_drag_ended.bind("music_volume"))

	sfx_volume_label = _make_setting_label("")
	sfx_volume_slider = _make_volume_slider(_current_audio_volume("sfx_volume", GameSettingsScript.DEFAULT_SFX_VOLUME))
	_add_setting_row(game_settings_layout, sfx_volume_label, sfx_volume_slider)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	sfx_volume_slider.drag_ended.connect(_on_volume_drag_ended.bind("sfx_volume"))

	display_section_label = _add_section_label(game_settings_layout, "")
	resolution_option = OptionButton.new()
	_populate_resolution_options()
	resolution_setting_label = _make_setting_label("")
	_add_setting_row(game_settings_layout, resolution_setting_label, resolution_option)
	resolution_option.item_selected.connect(_on_resolution_selected)

	window_mode_option = OptionButton.new()
	_populate_window_mode_options()
	window_mode_setting_label = _make_setting_label("")
	_add_setting_row(game_settings_layout, window_mode_setting_label, window_mode_option)
	window_mode_option.item_selected.connect(_on_window_mode_selected)

	vsync_checkbox = CheckBox.new()
	vsync_checkbox.button_pressed = bool(GameSettingsScript.display_settings(current_settings).get("vsync_enabled", true))
	vsync_checkbox.toggled.connect(_on_vsync_toggled)
	game_settings_layout.add_child(vsync_checkbox)

	_build_input_settings(key_settings_layout)

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	action_row.add_theme_constant_override("separation", 10)
	panel_layout.add_child(action_row)

	settings_default_button = _make_small_button("")
	settings_default_button.custom_minimum_size = Vector2(92.0, 36.0)
	settings_default_button.pressed.connect(_on_settings_default_pressed)
	action_row.add_child(settings_default_button)

	settings_cancel_button = _make_small_button("")
	settings_cancel_button.custom_minimum_size = Vector2(92.0, 36.0)
	settings_cancel_button.pressed.connect(_on_settings_cancel_pressed)
	action_row.add_child(settings_cancel_button)

	settings_confirm_button = _make_small_button("")
	settings_confirm_button.custom_minimum_size = Vector2(92.0, 36.0)
	settings_confirm_button.pressed.connect(_on_settings_confirm_pressed)
	action_row.add_child(settings_confirm_button)

	_set_settings_tab(SETTINGS_TAB_GAME)
	_update_volume_labels()

func _build_input_settings(settings_layout: VBoxContainer) -> void:
	controls_section_label = null
	input_category_labels.clear()
	input_action_labels.clear()
	input_binding_buttons.clear()
	input_reset_buttons.clear()
	for category_variant in InputActionDatabaseScript.categories_for_settings():
		var category_id := str(category_variant)
		var category_label := _add_section_label(settings_layout, "")
		category_label.add_theme_font_size_override("font_size", 14)
		input_category_labels[category_id] = category_label
		for definition_variant in InputActionDatabaseScript.actions_for_category(category_id):
			var definition: Dictionary = definition_variant
			var action_id := str(definition.get("id", ""))
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 10)
			settings_layout.add_child(row)

			var action_label := _make_setting_label("")
			action_label.custom_minimum_size = Vector2(230.0, 1.0)
			row.add_child(action_label)
			input_action_labels[action_id] = action_label

			var binding_button := _make_small_button("")
			binding_button.custom_minimum_size = Vector2(130.0, 32.0)
			binding_button.pressed.connect(_on_rebind_action_pressed.bind(action_id))
			row.add_child(binding_button)
			input_binding_buttons[action_id] = binding_button

			var reset_button := _make_small_button("")
			reset_button.custom_minimum_size = Vector2(86.0, 32.0)
			reset_button.pressed.connect(_on_reset_action_binding_pressed.bind(action_id))
			row.add_child(reset_button)
			input_reset_buttons[action_id] = reset_button

func _make_menu_button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(220.0, 48.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 18)
	_style_button(button, Color(0.09, 0.10, 0.11, 0.96), Color(0.50, 0.55, 0.62, 1.0))
	return button

func _make_tab_button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(110.0, 36.0)
	button.add_theme_font_size_override("font_size", 16)
	_style_button(button, Color(0.085, 0.095, 0.105, 0.96), Color(0.42, 0.47, 0.54, 1.0))
	return button

func _make_small_button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 14)
	_style_button(button, Color(0.085, 0.095, 0.105, 0.96), Color(0.42, 0.47, 0.54, 1.0))
	return button

func _make_settings_scroll() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(660.0, 390.0)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return scroll

func _make_setting_label(label_text: String) -> Label:
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(150.0, 1.0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.90, 0.91, 0.86, 1.0))
	return label

func _make_volume_slider(value: float) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = clamp(value, 0.0, 1.0)
	slider.custom_minimum_size = Vector2(320.0, 28.0)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return slider

func _add_section_label(parent: VBoxContainer, label_text: String) -> Label:
	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	parent.add_child(label)
	return label

func _add_setting_row(parent: VBoxContainer, label: Label, control: Control) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)

func _populate_resolution_options() -> void:
	var display: Dictionary = GameSettingsScript.display_settings(current_settings)
	var current_resolution_id := str(display.get("resolution_id", GameSettingsScript.DEFAULT_RESOLUTION_ID))
	var selected_index := 0
	var resolutions: Array = DisplayModeManagerScript.supported_resolutions()
	for i in range(resolutions.size()):
		var definition: Dictionary = resolutions[i]
		var resolution_id := str(definition.get("id", ""))
		var item_text := "%s  %sx%s" % [str(definition.get("label", resolution_id)), int(definition.get("width", 0)), int(definition.get("height", 0))]
		resolution_option.add_item(item_text)
		resolution_option.set_item_metadata(i, resolution_id)
		if resolution_id == current_resolution_id:
			selected_index = i
	resolution_option.select(selected_index)

func _populate_window_mode_options() -> void:
	var display: Dictionary = GameSettingsScript.display_settings(current_settings)
	var current_mode := str(display.get("window_mode", GameSettingsScript.DEFAULT_WINDOW_MODE))
	var modes := [
		{"id": GameSettingsScript.WINDOW_MODE_WINDOWED, "text_id": "settings.windowed"},
		{"id": GameSettingsScript.WINDOW_MODE_FULLSCREEN, "text_id": "settings.fullscreen"},
		{"id": GameSettingsScript.WINDOW_MODE_BORDERLESS_FULLSCREEN, "text_id": "settings.borderless_fullscreen"}
	]
	var selected_index := 0
	for i in range(modes.size()):
		var mode: Dictionary = modes[i]
		window_mode_option.add_item(_text(str(mode.get("text_id", ""))))
		window_mode_option.set_item_metadata(i, str(mode.get("id", "")))
		if str(mode.get("id", "")) == current_mode:
			selected_index = i
	window_mode_option.select(selected_index)

func _populate_language_options() -> void:
	var localization: Dictionary = GameSettingsScript.localization_settings(current_settings)
	var current_language_id := str(localization.get("language_id", GameSettingsScript.DEFAULT_LANGUAGE_ID))
	var selected_index := 0
	var language_ids: Array = LocalizationDatabaseScript.language_ids()
	for i in range(language_ids.size()):
		var language_id := str(language_ids[i])
		var definition: Dictionary = LocalizationDatabaseScript.language_definition(language_id)
		language_option.add_item(str(definition.get("native_name", language_id)))
		language_option.set_item_metadata(i, language_id)
		if language_id == current_language_id:
			selected_index = i
	language_option.select(selected_index)

func _on_start_pressed() -> void:
	_play_audio("ui_confirm")
	start_requested.emit()

func _on_settings_pressed() -> void:
	if settings_panel.visible:
		_on_settings_cancel_pressed()
		return
	_play_audio("ui_click")
	_open_settings_panel()

func _open_settings_panel() -> void:
	settings_open_snapshot = current_settings.duplicate(true)
	rebinding_action_id = ""
	_refresh_setting_controls_from_current()
	_set_settings_tab(SETTINGS_TAB_GAME)
	settings_panel.visible = true

func _set_settings_tab(tab_id: String) -> void:
	active_settings_tab = tab_id
	var game_selected := active_settings_tab == SETTINGS_TAB_GAME
	if game_page_scroll != null:
		game_page_scroll.visible = game_selected
	if keys_page_scroll != null:
		keys_page_scroll.visible = not game_selected
	if game_tab_button != null:
		game_tab_button.button_pressed = game_selected
	if keys_tab_button != null:
		keys_tab_button.button_pressed = not game_selected

func _on_quit_pressed() -> void:
	_play_audio("ui_click")
	quit_requested.emit()

func _on_master_volume_changed(value: float) -> void:
	if suppress_setting_signals:
		return
	_set_audio_volume("master_volume", value)

func _on_music_volume_changed(value: float) -> void:
	if suppress_setting_signals:
		return
	_set_audio_volume("music_volume", value)

func _on_sfx_volume_changed(value: float) -> void:
	if suppress_setting_signals:
		return
	_set_audio_volume("sfx_volume", value)

func _on_volume_drag_ended(value_changed: bool, _volume_key: String) -> void:
	if suppress_setting_signals or not value_changed:
		return
	_play_audio("ui_confirm")

func _on_rebind_action_pressed(action_id: String) -> void:
	rebinding_action_id = action_id
	_refresh_binding_labels()

func _on_reset_action_binding_pressed(action_id: String) -> void:
	if suppress_setting_signals:
		return
	current_settings = SettingsStoreScript.reset_action_binding(current_settings, action_id)
	_apply_preview_settings()
	_refresh_binding_labels()

func _on_language_selected(index: int) -> void:
	if suppress_setting_signals:
		return
	var language_id := str(language_option.get_item_metadata(index))
	current_settings = SettingsStoreScript.set_language_id(current_settings, language_id)
	_apply_preview_settings()
	_refresh_localized_text()

func _on_resolution_selected(index: int) -> void:
	if suppress_setting_signals:
		return
	var resolution_id := str(resolution_option.get_item_metadata(index))
	var display: Dictionary = GameSettingsScript.display_settings(current_settings)
	current_settings = SettingsStoreScript.set_display_mode(current_settings, resolution_id, str(display.get("window_mode", GameSettingsScript.DEFAULT_WINDOW_MODE)))
	_apply_preview_settings()

func _on_window_mode_selected(index: int) -> void:
	if suppress_setting_signals:
		return
	var window_mode := str(window_mode_option.get_item_metadata(index))
	var display: Dictionary = GameSettingsScript.display_settings(current_settings)
	current_settings = SettingsStoreScript.set_display_mode(current_settings, str(display.get("resolution_id", GameSettingsScript.DEFAULT_RESOLUTION_ID)), window_mode)
	_apply_preview_settings()

func _on_vsync_toggled(enabled: bool) -> void:
	if suppress_setting_signals:
		return
	var display: Dictionary = GameSettingsScript.display_settings(current_settings)
	display["vsync_enabled"] = enabled
	current_settings["display"] = display
	_apply_preview_settings()

func _set_audio_volume(volume_key: String, value: float) -> void:
	current_settings = SettingsStoreScript.set_audio_volume(current_settings, volume_key, value)
	_apply_preview_settings()
	_apply_audio_settings(current_settings)
	_update_volume_labels()

func _on_settings_confirm_pressed() -> void:
	_play_audio("ui_confirm")
	current_settings = GameSettingsScript.sanitize(current_settings)
	SettingsStoreScript.save_settings(current_settings)
	settings_open_snapshot = current_settings.duplicate(true)
	_apply_preview_settings()
	settings_panel.visible = false

func _on_settings_cancel_pressed() -> void:
	_play_audio("ui_click")
	if not settings_open_snapshot.is_empty():
		current_settings = GameSettingsScript.sanitize(settings_open_snapshot.duplicate(true))
	rebinding_action_id = ""
	_apply_preview_settings()
	_refresh_setting_controls_from_current()
	settings_panel.visible = false

func _on_settings_default_pressed() -> void:
	_play_audio("ui_click")
	var defaults: Dictionary = SettingsStoreScript.default_settings()
	var next_settings: Dictionary = current_settings.duplicate(true)
	if active_settings_tab == SETTINGS_TAB_KEYS:
		next_settings["input"] = (defaults.get("input", {}) as Dictionary).duplicate(true)
	else:
		next_settings["localization"] = (defaults.get("localization", {}) as Dictionary).duplicate(true)
		next_settings["audio"] = (defaults.get("audio", {}) as Dictionary).duplicate(true)
		next_settings["display"] = (defaults.get("display", {}) as Dictionary).duplicate(true)
	current_settings = GameSettingsScript.sanitize(next_settings)
	rebinding_action_id = ""
	_apply_preview_settings()
	_refresh_setting_controls_from_current()

func _input(event: InputEvent) -> void:
	if rebinding_action_id == "":
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		var event_spec: Dictionary = InputActionDatabaseScript.spec_from_event(key_event)
		if event_spec.is_empty():
			return
		current_settings = SettingsStoreScript.set_action_binding(current_settings, rebinding_action_id, event_spec)
		rebinding_action_id = ""
		_apply_preview_settings()
		_refresh_binding_labels()
		get_viewport().set_input_as_handled()

func _apply_preview_settings() -> void:
	current_settings = GameSettingsScript.sanitize(current_settings)
	_apply_audio_settings(current_settings)
	settings_changed.emit(current_settings.duplicate(true))

func _refresh_setting_controls_from_current() -> void:
	suppress_setting_signals = true
	var display: Dictionary = GameSettingsScript.display_settings(current_settings)
	var audio: Dictionary = GameSettingsScript.audio_settings(current_settings)
	var localization: Dictionary = GameSettingsScript.localization_settings(current_settings)
	_select_option_by_metadata(language_option, str(localization.get("language_id", GameSettingsScript.DEFAULT_LANGUAGE_ID)))
	_select_option_by_metadata(resolution_option, str(display.get("resolution_id", GameSettingsScript.DEFAULT_RESOLUTION_ID)))
	_select_option_by_metadata(window_mode_option, str(display.get("window_mode", GameSettingsScript.DEFAULT_WINDOW_MODE)))
	if vsync_checkbox != null:
		vsync_checkbox.button_pressed = bool(display.get("vsync_enabled", true))
	if master_volume_slider != null:
		master_volume_slider.value = float(audio.get("master_volume", GameSettingsScript.DEFAULT_MASTER_VOLUME))
	if music_volume_slider != null:
		music_volume_slider.value = float(audio.get("music_volume", GameSettingsScript.DEFAULT_MUSIC_VOLUME))
	if sfx_volume_slider != null:
		sfx_volume_slider.value = float(audio.get("sfx_volume", GameSettingsScript.DEFAULT_SFX_VOLUME))
	suppress_setting_signals = false
	_refresh_localized_text()

func _select_option_by_metadata(option: OptionButton, metadata: String) -> void:
	if option == null:
		return
	for i in range(option.get_item_count()):
		if str(option.get_item_metadata(i)) == metadata:
			option.select(i)
			return

func _current_audio_volume(volume_key: String, fallback: float) -> float:
	var audio: Dictionary = GameSettingsScript.audio_settings(current_settings)
	return clamp(float(audio.get(volume_key, fallback)), 0.0, 1.0)

func _apply_audio_settings(settings: Dictionary) -> void:
	var audio: Dictionary = GameSettingsScript.audio_settings(settings)
	_apply_master_volume(float(audio.get("master_volume", GameSettingsScript.DEFAULT_MASTER_VOLUME)))
	if audio_manager != null and audio_manager.has_method("set_sfx_volume"):
		audio_manager.call("set_sfx_volume", float(audio.get("sfx_volume", GameSettingsScript.DEFAULT_SFX_VOLUME)))

func _apply_master_volume(value: float) -> void:
	var bus: int = AudioServer.get_bus_index("Master")
	if bus < 0:
		return
	var normalized: float = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_mute(bus, normalized <= 0.001)
	if normalized > 0.001:
		AudioServer.set_bus_volume_db(bus, linear_to_db(normalized))

func _update_volume_labels() -> void:
	if master_volume_label != null and master_volume_slider != null:
		master_volume_label.text = _text("settings.master_volume", {"percent": int(round(master_volume_slider.value * 100.0))})
	if music_volume_label != null and music_volume_slider != null:
		music_volume_label.text = _text("settings.music_volume", {"percent": int(round(music_volume_slider.value * 100.0))})
	if sfx_volume_label != null and sfx_volume_slider != null:
		sfx_volume_label.text = _text("settings.sfx_volume", {"percent": int(round(sfx_volume_slider.value * 100.0))})

func _refresh_binding_labels() -> void:
	for action_id_variant in input_binding_buttons.keys():
		var action_id := str(action_id_variant)
		var button := input_binding_buttons.get(action_id, null) as Button
		if button == null:
			continue
		if action_id == rebinding_action_id:
			button.text = _text("settings.waiting_key")
		else:
			button.text = InputSettingsScript.binding_label_for_action(current_settings, action_id)

func _refresh_localized_text() -> void:
	if title_label != null:
		title_label.text = _text("app.title")
	if subtitle_label != null:
		subtitle_label.text = _text("app.subtitle")
	if start_button != null:
		start_button.text = _text("menu.start_game")
	if settings_button != null:
		settings_button.text = _text("menu.settings")
	if quit_button != null:
		quit_button.text = _text("menu.quit")
	if game_tab_button != null:
		game_tab_button.text = _text("settings.tab_game")
	if keys_tab_button != null:
		keys_tab_button.text = _text("settings.tab_keys")
	if general_section_label != null:
		general_section_label.text = _text("settings.general")
	if audio_section_label != null:
		audio_section_label.text = _text("settings.audio")
	if display_section_label != null:
		display_section_label.text = _text("settings.display")
	if controls_section_label != null:
		controls_section_label.text = _text("settings.controls")
	for category_id_variant in input_category_labels.keys():
		var category_id := str(category_id_variant)
		var label := input_category_labels.get(category_id, null) as Label
		if label != null:
			label.text = _input_category_text(category_id)
	for action_id_variant in input_action_labels.keys():
		var action_id := str(action_id_variant)
		var label := input_action_labels.get(action_id, null) as Label
		if label != null:
			label.text = _text(InputActionDatabaseScript.action_text_id(action_id))
	for action_id_variant in input_reset_buttons.keys():
		var action_id := str(action_id_variant)
		var button := input_reset_buttons.get(action_id, null) as Button
		if button != null:
			button.text = _text("settings.reset_binding")
	if language_setting_label != null:
		language_setting_label.text = _text("settings.language")
	if resolution_setting_label != null:
		resolution_setting_label.text = _text("settings.resolution")
	if window_mode_setting_label != null:
		window_mode_setting_label.text = _text("settings.window_mode")
	if vsync_checkbox != null:
		vsync_checkbox.text = _text("settings.vsync")
	if settings_default_button != null:
		settings_default_button.text = _text("settings.default")
	if settings_cancel_button != null:
		settings_cancel_button.text = _text("settings.cancel")
	if settings_confirm_button != null:
		settings_confirm_button.text = _text("settings.confirm")
	_refresh_window_mode_labels()
	_update_volume_labels()
	_refresh_binding_labels()

func _refresh_window_mode_labels() -> void:
	if window_mode_option == null:
		return
	for i in range(window_mode_option.get_item_count()):
		var mode_id := str(window_mode_option.get_item_metadata(i))
		match mode_id:
			GameSettingsScript.WINDOW_MODE_FULLSCREEN:
				window_mode_option.set_item_text(i, _text("settings.fullscreen"))
			GameSettingsScript.WINDOW_MODE_BORDERLESS_FULLSCREEN:
				window_mode_option.set_item_text(i, _text("settings.borderless_fullscreen"))
			_:
				window_mode_option.set_item_text(i, _text("settings.windowed"))

func _text(text_id: String, params: Dictionary = {}) -> String:
	return LocalizationServiceScript.text_for_settings(text_id, current_settings, params)

func _input_category_text(category_id: String) -> String:
	match category_id:
		InputActionDatabaseScript.CATEGORY_MENU:
			return _text("settings.input_menu")
		InputActionDatabaseScript.CATEGORY_BATTLE:
			return _text("settings.input_battle")
		InputActionDatabaseScript.CATEGORY_CARD_SHORTCUT:
			return _text("settings.input_card_shortcut")
	return category_id

func _play_audio(event_name: String) -> void:
	if audio_manager != null and audio_manager.has_method("play_event"):
		audio_manager.call("play_event", event_name)

func _style_button(button: Button, bg: Color, border: Color) -> void:
	UIStyleFactoryScript.apply_button_style(button, bg, border, 7, 1, 2, 2, Vector4(12, 12, 10, 10), 0, 0.14, 0.06, 0.18)

func _panel_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	return UIStyleFactoryScript.panel_style(bg, border, radius, border_width, Vector4(12, 12, 10, 10))
