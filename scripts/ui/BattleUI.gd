extends Control

signal map_battle_completed(deck_ids: Array, reserve_ids: Array, player_hp: int, player_max_hp: int)
signal run_abandoned

const BattleManagerScript = preload("res://scripts/battle/BattleManager.gd")
const BattleViewModelScript = preload("res://scripts/battle/BattleViewModel.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const CardButtonScene = preload("res://scenes/ui/CardButton.tscn")
const ZoneSlotScene = preload("res://scenes/battle/ZoneSlot.tscn")
const CombatActorViewScene = preload("res://scenes/battle/CombatActorView.tscn")
const BattleDebugToolsScript = preload("res://scripts/ui/BattleDebugTools.gd")
const AudioManagerScript = preload("res://scripts/audio/AudioManager.gd")
const CardInteractionRulesScript = preload("res://scripts/ui/CardInteractionRules.gd")
const BattleAudioRouterScript = preload("res://scripts/ui/BattleAudioRouter.gd")
const CardDisplayRulesScript = preload("res://scripts/ui/CardDisplayRules.gd")
const UIStyleFactoryScript = preload("res://scripts/ui/UIStyleFactory.gd")
const BattleFloatingTextRulesScript = preload("res://scripts/ui/BattleFloatingTextRules.gd")
const CharacterVisualDatabaseScript = preload("res://scripts/assets/CharacterVisualDatabase.gd")
const LocalizationServiceScript = preload("res://scripts/localization/LocalizationService.gd")

const ACTOR_BASE_SIZE := Vector2(238, 286)
const ACTOR_SIDE_SCALE := 0.72
const HAND_CARD_SIZE := Vector2(225, 315)
const HAND_NORMAL_GAP := 12.0
const HAND_MAX_WIDTH_RATIO := 0.68
const HAND_MAX_WIDTH := 1280.0
const HAND_Z_BASE := 100
const EQUIPMENT_CARD_SIZE := Vector2(52, 66)
const EQUIPMENT_NORMAL_GAP := 6.0
const EQUIPMENT_Z_BASE := 80
const UNIT_EQUIPMENT_SLOT_SIZE := Vector2(52, 66)
const UNIT_EQUIPMENT_GAP := 6.0
const CARD_DRAG_START_THRESHOLD := 10.0
const VISUAL_STEP_GAP := 0.04
const DRAW_AFTER_TURN_BANNER_GAP := 0.14
const DEBUG_TOOLS_ENABLED := false

var manager
var highlighted_slot_uid := ""
var highlighted_equipment_uid := ""
var log_expanded := false
var log_tween: Tween
var audio_manager: Node
var victory_audio_battle := -1
var equipment_replace_uids: Dictionary = {}
var selected_equipment_uid := ""
var fx_layer: Control
var turn_banner_layer: Control
var turn_banner_panel: Panel
var turn_banner_label: Label
var turn_banner_tween: Tween
var turn_banner_active := false
var draw_fx_queue: Array = []
var draw_fx_active := false
var hidden_draw_uids: Dictionary = {}
var result_preview_label: Label
var attack_indicator_layer: Control
var attack_indicator_line: Line2D
var attack_indicator_arrow_left: Line2D
var attack_indicator_arrow_right: Line2D
var attack_indicator_tween: Tween
var pile_modal_overlay: ColorRect
var map_spirit_reward := 0
var pending_map_completion: Dictionary = {}
var unit_actor_views: Dictionary = {}
var unit_equipment_zone_views: Dictionary = {}
var unit_action_panel_views: Dictionary = {}
var debug_tools: PanelContainer
var debug_toggle_button: Button
var debug_tools_expanded := false
var enemy_spell_zone_container: HBoxContainer
var combat_source_highlight_uid := ""
var combat_target_highlight_uid := ""
var drag_candidate_uid := ""
var drag_candidate_button: CardButton = null
var drag_candidate_start_mouse := Vector2.ZERO
var drag_active := false
var drag_card_uid := ""
var drag_card_data: Dictionary = {}
var drag_card_rule := ""
var drag_source_button: CardButton = null
var drag_source_global_position := Vector2.ZERO
var drag_source_size := Vector2.ZERO
var drag_source_scale := Vector2.ONE
var drag_source_prefix := ""
var drag_pointer_offset := Vector2.ZERO
var drag_ghost: CardButton = null
var drag_drop_targets: Array = []
var drag_hover_target_index := -1
var suppress_hand_press_uid := ""

@onready var battle_number_label: Label = get_node("BattleNumberLabel") as Label
@onready var player_actor: CombatActorView = get_node("PlayerActor") as CombatActorView
@onready var enemy_actor: CombatActorView = get_node("EnemyActor") as CombatActorView
@onready var spell_zone_container: HBoxContainer = get_node("SpellDefenseZone") as HBoxContainer
@onready var equipment_zone_container: Control = get_node("EquipmentZone") as Control
@onready var equipment_replace_hint_panel: PanelContainer = get_node("EquipmentReplaceHintPanel") as PanelContainer
@onready var equipment_replace_hint_label: Label = get_node("EquipmentReplaceHintPanel/EquipmentReplaceHintLayout/EquipmentReplaceHintLabel") as Label
@onready var equipment_replace_cancel_button: Button = get_node("EquipmentReplaceHintPanel/EquipmentReplaceHintLayout/EquipmentReplaceCancelButton") as Button
@onready var action_row: HBoxContainer = get_node("ActionRow") as HBoxContainer
@onready var normal_attack_button: Button = get_node("ActionRow/NormalAttackButton") as Button
@onready var end_turn_button: Button = get_node("ActionRow/EndTurnButton") as Button
@onready var restart_button: Button = get_node("RestartButton") as Button
@onready var hand_container: Control = get_node("HandContainer") as Control
@onready var deck_pile_button: Button = get_node("DeckPileButton") as Button
@onready var graveyard_pile_button: Button = get_node("GraveyardPileButton") as Button
@onready var exile_pile_button: Button = get_node("ExilePileButton") as Button
@onready var log_toggle_button: Button = get_node("LogToggleButton") as Button
@onready var log_panel: PanelContainer = get_node("LogPanel") as PanelContainer
@onready var log_close_button: Button = get_node("LogPanel/LogLayout/LogHeaderRow/LogCloseButton") as Button
@onready var log_container: VBoxContainer = get_node("LogPanel/LogLayout/LogScroll/LogContainer") as VBoxContainer
@onready var choice_panel: PanelContainer = get_node("ChoicePanel") as PanelContainer
@onready var choice_title_label: Label = get_node("ChoicePanel/ChoiceLayout/ChoiceTitleLabel") as Label
@onready var choice_container: GridContainer = get_node("ChoicePanel/ChoiceLayout/ChoiceContainer") as GridContainer
@onready var reward_scene: Control = get_node("RewardScene") as Control
@onready var reward_title_label: Label = get_node("RewardScene/RewardLayout/RewardTitleLabel") as Label
@onready var reward_container: GridContainer = get_node("RewardScene/RewardLayout/RewardContainer") as GridContainer
@onready var equipment_confirm_panel: PanelContainer = get_node("EquipmentConfirmPanel") as PanelContainer
@onready var equipment_confirm_name_label: Label = get_node("EquipmentConfirmPanel/ConfirmLayout/ConfirmNameLabel") as Label
@onready var equipment_confirm_activate_button: Button = get_node("EquipmentConfirmPanel/ConfirmLayout/ConfirmButtonRow/ConfirmActivateButton") as Button
@onready var equipment_confirm_cancel_button: Button = get_node("EquipmentConfirmPanel/ConfirmLayout/ConfirmButtonRow/ConfirmCancelButton") as Button
@onready var pile_viewer = get_node("PileViewer")
@onready var card_tooltip = get_node("CardTooltip")

func _ready() -> void:
	audio_manager = AudioManagerScript.new()
	add_child(audio_manager)
	_create_pile_modal_overlay()
	_create_fx_layer()
	_create_turn_banner_layer()
	_create_attack_indicator_layer()
	_create_result_preview_label()
	_create_enemy_spell_zone()
	if _battle_debug_tools_enabled():
		_create_debug_tools()
	normal_attack_button.pressed.connect(_on_normal_attack)
	end_turn_button.pressed.connect(_on_end_turn)
	restart_button.pressed.connect(_on_restart)
	deck_pile_button.pressed.connect(_on_deck_pile_pressed)
	graveyard_pile_button.pressed.connect(_on_graveyard_pile_pressed)
	exile_pile_button.pressed.connect(_on_exile_pile_pressed)
	log_toggle_button.pressed.connect(_on_log_toggle)
	log_close_button.pressed.connect(_on_log_close)
	equipment_confirm_activate_button.pressed.connect(_on_equipment_confirm_activate)
	equipment_confirm_cancel_button.pressed.connect(_on_equipment_confirm_cancel)
	equipment_replace_cancel_button.pressed.connect(_on_equipment_replace_cancel)
	if pile_viewer.has_signal("viewer_closed"):
		pile_viewer.viewer_closed.connect(_on_pile_viewer_closed)
	_apply_scene_style()
	_apply_log_state(false)

func _input(event: InputEvent) -> void:
	if _interaction_locked():
		if drag_active:
			_cancel_hand_card_drag()
		_clear_hand_drag_candidate()
		return
	if drag_active:
		if event is InputEventMouseMotion:
			var motion_event := event as InputEventMouseMotion
			_update_hand_card_drag(motion_event.global_position)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton:
			var mouse_event := event as InputEventMouseButton
			if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
				_finish_hand_card_drag(mouse_event.global_position)
				get_viewport().set_input_as_handled()
			elif mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
				_cancel_hand_card_drag()
				get_viewport().set_input_as_handled()
		return
	if drag_candidate_uid == "":
		return
	if event is InputEventMouseMotion:
		var candidate_motion := event as InputEventMouseMotion
		if candidate_motion.button_mask & MOUSE_BUTTON_MASK_LEFT == 0:
			_clear_hand_drag_candidate()
			return
		if candidate_motion.global_position.distance_to(drag_candidate_start_mouse) >= CARD_DRAG_START_THRESHOLD:
			if _begin_hand_card_drag(drag_candidate_button, candidate_motion.global_position):
				get_viewport().set_input_as_handled()
			else:
				_clear_hand_drag_candidate()
	elif event is InputEventMouseButton:
		var candidate_mouse := event as InputEventMouseButton
		if candidate_mouse.button_index == MOUSE_BUTTON_LEFT and not candidate_mouse.pressed:
			_clear_hand_drag_candidate()

func setup(job_id: String) -> void:
	map_spirit_reward = 0
	pending_map_completion.clear()
	manager = BattleViewModelScript.new(BattleManagerScript.new())
	manager.combat_event.connect(_on_combat_event)
	manager.start_run(job_id)
	render()

func setup_run_battle(job_id: String, deck_ids: Array, battle_number: int, encounter_type: String, run_context := {}, spirit_reward := 0) -> void:
	map_spirit_reward = max(0, int(spirit_reward))
	pending_map_completion.clear()
	manager = BattleViewModelScript.new(BattleManagerScript.new())
	manager.combat_event.connect(_on_combat_event)
	manager.start_run_with_deck(job_id, deck_ids, battle_number, encounter_type, false, run_context)
	render()

func render() -> void:
	if manager == null:
		return
	_refresh_restart_button()
	_refresh_actors()
	_refresh_unit_action_panels()
	_refresh_card_area_info()
	_refresh_actions()
	_refresh_pending_choice()
	_refresh_reward()
	_refresh_result_preview()
	_refresh_equipment_replace()
	_refresh_hand()
	_refresh_spell_zone()
	_refresh_enemy_spell_zone()
	_refresh_equipment_zone()
	_refresh_log()

func _refresh_actors() -> void:
	battle_number_label.text = _text("battle.number", {"number": manager.battle_number}, "第 {number} 场")
	var active_uids: Dictionary = {}
	_refresh_formation_side(manager.formation.player_units, true, active_uids)
	_refresh_formation_side(manager.formation.enemy_units, false, active_uids)
	_remove_inactive_actor_views(active_uids)

func _refresh_formation_side(units: Array, is_player_side: bool, active_uids: Dictionary) -> void:
	var sorted_units := units.duplicate()
	sorted_units.sort_custom(func(a, b) -> bool:
		return int(a.slot_index) < int(b.slot_index)
	)
	var compact := sorted_units.size() > 1
	for unit in sorted_units:
		if unit == null:
			continue
		var actor := _actor_view_for_unit(unit, is_player_side)
		var unit_uid := str(unit.uid)
		active_uids[unit_uid] = true
		unit_actor_views[unit_uid] = actor
		_setup_unit_actor_view(actor, unit, is_player_side)
		_layout_unit_actor_view(actor, unit, is_player_side, compact)

func _actor_view_for_unit(unit, is_player_side: bool) -> CombatActorView:
	if unit == manager.player:
		return player_actor
	if unit == manager.enemy:
		return enemy_actor
	var unit_uid := str(unit.uid)
	if unit_actor_views.has(unit_uid) and is_instance_valid(unit_actor_views[unit_uid]):
		return unit_actor_views[unit_uid] as CombatActorView
	var actor: CombatActorView = CombatActorViewScene.instantiate()
	actor.name = "FormationActor_%s" % unit_uid
	actor.z_index = 10
	add_child(actor)
	return actor

func _setup_unit_actor_view(actor: CombatActorView, unit, is_player_side: bool) -> void:
	var unit_uid := str(unit.uid)
	actor.visible = true
	actor.set_meta("unit_uid", unit_uid)
	actor.set_meta("unit_team", "player" if is_player_side else "enemy")
	_connect_actor_input(actor)
	actor.mouse_filter = Control.MOUSE_FILTER_STOP
	actor.apply_visual_profile(CharacterVisualDatabaseScript.profile_for_unit_data(_unit_visual_data(unit)))
	var extra := ""
	if unit == manager.player and manager.player.job_id == "sword":
		extra = "剑势 %d" % manager.player.sword_momentum
	elif unit != manager.player:
		extra = _unit_equipment_text(unit)
	var intent := ""
	if unit == manager.enemy:
		var current_intent := str(manager.enemy.current_intent)
		if current_intent == "":
			current_intent = "无"
		intent = "意图：%s" % current_intent
	actor.setup_actor(
		_unit_display_name_for_view(unit, is_player_side),
		"玩家占位" if is_player_side else "敌人占位",
		int(unit.hp),
		int(unit.max_hp),
		unit.current_attack(),
		unit.current_defense(),
		extra,
		intent
	)
	var selected_for_enemy_target: bool = (not is_player_side) and manager.phase == "target_select" and unit_uid == manager.selected_enemy_uid
	var selected_for_unit_action := false
	actor.set_selected(selected_for_enemy_target or selected_for_unit_action)
	actor.set_combat_highlight(_combat_highlight_mode_for_key(_unit_combat_key(unit)))

func _unit_visual_data(unit) -> Dictionary:
	return {
		"id": str(unit.unit_id),
		"name": str(unit.name),
		"visual_profile_id": str(unit.visual_profile_id),
		"animation_profile": str(unit.battle_animation_profile_id)
	}

func _layout_unit_actor_view(actor: CombatActorView, unit, is_player_side: bool, compact: bool) -> void:
	var viewport_size := get_viewport_rect().size
	var scale_value: float = _actor_scale_for_unit(unit, compact)
	actor.custom_minimum_size = ACTOR_BASE_SIZE
	actor.size = ACTOR_BASE_SIZE
	actor.scale = Vector2(scale_value, scale_value)
	actor.global_position = _actor_global_position_for_slot(is_player_side, int(unit.slot_index), compact, scale_value, viewport_size)
	actor.base_position = actor.position

func _actor_scale_for_unit(unit, compact: bool) -> float:
	if not compact:
		return 1.0
	if unit == manager.player or unit == manager.enemy:
		return 1.0
	return ACTOR_SIDE_SCALE

func _actor_global_position_for_slot(is_player_side: bool, slot_index: int, compact: bool, scale_value: float, viewport_size: Vector2) -> Vector2:
	if not compact:
		if is_player_side:
			return Vector2(viewport_size.x * 0.18 - ACTOR_BASE_SIZE.x * 0.5, 192.0)
		return Vector2(viewport_size.x * 0.82 - ACTOR_BASE_SIZE.x * 0.5, 190.0)
	var primary_center_x: float = viewport_size.x * (0.18 if is_player_side else 0.82)
	var primary_top_y := 192.0 if is_player_side else 190.0
	if slot_index == 2:
		return Vector2(primary_center_x - ACTOR_BASE_SIZE.x * 0.5, primary_top_y)
	var side_center_x: float = viewport_size.x * (0.40 if is_player_side else 0.60)
	var side_center_y := 178.0 if slot_index < 2 else 500.0
	var scaled_size := ACTOR_BASE_SIZE * scale_value
	return Vector2(side_center_x - scaled_size.x * 0.5, side_center_y - scaled_size.y * 0.5)

func _connect_actor_input(actor: CombatActorView) -> void:
	if bool(actor.get_meta("formation_input_connected", false)):
		return
	actor.gui_input.connect(_on_actor_gui_input.bind(actor))
	actor.mouse_entered.connect(_on_actor_mouse_entered.bind(actor))
	actor.set_meta("formation_input_connected", true)

func _on_actor_mouse_entered(actor: CombatActorView) -> void:
	if manager == null or manager.phase != "target_select":
		return
	if str(actor.get_meta("unit_team", "")) != "enemy":
		return
	var uid := str(actor.get_meta("unit_uid", ""))
	if _battle_result_succeeded(manager.select_enemy_target(uid)):
		render()

func _on_actor_gui_input(event: InputEvent, actor: CombatActorView) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null or not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	var unit_team := str(actor.get_meta("unit_team", ""))
	var uid := str(actor.get_meta("unit_uid", ""))
	if manager.phase == "target_select" and unit_team == "enemy":
		var result: Dictionary = manager.confirm_target_selection(uid)
		if _consume_battle_result(result):
			audio_manager.play_event("ui_confirm")
		render()
	elif unit_team == "enemy" and _battle_result_succeeded(manager.select_enemy_target(uid)):
		audio_manager.play_event("ui_click")
		render()
	elif unit_team == "player" and _battle_result_succeeded(manager.select_player_target(uid)):
		audio_manager.play_event("ui_click")
		render()

func _remove_inactive_actor_views(active_uids: Dictionary) -> void:
	for uid in unit_actor_views.keys():
		if active_uids.has(uid):
			continue
		var actor: CombatActorView = unit_actor_views[uid]
		unit_actor_views.erase(uid)
		if actor == player_actor or actor == enemy_actor:
			actor.visible = false
		elif is_instance_valid(actor):
			actor.queue_free()

func _unit_display_name_for_view(unit, is_player_side: bool) -> String:
	if unit == manager.player:
		return "玩家：%s" % manager.player.job_name
	return str(unit.name)

func _unit_equipment_text(unit) -> String:
	if unit == null:
		return ""
	var limit: int = int(unit.equipment_limit)
	if limit <= 0:
		return ""
	var equipped_count: int = 0
	for _card in unit.equipment:
		equipped_count += 1
	return "装备 %d/%d" % [equipped_count, limit]

func _actor_for_combat_key(key: String) -> CombatActorView:
	if unit_actor_views.has(key) and is_instance_valid(unit_actor_views[key]):
		return unit_actor_views[key] as CombatActorView
	if key == "player":
		return player_actor
	if key == "enemy":
		return enemy_actor
	return null

func _unit_combat_key(unit) -> String:
	if unit == manager.player:
		return "player"
	if unit == manager.enemy:
		return "enemy"
	return "" if unit == null else str(unit.uid)

func _combat_highlight_mode_for_key(key: String) -> String:
	if key == "":
		return ""
	if key == combat_source_highlight_uid:
		return "source"
	if key == combat_target_highlight_uid:
		return "target"
	return ""

func _refresh_card_area_info() -> void:
	deck_pile_button.text = _text("battle.pile.deck", {"count": manager.deck.deck.size()}, "卡组\n{count}")
	graveyard_pile_button.text = _text("battle.pile.graveyard", {"count": manager.deck.graveyard.size()}, "墓地\n{count}")
	exile_pile_button.text = _text("battle.pile.exile", {"count": manager.deck.exile.size()}, "除外\n{count}")

func _refresh_actions() -> void:
	var choosing: bool = not manager.pending_choice.is_empty() or not manager.pending_equipment_replace.is_empty()
	var responding: bool = manager.phase == "response"
	var player_phase: bool = manager.phase == "player"
	action_row.visible = player_phase or responding
	normal_attack_button.visible = false
	end_turn_button.visible = player_phase or responding
	end_turn_button.text = _text("battle.action.skip_response", {}, "跳过响应") if responding else _text("battle.action.end_turn", {}, "结束回合")
	end_turn_button.disabled = (not player_phase and not responding) or choosing or _interaction_locked()
	_style_end_turn_button(_end_turn_should_glow(player_phase, choosing, responding))

func _end_turn_should_glow(player_phase: bool, choosing: bool, responding: bool) -> bool:
	if not player_phase or choosing or responding or _interaction_locked() or manager == null:
		return false
	var units: Array = manager.formation.living_units("player")
	if units.is_empty():
		return false
	for unit in units:
		if unit == null:
			continue
		if not manager.player_unit_action_used(unit):
			return false
	return true

func _refresh_unit_action_panels() -> void:
	var active_uids: Dictionary = {}
	if manager == null:
		_remove_inactive_unit_action_panels(active_uids)
		return
	var can_show: bool = manager.phase == "player" and manager.pending_choice.is_empty() and manager.pending_equipment_replace.is_empty() and not _interaction_locked()
	if can_show:
		for unit in manager.formation.living_units("player"):
			if unit == null:
				continue
			var uid := str(unit.uid)
			if manager.player_unit_action_used(unit):
				continue
			var actor := _actor_for_combat_key(_unit_combat_key(unit))
			if actor == null or not actor.visible:
				continue
			var panel := _inline_action_panel_for_unit(uid)
			active_uids[uid] = true
			panel.visible = true
			_position_inline_action_panel(panel, actor)
			var attack_button := panel.get_node("ButtonRow/AttackButton") as Button
			var defend_button := panel.get_node("ButtonRow/DefendButton") as Button
			attack_button.disabled = manager.enemy_target_count() <= 0
			defend_button.disabled = false
	_remove_inactive_unit_action_panels(active_uids)

func _inline_action_panel_for_unit(uid: String) -> PanelContainer:
	if unit_action_panel_views.has(uid) and is_instance_valid(unit_action_panel_views[uid]):
		return unit_action_panel_views[uid] as PanelContainer
	var panel := PanelContainer.new()
	panel.name = "InlineActionPanel_%s" % uid
	panel.custom_minimum_size = Vector2(152.0, 38.0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.z_index = 96
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.05, 0.058, 0.92), Color(0.72, 0.62, 0.36, 0.92), 8, 1))
	add_child(panel)
	var row := HBoxContainer.new()
	row.name = "ButtonRow"
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	var attack_button := Button.new()
	attack_button.name = "AttackButton"
	attack_button.text = _text("battle.action.attack", {}, "攻击")
	attack_button.focus_mode = Control.FOCUS_NONE
	attack_button.custom_minimum_size = Vector2(66.0, 30.0)
	attack_button.pressed.connect(_on_inline_unit_attack_pressed.bind(uid))
	_style_button(attack_button, Color(0.25, 0.13, 0.07, 0.96), Color(0.94, 0.54, 0.30, 1.0))
	row.add_child(attack_button)
	var defend_button := Button.new()
	defend_button.name = "DefendButton"
	defend_button.text = _text("battle.action.defend", {}, "防御")
	defend_button.focus_mode = Control.FOCUS_NONE
	defend_button.custom_minimum_size = Vector2(66.0, 30.0)
	defend_button.pressed.connect(_on_inline_unit_defend_pressed.bind(uid))
	_style_button(defend_button, Color(0.08, 0.15, 0.20, 0.96), Color(0.38, 0.68, 0.88, 1.0))
	row.add_child(defend_button)
	unit_action_panel_views[uid] = panel
	return panel

func _position_inline_action_panel(panel: PanelContainer, actor: CombatActorView) -> void:
	panel.size = panel.custom_minimum_size
	var actor_size: Vector2 = actor.size * actor.scale
	var viewport_size: Vector2 = get_viewport_rect().size
	var target: Vector2 = actor.global_position + Vector2((actor_size.x - panel.size.x) * 0.5, actor_size.y + 8.0)
	target.x = clamp(target.x, 12.0, max(12.0, viewport_size.x - panel.size.x - 12.0))
	target.y = clamp(target.y, 12.0, max(12.0, viewport_size.y - panel.size.y - 12.0))
	panel.global_position = target

func _remove_inactive_unit_action_panels(active_uids: Dictionary) -> void:
	for uid in unit_action_panel_views.keys():
		if active_uids.has(uid):
			continue
		var panel: PanelContainer = unit_action_panel_views[uid]
		unit_action_panel_views.erase(uid)
		if is_instance_valid(panel):
			panel.queue_free()

func _refresh_restart_button() -> void:
	if manager == null:
		return
	if not manager.auto_advance_after_reward and manager.phase == "defeat":
		restart_button.text = _text("battle.action.return_menu", {}, "返回菜单")
	else:
		restart_button.text = _text("battle.action.restart", {}, "重开")

func _refresh_pending_choice() -> void:
	_clear_children(choice_container)
	choice_panel.visible = not manager.pending_choice.is_empty()
	if not choice_panel.visible:
		return
	choice_title_label.text = str(manager.pending_choice.get("prompt", _text("common.choose", {}, "请选择")))
	for card in manager.get_pending_options():
		var button: CardButton = CardButtonScene.instantiate()
		button.setup(card, "选择")
		button.hover_details_enabled = false
		button.hover_motion_enabled = false
		button.card_pressed.connect(_on_pending_choice)
		choice_container.add_child(button)

func _refresh_reward() -> void:
	_clear_children(reward_container)
	reward_scene.visible = manager.phase == "reward"
	if not reward_scene.visible:
		return
	if victory_audio_battle != manager.battle_number:
		audio_manager.play_event("victory")
		victory_audio_battle = manager.battle_number
	reward_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_title_label.text = _text("battle.reward.title", {}, "战斗胜利\n选择一张奖励卡")
	reward_container.columns = 3
	for card_id in manager.reward_options:
		var card := CardDatabaseScript.get_card(card_id)
		var slot := VBoxContainer.new()
		slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		slot.add_theme_constant_override("separation", 8)
		reward_container.add_child(slot)
		var button: CardButton = CardButtonScene.instantiate()
		button.build_cost_display_enabled = true
		button.setup(card, "奖励")
		button.hover_details_enabled = false
		button.hover_motion_enabled = false
		button.card_pressed.connect(_on_reward_pressed.bind(card_id))
		slot.add_child(button)
		var choose_button := Button.new()
		choose_button.text = _text("common.choose_card", {}, "选择此卡")
		choose_button.focus_mode = Control.FOCUS_NONE
		choose_button.custom_minimum_size = Vector2(0.0, 36.0)
		choose_button.pressed.connect(func() -> void:
			_on_reward_pressed("", card_id)
		)
		_style_button(choose_button, Color(0.14, 0.11, 0.07, 0.96), Color(0.88, 0.68, 0.34, 1.0))
		slot.add_child(choose_button)

func _refresh_result_preview() -> void:
	if manager == null:
		_hide_result_preview()
		return
	match manager.phase:
		"target_select":
			_update_target_preview_text()
		_:
			_hide_result_preview()

func _refresh_equipment_replace() -> void:
	equipment_replace_uids.clear()
	var active: bool = not manager.pending_equipment_replace.is_empty()
	equipment_replace_hint_panel.visible = active
	if not active:
		_clear_equipment_replace_selection()
		return
	var source_card: Dictionary = manager.pending_equipment_replace.get("source_card", {})
	equipment_replace_hint_label.text = _text("battle.equipment.choose_replace", {}, "替换：选择要卸下的装备")
	if not source_card.is_empty():
		equipment_replace_hint_label.text = _text("battle.equipment.replace", {"name": source_card.get("name", _text("battle.equipment.name", {}, "装备"))}, "替换：{name}")
	var target_uid := str(manager.pending_equipment_replace.get("target_uid", manager.player.uid))
	var target_unit = manager.formation.unit_by_uid(target_uid)
	if target_unit == null:
		target_unit = manager.player
	for card in target_unit.equipment:
		equipment_replace_uids[str(card.get("uid", ""))] = true
	if selected_equipment_uid != "" and not equipment_replace_uids.has(selected_equipment_uid):
		_clear_equipment_replace_selection()

func _refresh_hand() -> void:
	_clear_children(hand_container)
	for card in manager.deck.hand:
		var button: CardButton = CardButtonScene.instantiate()
		var prefix := CardInteractionRulesScript.hand_button_prefix_for_card(card)
		button.setup(card, prefix)
		button.hover_details_enabled = false
		button.disabled = manager.phase != "player" or not manager.pending_choice.is_empty() or not manager.pending_equipment_replace.is_empty() or _interaction_locked()
		button.gui_input.connect(_on_hand_card_gui_input.bind(button))
		button.card_pressed.connect(_on_hand_card_pressed)
		button.card_motion_started.connect(_on_hand_card_motion_started)
		_apply_hand_card_draw_visibility(button, str(card.get("uid", "")))
		hand_container.add_child(button)
	call_deferred("_layout_hand_cards")

func _apply_hand_card_draw_visibility(button: CardButton, uid: String) -> void:
	var hidden := hidden_draw_uids.has(uid)
	button.visible = not hidden
	button.disabled = button.disabled or hidden

func _refresh_spell_zone() -> void:
	_clear_children(spell_zone_container)
	var available_response_uids: Dictionary = {}
	if manager.phase == "response":
		for response_variant in manager.available_responses():
			var response_card: Dictionary = response_variant
			available_response_uids[str(response_card.get("uid", ""))] = true
	for i in range(5):
		var slot: ZoneSlot = ZoneSlotScene.instantiate()
		if i < manager.player.spell_zone.size():
			var card: Dictionary = manager.player.spell_zone[i]
			slot.setup(card)
			slot.set_meta("card_uid", str(card.get("uid", "")))
		else:
			slot.setup()
			slot.set_meta("card_uid", "")
		slot.slot_hovered.connect(_show_card_tooltip)
		slot.slot_unhovered.connect(_hide_card_tooltip)
		slot.slot_pressed.connect(_on_spell_zone_slot_pressed)
		spell_zone_container.add_child(slot)
		var slot_uid := str(slot.get_meta("card_uid", ""))
		slot.set_response_available(available_response_uids.has(slot_uid))
		if i < manager.player.spell_zone.size():
			var zone_card: Dictionary = manager.player.spell_zone[i]
			if str(zone_card.get("uid", "")) == highlighted_slot_uid:
				slot.call_deferred("flash")
	highlighted_slot_uid = ""


func _on_spell_zone_slot_pressed(card: Dictionary, _anchor_position: Vector2) -> void:
	if manager == null or manager.phase != "response":
		return
	var uid := str(card.get("uid", ""))
	if uid == "":
		return
	if _consume_battle_result(manager.play_response_card(uid)):
		audio_manager.play_event("ui_confirm")
	render()

func _refresh_enemy_spell_zone() -> void:
	if enemy_spell_zone_container == null:
		return
	_clear_children(enemy_spell_zone_container)
	var cards: Array = []
	if manager.enemy_side != null:
		cards = manager.enemy_side.spell_zone
	for i in range(5):
		var slot: ZoneSlot = ZoneSlotScene.instantiate()
		if i < cards.size():
			var card: Dictionary = cards[i]
			slot.setup(card)
			slot.set_meta("card_uid", str(card.get("uid", "")))
		else:
			slot.setup()
			slot.set_meta("card_uid", "")
		slot.set_meta("enemy_zone", true)
		slot.slot_hovered.connect(_show_card_tooltip)
		slot.slot_unhovered.connect(_hide_card_tooltip)
		enemy_spell_zone_container.add_child(slot)

func _refresh_equipment_zone() -> void:
	_refresh_player_equipment_zone()
	_refresh_unit_equipment_zones()
	highlighted_equipment_uid = ""

func _refresh_player_equipment_zone() -> void:
	_clear_children(equipment_zone_container)
	_position_equipment_zone_for_player()
	var limit: int = max(0, int(manager.player.equipment_limit))
	equipment_zone_container.visible = limit > 0
	if not equipment_zone_container.visible:
		return
	for i in range(limit):
		var card: Dictionary = {}
		if i < manager.player.equipment.size():
			card = manager.player.equipment[i]
		var slot: ZoneSlot = _make_equipment_slot(card, EQUIPMENT_CARD_SIZE, str(manager.player.uid), true)
		equipment_zone_container.add_child(slot)
		var slot_uid := str(slot.get_meta("card_uid", ""))
		if slot.has_method("set_response_available"):
			slot.call("set_response_available", equipment_replace_uids.has(slot_uid), slot_uid == selected_equipment_uid)
		if slot_uid != "" and slot_uid == highlighted_equipment_uid:
			slot.call_deferred("flash")
	call_deferred("_layout_equipment_cards")

func _position_equipment_zone_for_player() -> void:
	if player_actor == null or equipment_zone_container == null:
		return
	var limit: int = max(0, int(manager.player.equipment_limit)) if manager != null else 0
	var zone_size := _equipment_zone_size(limit)
	var zone_width: float = zone_size.x
	var zone_height: float = zone_size.y
	equipment_zone_container.size = Vector2(zone_width, zone_height)
	var viewport_size: Vector2 = get_viewport_rect().size
	var target: Vector2 = player_actor.global_position + Vector2(-zone_width - 6.0, 12.0)
	target.x = clamp(target.x, 12.0, max(12.0, viewport_size.x - zone_width - 12.0))
	target.y = clamp(target.y, 12.0, max(12.0, viewport_size.y - zone_height - 12.0))
	equipment_zone_container.global_position = target

func _refresh_unit_equipment_zones() -> void:
	var active_uids: Dictionary = {}
	if manager == null:
		_remove_inactive_equipment_zones(active_uids)
		return
	for unit in manager.formation.player_units:
		_refresh_single_unit_equipment_zone(unit, true, active_uids)
	for unit in manager.formation.enemy_units:
		_refresh_single_unit_equipment_zone(unit, false, active_uids)
	_remove_inactive_equipment_zones(active_uids)

func _refresh_single_unit_equipment_zone(unit, is_player_side: bool, active_uids: Dictionary) -> void:
	if unit == null or unit == manager.player:
		return
	var limit: int = max(0, int(unit.equipment_limit))
	if limit <= 0:
		return
	var actor := _actor_view_for_equipment_zone(unit)
	if actor == null or not actor.visible:
		return
	var unit_uid := str(unit.uid)
	var zone := _equipment_zone_for_unit(unit_uid)
	active_uids[unit_uid] = true
	_clear_children(zone)
	zone.visible = true
	zone.size = _equipment_zone_size(limit)
	for i in range(limit):
		var card: Dictionary = {}
		if i < unit.equipment.size():
			card = unit.equipment[i]
		var allow_replace := str(manager.pending_equipment_replace.get("target_uid", "")) == unit_uid
		var slot: ZoneSlot = _make_equipment_slot(card, UNIT_EQUIPMENT_SLOT_SIZE, unit_uid, allow_replace)
		var slot_uid := str(slot.get_meta("card_uid", ""))
		if slot.has_method("set_response_available"):
			slot.call("set_response_available", equipment_replace_uids.has(slot_uid), slot_uid == selected_equipment_uid)
		if slot_uid != "" and slot_uid == highlighted_equipment_uid:
			slot.call_deferred("flash")
		slot.position = Vector2(0.0, float(i) * (UNIT_EQUIPMENT_SLOT_SIZE.y + UNIT_EQUIPMENT_GAP))
		zone.add_child(slot)
	_position_equipment_zone_for_unit(zone, actor, is_player_side)

func _actor_view_for_equipment_zone(unit) -> CombatActorView:
	if unit == manager.enemy:
		return enemy_actor
	var unit_uid := str(unit.uid)
	if unit_actor_views.has(unit_uid) and is_instance_valid(unit_actor_views[unit_uid]):
		return unit_actor_views[unit_uid] as CombatActorView
	return null

func _equipment_zone_for_unit(unit_uid: String) -> Control:
	if unit_equipment_zone_views.has(unit_uid) and is_instance_valid(unit_equipment_zone_views[unit_uid]):
		return unit_equipment_zone_views[unit_uid] as Control
	var zone := Control.new()
	zone.name = "UnitEquipmentZone_%s" % unit_uid
	zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zone.z_index = 52
	add_child(zone)
	unit_equipment_zone_views[unit_uid] = zone
	return zone

func _make_equipment_slot(card: Dictionary, slot_size: Vector2, unit_uid: String, allow_replace_press: bool) -> ZoneSlot:
	var slot: ZoneSlot = ZoneSlotScene.instantiate()
	slot.custom_minimum_size = slot_size
	slot.size = slot_size
	slot.setup(card)
	slot.set_meta("unit_uid", unit_uid)
	slot.set_meta("card_uid", str(card.get("uid", "")) if not card.is_empty() else "")
	slot.slot_hovered.connect(_show_card_tooltip)
	slot.slot_unhovered.connect(_hide_card_tooltip)
	if allow_replace_press:
		slot.slot_pressed.connect(_on_equipment_slot_pressed)
	return slot

func _equipment_zone_size(limit: int) -> Vector2:
	var height: float = UNIT_EQUIPMENT_SLOT_SIZE.y * float(limit) + UNIT_EQUIPMENT_GAP * float(max(0, limit - 1))
	return Vector2(UNIT_EQUIPMENT_SLOT_SIZE.x, height)

func _position_equipment_zone_for_unit(zone: Control, actor: CombatActorView, is_player_side: bool) -> void:
	if zone == null or actor == null:
		return
	var actor_size: Vector2 = actor.size * actor.scale
	var gap := 6.0
	var target_x: float = actor.global_position.x - zone.size.x - gap
	if not is_player_side:
		target_x = actor.global_position.x + actor_size.x + gap
	var target_y: float = actor.global_position.y + 12.0
	var viewport_size: Vector2 = get_viewport_rect().size
	target_x = clamp(target_x, 12.0, max(12.0, viewport_size.x - zone.size.x - 12.0))
	target_y = clamp(target_y, 12.0, max(12.0, viewport_size.y - zone.size.y - 12.0))
	zone.global_position = Vector2(target_x, target_y)

func _remove_inactive_equipment_zones(active_uids: Dictionary) -> void:
	for uid in unit_equipment_zone_views.keys():
		if active_uids.has(uid):
			continue
		var zone: Control = unit_equipment_zone_views[uid]
		unit_equipment_zone_views.erase(uid)
		if is_instance_valid(zone):
			zone.queue_free()

func _refresh_log() -> void:
	_clear_children(log_container)
	for message in manager.messages:
		var label := Label.new()
		label.text = str(message)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82, 1.0))
		log_container.add_child(label)

func _wire_card_tooltip(button: CardButton) -> void:
	button.card_hovered.connect(_show_card_tooltip)
	button.card_unhovered.connect(_hide_card_tooltip)

func _layout_hand_cards() -> void:
	var cards := hand_container.get_children()
	var count: int = cards.size()
	if count == 0:
		return
	var viewport_width := float(get_viewport_rect().size.x)
	var available_width: float = min(viewport_width * HAND_MAX_WIDTH_RATIO, HAND_MAX_WIDTH)
	if available_width <= 0.0:
		available_width = HAND_MAX_WIDTH
	available_width = max(available_width, HAND_CARD_SIZE.x)
	var natural_width: float = HAND_CARD_SIZE.x * float(count) + HAND_NORMAL_GAP * float(max(0, count - 1))
	var step: float = HAND_CARD_SIZE.x + HAND_NORMAL_GAP
	if count > 1 and natural_width > available_width:
		step = max(0.0, (available_width - HAND_CARD_SIZE.x) / float(count - 1))
	var total_width: float = HAND_CARD_SIZE.x + step * float(count - 1)
	var start_x: float = (hand_container.size.x - total_width) * 0.5
	var base_y := 0.0
	for i in range(count):
		var card := cards[i] as Control
		card.custom_minimum_size = HAND_CARD_SIZE
		card.size = HAND_CARD_SIZE
		card.position = Vector2(start_x + step * i, base_y)
		card.z_index = HAND_Z_BASE + i
		if card.has_method("cache_base_position"):
			card.call("cache_base_position")

func _cache_hand_card_base_positions() -> void:
	_layout_hand_cards()

func _layout_equipment_cards() -> void:
	var cards := equipment_zone_container.get_children()
	var count: int = cards.size()
	if count == 0:
		return
	var available_height: float = max(EQUIPMENT_CARD_SIZE.y, equipment_zone_container.size.y)
	var natural_height: float = EQUIPMENT_CARD_SIZE.y * float(count) + EQUIPMENT_NORMAL_GAP * float(max(0, count - 1))
	var step: float = EQUIPMENT_CARD_SIZE.y + EQUIPMENT_NORMAL_GAP
	if count > 1 and natural_height > available_height:
		step = max(0.0, (available_height - EQUIPMENT_CARD_SIZE.y) / float(count - 1))
	for i in range(count):
		var card := cards[i] as Control
		var slot_uid := str(card.get_meta("card_uid", ""))
		card.custom_minimum_size = EQUIPMENT_CARD_SIZE
		card.size = EQUIPMENT_CARD_SIZE
		card.position = Vector2(8.0 if slot_uid != "" and slot_uid == selected_equipment_uid else 0.0, step * i)
		card.z_index = EQUIPMENT_Z_BASE + i

func _show_card_tooltip(card: Dictionary, anchor_position: Vector2) -> void:
	card_tooltip.show_card(card, anchor_position)

func _hide_card_tooltip() -> void:
	card_tooltip.hide_tooltip()

func _clear_equipment_replace_selection() -> void:
	selected_equipment_uid = ""
	_hide_equipment_confirm_panel()

func _hide_equipment_confirm_panel() -> void:
	equipment_confirm_panel.visible = false

func _update_target_preview_text() -> void:
	var lines: Array = _target_selection_preview_lines()
	_set_result_preview_text(lines)

func _target_selection_preview_lines() -> Array:
	if manager == null or manager.pending_target_action.is_empty():
		return []
	var action_type := str(manager.pending_target_action.get("type", ""))
	if action_type != "normal_attack" and action_type != "unit_attack":
		return []
	var source_unit = _target_selection_source_unit(action_type)
	var target_unit = manager.selected_enemy_unit()
	if source_unit == null or target_unit == null:
		return []
	var attack_value: int = source_unit.current_attack()
	var defense_value: int = target_unit.current_defense()
	var damage: int = max(0, attack_value - defense_value)
	return [
		"预计结果：%s攻击%s。" % [_unit_display_name_for_preview(source_unit), _unit_display_name_for_preview(target_unit)],
		"预计造成 %d 点伤害。（攻击 %d - 防御 %d）" % [damage, attack_value, defense_value]
	]

func _target_selection_source_unit(action_type: String):
	if action_type == "normal_attack":
		return manager.player
	return manager.formation.living_unit_by_uid("player", str(manager.pending_target_action.get("source_uid", "")))

func _unit_display_name_for_preview(unit) -> String:
	if manager != null and unit == manager.player:
		return "玩家：%s" % manager.player.job_name
	if unit != null and unit.get("name") != null:
		return str(unit.name)
	return "单位"

func _set_result_preview_text(lines: Array) -> void:
	if result_preview_label == null:
		return
	result_preview_label.visible = not lines.is_empty()
	result_preview_label.text = "\n".join(lines)

func _hide_result_preview() -> void:
	if result_preview_label == null:
		return
	result_preview_label.visible = false
	result_preview_label.text = ""

func _update_equipment_zone_replace_state() -> void:
	for child in equipment_zone_container.get_children():
		var slot_uid := str(child.get_meta("card_uid", ""))
		if child.has_method("set_response_available"):
			child.call("set_response_available", equipment_replace_uids.has(slot_uid), slot_uid == selected_equipment_uid)
	for zone_value in unit_equipment_zone_views.values():
		var zone := zone_value as Control
		if zone == null or not is_instance_valid(zone):
			continue
		for child in zone.get_children():
			var slot_uid := str(child.get_meta("card_uid", ""))
			if child.has_method("set_response_available"):
				child.call("set_response_available", equipment_replace_uids.has(slot_uid), slot_uid == selected_equipment_uid)
	_layout_equipment_cards()

func _on_equipment_slot_pressed(card: Dictionary, anchor_position: Vector2) -> void:
	if manager.pending_equipment_replace.is_empty():
		return
	var uid := str(card.get("uid", ""))
	if not equipment_replace_uids.has(uid):
		return
	selected_equipment_uid = uid
	_update_equipment_zone_replace_state()
	_show_equipment_replace_confirm(card, anchor_position)

func _show_equipment_replace_confirm(card: Dictionary, anchor_position: Vector2) -> void:
	equipment_confirm_name_label.text = _text("battle.equipment.confirm", {"name": card.get("name", _text("battle.equipment.name", {}, "装备"))}, "替换 {name}？")
	equipment_confirm_activate_button.text = _text("battle.equipment.replace_action", {}, "替换")
	equipment_confirm_cancel_button.text = _text("common.cancel", {}, "取消")
	equipment_confirm_panel.visible = true
	equipment_confirm_panel.size = equipment_confirm_panel.custom_minimum_size
	var panel_size := equipment_confirm_panel.size
	var viewport_size := get_viewport_rect().size
	var target := anchor_position + Vector2(12.0, -panel_size.y * 0.5)
	target.x = clamp(target.x, 12.0, max(12.0, viewport_size.x - panel_size.x - 12.0))
	target.y = clamp(target.y, 12.0, max(12.0, viewport_size.y - panel_size.y - 12.0))
	equipment_confirm_panel.global_position = target

func _on_hand_card_gui_input(event: InputEvent, button: CardButton) -> void:
	if manager == null or button == null:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if mouse_event.pressed:
		if _can_start_hand_card_drag(button):
			drag_candidate_uid = button.card_uid
			drag_candidate_button = button
			drag_candidate_start_mouse = mouse_event.global_position
	else:
		if drag_candidate_uid == button.card_uid and not drag_active:
			_clear_hand_drag_candidate()

func _can_start_hand_card_drag(button: CardButton) -> bool:
	if button == null or button.disabled or button.card_data.is_empty():
		return false
	if manager == null or manager.phase != "player":
		return false
	if _interaction_locked():
		return false
	if not manager.pending_choice.is_empty() or not manager.pending_equipment_replace.is_empty():
		return false
	return _card_drag_rule(button.card_data) != "direct"

func _begin_hand_card_drag(button: CardButton, pointer_global_position: Vector2) -> bool:
	if button == null or button.card_data.is_empty():
		return false
	var rule := _card_drag_rule(button.card_data)
	if rule == "direct":
		return false
	drag_drop_targets = _collect_hand_card_drop_targets(button.card_data, rule)
	if drag_drop_targets.is_empty():
		return false
	drag_active = true
	drag_card_uid = button.card_uid
	drag_candidate_uid = ""
	drag_candidate_button = null
	drag_card_data = button.card_data.duplicate(true)
	drag_card_rule = rule
	drag_source_button = button
	drag_source_global_position = button.global_position
	drag_source_size = button.size
	drag_source_scale = button.scale
	drag_source_prefix = _hand_prefix_for_card(drag_card_data)
	drag_pointer_offset = pointer_global_position - drag_source_global_position
	drag_hover_target_index = -2
	suppress_hand_press_uid = drag_card_uid
	drag_source_button.modulate = Color(1.0, 1.0, 1.0, 0.35)
	_create_hand_drag_ghost()
	_update_hand_card_drag(pointer_global_position)
	return true

func _create_hand_drag_ghost() -> void:
	if fx_layer == null or drag_card_data.is_empty():
		return
	drag_ghost = CardButtonScene.instantiate()
	fx_layer.add_child(drag_ghost)
	drag_ghost.setup(drag_card_data, drag_source_prefix)
	drag_ghost.hover_details_enabled = false
	drag_ghost.hover_motion_enabled = false
	drag_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_ghost.focus_mode = Control.FOCUS_NONE
	drag_ghost.custom_minimum_size = drag_source_size
	drag_ghost.size = drag_source_size
	drag_ghost.scale = drag_source_scale
	drag_ghost.pivot_offset = drag_source_size * 0.5
	drag_ghost.z_index = 300
	drag_ghost.modulate = Color(1.0, 1.0, 1.0, 0.92)
	drag_ghost.position = drag_source_global_position - fx_layer.global_position

func _update_hand_card_drag(pointer_global_position: Vector2) -> void:
	if drag_ghost != null and is_instance_valid(drag_ghost):
		drag_ghost.position = pointer_global_position - drag_pointer_offset - fx_layer.global_position
	_update_hand_drag_target_hints(pointer_global_position)

func _finish_hand_card_drag(pointer_global_position: Vector2) -> void:
	var uid := drag_card_uid
	var source_card := drag_card_data.duplicate(true)
	var source_position := drag_source_global_position
	var source_size := drag_source_size
	var source_scale := drag_source_scale
	var source_prefix := drag_source_prefix
	var target := _hand_drag_target_at(pointer_global_position)
	_clear_hand_card_drag_visuals()
	if target.is_empty():
		call_deferred("_clear_suppressed_hand_press", uid)
		return
	audio_manager.play_event("ui_confirm")
	var result: Dictionary = {}
	match str(target.get("kind", "")):
		"enemy_unit":
			result = manager.play_hand_card_on_enemy_target(uid, str(target.get("unit_uid", "")))
		"ally_unit":
			result = manager.play_hand_card_on_unit_target(uid, str(target.get("unit_uid", "")))
		"spell_zone":
			result = manager.play_hand_card(uid)
		"unit_equipment":
			result = manager.play_hand_card_on_unit_target(uid, str(target.get("unit_uid", "")))
	var card_was_consumed := _consume_battle_result(result) and _battle_result_consumed_card(result, uid)
	render()
	if card_was_consumed:
		_play_hand_card_release_fx(source_card, source_prefix, source_position, source_size, source_scale)
	call_deferred("_clear_suppressed_hand_press", uid)

func _cancel_hand_card_drag() -> void:
	var uid := drag_card_uid
	_clear_hand_card_drag_visuals()
	call_deferred("_clear_suppressed_hand_press", uid)

func _clear_hand_card_drag_visuals() -> void:
	_clear_hand_drag_target_hints()
	if drag_ghost != null and is_instance_valid(drag_ghost):
		drag_ghost.queue_free()
	if drag_source_button != null and is_instance_valid(drag_source_button):
		drag_source_button.modulate = Color.WHITE
	drag_active = false
	drag_card_uid = ""
	drag_card_data.clear()
	drag_card_rule = ""
	drag_source_button = null
	drag_source_global_position = Vector2.ZERO
	drag_source_size = Vector2.ZERO
	drag_source_scale = Vector2.ONE
	drag_source_prefix = ""
	drag_pointer_offset = Vector2.ZERO
	drag_ghost = null
	drag_hover_target_index = -1
	_clear_hand_drag_candidate()

func _clear_hand_drag_candidate() -> void:
	drag_candidate_uid = ""
	drag_candidate_button = null
	drag_candidate_start_mouse = Vector2.ZERO

func _clear_suppressed_hand_press(uid: String) -> void:
	if suppress_hand_press_uid == uid:
		suppress_hand_press_uid = ""

func _collect_hand_card_drop_targets(card: Dictionary, rule: String) -> Array:
	var result: Array = []
	match rule:
		"ally_unit":
			for unit in manager.formation.living_units("player"):
				var actor := _actor_for_combat_key(_unit_combat_key(unit))
				if actor != null and actor.visible:
					result.append({"kind": "ally_unit", "unit_uid": str(unit.uid), "control": actor})
		"enemy_unit":
			for unit in manager.formation.living_units("enemy"):
				var actor := _actor_for_combat_key(_unit_combat_key(unit))
				if actor != null and actor.visible:
					result.append({"kind": "enemy_unit", "unit_uid": str(unit.uid), "control": actor})
		"spell_zone":
			for child in spell_zone_container.get_children():
				var slot := child as Control
				if slot == null:
					continue
				if str(slot.get_meta("card_uid", "")) == "":
					result.append({"kind": "spell_zone", "control": slot})
		"unit_equipment":
			for unit in manager.formation.living_units("player"):
				if unit == null or int(unit.equipment_limit) <= 0:
					continue
				var actor := _actor_for_combat_key(_unit_combat_key(unit))
				if actor != null and actor.visible:
					result.append({"kind": "unit_equipment", "unit_uid": str(unit.uid), "control": actor})
	return result

func _update_hand_drag_target_hints(pointer_global_position: Vector2) -> void:
	var hovered_index := _hand_drag_target_index_at(pointer_global_position)
	if hovered_index == drag_hover_target_index:
		return
	drag_hover_target_index = hovered_index
	for i in range(drag_drop_targets.size()):
		var target: Dictionary = drag_drop_targets[i]
		var control := target.get("control", null) as Control
		if control == null or not is_instance_valid(control):
			continue
		if control.has_method("set_drop_available"):
			control.call("set_drop_available", true, i == drag_hover_target_index)

func _clear_hand_drag_target_hints() -> void:
	for target in drag_drop_targets:
		var control := target.get("control", null) as Control
		if control != null and is_instance_valid(control) and control.has_method("set_drop_available"):
			control.call("set_drop_available", false, false)
	drag_drop_targets.clear()
	drag_hover_target_index = -1

func _hand_drag_target_at(pointer_global_position: Vector2) -> Dictionary:
	var index := _hand_drag_target_index_at(pointer_global_position)
	if index < 0 or index >= drag_drop_targets.size():
		return {}
	return drag_drop_targets[index]

func _hand_drag_target_index_at(pointer_global_position: Vector2) -> int:
	for i in range(drag_drop_targets.size() - 1, -1, -1):
		var target: Dictionary = drag_drop_targets[i]
		var control := target.get("control", null) as Control
		if control != null and is_instance_valid(control) and _global_point_in_control(pointer_global_position, control):
			return i
	return -1

func _global_point_in_control(point: Vector2, control: Control) -> bool:
	var rect_size := control.size * control.scale
	var rect := Rect2(control.global_position, rect_size)
	return rect.has_point(point)

func _card_drag_rule(card: Dictionary) -> String:
	return CardInteractionRulesScript.card_drag_rule(card)

func _card_needs_enemy_target(card: Dictionary) -> bool:
	return CardInteractionRulesScript.card_needs_enemy_target(card)

func _effect_needs_enemy_target(effect: Dictionary) -> bool:
	return CardInteractionRulesScript.effect_needs_enemy_target(effect)

func _on_hand_card_pressed(uid: String) -> void:
	if _interaction_locked():
		return
	if suppress_hand_press_uid == uid:
		suppress_hand_press_uid = ""
		return
	var source_button := _find_hand_card_button(uid)
	var source_card := _card_from_hand_button_or_manager(source_button, uid)
	var source_position := source_button.global_position if source_button != null else Vector2.ZERO
	var source_size := source_button.size if source_button != null else HAND_CARD_SIZE
	var source_scale := source_button.scale if source_button != null else Vector2.ONE
	var source_prefix := _hand_prefix_for_card(source_card)
	var result: Dictionary = manager.play_hand_card(uid)
	var card_was_consumed := _consume_battle_result(result) and _battle_result_consumed_card(result, uid)
	render()
	if card_was_consumed and source_button != null:
		_play_hand_card_release_fx(source_card, source_prefix, source_position, source_size, source_scale)

func _on_hand_card_motion_started(_card: Dictionary) -> void:
	audio_manager.play_event("card_hover")

func _on_pending_choice(uid: String) -> void:
	audio_manager.play_event("ui_confirm")
	manager.choose_pending(uid)
	render()

func _on_reward_pressed(_uid: String, card_id: String) -> void:
	audio_manager.play_event("ui_confirm")
	manager.choose_reward(card_id)
	victory_audio_battle = -1
	pile_viewer.close()
	if manager.phase == "map_complete":
		pending_map_completion = {
			"deck_ids": manager.master_deck_ids.duplicate(),
			"reserve_ids": manager.master_reserve_ids.duplicate(),
			"player_hp": manager.player.hp,
			"player_max_hp": manager.player.max_hp
		}
		if map_spirit_reward > 0:
			_show_reward_spirit_confirmation()
		else:
			_emit_pending_map_completion()
		return
	render()

func _show_reward_spirit_confirmation() -> void:
	_clear_children(reward_container)
	reward_scene.visible = true
	reward_container.columns = 1
	reward_title_label.text = _text("battle.reward.stones", {"value": map_spirit_reward}, "获得 {value} 灵石")
	reward_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var continue_button := Button.new()
	continue_button.text = _text("battle.action.continue", {}, "继续探索")
	continue_button.focus_mode = Control.FOCUS_NONE
	continue_button.custom_minimum_size = Vector2(220.0, 42.0)
	continue_button.pressed.connect(_emit_pending_map_completion)
	_style_button(continue_button, Color(0.12, 0.16, 0.12, 0.96), Color(0.58, 0.82, 0.46, 1.0))
	reward_container.add_child(continue_button)

func _emit_pending_map_completion() -> void:
	if pending_map_completion.is_empty():
		return
	var deck_ids: Array = pending_map_completion.get("deck_ids", []).duplicate()
	var reserve_ids: Array = pending_map_completion.get("reserve_ids", []).duplicate()
	var player_hp: int = int(pending_map_completion.get("player_hp", 0))
	var player_max_hp: int = int(pending_map_completion.get("player_max_hp", 0))
	pending_map_completion.clear()
	map_battle_completed.emit(deck_ids, reserve_ids, player_hp, player_max_hp)

func _on_equipment_confirm_activate() -> void:
	audio_manager.play_event("ui_confirm")
	if selected_equipment_uid == "":
		return
	var source_uid := str(manager.pending_equipment_replace.get("source_uid", ""))
	var source_card: Dictionary = manager.pending_equipment_replace.get("source_card", {})
	var source_button := _find_hand_card_button(source_uid)
	var source_position := source_button.global_position if source_button != null else Vector2.ZERO
	var source_size := source_button.size if source_button != null else HAND_CARD_SIZE
	var source_scale := source_button.scale if source_button != null else Vector2.ONE
	var source_prefix := _hand_prefix_for_card(source_card)
	_hide_equipment_confirm_panel()
	card_tooltip.hide_tooltip()
	var result: Dictionary = manager.choose_equipment_replacement(selected_equipment_uid)
	var source_was_consumed := _consume_battle_result(result) and _battle_result_consumed_card(result, source_uid)
	selected_equipment_uid = ""
	render()
	if source_was_consumed and source_button != null:
		_play_hand_card_release_fx(source_card, source_prefix, source_position, source_size, source_scale)

func _on_equipment_confirm_cancel() -> void:
	audio_manager.play_event("ui_click")
	_clear_equipment_replace_selection()
	_update_equipment_zone_replace_state()

func _on_equipment_replace_cancel() -> void:
	audio_manager.play_event("ui_click")
	_clear_equipment_replace_selection()
	card_tooltip.hide_tooltip()
	_consume_battle_result(manager.cancel_equipment_replacement())
	render()

func _on_normal_attack() -> void:
	_consume_battle_result(manager.player_normal_attack())
	render()

func _on_end_turn() -> void:
	if manager.phase == "response":
		_consume_battle_result(manager.skip_response())
	else:
		_consume_battle_result(manager.end_player_turn())
	render()

func _on_restart() -> void:
	audio_manager.play_event("ui_click")
	victory_audio_battle = -1
	pile_viewer.close()
	if not manager.auto_advance_after_reward and manager.phase == "defeat":
		run_abandoned.emit()
		return
	manager.restart_run()
	render()

func _on_deck_pile_pressed() -> void:
	_open_pile_viewer("卡组", manager.deck.deck)

func _on_graveyard_pile_pressed() -> void:
	_open_pile_viewer("墓地", manager.deck.graveyard)

func _on_exile_pile_pressed() -> void:
	_open_pile_viewer("除外区", manager.deck.exile)

func _on_log_toggle() -> void:
	audio_manager.play_event("ui_click")
	_apply_log_state(not log_expanded)

func _on_log_close() -> void:
	audio_manager.play_event("ui_click")
	_apply_log_state(false)

func _on_combat_event(event: Dictionary) -> void:
	for event_name in BattleAudioRouterScript.events_for_combat_event(event):
		audio_manager.play_event(str(event_name))
	_apply_combat_floating_text(event)
	match event.get("type", ""):
		"turn_started":
			_show_turn_banner(str(event.get("label", "")))
		"cards_drawn":
			_queue_draw_fx(event.get("cards", []))
		"attack_started":
			var source_key: String = str(event.get("source", ""))
			var target_key: String = str(event.get("target", ""))
			var source_actor: CombatActorView = _actor_for_combat_key(source_key)
			var target_actor: CombatActorView = _actor_for_combat_key(target_key)
			_set_combat_focus(source_key, target_key)
			_show_attack_indicator(source_actor, target_actor)
			if source_actor != null:
				var source_team := str(source_actor.get_meta("unit_team", "enemy"))
				source_actor.play_attack(1 if source_team == "player" else -1)
		"attack_finished":
			_clear_combat_focus()
		"damage_applied":
			pass
		"heal_applied":
			pass
		"sword_power_changed":
			pass
		"damage_reduced":
			pass
		"unit_defended":
			pass
		"card_played":
			pass
		"defense_card_set":
			highlighted_slot_uid = str(event.get("card", {}).get("uid", ""))
		"card_placed_in_spell_zone":
			var placed_card: Dictionary = event.get("card", {})
			highlighted_slot_uid = str(placed_card.get("uid", ""))
			_flash_spell_slot(highlighted_slot_uid)
		"card_equipped":
			var equipped_card: Dictionary = event.get("card", {})
			highlighted_equipment_uid = str(equipped_card.get("uid", ""))
			_flash_equipment_slot(highlighted_equipment_uid)
		"card_destroyed":
			pass

func _apply_combat_floating_text(event: Dictionary) -> void:
	for entry in BattleFloatingTextRulesScript.entries_for_combat_event(event):
		var feedback: Dictionary = entry
		var actor := _actor_for_combat_key(str(feedback.get("target", "")))
		if actor == null:
			continue
		if bool(feedback.get("hit", false)):
			actor.play_hit()
		var color: Color = feedback.get("color", Color.WHITE)
		actor.show_floating_text(str(feedback.get("text", "")), color)

func _flash_spell_slot(uid: String) -> void:
	if uid == "":
		return
	for child in spell_zone_container.get_children():
		if str(child.get_meta("card_uid", "")) == uid and child.has_method("flash"):
			child.call("flash")
			return

func _flash_equipment_slot(uid: String) -> void:
	if uid == "":
		return
	for child in equipment_zone_container.get_children():
		if str(child.get_meta("card_uid", "")) == uid and child.has_method("flash"):
			child.call("flash")
			return
	for zone_value in unit_equipment_zone_views.values():
		var zone := zone_value as Control
		if zone == null or not is_instance_valid(zone):
			continue
		for child in zone.get_children():
			if str(child.get_meta("card_uid", "")) == uid and child.has_method("flash"):
				child.call("flash")
				return

func _create_pile_modal_overlay() -> void:
	pile_modal_overlay = ColorRect.new()
	pile_modal_overlay.name = "PileModalOverlay"
	pile_modal_overlay.color = Color(0.0, 0.0, 0.0, 0.50)
	pile_modal_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	pile_modal_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	pile_modal_overlay.visible = false
	pile_modal_overlay.z_index = 115
	pile_modal_overlay.gui_input.connect(_on_pile_modal_overlay_input)
	add_child(pile_modal_overlay)
	move_child(pile_modal_overlay, pile_viewer.get_index())

func _open_pile_viewer(title: String, cards: Array) -> void:
	audio_manager.play_event("ui_click")
	pile_modal_overlay.visible = true
	pile_viewer.open(title, cards)

func _on_pile_modal_overlay_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	accept_event()
	pile_viewer.close()

func _on_pile_viewer_closed() -> void:
	if pile_modal_overlay != null and pile_modal_overlay.visible:
		audio_manager.play_event("ui_click")
	if pile_modal_overlay != null:
		pile_modal_overlay.visible = false

func _create_fx_layer() -> void:
	fx_layer = Control.new()
	fx_layer.name = "FxLayer"
	fx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_layer.z_index = 2000
	add_child(fx_layer)

func _create_turn_banner_layer() -> void:
	turn_banner_layer = Control.new()
	turn_banner_layer.name = "TurnBannerLayer"
	turn_banner_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	turn_banner_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	turn_banner_layer.z_index = 1700
	turn_banner_layer.visible = false
	add_child(turn_banner_layer)

	turn_banner_panel = Panel.new()
	turn_banner_panel.name = "TurnBannerPanel"
	turn_banner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	turn_banner_panel.add_theme_stylebox_override("panel", _turn_banner_style())
	turn_banner_layer.add_child(turn_banner_panel)

	turn_banner_label = Label.new()
	turn_banner_label.name = "TurnBannerLabel"
	turn_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	turn_banner_label.add_theme_font_size_override("font_size", 36)
	turn_banner_label.add_theme_color_override("font_color", Color(1.0, 0.93, 0.70, 1.0))
	turn_banner_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.70))
	turn_banner_label.add_theme_constant_override("shadow_offset_x", 2)
	turn_banner_label.add_theme_constant_override("shadow_offset_y", 3)
	turn_banner_panel.add_child(turn_banner_label)

func _turn_banner_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.035, 0.04, 0.82)
	style.border_color = Color(0.82, 0.66, 0.32, 0.88)
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _interaction_locked() -> bool:
	return turn_banner_active or draw_fx_active

func _show_turn_banner(label_text: String) -> void:
	if turn_banner_layer == null or turn_banner_panel == null or turn_banner_label == null:
		return
	if turn_banner_tween != null and turn_banner_tween.is_running():
		turn_banner_tween.kill()
	turn_banner_active = true
	turn_banner_label.text = label_text
	_layout_turn_banner()
	turn_banner_layer.visible = true
	turn_banner_layer.modulate = Color.WHITE
	turn_banner_panel.modulate = Color(1.0, 1.0, 1.0, 0.94)
	turn_banner_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	turn_banner_label.scale = Vector2(1.72, 1.72)
	turn_banner_tween = create_tween()
	turn_banner_tween.set_parallel(true)
	turn_banner_tween.tween_property(turn_banner_label, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	turn_banner_tween.tween_property(turn_banner_label, "modulate:a", 1.0, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	turn_banner_tween.chain().tween_interval(0.34)
	turn_banner_tween.chain().set_parallel(true)
	turn_banner_tween.tween_property(turn_banner_layer, "modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	turn_banner_tween.finished.connect(func() -> void:
		turn_banner_active = false
		turn_banner_layer.visible = false
		turn_banner_layer.modulate = Color.WHITE
		turn_banner_panel.modulate = Color.WHITE
		turn_banner_label.modulate = Color.WHITE
		turn_banner_label.scale = Vector2.ONE
		render()
	)
	render()

func _layout_turn_banner() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var banner_height := 74.0
	turn_banner_panel.size = Vector2(viewport_size.x, banner_height)
	turn_banner_panel.global_position = Vector2(0.0, viewport_size.y * 0.5 - banner_height * 0.5)
	turn_banner_label.size = turn_banner_panel.size
	turn_banner_label.position = Vector2.ZERO
	turn_banner_label.pivot_offset = turn_banner_label.size * 0.5

func _queue_draw_fx(cards: Array) -> void:
	for card in cards:
		var card_dict: Dictionary = card
		if not card_dict.is_empty():
			hidden_draw_uids[str(card_dict.get("uid", ""))] = true
			draw_fx_queue.append(card_dict.duplicate(true))
	render()
	call_deferred("_play_pending_draw_animations")

func _play_pending_draw_animations() -> void:
	if draw_fx_active or fx_layer == null:
		return
	if draw_fx_queue.is_empty():
		return
	draw_fx_active = true
	await get_tree().process_frame
	if not is_inside_tree():
		draw_fx_active = false
		return
	await _wait_for_turn_banner_gap()
	if not is_inside_tree():
		draw_fx_active = false
		return
	while not draw_fx_queue.is_empty():
		var card: Dictionary = draw_fx_queue.pop_front()
		await _play_single_draw_fx(card)
		if not draw_fx_queue.is_empty():
			if not is_inside_tree():
				draw_fx_active = false
				return
			await get_tree().create_timer(VISUAL_STEP_GAP).timeout
	draw_fx_active = false
	render()

func _wait_for_turn_banner_gap() -> void:
	var waited := false
	while turn_banner_active:
		if not is_inside_tree():
			return
		waited = true
		await get_tree().process_frame
	if waited and is_inside_tree():
		await get_tree().create_timer(DRAW_AFTER_TURN_BANNER_GAP).timeout

func _play_single_draw_fx(card: Dictionary) -> void:
	if card.is_empty() or fx_layer == null:
		return
	var uid := str(card.get("uid", ""))
	var ghost_size := HAND_CARD_SIZE
	var start_center := _draw_fx_start_center()
	var finish_center := _draw_fx_finish_center(card)
	var ghost: CardButton = CardButtonScene.instantiate()
	fx_layer.add_child(ghost)
	ghost.setup(card, "抽牌")
	ghost.hover_details_enabled = false
	ghost.hover_motion_enabled = false
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.focus_mode = Control.FOCUS_NONE
	ghost.custom_minimum_size = ghost_size
	ghost.size = ghost_size
	ghost.position = start_center - fx_layer.global_position - ghost_size * 0.5
	ghost.pivot_offset = ghost_size * 0.5
	ghost.scale = Vector2(0.76, 0.76)
	ghost.z_index = 40
	ghost.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var finish_position := finish_center - fx_layer.global_position - ghost_size * 0.5
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ghost, "modulate:a", 0.94, 0.05)
	tween.tween_property(ghost, "position", finish_position, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ghost, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func() -> void:
		_reveal_drawn_hand_card(uid)
	)
	tween.chain().tween_property(ghost, "modulate:a", 0.0, 0.08)
	tween.finished.connect(func() -> void:
		if is_instance_valid(ghost):
			ghost.queue_free()
	)
	await tween.finished

func _reveal_drawn_hand_card(uid: String) -> void:
	if uid == "":
		return
	hidden_draw_uids.erase(uid)
	var button := _find_hand_card_button(uid)
	if button == null:
		return
	button.visible = true
	button.disabled = manager == null or manager.phase != "player" or not manager.pending_choice.is_empty() or not manager.pending_equipment_replace.is_empty() or _interaction_locked()
	button.modulate = Color(1.0, 1.0, 1.0, 0.0)
	button.scale = Vector2(0.92, 0.92)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw_fx_start_center() -> Vector2:
	if deck_pile_button != null and deck_pile_button.visible:
		return deck_pile_button.global_position + deck_pile_button.size * 0.5
	var viewport_size: Vector2 = get_viewport_rect().size
	return Vector2(viewport_size.x - 84.0, viewport_size.y - 92.0)

func _draw_fx_finish_center(card: Dictionary) -> Vector2:
	var uid := str(card.get("uid", ""))
	var target_button := _find_hand_card_button(uid)
	if target_button != null:
		return target_button.global_position + target_button.size * target_button.scale * 0.5
	var viewport_size: Vector2 = get_viewport_rect().size
	return Vector2(viewport_size.x * 0.5, viewport_size.y - 82.0)

func _create_attack_indicator_layer() -> void:
	attack_indicator_layer = Control.new()
	attack_indicator_layer.name = "AttackIndicatorLayer"
	attack_indicator_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	attack_indicator_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	attack_indicator_layer.z_index = 66
	attack_indicator_layer.visible = false
	add_child(attack_indicator_layer)

	attack_indicator_line = _create_attack_indicator_line(6.0)
	attack_indicator_arrow_left = _create_attack_indicator_line(6.0)
	attack_indicator_arrow_right = _create_attack_indicator_line(6.0)

func _create_result_preview_label() -> void:
	result_preview_label = Label.new()
	result_preview_label.name = "ResultPreviewLabel"
	result_preview_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_preview_label.z_index = 300
	result_preview_label.set_anchors_preset(Control.PRESET_CENTER)
	result_preview_label.offset_left = -360.0
	result_preview_label.offset_top = -222.0
	result_preview_label.offset_right = 360.0
	result_preview_label.offset_bottom = -142.0
	result_preview_label.visible = false
	add_child(result_preview_label)

func _create_attack_indicator_line(width: float) -> Line2D:
	var line: Line2D = Line2D.new()
	line.width = width
	line.default_color = Color(1.0, 0.18, 0.12, 0.92)
	line.antialiased = true
	line.visible = false
	attack_indicator_layer.add_child(line)
	return line

func _set_combat_focus(source_key: String, target_key: String) -> void:
	combat_source_highlight_uid = source_key
	combat_target_highlight_uid = target_key
	_apply_combat_highlights()

func _clear_combat_focus() -> void:
	combat_source_highlight_uid = ""
	combat_target_highlight_uid = ""
	_apply_combat_highlights()

func _apply_combat_highlights() -> void:
	for actor_value in unit_actor_views.values():
		var actor: CombatActorView = actor_value as CombatActorView
		if actor == null or not is_instance_valid(actor):
			continue
		var key: String = _actor_combat_key(actor)
		actor.set_combat_highlight(_combat_highlight_mode_for_key(key))

func _actor_combat_key(actor: CombatActorView) -> String:
	if actor == player_actor:
		return "player"
	if actor == enemy_actor:
		return "enemy"
	return str(actor.get_meta("unit_uid", ""))

func _show_attack_indicator(source_actor: CombatActorView, target_actor: CombatActorView) -> void:
	if attack_indicator_layer == null or attack_indicator_line == null:
		return
	if source_actor == null or target_actor == null:
		return
	var start: Vector2 = _actor_visual_center(source_actor) - attack_indicator_layer.global_position
	var finish: Vector2 = _actor_visual_center(target_actor) - attack_indicator_layer.global_position
	var distance: float = start.distance_to(finish)
	if distance < 16.0:
		return
	var direction: Vector2 = (finish - start) / distance
	var normal: Vector2 = Vector2(-direction.y, direction.x)
	var trim: float = min(72.0, distance * 0.24)
	var line_start: Vector2 = start + direction * trim
	var line_end: Vector2 = finish - direction * trim
	var head_length: float = 30.0
	var head_width: float = 17.0
	attack_indicator_line.points = PackedVector2Array([line_start, line_end])
	attack_indicator_arrow_left.points = PackedVector2Array([line_end, line_end - direction * head_length + normal * head_width])
	attack_indicator_arrow_right.points = PackedVector2Array([line_end, line_end - direction * head_length - normal * head_width])
	for line_node in [attack_indicator_line, attack_indicator_arrow_left, attack_indicator_arrow_right]:
		var line: Line2D = line_node as Line2D
		line.visible = true
	attack_indicator_layer.visible = true
	attack_indicator_layer.modulate = Color.WHITE
	if attack_indicator_tween != null and attack_indicator_tween.is_running():
		attack_indicator_tween.kill()
	attack_indicator_tween = create_tween()
	attack_indicator_tween.tween_interval(0.95)
	attack_indicator_tween.tween_property(attack_indicator_layer, "modulate:a", 0.0, 0.32)
	attack_indicator_tween.finished.connect(_hide_attack_indicator)

func _actor_visual_center(actor: CombatActorView) -> Vector2:
	return actor.global_position + actor.size * actor.scale * 0.5

func _hide_attack_indicator() -> void:
	if attack_indicator_layer == null:
		return
	attack_indicator_layer.visible = false
	attack_indicator_layer.modulate = Color.WHITE
	for line_node in [attack_indicator_line, attack_indicator_arrow_left, attack_indicator_arrow_right]:
		var line: Line2D = line_node as Line2D
		if line != null:
			line.visible = false

func _create_enemy_spell_zone() -> void:
	enemy_spell_zone_container = HBoxContainer.new()
	enemy_spell_zone_container.name = "EnemySpellDefenseZone"
	enemy_spell_zone_container.anchor_left = 0.82
	enemy_spell_zone_container.anchor_right = 0.82
	enemy_spell_zone_container.offset_left = -205.0
	enemy_spell_zone_container.offset_top = 552.0
	enemy_spell_zone_container.offset_right = 205.0
	enemy_spell_zone_container.offset_bottom = 640.0
	enemy_spell_zone_container.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_spell_zone_container.add_theme_constant_override("separation", 5)
	enemy_spell_zone_container.z_index = 4
	add_child(enemy_spell_zone_container)

func _create_debug_tools() -> void:
	if not _battle_debug_tools_enabled():
		return
	debug_toggle_button = Button.new()
	debug_toggle_button.name = "DebugToolsToggleButton"
	debug_toggle_button.text = _text("battle.debug.open", {}, "测试")
	debug_toggle_button.focus_mode = Control.FOCUS_NONE
	debug_toggle_button.anchor_left = 0.0
	debug_toggle_button.anchor_top = 0.0
	debug_toggle_button.offset_left = 14.0
	debug_toggle_button.offset_top = 56.0
	debug_toggle_button.offset_right = 82.0
	debug_toggle_button.offset_bottom = 92.0
	debug_toggle_button.z_index = 91
	debug_toggle_button.pressed.connect(_on_debug_toggle)
	add_child(debug_toggle_button)

	debug_tools = BattleDebugToolsScript.new()
	debug_tools.name = "BattleDebugTools"
	debug_tools.anchor_left = 0.0
	debug_tools.anchor_top = 0.0
	debug_tools.offset_left = 14.0
	debug_tools.offset_top = 98.0
	debug_tools.offset_right = 202.0
	debug_tools.offset_bottom = 316.0
	debug_tools.z_index = 90
	debug_tools.visible = false
	add_child(debug_tools)
	debug_tools.add_enemy_requested.connect(_on_debug_add_enemy)
	debug_tools.add_ally_requested.connect(_on_debug_add_ally)
	debug_tools.clear_extra_enemies_requested.connect(_on_debug_clear_extra_enemies)
	debug_tools.damage_target_requested.connect(_on_debug_damage_target)
	debug_tools.heal_target_requested.connect(_on_debug_heal_target)
	debug_tools.modify_target_attack_requested.connect(_on_debug_modify_target_attack)
	debug_tools.modify_target_defense_requested.connect(_on_debug_modify_target_defense)
	_apply_debug_tools_state(false)

func _battle_debug_tools_enabled() -> bool:
	return DEBUG_TOOLS_ENABLED

func _on_inline_unit_attack_pressed(unit_uid: String) -> void:
	if manager == null:
		return
	audio_manager.play_event("ui_confirm")
	_consume_battle_result(manager.player_unit_attack(unit_uid))
	render()

func _on_inline_unit_defend_pressed(unit_uid: String) -> void:
	if manager == null:
		return
	audio_manager.play_event("ui_confirm")
	_consume_battle_result(manager.player_unit_defend(unit_uid))
	render()

func _on_debug_toggle() -> void:
	if not _battle_debug_tools_enabled():
		_apply_debug_tools_state(false)
		return
	audio_manager.play_event("ui_click")
	_apply_debug_tools_state(not debug_tools_expanded)

func _apply_debug_tools_state(expanded: bool) -> void:
	if not _battle_debug_tools_enabled():
		expanded = false
	debug_tools_expanded = expanded
	if debug_tools != null:
		debug_tools.visible = expanded
	if debug_toggle_button != null:
		debug_toggle_button.text = _text("common.collapse", {}, "收起") if expanded else _text("battle.debug.open", {}, "测试")

func _on_debug_add_enemy() -> void:
	if not _battle_debug_tools_enabled() or manager == null:
		return
	if manager.debug_add_enemy():
		audio_manager.play_event("ui_confirm")
	render()

func _on_debug_add_ally() -> void:
	if not _battle_debug_tools_enabled() or manager == null:
		return
	if manager.debug_add_ally():
		audio_manager.play_event("ui_confirm")
	render()

func _on_debug_clear_extra_enemies() -> void:
	if not _battle_debug_tools_enabled() or manager == null:
		return
	manager.clear_extra_enemy_units()
	manager.clear_extra_player_units()
	audio_manager.play_event("ui_click")
	render()

func _on_debug_damage_target(amount: int) -> void:
	if not _battle_debug_tools_enabled() or manager == null:
		return
	var target = manager.selected_debug_unit()
	if target == null:
		return
	manager.apply_damage_to_unit(target, amount, "测试工具")
	manager.check_victory_or_defeat()
	render()

func _on_debug_heal_target(amount: int) -> void:
	if not _battle_debug_tools_enabled() or manager == null:
		return
	var target = manager.selected_debug_unit()
	if target == null:
		return
	manager.heal_unit(target, amount, "测试工具")
	render()

func _on_debug_modify_target_attack(amount: int) -> void:
	if not _battle_debug_tools_enabled() or manager == null:
		return
	var target = manager.selected_debug_unit()
	if target == null:
		return
	manager.modify_unit_stat(target, "attack", amount, false, "测试工具")
	render()

func _on_debug_modify_target_defense(amount: int) -> void:
	if not _battle_debug_tools_enabled() or manager == null:
		return
	var target = manager.selected_debug_unit()
	if target == null:
		return
	manager.modify_unit_stat(target, "defense", amount, false, "测试工具")
	render()

func _find_hand_card_button(uid: String) -> CardButton:
	if uid == "":
		return null
	for child in hand_container.get_children():
		var button := child as CardButton
		if button != null and button.card_uid == uid:
			return button
	return null

func _card_from_hand_button_or_manager(button: CardButton, uid: String) -> Dictionary:
	if button != null and not button.card_data.is_empty():
		return button.card_data.duplicate(true)
	var card: Dictionary = manager.deck.find_hand_card(uid)
	return card.duplicate(true) if not card.is_empty() else {}


func _battle_result_succeeded(result: Dictionary) -> bool:
	return bool(result.get("accepted", false)) and bool(result.get("success", false))


func _consume_battle_result(result: Dictionary) -> bool:
	if _battle_result_succeeded(result):
		return true
	var error_code := str(result.get("error_code", result.get("error", "request_rejected")))
	var error_key := str(result.get("error_key", "battle.error.%s" % error_code))
	if result_preview_label != null:
		result_preview_label.text = _text(error_key, {}, _battle_error_fallback(error_code))
	return false


func _battle_error_fallback(error_code: String) -> String:
	match error_code:
		"missing_request_id":
			return "请求缺少编号。"
		"missing_request_type":
			return "请求缺少类型。"
		"unknown_request_type":
			return "请求类型无效。"
		"invalid_request_side":
			return "请求阵营无效。"
	return "请求未被接受。"


func _battle_result_consumed_card(result: Dictionary, card_uid: String) -> bool:
	if card_uid == "":
		return false
	for event_variant in result.get("events", []):
		var event: Dictionary = event_variant
		if not ["card_played", "enemy_card_played", "defense_card_set", "defense_card_activated", "equipment_replaced"].has(str(event.get("type", ""))):
			continue
		for field in ["card", "new_card"]:
			var card: Dictionary = event.get(field, {})
			if str(card.get("uid", "")) == card_uid:
				return true
	return false


func _text(text_id: String, params: Dictionary = {}, source_fallback := "") -> String:
	return LocalizationServiceScript.text(text_id, "zh_cn", params, source_fallback)

func _hand_prefix_for_card(card: Dictionary) -> String:
	return CardInteractionRulesScript.played_card_fx_prefix_for_card(card)

func _play_hand_card_release_fx(card: Dictionary, prefix: String, start_global_position: Vector2, start_size: Vector2, start_scale: Vector2) -> void:
	if fx_layer == null or card.is_empty():
		return
	var start_position: Vector2 = start_global_position - fx_layer.global_position
	var ghost: CardButton = CardButtonScene.instantiate()
	fx_layer.add_child(ghost)
	ghost.setup(card, prefix)
	ghost.hover_details_enabled = false
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.focus_mode = Control.FOCUS_NONE
	ghost.custom_minimum_size = start_size
	ghost.size = start_size
	ghost.position = start_position
	ghost.scale = start_scale
	ghost.pivot_offset = start_size * 0.5
	ghost.z_index = 20
	ghost.modulate = Color(1.0, 1.0, 1.0, 0.92)

	var outline := _create_card_outline(card, start_size)
	fx_layer.add_child(outline)
	outline.position = start_position
	outline.scale = start_scale
	outline.pivot_offset = start_size * 0.5
	outline.z_index = 21
	outline.modulate = Color(1.0, 1.0, 1.0, 0.74)

	var lift := Vector2(0.0, -126.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ghost, "position", start_position + lift, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ghost, "scale", start_scale * 1.035, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ghost, "modulate:a", 0.0, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(outline, "position", start_position + lift + Vector2(0.0, -18.0), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(outline, "scale", start_scale * 1.08, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(outline, "modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(func() -> void:
		ghost.queue_free()
		outline.queue_free()
	)

func _create_card_outline(card: Dictionary, outline_size: Vector2) -> Panel:
	var outline := Panel.new()
	outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outline.custom_minimum_size = outline_size
	outline.size = outline_size
	outline.add_theme_stylebox_override("panel", _card_outline_style(card))
	return outline

func _card_outline_style(card: Dictionary) -> StyleBoxFlat:
	var border := CardDisplayRulesScript.card_outline_border_color(card)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(border.r, border.g, border.b, 0.04)
	style.border_color = border
	style.set_border_width_all(3)
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	style.shadow_color = Color(border.r, border.g, border.b, 0.30)
	style.shadow_size = 8
	return style

func _apply_log_state(expanded: bool) -> void:
	log_expanded = expanded
	log_toggle_button.text = _text("common.collapse", {}, "收起") if log_expanded else _text("battle.log", {}, "日志")
	if log_tween != null and log_tween.is_running():
		log_tween.kill()
	if log_expanded:
		log_panel.visible = true
		log_panel.offset_left = -18.0
		log_panel.offset_right = 308.0
		log_panel.modulate.a = 0.0
		log_tween = create_tween()
		log_tween.set_parallel(true)
		log_tween.tween_property(log_panel, "offset_left", -344.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		log_tween.tween_property(log_panel, "offset_right", -18.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		log_tween.tween_property(log_panel, "modulate:a", 1.0, 0.12)
	else:
		if not log_panel.visible:
			return
		log_tween = create_tween()
		log_tween.set_parallel(true)
		log_tween.tween_property(log_panel, "offset_left", -18.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		log_tween.tween_property(log_panel, "offset_right", 308.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		log_tween.tween_property(log_panel, "modulate:a", 0.0, 0.12)
		log_tween.finished.connect(func() -> void:
			log_panel.visible = false
		)

func _apply_scene_style() -> void:
	log_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.05, 0.058, 0.96), Color(0.34, 0.38, 0.46, 1.0), 8, 2))
	choice_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.05, 0.058, 0.96), Color(0.54, 0.62, 0.82, 1.0), 8, 2))
	equipment_confirm_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.05, 0.058, 0.98), Color(0.95, 0.88, 0.62, 1.0), 8, 2))
	equipment_replace_hint_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.07, 0.055, 0.96), Color(0.42, 0.84, 0.56, 1.0), 8, 2))
	equipment_replace_hint_label.add_theme_font_size_override("font_size", 12)
	equipment_replace_hint_label.add_theme_color_override("font_color", Color(0.82, 1.0, 0.86, 1.0))
	if result_preview_label != null:
		result_preview_label.add_theme_font_size_override("font_size", 18)
		result_preview_label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.66, 1.0))
		result_preview_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
		result_preview_label.add_theme_constant_override("shadow_offset_x", 1)
		result_preview_label.add_theme_constant_override("shadow_offset_y", 2)
	equipment_confirm_name_label.add_theme_font_size_override("font_size", 13)
	equipment_confirm_name_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.70, 1.0))
	if reward_scene is PanelContainer:
		(reward_scene as PanelContainer).add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.05, 0.058, 0.96), Color(0.58, 0.50, 0.32, 1.0), 8, 2))
	reward_title_label.add_theme_font_size_override("font_size", 22)
	reward_title_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.76, 1.0))
	_style_button(normal_attack_button, Color(0.26, 0.13, 0.08, 1.0), Color(0.95, 0.54, 0.32, 1.0))
	_style_end_turn_button(false)
	_style_button(restart_button, Color(0.10, 0.10, 0.11, 0.94), Color(0.42, 0.44, 0.48, 1.0))
	_style_button(equipment_confirm_activate_button, Color(0.24, 0.14, 0.06, 0.96), Color(0.96, 0.70, 0.32, 1.0))
	_style_button(equipment_confirm_cancel_button, Color(0.10, 0.10, 0.11, 0.96), Color(0.54, 0.56, 0.62, 1.0))
	_style_button(equipment_replace_cancel_button, Color(0.08, 0.10, 0.09, 0.94), Color(0.42, 0.84, 0.56, 1.0))
	_style_button(deck_pile_button, Color(0.11, 0.10, 0.08, 0.92), Color(0.74, 0.58, 0.30, 1.0))
	_style_button(graveyard_pile_button, Color(0.09, 0.09, 0.10, 0.92), Color(0.50, 0.54, 0.60, 1.0))
	_style_button(exile_pile_button, Color(0.12, 0.08, 0.12, 0.92), Color(0.72, 0.44, 0.86, 1.0))
	_style_button(log_toggle_button, Color(0.08, 0.09, 0.10, 0.92), Color(0.48, 0.52, 0.58, 1.0))
	if debug_toggle_button != null:
		_style_button(debug_toggle_button, Color(0.08, 0.09, 0.08, 0.92), Color(0.62, 0.52, 0.28, 1.0))

func _style_end_turn_button(glowing: bool) -> void:
	if end_turn_button == null:
		return
	if glowing:
		_style_button(end_turn_button, Color(0.18, 0.15, 0.07, 1.0), Color(1.0, 0.76, 0.28, 1.0), 14)
	else:
		_style_button(end_turn_button, Color(0.12, 0.18, 0.22, 1.0), Color(0.44, 0.70, 0.90, 1.0))

func _style_button(button: Button, bg: Color, border: Color, shadow_size := 0) -> void:
	UIStyleFactoryScript.apply_button_style(button, bg, border, 6, 1, 2, 2, Vector4(10, 10, 8, 8), shadow_size, 0.12, 0.06, 0.18)

func _button_style(bg: Color, border: Color, radius: int, border_width: int, shadow_size := 0) -> StyleBoxFlat:
	return UIStyleFactoryScript.button_style(bg, border, radius, border_width, Vector4(10, 10, 8, 8), shadow_size)

func _panel_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	return UIStyleFactoryScript.panel_style(bg, border, radius, border_width, Vector4(10, 10, 8, 8))

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
