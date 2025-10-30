import SwiftUI
struct CanvasManager {
    static let savedCanvasesKey = "savedCanvases"

    static func saveCanvas(paths: [DrawingPath], coveredCells: Set<Int>, withName name: String) {
        var savedCanvases = loadAllCanvases()
        savedCanvases[name] = CanvasData(paths: paths, coveredCells: coveredCells)
        if let data = try? JSONEncoder().encode(savedCanvases) {
            UserDefaults.standard.set(data, forKey: savedCanvasesKey)
        }
    }

    static func loadCanvas(withName name: String) -> CanvasData? {
        let savedCanvases = loadAllCanvases()
        return savedCanvases[name]
    }

    static func loadAllCanvases() -> [String: CanvasData] {
        if let data = UserDefaults.standard.data(forKey: savedCanvasesKey),
           let savedCanvases = try? JSONDecoder().decode([String: CanvasData].self, from: data) {
            return savedCanvases
        }
        return [:]
    }

    static func deleteCanvas(named name: String) -> Bool {
        var savedCanvases = loadAllCanvases()
        if savedCanvases.removeValue(forKey: name) != nil {
            if let data = try? JSONEncoder().encode(savedCanvases) {
                UserDefaults.standard.set(data, forKey: savedCanvasesKey)
            }
            return true
        }
        return false
    }

    struct CanvasData: Codable {
        var paths: [DrawingPath]
        var coveredCells: Set<Int>
    }
}

