extends RefCounted
class_name BattleManager

signal combat_event(payload: Dictionary)

const JobDatabaseScript = preload("res://scripts/data/JobDatabase.gd")
const CardAcquisitionRulesScript = preload("res://scripts/run/CardAcquisitionRules.gd")
const RewardServiceScript = preload("res://scripts/run/RewardService.gd")
const PlayerStateScript = preload("res://scripts/battle/PlayerState.gd")
const EnemyStateScript = preload("res://scripts/battle/EnemyState.gd")
const DeckManagerScript = preload("res://scripts/battle/DeckManager.gd")
const CardResolverScript = preload("res://scripts/battle/CardResolver.gd")
const EffectResolverScript = preload("res://scripts/battle/EffectResolver.gd")
const BattleEncounterRuntimeScript = preload("res://scripts/battle/BattleEncounterRuntime.gd")
const BattleFormationScript = preload("res://scripts/battle/BattleFormation.gd")
const BattleUnitScript = preload("res://scripts/battle/BattleUnit.gd")
const BattleSideScript = preload("res://scripts/battle/BattleSide.gd")
const EnemyAIControllerScript = preload("res://scripts/battle/EnemyAIController.gd")
const BattleActionRulesScript = preload("res://scripts/battle/BattleActionRules.gd")

var player: PlayerState
var enemy: EnemyState
var formation
var player_side
var enemy_side
var deck: DeckManager
var resolver: CardResolver
var effect_resolver
var enemy_controller
var job_id := ""
var battle_number := 1
var turn_number := 0
var phase := "player"
var master_deck_ids: Array = []
var master_reserve_ids: Array = []
var reward_options: Array = []
var pending_choice: Dictionary = {}
var pending_equipment_replace: Dictionary = {}
var messages: Array = []
var rng := RandomNumberGenerator.new()
var current_event: Dictionary = {}
var chain_stack: Array = []
var response_loop_guard := 0
var auto_advance_after_reward := true
var current_encounter_type := "normal"
var current_realm_index := 0
var current_realm_name := "练气"
var draw_per_turn := 1
var deck_score_limit := 0
var meta_bonuses: Dictionary = {}
var selected_enemy_uid := ""
var selected_player_uid := ""
var selected_debug_uid := ""
var pending_target_action: Dictionary = {}
var enemy_action_queue: Array = []
var player_unit_actions_used: Dictionary = {}
var skip_next_player_turn_draw := false
var active_enemy_unit = null
var current_enemy_deck_profile: Dictionary = {}
var current_encounter_profile: Dictionary = {}
var enemy_cards_played_this_turn := 0
var enemy_card_play_limit := 0
var current_world_difficulty := 0

const MAX_CHAIN_ACTIONS := 32
const STATUS_BURN := "灼伤"
const STATUS_DELAY := "迟滞"
const STATUS_NEXT_DAMAGE_REDUCTION := "下次减伤"

func _init() -> void:
	player = PlayerStateScript.new()
	enemy = EnemyStateScript.new()
	formation = BattleFormationScript.new()
	player_side = BattleSideScript.new()
	enemy_side = BattleSideScript.new()
	deck = DeckManagerScript.new()
	resolver = CardResolverScript.new()
	effect_resolver = EffectResolverScript.new()
	enemy_controller = EnemyAIControllerScript.new()
	rng.randomize()

func start_run(selected_job_id: String) -> void:
	job_id = selected_job_id
	auto_advance_after_reward = true
	current_encounter_type = "normal"
	current_realm_index = 0
	current_realm_name = "练气"
	current_world_difficulty = 0
	draw_per_turn = 1
	deck_score_limit = 0
	meta_bonuses.clear()
	var job := JobDatabaseScript.get_job(job_id)
	player.setup_from_job(job)
	master_deck_ids = player.start_deck_from_job(job)
	master_reserve_ids.clear()
	battle_number = 1
	messages.clear()
	start_battle()

func start_run_with_deck(selected_job_id: String, deck_ids: Array, selected_battle_number := 1, encounter_type := "normal", auto_advance := false, run_context := {}) -> void:
	job_id = selected_job_id
	auto_advance_after_reward = auto_advance
	current_encounter_type = encounter_type
	current_realm_index = int(run_context.get("realm_index", 0))
	current_realm_name = str(run_context.get("realm_name", "练气"))
	current_world_difficulty = max(0, int(run_context.get("world_difficulty", 0)))
	draw_per_turn = max(1, int(run_context.get("draw_per_turn", 1)))
	deck_score_limit = int(run_context.get("deck_score_limit", 0))
	meta_bonuses = (run_context.get("meta_bonuses", {}) as Dictionary).duplicate(true)
	var job := JobDatabaseScript.get_job(job_id)
	player.setup_from_job(job)
	_apply_meta_bonuses()
	var context_max_hp := int(run_context.get("max_hp", -1))
	if context_max_hp > 0:
		player.max_hp = context_max_hp
	var context_current_hp := int(run_context.get("current_hp", -1))
	if context_current_hp >= 0:
		player.hp = clampi(context_current_hp, 0, player.max_hp)
	master_deck_ids = deck_ids.duplicate()
	master_reserve_ids = run_context.get("reserve_ids", []).duplicate()
	battle_number = max(1, int(selected_battle_number))
	messages.clear()
	start_battle()

func restart_run() -> void:
	if auto_advance_after_reward:
		start_run(job_id)
	else:
		start_run_with_deck(job_id, master_deck_ids, battle_number, current_encounter_type, false, {
			"current_hp": player.hp,
			"max_hp": player.max_hp,
			"draw_per_turn": draw_per_turn,
			"deck_score_limit": deck_score_limit,
			"reserve_ids": master_reserve_ids.duplicate(),
			"realm_index": current_realm_index,
			"realm_name": current_realm_name,
			"world_difficulty": current_world_difficulty,
			"meta_bonuses": meta_bonuses.duplicate(true)
		})

func _apply_meta_bonuses() -> void:
	if meta_bonuses.is_empty():
		return
	player.max_hp += int(meta_bonuses.get("max_hp", 0))
	player.hp = player.max_hp
	player.attack += int(meta_bonuses.get("attack", 0))
	player.defense += int(meta_bonuses.get("defense", 0))

func start_battle() -> void:
	pending_choice.clear()
	pending_equipment_replace.clear()
	pending_target_action.clear()
	enemy_action_queue.clear()
	player_unit_actions_used.clear()
	reward_options.clear()
	current_event.clear()
	chain_stack.clear()
	active_enemy_unit = null
	current_enemy_deck_profile.clear()
	current_encounter_profile = _select_encounter_profile()
	enemy_cards_played_this_turn = 0
	enemy_card_play_limit = 0
	phase = "player"
	turn_number = 0
	player.reset_for_battle()
	enemy = EnemyStateScript.new()
	enemy.setup(_enemy_data_for_current_battle())
	current_enemy_deck_profile = _enemy_deck_profile_from_encounter()
	formation.setup_primary(player, enemy)
	_add_extra_enemy_units_from_encounter()
	_setup_battle_sides()
	selected_enemy_uid = enemy.uid
	selected_player_uid = player.uid
	selected_debug_uid = enemy.uid
	player_side.setup_deck(master_deck_ids)
	enemy_side.setup_deck(_enemy_deck_for_current_encounter())
	add_log("%s，第 %d 场战斗：%s。" % [current_realm_name, battle_number, enemy.name])
	if player.hp <= 0:
		player.hp = 0
		phase = "defeat"
		add_log("玩家生命为 0，无法进入战斗。")
		return
	_draw_player_cards(5, "opening")
	skip_next_player_turn_draw = true
	_flush_deck_messages()
	start_player_turn()

func _add_extra_enemy_units_from_encounter() -> void:
	var units: Array = current_encounter_profile.get("enemy_units", [])
	for i in range(1, units.size()):
		var data: Dictionary = units[i]
		var unit = EnemyStateScript.new()
		unit.setup(data)
		formation.add_unit(unit, BattleUnitScript.TEAM_ENEMY, int(data.get("slot_index", -1)))

func _setup_battle_sides() -> void:
	player_side.setup("player", BattleUnitScript.TEAM_PLAYER, player, formation.player_units, deck)
	player_side.bind_player_state(player)
	player_side.draw_per_turn = draw_per_turn
	player_side.visible_zones = {
		"spell_zone": true,
		"hand": true,
		"deck": true,
		"graveyard": true,
		"exile": true
	}
	enemy_side.setup("enemy", BattleUnitScript.TEAM_ENEMY, enemy, formation.enemy_units)
	enemy_side.reset_visible_zones()
	enemy_side.draw_per_turn = _enemy_draw_for_current_encounter()
	enemy_side.visible_zones = {
		"spell_zone": true,
		"hand": false,
		"deck": false,
		"graveyard": false,
		"exile": false
	}
	var starting_sword: int = int(meta_bonuses.get("starting_sword", 0))
	if starting_sword > 0 and player.job_id == "sword":
		player.add_sword(starting_sword)
		add_log("局外成长：开局获得 %d 点剑势。" % starting_sword)

func _refresh_side_unit_refs() -> void:
	if player_side != null:
		player_side.set_units(formation.player_units)
	if enemy_side != null:
		enemy_side.set_units(formation.enemy_units)

func _cleanup_defeated_units() -> void:
	var removed_units: Array = formation.remove_defeated_units()
	if removed_units.is_empty():
		return
	var removed_uids: Dictionary = {}
	for unit in removed_units:
		if unit == null:
			continue
		var uid := str(unit.uid)
		removed_uids[uid] = true
		player_unit_actions_used.erase(uid)
		add_log("%s 阵亡退场。" % _unit_display_name(unit))
	if removed_uids.has(selected_enemy_uid):
		selected_enemy_uid = ""
	if removed_uids.has(selected_player_uid):
		selected_player_uid = ""
	if removed_uids.has(selected_debug_uid):
		selected_debug_uid = ""
	if not pending_target_action.is_empty() and removed_uids.has(str(pending_target_action.get("source_uid", ""))):
		pending_target_action.clear()
		if phase == "target_select":
			phase = "player"
	for i in range(enemy_action_queue.size() - 1, -1, -1):
		var queued_unit = enemy_action_queue[i]
		if queued_unit == null or removed_uids.has(str(queued_unit.uid)):
			enemy_action_queue.remove_at(i)
	_refresh_side_unit_refs()

func _enemy_draw_for_current_encounter() -> int:
	return BattleEncounterRuntimeScript.draw_per_turn(current_encounter_profile, current_encounter_type)

func _enemy_deck_for_current_encounter() -> Array:
	var profile: Dictionary = _enemy_deck_profile()
	return profile.get("deck", []).duplicate()

func _enemy_card_play_limit_for_current_encounter() -> int:
	return BattleEncounterRuntimeScript.card_play_limit(current_encounter_profile, current_encounter_type)

func _current_layer_index() -> int:
	return max(1, current_realm_index + 1)

func _enemy_deck_profile() -> Dictionary:
	if current_enemy_deck_profile.is_empty():
		current_enemy_deck_profile = _enemy_deck_profile_from_encounter()
	return current_enemy_deck_profile

func _enemy_deck_profile_from_encounter() -> Dictionary:
	if current_encounter_profile.is_empty():
		current_encounter_profile = _select_encounter_profile()
	return BattleEncounterRuntimeScript.deck_profile(current_encounter_profile)

func _select_encounter_profile() -> Dictionary:
	return BattleEncounterRuntimeScript.select_encounter(
		battle_number,
		current_encounter_type,
		current_realm_index,
		current_world_difficulty,
		rng
	)

func start_player_turn() -> void:
	if phase == "defeat":
		return
	phase = "player"
	turn_number += 1
	emit_combat_event({"type": "turn_started", "side": "player", "label": "我方回合"})
	_clear_player_temporary_defense()
	_reset_player_unit_actions()
	player.start_turn()
	add_log("玩家第 %d 回合开始。" % turn_number)
	resolver.apply_player_turn_start(self)
	if check_victory_or_defeat():
		return
	if skip_next_player_turn_draw:
		skip_next_player_turn_draw = false
	else:
		_draw_player_cards(draw_per_turn, "turn")
	_flush_deck_messages()
	enemy.current_intent = enemy.peek_action().get("intent", "")

func play_hand_card(uid: String) -> void:
	resolver.play_hand_card(self, uid)

func play_hand_card_on_enemy_target(uid: String, target_uid: String) -> void:
	if not select_enemy_target(target_uid):
		add_log("没有可选择的敌方目标。")
		return
	resolver.play_spell_card(self, uid, true)

func play_hand_card_on_unit_target(uid: String, target_uid: String) -> void:
	var target_unit = formation.unit_by_uid(target_uid)
	if target_unit == null or int(target_unit.hp) <= 0:
		add_log("没有可装备的目标。")
		return
	if str(target_unit.team) == BattleUnitScript.TEAM_PLAYER:
		selected_player_uid = str(target_unit.uid)
	elif str(target_unit.team) == BattleUnitScript.TEAM_ENEMY:
		selected_enemy_uid = str(target_unit.uid)
	selected_debug_uid = str(target_unit.uid)
	resolver.play_spell_card(self, uid, true, {"equipment_target_uid": str(target_unit.uid), "target_unit": target_unit})

func activate_spell_zone_card(uid: String) -> void:
	resolver.activate_spell_zone_card(self, uid)

func get_pending_options() -> Array:
	return resolver.get_pending_options(self)

func choose_pending(uid: String) -> void:
	resolver.choose_pending(self, uid)

func choose_equipment_replacement(uid: String) -> void:
	resolver.choose_equipment_replacement(self, uid)

func cancel_equipment_replacement() -> void:
	if pending_equipment_replace.is_empty():
		return
	pending_equipment_replace.clear()
	add_log("取消装备替换。")

func player_normal_attack() -> void:
	player_unit_attack(player.uid)

func player_unit_attack(unit_uid: String) -> void:
	if phase != "player":
		add_log("现在不是玩家回合。")
		return
	if not pending_choice.is_empty():
		add_log("请先完成当前选择。")
		return
	if not pending_equipment_replace.is_empty():
		add_log("请先完成装备替换。")
		return
	var source_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, unit_uid)
	if source_unit == null:
		add_log("没有可行动的我方单位。")
		return
	if player_unit_action_used(source_unit):
		add_log("%s 本回合已经行动过。" % _unit_display_name(source_unit))
		return
	if enemy_target_count() > 1 and not BattleActionRulesScript.player_attack_uses_auto_targets(player, source_unit):
		begin_enemy_target_selection({"type": "unit_attack", "source_uid": str(source_unit.uid)}, "选择攻击目标")
		return
	_perform_player_unit_attack(source_unit)

func _perform_player_normal_attack() -> void:
	_perform_player_unit_attack(player)

func _perform_player_unit_attack(source_unit) -> void:
	if source_unit == null or str(source_unit.team) != BattleUnitScript.TEAM_PLAYER:
		add_log("没有可行动的我方单位。")
		return
	if player_unit_action_used(source_unit):
		add_log("%s 本回合已经行动过。" % _unit_display_name(source_unit))
		return
	_mark_player_unit_action_used(source_unit)
	var hit_count: int = _perform_basic_attack_hits(source_unit)
	if hit_count > 0 and source_unit == player and player.job_id == "sword":
		var sword_gain: int = 1 + player.extra_sword_on_attack_hit
		add_unit_resource(player, "sword_momentum", sword_gain, "普通攻击")
		add_log("剑修普通攻击命中：获得 %d 点剑势。" % sword_gain)
	check_victory_or_defeat()

func _perform_basic_attack_hits(source_unit) -> int:
	var targets: Array = BattleActionRulesScript.basic_attack_targets(self, source_unit)
	if targets.is_empty():
		add_log("没有可攻击的敌方目标。")
		BattleActionRulesScript.clear_consumed_attack_modifiers(player, source_unit)
		return 0
	var hits := 0
	for target in targets:
		if target == null or int(target.hp) <= 0:
			continue
		emit_combat_event({"type": "attack_started", "source": _unit_event_key(source_unit), "target": _unit_event_key(target)})
		var damage: int = BattleActionRulesScript.basic_attack_damage(player, source_unit, target)
		if damage <= 0:
			add_log("%s 攻击 %s 未造成伤害。" % [_unit_display_name(source_unit), _unit_display_name(target)])
			emit_combat_event({"type": "attack_finished", "source": _unit_event_key(source_unit), "target": _unit_event_key(target)})
			continue
		apply_damage_to_unit(target, damage, "normal_attack")
		hits += 1
		add_log("%s 攻击 %s，造成 %d 点伤害。" % [_unit_display_name(source_unit), _unit_display_name(target), damage])
		emit_combat_event({"type": "attack_finished", "source": _unit_event_key(source_unit), "target": _unit_event_key(target)})
		_cleanup_defeated_units()
		if formation.all_enemies_defeated():
			break
	BattleActionRulesScript.clear_consumed_attack_modifiers(player, source_unit)
	return hits

func player_unit_defend(unit_uid: String) -> void:
	if phase != "player":
		add_log("现在不是玩家回合。")
		return
	if not pending_choice.is_empty():
		add_log("请先完成当前选择。")
		return
	if not pending_equipment_replace.is_empty():
		add_log("请先完成装备替换。")
		return
	var source_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, unit_uid)
	if source_unit == null:
		add_log("没有可防御的我方单位。")
		return
	if player_unit_action_used(source_unit):
		add_log("%s 本回合已经行动过。" % _unit_display_name(source_unit))
		return
	var defense_bonus: int = BattleActionRulesScript.defense_bonus_for_unit(source_unit)
	source_unit.temp_defense_delta += defense_bonus
	_mark_player_unit_action_used(source_unit)
	add_log("%s 进入防御，防御力 +%d，持续到下个玩家回合开始。" % [_unit_display_name(source_unit), defense_bonus])
	emit_combat_event({"type": "unit_defended", "target": _unit_event_key(source_unit), "value": defense_bonus})

func begin_enemy_target_selection(action: Dictionary, prompt := "选择敌方目标") -> void:
	if enemy_target_count() <= 1:
		return
	pending_target_action = action.duplicate(true)
	pending_target_action["prompt"] = prompt
	phase = "target_select"
	var current_target = selected_enemy_unit()
	if current_target != null:
		selected_enemy_uid = str(current_target.uid)
	add_log(prompt)

func confirm_target_selection(uid: String) -> void:
	if phase != "target_select":
		select_enemy_target(uid)
		return
	if not select_enemy_target(uid):
		return
	var action := pending_target_action.duplicate(true)
	pending_target_action.clear()
	phase = "player"
	match str(action.get("type", "")):
		"normal_attack":
			_perform_player_normal_attack()
		"unit_attack":
			var source_unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, str(action.get("source_uid", "")))
			_perform_player_unit_attack(source_unit)
		"hand_card":
			resolver.play_spell_card(self, str(action.get("uid", "")), true)
		_:
			add_log("未识别的目标选择动作。")

func player_unit_action_used(unit) -> bool:
	if unit == null:
		return true
	return int(player_unit_actions_used.get(str(unit.uid), 0)) >= _player_unit_action_limit(unit)

func _mark_player_unit_action_used(unit) -> void:
	if unit == null:
		return
	var uid := str(unit.uid)
	player_unit_actions_used[uid] = int(player_unit_actions_used.get(uid, 0)) + 1
	if unit == player:
		player.normal_attack_used = player_unit_action_used(unit)

func _player_unit_action_limit(unit) -> int:
	if unit == player:
		return player.basic_attack_limit()
	return 1

func _reset_player_unit_actions() -> void:
	player_unit_actions_used.clear()
	player.normal_attack_used = false

func _clear_player_temporary_defense() -> void:
	for unit in formation.living_units(BattleUnitScript.TEAM_PLAYER):
		if unit != null:
			unit.temp_defense_delta = 0

func cancel_target_selection() -> void:
	if phase != "target_select":
		return
	pending_target_action.clear()
	phase = "player"
	add_log("取消目标选择。")

func enemy_target_count() -> int:
	return formation.living_units(BattleUnitScript.TEAM_ENEMY).size()

func player_target_count() -> int:
	return formation.living_units(BattleUnitScript.TEAM_PLAYER).size()

func add_enemy_unit(data: Dictionary, preferred_slot := -1) -> bool:
	var unit = EnemyStateScript.new()
	unit.setup(data)
	var added: bool = formation.add_unit(unit, BattleUnitScript.TEAM_ENEMY, preferred_slot)
	if added and selected_enemy_unit() == null:
		selected_enemy_uid = unit.uid
	if added:
		selected_debug_uid = unit.uid
		_refresh_side_unit_refs()
	return added

func add_player_summon(data: Dictionary, preferred_slot := -1) -> bool:
	var unit = BattleUnitScript.new()
	var uid := str(data.get("uid", "summon_%d_%d" % [Time.get_ticks_usec(), rng.randi()]))
	var unit_data: Dictionary = {
		"id": data.get("id", "summon"),
		"uid": uid,
		"name": data.get("name", "召唤物"),
		"team": BattleUnitScript.TEAM_PLAYER,
		"unit_type": data.get("unit_type", BattleUnitScript.TYPE_SUMMON),
		"unit_rank": data.get("unit_rank", BattleUnitScript.RANK_NORMAL),
		"slot_index": int(data.get("slot_index", 2)),
		"max_hp": int(data.get("max_hp", 1)),
		"hp": int(data.get("hp", data.get("max_hp", 1))),
		"attack": int(data.get("attack", 0)),
		"defense": int(data.get("defense", 0)),
		"equipment": data.get("equipment", []),
		"status_counters": data.get("status_counters", {}),
		"resource_counters": data.get("resource_counters", {})
	}
	if data.has("equipment_limit"):
		unit_data["equipment_limit"] = int(data.get("equipment_limit", 1))
	unit.setup_unit(unit_data, BattleUnitScript.TEAM_PLAYER, BattleUnitScript.TYPE_SUMMON)
	var added: bool = formation.add_unit(unit, BattleUnitScript.TEAM_PLAYER, preferred_slot)
	if added:
		selected_player_uid = unit.uid
		selected_debug_uid = unit.uid
		_refresh_side_unit_refs()
	return added

func summon_units(unit_team: String, data: Dictionary, count: int) -> int:
	var added_count := 0
	for i in range(max(0, count)):
		var unit_data: Dictionary = data.duplicate(true)
		unit_data["uid"] = "%s_%d_%d" % [str(unit_data.get("id", "summon")), Time.get_ticks_usec(), i]
		if unit_team == BattleUnitScript.TEAM_PLAYER:
			if add_player_summon(unit_data):
				added_count += 1
	return added_count

func select_enemy_target(uid: String) -> bool:
	var unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_ENEMY, uid)
	if unit == null:
		return false
	selected_enemy_uid = str(unit.uid)
	selected_debug_uid = str(unit.uid)
	return true

func select_player_target(uid: String) -> bool:
	var unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, uid)
	if unit == null:
		return false
	selected_player_uid = str(unit.uid)
	selected_debug_uid = str(unit.uid)
	return true

func select_debug_target(uid: String) -> bool:
	var unit = formation.unit_by_uid(uid)
	if unit == null or int(unit.hp) <= 0:
		return false
	selected_debug_uid = str(unit.uid)
	return true

func selected_enemy_unit():
	var unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_ENEMY, selected_enemy_uid)
	if unit != null:
		return unit
	unit = formation.primary_enemy()
	selected_enemy_uid = "" if unit == null else str(unit.uid)
	return unit

func selected_player_unit():
	var unit = formation.living_unit_by_uid(BattleUnitScript.TEAM_PLAYER, selected_player_uid)
	if unit != null:
		return unit
	unit = formation.primary_player()
	selected_player_uid = "" if unit == null else str(unit.uid)
	return unit

func selected_debug_unit():
	var unit = formation.unit_by_uid(selected_debug_uid)
	if unit != null and int(unit.hp) > 0:
		return unit
	unit = selected_enemy_unit()
	if unit != null:
		selected_debug_uid = str(unit.uid)
		return unit
	unit = selected_player_unit()
	if unit != null:
		selected_debug_uid = str(unit.uid)
	return unit

func clear_extra_enemy_units() -> void:
	formation.enemy_units.clear()
	formation.add_unit(enemy, BattleUnitScript.TEAM_ENEMY, 2)
	selected_enemy_uid = enemy.uid
	selected_debug_uid = enemy.uid
	_refresh_side_unit_refs()

func clear_extra_player_units() -> void:
	formation.player_units.clear()
	formation.add_unit(player, BattleUnitScript.TEAM_PLAYER, 2)
	selected_player_uid = player.uid
	selected_debug_uid = player.uid
	_refresh_side_unit_refs()

func debug_add_enemy() -> bool:
	var index: int = formation.enemy_units.size()
	return add_enemy_unit({
		"id": "debug_enemy_%d" % index,
		"name": "测试妖 %d" % index,
		"max_hp": 18,
		"attack": 5,
		"defense": 1,
		"action_sequence": [
			{"kind": "normal_attack", "intent": "攻击"}
		]
	}, -1)

func debug_add_ally() -> bool:
	var index: int = formation.player_units.size()
	return add_player_summon({
		"id": "debug_ally_%d" % index,
		"name": "测试幻象 %d" % index,
		"max_hp": 6,
		"attack": 0,
		"defense": 0
	}, -1)

func end_player_turn() -> void:
	if phase != "player":
		return
	if not pending_choice.is_empty():
		add_log("请先完成当前选择。")
		return
	if not pending_equipment_replace.is_empty():
		add_log("请先完成装备替换。")
		return
	resolver.ready_defenses_after_player_turn(self)
	player.end_turn()
	_tick_turn_end_statuses_for_team(BattleUnitScript.TEAM_PLAYER)
	if check_victory_or_defeat():
		return
	_start_enemy_turn()

func _start_enemy_turn() -> void:
	phase = "enemy"
	emit_combat_event({"type": "turn_started", "side": "enemy", "label": "敌方回合"})
	enemy_cards_played_this_turn = 0
	enemy_card_play_limit = _enemy_card_play_limit_for_current_encounter()
	_draw_enemy_cards(enemy_side.draw_per_turn)
	enemy_action_queue = enemy_controller.action_queue_for_units(formation.living_units(BattleUnitScript.TEAM_ENEMY))
	if _try_enemy_play_next_side_card():
		return
	_continue_enemy_turn()

func _continue_enemy_turn() -> void:
	if phase == "reward" or phase == "defeat":
		return
	while not enemy_action_queue.is_empty():
		var acting_unit = enemy_action_queue.pop_front()
		if acting_unit == null or int(acting_unit.hp) <= 0:
			continue
		_take_enemy_unit_turn(acting_unit)
		return
	start_player_turn()

func _take_enemy_unit_turn(source_unit) -> void:
	active_enemy_unit = source_unit
	enemy_controller.prepare_unit_turn(self, source_unit)
	_apply_zone_enemy_action_start_effects(source_unit)
	if check_victory_or_defeat():
		return
	var action: Dictionary = enemy_controller.next_unit_action(self, source_unit)
	var intent := str(action.get("intent", ""))
	add_log("%s 行动：%s。" % [_unit_display_name(source_unit), intent])
	match action.get("kind", ""):
		"normal_attack":
			_enemy_attack(source_unit, source_unit.current_attack())
		"charge":
			add_log("%s 正在蓄力。" % _unit_display_name(source_unit))
			_finish_enemy_action()
		"strong_attack":
			_enemy_attack(source_unit, source_unit.current_attack() + int(action.get("attack_bonus", 0)))
		"defense_stance":
			var defense_bonus: int = int(action.get("defense_delta", 0))
			if defense_bonus <= 0:
				defense_bonus = BattleActionRulesScript.defense_bonus_for_unit(source_unit)
			source_unit.temp_defense_delta = defense_bonus
			add_log("%s 防御力 +%d，持续 1 回合。" % [_unit_display_name(source_unit), source_unit.temp_defense_delta])
			_finish_enemy_action()
		"weakness":
			source_unit.temp_defense_delta = int(action.get("defense_delta", 0))
			add_log("%s 防御力 %d，持续 1 回合。" % [_unit_display_name(source_unit), source_unit.temp_defense_delta])
			_finish_enemy_action()
		"destroy_spell_zone":
			_enemy_destroy_spell_zone(source_unit)
		"spell_attack":
			_enemy_spell_attack(source_unit)
		"skill":
			_enemy_use_skill(source_unit, action)
		_:
			_finish_enemy_action()

func _enemy_attack(source_unit, power: int) -> void:
	var target = choose_single_target(BattleUnitScript.TEAM_PLAYER)
	if target == null:
		add_log("敌人没有可攻击的目标。")
		_finish_enemy_action()
		return
	var final_power: int = _consume_delay_status_for_power(source_unit, power)
	add_log("%s 准备攻击 %s。" % [_unit_display_name(source_unit), _unit_display_name(target)])
	emit_combat_event({"type": "enemy_intent_started", "intent": "攻击"})
	open_timing_window(create_event("enemy_attack_declared", source_unit, target, final_power))

func _enemy_spell_attack(source_unit) -> void:
	var target = choose_single_target(BattleUnitScript.TEAM_PLAYER)
	if target == null:
		add_log("敌人没有可施法目标。")
		_finish_enemy_action()
		return
	var final_power: int = _consume_delay_status_for_power(source_unit, source_unit.current_attack())
	add_log("%s 准备对 %s 施法。" % [_unit_display_name(source_unit), _unit_display_name(target)])
	emit_combat_event({"type": "enemy_intent_started", "intent": "施法"})
	open_timing_window(create_event("enemy_spell_declared", source_unit, target, final_power))

func _enemy_destroy_spell_zone(source_unit) -> void:
	if player.spell_zone.is_empty():
		add_log("法防区为空，敌人没有破坏目标。")
		_finish_enemy_action()
		return
	var card: Dictionary = player.spell_zone[0]
	add_log("%s 准备破坏法防区的 %s。" % [_unit_display_name(source_unit), card.get("name", "")])
	emit_combat_event({"type": "enemy_intent_started", "intent": "破坏法防区"})
	open_timing_window(create_event("enemy_destroy_zone_card_declared", source_unit, card, 1))

func _enemy_use_skill(source_unit, action: Dictionary) -> void:
	var skill_id := str(action.get("skill_id", ""))
	if source_unit == null:
		_finish_enemy_action()
		return
	if not source_unit.has_method("skill_for_action") or not source_unit.has_method("skill_ready"):
		add_log("%s 没有可用技能，改为普通攻击。" % _unit_display_name(source_unit))
		_enemy_attack(source_unit, source_unit.current_attack())
		return
	var skill: Dictionary = source_unit.call("skill_for_action", action)
	if skill.is_empty() or not bool(source_unit.call("skill_ready", skill_id)):
		add_log("%s 技能未就绪，改为普通攻击。" % _unit_display_name(source_unit))
		_enemy_attack(source_unit, source_unit.current_attack())
		return
	var skill_name := str(skill.get("name", action.get("intent", "技能")))
	add_log("%s 发动技能：%s。" % [_unit_display_name(source_unit), skill_name])
	effect_resolver.apply_steps(self, source_unit, skill.get("effect_steps", []), {"action": action})
	if source_unit.has_method("put_skill_on_cooldown"):
		source_unit.call("put_skill_on_cooldown", skill_id)
	_finish_enemy_action()

func _try_enemy_play_next_side_card() -> bool:
	if enemy_side == null or enemy_side.deck_manager == null:
		return false
	if enemy_cards_played_this_turn >= enemy_card_play_limit:
		return false
	var source_unit = enemy_controller.side_card_source_unit(self)
	if source_unit == null:
		return false
	var card: Dictionary = enemy_controller.select_next_side_card(self, source_unit)
	if card.is_empty():
		return false
	enemy_cards_played_this_turn += 1
	return _play_enemy_card(source_unit, card)

func _play_enemy_card(source_unit, card: Dictionary) -> bool:
	if enemy_side == null or enemy_side.deck_manager == null:
		return false
	var card_id := str(card.get("id", ""))
	var removed: Dictionary = enemy_side.deck_manager.remove_from_hand(str(card.get("uid", "")))
	if removed.is_empty():
		return false
	add_log("敌方阵营使用卡：%s。" % removed.get("name", card_id))
	emit_combat_event({"type": "enemy_card_played", "source": _unit_event_key(source_unit), "card": removed})
	if card_id == "铁木甲":
		return _play_enemy_equipment_card(source_unit, removed)
	return _play_enemy_spell_card(source_unit, removed)

func _play_enemy_equipment_card(source_unit, card: Dictionary) -> bool:
	source_unit.equipment.append(card)
	_apply_enemy_equipment_effect_recursive(source_unit, card.get("effect", {}))
	add_log("%s 装备 %s。" % [_unit_display_name(source_unit), card.get("name", "装备")])
	_finish_enemy_side_card()
	return true

func _apply_enemy_equipment_effect_recursive(source_unit, effect: Dictionary) -> void:
	match str(effect.get("kind", "")):
		"equipment_attack_bonus":
			source_unit.equipment_attack_bonus += int(effect.get("value", 0))
		"equipment_defense_bonus":
			source_unit.equipment_defense_bonus += int(effect.get("value", 0))
		"multi":
			for sub_effect_variant in effect.get("effects", []):
				var sub_effect: Dictionary = sub_effect_variant
				_apply_enemy_equipment_effect_recursive(source_unit, sub_effect)

func _play_enemy_spell_card(source_unit, card: Dictionary) -> bool:
	var profile: Dictionary = enemy_controller.side_card_profile(str(card.get("id", "")))
	if profile.is_empty():
		_move_enemy_card_to_graveyard(card)
		_finish_enemy_side_card()
		return true
	var target = choose_single_target(BattleUnitScript.TEAM_PLAYER)
	if target == null:
		_move_enemy_card_to_graveyard(card)
		_finish_enemy_side_card()
		return true
	_move_enemy_card_to_graveyard(card)
	var base_damage: int = int(profile.get("damage", 0))
	var final_power: int = _consume_delay_status_for_power(source_unit, base_damage) if base_damage > 0 else 0
	var event := create_event("enemy_spell_declared", source_unit, target, final_power)
	event["spell_name"] = str(card.get("name", "敌方卡"))
	event["post_steps"] = profile.get("post_steps", []).duplicate(true)
	event["post_source_unit"] = source_unit
	event["enemy_side_card"] = true
	open_timing_window(event)
	return true

func _move_enemy_card_to_graveyard(card: Dictionary) -> void:
	if enemy_side == null or enemy_side.deck_manager == null:
		return
	enemy_side.deck_manager.add_to_graveyard(card)

func create_event(event_type: String, source, target, value := 0) -> Dictionary:
	return {
		"event_type": event_type,
		"source": source,
		"target": target,
		"source_key": _unit_event_key(source) if _is_battle_unit(source) else str(source),
		"target_key": _unit_event_key(target) if _is_battle_unit(target) else str(target),
		"value": int(value),
		"cancelled": false,
		"modifiers": [],
		"protected_targets": []
	}

func resolve_target_units(target_rule: String, source_unit = null, context := {}) -> Array:
	match target_rule:
		"self":
			return [] if source_unit == null else [source_unit]
		"player":
			if source_unit != null and source_unit.team == BattleUnitScript.TEAM_ENEMY:
				var ai_player_target = choose_single_target(BattleUnitScript.TEAM_PLAYER)
				return [] if ai_player_target == null else [ai_player_target]
			var player_unit = formation.primary_player()
			return [] if player_unit == null else [player_unit]
		"primary_player":
			var player_unit = formation.primary_player()
			return [] if player_unit == null else [player_unit]
		"ally", "single_ally":
			if source_unit == null:
				return []
			var ally_target = choose_single_target(str(source_unit.team))
			return [] if ally_target == null else [ally_target]
		"enemy", "primary_enemy":
			var enemy_unit = selected_enemy_unit()
			return [] if enemy_unit == null else [enemy_unit]
		"all_players":
			return formation.living_units(BattleUnitScript.TEAM_PLAYER)
		"all_enemies":
			return formation.living_units(BattleUnitScript.TEAM_ENEMY)
		"opponent":
			if source_unit != null and source_unit.team == BattleUnitScript.TEAM_ENEMY:
				var target_player = choose_single_target(BattleUnitScript.TEAM_PLAYER)
				return [] if target_player == null else [target_player]
			var target_enemy = formation.primary_enemy()
			return [] if target_enemy == null else [target_enemy]
		"context_target":
			var context_target = context.get("target_unit", null)
			return [] if context_target == null else [context_target]
	return []

func choose_single_target(unit_team: String):
	var candidates: Array = formation.living_units(unit_team)
	if candidates.is_empty():
		return null
	var taunt_candidates: Array = []
	for unit in candidates:
		if unit != null and unit.get_status("taunt") > 0:
			taunt_candidates.append(unit)
	if not taunt_candidates.is_empty():
		candidates = taunt_candidates
	if candidates.size() == 1:
		return candidates[0]
	return candidates[rng.randi_range(0, candidates.size() - 1)]

func apply_damage_to_unit(unit, amount: int, source_name := "伤害") -> int:
	if unit == null:
		return 0
	var applied: int = unit.apply_damage(amount)
	emit_combat_event({"type": "damage_applied", "target": _unit_event_key(unit), "value": applied, "source": source_name})
	return applied

func heal_unit(unit, amount: int, source_name := "治疗") -> int:
	if unit == null:
		return 0
	var healed: int = unit.heal(amount)
	add_log("%s：%s 回复 %d 点生命。" % [source_name, _unit_display_name(unit), healed])
	emit_combat_event({"type": "heal_applied", "target": _unit_event_key(unit), "value": healed, "source": source_name})
	return healed

func modify_unit_stat(unit, stat: String, amount: int, temporary := false, source_name := "效果") -> void:
	if unit == null:
		return
	match stat:
		"attack":
			if temporary:
				unit.temp_attack_delta += amount
			else:
				unit.attack += amount
		"defense":
			if temporary:
				unit.temp_defense_delta += amount
			else:
				unit.defense += amount
		_:
			return
	add_log("%s：%s %s %+d。" % [source_name, _unit_display_name(unit), _stat_display_name(stat), amount])

func add_unit_resource(unit, resource_id: String, amount: int, source_name := "效果") -> int:
	if unit == null:
		return 0
	var next_value: int = 0
	if unit == player and resource_id in ["sword", "sword_momentum"]:
		player.add_sword(amount)
		next_value = player.sword_momentum
		emit_combat_event({"type": "sword_power_changed", "target": "player", "value": amount, "source": source_name})
	else:
		next_value = unit.add_resource(resource_id, amount)
		emit_combat_event({"type": "resource_changed", "target": _unit_event_key(unit), "resource": resource_id, "value": amount, "source": source_name})
	return next_value

func add_unit_status(unit, status_id: String, amount: int, source_name := "效果") -> int:
	if unit == null:
		return 0
	var next_value: int = unit.add_status(status_id, amount)
	add_log("%s：%s %s %+d。" % [source_name, _unit_display_name(unit), status_id, amount])
	emit_combat_event({"type": "status_changed", "target": _unit_event_key(unit), "status": status_id, "value": amount, "source": source_name})
	return next_value

func _tick_turn_end_statuses_for_team(unit_team: String) -> void:
	for unit in formation.living_units(unit_team):
		_tick_turn_end_statuses_for_unit(unit)

func _tick_turn_end_statuses_for_unit(unit) -> void:
	if unit == null or int(unit.hp) <= 0:
		return
	var burn: int = int(unit.get_status(STATUS_BURN))
	if burn > 0:
		apply_damage_to_unit(unit, burn, STATUS_BURN)
		add_log("%s：%s 受到 %d 点伤害。" % [STATUS_BURN, _unit_display_name(unit), burn])
		add_unit_status(unit, STATUS_BURN, -1, "状态结算")
	for status_id in ["破甲", "虚弱"]:
		if int(unit.get_status(status_id)) > 0:
			add_unit_status(unit, status_id, -1, "状态结算")

func _consume_delay_status_for_power(unit, power: int) -> int:
	if unit == null:
		return max(0, power)
	var delay: int = int(unit.get_status(STATUS_DELAY))
	if delay <= 0:
		return max(0, power)
	var final_power: int = max(0, power - delay)
	unit.add_status(STATUS_DELAY, -delay)
	add_log("%s：%s 本次行动威力 %d -> %d。" % [STATUS_DELAY, _unit_display_name(unit), power, final_power])
	emit_combat_event({"type": "status_changed", "target": _unit_event_key(unit), "status": STATUS_DELAY, "value": -delay, "source": STATUS_DELAY})
	return final_power

func _apply_next_damage_reduction_status(event: Dictionary, target_unit) -> void:
	if target_unit == null:
		return
	var reduction: int = int(target_unit.get_status(STATUS_NEXT_DAMAGE_REDUCTION))
	if reduction <= 0:
		return
	var before: int = int(event.get("value", 0))
	var after: int = max(0, before - reduction)
	event["value"] = after
	target_unit.add_status(STATUS_NEXT_DAMAGE_REDUCTION, -reduction)
	add_log("%s：%s 本次伤害 %d -> %d。" % [STATUS_NEXT_DAMAGE_REDUCTION, _unit_display_name(target_unit), before, after])
	emit_combat_event({"type": "damage_reduced", "target": _unit_event_key(target_unit), "value": before - after, "source": STATUS_NEXT_DAMAGE_REDUCTION})

func _apply_zone_damage_reduction(event: Dictionary, target_unit) -> void:
	if target_unit == null:
		return
	for card_variant in player.spell_zone.duplicate():
		var card: Dictionary = card_variant
		var effect: Dictionary = card.get("effect", {})
		if str(effect.get("kind", "")) != "zone_damage_reduction":
			continue
		if int(card.get("last_zone_trigger_turn", -1)) == turn_number:
			continue
		var before: int = int(event.get("value", 0))
		var reduction: int = int(effect.get("value", 0))
		var after: int = max(0, before - reduction)
		event["value"] = after
		card["last_zone_trigger_turn"] = turn_number
		add_log("%s：%s 本次伤害 %d -> %d。" % [card.get("name", "放置牌"), _unit_display_name(target_unit), before, after])
		emit_combat_event({"type": "damage_reduced", "target": _unit_event_key(target_unit), "value": before - after, "source": card.get("name", "")})
		if card.has("zone_uses_remaining"):
			card["zone_uses_remaining"] = max(0, int(card.get("zone_uses_remaining", 0)) - 1)
			if int(card.get("zone_uses_remaining", 0)) <= 0:
				resolver.move_spell_zone_card_to_destination(self, card)

func _apply_zone_enemy_action_start_effects(source_unit) -> void:
	if source_unit == null:
		return
	for card_variant in player.spell_zone.duplicate():
		var card: Dictionary = card_variant
		var effect: Dictionary = card.get("effect", {})
		if str(effect.get("kind", "")) != "zone_next_enemy_action_status":
			continue
		var status_id := str(effect.get("status", ""))
		var amount: int = int(effect.get("value", 0))
		if status_id != "" and amount != 0:
			add_unit_status(source_unit, status_id, amount, str(card.get("name", "放置牌")))
		resolver.move_spell_zone_card_to_destination(self, card)
		break

func _apply_lethal_equipment_save(event: Dictionary, target_unit) -> void:
	if target_unit == null:
		return
	var damage: int = int(event.get("value", 0))
	if damage < int(target_unit.hp):
		return
	for i in range(target_unit.equipment.size()):
		var card: Dictionary = target_unit.equipment[i]
		if not _equipment_has_lethal_save(card):
			continue
		_remove_equipment_effect_recursive(target_unit, card.get("effect", {}))
		target_unit.equipment.remove_at(i)
		deck.add_to_graveyard(card)
		event["value"] = max(0, int(target_unit.hp) - 1)
		add_log("%s：破坏装备，%s 本次致命伤害改为保留 1 点生命。" % [card.get("name", "装备"), _unit_display_name(target_unit)])
		emit_combat_event({"type": "card_moved_to_graveyard", "card": card})
		return

func _equipment_has_lethal_save(card: Dictionary) -> bool:
	return _effect_has_kind(card.get("effect", {}), "equipment_lethal_save")

func _effect_has_kind(effect: Dictionary, expected_kind: String) -> bool:
	if str(effect.get("kind", "")) == expected_kind:
		return true
	if str(effect.get("kind", "")) == "multi":
		for sub_effect_variant in effect.get("effects", []):
			var sub_effect: Dictionary = sub_effect_variant
			if _effect_has_kind(sub_effect, expected_kind):
				return true
	return false

func _remove_equipment_effect_recursive(unit, effect: Dictionary) -> void:
	match str(effect.get("kind", "")):
		"equipment_attack_bonus":
			unit.equipment_attack_bonus -= int(effect.get("value", 0))
		"equipment_defense_bonus":
			unit.equipment_defense_bonus -= int(effect.get("value", 0))
		"multi":
			for sub_effect_variant in effect.get("effects", []):
				var sub_effect: Dictionary = sub_effect_variant
				_remove_equipment_effect_recursive(unit, sub_effect)

func _is_battle_unit(value) -> bool:
	return value is Object and value.has_method("current_defense") and value.has_method("apply_damage")

func _event_target_unit(event: Dictionary):
	var target = event.get("target", null)
	if _is_battle_unit(target):
		return target
	var target_key := str(event.get("target_key", target))
	if target_key == "player":
		return player
	if target_key == "enemy":
		return enemy
	return formation.unit_by_uid(target_key)

func _unit_event_key(unit) -> String:
	if unit == player:
		return "player"
	if unit == enemy:
		return "enemy"
	return str(unit.uid)

func _unit_display_name(unit) -> String:
	if unit == player:
		return "玩家"
	if unit == enemy:
		return "敌人"
	return str(unit.name)

func _stat_display_name(stat: String) -> String:
	match stat:
		"attack":
			return "攻击"
		"defense":
			return "防御"
	return stat

func open_timing_window(event: Dictionary) -> void:
	current_event = event
	chain_stack.clear()
	response_loop_guard = 0
	add_log("进入时点：%s。" % get_event_description(event))
	var responses := get_available_responses(event)
	if responses.is_empty():
		add_log("没有可响应防御牌。")
		resolve_chain(event)
		return
	add_log("发现可响应防御牌：%s。" % _response_names(responses))
	phase = "response"

func get_available_responses(event: Dictionary) -> Array:
	return resolver.get_available_responses(self, event)

func get_available_responses_for_current_event() -> Array:
	if current_event.is_empty():
		return []
	return get_available_responses(current_event)

func add_card_to_chain(uid: String) -> void:
	if phase != "response":
		return
	response_loop_guard += 1
	if response_loop_guard > MAX_CHAIN_ACTIONS:
		add_log("响应循环超过安全上限，强制结算当前连锁。")
		resolve_chain(current_event)
		return
	var available := get_available_responses(current_event)
	var can_use := false
	for card in available:
		if str(card.get("uid", "")) == uid:
			can_use = true
			break
	if not can_use:
		add_log("该防御牌当前不能响应。")
		return
	var chain_card := resolver.mark_card_in_chain(self, uid)
	if chain_card.is_empty():
		return
	chain_stack.append(chain_card.duplicate(true))
	add_log("玩家发动：%s。" % chain_card.get("name", ""))
	emit_combat_event({"type": "defense_card_activated", "card": chain_card})
	if get_available_responses(current_event).is_empty():
		resolve_chain(current_event)

func skip_response() -> void:
	if phase != "response":
		return
	add_log("玩家跳过响应。")
	resolve_chain(current_event)

func resolve_chain(event: Dictionary) -> void:
	if not chain_stack.is_empty():
		add_log("连锁开始结算。")
		emit_combat_event({"type": "chain_started"})
	var order := 1
	while not chain_stack.is_empty():
		var card: Dictionary = chain_stack.pop_back()
		add_log("连锁结算 %d：%s。" % [order, card.get("name", "")])
		emit_combat_event({"type": "chain_card_resolved", "card": card, "order": order})
		resolver.resolve_chain_card(self, card, event)
		order += 1
	if order > 1:
		add_log("连锁结束。")
		emit_combat_event({"type": "chain_finished"})
	resolve_original_event(event)

func resolve_original_event(event: Dictionary) -> void:
	if bool(event.get("cancelled", false)):
		add_log("原始事件被打断，不再结算。")
		_finish_enemy_resolution(event)
		return
	match event.get("event_type", ""):
		"enemy_attack_declared":
			add_log("敌人攻击继续结算。")
			var attack_target = _event_target_unit(event)
			if attack_target == null:
				_finish_enemy_action()
				return
			var attack_source_key := str(event.get("source_key", "enemy"))
			emit_combat_event({"type": "attack_started", "source": attack_source_key, "target": _unit_event_key(attack_target)})
			var damage: int = max(0, int(event.get("value", 0)) - attack_target.current_defense())
			if str(attack_target.team) == BattleUnitScript.TEAM_PLAYER:
				var attack_damage_event := create_event("player_damage_before", "enemy_attack", attack_target, damage)
				attack_damage_event["attack_source_key"] = attack_source_key
				open_timing_window(attack_damage_event)
			else:
				_apply_final_damage_to_unit(attack_target, damage, "enemy_attack", attack_source_key)
		"enemy_spell_declared":
			add_log("敌人施法继续结算。")
			var spell_target = _event_target_unit(event)
			if spell_target == null:
				_finish_enemy_resolution(event)
				return
			var spell_source_key := str(event.get("source_key", "enemy"))
			var damage: int = max(0, int(event.get("value", 0)) - spell_target.current_defense())
			if damage <= 0:
				_apply_enemy_spell_post_steps(event)
				_finish_enemy_resolution(event)
			elif str(spell_target.team) == BattleUnitScript.TEAM_PLAYER:
				var spell_damage_event := create_event("player_damage_before", "enemy_spell", spell_target, damage)
				spell_damage_event["attack_source_key"] = spell_source_key
				_copy_enemy_spell_post_context(event, spell_damage_event)
				open_timing_window(spell_damage_event)
			else:
				_apply_final_damage_to_unit(spell_target, damage, "enemy_spell", spell_source_key, event)
		"enemy_destroy_zone_card_declared":
			_resolve_destroy_zone_event(event)
			_finish_enemy_action()
		"player_damage_before":
			var damage := int(event.get("value", 0))
			var damage_target = _event_target_unit(event)
			if damage_target == null:
				damage_target = player
			_apply_zone_damage_reduction(event, damage_target)
			_apply_next_damage_reduction_status(event, damage_target)
			damage = int(event.get("value", 0))
			if damage_target == player and damage >= player.hp and damage > 0:
				var lethal_event := create_event("player_lethal_damage_before", event.get("source", ""), damage_target, damage)
				lethal_event["attack_source_key"] = str(event.get("attack_source_key", "enemy"))
				_copy_enemy_spell_post_context(event, lethal_event)
				open_timing_window(lethal_event)
			else:
				_apply_final_damage_to_unit(damage_target, damage, str(event.get("source", "伤害")), str(event.get("attack_source_key", "enemy")), event)
		"player_lethal_damage_before":
			var lethal_target = _event_target_unit(event)
			var final_target = player if lethal_target == null else lethal_target
			_apply_lethal_equipment_save(event, final_target)
			_apply_final_damage_to_unit(final_target, int(event.get("value", 0)), str(event.get("source", "致命伤害")), str(event.get("attack_source_key", "enemy")), event)

func _resolve_destroy_zone_event(event: Dictionary) -> void:
	var target: Dictionary = event.get("target", {})
	var target_key := _target_key(target)
	if target_key in event.get("protected_targets", []):
		add_log("%s 被保护，本次破坏无效。" % target.get("name", "目标"))
		return
	_destroy_spell_zone_card(target)

func _destroy_spell_zone_card(card: Dictionary) -> void:
	for i in range(player.spell_zone.size()):
		if str(player.spell_zone[i].get("uid", "")) == str(card.get("uid", "")):
			player.spell_zone.remove_at(i)
			break
	_release_attached_cards_to_graveyard(card)
	deck.add_to_graveyard(card)
	add_log("%s 被破坏并进入墓地。" % card.get("name", "卡牌"))
	emit_combat_event({"type": "card_destroyed", "card": card})

func _release_attached_cards_to_graveyard(card: Dictionary) -> void:
	var attached_cards: Array = card.get("attached_cards", [])
	if attached_cards.is_empty():
		return
	for attached_card_variant in attached_cards:
		var attached_card: Dictionary = attached_card_variant
		deck.add_to_graveyard(attached_card)
		add_log("%s 下方的 %s 进入墓地。" % [card.get("name", "放置牌"), attached_card.get("name", "卡牌")])
	card["attached_cards"] = []

func _apply_final_damage_to_unit(target_unit, damage: int, source_name: String, attack_source_key := "enemy", post_context := {}) -> void:
	if target_unit == null:
		_finish_enemy_resolution(post_context)
		return
	apply_damage_to_unit(target_unit, max(0, damage), source_name)
	add_log("%s 对 %s 造成 %d 点伤害。" % [source_name, _unit_display_name(target_unit), max(0, damage)])
	_apply_enemy_spell_post_steps(post_context)
	if source_name == "enemy_attack":
		emit_combat_event({"type": "attack_finished", "source": attack_source_key, "target": _unit_event_key(target_unit)})
	_finish_enemy_resolution(post_context)

func _copy_enemy_spell_post_context(source_event: Dictionary, target_event: Dictionary) -> void:
	var post_steps: Array = source_event.get("post_steps", [])
	if not post_steps.is_empty():
		target_event["post_steps"] = post_steps.duplicate(true)
	if source_event.has("post_source_unit"):
		target_event["post_source_unit"] = source_event.get("post_source_unit", null)
	if bool(source_event.get("enemy_side_card", false)):
		target_event["enemy_side_card"] = true

func _apply_enemy_spell_post_steps(event_context) -> void:
	if not (event_context is Dictionary):
		return
	var context_dict: Dictionary = event_context
	var post_steps: Array = context_dict.get("post_steps", [])
	if post_steps.is_empty():
		return
	var source_unit = context_dict.get("post_source_unit", active_enemy_unit)
	var target_unit = _event_target_unit(context_dict)
	effect_resolver.apply_steps(self, source_unit, post_steps, {"target_unit": target_unit})

func _finish_enemy_resolution(context = {}) -> void:
	if context is Dictionary and bool((context as Dictionary).get("enemy_side_card", false)):
		_finish_enemy_side_card()
	else:
		_finish_enemy_action()

func _finish_enemy_side_card() -> void:
	current_event.clear()
	chain_stack.clear()
	if check_victory_or_defeat():
		return
	if phase != "reward" and phase != "defeat":
		phase = "enemy"
		if _try_enemy_play_next_side_card():
			return
		_continue_enemy_turn()

func _finish_enemy_action() -> void:
	current_event.clear()
	chain_stack.clear()
	if active_enemy_unit != null:
		_tick_turn_end_statuses_for_unit(active_enemy_unit)
		active_enemy_unit = null
	if check_victory_or_defeat():
		return
	if phase != "reward" and phase != "defeat":
		phase = "enemy"
		_continue_enemy_turn()

func get_event_description(event: Dictionary) -> String:
	match event.get("event_type", ""):
		"enemy_attack_declared":
			return "敌人攻击前"
		"enemy_spell_declared":
			return "敌人施法前"
		"enemy_destroy_zone_card_declared":
			return "敌人破坏法防区前"
		"player_damage_before":
			return "我方单位受到伤害前"
		"player_lethal_damage_before":
			return "玩家受到致命伤害前"
	return str(event.get("event_type", "未知时点"))

func _response_names(responses: Array) -> String:
	var names: Array = []
	for card in responses:
		names.append(card.get("name", "卡牌"))
	return "、".join(names)

func _target_key(target) -> String:
	if target is Dictionary:
		return str(target.get("uid", target.get("id", target.get("name", ""))))
	return str(target)

func choose_reward(card_id: String) -> void:
	if phase != "reward":
		return
	if not reward_options.has(card_id):
		return
	var result: Dictionary = CardAcquisitionRulesScript.card_gain_result(card_id, master_deck_ids, deck_score_limit)
	match str(result.get("destination", "none")):
		"deck":
			master_deck_ids.append(card_id)
			add_log("选择奖励：%s 加入卡组。" % card_id)
		"reserve":
			master_reserve_ids.append(card_id)
			add_log("选择奖励：%s 加入备牌区（%s）。" % [card_id, str(result.get("reason", ""))])
		_:
			add_log(str(result.get("message", "未获得卡牌。")))
			return
	if not auto_advance_after_reward:
		phase = "map_complete"
		return
	battle_number += 1
	if battle_number > 5:
		battle_number = 1
		add_log("第 5 场胜利后回到第 1 场循环。")
	start_battle()

func _enemy_data_for_current_battle() -> Dictionary:
	if current_encounter_profile.is_empty():
		current_encounter_profile = _select_encounter_profile()
	return BattleEncounterRuntimeScript.primary_enemy_data(current_encounter_profile, battle_number)

func check_victory_or_defeat() -> bool:
	_cleanup_defeated_units()
	if player.hp <= 0 or formation.all_players_defeated():
		player.hp = 0
		phase = "defeat"
		add_log("玩家生命降为 0，战斗失败。")
		return true
	if formation.all_enemies_defeated() and phase != "reward":
		enemy.hp = 0
		player.sword_momentum = 0
		player.set_resource("sword_momentum", 0)
		phase = "reward"
		reward_options = _generate_rewards()
		add_log("战斗胜利。请选择 1 张奖励卡。")
		return true
	return false

func _generate_rewards() -> Array:
	var unlock_tier: int = int(meta_bonuses.get("card_unlock_tier", 0))
	return RewardServiceScript.battle_card_rewards(job_id, current_encounter_type, unlock_tier, rng, 3)

func _draw_player_cards(amount: int, reason := "") -> Array:
	var drawn: Array = deck.draw(max(0, amount))
	if not drawn.is_empty():
		emit_combat_event({"type": "cards_drawn", "cards": drawn.duplicate(true), "reason": reason})
	return drawn

func _draw_enemy_cards(amount: int) -> Array:
	if enemy_side == null or amount <= 0:
		return []
	var drawn: Array = enemy_side.draw_cards(amount)
	enemy_side.take_deck_messages()
	if not drawn.is_empty():
		add_log("敌方抽取 %d 张牌。" % drawn.size())
		emit_combat_event({"type": "enemy_cards_drawn", "count": drawn.size()})
	return drawn

func _flush_deck_messages() -> void:
	for message in deck.take_messages():
		add_log(message)

func add_log(message: String) -> void:
	messages.append(message)
	while messages.size() > 12:
		messages.pop_front()

func emit_combat_event(payload: Dictionary) -> void:
	combat_event.emit(payload)
