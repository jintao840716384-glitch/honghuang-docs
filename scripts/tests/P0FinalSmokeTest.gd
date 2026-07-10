extends SceneTree

const DataRegistryScript = preload("res://scripts/data/DataRegistry.gd")
const DataValidatorScript = preload("res://scripts/data/DataValidator.gd")
const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")
const CardDatabaseScript = preload("res://scripts/data/CardDatabase.gd")
const DifficultyCurveDatabaseScript = preload("res://scripts/data/DifficultyCurveDatabase.gd")
const EnemyDeckTemplateDatabaseScript = preload("res://scripts/data/EnemyDeckTemplateDatabase.gd")
const EncounterFactoryScript = preload("res://scripts/data/EncounterFactory.gd")
const WorldDifficultyDatabaseScript = preload("res://scripts/data/WorldDifficultyDatabase.gd")
const MapContentDatabaseScript = preload("res://scripts/data/MapContentDatabase.gd")
const BattleManagerScript = preload("res://scripts/battle/BattleManager.gd")
const BattleSnapshotScript = preload("res://scripts/battle/BattleSnapshot.gd")
const BattleViewModelScript = preload("res://scripts/battle/BattleViewModel.gd")
const SaveStoreScript = preload("res://scripts/save/SaveStore.gd")
const SettingsStoreScript = preload("res://scripts/settings/SettingsStore.gd")
const SaveMigrationServiceScript = preload("res://scripts/save/SaveMigrationService.gd")
const LocalizationDatabaseScript = preload("res://scripts/localization/LocalizationDatabase.gd")
const LocalizationServiceScript = preload("res://scripts/localization/LocalizationService.gd")
const CharacterVisualDatabaseScript = preload("res://scripts/assets/CharacterVisualDatabase.gd")
const VisualAssetDatabaseScript = preload("res://scripts/assets/VisualAssetDatabase.gd")
const AudioEventDatabaseScript = preload("res://scripts/audio/AudioEventDatabase.gd")
const BattleAudioRouterScript = preload("res://scripts/ui/BattleAudioRouter.gd")


func _init() -> void:
	var ok := true
	ok = _report("registry_validator", _test_registry_validator()) and ok
	ok = _report("validator_negative_boundaries", _test_validator_negative_boundaries()) and ok
	ok = _report("canonical_content_state", _test_canonical_content_state()) and ok
	ok = _report("difficulty_curves", _test_difficulty_curves()) and ok
	ok = _report("world_map_treasure", _test_world_map_treasure()) and ok
	ok = _report("battle_contracts", _test_battle_contracts()) and ok
	ok = _report("response_request_results", _test_response_request_results()) and ok
	ok = _report("viewmodel_result_consumption", _test_viewmodel_result_consumption()) and ok
	ok = _report("snapshot_isolation", _test_snapshot_isolation()) and ok
	ok = _report("save_store_isolation", _test_save_store_isolation()) and ok
	ok = _report("resource_localization", _test_resource_localization()) and ok
	ok = _report("deck_rule_ownership", _test_deck_rule_ownership()) and ok
	if ok:
		print("P0_FINAL_SMOKE_TEST_OK")
		quit(0)
	else:
		push_error("P0_FINAL_SMOKE_TEST_FAILED")
		quit(1)


func _report(label: String, passed: bool) -> bool:
	if not passed:
		push_error("%s failed" % label)
	return passed


func _test_registry_validator() -> bool:
	var registry: Dictionary = DataRegistryScript.snapshot()
	var result: Dictionary = DataValidatorScript.validate(registry)
	if not bool(result.get("valid", false)):
		push_error("validator errors: %s" % str(result.get("errors", [])))
		return false
	var invalid_registry := registry.duplicate(true)
	var jobs: Array = invalid_registry.get("jobs", [])
	var invalid_job: Dictionary = (jobs[0] as Dictionary).duplicate(true)
	invalid_job["start_deck"] = ["missing_card"]
	jobs[0] = invalid_job
	invalid_registry["jobs"] = jobs
	var invalid_result: Dictionary = DataValidatorScript.validate(invalid_registry)
	return not bool(invalid_result.get("valid", true)) and not (invalid_result.get("errors", []) as Array).is_empty()


func _test_validator_negative_boundaries() -> bool:
	if not _validator_rejects(_invalid_active_card_registry({"effect_type": "unknown_effect"}, {})):
		return false
	if not _validator_rejects(_invalid_active_card_registry({}, {"remove_effect_type": true})):
		return false
	if not _validator_rejects(_invalid_active_card_registry({}, {"target_scope": "invalid_target"})):
		return false
	if not _validator_rejects(_invalid_active_card_registry({"target": "invalid_target"}, {})):
		return false
	if not _validator_rejects(_invalid_active_card_registry({}, {"after_use": "invalid_zone"})):
		return false
	var invalid_map := DataRegistryScript.snapshot()
	var layouts: Array = invalid_map.get("map_layouts", [])
	var layout: Dictionary = (layouts[0] as Dictionary).duplicate(true)
	layout["layout_id"] = "invalid_layout"
	var floors: Array = layout.get("floors", []).duplicate(true)
	var first_floor: Array = (floors[0] as Array).duplicate(true)
	var first_node: Dictionary = (first_floor[0] as Dictionary).duplicate(true)
	first_node["type"] = "invalid_node"
	first_floor[0] = first_node
	floors[0] = first_floor
	layout["floors"] = floors
	layouts[0] = layout
	invalid_map["map_layouts"] = layouts
	if not _validator_rejects(invalid_map):
		return false
	var invalid_treasure := DataRegistryScript.snapshot()
	var treasures: Array = invalid_treasure.get("treasures", [])
	var treasure: Dictionary = (treasures[0] as Dictionary).duplicate(true)
	treasure["reward_kind"] = "invalid_reward"
	treasure["choice_count"] = 2
	treasures[0] = treasure
	invalid_treasure["treasures"] = treasures
	if not _validator_rejects(invalid_treasure):
		return false
	var main_source := FileAccess.get_file_as_string("res://scripts/Main.gd")
	return main_source.contains("DataValidatorScript.assert_valid_for_startup()")


func _invalid_active_card_registry(step_patch: Dictionary, card_patch: Dictionary) -> Dictionary:
	var registry := DataRegistryScript.snapshot()
	var cards: Array = registry.get("cards", [])
	for i in range(cards.size()):
		var card: Dictionary = cards[i]
		if str(card.get("id", "")) != "break_defense_setup":
			continue
		card = card.duplicate(true)
		for key_variant in card_patch.keys():
			if str(key_variant) != "remove_effect_type":
				card[key_variant] = card_patch[key_variant]
		var steps: Array = card.get("effect_steps", []).duplicate(true)
		var step: Dictionary = (steps[0] as Dictionary).duplicate(true)
		if bool(card_patch.get("remove_effect_type", false)):
			step.erase("effect_type")
		for key_variant in step_patch.keys():
			step[key_variant] = step_patch[key_variant]
		steps[0] = step
		card["effect_steps"] = steps
		cards[i] = card
		break
	registry["cards"] = cards
	return registry


func _validator_rejects(registry: Dictionary) -> bool:
	var result: Dictionary = DataValidatorScript.validate(registry)
	return not bool(result.get("valid", true)) and not (result.get("errors", []) as Array).is_empty()


func _test_canonical_content_state() -> bool:
	var active_ids: Array = CardDefinitionDatabaseScript.active_card_ids()
	active_ids.sort()
	var expected := ["blank_card", "break_defense_setup", "clear_buff", "defense_setup", "heal_wound", "poison", "quick_draw", "weaken_attack_setup"]
	if active_ids != expected:
		return false
	for card_id_variant in active_ids:
		var card: Dictionary = CardDefinitionDatabaseScript.get_card(str(card_id_variant))
		if str(card.get("content_state", "")) != "active":
			return false
	for candidate_variant in EnemyDeckTemplateDatabaseScript.candidate_deck_templates():
		if str((candidate_variant as Dictionary).get("content_state", "")) == "active":
			return false
	return true


func _test_difficulty_curves() -> bool:
	var definitions: Array = DifficultyCurveDatabaseScript.active_definitions()
	var ids: Array = []
	for definition_variant in definitions:
		var definition: Dictionary = definition_variant
		ids.append(str(definition.get("curve_id", "")))
		if str(definition.get("content_state", "")) != "active" or str(definition.get("world_difficulty_id", "")) != "wd0":
			return false
	ids.sort()
	if ids != ["curve_boss_01", "curve_elite_01", "curve_normal_01"]:
		return false
	var synthetic := definitions.duplicate(true)
	var inactive: Dictionary = (definitions[0] as Dictionary).duplicate(true)
	inactive["curve_id"] = "curve_prototype_test"
	inactive["encounter_type"] = "prototype"
	inactive["content_state"] = "prototype"
	synthetic.append(inactive)
	if DifficultyCurveDatabaseScript.filter_active(synthetic).size() != 3:
		return false
	return DifficultyCurveDatabaseScript.active_curve_for_encounter("prototype").is_empty()


func _test_world_map_treasure() -> bool:
	var active_worlds: Array = WorldDifficultyDatabaseScript.active_definitions()
	if active_worlds.size() != 1 or str((active_worlds[0] as Dictionary).get("world_difficulty_id", "")) != "wd0":
		return false
	if not EncounterFactoryScript.get_encounter_for_battle(1, "normal", 0, 2).is_empty():
		return false
	var layout: Dictionary = MapContentDatabaseScript.active_layout()
	if str(layout.get("layout_id", "")) != "main_story_layout_01" or (layout.get("floors", []) as Array).size() != 7:
		return false
	for floor_variant in layout.get("floors", []):
		for node_variant in floor_variant:
			if not ["normal", "elite", "boss", "event", "treasure", "shop", "rest"].has(str((node_variant as Dictionary).get("type", ""))):
				return false
	var treasure: Dictionary = MapContentDatabaseScript.active_treasure()
	return str(treasure.get("treasure_id", "")) == "treasure_card_choice_01" \
		and str(treasure.get("reward_kind", "")) == "card_choice" \
		and int(treasure.get("choice_count", 0)) == 3


func _test_battle_contracts() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	if battle.context == null or battle.player != battle.context.player or battle.deck != battle.context.deck:
		return false
	var invalid_result: Dictionary = battle.submit_request({"type": "end_turn", "side": "invalid"})
	if bool(invalid_result.get("accepted", true)) \
		or str(invalid_result.get("error_code", "")) != "invalid_request_side" \
		or str(invalid_result.get("error_key", "")) != "battle.error.invalid_request_side":
		return false
	var result: Dictionary = battle.submit_request({
		"type": "unit_defend",
		"side": "player",
		"source_uid": str(battle.player.uid)
	})
	for field in ["accepted", "success", "request_id", "request_type", "side", "error", "error_code", "error_key", "events", "state_changes"]:
		if not result.has(field):
			return false
	var context_source := FileAccess.get_file_as_string("res://scripts/battle/BattleContext.gd")
	return bool(result.get("accepted", false)) and str(result.get("request_id", "")) != "" \
		and not context_source.contains("var resolver") \
		and not context_source.contains("var effect_resolver") \
		and not context_source.contains("var enemy_controller")


func _test_response_request_results() -> bool:
	var response_battle = BattleManagerScript.new()
	response_battle.start_run("sword")
	var guard := CardDatabaseScript.make_card("护身符")
	guard["set_turn"] = 0
	guard["cover_turn"] = 0
	guard["face_down"] = true
	guard["ready"] = true
	guard["sealed"] = false
	guard["already_in_chain"] = false
	response_battle.player.spell_zone.append(guard)
	response_battle.open_timing_window(response_battle.create_event("player_damage_before", "test", response_battle.player, 3))
	var play_result: Dictionary = response_battle.submit_request({"request_type": "play_response", "side": "player", "card_uid": str(guard.get("uid", ""))})
	if not bool(play_result.get("accepted", false)) or str(play_result.get("request_type", "")) != "play_response" or str(play_result.get("request_id", "")) == "":
		return false
	var skip_battle = BattleManagerScript.new()
	skip_battle.start_run("sword")
	var skip_guard := CardDatabaseScript.make_card("护身符")
	for field in ["set_turn", "cover_turn"]:
		skip_guard[field] = 0
	skip_guard["face_down"] = true
	skip_guard["ready"] = true
	skip_guard["sealed"] = false
	skip_guard["already_in_chain"] = false
	skip_battle.player.spell_zone.append(skip_guard)
	skip_battle.open_timing_window(skip_battle.create_event("player_damage_before", "test", skip_battle.player, 3))
	var skip_result: Dictionary = skip_battle.submit_request({"request_type": "skip_response", "side": "player"})
	if not bool(skip_result.get("accepted", false)) or str(skip_result.get("request_type", "")) != "skip_response":
		return false
	var manager_source := FileAccess.get_file_as_string("res://scripts/battle/BattleManager.gd")
	var obsolete_add_entry := "func add_card" + "_to_chain("
	var obsolete_skip_entry := "func skip_response" + "_for_side("
	return not manager_source.contains(obsolete_add_entry) and not manager_source.contains(obsolete_skip_entry)


func _test_viewmodel_result_consumption() -> bool:
	var view_model = BattleViewModelScript.new(BattleManagerScript.new())
	view_model.start_run("sword")
	var result: Dictionary = view_model.player_unit_defend(str(view_model.player.uid))
	if not bool(result.get("accepted", false)) or str(result.get("request_type", "")) != "unit_defend":
		return false
	var ui_source := FileAccess.get_file_as_string("res://scripts/ui/BattleUI.gd")
	var removed_card_delta_check := "card_was" + "_removed"
	var removed_source_delta_check := "source_was" + "_removed"
	return ui_source.contains("_consume_battle_result") \
		and ui_source.contains("_battle_result_consumed_card") \
		and not ui_source.contains(removed_card_delta_check) \
		and not ui_source.contains(removed_source_delta_check)


func _test_snapshot_isolation() -> bool:
	var battle = BattleManagerScript.new()
	battle.start_run("sword")
	var snapshot = BattleSnapshotScript.new().from_context(battle.context)
	var original_hp := int(battle.player.hp)
	snapshot.player.hp = 1
	snapshot.messages.append("snapshot-only")
	return int(battle.player.hp) == original_hp and not battle.messages.has("snapshot-only") and snapshot.player != battle.player


func _test_save_store_isolation() -> bool:
	var base := OS.get_temp_dir().path_join("taixuanzong_p0_final_%d" % Time.get_ticks_usec())
	var settings_path := "%s_settings.cfg" % base
	var progression_path := "%s_progression.json" % base
	var settings: Dictionary = SettingsStoreScript.default_settings()
	if SaveStoreScript.save_settings(settings, settings_path) != OK:
		return false
	var loaded_settings: Dictionary = SaveStoreScript.load_settings(SettingsStoreScript.default_settings(), settings_path)
	var progression := SaveMigrationServiceScript.default_meta_progression_data()
	if not SaveStoreScript.save_progression(progression, progression_path):
		return false
	var loaded_progression: Dictionary = SaveStoreScript.load_progression(progression_path)
	DirAccess.remove_absolute(settings_path)
	DirAccess.remove_absolute(progression_path)
	return int(loaded_settings.get("version", SaveMigrationServiceScript.CURRENT_SETTINGS_VERSION)) == SaveMigrationServiceScript.CURRENT_SETTINGS_VERSION \
		and int(loaded_progression.get("version", 0)) == SaveMigrationServiceScript.CURRENT_META_PROGRESSION_VERSION


func _test_resource_localization() -> bool:
	for profile_variant in CharacterVisualDatabaseScript.visual_profiles().values():
		var profile: Dictionary = profile_variant
		for field in ["portrait_asset_id", "battle_sprite_asset_id", "battle_animation_asset_id", "icon_asset_id"]:
			if not VisualAssetDatabaseScript.has_asset(str(profile.get(field, ""))):
				return false
	for event_id_variant in ["music.main_menu", "music.battle", "card_play", "attack", "hit"]:
		if not AudioEventDatabaseScript.has_event(str(event_id_variant)):
			return false
	for fallback_id_variant in VisualAssetDatabaseScript.fallback_asset_ids():
		if not VisualAssetDatabaseScript.has_asset(str(fallback_id_variant)):
			return false
	for routed_id_variant in BattleAudioRouterScript.routed_audio_event_ids():
		if not AudioEventDatabaseScript.has_event(str(routed_id_variant)):
			return false
	for event_variant in AudioEventDatabaseScript.event_definitions().values():
		var event: Dictionary = event_variant
		var placeholder_id := str(event.get("placeholder_id", ""))
		if placeholder_id != "" and not AudioEventDatabaseScript.has_event(placeholder_id):
			return false
	for key_variant in LocalizationDatabaseScript.REQUIRED_SCREEN_TEXT_IDS:
		if not LocalizationDatabaseScript.has_text(str(key_variant)):
			return false
	var fallback := LocalizationServiceScript.text("missing.key", "zh_cn", {}, "原文")
	return fallback == "原文" \
		and LocalizationServiceScript.text("battle.number", "zh_cn", {"number": 2}, "第 {number} 场") == "第 2 场" \
		and LocalizationDatabaseScript.has_text("card.poison.name") \
		and LocalizationDatabaseScript.has_text("map.node.treasure") \
		and LocalizationDatabaseScript.has_text("job_select.title") \
		and LocalizationDatabaseScript.has_text("prep.growth.title") \
		and LocalizationDatabaseScript.has_text("map.title") \
		and LocalizationDatabaseScript.has_text("battle.action.attack") \
		and LocalizationDatabaseScript.has_text("settlement.complete")


func _test_deck_rule_ownership() -> bool:
	var source := FileAccess.get_file_as_string("res://scripts/data/CardDatabase.gd")
	return not source.contains("static func deck_score(") \
		and not source.contains("static func can_add_card_to_deck(") \
		and not source.contains("static func deck_add_block_reason(")
