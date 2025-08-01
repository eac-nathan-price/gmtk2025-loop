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
var is_playing = false
var recording_start_time = 0.0
var recording_elapsed_time = 0.0

# Tracks data - each track is an array of booleans for each sixteenth note
var tracks = {
	"move_right": [],
	"move_left": [],
	"jump": []
}

# Recording state for each track
var recording_tracks = {
	"move_right": false,
	"move_left": false,
	"jump": false
}

# Input mapping - we'll use any key press for recording
var input_map = {
	"move_right": "ui_right",
	"move_left": "ui_left", 
	"jump": "ui_accept"
}

# UI References
@onready var play_button = $BottomHalf/DAWHeader/PlayButton
@onready var stop_button = $BottomHalf/DAWHeader/StopButton
@onready var bpm_display = $BottomHalf/DAWHeader/BPMDisplay
@onready var click_track = $ClickTrack

# Record buttons for each track
@onready var record_right_button = $BottomHalf/TimelineContainer/TimelineGrid/TimelineTracks/MoveRightTrack/RecordRightButton
@onready var record_left_button = $BottomHalf/TimelineContainer/TimelineGrid/TimelineTracks/MoveLeftTrack/RecordLeftButton
@onready var record_jump_button = $BottomHalf/TimelineContainer/TimelineGrid/TimelineTracks/JumpTrack/RecordJumpButton

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
	record_right_button.pressed.connect(_on_record_right_pressed)
	record_left_button.pressed.connect(_on_record_left_pressed)
	record_jump_button.pressed.connect(_on_record_jump_pressed)
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
			button.custom_minimum_size = Vector2(8, 25)  # Much narrower buttons
			button.text = ""
			button.toggle_mode = true
			button.pressed.connect(_on_timeline_button_pressed.bind(track_name, i))
			track_container.add_child(button)
			timeline_buttons[track_name].append(button)

func _setup_click_track():
	# For now, we'll use a simple approach without audio generation
	# The click track will be set up when needed during playback
	pass

func _on_record_right_pressed():
	if not is_playing:
		if not recording_tracks["move_right"]:
			_start_recording_track("move_right")
		else:
			_stop_recording_track("move_right")

func _on_record_left_pressed():
	if not is_playing:
		if not recording_tracks["move_left"]:
			_start_recording_track("move_left")
		else:
			_stop_recording_track("move_left")

func _on_record_jump_pressed():
	if not is_playing:
		if not recording_tracks["jump"]:
			_start_recording_track("jump")
		else:
			_stop_recording_track("jump")

func _on_play_pressed():
	# Check if any track is recording
	var any_recording = false
	for track_name in recording_tracks.keys():
		if recording_tracks[track_name]:
			any_recording = true
			break
	
	if not any_recording and not is_playing:
		_start_playback()
	elif is_playing:
		_stop_playback()

func _on_stop_pressed():
	# Stop all recording
	for track_name in recording_tracks.keys():
		if recording_tracks[track_name]:
			_stop_recording_track(track_name)
	if is_playing:
		_stop_playback()

func _start_recording_track(track_name):
	recording_tracks[track_name] = true
	recording_start_time = Time.get_ticks_msec() / 1000.0
	recording_elapsed_time = 0.0
	
	# Update button text
	match track_name:
		"move_right":
			record_right_button.text = "Stop"
		"move_left":
			record_left_button.text = "Stop"
		"jump":
			record_jump_button.text = "Stop"
	
	# Clear previous recording for this track
	for i in range(total_sixteenth_notes):
		tracks[track_name][i] = false
		timeline_buttons[track_name][i].button_pressed = false
		timeline_buttons[track_name][i].modulate = Color.WHITE

func _stop_recording_track(track_name):
	recording_tracks[track_name] = false
	
	# Update button text
	match track_name:
		"move_right":
			record_right_button.text = "Record"
		"move_left":
			record_left_button.text = "Record"
		"jump":
			record_jump_button.text = "Record"

func _start_playback():
	is_playing = true
	current_time = 0.0
	play_button.text = "Stop Playback"
	
	# Disable all record buttons
	record_right_button.disabled = true
	record_left_button.disabled = true
	record_jump_button.disabled = true
	
	# Reset character position
	character.position = Vector2(576, 200)

func _stop_playback():
	is_playing = false
	current_time = 0.0
	play_button.text = "Play"
	
	# Enable all record buttons
	record_right_button.disabled = false
	record_left_button.disabled = false
	record_jump_button.disabled = false

func _on_timeline_button_pressed(track_name, index):
	# Check if any track is recording
	var any_recording = false
	for track_name_check in recording_tracks.keys():
		if recording_tracks[track_name_check]:
			any_recording = true
			break
	
	if not any_recording:
		tracks[track_name][index] = timeline_buttons[track_name][index].button_pressed

func _process(delta):
	# Check if any track is recording
	var any_recording = false
	for track_name in recording_tracks.keys():
		if recording_tracks[track_name]:
			any_recording = true
			break
	
	if any_recording:
		_process_recording(delta)
	elif is_playing:
		_process_playback(delta)

func _process_recording(delta):
	recording_elapsed_time += delta
	var current_sixteenth = int(recording_elapsed_time / sixteenth_note_time) % total_sixteenth_notes
	
	# Check for ANY key press during current sixteenth note
	if Input.is_anything_pressed():
		# Record on all currently recording tracks
		for track_name in recording_tracks.keys():
			if recording_tracks[track_name]:
				tracks[track_name][current_sixteenth] = true
				timeline_buttons[track_name][current_sixteenth].button_pressed = true
				timeline_buttons[track_name][current_sixteenth].modulate = Color.GREEN

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
