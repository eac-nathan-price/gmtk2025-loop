extends Node

@onready var player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var generator := AudioStreamGenerator.new()
var playback: AudioStreamGeneratorPlayback

# Audio settings
var sample_rate := 44100
var frequency := 440.0  # Hz
var amplitude := 0.8
var phase := 0.0

func _ready():
	# Setup stream
	generator.mix_rate = sample_rate
	player.stream = generator
	player.play()
	
	# Get the playback object to push samples to
	playback = player.get_stream_playback()
	set_process(true)

func _process(_delta):
	var frames_to_generate = playback.get_frames_available()
	for i in frames_to_generate:
		var sample = sin(phase * TAU) * amplitude
		var frame = Vector2(sample, sample)  # left and right channel
		playback.push_frame(frame)
		phase += frequency / sample_rate
		if phase >= 1.0:
			phase -= 1.0
