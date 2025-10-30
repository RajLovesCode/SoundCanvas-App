import SwiftUI

struct ToolbarView: View {
    @Binding var canvasBrushSize: CGFloat
    @Binding var canvasColor: Color
    @Binding var paths: [DrawingPath]
    @Binding var currentPath: DrawingPath
    @Binding var undoStack: [DrawingPath]
    @Binding var redoStack: [DrawingPath]
    @Binding var coveredCells: Set<Int>
    @Binding var undoCellStack: [Set<Int>]
    @Binding var redoCellStack: [Set<Int>]
    @Binding var bpm: Double
    @Binding var mood: String
    @Binding var scale: [UInt8]
    @Binding var showGridOverlay: Bool
    @Binding var showSaveDialog: Bool
    @Binding var showLoadDialog: Bool

    @StateObject private var midiPlayer = MIDIPlayer()
    @State private var showInfoCard = false
    @State private var allCoveredCells: Set<Int> = []

    private let moodScales: [String: [UInt8]] = [
        "Happy": [42, 44, 46, 47, 49, 51, 53],
        "Sad": [42, 44, 45, 47, 49, 50, 52],
        "Peaceful": [42, 44, 46, 48, 49, 51, 53],
        "Excited": [42, 46, 49, 54, 58, 61, 66],
        "Energetic": [42, 44, 46, 49, 51, 53, 55],
        "Mysterious": [42, 46, 50, 54, 58, 62, 66],
        "Epic": [42, 44, 46, 48, 50, 51, 53]
    ]


    private func undoAction() {
        if let lastPath = paths.popLast() {
            undoStack.append(lastPath)
            for cell in lastPath.coveredCells {
                coveredCells.remove(cell)
            }
            undoCellStack.append(coveredCells)
        }
    }

    private func redoAction() {
        if let lastUndonePath = undoStack.popLast() {
            redoStack.append(lastUndonePath)
            paths.append(lastUndonePath)
            for cell in lastUndonePath.coveredCells {
                coveredCells.insert(cell)
            }
            redoCellStack.append(coveredCells)
        }
    }

    private func clearCoveredCells() {
        coveredCells.removeAll()
        undoCellStack.removeAll()
        redoCellStack.removeAll()
    }

    private func updateCoveredCells() {
        allCoveredCells = Set(paths.flatMap { $0.coveredCells })
    }

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 15) {
                // Drawing tools
                brushSizeSlider
                
                colorPicker
                
                Divider()
                    .frame(height: 40)
                    .background(Color.gray.opacity(0.5))
                
                // Music controls
                bpmSlider
                
                moodSelector
                
                PlayButtonView(midiPlayer: midiPlayer, coveredCells: $coveredCells, bpm: $bpm, scale: $scale)
                    .frame(width: 40, height: 40)
                
                Divider()
                    .frame(height: 40)
                    .background(Color.gray.opacity(0.5))
                
                // General controls 
                undoRedoButtons
                
                clearScreenButton
                
                toggleGridButton
                
                loadButton
                
                infoCardButton
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(
                Color.black.opacity(0.8)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            )
            .shadow(radius: 10)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .onChange(of: paths) { _ in
            updateCoveredCells()
        }
    }
    
    struct ToolbarButtonStyle: ButtonStyle {
        var isSelected: Bool = false
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(.white)
                .padding(8)
                .background(
                    isSelected ? Color.blue.opacity(0.7) :
                    configuration.isPressed ? Color.gray.opacity(0.8) : Color.gray.opacity(0.6)
                )
                .clipShape(Circle())
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.spring(), value: configuration.isPressed)
        }
    }


    private var brushSizeSlider: some View {
        HStack {
            Text("Size: \(Int(canvasBrushSize))")
                .font(.caption)
                .foregroundColor(.white)
            
            HStack(spacing: 5) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.white)
                
                Slider(value: $canvasBrushSize, in: 1...30)
                    .frame(width: 90)
                    .accentColor(.blue)
                
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.white)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
    }

    private var bpmSlider: some View {
        HStack {
            Text("Speed: \(Int(bpm)) ")
                .font(.caption)
                .foregroundColor(.white)
            
            HStack(spacing: 5) {
                Image(systemName: "tortoise.fill")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.white)
                
                Slider(value: $bpm, in: 60...400)
                    .frame(width: 90)
                    .accentColor(.green)
                
                Image(systemName: "hare.fill")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.white)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
        .help("Adjust playback speed")
    }

    private func moodIcon(for mood: String) -> String {
        switch mood {
        case "Happy": return "sun.max.fill"
        case "Sad": return "cloud.rain.fill"
        case "Peaceful": return "leaf.fill"
        case "Excited": return "star.fill"
        case "Energetic": return "bolt.fill"
        case "Mysterious": return "moon.stars.fill"
        case "Epic": return "flame.fill"
        default: return "music.note"
        }
    }

    private var moodSelector: some View {
        HStack {
            Text("Mood")
                .font(.caption)
                .foregroundColor(.white)
            
            Menu {
                ForEach(moodScales.keys.sorted(), id: \.self) { mood in
                    Button(action: {
                        scale = moodScales[mood] ?? [42, 44, 46, 47, 49, 51, 53]
                        self.mood = mood
                    }) {
                        Label(mood, systemImage: moodIcon(for: mood))
                    }
                }
            } label: {
                HStack {
                    Image(systemName: moodIcon(for: mood))
                    Text(mood)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
        .help("Select musical mood")
    }

    private var colorPicker: some View {
        HStack {
            Text("Color")
                .font(.caption)
                .foregroundColor(.white)
            
            ColorPicker("", selection: $canvasColor)
                .frame(width: 30, height: 30)
                .accentColor(.blue)
                .labelsHidden()
        }
        .padding(8)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
        .help("Select drawing color")
    }

    private var undoRedoButtons: some View {
        HStack(spacing: 10) {
            Button(action: undoAction) {
                Image(systemName: "arrow.uturn.left.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(ToolbarButtonStyle())
            .help("Undo last action")
            .disabled(paths.isEmpty)
            
            Button(action: redoAction) {
                Image(systemName: "arrow.uturn.right.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(ToolbarButtonStyle())
            .help("Redo last action")
            .disabled(undoStack.isEmpty)
        }
    }

    private var clearScreenButton: some View {
        Button(action: {
            paths.removeAll()
            undoStack.removeAll()
            redoStack.removeAll()
            clearCoveredCells()
        }) {
            Image(systemName: "trash.fill")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.red)
        }
        .buttonStyle(ToolbarButtonStyle())
        .help("Clear all drawings")
    }

    private var toggleGridButton: some View {
        Button(action: {
            showGridOverlay.toggle()
        }) {
            Image(systemName: showGridOverlay ? "eye.slash" : "eye")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .buttonStyle(ToolbarButtonStyle())
        .help(showGridOverlay ? "Hide grid" : "Show grid")
    }
    
    private var loadButton: some View {
        Button(action: {
            showLoadDialog = true
        }) {
            Image(systemName: "folder")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .buttonStyle(ToolbarButtonStyle())
        .help("Load drawing")
    }

    private var infoCardButton: some View {
        Button(action: {
            showInfoCard.toggle()
        }) {
            Image(systemName: "info.circle")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .buttonStyle(ToolbarButtonStyle())
        .help("Show info")
        .sheet(isPresented: $showInfoCard) {
            InfoCardView()
        }
    }
}
