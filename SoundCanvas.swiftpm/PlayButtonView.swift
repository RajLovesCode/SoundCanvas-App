import SwiftUI

struct PlayButtonView: View {
    @ObservedObject var midiPlayer: MIDIPlayer
    @Binding var coveredCells: Set<Int>
    @Binding var bpm: Double
    @Binding var scale: [UInt8]

    private let columns = 32
    private let rows = 24

    var body: some View {
        Button(action: {
            playSequence()
        }) {
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.green)
                .padding()
        }
    }

    private func playSequence() {
        let timeInterval = 60.0 / bpm

        DispatchQueue.global(qos: .userInitiated).async {
            for column in 0..<columns {
                DispatchQueue.main.async {
                    playColumn(column)
                }
                Thread.sleep(forTimeInterval: timeInterval) 
            }
        }
    }

    private func playColumn(_ column: Int) {
        for row in 0..<rows {
            let cellIndex = row * columns + column
            if coveredCells.contains(cellIndex) {
                let noteToPlay = noteForCell(column: column, row: row)
                midiPlayer.playNote(noteToPlay)
            }
        }
    }

    private func noteForCell(column: Int, row: Int) -> UInt8 {
        let mirroredRow = (rows - 1) - row
        let octave = mirroredRow / 7
        let positionInScale = mirroredRow % 7
        let baseNote = scale[positionInScale]
        let noteWithOctave = baseNote + UInt8(octave * 12)
        return noteWithOctave
    }
}

