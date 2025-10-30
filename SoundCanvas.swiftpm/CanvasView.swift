import SwiftUI

extension Color {
    init(colorhex: String) {
        let hexSanitized = colorhex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexSanitized)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

struct CanvasView: View {
    @Binding var brushSize: CGFloat
    @Binding var selectedColor: Color
    @Binding var paths: [DrawingPath]
    @Binding var currentPath: DrawingPath
    @Binding var undoStack: [DrawingPath]
    @Binding var redoStack: [DrawingPath]
    @Binding var coveredCells: Set<Int>
    @Binding var undoCellStack: [Set<Int>]
    @Binding var redoCellStack: [Set<Int>]
    @Binding var scale: [UInt8]
    @Binding var mood: String
    @Binding var showGridOverlay: Bool
    
    @State private var geometrySize: CGSize = .zero
    @StateObject private var midiPlayer = MIDIPlayer()
    @State private var isCanvasPressed = false
    
    private let rows = 24
    private let columns = 32
    
    private let moodGradients: [String: [Color]] = [
        "Happy": [
            Color(red: 1.0, green: 0.95, blue: 0.4),
            Color(red: 1.0, green: 0.85, blue: 0.2),
            Color(red: 1.0, green: 0.7, blue: 0.0)
        ],
        "Sad": [
            Color(red: 0.2, green: 0.3, blue: 0.4),
            Color(red: 0.1, green: 0.15, blue: 0.25),
            Color(red: 0.05, green: 0.05, blue: 0.15)
        ],
        "Peaceful": [
            Color(red: 0.8, green: 0.95, blue: 0.9),
            Color(red: 0.7, green: 0.9, blue: 0.95),
            Color(red: 0.6, green: 0.85, blue: 0.9)
        ],
        "Excited": [
            Color(red: 1.0, green: 0.4, blue: 0.4),
            Color(red: 1.0, green: 0.2, blue: 0.3),
            Color(red: 0.9, green: 0.0, blue: 0.2)
        ],
        "Energetic": [
            Color(red: 1.0, green: 0.6, blue: 0.0),
            Color(red: 1.0, green: 0.4, blue: 0.0),
            Color(red: 1.0, green: 0.2, blue: 0.0)
        ],
        "Mysterious": [
            Color(red: 0.4, green: 0.2, blue: 0.6),
            Color(red: 0.25, green: 0.1, blue: 0.5),
            Color(red: 0.15, green: 0.05, blue: 0.4)
        ],
        "Epic": [
            Color(red: 0.8, green: 0.1, blue: 0.2),
            Color(red: 0.6, green: 0.0, blue: 0.1),
            Color(red: 0.4, green: 0.0, blue: 0.05)
        ]
    ]
    
    private func updateCurrentPath() {
        currentPath.color = selectedColor
        currentPath.lineWidth = brushSize
    }
    
    private func noteForCell(column: Int, row: Int) -> UInt8 {
        let mirroredRow = (rows - 1) - row
        let octave = mirroredRow / 7
        let positionInScale = mirroredRow % 7
        let baseNote = scale[positionInScale]
        let noteWithOctave = baseNote + UInt8(octave * 12)
        return noteWithOctave
    }

    
    var body: some View {
        ZStack {
            LinearGradient(
                           gradient: Gradient(colors: moodGradients[mood] ?? [Color.white, Color.gray]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing
                       )
                       .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
              
                HStack {
                    Text("SoundCanvas")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(colorhex: "#1976D2"))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.9))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.top)
                .offset(y:20)
                
               
                GeometryReader { geometry in
                    ZStack {
                      
                        Group {
                           
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .frame(width: geometry.size.width - 40, height: geometry.size.height - 180)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(colorhex: "#2196F3"),
                                                    Color(colorhex: "#1976D2")
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: isCanvasPressed ? 6 : 4
                                        )
                                )
                                .animation(.easeInOut(duration: 0.2), value: isCanvasPressed)
                                .padding(20)
                            
                          
                            GridOverlay(
                                canvasWidth: geometry.size.width - 40,
                                canvasHeight: geometry.size.height - 180,
                                coveredCells: $coveredCells,
                                scale: $scale,
                                showGridOverlay: $showGridOverlay
                            )
                            .padding(20)
                            .offset(y: 70)
                        }
                        .offset(y: -10)
                        
                       
                        ForEach(paths, id: \.self) { path in
                            Path { pathShape in
                                for (index, point) in path.points.enumerated() {
                                    if index == 0 {
                                        pathShape.move(to: point)
                                    } else {
                                        pathShape.addLine(to: point)
                                    }
                                }
                            }
                            .stroke(path.color, lineWidth: path.lineWidth)
                            .shadow(color: path.color.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                        
                      
                        Path { pathShape in
                            for (index, point) in currentPath.points.enumerated() {
                                if index == 0 {
                                    pathShape.move(to: point)
                                } else {
                                    pathShape.addLine(to: point)
                                }
                            }
                        }
                        .stroke(currentPath.color, lineWidth: currentPath.lineWidth)
                        .shadow(color: currentPath.color.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isCanvasPressed = true
                                currentPath.points.append(value.location)
                                updateCurrentPath()
                                
                                let canvasWidth = geometry.size.width - 40
                                let canvasHeight = geometry.size.height - 180
                                let cellWidth = canvasWidth / CGFloat(columns)
                                let cellHeight = canvasHeight / CGFloat(rows)
                                
                                let xIndex = Int((value.location.x - 20) / cellWidth)
                                var yIndex = Int((value.location.y - 90) / cellHeight)
                                yIndex = max(0, min(yIndex, rows - 1))
                                
                                if xIndex >= 0 && xIndex < columns {
                                    let noteToPlay = noteForCell(column: xIndex, row: yIndex)
                                    midiPlayer.playNote(noteToPlay)
                                    
                                    let cellIndex = yIndex * columns + xIndex
                                    coveredCells.insert(cellIndex)
                                    currentPath.coveredCells.insert(cellIndex)
                                }
                            }
                            .onEnded { _ in
                                isCanvasPressed = false
                                paths.append(currentPath)
                                currentPath = DrawingPath(points: [], color: selectedColor, lineWidth: brushSize)
                                undoCellStack.append(coveredCells)
                                redoStack.removeAll()
                                redoCellStack.removeAll()
                            }
                    )
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

struct GridOverlay: View {
    let columns = 32
    let rows = 24
    let canvasWidth: CGFloat
    let canvasHeight: CGFloat
    @Binding var coveredCells: Set<Int>
    @Binding var scale: [UInt8]
    @Binding var showGridOverlay: Bool
    
    private func noteForCell(column: Int, row: Int) -> UInt8 {
        let mirroredRow = (rows - 1) - row
        let octave = mirroredRow / 7
        let positionInScale = mirroredRow % 7
        let baseNote = scale[positionInScale]
        let noteWithOctave = baseNote + UInt8(octave * 12)
        return noteWithOctave
    }

    
    var body: some View {
        let cellWidth = canvasWidth / CGFloat(columns)
        let cellHeight = canvasHeight / CGFloat(rows)
        
        ZStack {
            
            Path { path in
                for i in 0...columns {
                    let x = CGFloat(i) * cellWidth
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: canvasHeight))
                }
                
                for i in 0...rows {
                    let y = CGFloat(i) * cellHeight
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: canvasWidth, y: y))
                }
            }
            .stroke(Color.black.opacity(showGridOverlay ? 0.2 : 0), lineWidth: 0.5)
            .animation(.easeInOut(duration: 0.3), value: showGridOverlay)
            
            
            ForEach(0..<rows, id: \.self) { row in
                ForEach(0..<columns, id: \.self) { column in
                    let cellIndex = row * columns + column
                    let isActive = coveredCells.contains(cellIndex)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .opacity(isActive ? (showGridOverlay ? 0.3 : 0) : 0)
                        .frame(width: cellWidth - 1, height: cellHeight - 1)
                        .position(x: CGFloat(column) * cellWidth + cellWidth / 2,
                                y: CGFloat(row) * cellHeight + cellHeight / 2)
                        .animation(.easeInOut(duration: 0.2), value: isActive)
                }
            }
        }
    }
}
