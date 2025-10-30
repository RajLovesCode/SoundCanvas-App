import SwiftUI

struct ContentView: View {
    @State private var brushSize: CGFloat = 5
    @State private var selectedColor: Color = .black

    @State private var paths: [DrawingPath] = [] {
        didSet {
            autoSaveCanvas()
        }
    }
    @State private var currentPath = DrawingPath(points: [], color: .black, lineWidth: 5)

    @State private var undoStack: [DrawingPath] = []
    @State private var redoStack: [DrawingPath] = []

    @State private var coveredCells: Set<Int> = [] {
        didSet {
            autoSaveCanvas()
        }
    }
    @State private var undoCellStack: [Set<Int>] = []
    @State private var redoCellStack: [Set<Int>] = []

    @State private var isPlaying: Bool = false
    @State private var bpm: Double = 100
    @State private var mood: String = "Happy"
    @State private var scale: [UInt8] = [42, 44, 46, 47, 49, 51, 53]

    @State private var showGridOverlay: Bool = true

    @State private var showSaveDialog: Bool = false
    @State private var showLoadDialog: Bool = false

    @State private var currentCanvasName: String = ""

    var body: some View {
        ZStack {
            CanvasView(
                brushSize: $brushSize,
                selectedColor: $selectedColor,
                paths: $paths,
                currentPath: $currentPath,
                undoStack: $undoStack,
                redoStack: $redoStack,
                coveredCells: $coveredCells,
                undoCellStack: $undoCellStack,
                redoCellStack: $redoCellStack,
                scale: $scale,
                mood: $mood,
                showGridOverlay: $showGridOverlay
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                ToolbarView(
                    canvasBrushSize: $brushSize,
                    canvasColor: $selectedColor,
                    paths: $paths,
                    currentPath: $currentPath,
                    undoStack: $undoStack,
                    redoStack: $redoStack,
                    coveredCells: $coveredCells,
                    undoCellStack: $undoCellStack,
                    redoCellStack: $redoCellStack,
                    bpm: $bpm,
                    mood: $mood,
                    scale: $scale,
                    showGridOverlay: $showGridOverlay,
                    showSaveDialog: $showSaveDialog,
                    showLoadDialog: $showLoadDialog
                )
                .frame(height: 100)
            }
        }
        .sheet(isPresented: $showSaveDialog) {
            CanvasManagementView(paths: $paths, coveredCells: $coveredCells, showSaveDialog: $showSaveDialog, showLoadDialog: $showLoadDialog, currentCanvasName: $currentCanvasName)
        }
        .sheet(isPresented: $showLoadDialog) {
            CanvasManagementView(paths: $paths, coveredCells: $coveredCells, showSaveDialog: $showSaveDialog, showLoadDialog: $showLoadDialog, currentCanvasName: $currentCanvasName)
        }
    }

    private func autoSaveCanvas() {
        if !currentCanvasName.isEmpty {
            CanvasManager.saveCanvas(paths: paths, coveredCells: coveredCells, withName: currentCanvasName)
        }
    }
}

