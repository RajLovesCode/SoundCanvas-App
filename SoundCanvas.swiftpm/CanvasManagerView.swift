import SwiftUI

struct CanvasManagementView: View {
    @Binding var paths: [DrawingPath]
    @Binding var coveredCells: Set<Int>
    @Binding var showSaveDialog: Bool
    @Binding var showLoadDialog: Bool
    @Binding var currentCanvasName: String

    @State private var canvasName: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Manage SoundCanvases")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 16)
                
                Spacer()
                
                Button(action: {
                    showLoadDialog = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Canvas Name")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 15) {
                    TextField("Enter a name for your canvas", text: $canvasName)
                        .padding(12)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                    
                    Button(action: {
                        print("Save button tapped")
                        saveCanvas()
                    }) {
                        Text("Save")
                            .fontWeight(.semibold)
                            .frame(minWidth: 100)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(canvasName.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .disabled(canvasName.isEmpty)
                }
            }
            .padding(.horizontal)
            
            Text("Your Saved Canvases")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)
            
            List {
                ForEach(Array(CanvasManager.loadAllCanvases().keys).sorted(), id: \.self) { name in
                    CanvasListItem(
                        name: name,
                        openCanvas: openCanvas,
                        updateCanvas: updateCanvas,
                        deleteCanvas: deleteCanvas
                    )
                    .listRowBackground(Color(UIColor.secondarySystemGroupedBackground))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(10)
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func saveCanvas() {
        if !canvasName.isEmpty {
            CanvasManager.saveCanvas(paths: paths, coveredCells: coveredCells, withName: canvasName)
            currentCanvasName = canvasName
            alertMessage = "Canvas saved successfully!"
            showAlert = true
        }
    }

    private func updateCanvas(named name: String) {
        if !name.isEmpty {
            CanvasManager.saveCanvas(paths: paths, coveredCells: coveredCells, withName: name)
            alertMessage = "Canvas updated successfully!"
            showAlert = true
        }
    }

    private func openCanvas(named name: String) {
        print("Attempting to open canvas: \(name)")

        if let canvasData = CanvasManager.loadCanvas(withName: name) {
            paths = canvasData.paths
            coveredCells = canvasData.coveredCells
            currentCanvasName = name
            showLoadDialog = false
            alertMessage = "Canvas \(name) opened successfully!"
            showAlert = true
            print("Canvas \(name) opened successfully!")
        } else {
            alertMessage = "Failed to open the canvas."
            showAlert = true
        }
    }

    private func deleteCanvas(named name: String) {
        print("Attempting to delete canvas: \(name)")

        if CanvasManager.deleteCanvas(named: name) {
            if currentCanvasName == name {
                currentCanvasName = ""
            }
            alertMessage = "Canvas deleted successfully!"
            showAlert = true
            print("Canvas \(name) deleted successfully!")
        } else {
            alertMessage = "Failed to delete the canvas."
            showAlert = true
        }
    }
}

struct CanvasListItem: View {
    let name: String
    let openCanvas: (String) -> Void
    let updateCanvas: (String) -> Void
    let deleteCanvas: (String) -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                
                Text("Last modified: Today")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 10) {
                StyledButton(
                    title: "Open",
                    action: { openCanvas(name) },
                    backgroundColor: Color.blue,
                    iconName: "folder.open"
                )
                
                StyledButton(
                    title: "Update",
                    action: { updateCanvas(name) },
                    backgroundColor: Color.green,
                    iconName: "arrow.triangle.2.circlepath"
                )
                
                StyledButton(
                    title: "Delete",
                    action: { deleteCanvas(name) },
                    backgroundColor: Color.red,
                    iconName: "trash"
                )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct StyledButton: View {
    let title: String
    let action: () -> Void
    let backgroundColor: Color
    let iconName: String
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 13))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: backgroundColor.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .fixedSize()
    }
}

