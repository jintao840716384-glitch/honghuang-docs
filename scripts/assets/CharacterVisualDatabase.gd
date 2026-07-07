extends RefCounted
class_name CharacterVisualDatabase

const VisualAssetDatabaseScript = preload("res://scripts/assets/VisualAssetDatabase.gd")

const DEFAULT_PROFILE_ID := "default"

static func visual_profiles() -> Dictionary:
	return {
		DEFAULT_PROFILE_ID: _profile(
			DEFAULT_PROFILE_ID,
			VisualAssetDatabaseScript.DEFAULT_CHARACTER_PORTRAIT,
			VisualAssetDatabaseScript.DEFAULT_CHARACTER_BATTLE_SPRITE,
			VisualAssetDatabaseScript.DEFAULT_BATTLE_ANIMATION,
			VisualAssetDatabaseScript.DEFAULT_CARD_ICON,
			Color(0.13, 0.15, 0.18, 1.0)
		),
		"sword": _profile(
			"sword",
			"character.sword.portrait",
			"character.sword.battle_sprite",
			"battle_animation.attack_slash",
			"icon.attack",
			Color(0.14, 0.17, 0.22, 1.0)
		),
		"talisman": _profile(
			"talisman",
			"character.talisman.portrait",
			"character.talisman.battle_sprite",
			"vfx.card_play",
			VisualAssetDatabaseScript.DEFAULT_CARD_ICON,
			Color(0.13, 0.12, 0.20, 1.0)
		),
		"beast": _enemy_profile("beast", "character.enemy.beast", Color(0.17, 0.13, 0.10, 1.0)),
		"armored": _enemy_profile("armored", "character.enemy.armored", Color(0.15, 0.16, 0.17, 1.0)),
		"caster": _enemy_profile("caster", "character.enemy.caster", Color(0.12, 0.12, 0.18, 1.0)),
		"bandit": _enemy_profile("bandit", "character.enemy.caster", Color(0.13, 0.12, 0.14, 1.0)),
		"stone_boss": _enemy_profile("stone_boss", "character.enemy.armored", Color(0.16, 0.16, 0.15, 1.0)),
		"hex_boss": _enemy_profile("hex_boss", "character.enemy.caster", Color(0.14, 0.10, 0.18, 1.0)),
		"ember_boss": _enemy_profile("ember_boss", "character.enemy.caster", Color(0.20, 0.11, 0.08, 1.0)),
		"guard_boss": _enemy_profile("guard_boss", "character.enemy.armored", Color(0.15, 0.16, 0.19, 1.0)),
		"drain_boss": _enemy_profile("drain_boss", "character.enemy.caster", Color(0.10, 0.14, 0.13, 1.0)),
		"thunder_boss": _enemy_profile("thunder_boss", "character.enemy.caster", Color(0.13, 0.13, 0.20, 1.0)),
		"warlord_boss": _enemy_profile("warlord_boss", "character.enemy.beast", Color(0.19, 0.12, 0.09, 1.0)),
		"mirror_boss": _enemy_profile("mirror_boss", "character.enemy.armored", Color(0.12, 0.15, 0.18, 1.0)),
		"chain_boss": _enemy_profile("chain_boss", "character.enemy.caster", Color(0.11, 0.12, 0.17, 1.0))
	}

static func profile(profile_id: String) -> Dictionary:
	var profiles: Dictionary = visual_profiles()
	if profiles.has(profile_id):
		return (profiles[profile_id] as Dictionary).duplicate(true)
	return (profiles[DEFAULT_PROFILE_ID] as Dictionary).duplicate(true)

static func profile_for_unit_data(unit_data: Dictionary) -> Dictionary:
	var profile_id := str(unit_data.get("visual_profile_id", unit_data.get("animation_profile", DEFAULT_PROFILE_ID)))
	var result := profile(profile_id)
	result["character_id"] = str(unit_data.get("id", unit_data.get("unit_id", "")))
	result["display_name"] = str(unit_data.get("name", unit_data.get("display_name", "")))
	return result

static func portrait_asset_id(profile_id: String) -> String:
	return str(profile(profile_id).get("portrait_asset_id", VisualAssetDatabaseScript.DEFAULT_CHARACTER_PORTRAIT))

static func battle_sprite_asset_id(profile_id: String) -> String:
	return str(profile(profile_id).get("battle_sprite_asset_id", VisualAssetDatabaseScript.DEFAULT_CHARACTER_BATTLE_SPRITE))

static func battle_animation_asset_id(profile_id: String) -> String:
	return str(profile(profile_id).get("battle_animation_asset_id", VisualAssetDatabaseScript.DEFAULT_BATTLE_ANIMATION))

static func _enemy_profile(profile_id: String, sprite_asset_id: String, color: Color) -> Dictionary:
	return _profile(profile_id, sprite_asset_id, sprite_asset_id, "battle_animation.attack_slash", "icon.attack", color)

static func _profile(profile_id: String, portrait_asset_id: String, battle_sprite_asset_id: String, battle_animation_asset_id: String, icon_asset_id: String, placeholder_color: Color) -> Dictionary:
	return {
		"id": profile_id,
		"portrait_asset_id": portrait_asset_id,
		"battle_sprite_asset_id": battle_sprite_asset_id,
		"battle_animation_asset_id": battle_animation_asset_id,
		"icon_asset_id": icon_asset_id,
		"placeholder_color": placeholder_color
	}
