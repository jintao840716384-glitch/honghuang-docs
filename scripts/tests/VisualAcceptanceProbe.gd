extends SceneTree

const CAPTURE_SIZE := Vector2i(1920, 1080)
const OUTPUT_ENV := "TAIXUANZONG_VISUAL_OUTPUT_DIR"
const DEFAULT_OUTPUT_FOLDER := "taixuanzong_visual_acceptance"
const SAMPLE_STEP := 8
const SCREEN_ORDER := [
	"main_menu",
	"job_select",
	"character_prep",
	"map",
	"battle",
	"run_settlement"
]

const MainMenuScene = preload("res://scenes/main/MainMenuScene.tscn")
const JobSelectScene = preload("res://scenes/main/JobSelectScene.tscn")
const CharacterPrepScene = preload("res://scenes/main/CharacterPrepScene.tscn")
const MapScene = preload("res://scenes/map/MapScene.tscn")
const BattleScene = preload("res://scenes/battle/BattleScene.tscn")
const RunSettlementScene = preload("res://scenes/main/RunSettlementScene.tscn")
const RunStateScript = preload("res://scripts/run/RunState.gd")

var _output_dir := ""
var _all_ok := true


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name().to_lower() == "headless":
		_fail("VisualAcceptanceProbe requires a non-headless display backend.")
		quit(1)
		return

	var selected_screens: Array = _resolve_screens()
	if selected_screens.is_empty():
		quit(1)
		return

	_output_dir = _resolve_output_dir()
	if _output_dir == "":
		quit(1)
		return
	var mkdir_error: Error = DirAccess.make_dir_recursive_absolute(_output_dir)
	if mkdir_error != OK:
		_fail("Unable to create output directory: %s (error %d)" % [_output_dir, mkdir_error])
		quit(1)
		return

	root.size = CAPTURE_SIZE
	await process_frame

	for screen_variant in selected_screens:
		await _capture_selected_screen(str(screen_variant))

	if _all_ok:
		print("VISUAL_ACCEPTANCE_SCREENS|%s" % ",".join(selected_screens))
		print("VISUAL_ACCEPTANCE_OUTPUT_DIR|%s" % _output_dir)
		print("VISUAL_ACCEPTANCE_PROBE_OK")
		quit(0)
	else:
		push_error("VISUAL_ACCEPTANCE_PROBE_FAILED")
		quit(1)


func _capture_selected_screen(screen: String) -> void:
	match screen:
		"main_menu":
			await _capture_scene(screen, MainMenuScene.instantiate())
		"job_select":
			await _capture_scene(screen, JobSelectScene.instantiate())
		"character_prep":
			await _capture_scene(screen, CharacterPrepScene.instantiate(), "setup", ["sword"])
		"map":
			var map_state = RunStateScript.new()
			map_state.start("sword")
			await _capture_scene(screen, MapScene.instantiate(), "setup", [map_state])
		"battle":
			var battle_state = RunStateScript.new()
			battle_state.start("sword")
			var battle_node: Dictionary = battle_state.available_nodes()[0]
			var battle_args := [
				battle_state.job_id,
				battle_state.deck_ids,
				battle_state.battle_number_for_node(battle_node),
				str(battle_node.get("type", "normal")),
				battle_state.run_context(),
				battle_state.battle_spirit_reward(battle_node)
			]
			await _capture_scene(screen, BattleScene.instantiate(), "setup_run_battle", battle_args)
		"run_settlement":
			var settlement_state = RunStateScript.new()
			settlement_state.start("sword")
			var settlement_result := {"base": 9, "multiplier": 1.25, "awarded": 12, "completed": false}
			await _capture_scene(screen, RunSettlementScene.instantiate(), "setup", [settlement_state, settlement_result])
		_:
			_fail("Unsupported screen reached capture: %s" % screen)


func _capture_scene(label: String, scene: Node, setup_method: String = "", setup_args: Array = []) -> void:
	root.add_child(scene)
	if setup_method != "":
		scene.callv(setup_method, setup_args)

	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

	var image: Image = root.get_texture().get_image()
	var output_path := _output_dir.path_join("%s.png" % label)
	if FileAccess.file_exists(output_path):
		var remove_error: Error = DirAccess.remove_absolute(output_path)
		if remove_error != OK:
			_fail("Unable to remove stale capture: %s (error %d)" % [output_path, remove_error])

	if image == null or image.is_empty():
		_fail("Viewport image is empty for %s." % label)
	else:
		var save_error: Error = image.save_png(output_path)
		if save_error != OK:
			_fail("save_png failed for %s (error %d)." % [label, save_error])
		else:
			_validate_saved_capture(label, output_path)

	root.remove_child(scene)
	scene.queue_free()
	await process_frame
	await process_frame


func _validate_saved_capture(label: String, output_path: String) -> void:
	if not FileAccess.file_exists(output_path):
		_fail("Capture file does not exist: %s" % output_path)
		return
	var file := FileAccess.open(output_path, FileAccess.READ)
	if file == null:
		_fail("Capture file cannot be opened: %s" % output_path)
		return
	var file_size: int = file.get_length()
	file.close()
	if file_size <= 0:
		_fail("Capture file is empty: %s" % output_path)
		return

	var saved_image := Image.new()
	var load_error: Error = saved_image.load(output_path)
	if load_error != OK:
		_fail("Saved PNG cannot be loaded for %s (error %d)." % [label, load_error])
		return
	if saved_image.get_size() != CAPTURE_SIZE:
		_fail("Capture size mismatch for %s: %s" % [label, saved_image.get_size()])
		return

	var sample_stats := _sample_image(saved_image)
	var visible_samples: int = int(sample_stats.get("visible_samples", 0))
	var unique_colors: int = int(sample_stats.get("unique_colors", 0))
	if visible_samples == 0:
		_fail("Capture has no visible sampled pixels: %s" % output_path)
		return
	if unique_colors < 2:
		_fail("Capture is blank or monochrome: %s" % output_path)
		return

	print("VISUAL_CAPTURE_OK|%s|%s|%dx%d|%d bytes|%d sampled colors" % [
		label,
		output_path,
		saved_image.get_width(),
		saved_image.get_height(),
		file_size,
		unique_colors
	])


func _sample_image(image: Image) -> Dictionary:
	var colors := {}
	var visible_samples := 0
	for y in range(0, image.get_height(), SAMPLE_STEP):
		for x in range(0, image.get_width(), SAMPLE_STEP):
			var color: Color = image.get_pixel(x, y)
			if color.a <= 0.01:
				continue
			visible_samples += 1
			var color_key := "%d,%d,%d" % [
				int(round(color.r * 255.0)),
				int(round(color.g * 255.0)),
				int(round(color.b * 255.0))
			]
			colors[color_key] = true
	return {
		"visible_samples": visible_samples,
		"unique_colors": colors.size()
	}


func _resolve_screens() -> Array:
	var found_argument := false
	var requested_value := ""
	for argument_variant in OS.get_cmdline_user_args():
		var argument := str(argument_variant)
		if not argument.begins_with("--screens="):
			continue
		if found_argument:
			_fail("--screens may only be provided once.")
			return []
		found_argument = true
		requested_value = argument.trim_prefix("--screens=")

	if not found_argument:
		return SCREEN_ORDER.duplicate()
	if requested_value.strip_edges() == "":
		_fail("--screens must contain at least one canonical screen.")
		return []

	var requested := {}
	for screen_variant in requested_value.split(",", true):
		var screen := str(screen_variant).strip_edges()
		if screen == "":
			_fail("--screens contains an empty screen name.")
			return []
		if not SCREEN_ORDER.has(screen):
			_fail("Unknown screen '%s'. Allowed: %s" % [screen, ",".join(SCREEN_ORDER)])
			return []
		requested[screen] = true

	var selected: Array = []
	for canonical_variant in SCREEN_ORDER:
		var canonical := str(canonical_variant)
		if requested.has(canonical):
			selected.append(canonical)
	return selected


func _resolve_output_dir() -> String:
	var requested := ""
	for argument_variant in OS.get_cmdline_user_args():
		var argument := str(argument_variant)
		if argument.begins_with("--output-dir="):
			requested = argument.trim_prefix("--output-dir=")
	if requested == "":
		requested = OS.get_environment(OUTPUT_ENV)
	if requested == "":
		requested = OS.get_temp_dir().path_join(DEFAULT_OUTPUT_FOLDER)
	if requested.begins_with("res://"):
		_fail("Capture output must not use res://.")
		return ""

	var absolute_path := requested
	if requested.begins_with("user://"):
		absolute_path = ProjectSettings.globalize_path(requested)
	elif not requested.is_absolute_path():
		absolute_path = OS.get_temp_dir().path_join(requested)
	absolute_path = absolute_path.simplify_path()

	var normalized_output := absolute_path.replace("\\", "/").trim_suffix("/").to_lower()
	var project_root := ProjectSettings.globalize_path("res://").simplify_path().replace("\\", "/").trim_suffix("/").to_lower()
	if normalized_output == project_root or normalized_output.begins_with(project_root + "/"):
		_fail("Capture output must be outside the project worktree: %s" % absolute_path)
		return ""
	return absolute_path


func _fail(message: String) -> void:
	_all_ok = false
	push_error(message)
