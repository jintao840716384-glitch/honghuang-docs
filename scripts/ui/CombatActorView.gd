extends PanelContainer
class_name CombatActorView

const FloatingTextScene = preload("res://scenes/FloatingText.tscn")
const FLOATING_TEXT_STEP_GAP := 0.28

@onready var name_label: Label = get_node("ActorLayout/NameLabel") as Label
@onready var hp_bar: ProgressBar = get_node("ActorLayout/HpBar") as ProgressBar
@onready var hp_label: Label = get_node("ActorLayout/HpBar/HpLabel") as Label
@onready var portrait_box: PanelContainer = get_node("ActorLayout/PortraitBox") as PanelContainer
@onready var portrait_label: Label = get_node("ActorLayout/PortraitBox/PortraitLabel") as Label
@onready var stat_label: Label = get_node("ActorLayout/StatLabel") as Label
@onready var extra_label: Label = get_node("ActorLayout/ExtraLabel") as Label
@onready var intent_label: Label = get_node("ActorLayout/IntentLabel") as Label

var base_position := Vector2.ZERO
var selected := false
var combat_highlight_mode := ""
var drop_available := false
var drop_selected := false
var floating_text_queue: Array = []
var floating_text_active := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	base_position = position
	_make_descendants_click_through(self)
	_apply_actor_style()

func setup_actor(actor_name: String, portrait_text: String, hp: int, max_hp: int, attack: int, defense: int, extra := "", intent := "") -> void:
	name_label.text = actor_name
	portrait_label.text = portrait_text
	hp_bar.max_value = max(1, max_hp)
	hp_bar.value = clamp(hp, 0, max_hp)
	hp_label.text = "%d / %d" % [hp, max_hp]
	stat_label.text = "攻 %d / 防 %d" % [attack, defense]
	extra_label.text = extra
	extra_label.visible = extra != ""
	intent_label.text = intent
	intent_label.visible = intent != ""

func set_selected(active: bool) -> void:
	selected = active
	if is_inside_tree():
		_apply_actor_style()

func set_combat_highlight(mode: String) -> void:
	combat_highlight_mode = mode
	if is_inside_tree():
		_apply_actor_style()

func set_drop_available(available: bool, hovered: bool = false) -> void:
	drop_available = available
	drop_selected = available and hovered
	if is_inside_tree():
		_apply_actor_style()

func play_attack(direction: int) -> void:
	base_position = position
	var tween := create_tween()
	tween.tween_property(self, "position:x", base_position.x + direction * 38.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:x", base_position.x, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func play_hit() -> void:
	var start := position
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1.0, 0.34, 0.34, 1.0), 0.08)
	tween.tween_property(self, "position:x", start.x + 10.0, 0.05)
	tween.chain().tween_property(self, "position:x", start.x - 10.0, 0.05)
	tween.chain().tween_property(self, "position:x", start.x, 0.06)
	tween.chain().tween_property(self, "modulate", Color.WHITE, 0.12)

func show_floating_text(display_text: String, color: Color) -> void:
	floating_text_queue.append({"text": display_text, "color": color})
	call_deferred("_play_floating_text_queue")

func _play_floating_text_queue() -> void:
	if floating_text_active:
		return
	if not is_inside_tree():
		return
	floating_text_active = true
	while not floating_text_queue.is_empty():
		if not is_inside_tree():
			floating_text_active = false
			return
		var entry: Dictionary = floating_text_queue.pop_front()
		var display_color: Color = entry.get("color", Color.WHITE)
		_spawn_floating_text(str(entry.get("text", "")), display_color)
		if not is_inside_tree():
			floating_text_active = false
			return
		await get_tree().create_timer(FLOATING_TEXT_STEP_GAP).timeout
	floating_text_active = false

func _spawn_floating_text(display_text: String, color: Color) -> void:
	var floating_text: Label = FloatingTextScene.instantiate()
	portrait_box.add_child(floating_text)
	floating_text.position = Vector2(max(20.0, portrait_box.size.x * 0.5), 4.0)
	floating_text.setup(display_text, color)

func _apply_actor_style() -> void:
	var border := Color(0.32, 0.36, 0.42, 0.42)
	var border_width := 1
	if combat_highlight_mode == "source":
		border = Color(1.0, 0.24, 0.20, 1.0)
		border_width = 4
	elif combat_highlight_mode == "target":
		border = Color(0.98, 0.76, 0.28, 1.0)
		border_width = 4
	elif drop_selected:
		border = Color(1.0, 0.94, 0.62, 1.0)
		border_width = 4
	elif drop_available:
		border = Color(0.88, 0.94, 1.0, 1.0)
		border_width = 3
	elif selected:
		border = Color(0.98, 0.76, 0.28, 1.0)
		border_width = 3
	add_theme_stylebox_override("panel", _make_style(Color(0.08, 0.09, 0.10, 0.34), border, border_width, 8))
	portrait_box.add_theme_stylebox_override("panel", _make_style(Color(0.13, 0.15, 0.18, 1.0), Color(0.54, 0.58, 0.66, 1.0), 2, 8))
	hp_bar.add_theme_stylebox_override("background", _make_style(Color(0.15, 0.05, 0.05, 1.0), Color(0.34, 0.18, 0.18, 1.0), 1, 5))
	hp_bar.add_theme_stylebox_override("fill", _make_style(Color(0.78, 0.08, 0.08, 1.0), Color(0.95, 0.26, 0.20, 1.0), 0, 5))
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", Color(0.96, 0.94, 0.88, 1.0))
	portrait_label.add_theme_font_size_override("font_size", 18)
	portrait_label.add_theme_color_override("font_color", Color(0.68, 0.70, 0.76, 1.0))
	hp_label.add_theme_font_size_override("font_size", 13)
	hp_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.90, 1.0))
	stat_label.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82, 1.0))
	extra_label.add_theme_color_override("font_color", Color(0.56, 0.78, 1.0, 1.0))
	intent_label.add_theme_color_override("font_color", Color(1.0, 0.74, 0.36, 1.0))

func _make_descendants_click_through(node: Node) -> void:
	for child in node.get_children():
		var child_control: Control = child as Control
		if child_control != null:
			child_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_make_descendants_click_through(child)

func _make_style(bg: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style
