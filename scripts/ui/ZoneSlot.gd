extends Control
class_name ZoneSlot

signal slot_hovered(card: Dictionary, anchor_position: Vector2)
signal slot_unhovered
signal slot_pressed(card: Dictionary, anchor_position: Vector2)

const DEFAULT_SLOT_SIZE := Vector2(70, 84)
const GLOW_MARGIN_RATIO := 0.18
const MIN_GLOW_MARGIN := 8.0

var card_data: Dictionary = {}
var occupied := false
var face_down := false
var response_available := false
var response_selected := false
var drop_available := false
var drop_selected := false
var glow_tween: Tween
var pulse_tween: Tween
var glow_base_alpha := 0.42
var glow_peak_alpha := 0.72
var glow_base_scale := 0.94
var glow_peak_scale := 1.12
var pulse_alpha := 0.86
var pulse_scale := 1.20

@onready var glow_layer: Control = get_node("GlowLayer") as Control
@onready var glow_outer: Panel = get_node("GlowLayer/GlowOuter") as Panel
@onready var glow_middle: Panel = get_node("GlowLayer/GlowMiddle") as Panel
@onready var glow_inner: Panel = get_node("GlowLayer/GlowInner") as Panel
@onready var card_panel: PanelContainer = get_node("CardPanel") as PanelContainer
@onready var card_label: Label = get_node("CardPanel/CardLabel") as Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	resized.connect(_sync_visual_layout)
	_ensure_nodes()
	_sync_visual_layout()
	call_deferred("_sync_visual_layout")

func _get_minimum_size() -> Vector2:
	if custom_minimum_size != Vector2.ZERO:
		return custom_minimum_size
	return DEFAULT_SLOT_SIZE

func setup(card: Dictionary = {}) -> void:
	_ensure_nodes()
	card_data = card.duplicate(true) if not card.is_empty() else {}
	occupied = not card.is_empty()
	face_down = bool(card.get("face_down", false)) if occupied else false
	response_available = false
	response_selected = false
	drop_available = false
	drop_selected = false
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = DEFAULT_SLOT_SIZE
	if card.is_empty():
		card_label.text = ""
		tooltip_text = ""
		_apply_style()
		_sync_response_glow()
		call_deferred("_sync_visual_layout")
		return
	if face_down:
		card_label.text = "卡背"
	else:
		card_label.text = _zone_card_label(card)
	tooltip_text = ""
	_apply_style()
	_sync_response_glow()
	call_deferred("_sync_visual_layout")

func _zone_card_label(card: Dictionary) -> String:
	var lines: Array = [str(card.get("name", "卡牌"))]
	var markers: Array = []
	if card.has("zone_countdown"):
		markers.append("倒%d" % int(card.get("zone_countdown", 0)))
	if card.has("zone_uses_remaining"):
		markers.append("余%d" % int(card.get("zone_uses_remaining", 0)))
	var attached_cards: Array = card.get("attached_cards", [])
	var attached_count: int = attached_cards.size()
	if attached_count > 0:
		markers.append("压%d" % attached_count)
	if not markers.is_empty():
		lines.append(" / ".join(markers))
	return "\n".join(lines)

func set_response_available(available: bool, selected: bool = false) -> void:
	response_available = available and occupied
	response_selected = selected and response_available
	_apply_style()
	_sync_response_glow()

func set_drop_available(available: bool, selected: bool = false) -> void:
	drop_available = available
	drop_selected = selected and drop_available
	_apply_style()
	_sync_response_glow()

func flash() -> void:
	pulse_glow()

func pulse_glow(color := Color(1.0, 0.92, 0.62, 1.0)) -> void:
	_ensure_nodes()
	if pulse_tween != null and pulse_tween.is_running():
		pulse_tween.kill()
	if glow_tween != null and glow_tween.is_running():
		glow_tween.kill()
	_apply_glow_styles(color)
	glow_layer.visible = true
	_set_pulse_phase(0.0)
	pulse_tween = create_tween()
	pulse_tween.tween_method(Callable(self, "_set_pulse_phase"), 0.0, 1.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	pulse_tween.tween_method(Callable(self, "_set_pulse_phase"), 1.0, 0.0, 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	pulse_tween.finished.connect(func() -> void:
		if response_available:
			_sync_response_glow()
		else:
			glow_layer.visible = false
			glow_layer.modulate.a = 0.0
			glow_layer.scale = Vector2.ONE
	)

func _on_mouse_entered() -> void:
	if not card_data.is_empty():
		slot_hovered.emit(card_data, global_position + Vector2(size.x, 0.0))

func _on_mouse_exited() -> void:
	slot_unhovered.emit()

func _gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	if card_data.is_empty():
		return
	accept_event()
	slot_pressed.emit(card_data, global_position + Vector2(size.x + 6.0, size.y * 0.5))

func _apply_style() -> void:
	_ensure_nodes()
	var style := StyleBoxFlat.new()
	if not occupied:
		style.bg_color = Color(0.08, 0.09, 0.10, 0.26)
		style.border_color = Color(0.64, 0.69, 0.78, 0.46)
	elif face_down:
		style.bg_color = Color(0.06, 0.10, 0.22, 1.0)
		style.border_color = Color(0.42, 0.62, 1.0, 1.0)
	elif str(card_data.get("after_use", "")) == "equipment":
		style.bg_color = Color(0.09, 0.22, 0.16, 1.0)
		style.border_color = Color(0.40, 0.82, 0.52, 1.0)
	else:
		style.bg_color = Color(0.18, 0.17, 0.13, 1.0)
		style.border_color = Color(0.84, 0.72, 0.42, 1.0)
	if response_available:
		style.border_color = Color(1.0, 0.92, 0.58, 1.0) if response_selected else Color(0.78, 0.86, 1.0, 1.0)
	elif drop_available:
		style.border_color = Color(1.0, 0.94, 0.62, 1.0) if drop_selected else Color(0.88, 0.94, 1.0, 1.0)
	style.set_border_width_all(3 if response_available or drop_available else 2)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	card_panel.add_theme_stylebox_override("panel", style)
	card_label.add_theme_color_override("font_color", Color(0.90, 0.90, 0.86, 1.0))
	card_label.add_theme_font_size_override("font_size", 13)

func _sync_response_glow() -> void:
	_ensure_nodes()
	if glow_tween != null and glow_tween.is_running():
		glow_tween.kill()
	if not response_available and not drop_available:
		glow_layer.visible = false
		glow_layer.modulate.a = 0.0
		glow_layer.scale = Vector2.ONE
		return
	var glow_color := Color(1.0, 0.88, 0.48, 1.0) if response_selected else Color(0.74, 0.86, 1.0, 1.0)
	if drop_available and not response_available:
		glow_color = Color(1.0, 0.94, 0.62, 1.0) if drop_selected else Color(0.88, 0.94, 1.0, 1.0)
	_apply_glow_styles(glow_color)
	glow_base_alpha = 0.54 if response_selected or drop_selected else 0.36
	glow_peak_alpha = 0.90 if response_selected or drop_selected else 0.66
	glow_base_scale = 0.94
	glow_peak_scale = 1.15 if response_selected or drop_selected else 1.10
	glow_layer.visible = true
	_set_glow_phase(0.0)
	glow_tween = create_tween()
	glow_tween.set_loops()
	glow_tween.tween_method(Callable(self, "_set_glow_phase"), 0.0, 1.0, 0.62).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	glow_tween.tween_method(Callable(self, "_set_glow_phase"), 1.0, 0.0, 0.62).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _ensure_nodes() -> void:
	if glow_layer == null and has_node("GlowLayer"):
		glow_layer = get_node("GlowLayer") as Control
	if glow_outer == null and has_node("GlowLayer/GlowOuter"):
		glow_outer = get_node("GlowLayer/GlowOuter") as Panel
	if glow_middle == null and has_node("GlowLayer/GlowMiddle"):
		glow_middle = get_node("GlowLayer/GlowMiddle") as Panel
	if glow_inner == null and has_node("GlowLayer/GlowInner"):
		glow_inner = get_node("GlowLayer/GlowInner") as Panel
	if card_panel == null and has_node("CardPanel"):
		card_panel = get_node("CardPanel") as PanelContainer
	if card_label == null and has_node("CardPanel/CardLabel"):
		card_label = get_node("CardPanel/CardLabel") as Label

func _sync_visual_layout() -> void:
	_ensure_nodes()
	var card_size := size
	if card_size.x <= 0.0 or card_size.y <= 0.0:
		card_size = custom_minimum_size
	if card_size.x <= 0.0 or card_size.y <= 0.0:
		card_size = DEFAULT_SLOT_SIZE
	var margin: float = max(MIN_GLOW_MARGIN, min(card_size.x, card_size.y) * GLOW_MARGIN_RATIO)
	card_panel.position = Vector2.ZERO
	card_panel.size = card_size
	glow_layer.position = Vector2(-margin, -margin)
	glow_layer.size = card_size + Vector2(margin * 2.0, margin * 2.0)
	glow_layer.pivot_offset = glow_layer.size * 0.5
	_layout_glow_panel(glow_outer, Vector2.ZERO, glow_layer.size)
	_layout_glow_panel(glow_middle, Vector2(margin * 0.34, margin * 0.34), glow_layer.size - Vector2(margin * 0.68, margin * 0.68))
	_layout_glow_panel(glow_inner, Vector2(margin * 0.70, margin * 0.70), glow_layer.size - Vector2(margin * 1.40, margin * 1.40))

func _layout_glow_panel(panel: Panel, panel_position: Vector2, panel_size: Vector2) -> void:
	if panel == null:
		return
	panel.position = panel_position
	panel.size = panel_size

func _apply_glow_styles(color: Color) -> void:
	_apply_single_glow_style(glow_outer, color, 0.16, 1, 14)
	_apply_single_glow_style(glow_middle, color.lightened(0.12), 0.28, 2, 10)
	_apply_single_glow_style(glow_inner, Color(1.0, 1.0, 1.0, 1.0).lerp(color, 0.30), 0.34, 2, 5)

func _apply_single_glow_style(panel: Panel, color: Color, alpha: float, border_width: int, shadow_size: int) -> void:
	if panel == null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, alpha * 0.14)
	style.border_color = Color(color.r, color.g, color.b, alpha)
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 9
	style.corner_radius_top_right = 9
	style.corner_radius_bottom_left = 9
	style.corner_radius_bottom_right = 9
	style.shadow_color = Color(color.r, color.g, color.b, alpha * 0.42)
	style.shadow_size = shadow_size
	panel.add_theme_stylebox_override("panel", style)

func _set_glow_phase(value: float) -> void:
	glow_layer.scale = Vector2.ONE * lerpf(glow_base_scale, glow_peak_scale, value)
	glow_layer.modulate = Color(1.0, 1.0, 1.0, lerpf(glow_base_alpha, glow_peak_alpha, value))

func _set_pulse_phase(value: float) -> void:
	glow_layer.scale = Vector2.ONE * lerpf(0.90, pulse_scale, value)
	glow_layer.modulate = Color(1.0, 1.0, 1.0, lerpf(0.0, pulse_alpha, value))
