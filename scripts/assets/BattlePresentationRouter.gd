extends RefCounted
class_name BattlePresentationRouter

const VisualAssetDatabaseScript = preload("res://scripts/assets/VisualAssetDatabase.gd")

const ACTION_ACTOR_ANIMATION := "actor_animation"
const ACTION_VFX := "vfx"
const ACTION_CARD_MOTION := "card_motion"

static func actions_for_combat_event(event: Dictionary) -> Array:
	match str(event.get("type", "")):
		"attack_started":
			return [
				_actor_animation(str(event.get("source", "enemy")), "attack", "battle_animation.attack_slash"),
				_vfx(str(event.get("target", "player")), "slash", "battle_animation.attack_slash")
			]
		"damage_applied":
			return [
				_actor_animation(str(event.get("target", "")), "hit", "battle_animation.hit_flash")
			]
		"heal_applied":
			return [
				_vfx(str(event.get("target", "player")), "heal", "battle_animation.heal_glow")
			]
		"card_played":
			return [
				_card_motion("play", "vfx.card_play")
			]
		"defense_card_set", "card_placed_in_spell_zone":
			return [
				_card_motion("place", "vfx.card_play")
			]
		"card_equipped":
			return [
				_card_motion("equip", "vfx.card_play")
			]
	return []

static func default_action_for_kind(action_kind: String) -> Dictionary:
	match action_kind:
		ACTION_ACTOR_ANIMATION:
			return _actor_animation("", "idle", VisualAssetDatabaseScript.DEFAULT_BATTLE_ANIMATION)
		ACTION_VFX:
			return _vfx("", "default", VisualAssetDatabaseScript.DEFAULT_BATTLE_ANIMATION)
		ACTION_CARD_MOTION:
			return _card_motion("default", "vfx.card_play")
	return {}

static func _actor_animation(target_key: String, animation_name: String, asset_id: String) -> Dictionary:
	return {
		"kind": ACTION_ACTOR_ANIMATION,
		"target": target_key,
		"animation": animation_name,
		"asset_id": asset_id
	}

static func _vfx(target_key: String, vfx_name: String, asset_id: String) -> Dictionary:
	return {
		"kind": ACTION_VFX,
		"target": target_key,
		"vfx": vfx_name,
		"asset_id": asset_id
	}

static func _card_motion(motion_name: String, asset_id: String) -> Dictionary:
	return {
		"kind": ACTION_CARD_MOTION,
		"motion": motion_name,
		"asset_id": asset_id
	}
