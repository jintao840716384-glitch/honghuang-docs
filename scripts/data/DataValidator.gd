extends RefCounted
class_name DataValidator

const DataRegistryScript = preload("res://scripts/data/DataRegistry.gd")
const CardDefinitionDatabaseScript = preload("res://scripts/data/CardDefinitionDatabase.gd")
const EffectResolverScript = preload("res://scripts/battle/EffectResolver.gd")

const VALID_CONTENT_STATES := ["active", "prototype", "legacy", "disabled", "pending_fill"]
const REQUIRED_ACTIVE_CARD_IDS := [
	"break_defense_setup",
	"weaken_attack_setup",
	"heal_wound",
	"clear_buff",
	"poison",
	"defense_setup",
	"quick_draw",
	"blank_card"
]
const REQUIRED_ACTIVE_STATUS_IDS := ["poison", "armor_break", "weak", "next_damage_reduce"]
const REQUIRED_ACTIVE_EVENT_IDS := ["event_minor_01", "event_windfall_01", "event_trade_01"]
const REQUIRED_ACTIVE_CURVE_IDS := ["curve_normal_01", "curve_elite_01", "curve_boss_01"]
const REQUIRED_CURVE_ENCOUNTER_TYPES := ["normal", "elite", "boss"]


static func validate(registry: Dictionary = {}) -> Dictionary:
	var data: Dictionary = DataRegistryScript.snapshot() if registry.is_empty() else registry.duplicate(true)
	var errors: Array = []
	var warnings: Array = []

	_validate_content_states(data, errors)
	var cards := _index(data.get("cards", []), "id", "cards", errors)
	var jobs := _index(data.get("jobs", []), "id", "jobs", errors)
	var characters := _index(data.get("characters", []), "id", "characters", errors)
	var templates := _index(data.get("enemy_deck_templates", []), "deck_template_id", "enemy_deck_templates", errors)
	var events := _index(data.get("events", []), "event_id", "events", errors)
	_index_composite(data.get("progressions", []), ["job_id", "progression_id"], "progressions", errors)
	var statuses := _index(data.get("statuses", []), "status_id", "statuses", errors)
	var difficulty_curves := _index(data.get("difficulty_curves", []), "curve_id", "difficulty_curves", errors)
	_index(data.get("map_layouts", []), "layout_id", "map_layouts", errors)
	_index(data.get("treasures", []), "treasure_id", "treasures", errors)
	var world_difficulties := _index(data.get("world_difficulties", []), "world_difficulty_id", "world_difficulties", errors)
	var visual_assets := _index(data.get("visual_assets", []), "id", "visual_assets", errors)
	var visual_profiles := _index(data.get("character_visual_profiles", []), "id", "character_visual_profiles", errors)
	var audio_events := _index(data.get("audio_events", []), "id", "audio_events", errors)
	_index(data.get("languages", []), "id", "languages", errors)

	_validate_active_cards(data, cards, statuses, errors)
	_validate_card_pools(data, cards, errors)
	_validate_jobs(jobs, characters, cards, errors)
	_validate_characters(characters, visual_profiles, errors)
	_validate_enemy_templates(templates, characters, cards, errors)
	_validate_events(events, errors)
	_validate_progressions(data, jobs, errors)
	_validate_statuses(statuses, errors)
	_validate_difficulty_curves(difficulty_curves, world_difficulties, errors)
	_validate_map_and_treasure(data, errors)
	_validate_world_difficulties(data, errors)
	_validate_visual_references(visual_profiles, visual_assets, errors)
	_validate_visual_audio_fallbacks(data, visual_profiles, visual_assets, audio_events, errors)
	_validate_resource_paths(data, warnings)
	_validate_localization(data, errors, warnings)

	return {
		"valid": errors.is_empty(),
		"errors": errors.duplicate(),
		"warnings": warnings.duplicate()
	}


static func assert_valid_for_startup() -> Dictionary:
	return validate()


static func _validate_content_states(data: Dictionary, errors: Array) -> void:
	for source_name in ["cards", "jobs", "characters", "enemy_deck_templates", "events", "progressions", "statuses", "difficulty_curves", "map_layouts", "treasures", "world_difficulties", "visual_assets", "character_visual_profiles", "audio_events", "languages"]:
		for definition_variant in data.get(source_name, []):
			if not (definition_variant is Dictionary):
				errors.append("%s contains a non-dictionary definition" % source_name)
				continue
			var definition: Dictionary = definition_variant
			var state := str(definition.get("content_state", ""))
			if not VALID_CONTENT_STATES.has(state):
				errors.append("%s has invalid content_state '%s'" % [source_name, state])


static func _validate_active_cards(data: Dictionary, cards: Dictionary, statuses: Dictionary, errors: Array) -> void:
	var active_ids := _active_ids(cards, "content_state")
	active_ids.sort()
	var required := REQUIRED_ACTIVE_CARD_IDS.duplicate()
	required.sort()
	if active_ids != required:
		errors.append("active card ids do not match the canonical set")
	for card_id_variant in active_ids:
		var card_id := str(card_id_variant)
		var card: Dictionary = cards.get(card_id, {})
		var target_scope := str(card.get("target_scope", ""))
		if not CardDefinitionDatabaseScript.VALID_ACTIVE_TARGET_SCOPES.has(target_scope):
			errors.append("active card '%s' has invalid target_scope '%s'" % [card_id, target_scope])
		var after_use := str(card.get("after_use", ""))
		if not CardDefinitionDatabaseScript.VALID_ACTIVE_AFTER_USE_DESTINATIONS.has(after_use):
			errors.append("active card '%s' has invalid after_use '%s'" % [card_id, after_use])
		var steps: Array = card.get("effect_steps", [])
		if steps.is_empty():
			errors.append("active card '%s' has no effect_steps" % card_id)
		for step_variant in steps:
			if not (step_variant is Dictionary):
				errors.append("active card '%s' has an invalid effect step" % card_id)
				continue
			var step: Dictionary = step_variant
			var effect_type := str(step.get("effect_type", ""))
			if effect_type == "":
				errors.append("active card '%s' has an empty effect_type" % card_id)
			elif not EffectResolverScript.SUPPORTED_EFFECT_TYPES.has(effect_type):
				errors.append("active card '%s' has unknown effect_type '%s'" % [card_id, effect_type])
			var target_mode := str(step.get("target", ""))
			if not EffectResolverScript.SUPPORTED_TARGET_MODES.has(target_mode):
				errors.append("active card '%s' has invalid effect target '%s'" % [card_id, target_mode])
			if step.has("status"):
				var status_id := str(step.get("status", ""))
				if not statuses.has(status_id) or not _is_active(statuses.get(status_id, {})):
					errors.append("active card '%s' references inactive status '%s'" % [card_id, status_id])
			if step.has("card_id"):
				var referenced_card_id := str(step.get("card_id", ""))
				if not cards.has(referenced_card_id) or not _is_active(cards.get(referenced_card_id, {})):
					errors.append("active card '%s' references inactive card '%s'" % [card_id, referenced_card_id])
	var declared_active: Array = data.get("active_card_ids", [])
	declared_active.sort()
	if declared_active != required:
		errors.append("registry active_card_ids are not derived from canonical content_state")


static func _validate_card_pools(data: Dictionary, cards: Dictionary, errors: Array) -> void:
	var packs: Dictionary = data.get("card_unlock_packs", {})
	for card_id_variant in packs.keys():
		var card_id := str(card_id_variant)
		if not cards.has(card_id) or not _is_active(cards.get(card_id, {})):
			errors.append("card pool references inactive card '%s'" % card_id)


static func _validate_jobs(jobs: Dictionary, characters: Dictionary, cards: Dictionary, errors: Array) -> void:
	for job_id_variant in jobs.keys():
		var job_id := str(job_id_variant)
		var job: Dictionary = jobs.get(job_id, {})
		if not _is_active(job):
			continue
		var character_id := str(job.get("character_id", ""))
		if not characters.has(character_id) or not _is_active(characters.get(character_id, {})):
			errors.append("active job '%s' references inactive character '%s'" % [job_id, character_id])
		for card_id_variant in job.get("start_deck", []):
			var card_id := str(card_id_variant)
			if not cards.has(card_id) or not _is_active(cards.get(card_id, {})):
				errors.append("active job '%s' start deck references inactive card '%s'" % [job_id, card_id])


static func _validate_characters(characters: Dictionary, visual_profiles: Dictionary, errors: Array) -> void:
	for character_id_variant in characters.keys():
		var character_id := str(character_id_variant)
		var character: Dictionary = characters.get(character_id, {})
		if not _is_active(character):
			continue
		var profile_id := str(character.get("visual_profile_id", ""))
		if profile_id == "" or not visual_profiles.has(profile_id) or not _is_active(visual_profiles.get(profile_id, {})):
			errors.append("active character '%s' references missing visual profile '%s'" % [character_id, profile_id])


static func _validate_enemy_templates(templates: Dictionary, characters: Dictionary, cards: Dictionary, errors: Array) -> void:
	for template_id_variant in templates.keys():
		var template_id := str(template_id_variant)
		var template: Dictionary = templates.get(template_id, {})
		if not _is_active(template):
			continue
		for card_id_variant in template.get("deck", []):
			var card_id := str(card_id_variant)
			if not cards.has(card_id) or not _is_active(cards.get(card_id, {})):
				errors.append("active enemy template '%s' references inactive card '%s'" % [template_id, card_id])
		for character_ref_variant in template.get("character_refs", []):
			var character_ref: Dictionary = character_ref_variant
			var character_id := str(character_ref.get("character_id", ""))
			if not characters.has(character_id) or not _is_active(characters.get(character_id, {})):
				errors.append("active enemy template '%s' references inactive character '%s'" % [template_id, character_id])


static func _validate_events(events: Dictionary, errors: Array) -> void:
	var active_ids := _active_ids(events, "content_state")
	active_ids.sort()
	var required := REQUIRED_ACTIVE_EVENT_IDS.duplicate()
	required.sort()
	if active_ids != required:
		errors.append("active event ids do not match the canonical set")
	var total_weight := 0
	for event_id_variant in active_ids:
		var event_id := str(event_id_variant)
		var definition: Dictionary = events.get(event_id, {})
		total_weight += int(definition.get("weight", 0))
		var option_ids: Dictionary = {}
		for option_variant in definition.get("options", []):
			var option: Dictionary = option_variant
			var option_id := str(option.get("option_id", ""))
			if option_id == "" or option_ids.has(option_id):
				errors.append("event '%s' has an invalid option id" % event_id)
			option_ids[option_id] = true
	if total_weight != 100:
		errors.append("active event weights must total 100")


static func _validate_progressions(data: Dictionary, jobs: Dictionary, errors: Array) -> void:
	for definition_variant in data.get("progressions", []):
		var definition: Dictionary = definition_variant
		if not _is_active(definition):
			continue
		var job_id := str(definition.get("job_id", ""))
		if not jobs.has(job_id) or not _is_active(jobs.get(job_id, {})):
			errors.append("active progression references inactive job '%s'" % job_id)


static func _validate_statuses(statuses: Dictionary, errors: Array) -> void:
	var active_ids := _active_ids(statuses, "content_state")
	active_ids.sort()
	var required := REQUIRED_ACTIVE_STATUS_IDS.duplicate()
	required.sort()
	if active_ids != required:
		errors.append("active status ids do not match the canonical set")


static func _validate_difficulty_curves(curves: Dictionary, world_difficulties: Dictionary, errors: Array) -> void:
	var active_ids := _active_ids(curves, "content_state")
	active_ids.sort()
	var required_ids := REQUIRED_ACTIVE_CURVE_IDS.duplicate()
	required_ids.sort()
	if active_ids != required_ids:
		errors.append("active difficulty curve ids do not match the canonical set")
	var encounter_types: Array = []
	for curve_id_variant in active_ids:
		var curve_id := str(curve_id_variant)
		var curve: Dictionary = curves.get(curve_id, {})
		var encounter_type := str(curve.get("encounter_type", ""))
		if not REQUIRED_CURVE_ENCOUNTER_TYPES.has(encounter_type) or encounter_types.has(encounter_type):
			errors.append("difficulty curve '%s' has invalid encounter_type '%s'" % [curve_id, encounter_type])
		encounter_types.append(encounter_type)
		var world_difficulty_id := str(curve.get("world_difficulty_id", ""))
		if world_difficulty_id != "wd0" or not world_difficulties.has(world_difficulty_id) or not _is_active(world_difficulties.get(world_difficulty_id, {})):
			errors.append("difficulty curve '%s' must reference active wd0" % curve_id)
		for field in ["hp_by_layer", "attack_by_layer", "defense_by_layer", "draw_bonus_by_layer"]:
			var values: Array = curve.get(field, [])
			if values.size() != 7:
				errors.append("difficulty curve '%s' field '%s' must contain seven layers" % [curve_id, field])
		for field in ["hp_per_node", "attack_node_step", "world_hp", "world_attack", "world_defense", "world_draw_step"]:
			if not curve.has(field):
				errors.append("difficulty curve '%s' is missing '%s'" % [curve_id, field])
	encounter_types.sort()
	var required_types := REQUIRED_CURVE_ENCOUNTER_TYPES.duplicate()
	required_types.sort()
	if encounter_types != required_types:
		errors.append("active difficulty curves must cover normal, elite and boss")


static func _validate_map_and_treasure(data: Dictionary, errors: Array) -> void:
	var active_layouts := _active_definitions(data.get("map_layouts", []))
	if active_layouts.size() != 1:
		errors.append("exactly one active map layout is required")
	else:
		var layout: Dictionary = active_layouts[0]
		if str(layout.get("layout_id", "")) != "main_story_layout_01":
			errors.append("active map layout id must be main_story_layout_01")
		var floors: Array = layout.get("floors", [])
		if floors.size() != 7:
			errors.append("active map layout must have seven floors")
		for floor_variant in floors:
			if not (floor_variant is Array) or (floor_variant as Array).is_empty():
				errors.append("active map layout contains an invalid floor")
				continue
			for node_variant in floor_variant:
				if not (node_variant is Dictionary):
					errors.append("active map layout contains a non-dictionary node")
					continue
				var node: Dictionary = node_variant
				if not ["normal", "elite", "boss", "event", "treasure", "shop", "rest"].has(str(node.get("type", ""))):
					errors.append("active map layout contains an unknown node type")
				var lane_type := typeof(node.get("lane"))
				if not node.has("lane") or not [TYPE_FLOAT, TYPE_INT].has(lane_type):
					errors.append("active map layout node has an invalid lane")
	var active_treasures := _active_definitions(data.get("treasures", []))
	if active_treasures.size() != 1:
		errors.append("exactly one active treasure is required")
	else:
		var treasure: Dictionary = active_treasures[0]
		if str(treasure.get("treasure_id", "")) != "treasure_card_choice_01":
			errors.append("active treasure id must be treasure_card_choice_01")
		if str(treasure.get("reward_kind", "")) != "card_choice" or int(treasure.get("choice_count", 0)) != 3:
			errors.append("active treasure must remain a three-card choice")


static func _validate_world_difficulties(data: Dictionary, errors: Array) -> void:
	var active := _active_definitions(data.get("world_difficulties", []))
	if active.size() != 1:
		errors.append("exactly one active world difficulty is required")
		return
	var definition: Dictionary = active[0]
	if str(definition.get("world_difficulty_id", "")) != "wd0" or int(definition.get("value", -1)) != 0:
		errors.append("wd0 must be the only active world difficulty")


static func _validate_visual_references(profiles: Dictionary, assets: Dictionary, errors: Array) -> void:
	for profile_id_variant in profiles.keys():
		var profile_id := str(profile_id_variant)
		var profile: Dictionary = profiles.get(profile_id, {})
		if not _is_active(profile):
			continue
		for field in ["portrait_asset_id", "battle_sprite_asset_id", "battle_animation_asset_id", "icon_asset_id"]:
			var asset_id := str(profile.get(field, ""))
			if asset_id == "" or not assets.has(asset_id) or not _is_active(assets.get(asset_id, {})):
				errors.append("visual profile '%s' references missing asset '%s'" % [profile_id, asset_id])


static func _validate_visual_audio_fallbacks(data: Dictionary, profiles: Dictionary, assets: Dictionary, audio_events: Dictionary, errors: Array) -> void:
	var default_profile_id := str(data.get("character_visual_default_profile_id", ""))
	if default_profile_id == "" or not profiles.has(default_profile_id) or not _is_active(profiles.get(default_profile_id, {})):
		errors.append("character visual default profile is missing or inactive")
	for asset_id_variant in data.get("visual_fallback_ids", []):
		var asset_id := str(asset_id_variant)
		if not assets.has(asset_id) or not _is_active(assets.get(asset_id, {})):
			errors.append("visual fallback asset '%s' is missing or inactive" % asset_id)
	for event_id_variant in data.get("battle_audio_event_ids", []):
		var event_id := str(event_id_variant)
		if not audio_events.has(event_id) or not _is_active(audio_events.get(event_id, {})):
			errors.append("battle audio route references missing event '%s'" % event_id)
	for event_id_variant in audio_events.keys():
		var event_id := str(event_id_variant)
		var definition: Dictionary = audio_events.get(event_id, {})
		if not _is_active(definition):
			continue
		var placeholder_id := str(definition.get("placeholder_id", ""))
		if placeholder_id != "" and (not audio_events.has(placeholder_id) or not _is_active(audio_events.get(placeholder_id, {}))):
			errors.append("audio event '%s' references missing placeholder '%s'" % [event_id, placeholder_id])


static func _validate_resource_paths(data: Dictionary, warnings: Array) -> void:
	for source_name in ["visual_assets", "audio_events"]:
		for definition_variant in data.get(source_name, []):
			var definition: Dictionary = definition_variant
			var path := str(definition.get("path", ""))
			if path != "" and not ResourceLoader.exists(path):
				warnings.append("%s '%s' uses fallback because '%s' is missing" % [source_name, str(definition.get("id", "")), path])


static func _validate_localization(data: Dictionary, errors: Array, _warnings: Array) -> void:
	var entries: Dictionary = data.get("localization_entries", {})
	for key_variant in data.get("required_localization_keys", []):
		var key := str(key_variant)
		if not entries.has(key):
			errors.append("required localization key '%s' is missing" % key)
			continue
		var entry: Dictionary = entries.get(key, {})
		if not entry.has("zh_cn") or not entry.has("en_us"):
			errors.append("localization key '%s' has no source fallback boundary" % key)
	for source_name in ["cards", "jobs", "characters", "statuses", "events"]:
		for definition_variant in data.get(source_name, []):
			var definition: Dictionary = definition_variant
			if not _is_active(definition):
				continue
			for field in ["name_key", "description_key"]:
				if definition.has(field):
					var key := str(definition.get(field, ""))
					if key != "" and not entries.has(key):
						errors.append("%s localization key '%s' is missing" % [source_name, key])


static func _index(definitions: Array, id_field: String, source_name: String, errors: Array) -> Dictionary:
	var result: Dictionary = {}
	for definition_variant in definitions:
		if not (definition_variant is Dictionary):
			continue
		var definition: Dictionary = definition_variant
		var definition_id := str(definition.get(id_field, ""))
		if definition_id == "":
			errors.append("%s has an empty %s" % [source_name, id_field])
			continue
		if result.has(definition_id):
			errors.append("%s has duplicate id '%s'" % [source_name, definition_id])
			continue
		result[definition_id] = definition.duplicate(true)
	return result


static func _index_composite(definitions: Array, fields: Array, source_name: String, errors: Array) -> Dictionary:
	var result: Dictionary = {}
	for definition_variant in definitions:
		var definition: Dictionary = definition_variant
		var parts: Array = []
		for field_variant in fields:
			parts.append(str(definition.get(str(field_variant), "")))
		var key := "|".join(parts)
		if key.contains("||") or key.begins_with("|") or key.ends_with("|"):
			errors.append("%s has an incomplete composite id" % source_name)
		elif result.has(key):
			errors.append("%s has duplicate composite id '%s'" % [source_name, key])
		else:
			result[key] = definition.duplicate(true)
	return result


static func _active_ids(index: Dictionary, _state_field: String) -> Array:
	var result: Array = []
	for definition_id_variant in index.keys():
		var definition_id := str(definition_id_variant)
		if _is_active(index.get(definition_id, {})):
			result.append(definition_id)
	return result


static func _active_definitions(definitions: Array) -> Array:
	var result: Array = []
	for definition_variant in definitions:
		var definition: Dictionary = definition_variant
		if _is_active(definition):
			result.append(definition.duplicate(true))
	return result


static func _is_active(definition: Dictionary) -> bool:
	return str(definition.get("content_state", "")) == "active"
