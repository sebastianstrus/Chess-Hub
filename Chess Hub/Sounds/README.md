# Sound Files for Chess Hub

This folder contains audio files for the Chess Hub app.

## Required Sound Files

Add the following sound files to this folder in either **MP3** or **WAV** format:

### 1. **move.mp3** (or move.wav)
- **When it plays**: Regular piece movement (non-capture)
- **Suggested sound**: Soft piece sliding sound, short click
- **Duration**: 0.2-0.5 seconds
- **Volume**: Medium-low

### 2. **capture.mp3** (or capture.wav)
- **When it plays**: When a piece captures another piece
- **Suggested sound**: Sharper click, more pronounced than regular move
- **Duration**: 0.2-0.5 seconds
- **Volume**: Medium

### 3. **castle.mp3** (or castle.wav)
- **When it plays**: When castling (king moves 2 squares, rook jumps over)
- **Suggested sound**: Double click or distinctive castling sound
- **Duration**: 0.3-0.6 seconds
- **Volume**: Medium

### 4. **success.mp3** (or success.wav)
- **When it plays**: When puzzle is solved correctly (all moves completed)
- **Suggested sound**: Positive chime, victory sound, pleasant bell
- **Duration**: 0.5-1.5 seconds
- **Volume**: Medium-high

### 5. **failure.mp3** (or failure.wav)
- **When it plays**: When player makes a wrong move
- **Suggested sound**: Short error buzz, negative tone (not too harsh)
- **Duration**: 0.3-0.8 seconds
- **Volume**: Medium

## Audio Format Recommendations

- **Format**: MP3 or WAV (MP3 recommended for smaller file size)
- **Sample Rate**: 44.1 kHz
- **Bit Rate**: 128-192 kbps for MP3
- **Channels**: Mono or Stereo (Mono is fine for these short sounds)

## Sound Design Tips

- Keep sounds **short and crisp** to avoid overlapping
- Use **professional chess app sounds** as reference (Lichess, Chess.com)
- Test on actual device with volume at different levels
- Sounds should feel satisfying but not distracting

## Free Sound Resources

You can find royalty-free sounds at:
- Freesound.org
- Zapsplat.com
- Mixkit.co
- Lichess open source assets

## Adding Sounds to Xcode

1. Drag and drop all 5 sound files into this `Sounds` folder in Xcode
2. In the dialog that appears, make sure:
   - ✅ "Copy items if needed" is checked
   - ✅ "Chess Hub" target is selected
   - ✅ "Create folder references" is selected
3. Build and run the app - sounds will play automatically!

## Disabling Sounds/Haptics

Users can disable sounds or haptic feedback by modifying `SoundManager.swift`:

```swift
SoundManager.shared.soundEnabled = false  // Disable sounds
SoundManager.shared.hapticEnabled = false // Disable haptics
```

(In the future, you can add UI settings for this in the app)
