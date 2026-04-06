import AVFoundation
import UIKit

// MARK: - SoundManager
// Handles audio playback and haptic feedback for the chess app.
// Place sound files in the Sounds folder with these names:
// - move.mp3 (or .wav) - regular piece move
// - capture.mp3 - piece capture
// - success.mp3 - puzzle solved correctly
// - failure.mp3 - wrong move

final class SoundManager {
    
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    // Settings
    var soundEnabled: Bool = true
    var hapticEnabled: Bool = true
    
    private init() {
        // Configure audio session to play sounds even in silent mode
        configureAudioSession()
        
        // Prepare haptic generators for lower latency
        hapticGenerator.prepare()
        notificationGenerator.prepare()
        
        // Preload common sounds
        preloadSound("move")
        preloadSound("capture")
        preloadSound("castle")
        preloadSound("success")
        preloadSound("failure")
    }
    
    /// Configure audio session to play sounds
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            print("✅ Audio session configured successfully")
        } catch {
            print("⚠️ Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sound Playback
    
    /// Preload a sound file into memory for instant playback
    private func preloadSound(_ name: String) {
        // Try multiple ways to find the sound file
        var url: URL? = nil
        
        // Try 1: Sounds subdirectory with mp3
        url = Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "Sounds")
        
        // Try 2: Sounds subdirectory with wav
        if url == nil {
            url = Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Sounds")
        }
        
        // Try 3: Root level with mp3 (in case files were added as groups)
        if url == nil {
            url = Bundle.main.url(forResource: name, withExtension: "mp3")
        }
        
        // Try 4: Root level with wav
        if url == nil {
            url = Bundle.main.url(forResource: name, withExtension: "wav")
        }
        
        // Try 5: With Sounds/ prefix in resource name
        if url == nil {
            url = Bundle.main.url(forResource: "Sounds/\(name)", withExtension: "mp3")
        }
        
        guard let soundURL = url else {
            print("⚠️ Sound file not found anywhere: \(name).mp3 or \(name).wav")
            print("   Searched in: subdirectory 'Sounds', root level, and 'Sounds/' prefix")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.prepareToPlay()
            audioPlayers[name] = player
            print("✅ Loaded sound: \(name) from \(soundURL.lastPathComponent)")
        } catch {
            print("⚠️ Failed to load sound: \(name) - \(error.localizedDescription)")
        }
    }
    
    /// Play a sound by name
    func playSound(_ name: String, volume: Float = 1.0) {
        guard soundEnabled else {
            print("🔇 Sound disabled, not playing: \(name)")
            return
        }
        
        if let player = audioPlayers[name] {
            player.volume = volume
            player.currentTime = 0
            let success = player.play()
            print("🔊 Playing sound: \(name) (volume: \(volume)) - success: \(success)")
        } else {
            print("⚠️ Sound not loaded: \(name), attempting to load...")
            // Try to load and play if not preloaded
            preloadSound(name)
            if let player = audioPlayers[name] {
                player.volume = volume
                let success = player.play()
                print("🔊 Playing sound after load: \(name) - success: \(success)")
            } else {
                print("❌ Failed to play sound: \(name) - not found")
            }
        }
    }
    
    // MARK: - Haptic Feedback
    
    /// Light haptic feedback (for regular moves)
    func hapticLight() {
        guard hapticEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium haptic feedback (for captures, selections)
    func hapticMedium() {
        guard hapticEnabled else { return }
        hapticGenerator.impactOccurred()
    }
    
    /// Heavy haptic feedback (for important events)
    func hapticHeavy() {
        guard hapticEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Success haptic (puzzle solved)
    func hapticSuccess() {
        guard hapticEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
    
    /// Error haptic (wrong move)
    func hapticError() {
        guard hapticEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Convenience Methods
    
    /// Play move sound with haptic feedback
    func playMove(isCapture: Bool = false, isCastle: Bool = false) {
        if isCastle {
            playSound("castle", volume: 0.7)
            hapticMedium()
        } else if isCapture {
            playSound("capture", volume: 0.8)
            hapticMedium()
        } else {
            playSound("move", volume: 0.6)
            hapticLight()
        }
    }
    
    /// Play success sound with haptic feedback
    func playSuccess() {
        playSound("success", volume: 0.3)
        hapticSuccess()
    }
    
    /// Play failure sound with haptic feedback
    func playFailure() {
        playSound("failure", volume: 0.1)
        hapticError()
    }
    
    /// Play piece selection sound
    func playSelection() {
        hapticLight()
    }
}
