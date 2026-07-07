extends Node
class_name MusicManager

const AudioEventDatabaseScript = preload("res://scripts/audio/AudioEventDatabase.gd")

var player: AudioStreamPlayer
var current_event_id := ""
var music_volume := 0.75

func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.name = "MusicPlayer"
	add_child(player)
	player.finished.connect(_on_music_finished)

func play_music(event_id: String) -> bool:
	var definition: Dictionary = AudioEventDatabaseScript.event_definition(event_id)
	if definition.is_empty() or str(definition.get("category", "")) != AudioEventDatabaseScript.CATEGORY_MUSIC:
		return false
	current_event_id = event_id
	_apply_volume()
	var stream := _stream_for_event(event_id)
	if stream == null:
		player.stop()
		player.stream = null
		return false
	player.stream = stream
	player.play()
	return true

func stop_music() -> void:
	current_event_id = ""
	if player != null:
		player.stop()

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	_apply_volume()

func register_stream(event_id: String, stream: AudioStream) -> bool:
	if AudioEventDatabaseScript.event_definition(event_id).is_empty():
		return false
	if player == null:
		return false
	if current_event_id == event_id:
		player.stream = stream
	return true

func _stream_for_event(event_id: String) -> AudioStream:
	var path := AudioEventDatabaseScript.stream_path(event_id)
	if path == "" or not ResourceLoader.exists(path):
		return null
	var resource := load(path)
	return resource as AudioStream

func _apply_volume() -> void:
	if player == null:
		return
	if music_volume <= 0.001:
		player.volume_db = -80.0
		return
	var event_volume := AudioEventDatabaseScript.volume_db(current_event_id) if current_event_id != "" else -12.0
	player.volume_db = event_volume + linear_to_db(music_volume)

func _on_music_finished() -> void:
	if current_event_id != "" and player != null and player.stream != null:
		player.play()
