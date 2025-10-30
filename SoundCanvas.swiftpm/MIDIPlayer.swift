import AVFoundation
import Combine

class MIDIPlayer: ObservableObject {
    private var engine = AVAudioEngine()  
    private var sampler = AVAudioUnitSampler()
    
    init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        loadBuiltInPiano() 
        do {
            try engine.start()
        } catch {
            print("Error starting AVAudioEngine: \(error)")
        }
    }
    
    private func loadBuiltInPiano() {
        do {
            try sampler.loadInstrument(at: URL(fileURLWithPath: "/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls"))
            print("Built-in piano sound loaded successfully!")
        } catch {
            print("Error loading built-in piano sound: \(error)")
        }
    }

    
    func playNote(_ note: UInt8) {
        sampler.startNote(note, withVelocity: 80, onChannel: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.sampler.stopNote(note, onChannel: 0)
        }
    }
}

