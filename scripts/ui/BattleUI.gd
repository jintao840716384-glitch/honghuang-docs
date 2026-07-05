extends Control

signal map_battle_completed(deck_ids: Array)

const BattleManagerScript = preload("res://scripts/battle/BattleManager.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const CardButtonScene = preload("res://scenes/CardButton.tscn")
const ZoneSlotScene = preload("res://scenes/ZoneSlot.tscn")
const AudioManagerScript = preload("res://scripts/audio/AudioManager.gd")

const HAND_CARD_SIZE := Vector2(225, 315)
const HAND_NORMAL_GAP := 12.0
const HAND_MAX_WIDTH_RATIO := 0.68
const HAND_MAX_WIDTH := 1280.0
const HAND_Z_BASE := 100
const EQUIPMENT_CARD_SIZE := Vector2(70, 96)
const EQUIPMENT_NORMAL_GAP := 8.0
const EQUIPMENT_Z_BASE := 80

var manager: BattleManager
var highlighted_slot_uid := ""
var highlighted_equipment_uid := ""
var log_expanded := false
var log_tween: Tween
var audio_manager: Node
var victory_audio_battle := -1
var available_response_uids: Dictionary = {}
var equipment_replace_uids: Dictionary = {}
var selected_response_uid := ""
var selected_response_card: Dictionary = {}
var selected_equipment_uid := ""
var confirm_mode := ""
var fx_layer: Control
var pile_modal_overlay: ColorRect

@onready var battle_number_label: Label = get_node("BattleNumberLabel") as Label
@onready var player_actor: CombatActorView = get_node("PlayerActor") as CombatActorView
@onready var enemy_actor: CombatActorView = get_node("EnemyActor") as CombatActorView
@onready var spell_zone_container: VBoxContainer = get_node("SpellDefenseZone") as VBoxContainer
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
@onready var reward_container: GridContainer = get_node("RewardScene/RewardLayout/RewardContainer") as GridContainer
@onready var chain_overlay: Control = get_node("ChainOverlay") as Control
@onready var chain_title_label: Label = get_node("ChainOverlay/ChainTitleLabel") as Label
@onready var chain_event_label: Label = get_node("ChainOverlay/ChainEventLabel") as Label
@onready var chain_skip_button: Button = get_node("ChainOverlay/SkipResponseButton") as Button
@onready var response_confirm_panel: PanelContainer = get_node("ResponseConfirmPanel") as PanelContainer
@onready var response_confirm_name_label: Label = get_node("ResponseConfirmPanel/ConfirmLayout/ConfirmNameLabel") as Label
@onready var response_confirm_activate_button: Button = get_node("ResponseConfirmPanel/ConfirmLayout/ConfirmButtonRow/ConfirmActivateButton") as Button
@onready var response_confirm_cancel_button: Button = get_node("ResponseConfirmPanel/ConfirmLayout/ConfirmButtonRow/ConfirmCancelButton") as Button
@onready var pile_viewer = get_node("PileViewer")
@onready var card_tooltip = get_node("CardTooltip")

func _ready() -> void:
	audio_manager = AudioManagerScript.new()
	add_child(audio_manager)
	_create_pile_modal_overlay()
	_create_fx_layer()
	normal_attack_button.pressed.connect(_on_normal_attack)
	end_turn_button.pressed.connect(_on_end_turn)
	restart_button.pressed.connect(_on_restart)
	deck_pile_button.pressed.connect(_on_deck_pile_pressed)
	graveyard_pile_button.pressed.connect(_on_graveyard_pile_pressed)
	exile_pile_button.pressed.connect(_on_exile_pile_pressed)
	log_toggle_button.pressed.connect(_on_log_toggle)
	log_close_button.pressed.connect(_on_log_close)
	chain_skip_button.pressed.connect(_on_response_skipped)
	response_confirm_activate_button.pressed.connect(_on_confirm_activate)
	response_confirm_cancel_button.pressed.connect(_on_confirm_cancel)
	equipment_replace_cancel_button.pressed.connect(_on_equipment_replace_cancel)
	if pile_viewer.has_signal("viewer_closed"):
		pile_viewer.viewer_closed.connect(_on_pile_viewer_closed)
	_apply_scene_style()
	_apply_log_state(false)

func setup(job_id: String) -> void:
	manager = BattleManagerScript.new()
	manager.combat_event.connect(_on_combat_event)
	manager.start_run(job_id)
	render()

func setup_run_battle(job_id: String, deck_ids: Array, battle_number: int, encounter_type: String) -> void:
	manager = BattleManagerScript.new()
	manager.combat_event.connect(_on_combat_event)
	manager.start_run_with_deck(job_id, deck_ids, battle_number, encounter_type, false)
	render()

func render() -> void:
	if manager == null:
		return
	_refresh_actors()
	_refresh_card_area_info()
	_refresh_actions()
	_refresh_pending_choice()
	_refresh_reward()
	_refresh_response()
	_refresh_equipment_replace()
	_refresh_hand()
	_refresh_spell_zone()
	_refresh_equipment_zone()
	_refresh_log()

func _refresh_actors() -> void:
	battle_number_label.text = "第 %d 场" % manager.battle_number
	var sword_text := ""
	if manager.player.job_id == "sword":
		sword_text = "剑势：%d" % manager.player.sword_momentum
	player_actor.setup_actor(
		"玩家：%s" % manager.player.job_name,
		"玩家占位",
		manager.player.hp,
		manager.player.max_hp,
		manager.player.current_attack(),
		manager.player.current_defense(),
		sword_text,
		""
	)
	var intent := str(manager.enemy.current_intent)
	if intent == "":
		intent = "无"
	enemy_actor.setup_actor(
		manager.enemy.name,
		"敌人占位",
		manager.enemy.hp,
		manager.enemy.max_hp,
		manager.enemy.attack,
		manager.enemy.current_defense(),
		"",
		"意图：%s" % intent
	)

func _refresh_card_area_info() -> void:
	deck_pile_button.text = "卡组\n%d" % manager.deck.deck.size()
	graveyard_pile_button.text = "墓地\n%d" % manager.deck.graveyard.size()
	exile_pile_button.text = "除外\n%d" % manager.deck.exile.size()

func _refresh_actions() -> void:
	var choosing := not manager.pending_choice.is_empty() or not manager.pending_equipment_replace.is_empty()
	var responding := manager.phase == "response"
	var player_phase := manager.phase == "player"
	action_row.visible = player_phase
	normal_attack_button.visible = player_phase
	end_turn_button.visible = player_phase
	normal_attack_button.disabled = not player_phase or manager.player.normal_attack_used or choosing or responding
	end_turn_button.disabled = not player_phase or choosing or responding

func _refresh_pending_choice() -> void:
	_clear_children(choice_container)
	choice_panel.visible = not manager.pending_choice.is_empty()
	if not choice_panel.visible:
		return
	choice_title_label.text = str(manager.pending_choice.get("prompt", "请选择"))
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
	for card_id in manager.reward_options:
		var card := CardDatabaseScript.get_card(card_id)
		var button: CardButton = CardButtonScene.instantiate()
		button.setup(card, "奖励")
		button.hover_details_enabled = false
		button.hover_motion_enabled = false
		button.card_pressed.connect(_on_reward_pressed.bind(card_id))
		reward_container.add_child(button)

func _refresh_response() -> void:
	available_response_uids.clear()
	chain_overlay.visible = manager.phase == "response"
	if not chain_overlay.visible:
		_clear_response_selection()
		return
	var responses: Array = manager.get_available_responses_for_current_event()
	for card in responses:
		available_response_uids[str(card.get("uid", ""))] = true
	if selected_response_uid != "" and not available_response_uids.has(selected_response_uid):
		_clear_response_selection()
	chain_title_label.text = "连锁"
	chain_event_label.text = "%s  ·  %s" % [manager.get_event_description(manager.current_event), _chain_status_text()]
	chain_skip_button.text = "结束连锁"

func _refresh_equipment_replace() -> void:
	equipment_replace_uids.clear()
	var active := not manager.pending_equipment_replace.is_empty()
	equipment_replace_hint_panel.visible = active
	if not active:
		_clear_equipment_replace_selection()
		return
	var source_card: Dictionary = manager.pending_equipment_replace.get("source_card", {})
	equipment_replace_hint_label.text = "替换：选择要卸下的装备"
	if not source_card.is_empty():
		equipment_replace_hint_label.text = "替换：%s" % source_card.get("name", "装备")
	for card in manager.player.equipment:
		equipment_replace_uids[str(card.get("uid", ""))] = true
	if selected_equipment_uid != "" and not equipment_replace_uids.has(selected_equipment_uid):
		_clear_equipment_replace_selection()

func _refresh_hand() -> void:
	_clear_children(hand_container)
	for card in manager.deck.hand:
		var button: CardButton = CardButtonScene.instantiate()
		var prefix := "使用"
		if card.get("type", "") == CardDatabaseScript.TYPE_DEFENSE:
			prefix = "盖伏"
		elif str(card.get("after_use", "")) == "equipment":
			prefix = "装备"
		button.setup(card, prefix)
		button.hover_details_enabled = false
		button.disabled = manager.phase != "player" or not manager.pending_choice.is_empty() or not manager.pending_equipment_replace.is_empty()
		button.card_pressed.connect(_on_hand_card_pressed)
		button.card_motion_started.connect(_on_hand_card_motion_started)
		hand_container.add_child(button)
	call_deferred("_layout_hand_cards")

func _refresh_spell_zone() -> void:
	_clear_children(spell_zone_container)
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
		if slot.has_method("set_response_available"):
			slot.call("set_response_available", available_response_uids.has(slot_uid), slot_uid == selected_response_uid)
		if i < manager.player.spell_zone.size():
			var zone_card: Dictionary = manager.player.spell_zone[i]
			if str(zone_card.get("uid", "")) == highlighted_slot_uid:
				slot.call_deferred("flash")
	highlighted_slot_uid = ""

func _refresh_equipment_zone() -> void:
	_clear_children(equipment_zone_container)
	equipment_zone_container.visible = manager.player.equipment.size() > 0
	if not equipment_zone_container.visible:
		return
	for card in manager.player.equipment:
		var slot: ZoneSlot = ZoneSlotScene.instantiate()
		slot.custom_minimum_size = EQUIPMENT_CARD_SIZE
		slot.setup(card)
		slot.set_meta("card_uid", str(card.get("uid", "")))
		slot.slot_hovered.connect(_show_card_tooltip)
		slot.slot_unhovered.connect(_hide_card_tooltip)
		slot.slot_pressed.connect(_on_equipment_slot_pressed)
		equipment_zone_container.add_child(slot)
		var slot_uid := str(slot.get_meta("card_uid", ""))
		if slot.has_method("set_response_available"):
			slot.call("set_response_available", equipment_replace_uids.has(slot_uid), slot_uid == selected_equipment_uid)
		if slot_uid == highlighted_equipment_uid:
			slot.call_deferred("flash")
	highlighted_equipment_uid = ""
	call_deferred("_layout_equipment_cards")

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

func _chain_status_text() -> String:
	if manager.chain_stack.is_empty():
		return "当前连锁：无"
	var names: Array = []
	for card in manager.chain_stack:
		names.append(str(card.get("name", "卡牌")))
	return "当前连锁：%s" % " <- ".join(names)

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
		card.position = Vector2(10.0 if slot_uid == selected_equipment_uid else 0.0, step * i)
		card.z_index = EQUIPMENT_Z_BASE + i

func _show_card_tooltip(card: Dictionary, anchor_position: Vector2) -> void:
	card_tooltip.show_card(card, anchor_position)

func _hide_card_tooltip() -> void:
	card_tooltip.hide_tooltip()

func _clear_response_selection() -> void:
	selected_response_uid = ""
	selected_response_card.clear()
	if confirm_mode == "response":
		_hide_confirm_panel()

func _clear_equipment_replace_selection() -> void:
	selected_equipment_uid = ""
	if confirm_mode == "equipment_replace":
		_hide_confirm_panel()

func _hide_confirm_panel() -> void:
	confirm_mode = ""
	response_confirm_panel.visible = false

func _update_spell_zone_response_state() -> void:
	for child in spell_zone_container.get_children():
		var slot_uid := str(child.get_meta("card_uid", ""))
		if child.has_method("set_response_available"):
			child.call("set_response_available", available_response_uids.has(slot_uid), slot_uid == selected_response_uid)

func _update_equipment_zone_replace_state() -> void:
	for child in equipment_zone_container.get_children():
		var slot_uid := str(child.get_meta("card_uid", ""))
		if child.has_method("set_response_available"):
			child.call("set_response_available", equipment_replace_uids.has(slot_uid), slot_uid == selected_equipment_uid)
	_layout_equipment_cards()

func _on_spell_zone_slot_pressed(card: Dictionary, anchor_position: Vector2) -> void:
	if manager.phase != "response":
		return
	var uid := str(card.get("uid", ""))
	if not available_response_uids.has(uid):
		return
	selected_response_uid = uid
	selected_response_card = card.duplicate(true)
	_update_spell_zone_response_state()
	_show_response_confirm(card, anchor_position)

func _show_response_confirm(card: Dictionary, anchor_position: Vector2) -> void:
	response_confirm_name_label.text = "发动 %s？" % card.get("name", "卡牌")
	confirm_mode = "response"
	response_confirm_activate_button.text = "发动"
	response_confirm_cancel_button.text = "取消"
	response_confirm_panel.visible = true
	response_confirm_panel.size = response_confirm_panel.custom_minimum_size
	var panel_size := response_confirm_panel.size
	var viewport_size := get_viewport_rect().size
	var target := anchor_position + Vector2(12.0, -panel_size.y * 0.5)
	target.x = clamp(target.x, 12.0, max(12.0, viewport_size.x - panel_size.x - 12.0))
	target.y = clamp(target.y, 12.0, max(12.0, viewport_size.y - panel_size.y - 12.0))
	response_confirm_panel.global_position = target

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
	confirm_mode = "equipment_replace"
	response_confirm_name_label.text = "替换 %s？" % card.get("name", "装备")
	response_confirm_activate_button.text = "替换"
	response_confirm_cancel_button.text = "取消"
	response_confirm_panel.visible = true
	response_confirm_panel.size = response_confirm_panel.custom_minimum_size
	var panel_size := response_confirm_panel.size
	var viewport_size := get_viewport_rect().size
	var target := anchor_position + Vector2(12.0, -panel_size.y * 0.5)
	target.x = clamp(target.x, 12.0, max(12.0, viewport_size.x - panel_size.x - 12.0))
	target.y = clamp(target.y, 12.0, max(12.0, viewport_size.y - panel_size.y - 12.0))
	response_confirm_panel.global_position = target

func _on_hand_card_pressed(uid: String) -> void:
	var source_button := _find_hand_card_button(uid)
	var source_card := _card_from_hand_button_or_manager(source_button, uid)
	var source_position := source_button.global_position if source_button != null else Vector2.ZERO
	var source_size := source_button.size if source_button != null else HAND_CARD_SIZE
	var source_scale := source_button.scale if source_button != null else Vector2.ONE
	var source_prefix := _hand_prefix_for_card(source_card)
	manager.play_hand_card(uid)
	var card_was_removed := not source_card.is_empty() and manager.deck.find_hand_card(uid).is_empty()
	render()
	if card_was_removed and source_button != null:
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
		map_battle_completed.emit(manager.master_deck_ids.duplicate())
		return
	render()

func _on_response_selected(uid: String) -> void:
	_clear_response_selection()
	card_tooltip.hide_tooltip()
	manager.add_card_to_chain(uid)
	render()

func _on_response_skipped() -> void:
	_clear_response_selection()
	card_tooltip.hide_tooltip()
	manager.skip_response()
	render()

func _on_confirm_activate() -> void:
	audio_manager.play_event("ui_confirm")
	match confirm_mode:
		"response":
			if selected_response_uid == "":
				return
			_on_response_selected(selected_response_uid)
		"equipment_replace":
			if selected_equipment_uid == "":
				return
			var source_uid := str(manager.pending_equipment_replace.get("source_uid", ""))
			var source_card: Dictionary = manager.pending_equipment_replace.get("source_card", {})
			var source_button := _find_hand_card_button(source_uid)
			var source_position := source_button.global_position if source_button != null else Vector2.ZERO
			var source_size := source_button.size if source_button != null else HAND_CARD_SIZE
			var source_scale := source_button.scale if source_button != null else Vector2.ONE
			var source_prefix := _hand_prefix_for_card(source_card)
			_hide_confirm_panel()
			card_tooltip.hide_tooltip()
			manager.choose_equipment_replacement(selected_equipment_uid)
			var source_was_removed := source_uid != "" and manager.deck.find_hand_card(source_uid).is_empty()
			selected_equipment_uid = ""
			render()
			if source_was_removed and source_button != null:
				_play_hand_card_release_fx(source_card, source_prefix, source_position, source_size, source_scale)

func _on_confirm_cancel() -> void:
	audio_manager.play_event("ui_click")
	match confirm_mode:
		"response":
			_clear_response_selection()
			_update_spell_zone_response_state()
		"equipment_replace":
			_clear_equipment_replace_selection()
			_update_equipment_zone_replace_state()

func _on_equipment_replace_cancel() -> void:
	audio_manager.play_event("ui_click")
	_clear_equipment_replace_selection()
	card_tooltip.hide_tooltip()
	manager.cancel_equipment_replacement()
	render()

func _on_normal_attack() -> void:
	manager.player_normal_attack()
	render()

func _on_end_turn() -> void:
	manager.end_player_turn()
	render()

func _on_restart() -> void:
	audio_manager.play_event("ui_click")
	victory_audio_battle = -1
	pile_viewer.close()
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
	match event.get("type", ""):
		"attack_started":
			audio_manager.play_event("attack")
			if event.get("source", "") == "player":
				player_actor.play_attack(1)
			elif event.get("source", "") == "enemy":
				enemy_actor.play_attack(-1)
		"damage_applied":
			audio_manager.play_event("hit")
			var value := int(event.get("value", 0))
			if event.get("target", "") == "enemy":
				enemy_actor.play_hit()
				enemy_actor.show_floating_text("-%d" % value, Color(1.0, 0.22, 0.18, 1.0))
			elif event.get("target", "") == "player":
				player_actor.play_hit()
				player_actor.show_floating_text("-%d" % value, Color(1.0, 0.22, 0.18, 1.0))
		"heal_applied":
			audio_manager.play_event("heal")
			player_actor.show_floating_text("+%d" % int(event.get("value", 0)), Color(0.30, 1.0, 0.45, 1.0))
		"sword_power_changed":
			player_actor.show_floating_text("剑势 +%d" % int(event.get("value", 0)), Color(0.55, 0.78, 1.0, 1.0))
		"damage_reduced":
			player_actor.show_floating_text("减伤 %d" % int(event.get("value", 0)), Color(0.65, 0.85, 1.0, 1.0))
		"event_interrupted":
			enemy_actor.show_floating_text("打断", Color(1.0, 0.85, 0.25, 1.0))
		"card_played":
			audio_manager.play_event("card_play")
		"defense_card_set":
			audio_manager.play_event("card_set")
			highlighted_slot_uid = str(event.get("card", {}).get("uid", ""))
		"card_placed_in_spell_zone":
			audio_manager.play_event("card_place")
			var placed_card: Dictionary = event.get("card", {})
			highlighted_slot_uid = str(placed_card.get("uid", ""))
			_flash_spell_slot(highlighted_slot_uid)
		"card_equipped":
			audio_manager.play_event("card_equip")
			var equipped_card: Dictionary = event.get("card", {})
			highlighted_equipment_uid = str(equipped_card.get("uid", ""))
			_flash_equipment_slot(highlighted_equipment_uid)
		"card_destroyed":
			audio_manager.play_event("card_break")
		"defense_card_activated":
			audio_manager.play_event("defense_activate")
			var card: Dictionary = event.get("card", {})
			highlighted_slot_uid = str(card.get("uid", ""))
			_flash_spell_slot(highlighted_slot_uid)
			player_actor.show_floating_text("发动 %s" % card.get("name", ""), Color(0.62, 0.78, 1.0, 1.0))
		"chain_started":
			audio_manager.play_event("chain_start")
		"chain_card_resolved":
			audio_manager.play_event("chain_resolve")
			var chain_card: Dictionary = event.get("card", {})
			_flash_spell_slot(str(chain_card.get("uid", "")))
			player_actor.show_floating_text("结算 %s" % chain_card.get("name", ""), Color(0.85, 0.72, 1.0, 1.0))

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
	var card := manager.deck.find_hand_card(uid)
	return card.duplicate(true) if not card.is_empty() else {}

func _hand_prefix_for_card(card: Dictionary) -> String:
	if card.is_empty():
		return ""
	if card.get("type", "") == CardDatabaseScript.TYPE_DEFENSE:
		return "盖伏"
	if str(card.get("after_use", "")) == "equipment":
		return "装备"
	return "使用"

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
	var card_type := str(card.get("type", ""))
	var after_use := str(card.get("after_use", ""))
	var border := Color(0.96, 0.68, 0.34, 1.0)
	if card_type == CardDatabaseScript.TYPE_DEFENSE:
		border = Color(0.58, 0.75, 1.0, 1.0)
	elif after_use == "equipment":
		border = Color(0.50, 0.92, 0.62, 1.0)
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
	log_toggle_button.text = "收起" if log_expanded else "日志"
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
	response_confirm_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.05, 0.058, 0.98), Color(0.95, 0.88, 0.62, 1.0), 8, 2))
	equipment_replace_hint_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.07, 0.055, 0.96), Color(0.42, 0.84, 0.56, 1.0), 8, 2))
	equipment_replace_hint_label.add_theme_font_size_override("font_size", 12)
	equipment_replace_hint_label.add_theme_color_override("font_color", Color(0.82, 1.0, 0.86, 1.0))
	chain_title_label.add_theme_font_size_override("font_size", 62)
	chain_title_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.72, 1.0))
	chain_title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
	chain_title_label.add_theme_constant_override("shadow_offset_x", 2)
	chain_title_label.add_theme_constant_override("shadow_offset_y", 3)
	chain_event_label.add_theme_font_size_override("font_size", 16)
	chain_event_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.95, 1.0))
	response_confirm_name_label.add_theme_font_size_override("font_size", 13)
	response_confirm_name_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.70, 1.0))
	if reward_scene is PanelContainer:
		(reward_scene as PanelContainer).add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.05, 0.058, 0.96), Color(0.58, 0.50, 0.32, 1.0), 8, 2))
	_style_button(normal_attack_button, Color(0.26, 0.13, 0.08, 1.0), Color(0.95, 0.54, 0.32, 1.0))
	_style_button(end_turn_button, Color(0.12, 0.18, 0.22, 1.0), Color(0.44, 0.70, 0.90, 1.0))
	_style_button(restart_button, Color(0.10, 0.10, 0.11, 0.94), Color(0.42, 0.44, 0.48, 1.0))
	_style_button(chain_skip_button, Color(0.10, 0.09, 0.07, 0.94), Color(0.88, 0.76, 0.44, 1.0))
	_style_button(response_confirm_activate_button, Color(0.24, 0.14, 0.06, 0.96), Color(0.96, 0.70, 0.32, 1.0))
	_style_button(response_confirm_cancel_button, Color(0.10, 0.10, 0.11, 0.96), Color(0.54, 0.56, 0.62, 1.0))
	_style_button(equipment_replace_cancel_button, Color(0.08, 0.10, 0.09, 0.94), Color(0.42, 0.84, 0.56, 1.0))
	_style_button(deck_pile_button, Color(0.11, 0.10, 0.08, 0.92), Color(0.74, 0.58, 0.30, 1.0))
	_style_button(graveyard_pile_button, Color(0.09, 0.09, 0.10, 0.92), Color(0.50, 0.54, 0.60, 1.0))
	_style_button(exile_pile_button, Color(0.12, 0.08, 0.12, 0.92), Color(0.72, 0.44, 0.86, 1.0))
	_style_button(log_toggle_button, Color(0.08, 0.09, 0.10, 0.92), Color(0.48, 0.52, 0.58, 1.0))

func _style_button(button: Button, bg: Color, border: Color) -> void:
	button.add_theme_stylebox_override("normal", _panel_style(bg, border, 6, 1))
	button.add_theme_stylebox_override("hover", _panel_style(bg.lightened(0.08), border.lightened(0.12), 6, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(bg.darkened(0.06), border.lightened(0.18), 6, 2))
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
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
