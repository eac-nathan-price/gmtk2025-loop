extends Control

# DAW System Variables
var bpm = 120
var beats_per_bar = 4
var bars = 4
var sixteenth_notes_per_bar = 16
var total_sixteenth_notes = 64  # 4 bars * 16 sixteenth notes

# Timing
var beat_time = 60.0 / bpm
var sixteenth_note_time = beat_time / 4.0
var current_time = 0.0
var is_recording = false
var is_playing = false
var recording_start_time = 0.0

# Tracks data - each track is an array of booleans for each sixteenth note
var tracks = {
	"move_right": [],
	"move_left": [],
	"jump": []
}

# Input mapping - we'll use any key press for recording
var input_map = {
	"move_right": "ui_right",
	"move_left": "ui_left", 
	"jump": "ui_accept"
}

# UI References
@onready var record_button = $BottomHalf/DAWHeader/RecordButton
@onready var play_button = $BottomHalf/DAWHeader/PlayButton
@onready var stop_button = $BottomHalf/DAWHeader/StopButton
@onready var bpm_display = $BottomHalf/DAWHeader/BPMDisplay
@onready var click_track = $ClickTrack

# Character reference
@onready var character = $TopHalf/SubViewport/GameWorld/CharacterBody2D

# Timeline UI elements
var timeline_buttons = {}

func _ready():
	# Initialize tracks with empty data
	for track_name in tracks.keys():
		tracks[track_name] = []
		for i in range(total_sixteenth_notes):
			tracks[track_name].append(false)
	
	# Setup UI
	record_button.pressed.connect(_on_record_pressed)
	play_button.pressed.connect(_on_play_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	
	# Create timeline buttons
	_create_timeline_ui()
	
	# Setup click track
	_setup_click_track()
	
	# Update display
	_update_bpm_display()

func _create_timeline_ui():
	# Create timeline buttons for each track
	var track_containers = {
		"move_right": $BottomHalf/TimelineContainer/TimelineGrid/TimelineTracks/MoveRightTrack,
		"move_left": $BottomHalf/TimelineContainer/TimelineGrid/TimelineTracks/MoveLeftTrack,
		"jump": $BottomHalf/TimelineContainer/TimelineGrid/TimelineTracks/JumpTrack
	}
	
	for track_name in tracks.keys():
		var track_container = track_containers[track_name]
		timeline_buttons[track_name] = []
		
		for i in range(total_sixteenth_notes):
			var button = Button.new()
			button.custom_minimum_size = Vector2(30, 30)
			button.text = ""
			button.toggle_mode = true
			button.pressed.connect(_on_timeline_button_pressed.bind(track_name, i))
			track_container.add_child(button)
			timeline_buttons[track_name].append(button)

func _setup_click_track():
	# For now, we'll use a simple approach without audio generation
	# The click track will be set up when needed during playback
	pass

func _on_record_pressed():
	if not is_recording and not is_playing:
		_start_recording()
	elif is_recording:
		_stop_recording()

func _on_play_pressed():
	if not is_recording and not is_playing:
		_start_playback()
	elif is_playing:
		_stop_playback()

func _on_stop_pressed():
	if is_recording:
		_stop_recording()
	if is_playing:
		_stop_playback()

func _start_recording():
	is_recording = true
	recording_start_time = Time.get_time_dict_from_system()["unix"]
	record_button.text = "Stop Recording"
	play_button.disabled = true
	
	# Clear previous recording
	for track_name in tracks.keys():
		for i in range(total_sixteenth_notes):
			tracks[track_name][i] = false
			timeline_buttons[track_name][i].button_pressed = false
			timeline_buttons[track_name][i].modulate = Color.WHITE

func _stop_recording():
	is_recording = false
	record_button.text = "Record"
	play_button.disabled = false

func _start_playback():
	is_playing = true
	current_time = 0.0
	play_button.text = "Stop Playback"
	record_button.disabled = true
	
	# Reset character position
	character.position = Vector2(576, 200)

func _stop_playback():
	is_playing = false
	current_time = 0.0
	play_button.text = "Play"
	record_button.disabled = false

func _on_timeline_button_pressed(track_name, index):
	if not is_recording:
		tracks[track_name][index] = timeline_buttons[track_name][index].button_pressed

func _process(delta):
	if is_recording:
		_process_recording(delta)
	elif is_playing:
		_process_playback(delta)

func _process_recording(_delta):
	var elapsed_time = Time.get_time_dict_from_system()["unix"] - recording_start_time
	var current_sixteenth = int(elapsed_time / sixteenth_note_time) % total_sixteenth_notes
	
	# Check for ANY key press during current sixteenth note
	if Input.is_anything_pressed():
		# Record on the move_right track for any key press
		tracks["move_right"][current_sixteenth] = true
		timeline_buttons["move_right"][current_sixteenth].button_pressed = true
		timeline_buttons["move_right"][current_sixteenth].modulate = Color.GREEN

func _process_playback(delta):
	current_time += delta
	var current_sixteenth = int(current_time / sixteenth_note_time) % total_sixteenth_notes
	
	# Play click track on beat
	if int(current_time / beat_time) != int((current_time - delta) / beat_time):
		_play_click()
	
	# Execute actions for current sixteenth note
	for track_name in tracks.keys():
		if tracks[track_name][current_sixteenth]:
			_execute_action(track_name)
	
	# Highlight current position in timeline
	_highlight_current_position(current_sixteenth)

func _execute_action(action):
	match action:
		"move_right":
			character.position.x += 32
		"move_left":
			character.position.x -= 32
		"jump":
			# Simple jump animation
			var tween = create_tween()
			tween.tween_property(character, "position:y", character.position.y - 50, 0.2)
			tween.tween_property(character, "position:y", character.position.y, 0.2)

func _play_click():
	# For now, we'll just print to console instead of playing audio
	print("Click!")
	# click_track.play()

func _highlight_current_position(sixteenth_note):
	# Reset all highlights
	for track_name in timeline_buttons.keys():
		for button in timeline_buttons[track_name]:
			button.modulate = Color.WHITE
	
	# Highlight current position
	for track_name in timeline_buttons.keys():
		if sixteenth_note < timeline_buttons[track_name].size():
			timeline_buttons[track_name][sixteenth_note].modulate = Color.YELLOW

func _update_bpm_display():
	bpm_display.text = str(bpm) + " BPM" 
