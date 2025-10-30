import SwiftUI

extension Color {
    struct RGB {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
    }
    
    var components: RGB {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let uiColor = UIColor(self)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return RGB(red: Double(red),
                  green: Double(green),
                  blue: Double(blue),
                  alpha: Double(alpha))
    }
    
    func toRGBAString() -> String {
        let rgb = components
        return "\(rgb.red);\(rgb.green);\(rgb.blue);\(rgb.alpha)"
    }
    
    init(rgbaString: String) {
        let components = rgbaString.split(separator: ";").map { Double($0) ?? 0 }
        let red = components.count > 0 ? components[0] : 0
        let green = components.count > 1 ? components[1] : 0
        let blue = components.count > 2 ? components[2] : 0
        let alpha = components.count > 3 ? components[3] : 1
        
        self.init(.sRGB,
                 red: red,
                 green: green,
                 blue: blue,
                 opacity: alpha)
    }
}

struct DrawingPath: Codable, Hashable {
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    var coveredCells: Set<Int>

    init(points: [CGPoint], color: Color, lineWidth: CGFloat, coveredCells: Set<Int> = []) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.coveredCells = coveredCells
    }

    enum CodingKeys: String, CodingKey {
        case points
        case color
        case lineWidth
        case coveredCells
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(points.map { [$0.x, $0.y] }, forKey: .points)
        try container.encode(color.toRGBAString(), forKey: .color)
        try container.encode(lineWidth, forKey: .lineWidth)
        try container.encode(coveredCells, forKey: .coveredCells)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let pointsArray = try container.decode([[CGFloat]].self, forKey: .points)
        self.points = pointsArray.map { CGPoint(x: $0[0], y: $0[1]) }
        let colorString = try container.decode(String.self, forKey: .color)
        self.color = Color(rgbaString: colorString)
        self.lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
        self.coveredCells = try container.decode(Set<Int>.self, forKey: .coveredCells)
    }

    func hash(into hasher: inout Hasher) {
        points.forEach { hasher.combine([$0.x, $0.y]) }
        hasher.combine(color.toRGBAString())
        hasher.combine(lineWidth)
        hasher.combine(coveredCells)
    }

    static func == (lhs: DrawingPath, rhs: DrawingPath) -> Bool {
        return lhs.points == rhs.points &&
               lhs.color.toRGBAString() == rhs.color.toRGBAString() &&
               lhs.lineWidth == rhs.lineWidth &&
               lhs.coveredCells == rhs.coveredCells
    }
}
