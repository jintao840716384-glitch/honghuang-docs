extends RefCounted
class_name UIStyleFactory

static func panel_style(bg: Color, border: Color, radius: int, border_width: int, margins := Vector4(10, 10, 8, 8)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = margins.x
	style.content_margin_right = margins.y
	style.content_margin_top = margins.z
	style.content_margin_bottom = margins.w
	return style

static func button_style(bg: Color, border: Color, radius: int, border_width: int, margins := Vector4(10, 10, 8, 8), shadow_size := 0) -> StyleBoxFlat:
	var style := panel_style(bg, border, radius, border_width, margins)
	if shadow_size > 0:
		style.shadow_color = Color(border.r, border.g, border.b, 0.44)
		style.shadow_size = shadow_size
	return style

static func apply_button_style(
	button: Button,
	bg: Color,
	border: Color,
	radius: int,
	normal_border_width: int,
	hover_border_width: int,
	pressed_border_width: int,
	margins := Vector4(10, 10, 8, 8),
	shadow_size := 0,
	hover_border_lighten := 0.12,
	pressed_bg_darken := 0.06,
	pressed_border_lighten := 0.18,
	hover_bg_lighten := 0.08
) -> void:
	var hover_shadow := 0
	if shadow_size > 0:
		hover_shadow = shadow_size + 3
	button.add_theme_stylebox_override("normal", button_style(bg, border, radius, normal_border_width, margins, shadow_size))
	button.add_theme_stylebox_override("hover", button_style(bg.lightened(hover_bg_lighten), border.lightened(hover_border_lighten), radius, hover_border_width, margins, hover_shadow))
	button.add_theme_stylebox_override("pressed", button_style(bg.darkened(pressed_bg_darken), border.lightened(pressed_border_lighten), radius, pressed_border_width, margins, shadow_size))
	button.add_theme_color_override("font_color", Color(0.94, 0.92, 0.86, 1.0))
