extends RefCounted
class_name BattleAudioRouter

const COMBAT_EVENT_AUDIO_ROUTES := {
	"attack_started": ["attack"],
	"damage_applied": ["hit"],
	"heal_applied": ["heal"],
	"card_played": ["card_play"],
	"defense_card_set": ["card_set"],
	"card_placed_in_spell_zone": ["card_place"],
	"card_equipped": ["card_equip"],
	"card_destroyed": ["card_break"]
}

static func events_for_combat_event(event: Dictionary) -> Array:
	return (COMBAT_EVENT_AUDIO_ROUTES.get(str(event.get("type", "")), []) as Array).duplicate()


static func routed_audio_event_ids() -> Array:
	var result: Array = []
	for ids_variant in COMBAT_EVENT_AUDIO_ROUTES.values():
		for event_id_variant in ids_variant:
			var event_id := str(event_id_variant)
			if not result.has(event_id):
				result.append(event_id)
	result.sort()
	return result
