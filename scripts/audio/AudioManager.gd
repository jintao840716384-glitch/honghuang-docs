extends Node
class_name AudioManager

const SAMPLE_RATE := 44100
const MASTER_VOLUME_DB := -11.0

const EVENTS := {
	"card_hover": {"volume": -24.0, "cooldown_ms": 28},
	"card_play": {"volume": -14.0, "cooldown_ms": 20},
	"card_set": {"volume": -13.0, "cooldown_ms": 30},
	"card_place": {"volume": -13.0, "cooldown_ms": 30},
	"card_equip": {"volume": -12.0, "cooldown_ms": 30},
	"card_break": {"volume": -11.0, "cooldown_ms": 50},
	"attack": {"volume": -14.0, "cooldown_ms": 60},
	"hit": {"volume": -10.0, "cooldown_ms": 35},
	"defense_activate": {"volume": -12.0, "cooldown_ms": 30},
	"chain_start": {"volume": -16.0, "cooldown_ms": 80},
	"chain_resolve": {"volume": -15.0, "cooldown_ms": 35},
	"heal": {"volume": -13.0, "cooldown_ms": 40},
	"victory": {"volume": -13.0, "cooldown_ms": 100},
	"ui_click": {"volume": -22.0, "cooldown_ms": 20},
	"ui_confirm": {"volume": -18.0, "cooldown_ms": 20}
}

var players: Dictionary = {}
var last_play_msec: Dictionary = {}

func _ready() -> void:
	_build_placeholder_streams()

func play_event(event_name: String) -> void:
	if not EVENTS.has(event_name):
		return
	var now := Time.get_ticks_msec()
	var cooldown := int(EVENTS[event_name].get("cooldown_ms", 0))
	if last_play_msec.has(event_name) and now - int(last_play_msec[event_name]) < cooldown:
		return
	last_play_msec[event_name] = now
	var player := players.get(event_name, null) as AudioStreamPlayer
	if player == null or player.stream == null:
		return
	player.pitch_scale = 1.0 + randf_range(-0.035, 0.035)
	player.play()

func register_stream(event_name: String, stream: AudioStream) -> void:
	if not EVENTS.has(event_name):
		return
	var player := _player_for(event_name)
	player.stream = stream

func _build_placeholder_streams() -> void:
	register_stream("card_hover", _noise_sweep(0.060, 0.34, 0.70, 0.20, 1001))
	register_stream("card_play", _whoosh(0.145, 840.0, 180.0, 0.46, 1002))
	register_stream("card_set", _thump_chime(0.135, 260.0, 740.0, 0.50, 1003))
	register_stream("card_place", _thump_chime(0.160, 330.0, 1040.0, 0.48, 1004))
	register_stream("card_equip", _chime(0.190, [440.0, 880.0, 1320.0], 0.45))
	register_stream("card_break", _break_noise(0.260, 0.72, 1005))
	register_stream("attack", _whoosh(0.130, 520.0, 110.0, 0.42, 1006))
	register_stream("hit", _impact(0.150, 0.70, 1007))
	register_stream("defense_activate", _chime(0.180, [520.0, 780.0, 1180.0], 0.42))
	register_stream("chain_start", _chime(0.210, [330.0, 660.0, 990.0], 0.34))
	register_stream("chain_resolve", _chime(0.150, [720.0, 1080.0], 0.32))
	register_stream("heal", _chime(0.240, [520.0, 760.0, 1040.0], 0.38))
	register_stream("victory", _arpeggio(0.420, [520.0, 660.0, 880.0, 1320.0], 0.38))
	register_stream("ui_click", _click(0.040, 1240.0, 0.24))
	register_stream("ui_confirm", _click(0.060, 860.0, 0.34))

func _player_for(event_name: String) -> AudioStreamPlayer:
	var player := players.get(event_name, null) as AudioStreamPlayer
	if player == null:
		player = AudioStreamPlayer.new()
		player.name = "Sfx_%s" % event_name
		player.volume_db = MASTER_VOLUME_DB + float(EVENTS[event_name].get("volume", -16.0))
		add_child(player)
		players[event_name] = player
	return player

func _stream_from_samples(samples: PackedFloat32Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in range(samples.size()):
		var sample := int(clamp(samples[i], -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream

func _noise_sweep(duration: float, amplitude: float, start_bias: float, end_bias: float, seed_value: int) -> AudioStreamWAV:
	var count := int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(count):
		var t := float(i) / float(max(1, count - 1))
		var env := sin(PI * t) * pow(1.0 - t, 0.25)
		var gate := lerpf(start_bias, end_bias, t)
		var noise := rng.randf_range(-1.0, 1.0) * gate
		var paper_tone := sin(TAU * (900.0 + 260.0 * t) * float(i) / SAMPLE_RATE) * 0.16
		samples[i] = (noise + paper_tone) * amplitude * env
	return _stream_from_samples(samples)

func _whoosh(duration: float, start_freq: float, end_freq: float, amplitude: float, seed_value: int) -> AudioStreamWAV:
	var count := int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var phase := 0.0
	for i in range(count):
		var t := float(i) / float(max(1, count - 1))
		var freq := lerpf(start_freq, end_freq, t)
		phase += TAU * freq / SAMPLE_RATE
		var env := pow(1.0 - t, 1.8) * sin(PI * min(1.0, t * 2.2))
		var noise := rng.randf_range(-1.0, 1.0) * 0.22 * (1.0 - t)
		samples[i] = (sin(phase) * 0.62 + noise) * amplitude * env
	return _stream_from_samples(samples)

func _thump_chime(duration: float, low_freq: float, high_freq: float, amplitude: float, seed_value: int) -> AudioStreamWAV:
	var count := int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(count):
		var t := float(i) / float(max(1, count - 1))
		var thump_env := exp(-t * 12.0)
		var chime_env := exp(-t * 5.5)
		var low := sin(TAU * low_freq * float(i) / SAMPLE_RATE) * thump_env
		var high := sin(TAU * high_freq * float(i) / SAMPLE_RATE) * chime_env * 0.45
		var click_noise := rng.randf_range(-1.0, 1.0) * exp(-t * 34.0) * 0.25
		samples[i] = (low + high + click_noise) * amplitude
	return _stream_from_samples(samples)

func _chime(duration: float, frequencies: Array, amplitude: float) -> AudioStreamWAV:
	var count := int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in range(count):
		var t := float(i) / float(max(1, count - 1))
		var env := sin(PI * min(1.0, t * 5.0)) * exp(-t * 4.2)
		var mixed := 0.0
		for j in range(frequencies.size()):
			var freq := float(frequencies[j])
			mixed += sin(TAU * freq * float(i) / SAMPLE_RATE) / float(frequencies.size())
		samples[i] = mixed * amplitude * env
	return _stream_from_samples(samples)

func _impact(duration: float, amplitude: float, seed_value: int) -> AudioStreamWAV:
	var count := int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(count):
		var t := float(i) / float(max(1, count - 1))
		var env := exp(-t * 15.0)
		var body := sin(TAU * 92.0 * float(i) / SAMPLE_RATE) * 0.65
		var crack := rng.randf_range(-1.0, 1.0) * 0.55
		samples[i] = (body + crack) * amplitude * env
	return _stream_from_samples(samples)

func _break_noise(duration: float, amplitude: float, seed_value: int) -> AudioStreamWAV:
	var count := int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(count):
		var t := float(i) / float(max(1, count - 1))
		var burst_1 := exp(-pow(t - 0.05, 2.0) * 900.0)
		var burst_2 := exp(-pow(t - 0.18, 2.0) * 520.0)
		var env := (burst_1 + burst_2 * 0.7) * exp(-t * 2.5)
		var glass := rng.randf_range(-1.0, 1.0) * 0.75
		var shard := sin(TAU * (1800.0 + 900.0 * t) * float(i) / SAMPLE_RATE) * 0.25
		samples[i] = (glass + shard) * amplitude * env
	return _stream_from_samples(samples)

func _click(duration: float, frequency: float, amplitude: float) -> AudioStreamWAV:
	var count := int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in range(count):
		var t := float(i) / float(max(1, count - 1))
		var env := exp(-t * 34.0)
		samples[i] = sin(TAU * frequency * float(i) / SAMPLE_RATE) * amplitude * env
	return _stream_from_samples(samples)

func _arpeggio(duration: float, frequencies: Array, amplitude: float) -> AudioStreamWAV:
	var count := int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var note_count: int = max(1, frequencies.size())
	for i in range(count):
		var t := float(i) / float(max(1, count - 1))
		var note_index: int = min(note_count - 1, int(floor(t * float(note_count))))
		var local_t := fmod(t * float(note_count), 1.0)
		var env := sin(PI * min(1.0, local_t * 4.0)) * exp(-local_t * 2.2)
		var freq := float(frequencies[note_index])
		var tone := sin(TAU * freq * float(i) / SAMPLE_RATE)
		var overtone := sin(TAU * freq * 2.0 * float(i) / SAMPLE_RATE) * 0.25
		samples[i] = (tone + overtone) * amplitude * env
	return _stream_from_samples(samples)
