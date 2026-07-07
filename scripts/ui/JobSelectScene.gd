extends Control

signal job_selected(job_id: String)
signal back_requested

const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const MetaProgressionScript = preload("res://scripts/data/MetaProgression.gd")
const AudioManagerScript = preload("res://scripts/audio/AudioManager.gd")
const UIStyleFactoryScript = preload("res://scripts/ui/UIStyleFactory.gd")
const CharacterVisualDatabaseScript = preload("res://scripts/assets/CharacterVisualDatabase.gd")

var selected_job_id := "sword"
var job_buttons: Dictionary = {}
var confirm_button: Button
var audio_manager: Node
var progression

func _ready() -> void:
	progression = MetaProgressionScript.new()
	progression.load()
	_build_scene()
	audio_manager = AudioManagerScript.new()
	add_child(audio_manager)
	_select_job(selected_job_id)

func _build_scene() -> void:
	var background := ColorRect.new()
	background.color = Color(0.035, 0.040, 0.045, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 58.0
	root.offset_top = 38.0
	root.offset_right = -58.0
	root.offset_bottom = -42.0
	root.add_theme_constant_override("separation", 18)
	add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	root.add_child(header)

	var back_button := Button.new()
	back_button.text = "返回"
	back_button.custom_minimum_size = Vector2(84.0, 36.0)
	back_button.pressed.connect(_on_back_pressed)
	_style_button(back_button, Color(0.08, 0.09, 0.10, 0.96), Color(0.40, 0.44, 0.50, 1.0))
	header.add_child(back_button)

	var title := Label.new()
	title.text = "选择角色"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	header.add_child(title)

	var header_spacer := Control.new()
	header_spacer.custom_minimum_size = Vector2(120.0, 36.0)
	header.add_child(header_spacer)

	var job_row := HBoxContainer.new()
	job_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	job_row.alignment = BoxContainer.ALIGNMENT_CENTER
	job_row.add_theme_constant_override("separation", 22)
	root.add_child(job_row)

	for job in JobDatabaseScript.all_jobs():
		var job_id := str(job.get("id", ""))
		var button := _create_job_card(job)
		button.pressed.connect(_on_job_card_pressed.bind(job_id))
		job_buttons[job_id] = button
		job_row.add_child(button)

	confirm_button = Button.new()
	confirm_button.text = "确认角色"
	confirm_button.custom_minimum_size = Vector2(180.0, 44.0)
	confirm_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	confirm_button.pressed.connect(_on_confirm_pressed)
	_style_button(confirm_button, Color(0.18, 0.12, 0.06, 0.96), Color(0.88, 0.62, 0.30, 1.0))
	root.add_child(confirm_button)

func _create_job_card(job: Dictionary) -> Button:
	var button := Button.new()
	button.text = ""
	button.custom_minimum_size = Vector2(300.0, 420.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.focus_mode = Control.FOCUS_NONE

	var layout := VBoxContainer.new()
	layout.name = "CardLayout"
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	layout.offset_left = 18.0
	layout.offset_top = 18.0
	layout.offset_right = -18.0
	layout.offset_bottom = -18.0
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_theme_constant_override("separation", 10)
	button.add_child(layout)

	var name_label := Label.new()
	name_label.text = str(job.get("name", ""))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.66, 1.0))
	layout.add_child(name_label)

	var stat_label := Label.new()
	stat_label.name = "StatLabel"
	stat_label.text = _job_stat_text(job)
	stat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stat_label.add_theme_font_size_override("font_size", 15)
	stat_label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.90, 1.0))
	layout.add_child(stat_label)

	var progress_label := Label.new()
	progress_label.name = "ProgressLabel"
	progress_label.text = _job_progress_text(str(job.get("id", "")))
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_font_size_override("font_size", 14)
	progress_label.add_theme_color_override("font_color", Color(0.72, 0.84, 0.74, 1.0))
	layout.add_child(progress_label)

	var portrait := Panel.new()
	portrait.custom_minimum_size = Vector2(1.0, 170.0)
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait.add_theme_stylebox_override("panel", _panel_style(_portrait_color(str(job.get("id", ""))), Color(0.50, 0.56, 0.62, 1.0), 8, 1))
	layout.add_child(portrait)

	var portrait_label := Label.new()
	portrait_label.text = str(job.get("name", ""))
	portrait_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	portrait_label.add_theme_font_size_override("font_size", 22)
	portrait_label.add_theme_color_override("font_color", Color(0.88, 0.91, 0.94, 1.0))
	portrait.add_child(portrait_label)

	var desc_label := Label.new()
	desc_label.text = str(job.get("description", ""))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.86, 0.84, 0.78, 1.0))
	layout.add_child(desc_label)

	return button

func _job_stat_text(job: Dictionary) -> String:
	var job_id := str(job.get("id", ""))
	var bonuses: Dictionary = progression.bonuses_for_job(job_id) if progression != null else {}
	var max_hp: int = int(job.get("max_hp", 0)) + int(bonuses.get("max_hp", 0))
	var attack: int = int(job.get("attack", 0)) + int(bonuses.get("attack", 0))
	var defense: int = int(job.get("defense", 0)) + int(bonuses.get("defense", 0))
	var deck_score_bonus: int = int(bonuses.get("deck_score_limit", 0))
	return "生命 %d    攻 %d / 防 %d    总分 +%d" % [max_hp, attack, defense, deck_score_bonus]

func _job_progress_text(job_id: String) -> String:
	if progression == null:
		return "修为点 0"
	return "修为点 %d / 累计 %d" % [progression.points_available(job_id), progression.points_total(job_id)]

func _on_job_card_pressed(job_id: String) -> void:
	_play_audio("ui_click")
	_select_job(job_id)

func _on_confirm_pressed() -> void:
	_play_audio("ui_confirm")
	job_selected.emit(selected_job_id)

func _on_back_pressed() -> void:
	_play_audio("ui_click")
	back_requested.emit()

func _select_job(job_id: String) -> void:
	selected_job_id = job_id
	for id in job_buttons.keys():
		var button := job_buttons[id] as Button
		var selected := str(id) == selected_job_id
		var bg := Color(0.08, 0.09, 0.10, 0.96)
		var border := Color(0.40, 0.46, 0.54, 1.0)
		if selected:
			bg = Color(0.14, 0.11, 0.07, 0.98)
			border = Color(0.92, 0.67, 0.34, 1.0)
		_style_button(button, bg, border)

func _portrait_color(job_id: String) -> Color:
	var job: Dictionary = JobDatabaseScript.get_job(job_id)
	if job.is_empty():
		return Color(0.14, 0.14, 0.18, 1.0)
	var profile: Dictionary = CharacterVisualDatabaseScript.profile_for_unit_data(job)
	return profile.get("placeholder_color", Color(0.14, 0.14, 0.18, 1.0)) as Color

func _play_audio(event_name: String) -> void:
	if audio_manager != null and audio_manager.has_method("play_event"):
		audio_manager.call("play_event", event_name)

func _style_button(button: Button, bg: Color, border: Color) -> void:
	UIStyleFactoryScript.apply_button_style(button, bg, border, 8, 2, 2, 2, Vector4(10, 10, 8, 8), 0, 0.14, 0.05, 0.18)

func _panel_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	return UIStyleFactoryScript.panel_style(bg, border, radius, border_width, Vector4(10, 10, 8, 8))
