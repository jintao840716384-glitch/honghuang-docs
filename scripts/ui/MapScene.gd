extends Control

signal battle_node_selected(node_data: Dictionary)

const AudioManagerScript = preload("res://scripts/audio/AudioManager.gd")

var run_state
var audio_manager: Node
var map_area: Control
var connection_layer: Control
var node_layer: Control
var title_label: Label
var status_label: Label
var deck_label: Label
var node_positions: Dictionary = {}

func _ready() -> void:
	_build_scene()
	audio_manager = AudioManagerScript.new()
	add_child(audio_manager)
	if run_state != null:
		call_deferred("_render_map")

func setup(state) -> void:
	run_state = state
	if is_inside_tree():
		call_deferred("_render_map")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_inside_tree():
		call_deferred("_render_map")

func _build_scene() -> void:
	var background := ColorRect.new()
	background.color = Color(0.035, 0.040, 0.045, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var header := HBoxContainer.new()
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 42.0
	header.offset_top = 24.0
	header.offset_right = -42.0
	header.offset_bottom = 72.0
	header.add_theme_constant_override("separation", 18)
	add_child(header)

	title_label = Label.new()
	title_label.text = "探索地图"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	header.add_child(title_label)

	deck_label = Label.new()
	deck_label.custom_minimum_size = Vector2(160.0, 34.0)
	deck_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	deck_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	deck_label.add_theme_font_size_override("font_size", 16)
	deck_label.add_theme_color_override("font_color", Color(0.80, 0.84, 0.88, 1.0))
	header.add_child(deck_label)

	status_label = Label.new()
	status_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	status_label.offset_left = 42.0
	status_label.offset_top = -72.0
	status_label.offset_right = -42.0
	status_label.offset_bottom = -24.0
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color(0.78, 0.82, 0.86, 1.0))
	add_child(status_label)

	map_area = Control.new()
	map_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_area.offset_left = 100.0
	map_area.offset_top = 92.0
	map_area.offset_right = -100.0
	map_area.offset_bottom = -96.0
	map_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(map_area)

	connection_layer = Control.new()
	connection_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	connection_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_area.add_child(connection_layer)

	node_layer = Control.new()
	node_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	node_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_area.add_child(node_layer)

func _render_map() -> void:
	if run_state == null or map_area == null:
		return
	if map_area.size.x <= 1.0 or map_area.size.y <= 1.0:
		call_deferred("_render_map")
		return

	_clear_children(connection_layer)
	_clear_children(node_layer)
	node_positions.clear()

	title_label.text = "探索地图  /  %s" % run_state.job_name
	deck_label.text = "卡组 %d" % run_state.deck_ids.size()
	status_label.text = "选择一个发亮节点进入战斗"
	if run_state.is_complete():
		status_label.text = "本层探索完成"

	var max_floor: int = _max_floor()
	var lane_spacing: float = min(240.0, map_area.size.x / 5.4)
	for node in run_state.map_nodes:
		var floor := int(node.get("floor", 0))
		var lane := float(node.get("lane", 0.0))
		var progress: float = 0.0 if max_floor <= 0 else float(floor) / float(max_floor)
		var x: float = map_area.size.x * 0.5 + lane * lane_spacing
		var y: float = lerpf(map_area.size.y - 70.0, 60.0, progress)
		node_positions[str(node.get("id", ""))] = Vector2(x, y)

	_draw_connections()
	_create_node_buttons()

func _draw_connections() -> void:
	for node in run_state.map_nodes:
		var from_id := str(node.get("id", ""))
		var from_position: Vector2 = node_positions.get(from_id, Vector2.ZERO)
		for next_id_variant in node.get("next", []):
			var next_id := str(next_id_variant)
			if not node_positions.has(next_id):
				continue
			var line := Line2D.new()
			line.width = 4.0
			line.default_color = _connection_color(from_id, next_id)
			line.points = PackedVector2Array([from_position, node_positions[next_id]])
			connection_layer.add_child(line)

func _create_node_buttons() -> void:
	var available_ids: Dictionary = run_state.available_node_ids()
	for node in run_state.map_nodes:
		var id := str(node.get("id", ""))
		var completed: bool = run_state.is_node_completed(id)
		var available: bool = available_ids.has(id)
		var button := Button.new()
		button.custom_minimum_size = Vector2(78.0, 58.0)
		button.size = button.custom_minimum_size
		var position: Vector2 = node_positions.get(id, Vector2.ZERO)
		button.position = Vector2(position.x - button.size.x * 0.5, position.y - button.size.y * 0.5)
		button.text = "已胜" if completed else str(node.get("title", "战斗"))
		button.disabled = not available
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 15)
		_style_node_button(button, str(node.get("type", "normal")), available, completed)
		if available:
			button.pressed.connect(_on_node_pressed.bind(node))
		node_layer.add_child(button)

func _on_node_pressed(node: Dictionary) -> void:
	_play_audio("ui_confirm")
	battle_node_selected.emit(node.duplicate(true))

func _connection_color(from_id: String, next_id: String) -> Color:
	if run_state.is_node_completed(from_id):
		return Color(0.78, 0.64, 0.34, 0.82)
	if run_state.is_node_available(next_id):
		return Color(0.46, 0.62, 0.86, 0.70)
	return Color(0.22, 0.25, 0.30, 0.62)

func _style_node_button(button: Button, node_type: String, available: bool, completed: bool) -> void:
	var bg := Color(0.09, 0.105, 0.12, 0.96)
	var border := Color(0.42, 0.48, 0.56, 1.0)
	if node_type == "elite":
		bg = Color(0.15, 0.10, 0.17, 0.96)
		border = Color(0.78, 0.45, 0.86, 1.0)
	elif node_type == "boss":
		bg = Color(0.18, 0.08, 0.06, 0.96)
		border = Color(0.92, 0.55, 0.30, 1.0)
	elif available:
		bg = Color(0.08, 0.13, 0.16, 0.96)
		border = Color(0.46, 0.72, 0.92, 1.0)
	if completed:
		bg = Color(0.12, 0.12, 0.09, 0.96)
		border = Color(0.76, 0.62, 0.32, 1.0)
	button.add_theme_stylebox_override("normal", _panel_style(bg, border, 8, 2))
	button.add_theme_stylebox_override("hover", _panel_style(bg.lightened(0.10), border.lightened(0.16), 8, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(bg.darkened(0.05), border.lightened(0.22), 8, 2))
	button.add_theme_stylebox_override("disabled", _panel_style(bg.darkened(0.25), border.darkened(0.35), 8, 1))
	button.add_theme_color_override("font_color", Color(0.94, 0.92, 0.86, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.54, 0.57, 0.60, 1.0))

func _max_floor() -> int:
	var result := 0
	for node in run_state.map_nodes:
		result = max(result, int(node.get("floor", 0)))
	return result

func _play_audio(event_name: String) -> void:
	if audio_manager != null and audio_manager.has_method("play_event"):
		audio_manager.call("play_event", event_name)

func _panel_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
