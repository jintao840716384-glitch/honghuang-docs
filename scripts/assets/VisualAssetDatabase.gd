extends RefCounted
class_name VisualAssetDatabase

const CATEGORY_UI_TEXTURE := "ui_texture"
const CATEGORY_STATIC_TEXTURE := "static_texture"
const CATEGORY_CHARACTER_SPRITE := "character_sprite"
const CATEGORY_BATTLE_ANIMATION := "battle_animation"
const CATEGORY_ICON := "icon"
const CATEGORY_VFX := "vfx"

const DEFAULT_UI_BACKGROUND := "ui.default_background"
const DEFAULT_PANEL_TEXTURE := "ui.default_panel"
const DEFAULT_CHARACTER_PORTRAIT := "character.default_portrait"
const DEFAULT_CHARACTER_BATTLE_SPRITE := "character.default_battle_sprite"
const DEFAULT_CARD_ICON := "icon.card_default"
const DEFAULT_BATTLE_ANIMATION := "battle_animation.default"

static func category_ids() -> Array:
	return [
		CATEGORY_UI_TEXTURE,
		CATEGORY_STATIC_TEXTURE,
		CATEGORY_CHARACTER_SPRITE,
		CATEGORY_BATTLE_ANIMATION,
		CATEGORY_ICON,
		CATEGORY_VFX
	]

static func asset_definitions() -> Dictionary:
	return {
		DEFAULT_UI_BACKGROUND: _asset(DEFAULT_UI_BACKGROUND, CATEGORY_UI_TEXTURE, "res://assets/visual/ui/default_background.png", Color(0.035, 0.040, 0.045, 1.0), "通用界面背景占位"),
		DEFAULT_PANEL_TEXTURE: _asset(DEFAULT_PANEL_TEXTURE, CATEGORY_UI_TEXTURE, "res://assets/visual/ui/default_panel.png", Color(0.055, 0.062, 0.068, 1.0), "通用面板皮肤占位"),
		"static.map_background": _asset("static.map_background", CATEGORY_STATIC_TEXTURE, "res://assets/visual/static/map_background.png", Color(0.035, 0.045, 0.046, 1.0), "探索地图背景占位"),
		"static.battle_background": _asset("static.battle_background", CATEGORY_STATIC_TEXTURE, "res://assets/visual/static/battle_background.png", Color(0.034, 0.038, 0.044, 1.0), "战斗背景占位"),
		DEFAULT_CHARACTER_PORTRAIT: _asset(DEFAULT_CHARACTER_PORTRAIT, CATEGORY_CHARACTER_SPRITE, "res://assets/visual/characters/default_portrait.png", Color(0.13, 0.15, 0.18, 1.0), "默认角色头像占位"),
		DEFAULT_CHARACTER_BATTLE_SPRITE: _asset(DEFAULT_CHARACTER_BATTLE_SPRITE, CATEGORY_CHARACTER_SPRITE, "res://assets/visual/characters/default_battle_sprite.png", Color(0.16, 0.18, 0.22, 1.0), "默认战斗精灵占位"),
		"character.sword.portrait": _asset("character.sword.portrait", CATEGORY_CHARACTER_SPRITE, "res://assets/visual/characters/sword_portrait.png", Color(0.14, 0.17, 0.22, 1.0), "剑修头像占位"),
		"character.sword.battle_sprite": _asset("character.sword.battle_sprite", CATEGORY_CHARACTER_SPRITE, "res://assets/visual/characters/sword_battle_sprite.png", Color(0.14, 0.17, 0.22, 1.0), "剑修战斗精灵占位"),
		"character.talisman.portrait": _asset("character.talisman.portrait", CATEGORY_CHARACTER_SPRITE, "res://assets/visual/characters/talisman_portrait.png", Color(0.13, 0.12, 0.20, 1.0), "符修头像占位"),
		"character.talisman.battle_sprite": _asset("character.talisman.battle_sprite", CATEGORY_CHARACTER_SPRITE, "res://assets/visual/characters/talisman_battle_sprite.png", Color(0.13, 0.12, 0.20, 1.0), "符修战斗精灵占位"),
		"character.enemy.beast": _asset("character.enemy.beast", CATEGORY_CHARACTER_SPRITE, "res://assets/visual/characters/enemy_beast.png", Color(0.17, 0.13, 0.10, 1.0), "妖兽类敌人占位"),
		"character.enemy.caster": _asset("character.enemy.caster", CATEGORY_CHARACTER_SPRITE, "res://assets/visual/characters/enemy_caster.png", Color(0.12, 0.12, 0.18, 1.0), "施法类敌人占位"),
		"character.enemy.armored": _asset("character.enemy.armored", CATEGORY_CHARACTER_SPRITE, "res://assets/visual/characters/enemy_armored.png", Color(0.15, 0.16, 0.17, 1.0), "护甲类敌人占位"),
		DEFAULT_CARD_ICON: _asset(DEFAULT_CARD_ICON, CATEGORY_ICON, "res://assets/visual/icons/card_default.png", Color(0.20, 0.19, 0.14, 1.0), "默认卡牌图标占位"),
		"icon.attack": _asset("icon.attack", CATEGORY_ICON, "res://assets/visual/icons/attack.png", Color(0.55, 0.18, 0.14, 1.0), "攻击图标占位"),
		"icon.defense": _asset("icon.defense", CATEGORY_ICON, "res://assets/visual/icons/defense.png", Color(0.18, 0.32, 0.55, 1.0), "防御图标占位"),
		DEFAULT_BATTLE_ANIMATION: _asset(DEFAULT_BATTLE_ANIMATION, CATEGORY_BATTLE_ANIMATION, "res://assets/visual/battle_animations/default.tres", Color(0.80, 0.82, 0.86, 1.0), "默认战斗动画占位"),
		"battle_animation.attack_slash": _asset("battle_animation.attack_slash", CATEGORY_BATTLE_ANIMATION, "res://assets/visual/battle_animations/attack_slash.tres", Color(1.0, 0.56, 0.24, 1.0), "攻击斩击动画占位"),
		"battle_animation.hit_flash": _asset("battle_animation.hit_flash", CATEGORY_BATTLE_ANIMATION, "res://assets/visual/battle_animations/hit_flash.tres", Color(1.0, 0.24, 0.18, 1.0), "受击闪光动画占位"),
		"battle_animation.heal_glow": _asset("battle_animation.heal_glow", CATEGORY_BATTLE_ANIMATION, "res://assets/visual/battle_animations/heal_glow.tres", Color(0.32, 1.0, 0.48, 1.0), "治疗光效动画占位"),
		"vfx.card_play": _asset("vfx.card_play", CATEGORY_VFX, "res://assets/visual/battle_animations/card_play_vfx.tres", Color(0.82, 0.72, 1.0, 1.0), "出牌表现占位")
	}

static func has_asset(asset_id: String) -> bool:
	return asset_definitions().has(asset_id)

static func asset(asset_id: String, fallback_id := DEFAULT_CHARACTER_PORTRAIT) -> Dictionary:
	var definitions: Dictionary = asset_definitions()
	if definitions.has(asset_id):
		return (definitions[asset_id] as Dictionary).duplicate(true)
	if definitions.has(fallback_id):
		return (definitions[fallback_id] as Dictionary).duplicate(true)
	return {}

static func assets_for_category(category_id: String) -> Array:
	var result: Array = []
	for asset_variant in asset_definitions().values():
		var definition: Dictionary = asset_variant
		if str(definition.get("category", "")) == category_id:
			result.append(definition.duplicate(true))
	return result

static func asset_path(asset_id: String) -> String:
	return str(asset(asset_id).get("path", ""))

static func placeholder_color(asset_id: String, fallback := Color(0.13, 0.15, 0.18, 1.0)) -> Color:
	var definition: Dictionary = asset(asset_id)
	if definition.has("placeholder_color"):
		return definition["placeholder_color"] as Color
	return fallback

static func texture(asset_id: String) -> Texture2D:
	var path := asset_path(asset_id)
	if path == "" or not ResourceLoader.exists(path):
		return null
	var resource := load(path)
	return resource as Texture2D

static func _asset(asset_id: String, category_id: String, path: String, placeholder_color: Color, description: String) -> Dictionary:
	return {
		"id": asset_id,
		"category": category_id,
		"path": path,
		"placeholder_color": placeholder_color,
		"description": description
	}
