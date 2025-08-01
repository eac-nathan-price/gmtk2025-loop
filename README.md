# GMTK2025 Loop - DAW-Style Character Recording System

A Godot project that combines character movement with a DAW (Digital Audio Workstation) style timeline for recording and playing back character actions.

## Features

- **Split Screen Interface**: Top half shows the character and tilemap, bottom half shows the DAW timeline
- **120 BPM Click Track**: Metronome-style timing for precise recording
- **Multiple Tracks**: Record different actions on separate tracks
  - Move Right (D key)
  - Move Left (A key) 
  - Jump (Spacebar)
- **16th Note Grid**: Each track is divided into 16th notes (64 total for 4 bars)
- **Real-time Recording**: Record your inputs in real-time with visual feedback
- **Playback System**: Play back recorded sequences with character movement

## How to Use

### Step 1: Open the Project
1. Open Godot 4.x
2. Click "Import" and select the `project.godot` file
3. Click "Import & Edit"

### Step 2: Run the Project
1. Press F5 or click the "Play" button in the top-right corner
2. The project will open with the split-screen interface

### Step 3: Recording
1. Click the "Record" button to start recording
2. The timeline will clear and you'll see a 120 BPM click track
3. Use the following controls to record actions:
   - **D key**: Move Right (records on Move Right track)
   - **A key**: Move Left (records on Move Left track)
   - **Spacebar**: Jump (records on Jump track)
4. Each 16th note will light up green when you press a key during that time
5. Click "Stop Recording" when you're done

### Step 4: Playback
1. Click the "Play" button to start playback
2. The character will execute all recorded actions in sequence
3. The current position will be highlighted in yellow on the timeline
4. The click track will play on each beat
5. Click "Stop" to stop playback

### Step 5: Manual Editing
- When not recording, you can click on any timeline button to manually toggle actions
- This allows you to fine-tune your recordings

## Controls

- **D**: Move Right / Record Move Right
- **A**: Move Left / Record Move Left  
- **Spacebar**: Jump / Record Jump
- **Record Button**: Start/Stop recording
- **Play Button**: Start/Stop playback
- **Stop Button**: Stop current operation

## Technical Details

- **BPM**: 120 beats per minute
- **Time Signature**: 4/4
- **Grid Resolution**: 16th notes
- **Total Length**: 4 bars (64 sixteenth notes)
- **Character Movement**: 32 pixels per action
- **Jump Animation**: Simple tween-based jump

## File Structure

- `main.tscn`: Main scene with split-screen layout
- `scripts/main_controller.gd`: DAW system and timeline management
- `scripts/character_controller.gd`: Character physics and movement
- `scripts/tilemap_setup.gd`: Level setup with platforms
- `project.godot`: Project configuration

## Tips

1. **Practice with the Click Track**: Listen to the 120 BPM click to get familiar with the timing
2. **Plan Your Sequence**: Think about what movements you want before recording
3. **Use Manual Editing**: Fine-tune your recordings by clicking timeline buttons
4. **Experiment**: Try different combinations of movements and jumps
5. **Watch the Character**: The green character will show you exactly what's being recorded

## Troubleshooting

- **Character not moving**: Make sure you're pressing the correct keys (D, A, Spacebar)
- **Timeline not updating**: Check that you're in recording mode
- **Playback not working**: Ensure you have recorded some actions first
- **Audio issues**: Check your system volume and Godot audio settings

Enjoy creating rhythmic character sequences! 